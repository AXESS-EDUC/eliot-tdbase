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

import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.Publication
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.utils.StringUtils
import org.springframework.context.ApplicationContext
import org.springframework.context.ApplicationContextAware
import org.springframework.transaction.annotation.Transactional
import static org.lilie.services.eliot.tdbase.QuestionTypeEnum.*


/**
 * Service de gestion des questions
 * @author franck silvestre
 */
class QuestionService implements ApplicationContextAware {

  static transactional = false
  ApplicationContext applicationContext

  SujetService sujetService
  ArtefactAutorisationService artefactAutorisationService

  /**
   * Récupère le service de gestion de spécification de question correspondant
   * au type de question passé en paramètre
   * @param questionType le type de question
   * @return le service ad-hoc pour le type de question
   */
  QuestionSpecificationService questionSpecificationServiceForQuestionType(QuestionType questionType) {
    return applicationContext.getBean("question${questionType.code}SpecificationService")
  }

  /**
   * Créé une question
   * @param proprietes les propriétés hors specification
   * @param specificationObject l'objet specification
   * @param proprietaire le proprietaire
   * @return la question créée
   */
  @Transactional
  Question createQuestion(Map proprietes, def specificationObject, Personne proprietaire) {
    Question question = new Question(
            proprietaire: proprietaire,
            titreNormalise: StringUtils.normalise(proprietes.titre),
            publie: false,
            versionQuestion: 1,
            copyrightsType: CopyrightsTypeEnum.TousDroitsReserves.copyrightsType,
            specification: "{}"
    )
    question.properties = proprietes
    question.save()
    def specService = questionSpecificationServiceForQuestionType(question.type)
    specService.updateQuestionSpecificationForObject(question, specificationObject)
    question.save(flush: true)
    return question
  }

  /**
   * Recopie une question
   * @param question la question à recopier
   * @param proprietaire le proprietaire
   * @return la copie de la question
   */
  @Transactional
  Question recopieQuestion(Question question, Personne proprietaire) {

    assert (artefactAutorisationService.utilisateurPeutDupliquerArtefact(proprietaire, question))

    Question questionCopie = new Question(
            proprietaire: proprietaire,
            titre: question.titre + " (Copie)",
            titreNormalise: question.titreNormalise,
            specification: question.specification,
            specificationNormalise: question.specificationNormalise,
            publie: false,
            copyrightsType: CopyrightsTypeEnum.TousDroitsReserves.copyrightsType,
            estAutonome: question.estAutonome,
            type: question.type,
            matiere: question.matiere,
            niveau: question.niveau,
            )
    questionCopie.save()

    // recopie les attachements (on ne duplique pas les attachements)
    question.questionAttachements.each { QuestionAttachement questionAttachement ->
      QuestionAttachement copieQuestionAttachement = new QuestionAttachement(
              question: questionCopie,
              attachement: questionAttachement.attachement,
              rang: questionAttachement.rang
      )
      questionCopie.addToQuestionAttachements(copieQuestionAttachement)
      questionCopie.save()
    }

    // recopie l'arborescence (si question composite)
    question.questionArborescenceFilles.each { QuestionArborescence questionArborescence ->
      QuestionArborescence copieQuestionArborescence = new QuestionArborescence(
              question: questionCopie,
              questionFille: questionArborescence.questionFille,
              rang: questionArborescence.rang
      )
      questionCopie.addToQuestionArborescenceFilles(copieQuestionArborescence)
      questionCopie.save()
    }

    // repertorie l'anteriorite
    questionCopie.paternite = question.paternite

    return questionCopie
  }

  /**
   * Modifie les proprietes de la question passée en paramètre
   * @param question la question
   * @param proprietes les nouvelles proprietes
   * @param specificationObject l'objet specification
   * @param proprietaire le proprietaire
   * @return la question
   */
  @Transactional
  Question updateProprietes(Question laQuestion, Map proprietes, def specificationObject,
                            Personne proprietaire) {

    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire,laQuestion))

    if (proprietes.titre && laQuestion.titre != proprietes.titre) {
      laQuestion.titreNormalise = StringUtils.normalise(proprietes.titre)
    }

    laQuestion.properties = proprietes
    laQuestion.save()
    def specService = questionSpecificationServiceForQuestionType(laQuestion.type)
    specService.updateQuestionSpecificationForObject(laQuestion, specificationObject)
    laQuestion.save(flush: true)
    return laQuestion
  }

/**
 * Créé une question et l'insert dans le sujet
 * @param proprietesQuestion les propriétés de la question
 * @param specificationObject l'objet specification
 * @param sujet le sujet
 * @param proprietaire le propriétaire
 * @param rang le rang d'insertion
 * @return la question insérée
 */
  @Transactional
  Question createQuestionAndInsertInSujet(Map proprietesQuestion,
                                          def specificatinObject,
                                          Sujet sujet,
                                          Personne proprietaire,
                                          Integer rang = null) {

    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire,sujet))

    Question question = createQuestion(proprietesQuestion, specificatinObject, proprietaire)
    sujetService.insertQuestionInSujet(question, sujet, proprietaire, rang)
    return question
  }

  /**
   * Supprime une question
   * @param question la question à supprimer
   * @param supprimeur la personne tentant la suppression
   */
  @Transactional
  def supprimeQuestion(Question laQuestion, Personne supprimeur) {
    assert (artefactAutorisationService.utilisateurPeutSupprimerArtefact(
            supprimeur, laQuestion))

    // supression des réponses
    Reponse.executeUpdate(" \
    DELETE FROM Reponse as reponse \
    where reponse.sujetQuestion = \
          (select sujetQuestion from \
           SujetSequenceQuestions as sujetQuestion where \
           sujetQuestion.question = :question)",
                          [question: laQuestion])

    // suppression des sujetQuestions
    SujetSequenceQuestions.executeUpdate(" \
                DELETE FROM SujetSequenceQuestions as sujetQuest \
                where sujetQuest.question = :question",
                                         [question: laQuestion])

    // suppression des questions arborescences
    QuestionArborescence.executeUpdate(" \
        DELETE FROM QuestionArborescence as questArb \
        where questArb.question = :question  or questArb.questionFille = :question",
                                       [question: laQuestion])

    // supprimer les attachements si nécessaire
    QuestionAttachement.executeUpdate(" \
            DELETE FROM QuestionAttachement as questAtt \
            where questAtt.question = :question",
                                      [question: laQuestion])

    // supprimer la publication si nécessaire
    if (laQuestion.estPartage()) {
      laQuestion.publication.delete()
    }

    laQuestion.delete()
  }

  /**
   *  Partage une question
   * @param laQuestion la question à partager
   * @param partageur la personne souhaitant partager
   */
  @Transactional
  def partageQuestion(Question laQuestion, Personne partageur) {
    assert (artefactAutorisationService.utilisateurPeutPartageArtefact(
            partageur, laQuestion))
    CopyrightsType ct = CopyrightsTypeEnum.CC_BY_NC.copyrightsType
    Publication publication = new Publication(dateDebut: new Date(),
                                              copyrightsType: ct)
    publication.save()
    laQuestion.copyrightsType = ct
    laQuestion.publication = publication
    // mise à jour de la paternite
    PaterniteItem paterniteItem = new PaterniteItem(
            auteur: "${partageur.nomAffichage}",
            copyrightDescription: "${ct.presentation}",
            copyrighLien: "${ct.lien}",
            datePublication: publication.dateDebut,
            oeuvreEnCours: true
    )
    Paternite paternite = new Paternite(laQuestion.paternite)
    paternite.paterniteItems.each {
      it.oeuvreEnCours = false
    }
    paternite.addPaterniteItem(paterniteItem)
    laQuestion.paternite = paternite.toString()
    laQuestion.save()
  }

  /**
   * Recherche de questions
   * @param chercheur la personne effectuant la recherche
   * @param patternTitre le pattern saisi pour le titre
   * @param patternAuteur le pattern saisi pour l'auteur
   * @param patternPresentation le pattern saisi pour la presentation
   * @param matiere la matiere
   * @param niveau le niveau
   * @param paginationAndSortingSpec les specifications pour l'ordre et
   * la pagination
   * @return la liste des sujets
   */
  List<Question> findQuestions(Personne chercheur,
                               String patternTitre,
                               String patternAuteur,
                               String patternSpecification,
                               Boolean estAutonome,
                               Matiere matiere,
                               Niveau niveau,
                               QuestionType questionType,
                               Map paginationAndSortingSpec = null) {
    // todofsil : gerer les index de manière efficace couplée avec présentation
    // paramètre de recherche ad-hoc
    if (!chercheur) {
      throw new IllegalArgumentException("question.recherche.chercheur.null")
    }
    if (paginationAndSortingSpec == null) {
      paginationAndSortingSpec = [:]
    }

    def criteria = Question.createCriteria()
    List<Question> questions = criteria.list(paginationAndSortingSpec) {
      if (patternAuteur) {
        String patternAuteurNormalise = "%${StringUtils.normalise(patternAuteur)}%"
        proprietaire {
          or {
            like "nomNormalise", patternAuteurNormalise
            like "prenomNormalise", patternAuteurNormalise
          }
        }
      }
      if (patternTitre) {
        like "titreNormalise", "%${StringUtils.normalise(patternTitre)}%"
      }
      if (patternSpecification) {
        like "specificationNormalise", "%${StringUtils.normalise(patternSpecification)}%"
      }
      if (estAutonome) {
        eq "estAutonome", true
      }
      if (matiere) {
        eq "matiere", matiere
      }
      if (niveau) {
        eq "niveau", niveau
      }
      if (questionType) {
        eq "type", questionType
      }
      or {
        eq 'proprietaire', chercheur
        eq 'publie', true
      }
      if (paginationAndSortingSpec) {
        def sortArg = paginationAndSortingSpec['sort'] ?: 'lastUpdated'
        def orderArg = paginationAndSortingSpec['order'] ?: 'desc'
        if (sortArg) {
          order "${sortArg}", orderArg
        }

      }
    }
    return questions
  }

  /**
   *
   * @return la liste de tous les types de question
   */
  List<QuestionType> getAllQuestionTypes() {
    return QuestionType.getAll()
  }

  /**
   *
   * @return la liste des types de questions à interaction supportes par tdbase
   */
  List<QuestionType> getTypesQuestionsInteractionSupportes() {
    [
            MultipleChoice.questionType,
            Decimal.questionType,
            QuestionTypeEnum.Integer.questionType,
            ExclusiveChoice.questionType,
            FillGap.questionType,
            Associate.questionType,
            Order.questionType,
            GraphicMatch.questionType
    ]
  }

  /**
   *
   * @return la liste des types de questions à interaction supportes par tdbase
   */
  List<QuestionType> getTypesQuestionsSupportes() {
    typesQuestionsInteractionSupportes +
    [
            Document.questionType,
            Statement.questionType,
    ]
  }


}
