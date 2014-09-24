package org.lilie.services.eliot.tdbase.securite

import org.lilie.services.eliot.tdbase.RoleApplicatif
import org.lilie.services.eliot.tdbase.preferences.MappingFonctionRole
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissement
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissementService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService


class SecuriteSessionService {

    static scope = "session"
    static proxy = true
    static transactional = false

    ProfilScolariteService profilScolariteService
    PreferenceEtablissementService preferenceEtablissementService

    Long personneId
    Etablissement currentEtablissement
    PreferenceEtablissement currentPreferenceEtablissement
    List<Etablissement> etablissementList
    RoleApplicatif currentRoleApplicatif
    SortedSet<RoleApplicatif> roleApplicatifList

    /**
     * Initialise l'objet Securite Session
     * @param personne
     */
    def initialiseSecuriteSessionForUtilisateur(Utilisateur utilisateur) {
        if (!personneId) {
            // initialise personneId
            personneId = utilisateur.personneId
            // initialise la lsite d'établissement
            Personne personne = utilisateur.personne
            etablissementList = profilScolariteService.findEtablissementsForPersonne(personne) ?: []
            // initialise currentEtablissement (le premier de la liste) et les autres proprietes
            onChangeEtablissement(personne, etablissementList?.first())
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
        // mise à jour du current etablissement
        currentEtablissement = newCurrentEtablissement
        // mise à jour du current preference etablissement
        if (currentEtablissement != null) {
            currentPreferenceEtablissement = preferenceEtablissementService.getPreferenceForEtablissement(currentEtablissement)
        } else {
            currentPreferenceEtablissement = null
        }
        // mise à jour de la liste des rôles applicatifs
        initialiseRoleApplicatifListForCurrentEtablissement(personne)
        // mise à jour du current role
        currentRoleApplicatif = roleApplicatifList?.first()
    }

    /**
     * Initialise la liste des rôles applicatifs pour le currentEtablissement
     * @param personne la personne authentifiée
     */
    def initialiseRoleApplicatifListForCurrentEtablissement(Personne personne) {
        roleApplicatifList = new TreeSet<RoleApplicatif>()
        if (currentEtablissement != null) {
            def fonctions = profilScolariteService.findFonctionEnumsForPersonneAndEtablissement(personne, currentEtablissement)
            MappingFonctionRole mapping = currentPreferenceEtablissement.mappingFonctionRoleAsMap()
            fonctions.each { FonctionEnum fct ->
                roleApplicatifList.addAll(mapping.getRolesForFonction(fct))
            }
        }
    }

}
