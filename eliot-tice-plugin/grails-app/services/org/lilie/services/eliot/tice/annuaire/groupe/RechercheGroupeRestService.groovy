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

package org.lilie.services.eliot.tice.annuaire.groupe

import org.codehaus.groovy.grails.commons.GrailsApplication
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.Fonction
import org.lilie.services.eliot.tice.webservices.rest.client.RestClient

/**
 * @author John Tranier
 */
class RechercheGroupeRestService {

    static transactional = false
    RestClient restClientForScolarite
    GrailsApplication grailsApplication

    /**
     * Recherche de groupe (scolarité ou ENT) via le WS de recherche de groupe
     * @param personne
     * @param critere
     * @param groupeType
     * @param codePorteur
     * @return
     */
    def rechercheGroupeList(Personne personne,
                            RechercheGroupeCritere critere,
                            GroupeType groupeType,
                            String codePorteur = null) {
        Map httpParameters = [
                utilisateurPersonneId: personne.id,
                codePorteur          : codePorteur,
                type                 : groupeType.name(),
                fonctionId           : critere.fonction.id,
                etablissementId      : critere.etablissement.id,
                motCle               : critere.motCle,
                offset               : 0,
                max                  : grailsApplication.config.eliot.listes.groupes.maxrecherche
        ]

      restClientForScolarite.invokeOperation(
                'rechercheGroupeList',
                null,
                httpParameters
        )
    }
}
