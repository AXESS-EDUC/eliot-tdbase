package org.lilie.services.eliot.tice.webservices.test

import groovy.json.JsonException
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import org.codehaus.groovy.runtime.powerassert.PowerAssertionError

class NotificationController {


    static scope = "singleton"

    def creerNotification() {
        String notification = request.inputStream.text
        String resp = '''{"success":true}'''
        def message = messageToSend(notification)
        if (message != null) {
            message = JsonOutput.toJson(message)
            resp = "{\"success\":false,\"message\":$message}"

        }
        render(text: resp, contentType: "application/json", encoding: "UTF-8")
    }


    private String messageToSend(String notificationAsString) {
        def res = null
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
            res = iae.message
        } catch (PowerAssertionError pae) {
            log.error(pae.message)
            res = pae.message
        } catch (JsonException je) {
            log.error(je.message)
            res = je.message
        }
        res
    }
}
