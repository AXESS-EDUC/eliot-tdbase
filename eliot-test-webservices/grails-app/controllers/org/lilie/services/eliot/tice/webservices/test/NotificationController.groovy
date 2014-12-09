package org.lilie.services.eliot.tice.webservices.test

class NotificationController {


    static scope = "singleton"

    def creerNotification() {
        String notification = params.notification
        String resp = '''{"success":true}'''
        if (!notificationisValide()) {
            resp = '''{"success":false,"message":"error_notification"}'''

        }
        render(text: resp, contentType: "application/json", encoding: "UTF-8")
    }


    private boolean notificationisValide() {
        true
    }
}
