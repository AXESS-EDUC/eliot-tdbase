package org.lilie.services.eliot.tdbase.parametrage

import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import org.lilie.services.eliot.tdbase.RoleApplicatif
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.utils.contract.Contract

/**
 * Created by franck on 08/09/2014.
 */
class MappingFonctionRole {

    static MappingFonctionRole defaultMappingFonctionRole

    public static final String KEY_ASSOCIE = 'associe'
    public static final String KEY_MODIFIABLE = 'modifiable'

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
    List<RoleApplicatif> getRolesForFonction(FonctionEnum fonction) {
        def rolesAsMap = mapping.get(fonction.name())
        def roles = []
        if (rolesAsMap) {
            rolesAsMap.each { String key, value ->
                if (value.get(KEY_ASSOCIE) == true) {
                    roles << RoleApplicatif.valueOf(key)
                }
            }
        }
        roles
    }

    AssociationFonctionRole hasRoleForFonction(RoleApplicatif role, FonctionEnum fonction) {
        def res = new AssociationFonctionRole()
        def roleAsMap = mapping.get(fonction.name())?.get(role.name())
        if (roleAsMap) {
           res = new AssociationFonctionRole(roleAsMap)
        }
        res
    }

    /**
     * Ajoute une association fonction-role
     * @param role le role
     * @param fonction la fonction
     */
    def addRoleForFonction(RoleApplicatif role, FonctionEnum fonction) {
        Map rolesAsMap = mapping.get(fonction.name())
        if (rolesAsMap == null) {
            rolesAsMap = [:]
            mapping.put(fonction.name(), rolesAsMap)
        }
        Map roleAsMap = rolesAsMap.get(role.name())
        if (roleAsMap) {
            Contract.requires(roleAsMap.get(KEY_MODIFIABLE) == true)
            roleAsMap.put(KEY_ASSOCIE, true)
        } else {
            rolesAsMap.put(role.name(), [("$KEY_ASSOCIE".toString()):true,("$KEY_MODIFIABLE".toString()):true])
        }
    }

    /**
     * Supprime une association fonction role
     * @param role le role
     * @param fonction la fonction
     */
    def deleteRoleForFonction(RoleApplicatif role, FonctionEnum fonction) {
        Map rolesAsMap = mapping.get(fonction.name())
        if (rolesAsMap) {
            Map roleAsMap = rolesAsMap.get(role.name())
            if (roleAsMap) {
                Contract.requires(roleAsMap.get(KEY_MODIFIABLE) == true)
                roleAsMap.put(KEY_ASSOCIE,false)
            }
        }
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
            if (!(value instanceof Map)) {
                res = false
            } else {
                value.each { String innerKey, innerValue ->
                    if (!(innerKey in goodValues)) {
                        res = false
                    }
                }
            }
        }
        res
    }

}

class AssociationFonctionRole {
    boolean associe = false
    boolean modifiable = true
}