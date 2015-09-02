package org.lilie.services.eliot.tdbase.securite

import org.lilie.services.eliot.tdbase.preferences.MappingFonctionRole
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissement
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissementService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.securite.CorrespondantDeploimentConfig
import org.lilie.services.eliot.tice.utils.contract.Contract


class SecuriteSessionService {

    static scope = "session"
    static proxy = true
    static transactional = false

    String login
    ProfilScolariteService profilScolariteService
    PreferenceEtablissementService preferenceEtablissementService

    Long personneId
    Etablissement currentEtablissement
    PreferenceEtablissement currentPreferenceEtablissement

    Map<Etablissement, Set<FonctionEnum>> etablissementsAndFonctionsByEtablissement
    RoleApplicatif defaultRoleApplicatif

    Set<Etablissement> getEtablissementList() {
        rolesApplicatifsAndPerimetreByRoleApplicatif.get(currentRoleApplicatif).etablissements
    }

    String getEtablissementListDisplay() {
        etablissementList.nomAffichage.join(",")
    }


    RoleApplicatif currentRoleApplicatif

    Map<RoleApplicatif, PerimetreRoleApplicatif> rolesApplicatifsAndPerimetreByRoleApplicatif

    /**
     * Initialise l'objet Securite Session
     * @param personne
     * @param roleApplicatif un role applicatif devant être utilisé si non null (provient du préfixe de login par exemple)
     * @param porteurEnt porteur ENT à prendre en compte si nécessaire
     */
    def initialiseSecuriteSessionForUtilisateur(Utilisateur utilisateur, RoleApplicatif roleApplicatif = null) {
        if (!personneId) {
            Personne.withTransaction {
                login = utilisateur.login
                // initialise personneId
                personneId = utilisateur.personneId
                // initialise la lsite d'établissement
                Personne personne = utilisateur.personne
                if (roleApplicatif) {
                   initialiseRolesAvecPerimetreForPersonne(personne, roleApplicatif)
                } else {
                    initialiseRolesAvecPerimetreForPersonne(personne)
                }
            }
        } else if (utilisateur.personneId != personneId) {
            throw new BadPersonnSecuritySessionException()
        }
    }

    /**
     * Met à jour l'objet Securite Session suite à un changement d'établissement
     * @param la personne déclenchant le changement d'établissement
     * @param newCurrentEtablissement le nouvel etablissement sélectionné
     */
    def onChangeEtablissement(Personne personne, Etablissement newCurrentEtablissement) {
        if (personne.id != personneId) {
            throw new BadPersonnSecuritySessionException()
        }
        if (newCurrentEtablissement == null || !etablissementList.contains(newCurrentEtablissement)) {
            throw new BadEtablissementSecuritySessionException()
        }
        // mise à jour du current etablissement
        currentEtablissement = newCurrentEtablissement
        // mise à jour du current preference etablissement
        currentPreferenceEtablissement = preferenceEtablissementService.getPreferenceForEtablissement(personne, currentEtablissement)

    }


    /**
     * Met à jour l'objet Securite Session suite à un changement de rôle applicatif
     * @param personne la personne déclenchant le changement
     * @param newRoleAppliatif le nouveau rôle applicatif
     */
    def onChangeRoleApplicatif(Personne personne, RoleApplicatif newRoleAppliatif) {
        if (personne.id != personneId) {
            throw new BadPersonnSecuritySessionException()
        }
        if (!rolesApplicatifsAndPerimetreByRoleApplicatif.keySet().contains(newRoleAppliatif)) {
            throw new BadRoleApplicatifSecuritySessionException()
        }
        currentRoleApplicatif = newRoleAppliatif

        def etabs = etablissementList
        if (etabs && !etabs.isEmpty()) {
            onChangeEtablissement(personne, etabs.first())
        } else {
            currentPreferenceEtablissement = null
            currentEtablissement = null
        }
    }

    /**
     * Initialise les rôles avec perimetre pour une personne
     * @param personne la personne
     */
    def initialiseRolesAvecPerimetreForPersonne(Personne personne, boolean updateCurrentRole = true) {
        rolesApplicatifsAndPerimetreByRoleApplicatif = new TreeMap<RoleApplicatif, PerimetreRoleApplicatif>()
        etablissementsAndFonctionsByEtablissement = profilScolariteService.findEtablissementsAndFonctionsForPersonne(personne)
        if (!etablissementsAndFonctionsByEtablissement.isEmpty()) {
            def allFonctionsHavingRole = new HashSet<FonctionEnum>()
            etablissementsAndFonctionsByEtablissement.each { etablissement, fcts ->
                MappingFonctionRole mapping = preferenceEtablissementService.getMappingFonctionRoleForEtablissement(personne, etablissement)
                fcts.each { FonctionEnum fct ->
                    def roles = mapping.getRolesForFonction(fct)
                    if (roles && !roles.isEmpty()) {
                        allFonctionsHavingRole.add(fct)
                    }
                    roles.each { role ->
                        def perimetre = rolesApplicatifsAndPerimetreByRoleApplicatif.get(role)
                        if (perimetre == null) {
                            perimetre = new PerimetreRoleApplicatif()
                            rolesApplicatifsAndPerimetreByRoleApplicatif.put(role, perimetre)
                        }
                        perimetre.etablissements.add(etablissement)
                    }
                }
            }

            if(allFonctionsHavingRole) {
                updatePerimetreForEachPerimetreRoleApplicatif(etablissementsAndFonctionsByEtablissement.size())
                defaultRoleApplicatif = updateDefaultRoleApplicatif(allFonctionsHavingRole, rolesApplicatifsAndPerimetreByRoleApplicatif)
            }
            else {
                handleUserWithNoRole()
            }

        } else {
            defaultRoleApplicatif = handleUserWithNoRole()
        }
        if (updateCurrentRole) {
            onChangeRoleApplicatif(personne, defaultRoleApplicatif)
        }
    }

    private RoleApplicatif handleUserWithNoRole() {
        rolesApplicatifsAndPerimetreByRoleApplicatif.put(RoleApplicatif.NO_ROLE,
                new PerimetreRoleApplicatif(perimetre: PerimetreRoleApplicatifEnum.NO_PERIMETRE))
        defaultRoleApplicatif = RoleApplicatif.NO_ROLE
        defaultRoleApplicatif
    }

    /**
     * Initialise les rôles avec perimetre pour une personne
     * @param personne la personne
     * @param roleApplicatif le rôle applicatif à parmétrer
     */
    def initialiseRolesAvecPerimetreForPersonne(Personne personne, RoleApplicatif roleApplicatif) {

        Contract.requires(roleApplicatif && (roleApplicatif == RoleApplicatif.ADMINISTRATEUR ||
                roleApplicatif == RoleApplicatif.SUPER_ADMINISTRATEUR),"requires_roleApplicatif_role_administrateur_or_role_super_administrateur")

        rolesApplicatifsAndPerimetreByRoleApplicatif = new TreeMap<RoleApplicatif, PerimetreRoleApplicatif>()

        if (roleApplicatif == RoleApplicatif.SUPER_ADMINISTRATEUR) {
            if (profilScolariteService.personneEstAdministrateurCentral(personne)) {
                rolesApplicatifsAndPerimetreByRoleApplicatif.put(roleApplicatif,
                        new PerimetreRoleApplicatif(perimetre: PerimetreRoleApplicatifEnum.ENT))
            }
        } else if (roleApplicatif == RoleApplicatif.ADMINISTRATEUR) {
            def etabs = profilScolariteService.findEtablissementsAdministresForPersonne(personne)
            if (!etabs.isEmpty()) {
                def perimetre = new PerimetreRoleApplicatif(perimetre: PerimetreRoleApplicatifEnum.ALL_ETABLISSEMENTS)
                perimetre.etablissements.addAll(etabs)
                rolesApplicatifsAndPerimetreByRoleApplicatif.put(roleApplicatif,perimetre)
            }
        }
        if (rolesApplicatifsAndPerimetreByRoleApplicatif.isEmpty()) {
            rolesApplicatifsAndPerimetreByRoleApplicatif.put(RoleApplicatif.NO_ROLE,
                    new PerimetreRoleApplicatif(perimetre: PerimetreRoleApplicatifEnum.NO_PERIMETRE))
            defaultRoleApplicatif = RoleApplicatif.NO_ROLE
            currentRoleApplicatif = RoleApplicatif.NO_ROLE
        } else {
            currentRoleApplicatif = roleApplicatif
            defaultRoleApplicatif = roleApplicatif
        }
    }

    /**
     * Initilaise la securité session pour l'utilisateur comme correspondant déploiement
     * @param utilisateur l'utilisateur reconnu comme correspondant déploiement
     */
    def initialiseSecuriteSessionForCorrespondantDeploiment(Utilisateur utilisateur) {
        Contract.requires(CorrespondantDeploimentConfig.externalIds.contains(utilisateur.autorite.identifiant),"utilisateur_non_CD")
        rolesApplicatifsAndPerimetreByRoleApplicatif = new TreeMap<RoleApplicatif, PerimetreRoleApplicatif>()
        rolesApplicatifsAndPerimetreByRoleApplicatif.put(RoleApplicatif.SUPER_ADMINISTRATEUR,
                new PerimetreRoleApplicatif(perimetre: PerimetreRoleApplicatifEnum.ENT))
        currentRoleApplicatif = RoleApplicatif.SUPER_ADMINISTRATEUR
        defaultRoleApplicatif = RoleApplicatif.SUPER_ADMINISTRATEUR

    }

    private RoleApplicatif updateDefaultRoleApplicatif(HashSet<FonctionEnum> allFonctionsHavingRole,
                                                       TreeMap<RoleApplicatif, PerimetreRoleApplicatif> rolesApplicatifsAndPerimetreByRoleApplicatif) {
        def defaultRoleApplicatif
        if (allFonctionsHavingRole.contains(FonctionEnum.ELEVE)) {
            defaultRoleApplicatif = RoleApplicatif.ELEVE
        } else if (allFonctionsHavingRole.contains(FonctionEnum.PERS_REL_ELEVE)) {
            defaultRoleApplicatif = RoleApplicatif.PARENT
        } else if (allFonctionsHavingRole.contains(FonctionEnum.DIR)) {
            defaultRoleApplicatif = RoleApplicatif.ADMINISTRATEUR
        } else if (allFonctionsHavingRole.contains(FonctionEnum.ENS)) {
            defaultRoleApplicatif = RoleApplicatif.ENSEIGNANT
        } else if (!defaultRoleApplicatif) {
            defaultRoleApplicatif = rolesApplicatifsAndPerimetreByRoleApplicatif.keySet().first()
        }
        defaultRoleApplicatif
    }

    private updatePerimetreForEachPerimetreRoleApplicatif(int etablissementCount) {
        rolesApplicatifsAndPerimetreByRoleApplicatif.values().each { perimetreRoleApplicatif ->
            if (perimetreRoleApplicatif.etablissements.size() == etablissementCount) {
                perimetreRoleApplicatif.perimetre = PerimetreRoleApplicatifEnum.ALL_ETABLISSEMENTS
            } else if (etablissementCount == 0) {
                perimetreRoleApplicatif.perimetre = PerimetreRoleApplicatifEnum.ENT
            } else {
                perimetreRoleApplicatif.perimetre = PerimetreRoleApplicatifEnum.SEVERAL_ETABLISSEMENTS
            }
        }
    }


}

class PerimetreRoleApplicatif {
    PerimetreRoleApplicatifEnum perimetre
    SortedSet<Etablissement> etablissements = new TreeSet<Etablissement>()

    String toString() {
        etablissements.toString()
    }
}

enum PerimetreRoleApplicatifEnum {
    ENT,
    ALL_ETABLISSEMENTS,
    SEVERAL_ETABLISSEMENTS,
    NO_PERIMETRE
}