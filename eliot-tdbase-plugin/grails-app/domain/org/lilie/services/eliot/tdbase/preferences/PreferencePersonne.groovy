package org.lilie.services.eliot.tdbase.preferences

import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement


/**
 * Classe qui représente les préférences d'un établissement : concerne
 * notamment le mapping fonction/role applicatif au sein de TD Base
 */
class PreferencePersonne {

    Personne personne

    Boolean notificationOnCreationSeance = false
    Boolean notificationOnPublicationResultats = false
    Integer codeSupportNotification

    Date lastUpdated

    static constraints = {
        codeSupportNotification nullable: true, inList: SupportNotification.values()*.code, validator: { val, obj ->
            return (val != null && (obj.notificationOnCreationSeance || obj.notificationOnPublicationResultats) ||
                    (val == null && !obj.notificationOnCreationSeance && !obj.notificationOnPublicationResultats))
        }
    }

    static mapping = {
        table('td.preference_personne')
        id(column: 'id', generator: 'sequence', params: [sequence: 'td.preference_personne_id_seq'])
        cache(true)
    }

}

enum SupportNotification {
    E_MAIL(1),
    SMS(2),
    E_MAIL_AND_SMS(3)

    int code

    SupportNotification(int code) {
        this.code = code
    }

}

