package org.lilie.services.eliot.tdbase.preferences

import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.utils.contract.Contract

class PreferencePersonneService {

    /**
     * Met à jour une préférence personne
     * @param preferencePersonne la préférence personne
     * @param personne la personne déclenchant la mise à jour
     * @return la préférence personne mise à jour ou avec des erreurs
     */
    PreferencePersonne updatePreferencePersonne(PreferencePersonne preferencePersonne, Personne personne) {
        Contract.requires(preferencePersonne && preferencePersonne.personne == personne,"bad_personne_ : ${personne} for_preference_personne : ${preferencePersonne.personne}")
        preferencePersonne.save()
        preferencePersonne
    }

    /**
     * Récupère la préférence personne d'une personne
     * @param personne la personne
     * @return la préférence personne
     */
    PreferencePersonne getPreferenceForPersonne(Personne personne) {
        PreferencePersonne preferencePersonne = PreferencePersonne.findByPersonne(personne)
        if (!preferencePersonne) {
            preferencePersonne = createPreferenceForPersonne(personne)
        }
        preferencePersonne
    }

    /**
     * Crée une préférence personne pour une personne
     * @param personne la personne
     * @return la préférénce personne
     */
    PreferencePersonne createPreferenceForPersonne(Personne personne) {
        PreferencePersonne preferencePersonne = new PreferencePersonne(personne:personne)
        preferencePersonne.save()
        preferencePersonne
    }
}
