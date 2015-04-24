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

package org.lilie.services.eliot.tice.webservices.test

import grails.converters.JSON
import org.lilie.services.eliot.tice.scolarite.ProprietesScolarite
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.Fonction
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeEnt

/**
 * @author John Tranier
 */
class RechercheGroupeController {

    static scope = "singleton"

    def rechercheGroupeList() {

        switch (params.type) {
            case 'SCOLARITE':
                return rechercheGroupeScolariteList()

            case 'ENT':
                return rechercheGroupeEntList()

            default:
                throw new IllegalStateException(
                        "Type de groupe inconnu : ${params.type}"
                )
        }
    }

    private rechercheGroupeScolariteList() {
        Etablissement etablissement = Etablissement.load(params.etablissementId)
        Fonction fonction = Fonction.load(params.fonctionId)

        List<ProprietesScolarite> groupeScolariteList = ProprietesScolarite.withCriteria {
            or {
                eq('etablissement', etablissement)
                'structureEnseignement' {
                    eq('etablissement', etablissement)
                }
            }
            eq('fonction', fonction)
        }


        render([
                kind          : "eliot-scolarite#groupes#paginable",
                groupes       : groupeScolariteList.collect {
                    convertGroupeScolarite(it)
                },
                'nombre-total': groupeScolariteList.size()
        ] as JSON)
    }

    private rechercheGroupeEntList() {
        Etablissement etablissement = Etablissement.load(params.etablissementId)

        List<GroupeEnt> groupeEntList = GroupeEnt.findAllByEtablissement(etablissement)

        render([
                kind          : "eliot-scolarite#groupes#paginable",
                groupes       : groupeEntList.collect {
                    convertGroupeEnt(it)
                },
                'nombre-total': groupeEntList.size()
        ] as JSON)
    }

    private Map convertGroupeScolarite(ProprietesScolarite proprietesScolarite) {
        return [
                kind           : "eliot-scolarite#groupes#standard",
                id             : proprietesScolarite.id,
                "nom-affichage": proprietesScolarite.nomAffichage,
                'autorite-id'  : null,
                type           : 'SCOLARITE'
        ]
    }

    private Map convertGroupeEnt(GroupeEnt groupeEnt) {
        return [
                kind           : "eliot-scolarite#groupes#standard",
                id             : groupeEnt.id,
                "nom-affichage": groupeEnt.nomAffichage,
                'autorite-id'  : null,
                type           : 'ENT'

        ]
    }
}
