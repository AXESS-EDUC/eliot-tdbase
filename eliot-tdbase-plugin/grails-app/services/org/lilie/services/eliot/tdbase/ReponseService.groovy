/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 * Lilie is free software. You can redistribute it and/or modify since
 * you respect the terms of either (at least one of the both license) :
 * - under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * - the CeCILL-C as published by CeCILL-C; either version 1 of the
 * License, or any later version
 *
 * There are special exceptions to the terms and conditions of the
 * licenses as they are applied to this software. View the full text of
 * the exception in file LICENSE.txt in the directory of this software
 * distribution.
 *
 * Lilie is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Licenses for more details.
 *
 * You should have received a copy of the GNU General Public License
 * and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */



package org.lilie.services.eliot.tdbase


import org.lilie.services.eliot.tice.annuaire.Personne
import org.springframework.context.ApplicationContext
import org.springframework.context.ApplicationContextAware
import org.springframework.transaction.annotation.Transactional

/**
 * Service de gestion des questions
 * @author franck silvestre
 */
class ReponseService implements ApplicationContextAware {

  static transactional = false
  ApplicationContext applicationContext
  ReponseAttachementService reponseAttachementService

  /**
   * Récupère le service de gestion de spécification de réponse correspondant
   * au type de question passé en paramètre
   * @param questionType le type de question
   * @return le service ad-hoc pour le type de question
   */
  ReponseSpecificationService reponseSpecificationServiceForQuestionType(QuestionType questionType) {
    return applicationContext.getBean("reponse${questionType.code}SpecificationService")
  }

  /**
   * Crée une nouvelle réponse à partir des éléments d'une question
   * @param copie la copie
   * @param sujetQuestion la question
   * @param proprietaire le proprietaire
   * @return la réponse
   */
  @Transactional
  Reponse createReponse(Copie copie, SujetSequenceQuestions sujetQuestion,
                        Personne proprietaire) {

    assert (copie.eleve == proprietaire)

    Reponse reponse = new Reponse(
            copie: copie,
            sujetQuestion: sujetQuestion,
            eleve: proprietaire,
            ).save()
    def question = sujetQuestion.question
    def qtype = question.type
    if (qtype.interaction) {
      def specService = reponseSpecificationServiceForQuestionType(qtype)
      specService.initialiseReponseSpecificationForQuestion(reponse, question)
    }
    copie.addToReponses(reponse)
    reponse.save(flush: true)
    return reponse
  }

  /**
   * Modifie les proprietes de la réponse passée en paramètre
   * @param reponse la reponse
   * @param specificationObject l'objet specification
   * @param proprietaire le proprietaire
   * @return la réponse avec la note correction automatique mise à jour
   */
  @Transactional
  Reponse updateSpecificationAndEvalue(Reponse reponse, def specificationObject,
                                       Personne proprietaire) {

    assert (reponse.eleve == proprietaire && reponse.questionType.interaction)

    QuestionType qtype = reponse.sujetQuestion.question.type
    def specService = reponseSpecificationServiceForQuestionType(qtype)
    specService.updateReponseSpecificationForObject(reponse, specificationObject)
    specService.evalueReponse(reponse)
    return reponse
  }

  /**
     * Modifie les proprietes de la réponse passée en paramètre
     * @param reponse la reponse
     * @param specificationObject l'objet specification
     * @param proprietaire le proprietaire
     * @return la réponse avec la note correction automatique mise à jour
     */
    @Transactional
    Reponse updateSpecification(Reponse reponse, def specificationObject,
                                         Personne proprietaire) {

      assert (reponse.eleve == proprietaire && reponse.questionType.interaction)

      QuestionType qtype = reponse.sujetQuestion.question.type
      def specService = reponseSpecificationServiceForQuestionType(qtype)
      specService.updateReponseSpecificationForObject(reponse, specificationObject)
      return reponse
    }

  /**
   * Récupère un template de spécification de réponse
   * @param reponse la réponse pour laquelle on souhaite récupéré un template de
   * spécification de réponse
   * @return un objet specification de réponse "vide" correspondant au
   * type de question
   */
  def getSpecificationReponseInitialisee(Reponse reponse) {
    assert (reponse.questionType.interaction)
    def question = reponse.sujetQuestion.question
    def specService = reponseSpecificationServiceForQuestionType(question.type)
    specService.getObjectInitialiseFromSpecification(question.specificationObject)
  }

  /**
   * Supprime une réponse
   * @param reponse la reponse a supprimer
   * @param supprimeur la personne déclenchant la suppression
   */
  @Transactional
  def supprimeReponse(Reponse reponse, Personne supprimeur) {
    def copie = reponse.copie
    if (!copie?.estJetable) {
      assert (copie.modaliteActivite?.enseignant == supprimeur)
    }
    copie.removeFromReponses(reponse)
    // supprimer les attachements si nécessaire
    def reponseAttachements = ReponseAttachement.findAllByReponse(reponse)
    reponseAttachements.each {
      reponseAttachementService.deleteReponseAttachement(it)
    }

    reponse.delete()

  }

}


