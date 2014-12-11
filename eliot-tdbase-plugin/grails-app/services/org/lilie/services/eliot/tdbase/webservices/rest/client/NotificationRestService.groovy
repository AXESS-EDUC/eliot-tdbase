package org.lilie.services.eliot.tdbase.webservices.rest.client

import groovy.json.JsonOutput
import org.lilie.services.eliot.tdbase.notification.Notification
import org.lilie.services.eliot.tice.webservices.rest.client.RestClient

/**
 *
 */
class NotificationRestService {

    static transactional = false
    RestClient restClientForNotification

    /**
     * Récupère les fonctions admnistrables d'un établissement
     * @param etablissementId
     */
    def postNotification(Notification notification) {
        restClientForNotification.invokeOperation('postNotification',
                null,
                null,
                [
                        etablissementIdExterne: notification.etablissementIdExerne,
                        demandeurIdExterne    : notification.demandeurIdexterne,
                        titre: notification.titre,
                        message: notification.message,
                        destinatairesIdExterne:JsonOutput.toJson(notification.destinatairesIdExterne),
                        supports:JsonOutput.toJson(notification.supports)
                ])
    }
}
