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
    Integer codeSupportNotification = SupportNotification.NO_SUPPORT.ordinal()

    Date lastUpdated

    static constraints = {
        codeSupportNotification inList: SupportNotification.values()*.ordinal(), validator: { val, obj ->
            return (val != 0 && (obj.notificationOnCreationSeance || obj.notificationOnPublicationResultats) ||
                    (val == 0 && !obj.notificationOnCreationSeance && !obj.notificationOnPublicationResultats))
        }
    }

    static mapping = {
        table('td.preference_personne')
        id(column: 'id', generator: 'sequence', params: [sequence: 'td.preference_personne_id_seq'])
        cache(true)
    }

}

enum SupportNotification {
    NO_SUPPORT,
    E_MAIL,
    SMS,
    E_MAIL_AND_SMS
}

