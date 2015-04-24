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

package org.lilie.services.eliot.tdbase.preferences

import org.codehaus.groovy.grails.commons.GrailsApplication
import org.lilie.services.eliot.tdbase.securite.RoleApplicatif
import org.lilie.services.eliot.tice.scolarite.FonctionEnum

/**
 * @author John Tranier
 */
class GestionnaireModificationLiaisonFonctionRole {

    GrailsApplication grailsApplication

    // Associe le code d'un rôle applicatif, à une association <code-fonction, booléen>
    // La valeur 'default' peut être utilisée à la place des codes de rôle / fonction pour définir
    // une valeur pour tous les rôles & fonctions qui ne sont pas explicitement définis
    Map<String, Map<String, Boolean>> liaisonFonctionRoleModifiable

    private void init() {
        if(!liaisonFonctionRoleModifiable) {

            liaisonFonctionRoleModifiable =
                    grailsApplication.config.eliot.tdbase.mappingFonctionRole.modifiable

            if(!liaisonFonctionRoleModifiable) {
                throw new IllegalStateException(
                        "La variable de configuration 'eliot.tdbase.mappingFonctionRole.modifiable' doit être définie"
                )
            }
        }
    }

    boolean isLiaisonModifiable(RoleApplicatif roleApplicatif, FonctionEnum fonctionEnum) {
        if(!liaisonFonctionRoleModifiable) {
            init()
        }

        // Recherche de la configuration pour le rôle
        Map<String, Boolean> fonctionMap =
                liaisonFonctionRoleModifiable[roleApplicatif.name()]

        // Si non trouvé, recherche de la configuration par défaut
        if (!fonctionMap) {
            fonctionMap = liaisonFonctionRoleModifiable["default"]

            // Si non trouvé ==> non modifiable
            if (!fonctionMap) {
                return false
            }
        }


        // Recherche de la configuration pour la fonction
        if (fonctionMap.containsKey(fonctionEnum.name())) {
            return fonctionMap[fonctionEnum.name()]
        }
        // Recherche de la configuration par défaut
        else if (fonctionMap.containsKey("default")) {
            return fonctionMap["default"]
        }
        // Si non trouvé ==> non modifiable
        return false
    }
}


