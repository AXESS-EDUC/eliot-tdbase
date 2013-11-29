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
package org.lilie.services.eliot.tdbase.emaeval.score

import org.lilie.services.eliot.competence.Competence
import org.lilie.services.eliot.tdbase.Copie
import org.lilie.services.eliot.tdbase.CopieService
import org.lilie.services.eliot.tdbase.Reponse
import org.lilie.services.eliot.tdbase.ReponseService
import org.lilie.services.eliot.tdbase.emaeval.CampagneProxy
import org.lilie.services.eliot.tdbase.emaeval.CampagneProxyStatut
import org.lilie.services.eliot.tdbase.emaeval.EmaEvalService
import org.lilie.services.eliot.tdbase.emaeval.ScoreTransmissionStatut
import org.springframework.transaction.annotation.Transactional

/**
 * Service de gestion des scores EmaEval
 *
 * @author John Tranier
 */
class EmaEvalScoreService {

  static transactional = false

  CopieService copieService
  ReponseService reponseService
  EmaEvalService emaEvalService

  /**
   * Retourne un lot de CampagneProxy qui sont attentes de transmission des scores
   * de la séance TD Base associée
   * @param max le nombre max de résultat à retourner (le traitement s'effectue par lot)
   * @return
   */
  List<CampagneProxy> findLotCampagneProxyEnAttenteTransmissionScore(int max) {
    CampagneProxy.withCriteria {
      eq('statut', CampagneProxyStatut.OK)
      eq('scoreTransmissionStatut', ScoreTransmissionStatut.EN_ATTENTE_FIN_SEANCE)
      'modaliteActivite' {
        le('dateFin', new Date())
        eq('optionEvaluerCompetences', true)
      }
      order('id', 'asc')
      maxResults(max)
    }
  }

  @Transactional
  void transmetScoreCampagne(CampagneProxy campagneProxy) {
    EvaluationSeance evaluationSeance = evalueSeance(campagneProxy)
    try {
      emaEvalService.transmetScore(evaluationSeance)
      campagneProxy.notifieSuccesTransmissionScore()
    }
    catch (Throwable throwable) {
      log.error(
          "Erreur durant la transmission de scores à EmaEval pour " +
              "la séance ${campagneProxy.modaliteActivite.id}",
          throwable
      )
      campagneProxy.notifieEchecTransmissionScore()
    }

  }

  /**
   * Calcule les scores sur les compétences de tous les élèves pour une séance TD Base
   * en vue de leur transmission à EmaEval
   * @param campagneProxy
   * @return
   */
  private EvaluationSeance evalueSeance(CampagneProxy campagneProxy) {
    List<Copie> copieList =
      copieService.findCopiesRemisesForModaliteActivite(
          campagneProxy.modaliteActivite,
          campagneProxy.modaliteActivite.enseignant
      )

    EvaluationSeance evaluationSeance = new EvaluationSeance(campagneProxy: campagneProxy)

    copieList.each { Copie copie ->
      evaluationSeance.addEvaluationCopie(
          copie.eleve,
          evalueCopie(copie)
      )
    }

    return evaluationSeance
  }

  /**
   * Calcule l'évaluation des compétences d'une copie en vue de la
   * transmission des scores à EmaEval
   * @param copie
   * @return
   */
  private EvaluationCopie evalueCopie(Copie copie) {
    String hqlReponseCompetence = """
      SELECT new map(reponse as reponse, competence as competence)
      FROM Reponse reponse
      INNER JOIN reponse.sujetQuestion sujetQuestion
      INNER JOIN sujetQuestion.question question
      INNER JOIN question.allQuestionCompetence allQuestionCompetence
      INNER JOIN allQuestionCompetence.competence competence
      where reponse.copie = :copie
    """

    def reponseCompetenceList = Copie.executeQuery(
        hqlReponseCompetence,
        [copie: copie]
    )



    EvaluationCopie evaluationCopie = new EvaluationCopie()

    reponseCompetenceList.each {
      Competence competence = it.competence
      Reponse reponse = it.reponse

      evaluationCopie.addNote(
          competence,
          new Note(
              note: reponseService.evalueReponse(reponse),
              noteMax: reponse.sujetQuestion.points
          )
      )
    }

    return evaluationCopie
  }
}
