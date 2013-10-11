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

import com.pentila.emawsconnector.manager.EvaluationObjectManager
import com.pentila.emawsconnector.utils.EmaWSConnector
import grails.plugin.spock.IntegrationSpec
import org.codehaus.groovy.grails.commons.ConfigurationHolder
import org.codehaus.groovy.grails.commons.GrailsApplication
import spock.lang.IgnoreIf

/**
 * Ce test permet de vérifier la connexion aux webservices d'EmaEval.
 *
 * Il nécessite :
 *  1) Que l'application EmaEval soit lancée
 *  2) Que l'url de connexion aux webservices d'EmaEval soit bien configurée
 *  3) Qu'au moins un référentiel de compétence ait été initialisé dans l'application EmaEval
 *  4) Que le certificat d'EmaEval soit reconnu par la JVM (la statégie que j'ai mis en place localement a
 *  consistée à créer un TrustStore dans lequel le certificat d'EmaEval comme "trustedCertEntry" + de transmettre
 *  les informations sur le TrustStore au lancement de l'application eliot-tdbase par les variables d'environnement
 *  suivantes : -Djavax.net.ssl.trustStore=/Users/john/.eliot/keystore.jks -Djavax.net.ssl.trustStorePassword=emaeval
 *
 *  Si la liaison à EmaEval est désactivée par configuration, ce test ne sera pas exécuté.
 *
 * @author John Tranier
 */
class EmaWSConnectorSpec extends IntegrationSpec {

  GrailsApplication grailsApplication

  @IgnoreIf({ !ConfigurationHolder.config.eliot.interfacage.emaeval.actif })
  def "testGetAllReferentiels"() {
    given:
    String url = grailsApplication.config.eliot.interfacage.emaeval.url
    EmaWSConnector emaWSConnector = new EmaWSConnector(url, 'xml', 'login') // Apparemment le webservice getAllReferentiels ne nécessite pas de login spécifique
    EvaluationObjectManager evaluationObjectManager = new EvaluationObjectManager(emaWSConnector)

    expect:
    evaluationObjectManager.allReferentiels
  }
}
