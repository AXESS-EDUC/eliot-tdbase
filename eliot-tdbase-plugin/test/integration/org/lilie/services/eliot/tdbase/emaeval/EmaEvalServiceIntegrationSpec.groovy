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
import grails.plugin.spock.IntegrationSpec
import groovy.util.slurpersupport.GPathResult
import org.codehaus.groovy.grails.commons.ConfigurationHolder
import org.lilie.services.eliot.competence.Referentiel
import org.lilie.services.eliot.competence.ReferentielDto
import org.lilie.services.eliot.competence.ReferentielService
import org.lilie.services.eliot.competence.SourceReferentiel
import org.lilie.services.eliot.tdbase.emaeval.xml.ReferentielMarshaller
import org.springframework.core.io.ClassPathResource
import spock.lang.IgnoreIf

/**
 * Cette classe comprend des tests concernant le connecteur aux webservices d'EmaEval
 * Ces tests ne peuvent être joués que si la liaison à EmaEval est configurée & active
 * Il sont donc automatiquement désactivés si la liaison est désactivée par configuration
 *
 * @author John Tranier
 */
class EmaEvalServiceIntegrationSpec extends IntegrationSpec {
  EmaEvalService emaEvalService
  EmaEvalFactoryService emaEvalFactoryService
  ReferentielService referentielService
  String emaEvalUserLogin = "100000000000001027"
  EmaEvalProprieteService emaEvalProprieteService


  def setup() {

  }

  private void importeReferentielPalier3() {
    GPathResult xml = new XmlSlurper().parse(
        new ClassPathResource('org/lilie/services/eliot/tdbase/emaeval/Palier3.xml').inputStream
    )
    ReferentielMarshaller referentielMarshaller = new ReferentielMarshaller()
    ReferentielDto referentielDto = referentielMarshaller.parse(xml)

    referentielService.importeReferentiel(referentielDto)

    assert Referentiel.findByNom("Palier 3")
  }

  def "test findEliotReferentiel"() {
    given:
    importeReferentielPalier3()

    when:
    Referentiel referentiel = emaEvalService.findEliotReferentiel()

    then:
    referentiel.nom == emaEvalService.defautReferentielNom
    Long.parseLong(referentiel.getIdExterne(SourceReferentiel.EMA_EVAL)) == 1
  }

  @IgnoreIf({ !ConfigurationHolder.config.eliot.interfacage.emaeval.actif })
  def "test FindEmaEvalReferentielByName"() {
    given:
    EvaluationObjectManager evaluationObjectManager =
      emaEvalFactoryService.getEvaluationObjectManager(
          emaEvalFactoryService.creeEmaWSConnector(emaEvalUserLogin)
      )

    expect:
    !emaEvalService.findEmaEvalReferentielByName(evaluationObjectManager, 'Inexistant')

    com.pentila.evalcomp.domain.definition.Referentiel emaEvalReferentiel =
      emaEvalService.findEmaEvalReferentielByName(
          evaluationObjectManager,
          emaEvalService.defautReferentielNom
      )
    emaEvalReferentiel.name == emaEvalService.defautReferentielNom
  }

  @IgnoreIf({ !ConfigurationHolder.config.eliot.interfacage.emaeval.actif })
  def "test findEmaEvalReferentielByEliotReferentiel"() {
    given:
    importeReferentielPalier3()
    EvaluationObjectManager evaluationObjectManager =
      emaEvalFactoryService.getEvaluationObjectManager(
          emaEvalFactoryService.creeEmaWSConnector(emaEvalUserLogin)
      )
    Referentiel referentiel = emaEvalService.findEliotReferentiel()

    expect:
    emaEvalService.findEmaEvalReferentielByEliotReferentiel(
        evaluationObjectManager,
        referentiel
    ).name == referentiel.nom
  }

  @IgnoreIf({ !ConfigurationHolder.config.eliot.interfacage.emaeval.actif })
  def "test findEmaEvalReferentielById"() {
    given:
    importeReferentielPalier3()
    EvaluationObjectManager evaluationObjectManager =
      emaEvalFactoryService.getEvaluationObjectManager(
          emaEvalFactoryService.creeEmaWSConnector(emaEvalUserLogin)
      )
    Referentiel referentiel = emaEvalService.findEliotReferentiel()
    Long id = Long.parseLong(referentiel.getIdExterne(SourceReferentiel.EMA_EVAL))

    expect:
    emaEvalService.findEmaEvalReferentielById(
        evaluationObjectManager,
        id
    ).name == referentiel.nom
  }

  @IgnoreIf({ !ConfigurationHolder.config.eliot.interfacage.emaeval.actif })
  def "test importeReferentielFromEmaEval"() {
    given:
    EvaluationObjectManager evaluationObjectManager =
      emaEvalFactoryService.getEvaluationObjectManager(
          emaEvalFactoryService.creeEmaWSConnector(emaEvalUserLogin)
      )

    when:
    emaEvalService.importeReferentielFromEmaEval(evaluationObjectManager)

    then:
    Propriete propriete = emaEvalProprieteService.getPropriete(ProprieteId.REFERENTIEL_STATUT)
    propriete.valeur == "OK"
    emaEvalService.initialiseOuVerifieReferentiel()
  }

  @IgnoreIf({ !ConfigurationHolder.config.eliot.interfacage.emaeval.actif })
  def "test creePlanDansEmaEval"() {
    given:
    PlanManager planManager = emaEvalFactoryService.getPlanManager(
        emaEvalFactoryService.creeEmaWSConnector(emaEvalUserLogin)
    )

    when:
    emaEvalService.creePlanDansEmaEval(planManager)

    then:
    Propriete propriete = emaEvalProprieteService.getPropriete(
        ProprieteId.PLAN_TDBASE_ID
    )
    propriete.valeur
    emaEvalService.initialiseOuVerifiePlan()
  }

  @IgnoreIf({ !ConfigurationHolder.config.eliot.interfacage.emaeval.actif })
  def "test importeScenarioFromEmaEval"() {
    given:
    WorkFlowManager workFlowManager = emaEvalFactoryService.getWorkFlowManager(
        emaEvalFactoryService.creeEmaWSConnector(emaEvalUserLogin)
    )

    when:
    emaEvalService.importeScenarioFromEmaEval(workFlowManager)

    then:
    Propriete propriete = emaEvalProprieteService.getPropriete(
        ProprieteId.SCENARIO_EVALUATION_DIRECTE_ID
    )
    propriete.valeur
    emaEvalService.initialiseOuVerifieScenario()
  }

  @IgnoreIf({ !ConfigurationHolder.config.eliot.interfacage.emaeval.actif })
  def "test importeMethodeEvaluationFromEmaEval"() {
    given:
    MethodManager methodManager = emaEvalFactoryService.getMethodManager(
        emaEvalFactoryService.creeEmaWSConnector(emaEvalUserLogin)
    )

    when:
    emaEvalService.importeMethodeEvaluationFromEmaEval(methodManager)

    then:
    Propriete propriete = emaEvalProprieteService.getPropriete(
        ProprieteId.METHODE_EVALUATION_BOOLEENNE_ID
    )
    propriete.valeur
    emaEvalService.initialiseOuVerifieMethodeEvaluation()
  }
}
