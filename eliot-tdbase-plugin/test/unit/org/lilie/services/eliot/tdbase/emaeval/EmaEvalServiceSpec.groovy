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

package org.lilie.services.eliot.tdbase.emaeval

import grails.test.mixin.TestFor
import org.codehaus.groovy.grails.commons.GrailsApplication
import org.lilie.services.eliot.competence.ReferentielService
import spock.lang.Specification

/**
 * @author John Tranier
 */
@TestFor(EmaEvalService)
class EmaEvalServiceSpec extends Specification {

  EmaEvalService emaEvalService
  ReferentielService referentielService
  EmaEvalProprieteService emaEvalProprieteService
  EmaEvalFactoryService emaEvalFactoryService

  def setup() {
    referentielService = Mock(ReferentielService)
    emaEvalProprieteService = Mock(EmaEvalProprieteService)
    emaEvalFactoryService = Mock(EmaEvalFactoryService)

    emaEvalService = new EmaEvalService(
        referentielService: referentielService,
        emaEvalProprieteService: emaEvalProprieteService,
        emaEvalFactoryService: emaEvalFactoryService
    )

    def config = new ConfigObject()
    config.eliot.interfacage.emaeval.actif = true
    config.eliot.interfacage.emaeval.referentiel.nom = "referentiel"
    config.eliot.interfacage.emaeval.plan.nom = "plan"
    config.eliot.interfacage.emaeval.scenario.nom = "scenario"
    config.eliot.interfacage.emaeval.methodeEvaluation.nom = "méthode"

    emaEvalService.grailsApplication = [getConfig: {config}] as GrailsApplication
  }

  def "test isLiaisonReady"(boolean actif) {
    given:
    emaEvalService.grailsApplication.config.eliot.interfacage.emaeval.actif = actif
    emaEvalProprieteService.getPropriete(ProprieteId.REFERENTIEL_STATUT) >> new Propriete(valeur: "OK")
    emaEvalProprieteService.getPropriete(ProprieteId.PLAN_TDBASE_ID) >> new Propriete(valeur: "1")
    emaEvalProprieteService.getPropriete(ProprieteId.SCENARIO_EVALUATION_DIRECTE_ID) >> new Propriete(valeur: "2")
    emaEvalProprieteService.getPropriete(ProprieteId.METHODE_EVALUATION_BOOLEENNE_ID) >> new Propriete(valeur: "3")

    expect:
    emaEvalService.isLiaisonReady() == actif

    where:
    actif << [true, false]
  }

}
