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

import org.lilie.services.eliot.tdbase.preferences.MappingFonctionRole
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissement
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissementService
import org.lilie.services.eliot.tdbase.securite.SecuriteSessionService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.utils.BreadcrumpsService

class PreferencesController {

    static scope = "singleton"

    BreadcrumpsService breadcrumpsServiceProxy
    SecuriteSessionService securiteSessionServiceProxy
    PreferenceEtablissementService preferenceEtablissementService

    /**
     * Accueil preferences
     * @return
     */
    def index() {
        Personne user = authenticatedPersonne
        breadcrumpsServiceProxy.manageBreadcrumps(params,
                message(code: "preferences.index.title"))

        Etablissement etab = securiteSessionServiceProxy.currentEtablissement
        PreferenceEtablissement pref = securiteSessionServiceProxy.currentPreferenceEtablissement

        [liens                  : breadcrumpsServiceProxy.liens,
         etablissement          : etab,
         mappingFonctionRole    : pref.mappingFonctionRoleAsMap(),
         fonctions              : preferenceEtablissementService.getFonctionsForEtablissement(etab),
         preferenceEtablissement: pref
        ]
    }

    /**
     * Enregistre une nouvelle version du mapping fonction rôle
     * @return
     */
    def enregistre() {
        PreferenceEtablissement prefEtab = securiteSessionServiceProxy.currentPreferenceEtablissement
        def mapping = getMappingFromParamsForPreferenceEtablissement(params, prefEtab)
        prefEtab.mappingFonctionRole = mapping.toJsonString()
        preferenceEtablissementService.updatePreferenceEtablissement(authenticatedPersonne, prefEtab)
        securiteSessionServiceProxy.initialiseRoleApplicatifListForCurrentEtablissement(authenticatedPersonne)
        flash.messageTextesCode = "preferences.save.success"
        redirect(controller: "preferences", action: "index", params: [bcInit: true])
    }

    private MappingFonctionRole getMappingFromParamsForPreferenceEtablissement(
            def params, PreferenceEtablissement prefEtab) {
        // start with the current mapping
        MappingFonctionRole mapping = prefEtab.mappingFonctionRoleAsMap()
        // apply changes
        mapping.reset()
        params.each { String key, value ->
            if (key.startsWith("fonction_")) {
                def keyParts = key.split("__")
                mapping.addRoleForFonction(RoleApplicatif.valueOf(keyParts[3]), FonctionEnum.valueOf(keyParts[1]))
            }
        }
        mapping
    }

}


