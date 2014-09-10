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

package org.lilie.services.eliot.tdbase

import org.lilie.services.eliot.tdbase.parametrage.MappingFonctionRole
import org.lilie.services.eliot.tice.scolarite.Fonction
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.utils.contract.Contract
import org.lilie.services.eliot.tice.utils.contract.PreConditionException
import spock.lang.Specification
import spock.lang.Unroll

/**
 * @author Franck Silvestre
 */
class MappingFonctionRoleSpec extends Specification {

    Fonction ens
    Fonction elv

    def setup() {
        ens = new Fonction(code: FonctionEnum.ENS.name(), libelle: "enseignant")
        elv = new Fonction(code: FonctionEnum.ELEVE.name(), libelle: "eleve")
    }

    def "creation d'un mapping fonction role"() {

        given: "les fonctions disponibles"
        ens
        elv

        when: "un nveau mapping est cree"
        MappingFonctionRole mapping = new MappingFonctionRole()

        then: "le mapping est vide"
        mapping.isEmpty()

    }

    def "ajout d'associations fonction role"() {

        given: "un mapping tout neuf"
        MappingFonctionRole mapping = new MappingFonctionRole()

        when: "un role est associe a une fonction"
        mapping.addRoleForFonction(RoleApplicatif.ENSEIGNANT, ens)

        then: "le role est ajoute a la liste des roles associes a la fonction"
        mapping.getRolesForFonction(ens).contains(RoleApplicatif.ENSEIGNANT)

        when: "un deuxieme role est ajoute"
        mapping.addRoleForFonction(RoleApplicatif.ELEVE, ens)

        then: "deux roles sont dans la liste des roles associes a la fonction"
        mapping.getRolesForFonction(ens).size() == 2

        when: "une nouveau role est associe a une nouvelle fonction"
        mapping.addRoleForFonction(RoleApplicatif.ENSEIGNANT, elv)

        then: "la deuxieme fonction a bien un role dans sa liste de role"
        mapping.getRolesForFonction(ens).size() == 2
        mapping.getRolesForFonction(elv).first() == RoleApplicatif.ENSEIGNANT

    }

    def "suppression d'associations fonction role sur un mapping vide"() {

        given: "un nouveau mapping vierge"
        MappingFonctionRole mapping = new MappingFonctionRole()

        when: "tentative de supprimer une association"
        mapping.deleteRoleForFonction(RoleApplicatif.ENSEIGNANT, ens)

        then: "il ne se passe rien, le mapping est vide"
        mapping.isEmpty()

    }

    def "suppression d'associations fonction role sur un mapping non vide"() {

        given: "un mapping contenant des associations"
        MappingFonctionRole mapping = new MappingFonctionRole()
        mapping.addRoleForFonction(RoleApplicatif.ENSEIGNANT, ens)
        mapping.addRoleForFonction(RoleApplicatif.ELEVE, ens)
        mapping.addRoleForFonction(RoleApplicatif.ENSEIGNANT, elv)

        when: "tentative de supprimer une association"
        mapping.deleteRoleForFonction(RoleApplicatif.ENSEIGNANT, ens)

        then: "le mapping est modifie en consequence"
        !mapping.isEmpty()
        mapping.getRolesForFonction(ens).size() == 1
        !mapping.getRolesForFonction(ens).contains(RoleApplicatif.ENSEIGNANT)

    }

    def "creation d'un mapping a partir d'une map existante"() {

        given: "une map valide"
        Map aMap = ["${ens.code}": [RoleApplicatif.ENSEIGNANT.name(), RoleApplicatif.ELEVE.name()],
                    "${elv.code}": [RoleApplicatif.ENSEIGNANT.name(), RoleApplicatif.ELEVE.name()]]

        when: "creation d'un mapping a partir d'une map existente valide"
        MappingFonctionRole mapping = new MappingFonctionRole(aMap)

        then: "le mapping est cree et initialise correctement"
        noExceptionThrown()
        !mapping.isEmpty()

    }

    def "creation d'un mapping a partir d'une map null ou vide"(Map aMap, _) {

        when: "creation d'un mapping a partir de la map null ou d'une map vide"
        MappingFonctionRole mapping = new MappingFonctionRole(aMap)

        then: "le mapping est initialisé à vide"
        noExceptionThrown()
        mapping != null
        mapping.isEmpty()

        where:
        aMap | _
        null | _
        [:]  | _

    }

    def "creation d'un mapping a partir d'une map non valide"(Map aMap, _) {

        when: "creation d'un mapping a partir de la map avec bad key"
        new MappingFonctionRole(aMap)


        then: "la creation du mapping echoue"
        thrown(PreConditionException)

        where:
        aMap                                                                                                                                                 | _
        ["ENS": [RoleApplicatif.ENSEIGNANT.name(), RoleApplicatif.ELEVE.name()], "bad_key": [RoleApplicatif.ENSEIGNANT.name(), RoleApplicatif.ELEVE.name()]] | _
        ["ENS": "bad_value", "elv": [RoleApplicatif.ENSEIGNANT.name(), RoleApplicatif.ELEVE.name()]]                                                         | _

    }

    def "creation d'un mapping a partir d'un Json valide"(String json, _) {

        when: "creation d'un mapping a partir de json"
        MappingFonctionRole mapping = new MappingFonctionRole(json)

        then: "le mapping est initialisé correctement"
        noExceptionThrown()
        mapping != null
        mapping.getRolesForFonction(ens) == [RoleApplicatif.ENSEIGNANT, RoleApplicatif.ELEVE]

        where:
        json                                               | _
        '{"ENS":["ENSEIGNANT","ELEVE"]}'                   | _
        '{"ENS":["ENSEIGNANT","ELEVE"],"ELEVE":["ELEVE"]}' | _

    }

    def "creation d'un mapping a partir d'un Json vide ou null"(String json, _) {

        when: "creation d'un mapping a partir de json"
        MappingFonctionRole mapping = new MappingFonctionRole(json)

        then: "le mapping est initialisé à vide"
        noExceptionThrown()
        mapping.isEmpty()

        where:
        json | _
        '{}' | _
        null | _

    }

    def "creation d'un mapping a partir d'un Json non valide"(String json, _) {

        when: "creation d'un mapping a partir de json"
        new MappingFonctionRole(json)

        then: "le mapping est initialisé à vide"
        thrown(PreConditionException)

        where:
        json                                                 | _
        '{"bad key":["ENSEIGNANT","ELEVE"]}'                 | _
        '{"ENS":["ENSEIGNANT","ELEVE"],"ELEVE":"bad value"}' | _

    }

    @Unroll
    def "conversion en Json d'un mapping"(Map aMap, String jsonAttendu) {

        given: "un mapping existant"
        def mapping = new MappingFonctionRole(aMap)

        when: "une conversion est demandee"
        String json = mapping.toJsonString()

        then: "le json obtenu correspond bien au mapping"
        json == jsonAttendu

        where:
        aMap                                                 | jsonAttendu
        null                                                 | '{}'
        [:]                                                  | '{}'
        ["ENS": ["ENSEIGNANT", "ELEVE"]]                     | '{"ENS":["ENSEIGNANT","ELEVE"]}'
        ["ENS": ["ENSEIGNANT", "ELEVE"], "ELEVE": ["ELEVE"]] | '{"ENS":["ENSEIGNANT","ELEVE"],"ELEVE":["ELEVE"]}'


    }

}
