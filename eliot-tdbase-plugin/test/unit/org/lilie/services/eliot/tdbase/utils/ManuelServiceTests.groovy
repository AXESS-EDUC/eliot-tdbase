/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
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
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tdbase.utils

import grails.test.mixin.TestFor
import org.lilie.services.eliot.tdbase.securite.RoleApplicatif
import org.lilie.services.eliot.tice.scolarite.FonctionEnum

/**
 * See the API for {@link grails.test.mixin.services.ServiceUnitTestMixin} for usage instructions
 */
@TestFor(PortailTagLibService)
class ManuelServiceTests {

  private static final String URL1 = "/aide/documents/Manuel_Utilisateur_Tdbase_Enseignants.pdf"
  private static final String URL2 = "/aide/documents/Manuel_Utilisateur_Tdbase_Eleves.pdf"
  private static final String URL3 = "/aide/documents/Manuel_Utilisateur_Tdbase_Parents.pdf"
  PortailTagLibService portailTagLibService = new PortailTagLibService()


  void testaddManuelDocumentUrls() {
    def urlMap = [
            "${RoleApplicatif.ENSEIGNANT.name()}": URL1,
            "${RoleApplicatif.SUPER_ADMINISTRATEUR.name()}": URL1,
            "${RoleApplicatif.ELEVE.name()}": URL2,
            "${RoleApplicatif.PARENT.name()}": URL3
    ]
    portailTagLibService.addManuelDocumentUrls(urlMap)
    def url1 = portailTagLibService.findManuelDocumentUrlForRole(RoleApplicatif.ENSEIGNANT)
    def url2 = portailTagLibService.findManuelDocumentUrlForRole(RoleApplicatif.ELEVE)
    assertEquals "url enseignant non conforme",URL1,url1
    assertEquals "url eleve non conforme",URL2,url2
    def url3 = portailTagLibService.findManuelDocumentUrlForRole(RoleApplicatif.PARENT)
    assertEquals "url parent non conforme",URL3,url3
    assertNull portailTagLibService.findManuelDocumentUrlForRole(RoleApplicatif.ADMINISTRATEUR)
  }
}