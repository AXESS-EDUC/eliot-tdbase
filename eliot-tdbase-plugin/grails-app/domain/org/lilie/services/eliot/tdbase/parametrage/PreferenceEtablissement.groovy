package org.lilie.services.eliot.tdbase.parametrage

import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement


/**
 * Classe qui représente les préférences d'un établissement : concerne
 * notamment le mapping fonction/role applicatif au sein de TD Base
 */
class PreferenceEtablissement {

    Etablissement etablissement
    Personne lastUpdateAuteur

    String mappingFonctionRole
    Date lastUpdated


    static constraints = {
        lastUpdateAuteur nullable: true
    }

    static mapping = {
        table('td.preference_etablissement')
        id(column: 'id', generator: 'sequence', params: [sequence: 'td.preference_etablissement_id_seq'])
        cache(true)
    }
}

