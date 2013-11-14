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

import com.pentila.emawsconnector.manager.EvaluationDefinitionManager
import com.pentila.emawsconnector.manager.EvaluationObjectManager
import com.pentila.emawsconnector.manager.MethodManager
import com.pentila.emawsconnector.manager.PlanManager
import com.pentila.emawsconnector.manager.WorkFlowManager
import com.pentila.emawsconnector.utils.EmaWSConnector
import org.codehaus.groovy.grails.commons.GrailsApplication

/**
 * Service qui prend en charge l'instantiation des différents managers permettant
 * d'utiliser les webservices d'EmaEval
 *
 * @author John Tranier
 */
class EmaEvalFactoryService {
  static transactional = true

  @SuppressWarnings('GrailsStatelessService') // singleton
  GrailsApplication grailsApplication

  /**
   * Crée une instance de EmaWSConnector
   * @param login l'identifiant externe de l'utilisateur au nom duquel les webservices
   * seront utilisés
   * @return
   */
  EmaWSConnector creeEmaWSConnector(String login) {
    assert grailsApplication.config.eliot.interfacage.emaeval.actif

    String url = grailsApplication.config.eliot.interfacage.emaeval.url
    EmaWSConnector emaWSConnector = new EmaWSConnector(url, 'xml', login)

    return emaWSConnector
  }

  MethodManager getMethodManager(EmaWSConnector connector) {
    return new MethodManager(connector)
  }

  WorkFlowManager getWorkFlowManager(EmaWSConnector connector) {
    return new WorkFlowManager(connector)
  }

  PlanManager getPlanManager(EmaWSConnector connector) {
    return new PlanManager(connector)
  }

  EvaluationObjectManager getEvaluationObjectManager(EmaWSConnector connector) {
    return new EvaluationObjectManager(connector)
  }

  EvaluationDefinitionManager getEvaluationDefinitionManager(EmaWSConnector connector) {
    return new EvaluationDefinitionManager(connector)
  }
}
