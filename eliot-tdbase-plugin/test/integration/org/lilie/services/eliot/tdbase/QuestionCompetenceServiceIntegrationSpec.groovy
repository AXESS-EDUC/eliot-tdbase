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

import grails.plugin.spock.IntegrationSpec
import org.lilie.services.eliot.competence.Competence
import org.lilie.services.eliot.competence.ReferentielBootstrapService
import org.lilie.services.eliot.tdbase.impl.decimal.DecimalSpecification
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.utils.BootstrapService

/**
 * @author John Tranier
 */
class QuestionCompetenceServiceIntegrationSpec extends IntegrationSpec {

  BootstrapService bootstrapService
  ReferentielBootstrapService referentielBootstrapService
  QuestionService questionService
  QuestionCompetenceService questionCompetenceService

  Personne personne1

  def setup() {
    bootstrapService.bootstrapForIntegrationTest()
    personne1 = bootstrapService.enseignant1
    referentielBootstrapService.initialiseReferentielTest()
  }

  def "testCreateQuestionCompetence"(int nbCompetence) {
    given:
    Question question = questionService.createQuestion(
        [
            titre: "Question 1",
            type: QuestionTypeEnum.Decimal.questionType,
            estAutonome: true
        ],
        new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
        personne1,
    )

    assert question
    assert !question.allQuestionCompetence

    def allCompetence =  Competence.findAll()
    assert allCompetence.size() >= nbCompetence

    // Ajout des QuestionCompetence
    nbCompetence.times {
      questionCompetenceService.createQuestionCompetence(question, allCompetence[it])
    }


    expect:
    question.allQuestionCompetence.size() == nbCompetence
    question.allQuestionCompetence.each {
      assert it.question == question
      assert it.competence in allCompetence[0..nbCompetence-1]
    }

    QuestionCompetence.findAll().size() == nbCompetence

    where:
    nbCompetence << [1, 2]
  }

  def "testDeleteQuestionCompetence"() {
    given:
    Question question = questionService.createQuestion(
        [
            titre: "Question 1",
            type: QuestionTypeEnum.Decimal.questionType,
            estAutonome: true
        ],
        new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
        personne1,
    )

    assert question
    assert !question.allQuestionCompetence

    def allCompetence =  Competence.findAll()
    assert allCompetence.size() >= 1

    questionCompetenceService.createQuestionCompetence(question, allCompetence.first())
    assert question.allQuestionCompetence.size() == 1

    when:
    questionCompetenceService.deleteQuestionCompetence(question.allQuestionCompetence.first())

    then:
    !question.allQuestionCompetence
    !QuestionCompetence.findAll()
  }

  /**
   * Vérifie qu'en cas de suppression d'une question les QuestionCompetence associés
   * sont bien supprimés
   */
  def "testSupprimeQuestion"() {
    given:
    int nbCompetence = 2
    Question question = questionService.createQuestion(
        [
            titre: "Question 1",
            type: QuestionTypeEnum.Decimal.questionType,
            estAutonome: true
        ],
        new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
        personne1,
    )

    assert question
    assert !question.allQuestionCompetence

    def allCompetence =  Competence.findAll()
    assert allCompetence.size() >= nbCompetence

    // Ajout des QuestionCompetence
    nbCompetence.times {
      questionCompetenceService.createQuestionCompetence(question, allCompetence[it])
    }

    assert question.allQuestionCompetence.size() == nbCompetence
    assert QuestionCompetence.findAll().size() == nbCompetence

    when:
    questionService.supprimeQuestion(question, personne1)

    then:
    QuestionCompetence.findAll().size() == 0
  }

  /**
   * Vérifie que les QuestionCompetence sont bien recopiées quand on recopie
   * une question
   */
  def "testRecopieQuestion"() {
    given:
    int nbCompetence = 2
    Question questionOriginale = questionService.createQuestion(
        [
            titre: "Question 1",
            type: QuestionTypeEnum.Decimal.questionType,
            estAutonome: true
        ],
        new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
        personne1,
    )

    assert questionOriginale
    assert !questionOriginale.allQuestionCompetence

    def allCompetence =  Competence.findAll()
    assert allCompetence.size() >= nbCompetence

    // Ajout des QuestionCompetence
    nbCompetence.times {
      questionCompetenceService.createQuestionCompetence(questionOriginale, allCompetence[it])
    }

    assert questionOriginale.allQuestionCompetence.size() == nbCompetence
    assert QuestionCompetence.findAll().size() == nbCompetence

    when:
    Question questionCopie = questionService.recopieQuestion(questionOriginale, personne1)

    then:
    questionCopie.allQuestionCompetence.size() == nbCompetence
    questionCopie.allQuestionCompetence.each {
      assert it.question == questionCopie
      assert it.competence in questionOriginale.allQuestionCompetence*.competence
    }
    QuestionCompetence.findAll().size() == 2 * nbCompetence

  }
}
