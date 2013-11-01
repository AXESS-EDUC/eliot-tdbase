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

import com.pentila.emawsconnector.manager.EvaluationObjectManager
import com.pentila.emawsconnector.manager.MethodManager
import com.pentila.emawsconnector.manager.PlanManager
import com.pentila.emawsconnector.manager.WorkFlowManager
import com.pentila.evalcomp.domain.definition.MethodEval
import com.pentila.evalcomp.domain.definition.Referentiel as EmaEvalReferentiel
import com.pentila.evalcomp.domain.plan.Plan
import com.pentila.evalcomp.domain.transit.TransitProcessDefinition
import org.codehaus.groovy.grails.commons.GrailsApplication
import org.lilie.services.eliot.competence.Referentiel as EliotReferentiel
import org.lilie.services.eliot.competence.ReferentielService
import org.lilie.services.eliot.competence.SourceReferentiel
import org.lilie.services.eliot.tdbase.emaeval.emawsconnector.ReferentielMarshaller
import org.springframework.transaction.annotation.Transactional

/**
 * Service de gestion de la liaison EmaEval
 *
 * @author John Tranier
 */
class EmaEvalService {

  static transactional = false

  @SuppressWarnings('GrailsStatelessService') // singleton
  GrailsApplication grailsApplication
  ReferentielService referentielService
  EmaEvalProprieteService emaEvalProprieteService
  EmaEvalFactoryService emaEvalFactoryService

  @SuppressWarnings('GrailsStatelessService') // singleton
  ReferentielMarshaller emaEvalReferentielMarshaller

  /**
   * @return true si la liaison TDBase / EmaEval est opérationnelle
   */
  public Boolean isLiaisonReady() {
    return grailsApplication.config.eliot.interfacage.emaeval.actif &&
        emaEvalProprieteService.getPropriete(ProprieteId.REFERENTIEL_STATUT).valeur == "OK" &&
        emaEvalProprieteService.getPropriete(ProprieteId.PLAN_TDBASE_ID).valeur &&
        emaEvalProprieteService.getPropriete(ProprieteId.SCENARIO_EVALUATION_DIRECTE_ID).valeur &&
        emaEvalProprieteService.getPropriete(ProprieteId.METHODE_EVALUATION_BOOLEENNE_ID).valeur
  }

  /**
   * Initialise le référentiel utilisé pour la liaison TD Base / EmaEval si nécessaire,
   * ou sinon vérifie la cohérence des référentiels.
   *
   * La vérification de la cohérence consiste en :
   *  - Récupérer le référentiel EmaEval dont l'identifiant est celui stocké dans le
   *  référentiel Eliot pour la source externe EmaEvam
   *  - Vérifier que les deux référentiels ont le même nom et la même version
   */
  @Transactional
  void initialiseOuVerifieReferentiel() {
    assert grailsApplication.config.eliot.interfacage.emaeval.actif

    // Création du manager
    EvaluationObjectManager evaluationObjectManager =
      emaEvalFactoryService.getEvaluationObjectManager(
          emaEvalFactoryService.creeEmaWSConnector(
              grailsApplication.config.eliot.interfacage.emaeval.admin.login
          )
      )

    EliotReferentiel eliotReferentiel = findEliotReferentiel()

    if (eliotReferentiel) {
      verifieCorrespondanceReferentiel(
          eliotReferentiel,
          findEmaEvalReferentielByEliotReferentiel(evaluationObjectManager, eliotReferentiel)
      )
    } else {
      importeReferentielFromEmaEval(evaluationObjectManager)
    }
  }

  /**
   * Initialiser le plan si nécessaire, sinon vérifie son existence dans EmaEval
   * L'initialisation du plan consiste en la création d'un plan spécifique à la liaison TD Base / EmaEval et le
   * stockage de son identifiant EmaEval dans la base eliot-scolarite (emaeval_interface.propriete)
   */
  @Transactional
  void initialiseOuVerifiePlan() {
    assert grailsApplication.config.eliot.interfacage.emaeval.actif

    // Création du manager
    PlanManager planManager = emaEvalFactoryService.getPlanManager(
        emaEvalFactoryService.creeEmaWSConnector(
            grailsApplication.config.eliot.interfacage.emaeval.admin.login
        )
    )

    Long planId = emaEvalPlanIdFromEliot
    if (planId != null) {
      verifiePlan(planManager, planId)
    } else {
      creePlanDansEmaEval(planManager)
    }
  }

  /**
   * Initialiser le scénario si nécessaire, sinon vérifie son existence dans EmaEval
   * L'initialisation du scenario consiste en la récupération de son identifiant EmaEval et son stockage
   * dans la base eliot-scolarite (emaeval_interface.propriete)
   */
  @Transactional
  void initialiseOuVerifieScenario() {
    assert grailsApplication.config.eliot.interfacage.emaeval.actif

    // Création du manager
    WorkFlowManager workFlowManager = emaEvalFactoryService.getWorkFlowManager(
        emaEvalFactoryService.creeEmaWSConnector(
            grailsApplication.config.eliot.interfacage.emaeval.admin.login
        )
    )

    String scenarioId = emaEvalScenarioIdFromEliot
    if (scenarioId != null) {
      verifieScenario(workFlowManager, scenarioId)
    } else {
      importeScenarioFromEmaEval(workFlowManager)
    }
  }

  /**
   * Initialise la méthode d'évaluation si nécessaire, sinon vérifie son existence dans EmaEval
   * L'initialisation de la méthode d'évaluation consiste en la récupération de son identifiant EmaEval et son
   * stockage dans la base eliot-scolarite (emaeval_interface.propriete)
   */
  @Transactional
  void initialiseOuVerifieMethodeEvaluation() {
    assert grailsApplication.config.eliot.interfacage.emaeval.actif

    // Création du manager
    MethodManager methodManager = emaEvalFactoryService.getMethodManager(
        emaEvalFactoryService.creeEmaWSConnector(
            grailsApplication.config.eliot.interfacage.emaeval.admin.login
        )
    )

    Long methodeEvaluationId = emaEvalMethodeEvaluationIdFromEliot
    if (methodeEvaluationId != null) {
      verifieMethodeEvaluation(methodManager, methodeEvaluationId)
    } else {
      importeMethodeEvaluationFromEmaEval(methodManager)
    }
  }

  String getDefautReferentielNom() {
    return grailsApplication.config.eliot.interfacage.emaeval.referentiel.nom
  }

  String getDefautPlanNom() {
    return grailsApplication.config.eliot.interfacage.emaeval.plan.nom
  }

  String getDefautScenarioNom() {
    return grailsApplication.config.eliot.interfacage.emaeval.scenario.nom
  }

  String getDefautMethodeEvaluationNom() {
    return grailsApplication.config.eliot.interfacage.emaeval.methodeEvaluation.nom
  }

  /**
   * @return Le référentiel de la base Eliot qui est utilisé pour la liaison TDBase / EmaEval
   */
  EliotReferentiel findEliotReferentiel() {

    EliotReferentiel referentiel =
      (EliotReferentiel) EliotReferentiel.withCriteria(uniqueResult: true) {
        eq('nom', defautReferentielNom)
        idExterneList {
          eq('sourceReferentiel', SourceReferentiel.EMA_EVAL)
        }
      }

    return referentiel
  }

  /**
   * Récupère un référentiel EmaEval à partir de son nom en effectuant un appel aux
   * webservices d'EmaEval
   * @param name
   * @return
   */
  EmaEvalReferentiel findEmaEvalReferentielByName(EvaluationObjectManager evaluationObjectManager,
                                                  String name) {

    return evaluationObjectManager.allReferentiels.find { EmaEvalReferentiel emaEvalReferentiel ->
      emaEvalReferentiel.name == name
    }
  }

  /**
   * Récupère, par webservice, un référentiel EmaEval correspondant à un référentiel Eliot
   * @param eliotReferentiel
   * @return
   */
  EmaEvalReferentiel findEmaEvalReferentielByEliotReferentiel(EvaluationObjectManager evaluationObjectManager,
                                                              EliotReferentiel eliotReferentiel) {
    String idExterne = eliotReferentiel.getIdExterne(SourceReferentiel.EMA_EVAL)
    if (!idExterne) {
      throw new IllegalStateException(
          "Le référentiel Eliot ${eliotReferentiel.id} n'est pas rattaché à un identifiant " +
              "externe pour la source EmaEval"
      )
    }

    return findEmaEvalReferentielById(evaluationObjectManager, Long.parseLong(idExterne))
  }

  /**
   * Récupère un référentiel EmaEval à partir de son ID en effectuant un appel aux
   * webservices d'EmaEval
   * @param id
   * @return
   */
  EmaEvalReferentiel findEmaEvalReferentielById(EvaluationObjectManager evaluationObjectManager,
                                                Long id) {
    return evaluationObjectManager.getReferentiel(id)
  }

  /**
   * Vérifie la correspondance entre le référentiel Eliot et le référentiel EmaEval
   *
   * La vérification de la correspondance est effectuée en vérifiant :
   *  - que les 2 référentiels portent le même nom
   *  - que les 2 référentiels portent la même version
   *
   */
  void verifieCorrespondanceReferentiel(EliotReferentiel eliotReferentiel,
                                        EmaEvalReferentiel emaEvalReferentiel) {

    if (emaEvalReferentiel.name != eliotReferentiel.nom) {
      throw new IllegalStateException(
          """
          Dans la base eliot-scolarité, le référentiel "${eliotReferentiel.nom}" est associé au
          référentiel d'id ${eliotReferentiel.getIdExterne(SourceReferentiel.EMA_EVAL)} dans EmaEval.
          Le nom du référentiel retourné par EmaEval ne correspond pas (${emaEvalReferentiel.name}).
          """
      )
    }

    if (emaEvalReferentiel.version != eliotReferentiel.referentielVersion) {
      throw new IllegalStateException(
          """
          Les versions du référentiel "${eliotReferentiel.nom}" ne correspondent pas
          (Eliot : ${eliotReferentiel.referentielVersion}, EmaEval: ${emaEvalReferentiel.version}).
          """
      )
    }

    Propriete propriete = emaEvalProprieteService.getPropriete(ProprieteId.REFERENTIEL_STATUT)
    propriete.valeur = "OK"
    propriete.save(failOnError: true)
  }

  /**
   * Importe le référentiel obtenu par les WS d'EmaEval dans la base de référentiel d'Eliot
   */
  @Transactional
  void importeReferentielFromEmaEval(EvaluationObjectManager evaluationObjectManager) {

    EmaEvalReferentiel referentiel =
      evaluationObjectManager.allReferentiels.find { EmaEvalReferentiel emaEvalReferentiel ->
        emaEvalReferentiel.name == defautReferentielNom
      }

    if (!referentiel) {
      throw new IllegalStateException(
          "Le référentiel '$defautReferentielNom' n'existe pas."
      )
    }

    // Patch car evaluationObjectManager.allReferentiels ne retourne pas le contenu des référentiel :-(
    referentiel = evaluationObjectManager.getReferentiel(referentiel.id)

    referentielService.importeReferentiel(
        emaEvalReferentielMarshaller.parseReferentiel(referentiel)
    )

    Propriete propriete = emaEvalProprieteService.getPropriete(ProprieteId.REFERENTIEL_STATUT)
    propriete.valeur = "OK"
    propriete.save(failOnError: true)
  }

  /**
   * @return l'identifiant EmaEval du plan stocké dans les propriétés de
   * la liaison EmaEval.
   * La valeur null indique que le plan n'a pas encore été créé
   */
  Long getEmaEvalPlanIdFromEliot() {
    Propriete propriete = emaEvalProprieteService.getPropriete(
        ProprieteId.PLAN_TDBASE_ID
    )

    return propriete.valeur ? Long.parseLong(propriete.valeur) : null
  }

  /**
   * Vérifie que le plan ayant l'identifiant planId existe dans EmaEval et
   * correspond au plan PLAN_NOM
   * @param planManager
   * @param planId
   */
  void verifiePlan(PlanManager planManager, long planId) {
    Plan plan = planManager.getPlan(planId)

    if (!plan) {
      throw new IllegalStateException(
          "Le plan '$defautPlanNom' n'existe pas."
      )
    }

    if (plan.name != defautPlanNom) {
      throw new IllegalStateException(
          "L'identifiant du plan configuré dans Eliot est $planId. " +
              "La plan retourné par EmaEval pour cet identifiant ne correspond pas à celui attendu : " +
              "${plan.name} au lieu de $defautPlanNom."
      )
    }
  }

  /**
   * Crée le plan PLAN_NOM dans EmaEval et stocke son identifiant dans les propriétés
   * de la liaison TDBase / EmaEval
   * @param planManager
   */
  Plan creePlanDansEmaEval(PlanManager planManager) {
    Plan plan = planManager.addPlan(defautPlanNom, defautPlanNom, defautPlanNom) // Note : comme on utile un plan unique, les notions d'organisation & ville du plan n'ont pas de sens

    if (!plan?.id) {
      throw new IllegalStateException(
          "La création du plan $defautPlanNom a échouée pour une raison inconnue."
      )
    }

    Propriete propriete = emaEvalProprieteService.getPropriete(
        ProprieteId.PLAN_TDBASE_ID
    )
    propriete.valeur = plan.id.toString()
    propriete.save(failOnError: true)

    return plan
  }

  /**
   * @return l'identifiant EmaEval du scénario stocké dans les propriétés de
   * la liaison EmaEval.
   * La valeur null indique que cet identifiant n'a pas été récupéré dans Eliot.
   */
  String getEmaEvalScenarioIdFromEliot() {
    Propriete propriete = emaEvalProprieteService.getPropriete(
        ProprieteId.SCENARIO_EVALUATION_DIRECTE_ID
    )

    return propriete.valeur
  }

  /**
   * Récupère depuis EmaEval l'identifiant du scénario SCENARIO_NOM
   * pour le stocker dans les propriétés de la liaison EmaEval
   * @param workFlowManager
   */
  void importeScenarioFromEmaEval(WorkFlowManager workFlowManager) {

    TransitProcessDefinition scenario = workFlowManager.allScenarios.find {
      it.name == defautScenarioNom
    }

    if (!scenario) {
      throw new IllegalStateException(
          "Le scénario '$defautScenarioNom' n'existe pas."
      )
    }

    Propriete propriete = emaEvalProprieteService.getPropriete(
        ProprieteId.SCENARIO_EVALUATION_DIRECTE_ID
    )
    propriete.valeur = scenario.id
    propriete.save(failOnError: true)
  }

  void verifieScenario(WorkFlowManager workFlowManager, String scenarioId) {

    // Note : le workFlowManager ne permet pas de récupérer un scenario à partir de son identifiant
    TransitProcessDefinition scenario = workFlowManager.allScenarios.find {
      it.name == defautScenarioNom
    }

    if (!scenario) {
      throw new IllegalStateException(
          "Le scénario '$defautScenarioNom' d'identifiant $scenario n'existe pas dans EmaEval."
      )
    }

    if (scenario.name != defautScenarioNom) {
      throw new IllegalStateException(
          "L'identifiant du scénario configuré dans Eliot est $scenarioId. " +
              "Le scénario retourné par EmaEval  pour cet identifiant ne correspond pas à celui attendu : " +
              "${scenario.name} au lieu de $defautScenarioNom."
      )
    }
  }

  /**
   * @return l'identifiant EmaEval de la méthode d'évaluation stocké dans les propriétés de
   * la liaison EmaEval.
   * La valeur null indique que cet identifiant n'a pas été récupéré dans Eliot.
   */
  Long getEmaEvalMethodeEvaluationIdFromEliot() {
    Propriete propriete = emaEvalProprieteService.getPropriete(
        ProprieteId.METHODE_EVALUATION_BOOLEENNE_ID
    )

    return propriete.valeur ? Long.parseLong(propriete.valeur) : null
  }

  /**
   * Récupère depuis EmaEval l'identifiant de la méthode METHODE_EVALUATION_BOOLEENNE_NOM
   * pour le stocker dans les propriétés de la liaison EmaEval
   * @param methodManager
   */
  void importeMethodeEvaluationFromEmaEval(MethodManager methodManager) {

    MethodEval methodEval = methodManager.allMethodEvals.find {
      it.name == defautMethodeEvaluationNom
    }

    if (!methodEval) {
      throw new IllegalStateException(
          "La méthode '$defautMethodeEvaluationNom' n'existe pas."
      )
    }

    // Enregistrement de l'identifiant en base
    Propriete propriete = emaEvalProprieteService.getPropriete(
        ProprieteId.METHODE_EVALUATION_BOOLEENNE_ID
    )
    propriete.valeur = methodEval.id.toString()
    propriete.save(failOnError: true)
  }

  /**
   * Vérifie que la méthode d'évaluation ayant methodeId pour identifiant existe bien
   * dans EmaEval et correspond à la méthode METHODE_EVALUATION_BOOLEENNE_NOM
   * @param methodManager
   * @param methodeId
   */
  void verifieMethodeEvaluation(MethodManager methodManager, long methodeId) {

    // Note : il n'y a pas de méthode dans MethodManager permettant de récupérer une méthode
    // à partir de son identifiant
    MethodEval methodEval = methodManager.allMethodEvals.find {
      it.id == methodeId
    }

    if (!methodEval) {
      throw new IllegalStateException(
          "La méthode '$defautMethodeEvaluationNom' n'existe pas."
      )
    }

    if (methodEval.name != defautMethodeEvaluationNom) {
      throw new IllegalStateException(
          "L'identifiant de la méthode d'évaluation configurée dans Eliot est $methodeId. " +
              "La méthode retournée par EmaEval  pour cet identifiant ne correspond pas à celle attendue : " +
              "${methodEval.name} au lieu de $defautMethodeEvaluationNom."
      )
    }
  }
}



