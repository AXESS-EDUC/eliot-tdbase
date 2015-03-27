package org.lilie.services.eliot.tdbase.preferences

import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import org.lilie.services.eliot.tdbase.securite.RoleApplicatif
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.utils.contract.PreConditionException

/**
 * Created by franck on 08/09/2014.
 *
 * Modifications apportées par John le 27/03/2015 :
 * Le format de stockage a été modifié pour ne stocker que les associations Role / Fonction.
 * Le fait de savoir si une association est modifiable ou non est maintenant géré par configuration applicative (et
 * plus par le paramétrage de chaque établissement).
 *
 * Un format simplifié JSON a été introduit. Celui-ci est dénommé "version 2".
 * Le parsing du format JSON initial a été conservé pour ne pas effectuer de reprise de donner.
 * Dès qu'un paramétrage établissement sera modifié, le nouveau paramétrage sera enregistré en version 2.
 *
 * @author Franck Silvestre
 * @author John Tranier
 */
class MappingFonctionRole {

    static MappingFonctionRole defaultMappingFonctionRole

    GestionnaireModificationLiaisonFonctionRole gestionnaireModificationLiaisonFonctionRole

    public static final String KEY_ASSOCIE = 'associe'
    private static final Long JSON_REPRESENTATION_VERSION = 2

    private Map<RoleApplicatif, RoleApplicatifBinding> mappingRole = [:]
    private Map<FonctionEnum, FonctionBinding> mappingFonction = [:]

    /**
     * Initialise ce mapping à partir d'une représentation JSON (version 1 ou 2)
     * @param jsonString
     * @return
     */
    MappingFonctionRole parseJsonRepresentation(String jsonString) {
        assert mappingRole.isEmpty()

        if (!jsonString) {
            return this
        }

        def slurper = new JsonSlurper()
        def representation = slurper.parseText(jsonString)
        if (!representation) {
            return this
        }

        if (!representation.version) {
            return parseJsonRepresentationVersion1((Map)representation)
        } else if (representation.version == JSON_REPRESENTATION_VERSION) {
            return parseJsonRepresentationVersion2((Map)representation)
        } else {
            throw new IllegalArgumentException(
                    "Version non supportée : ${representation.version}"
            )
        }
    }

    /**
     * Initialise ce mapping à partir d'une représentation JSON (version 1)
     * @param representation
     * @return
     */
    private MappingFonctionRole parseJsonRepresentationVersion1(Map representation) {
        representation.each { def fonctionCode, def roleMap ->
            assert (fonctionCode instanceof String)
            assert (roleMap instanceof Map)

            roleMap.each { def roleCode, Map association ->
                assert (roleCode instanceof String)
                assert(association instanceof Map)

                if(association[KEY_ASSOCIE]) {
                    addBinding(
                            RoleApplicatif.valueOf(roleCode),
                            FonctionEnum.valueOf(fonctionCode),
                            false
                    )
                }
            }
        }

        return this
    }

    /**
     * Initialise ce mapping à partir d'une représentation JSON (version 2)
     * @param representation
     * @return
     */
    private MappingFonctionRole parseJsonRepresentationVersion2(Map representation) {
        assert representation.version == JSON_REPRESENTATION_VERSION
        representation.data.each { String roleApplicatifCode, List<String> fonctionCodeList ->
            RoleApplicatif roleApplicatif = RoleApplicatif.valueOf(roleApplicatifCode)

            fonctionCodeList.each { String fonctionCode ->
                FonctionEnum fonctionEnum = FonctionEnum.valueOf(fonctionCode)
                addBinding(roleApplicatif, fonctionEnum, false)
            }
        }

        return this
    }

    // TODO Doc (<RoleApplicatif, List<FonctionEnum>>)
    /**
     * Initialise ce mapping à partir d'une représentation Map de la forme RoleApplicatif => List<FonctionEnum>)
     * Les clés & valeurs de la Map peuvent être typées par RoleApplicatif et FonctionEnum, ou par des String correspondant
     * au "name" de ces enums
     * @param representation
     * @return
     */
    MappingFonctionRole parseMapRepresentation(Map representation) {
        assert mappingRole.isEmpty()

        representation.each { def roleApplicatif, List fonctionEnumList ->
            fonctionEnumList.each { def fonctionEnum ->
                addBinding(
                        parseRoleApplicatif(roleApplicatif),
                        parseFonctionEnum(fonctionEnum),
                        false
                )
            }
        }

        return this
    }

    private RoleApplicatif parseRoleApplicatif(def role) {
        if(role instanceof String) {
            return RoleApplicatif.valueOf(role)
        }
        else if(role instanceof RoleApplicatif) {
            return role
        }
        else {
            throw new IllegalArgumentException(
                    "La classe du rôle n'est pas supportée : ${role.getClass()}"
            )
        }
    }

    private FonctionEnum parseFonctionEnum(def fonctionEnum) {
        if(fonctionEnum instanceof String) {
            return FonctionEnum.valueOf(fonctionEnum)
        }
        else if (fonctionEnum in FonctionEnum) {
            return fonctionEnum
        }
        else {
            throw new IllegalArgumentException(
                    "La classe de cette fonction n'est pas supportée : ${fonctionEnum.getClass()}"
            )
        }
    }

    /**
     * Associe un rôle applicatif à une fonction
     * @param roleApplicatif
     * @param fonctionEnum
     * @param checkModifiable Si false, on ne vérifie pas si la liaison est modifiable (à ne pas utiliser pour
     * enregistrer une modification utilisateur)
     */
    void addBinding(RoleApplicatif roleApplicatif,
                    FonctionEnum fonctionEnum,
                    boolean checkModifiable = true) {
        if(checkModifiable && !gestionnaireModificationLiaisonFonctionRole.isLiaisonModifiable(roleApplicatif, fonctionEnum)) {
            throw new PreConditionException("La liaison $roleApplicatif / $fonctionEnum n'est pas modifiable")
        }

        // Mise à jour mappingRole
        RoleApplicatifBinding roleApplicatifBinding = mappingRole[roleApplicatif]
        if (!roleApplicatifBinding) {
            roleApplicatifBinding = new RoleApplicatifBinding(roleApplicatif: roleApplicatif)
            mappingRole[roleApplicatif] = roleApplicatifBinding
        }
        roleApplicatifBinding.addFonction(fonctionEnum)

        // Mise à jour mappingFonction
        FonctionBinding fonctionBinding = mappingFonction[fonctionEnum]
        if (!fonctionBinding) {
            fonctionBinding = new FonctionBinding(fonctionEnum: fonctionEnum)
            mappingFonction[fonctionEnum] = fonctionBinding
        }
        fonctionBinding.addRoleApplicatif(roleApplicatif)
    }

    /**
     * Retire l'association entre un rôle applicatif à une fonction
     * @param roleApplicatif
     * @param fonctionEnum
     * @param checkModifiable Si false, on ne vérifie pas si la liaison est modifiable (à ne pas utiliser pour
     * enregistrer une modification utilisateur)
     */
    void removeBinding(RoleApplicatif roleApplicatif,
                       FonctionEnum fonctionEnum,
                       boolean checkModifiable = true) {
        if(checkModifiable && !gestionnaireModificationLiaisonFonctionRole.isLiaisonModifiable(roleApplicatif, fonctionEnum)) {
            throw new PreConditionException("La liaison $roleApplicatif / $fonctionEnum n'est pas modifiable")
        }

        // Mise à jour mappingRole
        RoleApplicatifBinding roleApplicatifBinding = mappingRole[roleApplicatif]
        if(!roleApplicatifBinding) {
            return // Cette liaison n'existe pas
        }
        roleApplicatifBinding.removeFonction(fonctionEnum)

        // Mise à jour mappingFonction
        FonctionBinding fonctionBinding = mappingFonction[fonctionEnum]
        fonctionBinding.removeRoleApplicatif(roleApplicatif)
    }

    /**
     * Récupère le mapping au format Json
     * @return la chaine de caractere Json correspondant au mapping
     */
    String toJsonString() {
        Map data = [:]
        Map representation = [
                version: JSON_REPRESENTATION_VERSION,
                data   : data
        ]

        mappingRole.each {
            RoleApplicatif roleApplicatif, RoleApplicatifBinding binding ->
            data[roleApplicatif.name()] = binding.associatedFonctionSet*.name()
        }

        def builder = new JsonBuilder()
        builder.call(representation)
        builder.toString()
    }

    /**
     * Récupère les rôles associés à une fonctionEnum
     * @param fonction la fonctionEnum
     * @return les rôles associés
     */
    List<RoleApplicatif> getRolesForFonction(FonctionEnum fonction) {
        FonctionBinding fonctionBinding = mappingFonction[fonction]
        if (!fonctionBinding) {
            return []
        }
        fonctionBinding.associatedRoleApplicatif.toList()
    }

    /**
     * Retourne la liste des fonctions qui sont associées à un rôle
     * @param role
     * @return
     */
    List<FonctionEnum> getFonctionEnumListForRole(RoleApplicatif role) {
        RoleApplicatifBinding binding = mappingRole[role]
        if (!binding) {
            return []
        }
        binding.associatedFonctionSet.toList()
    }

    AssociationFonctionRole getAssociationFonctionRole(RoleApplicatif role,
                                                       FonctionEnum fonctionEnum) {

        AssociationFonctionRole associationFonctionRole = new AssociationFonctionRole(
                role: role,
                fonction: fonctionEnum,
                associe: mappingFonction[fonctionEnum]?.isAssociatedTo(role) as boolean,
                modifiable: gestionnaireModificationLiaisonFonctionRole.isLiaisonModifiable(
                        role,
                        fonctionEnum
                )
        )

        return associationFonctionRole
    }

    /**
     *
     * @return true si le mapping est vide false sinon
     */
    boolean isEmpty() {
        mappingRole.isEmpty()
    }

    /**
     * Conserve les valeurs non modifiables et remet les autres valeurs à "non associe"
     */
    def resetOnRoleEnseignantAndEleve(GestionnaireModificationLiaisonFonctionRole gestionnaireModificationLiaisonFonctionRole) {

        [RoleApplicatif.ELEVE, RoleApplicatif.ENSEIGNANT].each { RoleApplicatif roleApplicatif ->
            List<FonctionEnum> fonctionEnumToRemove = []
            mappingRole[roleApplicatif].associatedFonctionSet.each { FonctionEnum fonctionEnum ->
                if(gestionnaireModificationLiaisonFonctionRole.isLiaisonModifiable(roleApplicatif, fonctionEnum)) {
                    fonctionEnumToRemove << fonctionEnum
                }
            }

            fonctionEnumToRemove.each {
                removeBinding(roleApplicatif, it, false)
            }
        }
    }
}

class AssociationFonctionRole {

    RoleApplicatif role
    FonctionEnum fonction
    boolean associe
    boolean modifiable
}