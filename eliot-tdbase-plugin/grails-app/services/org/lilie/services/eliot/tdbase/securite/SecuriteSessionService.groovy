package org.lilie.services.eliot.tdbase.securite

import org.lilie.services.eliot.tdbase.RoleApplicatif
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissement
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissementService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService

class SecuriteSessionService {

    static scope = "session"
    static proxy = true

    ProfilScolariteService profilScolariteService
    PreferenceEtablissementService preferenceEtablissementServiceProxy

    Long personneId
    Etablissement currentEtablissement
    List<Etablissement> etablissementList
    RoleApplicatif currentRoleApplicatif
    List<RoleApplicatif> roleApplicatifList

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
        // mise à jour de la liste des rôles applicatifs
        initialiseRoleApplicatifListForCurrentEtablissement(Personne.get(personneId))
        // mise à jour du current role
        currentRoleApplicatif = roleApplicatifList?.first()
    }

    /**
     * Initialise la liste des rôles applicatifs pour le currentEtablissement
     * @param personne la personne authentifiée
     */
    private initialiseRoleApplicatifListForCurrentEtablissement(Personne personne) {
        roleApplicatifList = [] // TODO : use a set to not have several times the same role
        if (currentEtablissement) {
            def fonctions = profilScolariteService.findFonctionsForPersonneAndEtablissement(personne, currentEtablissement)
            PreferenceEtablissement pref = preferenceEtablissementServiceProxy.getPreferenceForEtablissement(currentEtablissement)
            def mapping = pref.mappingFonctionRoleAsMap()
            fonctions.each {
                roleApplicatifList.addAll(mapping.getRolesForFonction(it))
            }
        }
    }

}
