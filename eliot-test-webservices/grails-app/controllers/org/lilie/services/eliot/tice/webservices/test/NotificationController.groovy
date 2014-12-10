package org.lilie.services.eliot.tice.webservices.test

import groovy.json.JsonSlurper
import org.codehaus.groovy.runtime.powerassert.PowerAssertionError

class NotificationController {


    static scope = "singleton"

    def creerNotification() {
        String notification = params.notification
        String resp = '''{"success":true}'''
        if (!notificationisValide(notification)) {
            resp = '''{"success":false,"message":"error_notification"}'''

        }
        render(text: resp, contentType: "application/json", encoding: "UTF-8")
    }


    private boolean notificationisValide(String notificationAsString) {
        boolean res = true
        def jsonSlurper = new JsonSlurper()
        Map notification
        try {
            notification = jsonSlurper.parseText(notificationAsString)
            assert notification.etablissementIdExterne != null
            assert notification.demandeurIdExterne != null
            assert notification.message != null
            assert notification.destinatairesIdExterne.size() > 0
            assert (notification.supports.contains('EMAIL') || notification.supports.contains('SMS'))
        } catch (IllegalArgumentException iae) {
            log.error(iae.message)
            res = false
        } catch (PowerAssertionError pae) {
            log.error(pae.message)
            res = false
        }
        res
    }
}
