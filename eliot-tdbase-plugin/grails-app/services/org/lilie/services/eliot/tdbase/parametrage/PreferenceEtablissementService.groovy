package org.lilie.services.eliot.tdbase.parametrage

import org.lilie.services.eliot.tdbase.PreferenceEtablissement
import org.lilie.services.eliot.tdbase.RoleApplicatif
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.utils.contract.ContractService

/**
 * Service de gestion des préférences établissement
 * @author Franck Silvestre
 */
class PreferenceEtablissementService {

    ContractService contractService

    /**
     * Récupère l'objet correspondant aux préférences d'un établissement
     * @param personne la personne effectuant la demande
     * @param role le role applicatif de la personne effectuant la demande
     * @param etablissement
     * @return l'objet correspondant aux préférences de l'établissement
     */
    PreferenceEtablissement getPreferenceForEtablissement(Personne personne,
                                                          Etablissement etablissement,
                                                          RoleApplicatif role = null) {

        PreferenceEtablissement pref = PreferenceEtablissement.findByEtablissement(etablissement)
        if (!pref && role == RoleApplicatif.ADMINISTRATEUR) {
            pref = new PreferenceEtablissement(etablissement: etablissement,
                    lastUpdateAuteur: personne,
                    mappingFonctionRole: "{}")
            pref.save(failOnError: true)
        }
        pref
    }
}
