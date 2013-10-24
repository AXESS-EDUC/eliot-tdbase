/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 *  This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
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
 *   <http://www.gnu.org/licenses/> and
 *   <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tdbase

import grails.plugin.spock.IntegrationSpec
import org.lilie.services.eliot.competence.Competence
import org.lilie.services.eliot.competence.CompetenceDto
import org.lilie.services.eliot.competence.DomaineDto
import org.lilie.services.eliot.competence.ReferentielDto
import org.lilie.services.eliot.competence.ReferentielService
import org.lilie.services.eliot.tdbase.impl.decimal.DecimalSpecification
import org.lilie.services.eliot.tdbase.utils.TdBaseInitialisationTestService
import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * @author John Tranier
 */
class SujetIntegrationSpec extends IntegrationSpec {

  Personne personne1

  TdBaseInitialisationTestService tdBaseInitialisationTestService
  SujetService sujetService
  QuestionService questionService
  ReferentielService referentielService
  QuestionCompetenceService questionCompetenceService

  def setup() {
    personne1 = tdBaseInitialisationTestService.utilisateur1.personne

    importeReferentielDeTest()
  }

  def "testHasCompetence"(int nbQuestion,
                          int nbExercice,
                          int nbQuestionAvecCompetence,
                          int nbExerciceAvecCompetence) {
    given: "Sachant un sujet dont connais le nombre de questions et d'exercices associés à des compétences"
    Sujet sujet = creeSujet(
        nbQuestion,
        nbExercice,
        nbQuestionAvecCompetence,
        nbExerciceAvecCompetence
    )

    expect: "Le sujet est associé à des compétences ssi il existe au moins une question ou un exercice associé à des compétences"
    sujet.hasCompetence() == (nbQuestionAvecCompetence + nbExerciceAvecCompetence > 0)

    where:
    nbQuestion | nbQuestionAvecCompetence | nbExercice | nbExerciceAvecCompetence
    0          | 0                        | 0          | 0
    3          | 0                        | 3          | 0
    3          | 1                        | 0          | 0
    3          | 0                        | 3          | 1
    3          | 3                        | 3          | 0
    3          | 0                        | 3          | 3
    3          | 3                        | 3          | 3
  }

  /**
   * Crée un sujet contenant un nombre donné de questions sans compétence, de questions avec
   * compétence, d'exercices sans compétence et d'exercices avec compétence
   * @param nbQuestion
   * @param nbExercice
   * @param nbQuestionAvecCompetence
   * @param nbExerciceAvecCompetence
   * @return
   */
  private Sujet creeSujet(int nbQuestion,
                          int nbExercice,
                          int nbQuestionAvecCompetence,
                          int nbExerciceAvecCompetence) {

    Sujet sujet = sujetService.createSujet(personne1, 'sujet')

    nbQuestionAvecCompetence.times {
      sujetService.insertQuestionInSujet(
          creeQuestion(it, true),
          sujet,
          personne1
      )
    }

    (nbQuestion - nbQuestionAvecCompetence).times {
      sujetService.insertQuestionInSujet(
          creeQuestion(it, false),
          sujet,
          personne1
      )
    }

    nbExerciceAvecCompetence.times {
      sujetService.insertQuestionInSujet(
          creeExercice(it, true),
          sujet,
          personne1
      )
    }

    (nbExercice - nbExerciceAvecCompetence).times {
      sujetService.insertQuestionInSujet(
          creeExercice(it, false),
          sujet,
          personne1
      )
    }

    return sujet
  }

  private Question creeQuestion(int num, boolean avecCompetence) {
    Question question = questionService.createQuestion(
        [
            titre: "Question $num",
            type: QuestionTypeEnum.Decimal.questionType,
            estAutonome: true
        ],
        new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
        personne1,
    )

    if (avecCompetence) {
      questionCompetenceService.createQuestionCompetence(
          question,
          Competence.first()
      )
    }

    return question
  }

  private Question creeExercice(int num, boolean avecCompetence) {
    Sujet exercice = sujetService.createSujet(personne1, 'sujet')


    3.times {
      Question question = creeQuestion(
          100 * num + it,
          avecCompetence
      )

      sujetService.insertQuestionInSujet(
          question,
          exercice,
          personne1
      )

      if (avecCompetence) {
        questionCompetenceService.createQuestionCompetence(
            question,
            Competence.first()
        )
      }
    }

    sujetService.updateProprietes(
        exercice,
        [
            sujetType: SujetTypeEnum.Exercice.sujetType
        ],
        personne1
    )

    return exercice.questionComposite
  }

  private void importeReferentielDeTest() {

    ReferentielDto referentielDto = new ReferentielDto(
        nom: "Référentiel de test",
        allDomaine: [
            new DomaineDto(
                nom: "Domaine de test",
                allCompetence: [
                    new CompetenceDto(nom: "Compétence de test")
                ]
            )
        ]
    )

    referentielService.importeReferentiel(referentielDto)
  }
}
