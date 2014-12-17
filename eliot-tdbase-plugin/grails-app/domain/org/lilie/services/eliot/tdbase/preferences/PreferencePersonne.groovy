package org.lilie.services.eliot.tdbase.preferences

import org.lilie.services.eliot.tdbase.notification.NotificationSupport
import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * Classe qui représente les préférences d'un établissement : concerne
 * notamment le mapping fonction/role applicatif au sein de TD Base
 */
class PreferencePersonne {

    Personne personne

    Boolean notificationOnCreationSeance = false
    Boolean notificationOnPublicationResultats = false
    Integer codeSupportNotification = NotificationSupport.NO_SUPPORT.ordinal()

    Date lastUpdated

    static constraints = {
        codeSupportNotification inList: NotificationSupport.values()*.ordinal(), validator: { val, obj ->
            if ((val != 0 && (!obj.notificationOnCreationSeance && !obj.notificationOnPublicationResultats) ||
                    (val == 0 && (obj.notificationOnCreationSeance || obj.notificationOnPublicationResultats)))) {
                return ['invalid.supportNonSelectionne']
            }
        }
    }

    static mapping = {
        table('td.preference_personne')
        id(column: 'id', generator: 'sequence', params: [sequence: 'td.preference_personne_id_seq'])
        cache(true)
    }

}


