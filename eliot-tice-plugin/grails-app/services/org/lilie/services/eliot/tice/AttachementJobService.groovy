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



package org.lilie.services.eliot.tice

import groovy.io.FileType
import org.lilie.services.eliot.tice.jackrabbit.core.data.version_2_4_0.DataStore

/**
 * Classe fournissant le service de gestion de breadcrumps
 * @author franck silvestre
 */
class AttachementJobService {

  static transactional = false
  DataStore dataStore

  /**
   * Garbage collect le datastore de attachements
   * @return le rapport de la garbage collection
   */
  GarbageCollectionDataStoreRapport garbageCollectDataStore() {
    def rootDir = new File(dataStore.getPath())
    GarbageCollectionDataStoreRapport rapport = new GarbageCollectionDataStoreRapport()
    rapport.dateGarbageCollection = new Date()
    if (Attachement.count() >= 0) {  // test acces base
      rootDir.eachFileRecurse(FileType.FILES) {
        rapport.nombreFichiersVerifies += 1
        def chemin = it.name
        def att = Attachement.findByCheminLike("${chemin}%")
        if (att == null) {
          log.warn("Fichier à supprimer : ${it.absolutePath}")
          if (it.delete()) {
            rapport.nombreFichiersSupprimes += 1
            log.warn("Fichier supprimé !")
          } else {
            rapport.nombreFichiersASupprimerNonSupprimes += 1
            log.warn("Fichier non supprimé.")
          }

        }
      }
    }
    rapport
  }


}

/**
 * Class représentant le rapport d'une garbage collection
 */
class GarbageCollectionDataStoreRapport {
  Date dateGarbageCollection
  Long nombreFichiersVerifies = 0
  Long nombreFichiersSupprimes = 0
  Long nombreFichiersASupprimerNonSupprimes = 0

}

