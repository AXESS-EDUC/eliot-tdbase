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
package org.lilie.services.eliot.tdbase

import org.lilie.services.eliot.tice.utils.BreadcrumpsService
import org.lilie.services.eliot.tice.AttachementJobService
import org.lilie.services.eliot.tice.GarbageCollectionDataStoreRapport

class MaintenanceController {

  CopieJobService copieJobService
  BreadcrumpsService breadcrumpsService
  AttachementJobService attachementJobService

  /**
   * Accueil maintenance
   * @return
   */
  def index() {
    breadcrumpsService.manageBreadcrumps(params,
                                         message(code: message(code: message(code: "maintenance.index.title"))))
    [liens: breadcrumpsService.liens]
  }

  /**
   * Action de suppression des copie jetables dont le dernier enregistrement date
   * de plus de 10 jours
   */
  def supprimeCopiesJetables() {
    breadcrumpsService.manageBreadcrumps(params,
                                         message(code: message(code: "maintenance.supprimecopiesjetables.title")))
    def nbJ = params?.nbJ as Integer
    SupprimeCopiesJetablesRapport rapport = copieJobService.supprimeCopiesJetablesForNombreJoursPasses(nbJ)
    render(view: '/maintenance/rapportSupprimeCopieJetable',
           model: [liens: breadcrumpsService.liens, rapport: rapport])
  }

  /**
   * Action de garbage collection des fichiers du datastore
   */
  def garbageCollectAttachementDataStore() {
    breadcrumpsService.manageBreadcrumps(params,
                                         message(code: message(code: message(code:"maintenance.garbagecollectiondatastore.title"))))
    GarbageCollectionDataStoreRapport rapport = attachementJobService.garbageCollectDataStore()
    render(view: '/maintenance/rapportGarbageCollectionAttachementDataStore',
           model: [liens: breadcrumpsService.liens, rapport: rapport])
  }


}


