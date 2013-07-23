package org.lilie.services.eliot.tdbase.importexport.natif

import grails.converters.JSON
import org.lilie.services.eliot.tdbase.ArtefactAutorisationService
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionType
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionDto
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.QuestionMarshaller
import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau

/**
 * Service d'import de questions au format JSON natif eliot-tdbase
 * @author John Tranier
 */
class QuestionImporterService {

  static transactional = true

  ArtefactAutorisationService artefactAutorisationService
  QuestionService questionService
  AttachementImporterService attachementImporterService

  /**
   * Importe une question depuis un fichier JSON au format natif eliot-tdbase
   * dans un sujet
   */
  Question importeQuestion(byte[] jsonBlob,
                           Sujet sujet,
                           Personne importeur,
                           Matiere matiere = null,
                           Niveau niveau = null) {
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet))

    QuestionDto questionDto = QuestionMarshaller.parse(
        JSON.parse(new ByteArrayInputStream(jsonBlob), 'UTF-8')
    )

    // Récupération du QuestionType & du QuestionSpecificationService
    QuestionType questionType = QuestionTypeEnum.valueOf(questionDto.type).questionType
    QuestionSpecificationService specService = questionService.questionSpecificationServiceForQuestionType(
        questionType
    )

    // Récupération du copyrightsType
    CopyrightsType copyrightsType = CopyrightsTypeEnum.parseFromCode(
        questionDto.copyrightsType.code
    ).copyrightsType

    // permet de securiser l'import :
    // on traduit en objet specification
    // on reutilise le Question service
    def objSpec = specService.getObjectFromSpecification(questionDto.specification)

    Question question = questionService.createQuestionAndInsertInSujet(
        [
            titre: questionDto.titre,
            type: questionType,
            matiere: matiere,
            niveau: niveau,
            estAutonome: questionDto.estAutonome,
            paternite: questionDto.paternite,
            versionQuestion: questionDto.versionQuestion,
            copyrightsType: copyrightsType
        ],
        objSpec,
        sujet,
        importeur
    )

    if (questionDto.principalAttachement) {
      attachementImporterService.importePrincipalAttachement(questionDto.principalAttachement, question)
    }

    attachementImporterService.importeQuestionAttachements(questionDto.questionAttachements, question)

    return question
  }
}
