package org.lilie.services.eliot.tdbase.preferences

import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement


/**
 * Classe qui représente les préférences d'un établissement : concerne
 * notamment le mapping fonction/role applicatif au sein de TD Base
 */
class PreferencePersonne {

    Personne personne

    Boolean notificationOnCreationSeance = true
    Boolean notificationOnPublicationResultats = true

    Date lastUpdated

    static constraints = {

    }

    static mapping = {
        table('td.preference_personne')
        id(column: 'id', generator: 'sequence', params: [sequence: 'td.preference_personne_id_seq'])
        cache(true)
    }
}

