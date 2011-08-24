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
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.utils.StringUtils
import org.springframework.context.ApplicationContext
import org.springframework.context.ApplicationContextAware
import org.springframework.transaction.annotation.Transactional

/**
 * Service de gestion des questions
 * @author franck silvestre
 */
class QuestionService implements ApplicationContextAware {

  static transactional = false
  ApplicationContext applicationContext

  SujetService sujetService

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
            copyrightsType: CopyrightsType.getDefault(),
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
   * Retourne la dernière version éditable d'une question pour un proprietaire donné
   * @param question la question
   * @param proprietaire le proprietaire
   * @return la question editable
   */
  Question getDerniereVersionQuestionForProprietaire(Question question, Personne proprietaire) {
    if (question.proprietaire == proprietaire && !question.publie) {
      return question
    } else {
      return recopieQuestion(question, proprietaire)
    }
  }

  /**
   * Recopie une question
   * - si le proprietaire de la copie est le proprietaire de l'original, on
   * incrémente la version ; on ne crée pas de nouvelle branche :
   * la question départ branche de la nouvelle version
   * est la question départ branche de la version précédente
   * - si le proprietaire de la copie est différent de l'original, on n'incrémente
   * pas la version ; on créé une nouvelle branche : la question départ branche de la
   * copie est la question recopié
   * @param question la question à recopier
   * @param proprietaire le proprietaire
   * @return la copie de la question
   */
  @Transactional
  Question recopieQuestion(Question question, Personne proprietaire) {
    // todofsil : implémenter le contrôle de sécurité
    def versionQuestion = 1
    def questionDepartBranche = question.questionDepartBranche
    if (question.proprietaire == proprietaire) {
      versionQuestion = question.versionQuestion + 1
    } else {
      questionDepartBranche = question
    }
    Question questionCopie = new Question(
            proprietaire: proprietaire,
            titre: question.titre,
            titreNormalise: question.titreNormalise,
            specification: question.specification,
            specificationNormalise: question.specificationNormalise,
            publie: false,
            versionQuestion: versionQuestion,
            questionDepartBranche: questionDepartBranche,
            copyrightsType: question.copyrightsType,
            estAutonome: question.estAutonome,
            type: question.type,
            etablissement: question.etablissement,
            matiere: question.matiere,
            niveau: question.niveau,
    )
    questionCopie.save()

    // recopie les attachements
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

    return questionCopie
  }

  /**
   * Modifie les proprietes du sujet passé en paramètre
   * @param sujet le sujet
   * @param proprietes les nouvelles proprietes
   * @param specificationObject l'objet specification
   * @param proprietaire le proprietaire
   * @return le sujet
   */
  @Transactional
  Question updateProprietes(Question question, Map proprietes, def specificationObject,
                            Personne proprietaire) {
    // verifie que c'est sur la derniere version du sujet editable que l'on
    // travaille
    Question laQuestion = getDerniereVersionQuestionForProprietaire(question, proprietaire)

    if (proprietes.titre && laQuestion.titre != proprietes.titre) {
      laQuestion.titreNormalise = StringUtils.normalise(proprietes.titre)
    }

    laQuestion.properties = proprietes
    laQuestion.save()
    def specService = questionSpecificationServiceForQuestionType(laQuestion.type)
    specService.updateQuestionSpecificationForObject(question, specificationObject)
    question.save(flush: true)
    return laQuestion
  }

/**
   * Créé une question et l'insert dans le sujet
   * @param proprietesQuestion les propriétés de la question
   * @param specificationObject l'objet specification
   * @param sujet le sujet
   * @param proprietaire le propriétaire
   * @return la question insérée
   */
  @Transactional
  Question createQuestionAndInsertInSujet(Map proprietesQuestion,
                                          def specificatinObject,
                                          Sujet sujet,
                                          Personne proprietaire) {
    Question question = createQuestion(proprietesQuestion, specificatinObject, proprietaire)
    sujetService.insertQuestionInSujet(question, sujet, proprietaire)
    return question
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

}


