package org.lilie.services.eliot.tdbase.parametrage

import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import org.lilie.services.eliot.tdbase.RoleApplicatif
import org.lilie.services.eliot.tice.scolarite.Fonction
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.utils.contract.Contract

/**
 * Created by franck on 08/09/2014.
 */
class MappingFonctionRole {

    private Map mapping = [:]

    /**
     * Default constructeur
     */
    MappingFonctionRole() {}

    /**
     * Crée et initialise le mapping à partir d'une map
     * @param mapping le mapping d'initialisation
     */
    MappingFonctionRole(Map aMapping) {
        if (aMapping) {
            Contract.requires(allKeysAndValuesAreFonctionCodesAndRoleCodes(aMapping))
            this.mapping = aMapping
        }
    }

    /**
     * Crée et initialise un mapping à partir d'un chaine de caractere au format JSON
     * @param jsonString
     */
    MappingFonctionRole(String jsonString) {
        if (jsonString) {
            def slurper = new JsonSlurper()
            def aMapping = slurper.parseText(jsonString)
            if (aMapping) {
                Contract.requires(allKeysAndValuesAreFonctionCodesAndRoleCodes(aMapping))
                this.mapping = aMapping
            }
        }
    }

    /**
     * Récupère le mpping au format Json
     * @return la chaine de caractere Json correspondant au mapping
     */
    String toJsonString() {
        def builder = new JsonBuilder()
        builder.call(mapping)
        builder.toString()
    }

    /**
     * Récupère les rôles associés à une fonction
     * @param fonction la fonction
     * @return les rôles associés
     */
    List<RoleApplicatif> getRolesForFonction(Fonction fonction) {
        def rolesAsString = mapping.get(fonction.code) ?: []
        def roles = rolesAsString.collect { RoleApplicatif.valueOf(it) }
        roles
    }

    /**
     * Ajoute une association fonction-role
     * @param role le role
     * @param fonction la fonction
     */
    def addRoleForFonction(RoleApplicatif role, Fonction fonction) {
        List<String> rolesAsString = mapping.get(fonction.code) ?: []
        if (!rolesAsString.contains(role.name())) {
            rolesAsString << role.name()
        }
        mapping.put(fonction.code, rolesAsString)
    }

    /**
     * Supprime une association fonction role
     * @param role le role
     * @param fonction la fonction
     */
    def deleteRoleForFonction(RoleApplicatif role, Fonction fonction) {
        List<String> rolesAsString = mapping.get(fonction.code) ?: []
        if (rolesAsString.contains(role.name())) {
            rolesAsString.remove(role.name())
        }
        mapping.put(fonction.code, rolesAsString)
    }

    /**
     *
     * @return true si le mapping est vide false sinon
     */
    boolean isEmpty() {
        if (mapping.isEmpty()) {
            return true
        }
        def isEmpty = true
        mapping.each { key, value -> if (!value.isEmpty()) isEmpty = false }
        isEmpty
    }

    private static boolean allKeysAndValuesAreFonctionCodesAndRoleCodes(Map aMapping) {
        if (aMapping.isEmpty()) {
            return true
        }
        boolean res = true
        def goodKeys = (FonctionEnum.values())*.name()
        def goodValues = (RoleApplicatif.values())*.name()
        aMapping.each { String key, value ->
            if (!(key in goodKeys)) {
                res = false
            }
            if (!goodValues.containsAll(value)) {
                res = false
            }
        }
        res
    }

}
