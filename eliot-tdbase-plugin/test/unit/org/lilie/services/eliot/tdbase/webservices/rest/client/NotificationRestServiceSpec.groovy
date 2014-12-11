package org.lilie.services.eliot.tdbase.webservices.rest.client

import grails.test.mixin.TestFor
import groovyx.net.http.ContentType
import groovyx.net.http.Method
import org.lilie.services.eliot.tdbase.notification.Notification
import org.lilie.services.eliot.tdbase.notification.NotificationSupport
import org.lilie.services.eliot.tice.webservices.rest.client.GenericRestOperation
import org.lilie.services.eliot.tice.webservices.rest.client.RestClient
import org.lilie.services.eliot.tice.webservices.rest.client.RestOperation
import org.lilie.services.eliot.tice.webservices.rest.client.RestOperationDirectory
import org.vertx.groovy.core.Vertx
import org.vertx.groovy.core.http.HttpServerRequest
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.services.ServiceUnitTestMixin} for usage instructions
 */
@TestFor(ScolariteRestService)
class NotificationRestServiceSpec extends Specification {

    RestOperationDirectory restOperationDirectory = new RestOperationDirectory()
    def httpserver
    def port = 8796
    NotificationRestService notificationRestService

    void setup() {
        def vertx = Vertx.newVertx()
        httpserver = vertx.createHttpServer()
        httpserver.requestHandler { HttpServerRequest req ->
            def rep = req.response
            req.bodyHandler { body ->
                rep.putHeader("Content-Type", "application/json").end(body)
            }
        }.listen(port)
        RestOperation restOperation = new GenericRestOperation(contentType: ContentType.JSON,
                description: "cree notification",
                operationName: "creeNotification",
                method: Method.POST,
                requestBodyTemplate: '''
                                                    {
                                                        "etablissementIdExterne": "$etablissementIdExterne",
                                                        "demandeurIdExterne": "$demandeurIdExterne",
                                                        "titre": "$titre",
                                                        "message": "$message",
                                                        "destinatairesIdExterne": $destinatairesIdExterne,
                                                        "supports": $supports
                                                    }
                                                    ''',
                responseContentStructure: "[success:true/false, message:message]",
                urlServer: "http://localhost:$port",
                uriTemplate: '/eliot-test-webservices/echanges/v2/notifications')
        restOperationDirectory.addOperation(restOperation)
        notificationRestService = new NotificationRestService(restClientForNotification: new RestClient(restOperationDirectory: restOperationDirectory))
    }

    void cleanup() {
        httpserver.close()
    }


    void testRestClientInvokeOperation() {
        given: "une notification"
        def notification = new Notification(
                etablissementIdExerne: "etab",
                demandeurIdexterne: "demandeur",
                titre: "titre",
                message: "message",
                destinatairesIdExterne: ["dest1","dest2"],
                supports: [NotificationSupport.EMAIL]
        )

        when:"on déclenche la création de la notification"
        Map res = notificationRestService.creeNotification(notification)

        then: "on verifie que la requête a été envoyé avec le json ad-hoc"
        res.size() == 6
        res.get('etablissementIdExterne') == 'etab'
        res.get('destinatairesIdExterne').size() == 2
    }

}


