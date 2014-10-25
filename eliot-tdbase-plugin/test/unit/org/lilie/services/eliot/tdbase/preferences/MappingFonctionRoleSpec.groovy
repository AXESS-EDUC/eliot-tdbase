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

import org.lilie.services.eliot.tdbase.securite.RoleApplicatif
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.utils.contract.PreConditionException
import spock.lang.Specification
import spock.lang.Unroll

/**
 * @author Franck Silvestre
 */
class MappingFonctionRoleSpec extends Specification {

    Map aMap

    def setup() {
        aMap = [
                ("${FonctionEnum.ENS.name()}".toString())           : [
                        ("${RoleApplicatif.ENSEIGNANT.name()}".toString()): [associe: true, modifiable: false],
                        ("${RoleApplicatif.ELEVE.name()}".toString())     : [associe: true, modifiable: true]],
                ("${FonctionEnum.ELEVE.name()}".toString())         : [
                        ("${RoleApplicatif.ENSEIGNANT.name()}".toString()): [associe: false, modifiable: true],
                        ("${RoleApplicatif.ELEVE.name()}".toString())     : [associe: true, modifiable: true]],
                ("${FonctionEnum.PERS_REL_ELEVE.name()}".toString()): [
                        ("${RoleApplicatif.ENSEIGNANT.name()}".toString()): [associe: false, modifiable: false],
                        ("${RoleApplicatif.PARENT.name()}".toString())    : [associe: true, modifiable: false]]
        ]
    }


    def "creation d'un mapping fonction role vide"() {

        when: "un nveau mapping est cree"
        MappingFonctionRole mapping = new MappingFonctionRole()

        then: "le mapping est vide"
        mapping.isEmpty()

    }

    def "creation d'un mapping a partir d'une map existante"() {

        given: "une map d'initialisation"
        aMap

        when: "creation d'un mapping a partir de la map"
        MappingFonctionRole mapping = new MappingFonctionRole(aMap)

        then: "le mapping est initialise de manier coherente"
        mapping.getRolesForFonction(FonctionEnum.ENS).size() == 2
        mapping.getRolesForFonction(FonctionEnum.ENS).containsAll([RoleApplicatif.ENSEIGNANT, RoleApplicatif.ELEVE])
        mapping.getRolesForFonction(FonctionEnum.ELEVE).size() == 1
        mapping.getRolesForFonction(FonctionEnum.ELEVE).contains(RoleApplicatif.ELEVE)
        mapping.getRolesForFonction(FonctionEnum.PERS_REL_ELEVE).size() == 1
        mapping.getRolesForFonction(FonctionEnum.PERS_REL_ELEVE).contains(RoleApplicatif.PARENT)
    }

    def "ajout d'associations fonction role a un mapping vide"() {

        given: "un mapping tout neuf"
        MappingFonctionRole mapping = new MappingFonctionRole()

        when: "un role est associe a une fonction"
        mapping.addRoleForFonction(RoleApplicatif.ENSEIGNANT, FonctionEnum.ENS)

        then: "le role est ajoute a la liste des roles associes a la fonction"
        mapping.getRolesForFonction(FonctionEnum.ENS).contains(RoleApplicatif.ENSEIGNANT)

        when: "un deuxieme role est ajoute"
        mapping.addRoleForFonction(RoleApplicatif.ELEVE, FonctionEnum.ENS)

        then: "deux roles sont dans la liste des roles associes a la fonction"
        mapping.getRolesForFonction(FonctionEnum.ENS).size() == 2

        when: "une nouveau role est associe a une nouvelle fonction"
        mapping.addRoleForFonction(RoleApplicatif.ENSEIGNANT, FonctionEnum.ELEVE)

        then: "la deuxieme fonction a bien un role dans sa liste de role"
        mapping.getRolesForFonction(FonctionEnum.ENS).size() == 2
        mapping.getRolesForFonction(FonctionEnum.ELEVE).first() == RoleApplicatif.ENSEIGNANT

    }

    def "ajout d'associations fonction role a un mapping initialise"() {

        given: "un mapping initialise"
        MappingFonctionRole mapping = new MappingFonctionRole(aMap)

        when: "un role est associe a une fonction sur association modifiable"
        mapping.addRoleForFonction(RoleApplicatif.ENSEIGNANT, FonctionEnum.ELEVE)

        then: "le role est ajoute a la liste des roles associes a la fonction"
        mapping.getRolesForFonction(FonctionEnum.ELEVE).contains(RoleApplicatif.ENSEIGNANT)

    }

    def "l'ajout ou suppression d'association non modifiable fonction role a un mapping initialise echoue"() {

        given: "un mapping initialise"
        MappingFonctionRole mapping = new MappingFonctionRole(aMap)

        when: "un role est associe a une fonction sur association non modifiable"
        mapping.addRoleForFonction(RoleApplicatif.ENSEIGNANT, FonctionEnum.PERS_REL_ELEVE)

        then: "une exception de type precondition est levee"
        thrown(PreConditionException)

        when: "un role est supprime a une fonction sur association non modifiable"
        mapping.deleteRoleForFonction(RoleApplicatif.PARENT, FonctionEnum.PERS_REL_ELEVE)

        then: "une exception de type precondition est levee"
        thrown(PreConditionException)

    }

    def "suppression d'associations fonction role sur un mapping vide"() {

        given: "un nouveau mapping vierge"
        MappingFonctionRole mapping = new MappingFonctionRole()

        when: "tentative de supprimer une association"
        mapping.deleteRoleForFonction(RoleApplicatif.ENSEIGNANT, FonctionEnum.ENS)

        then: "il ne se passe rien, le mapping est vide"
        mapping.isEmpty()

    }

    def "suppression d'associations fonction role sur un mapping non vide"() {

        given: "un mapping contenant des associations"
        MappingFonctionRole mapping = new MappingFonctionRole()
        mapping.addRoleForFonction(RoleApplicatif.ENSEIGNANT, FonctionEnum.ENS)
        mapping.addRoleForFonction(RoleApplicatif.ELEVE, FonctionEnum.ENS)
        mapping.addRoleForFonction(RoleApplicatif.ENSEIGNANT, FonctionEnum.ELEVE)

        when: "tentative de supprimer une association"
        mapping.deleteRoleForFonction(RoleApplicatif.ENSEIGNANT, FonctionEnum.ENS)

        then: "le mapping est modifie en consequence"
        !mapping.isEmpty()
        mapping.getRolesForFonction(FonctionEnum.ENS).size() == 1
        !mapping.getRolesForFonction(FonctionEnum.ENS).contains(RoleApplicatif.ENSEIGNANT)

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
        aMap                                                                                                                                  | _
        ["${FonctionEnum.ENS.name()}": ["${RoleApplicatif.ENSEIGNANT.name()}": [:]], "bad_key": ["${RoleApplicatif.ENSEIGNANT.name()}": [:]]] | _
        ["${FonctionEnum.ENS.name()}": "bad_value", "${FonctionEnum.ELEVE.name()}": ["${RoleApplicatif.ENSEIGNANT.name()}": [:]]]             | _

    }

    @Unroll
    def "creation d'un mapping a partir d'un Json valide"() {

        given: "un json valide"
        def json = '{"ENS":{"ENSEIGNANT":{"associe":true,"modifiable":false},"ELEVE":{"associe":true,"modifiable":true}},' +
                '"ELEVE":{"ENSEIGNANT":{"associe":false,"modifiable":true},"ELEVE":{"associe":true,"modifiable":false}}}'


        when: "creation d'un mapping a partir de json"
        MappingFonctionRole mapping = new MappingFonctionRole(json)

        then: "le mapping est initialisé correctement"
        noExceptionThrown()
        mapping != null
        mapping.getRolesForFonction(FonctionEnum.ENS).size() == 2
        mapping.getRolesForFonction(FonctionEnum.ENS).containsAll([RoleApplicatif.ENSEIGNANT, RoleApplicatif.ELEVE])
        mapping.getRolesForFonction(FonctionEnum.ELEVE).size() == 1
        mapping.getRolesForFonction(FonctionEnum.ENS).contains(RoleApplicatif.ELEVE)

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
        json                                                                                                        | _
        '{"bad_key":{"ENSEIGNANT":{"associe":true,"modifiable":false},"ELEVE":{"associe":true,"modifiable":true}}}' | _
        '{"ELEVE":"bad value"}'                                                                                     | _

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
        aMap                                                                                                            | jsonAttendu
        null                                                                                                            | '{}'
        [:]                                                                                                             | '{}'
        ["ENS": ["ENSEIGNANT": ["associe": true, "modifiable": false], "ELEVE": ["associe": true, "modifiable": true]]] | '{"ENS":{"ENSEIGNANT":{"associe":true,"modifiable":false},"ELEVE":{"associe":true,"modifiable":true}}}'

    }

    @Unroll
    def "recuperation des caracteristiques d'une association fonction #fonction role #role"(role, fonction, associe, modifiable) {

        given: "un mapping initialise"
        MappingFonctionRole mapping = new MappingFonctionRole(aMap)

        when: "une associassion est recuperee"
        AssociationFonctionRole ass = mapping.hasRoleForFonction(role, fonction)

        then: "l'association est conforme"
        ass.associe == associe
        ass.modifiable == modifiable

        where:
        role                          | fonction           | associe | modifiable
        RoleApplicatif.ENSEIGNANT     | FonctionEnum.ENS   | true    | false
        RoleApplicatif.ENSEIGNANT     | FonctionEnum.ELEVE | false   | true
        RoleApplicatif.ELEVE          | FonctionEnum.ELEVE | true    | true
        RoleApplicatif.ELEVE          | FonctionEnum.ENS   | true    | true
        RoleApplicatif.ADMINISTRATEUR | FonctionEnum.DIR   | false   | true

    }

    def "reset d'un mapping"() {

        given:"un mapping initialise"
        MappingFonctionRole mapping = new MappingFonctionRole(aMap)

        when: "un reset est execute sur le mapping"
        mapping.resetOnRoleEnseignantAndEleve()

        then: "toutes les correspondances non modifiable sont laissées intactes, les autres sont positionnées à non assiciées"
        mapping.getRolesForFonction(FonctionEnum.ENS).size() == 1
        mapping.getRolesForFonction(FonctionEnum.ELEVE).size() == 0
        mapping.getRolesForFonction(FonctionEnum.PERS_REL_ELEVE).size() == 1

    }
}
