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

import com.pentila.emawsconnector.manager.EvaluationDefinitionManager
import com.pentila.emawsconnector.manager.EvaluationObjectManager
import com.pentila.emawsconnector.manager.EvaluationSubjectInstanceManager
import com.pentila.emawsconnector.manager.MethodManager
import com.pentila.emawsconnector.manager.PlanManager
import com.pentila.emawsconnector.manager.WorkFlowManager
import com.pentila.emawsconnector.utils.EmaWSConnector
import com.pentila.evalcomp.domain.Entity
import com.pentila.evalcomp.domain.User
import com.pentila.evalcomp.domain.definition.EntityDefinition
import com.pentila.evalcomp.domain.definition.EvaluationDefinition
import com.pentila.evalcomp.domain.definition.EvaluationSubject
import com.pentila.evalcomp.domain.definition.MethodEval
import com.pentila.evalcomp.domain.definition.ProcessRoleDefinition
import com.pentila.evalcomp.domain.definition.Referentiel as EmaEvalReferentiel
import com.pentila.evalcomp.domain.definition.ScenarioDefinition
import com.pentila.evalcomp.domain.plan.Plan
import com.pentila.evalcomp.domain.transit.TransitProcessDefinition
import org.codehaus.groovy.grails.commons.GrailsApplication
import org.lilie.services.eliot.competence.Competence
import org.lilie.services.eliot.competence.CompetenceIdExterne
import org.lilie.services.eliot.competence.Referentiel as EliotReferentiel
import org.lilie.services.eliot.competence.ReferentielService
import org.lilie.services.eliot.competence.SourceReferentiel
import org.lilie.services.eliot.tdbase.ModaliteActivite
import org.lilie.services.eliot.tdbase.emaeval.emawsconnector.ReferentielMarshaller
import org.lilie.services.eliot.tdbase.emaeval.score.EvaluationCopie
import org.lilie.services.eliot.tdbase.emaeval.score.EvaluationSeance
import org.lilie.services.eliot.tice.annuaire.Personne
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
  void initialiseOuVerifieReferentiel(Personne operateur) {
    assert grailsApplication.config.eliot.interfacage.emaeval.actif

    // Création du manager
    EvaluationObjectManager evaluationObjectManager =
      emaEvalFactoryService.getEvaluationObjectManager(
          emaEvalFactoryService.creeEmaWSConnector(operateur.autorite.identifiant)
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
  void initialiseOuVerifiePlan(Personne operateur) {
    assert grailsApplication.config.eliot.interfacage.emaeval.actif

    // Création du manager
    PlanManager planManager = emaEvalFactoryService.getPlanManager(
        emaEvalFactoryService.creeEmaWSConnector(operateur.autorite.identifiant)
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
  void initialiseOuVerifieScenario(Personne operateur) {
    assert grailsApplication.config.eliot.interfacage.emaeval.actif

    // Création du manager
    WorkFlowManager workFlowManager = emaEvalFactoryService.getWorkFlowManager(
        emaEvalFactoryService.creeEmaWSConnector(operateur.autorite.identifiant)
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
  void initialiseOuVerifieMethodeEvaluation(Personne operateur) {
    assert grailsApplication.config.eliot.interfacage.emaeval.actif

    // Création du manager
    MethodManager methodManager = emaEvalFactoryService.getMethodManager(
        emaEvalFactoryService.creeEmaWSConnector(operateur.autorite.identifiant)
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
   * Retourne le plan par défaut utilisé pour la liaison TD Base / EmaEval
   * Cette méthode vérifie que le plan obtenu depuis EmaEval est correct
   * @param connector
   * @return
   */
  Plan getDefautPlan(EmaWSConnector connector) {
    return verifiePlan(
        emaEvalFactoryService.getPlanManager(connector),
        emaEvalPlanIdFromEliot
    )
  }

  /**
   * Retourne le scénario par défaut utilisé pour la liaison TD Base / EmaEva
   * Cette méthode vérifie que le scénario obtenu depuis EmaEval est correct
   * @param connector
   * @return
   */
  TransitProcessDefinition getDefautScenario(EmaWSConnector connector) {
    return verifieScenario(
        emaEvalFactoryService.getWorkFlowManager(connector),
        emaEvalScenarioIdFromEliot
    )
  }

  /**
   * Retourne la méthode d'évaluation par défaut utilisée pour la liaison TD Base / EmaEval
   * Cette méthode vérifie que la méthode obtenue depiuis EmaEval est correcte
   * @param connector
   * @return
   */
  MethodEval getDefautMethodeEvaluation(EmaWSConnector connector) {
    return verifieMethodeEvaluation(
        emaEvalFactoryService.getMethodManager(connector),
        emaEvalMethodeEvaluationIdFromEliot
    )
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

    emaEvalProprieteService.setPropriete(
        ProprieteId.REFERENTIEL_STATUT,
        "OK"
    )
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

    emaEvalProprieteService.setPropriete(
        ProprieteId.REFERENTIEL_STATUT,
        "OK"
    )
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
  Plan verifiePlan(PlanManager planManager, long planId) {
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

    return plan
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

    emaEvalProprieteService.setPropriete(
        ProprieteId.PLAN_TDBASE_ID,
        plan.id.toString()
    )

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

    emaEvalProprieteService.setPropriete(
        ProprieteId.SCENARIO_EVALUATION_DIRECTE_ID,
        scenario.id
    )
  }

  TransitProcessDefinition verifieScenario(WorkFlowManager workFlowManager,
                                           String scenarioId) {

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

    return scenario
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
    emaEvalProprieteService.setPropriete(
        ProprieteId.METHODE_EVALUATION_BOOLEENNE_ID,
        methodEval.id.toString()
    )
  }

  /**
   * Vérifie que la méthode d'évaluation ayant methodeId pour identifiant existe bien
   * dans EmaEval et correspond à la méthode METHODE_EVALUATION_BOOLEENNE_NOM
   * @param methodManager
   * @param methodeId
   */
  MethodEval verifieMethodeEvaluation(MethodManager methodManager, long methodeId) {

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

    return methodEval
  }

  /**
   * Crée une campagne d'évaluation EmaEval pour une séance TD Base
   * @param modaliteActivite la séance TD Base
   *
   * L'identifiant de la campagne créée est stocké en base pour pouvoir ensuite transmettre les résultats
   *
   * @return
   */
  EvaluationDefinition creeCampagne(ModaliteActivite modaliteActivite) {
    String login = modaliteActivite.enseignant.autorite.identifiant

    // Récupère les éléments nécessaire à la création d'une campagne
    EmaWSConnector connector = emaEvalFactoryService.creeEmaWSConnector(login)
    Plan plan = getDefautPlan(connector)
    TransitProcessDefinition scenario = getDefautScenario(connector)
    MethodEval methodEval = getDefautMethodeEvaluation(connector)
    EvaluationDefinitionManager evaluationDefinitionManager =
      emaEvalFactoryService.getEvaluationDefinitionManager(connector)

    // Création campagne
    EvaluationDefinition campagne = creeCampagneEmaEval(
        evaluationDefinitionManager,
        modaliteActivite,
        login
    )

    // Mise à jour du plan de la campagne
    campagne = evaluationDefinitionManager.replacePlan(campagne, plan)

    // Mise à jour du scénario de la campagne
    campagne = evaluationDefinitionManager.replaceScenarioEvaluation(
        campagne,
        scenario.UUID
    )

    // Mise à jour de la méthode d'évaluation
    campagne = evaluationDefinitionManager.replaceMethodEval(
        campagne,
        methodEval
    )

    // Mise à jour des compétences évaluées
    campagne = metAJourCompetenceList(
        modaliteActivite,
        evaluationDefinitionManager,
        campagne
    )

    // Mise à jour de l'évaluateur
    campagne = metAJourEvaluateur(modaliteActivite, evaluationDefinitionManager, campagne)

    // Mise à jour des candidats
    campagne = metAJourCandidatList(
        modaliteActivite,
        evaluationDefinitionManager,
        campagne
    )

    // Association de l'évaluateur à tous les sujets
    campagne = associeEvaluateurSujetList(campagne, evaluationDefinitionManager)

    // instantiateED
    campagne = evaluationDefinitionManager.instantiateED(campagne)

    return campagne
  }

  /**
   * Transmet à EmaEval les scores des élèves sur les compétences évaluées dans une séance TD Base
   * @param evaluationSeance
   */
  void transmetScore(EvaluationSeance evaluationSeance) {
    CampagneProxy campagneProxy = evaluationSeance.campagneProxy
    EmaWSConnector connector = emaEvalFactoryService.creeEmaWSConnector(
        campagneProxy.operateurLogin
    )
    EvaluationDefinitionManager evaluationDefinitionManager =
      emaEvalFactoryService.getEvaluationDefinitionManager(connector)
    EvaluationSubjectInstanceManager evaluationSubjectInstanceManager =
      new EvaluationSubjectInstanceManager(connector)

    EvaluationDefinition campagne = evaluationDefinitionManager.getEvaluationDefinition(campagneProxy.campagneId)

    evaluationSeance.eachEleve { Personne eleve, EvaluationCopie evaluationCopie ->
      User user = new User()
      user.setUid(eleve.autorite.identifiant)

      evaluationSubjectInstanceManager.putResult(
          campagne,
          user,
          evaluationCopie.emaEvalScore
      )
    }
  }

  void supprimeCampagneEmaEval(String operateurLogin, Long campagneId) {

    EmaWSConnector connector = emaEvalFactoryService.creeEmaWSConnector(operateurLogin)
    EvaluationDefinitionManager evaluationDefinitionManager =
      emaEvalFactoryService.getEvaluationDefinitionManager(connector)

    // Récupère la campagne
    EvaluationDefinition campagne = evaluationDefinitionManager.getEvaluationDefinition(
        campagneId
    )

    // Supprime la campagne
    evaluationDefinitionManager.deleteEvaluationDefinition(campagne)
  }

  private static EvaluationDefinition associeEvaluateurSujetList(EvaluationDefinition campagne,
                                                                 evaluationDefinitionManager) {
    Set<EntityDefinition> entityDefinitionSet = [] as Set
    campagne.scenarioDefinitions.each { ScenarioDefinition scenarioDefinition ->
      scenarioDefinition.pid.processRoleDefinitions.each { ProcessRoleDefinition processRoleDefinition ->
        if (processRoleDefinition.name == "Evaluateurs") {
          processRoleDefinition.entityDefinitions.each {
            entityDefinitionSet << it
          }
        }
      }
    }


    Set<EvaluationSubject> evaluationSubjectSet = campagne.evaluationSubjects

    evaluationSubjectSet.each { EvaluationSubject evaluationSubject ->
      entityDefinitionSet.each { EntityDefinition entityDefinition ->
        campagne = evaluationDefinitionManager.addEDefToES(entityDefinition.id, evaluationSubject.id, campagne)
      }
    }

    return campagne
  }

  private static EvaluationDefinition metAJourCandidatList(ModaliteActivite modaliteActivite,
                                                           EvaluationDefinitionManager evaluationDefinitionManager,
                                                           EvaluationDefinition campagne) {
    Set<Entity> candidatList = [] as Set
    modaliteActivite.personnesDevantRendreCopie.each { Personne personne ->
      candidatList << new User(uid: personne.autorite.identifiant)
    }
    campagne = evaluationDefinitionManager.addEntities(
        campagne,
        candidatList,
        "Candidats"
    )

    return campagne
  }

  private static EvaluationDefinition metAJourEvaluateur(ModaliteActivite modaliteActivite,
                                                         EvaluationDefinitionManager evaluationDefinitionManager,
                                                         EvaluationDefinition campagne) {
    Set<Entity> evaluateurList = [] as Set
    evaluateurList << new User(
        uid: modaliteActivite.sujet.proprietaire.autorite.identifiant
    )

    campagne = evaluationDefinitionManager.addEntities(
        campagne,
        evaluateurList,
        "Evaluateurs"
    )

    return campagne
  }

  private static EvaluationDefinition metAJourCompetenceList(ModaliteActivite modaliteActivite,
                                                             EvaluationDefinitionManager evaluationDefinitionManager,
                                                             EvaluationDefinition campagne) {
    List<Competence> competenceList = modaliteActivite.sujet.findAllCompetence()
    List<Long> evaluationObjectIdList = getCompetenceIdEmaEvalList(competenceList)

    campagne = evaluationDefinitionManager.addEvaluationObjects(
        campagne,
        evaluationObjectIdList
    )

    return campagne
  }

  private static EvaluationDefinition creeCampagneEmaEval(EvaluationDefinitionManager evaluationDefinitionManager,
                                                          ModaliteActivite modaliteActivite,
                                                          String login) {
    evaluationDefinitionManager.addEvaluationDefinition(
        modaliteActivite.dateDebut,
        modaliteActivite.dateFin + 2, // 2j plus tard car EmaEval impose de transmettre les résultats avant la fin de la campagne
        login,
        "Campagne d'évaluation de la séance TD Base " + modaliteActivite.id,
        "Campagne d'évaluation de la séance TD Base " + modaliteActivite.id
    )
  }

  /**
   * Permet de récupérer la liste des identifiants dans EmaEval d'une liste de compétence Eliot
   *
   * Note d'implémentation : on passe par un criteria global pour éviter un N+1 SELECT
   *
   * @param competenceList
   * @return
   */
  private static List<Long> getCompetenceIdEmaEvalList(List<Competence> competenceList) {

    if (competenceList.isEmpty()) {
      return []
    }

    List<CompetenceIdExterne> competenceIdExterneList = CompetenceIdExterne.withCriteria {
      inList('competence', competenceList)
      eq('sourceReferentiel', SourceReferentiel.EMA_EVAL)
    } ?: []

    return competenceIdExterneList.collect {
      Long.parseLong(it.idExterne)
    }
  }
}



