package org.lilie.services.eliot.tdbase.securite

import org.lilie.services.eliot.tdbase.preferences.MappingFonctionRole
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissement
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissementService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.PorteurEnt
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService


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
            rolesApplicatifsAndPerimetreByRoleApplicatif.get(currentRoleApplicatif).etablissementList
    }
    String getEtablissementListDisplay() {
        etablissementList.nomAffichage.join(",")
    }


    RoleApplicatif currentRoleApplicatif

    Map<RoleApplicatif, PerimetreRoleApplicatif> rolesApplicatifsAndPerimetreByRoleApplicatif



    /**
     * Initialise l'objet Securite Session
     * @param personne
     */
    def initialiseSecuriteSessionForUtilisateur(Utilisateur utilisateur, PorteurEnt porteurEnt = null) {
        // todo : comment injecter le porteur ENt dans l'objet securitesession ???
        if (!personneId) {
            Personne.withTransaction {
                login = utilisateur.login
                // initialise personneId
                personneId = utilisateur.personneId
                // initialise la lsite d'établissement
                Personne personne = utilisateur.personne
                initialiseRolesAvecPerimetreForPersonne(personne)
                if (rolesApplicatifsAndPerimetreByRoleApplicatif.isEmpty()) {
                    // on test si c'est un super administrateur
                    inialiseRoleApplicatifForPersonneWithoutEtablissementForPorteurEnt(personne,porteurEnt)
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
     * Initialise le role applicatif d'une personne sans établissement
     * @param personne
     */
    def inialiseRoleApplicatifForPersonneWithoutEtablissementForPorteurEnt(Personne personne, PorteurEnt porteurEnt) {
        if (personne.id != personneId) {
            throw new BadPersonnSecuritySessionException()
        }
        if (profilScolariteService.personneEstAdministrateurCentralForPorteurEnt(personne, porteurEnt)) {
            currentRoleApplicatif = RoleApplicatif.SUPER_ADMINISTRATEUR
        } else {
            currentRoleApplicatif = null
        }
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
            onChangeEtablissement(personne,etabs.first())
        } else {
            currentPreferenceEtablissement = null
            currentEtablissement = null
        }


    }


    /**
     * Initialise les rôles avec perimetre pour une personne
     * @param personne la personne
     */
    def initialiseRolesAvecPerimetreForPersonne(Personne personne) {
        rolesApplicatifsAndPerimetreByRoleApplicatif =  new TreeMap<RoleApplicatif,PerimetreRoleApplicatif>()
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
                        perimetre.etablissementList.add(etablissement)
                    }
                }
            }
            updatePerimetreForEachPerimetreRoleApplicatif(etablissementsAndFonctionsByEtablissement.size())
            if (allFonctionsHavingRole.contains(FonctionEnum.ELEVE)) {
                defaultRoleApplicatif = RoleApplicatif.ELEVE
            } else if (allFonctionsHavingRole.contains(FonctionEnum.PERS_REL_ELEVE)) {
                defaultRoleApplicatif = RoleApplicatif.PARENT
            } else if (allFonctionsHavingRole.contains(FonctionEnum.DIR)) {
                defaultRoleApplicatif = RoleApplicatif.ADMINISTRATEUR
            } else if (allFonctionsHavingRole.contains(FonctionEnum.ENS)) {
                defaultRoleApplicatif = RoleApplicatif.ENSEIGNANT
            }else if (!defaultRoleApplicatif) {
                defaultRoleApplicatif = rolesApplicatifsAndPerimetreByRoleApplicatif.keySet().first()
            }
            onChangeRoleApplicatif(personne,defaultRoleApplicatif)
        }
    }

    private updatePerimetreForEachPerimetreRoleApplicatif(int etablissementCount) {
        rolesApplicatifsAndPerimetreByRoleApplicatif.values().each { perimetreRoleApplicatif ->
            if (perimetreRoleApplicatif.etablissementList.size() == etablissementCount) {
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
    SortedSet<Etablissement> etablissementList = new TreeSet<Etablissement>()

    String toString() {
        etablissementList.toString()
    }
}

enum PerimetreRoleApplicatifEnum {
    ENT,
    ALL_ETABLISSEMENTS,
    SEVERAL_ETABLISSEMENTS
}