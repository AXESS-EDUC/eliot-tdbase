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

package org.lilie.services.eliot.tdbase.emaeval

import grails.converters.JSON
import org.codehaus.groovy.grails.commons.GrailsApplication
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.utils.BreadcrumpsService

/**
 * @author John Tranier
 */
class EmaEvalController {

  static defaultAction = "admin"

  BreadcrumpsService breadcrumpsService
  EmaEvalService emaEvalService
  GrailsApplication grailsApplication

  /**
   * Page d'administration de la liaison TDBase / EmaEval
   * Cette page permet de consulter la configuration de la liaison, d'initialiser la liaison, et de vérifier son
   * bon fonctionnement par la suite
   * @return la vue /maintenance/emaEval/admin
   */
  def admin() {
    breadcrumpsService.manageBreadcrumps(
        params,
        (String)message(code: message(code: message(code: "maintenance.emaeval.title")))
    )

    render(
        view: '/maintenance/emaEval/admin',
        model: [
            config: grailsApplication.config,
            liens: breadcrumpsService.liens
        ]
    )
  }

  /**
   * Action permettant d'initialiser le référentiel de compétence pour la liaison TD Base / EmaEval, puis de
   * vérifier la cohérence des référentiels par la suite
   *
   * L'initialisation consiste en :
   *  - L'import du référentiel dans Eliot
   *  - Le stockage de l'identifiant EmaEval du référentiel dans la base eliot-scolarite (emaeval_interface.propriete)
   *
   * La vérification du référentiel consiste en :
   *  - Vérifier que le référentiel existe dans la base eliot-scolarite
   *  - Vérifier que le référentiel existe dans EmaEval
   *  - Vérifier que les 2 référentiels portent le même nom et la même version
   *
   * @return réponse JSON indiquant si le référentiel est opérationnel (success) et la stacktrace d'une erreur le cas
   * échéant
   */
  @SuppressWarnings('CatchThrowable') // Les exceptions sont rendues sur la page
  def initialiseOuVerifieReferentiel() {
    boolean success = true
    Throwable error = null

    try {
      emaEvalService.initialiseOuVerifieReferentiel((Personne)authenticatedPersonne)
    }
    catch (Throwable e) {
      log.warn("Erreur durant l'initialisation ou la vérification du référentiel", e)
      success = false
      error = e
    }

    render([
        success: success,
        error: g.renderStackTrace(exception: error)
    ] as JSON)
  }

  /**
   * Action permettant d'initialiser le plan, puis de vérifier son existence par la suite
   * L'initialisation du plan consiste en la création d'un plan spécifique à la liaison TD Base / EmaEval et le
   * stockage de son identifiant EmaEval dans la base eliot-scolarite (emaeval_interface.propriete)
   * @return réponse JSON indiquant si le plan est opérationnel (success) et la stacktrace d'une erreur le cas
   * échéant
   */
  @SuppressWarnings('CatchThrowable') // Les exceptions sont rendues sur la page
  def initialiseOuVerifiePlan() {

    boolean success = true
    Throwable error = null

    try {
      emaEvalService.initialiseOuVerifiePlan((Personne)authenticatedPersonne)
    }
    catch (Throwable e) {
      log.warn("Erreur durant l'initialisation ou la vérification du plan", e)
      success = false
      error = e
    }

    render([
        success: success,
        error: g.renderStackTrace(exception: error)
    ] as JSON)
  }

  /**
   * Action permettant d'initialiser le scénario, puis de vérifier son existence par la suite
   * L'initialisation du scenario consiste en la récupération de son identifiant EmaEval et son stockage
   * dans la base eliot-scolarite (emaeval_interface.propriete)
   * @return réponse JSON indiquant si le scenario est opérationnel (success) et la stacktrace d'une erreur le cas
   * échéant
   */
  @SuppressWarnings('CatchThrowable') // Les exceptions sont rendues sur la page
  def initialiseOuVerifieScenario() {
    boolean success = true
    Throwable error = null

    try {
      emaEvalService.initialiseOuVerifieScenario((Personne)authenticatedPersonne)
    }
    catch (Throwable e) {
      log.warn("Erreur durant l'initialisation ou la vérification du scénario", e)
      success = false
      error = e
    }

    render([
        success: success,
        error: g.renderStackTrace(exception: error)
    ] as JSON)
  }

  /**
   * Action permettant d'initialiser la méthode d'évaluation, puis de vérifier son existence par la suite
   * L'initialisation de la méthode d'évaluation consiste en la récupération de son identifiant EmaEval et son
   * stockage dans la base eliot-scolarite (emaeval_interface.propriete)
   * @return réponse JSON indiquant si la méthode d'évaluation est opérationnels (success) et la stacktrace
   * d'une erreur le cas échéant
   */
  @SuppressWarnings('CatchThrowable') // Les exceptions sont rendues sur la page
  def initialiseOuVerifieMethodeEvaluation() {
    boolean success = true
    Throwable error = null


    try {
      emaEvalService.initialiseOuVerifieMethodeEvaluation((Personne)authenticatedPersonne)
    }
    catch (Throwable e) {
      log.warn("Erreur durant l'initialisation ou la vérification de la méthode d'évaluation", e)
      success = false
      error = e
    }

    render([
        success: success,
        error: g.renderStackTrace(exception: error)
    ] as JSON)
  }
}
