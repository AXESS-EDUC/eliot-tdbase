/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tdbase.xml

import org.lilie.services.eliot.tdbase.xml.transformation.MoodleQuizTransformer
import org.lilie.services.eliot.tice.annuaire.Personne
import org.springframework.web.multipart.MultipartFile
import org.lilie.services.eliot.tdbase.*

/**
 * Service d'import d'un quiz moodle
 * @author franck Silvestre
 */
class MoodleQuizImporterService {

  static transactional = false

  MoodleQuizTransformer moodleQuizTransformer
  QuestionService questionService
  ArtefactAutorisationService artefactAutorisationService

  /**
   * Import les items issus d'un fichier XML moodle dans un sujet donné
   * @param xmlMoodle l'inputstream correspondant au fichier XML Moodle
   * @param sujet le sujet dans lequel on importe les questions
   * @param importeur la personne déclenchant l'import
   * @return  le rapport d'import
   */
  MoodleQuizImportReport importMoodleQuiz(MultipartFile xmlMoodle, Sujet sujet, Personne importeur) {

    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet))
    //
    // la transformation
    //
    Map map
    try {
      map = moodleQuizTransformer.moodleQuizTransform(xmlMoodle.inputStream)
    } catch (Exception e) {
      log.error(e.message)
      throw new Exception("xml.import.moodle.echec")
    }
    MoodleQuizImportReport report = new MoodleQuizImportReport()
    report.nombreItemsTraites = map.quiz[0].nombreItems
    //
    // Traitement des items
    //
    for (int i = 1; i < map.quiz.size(); i++) {
      def item = map.quiz[i]
      def importItem = new ImportItem()
      importItem.titre = item.titre
      importItem.questionTypeCode = item.questionTypeCode
      QuestionTypeEnum questionTypeEnum = QuestionTypeEnum.valueOf(item.questionTypeCode)
      if (questionTypeEnum == null) {
        importItem.erreurImport = "xml.import.moodle.item.typenonsupporte"
        report.itemsNonImportes << importItem
        continue
      }
      QuestionSpecificationService specService = questionService.questionSpecificationServiceForQuestionType(questionTypeEnum.questionType)
      // permet de securiser l'import :
      // on traduit en objet specification
      // on reutilise le Question service
      def objSpec
      try {
        objSpec = specService.getObjectFromSpecification(item.specification)
      } catch (Exception e1) {
        log.error(e1.message)
        importItem.erreurImport = "xml.import.moodle.item.specificationincorrecte"
        report.itemsNonImportes << importItem
        continue
      }
      // l'import en base correspond à une création de question et à une
      // insertion dans le sujet passé en paramètre
      Question question = questionService.createQuestionAndInsertInSujet(
              [
                      titre: item.titre,
                      typeId: questionTypeEnum.id
              ],
              objSpec,
              sujet,
              importeur
      )
      if (question.hasErrors()) {
        log.error(question.errors.allErrors.toListString())
        importItem.erreurImport = "xml.import.moodle.item.loadfail"
        report.itemsNonImportes << importItem
        continue
      }

      report.itemsImportes << importItem
    }
  }


}

/**
 * Classe représentant un rapport d'import de quiz Moodle XML
 */
class MoodleQuizImportReport {
  Integer nombreItemsTraites = 0

  List<ImportItem> itemsImportes = []
  List<ImportItem> itemsNonImportes = []

}

class ImportItem {
  String titre
  String questionTypeCode
  String erreurImport
}