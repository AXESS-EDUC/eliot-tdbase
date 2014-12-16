package org.lilie.services.eliot.tdbase.notification

import grails.plugin.spock.IntegrationSpec
import groovyx.net.http.ContentType
import groovyx.net.http.Method
import org.lilie.services.eliot.tdbase.ModaliteActivite
import org.lilie.services.eliot.tdbase.ModaliteActiviteService
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.preferences.PreferencePersonne
import org.lilie.services.eliot.tdbase.preferences.PreferencePersonneService
import org.lilie.services.eliot.tdbase.webservices.rest.client.NotificationRestService
import org.lilie.services.eliot.tice.utils.BootstrapService
import org.lilie.services.eliot.tice.webservices.rest.client.GenericRestOperation
import org.lilie.services.eliot.tice.webservices.rest.client.RestClient
import org.lilie.services.eliot.tice.webservices.rest.client.RestOperation
import org.lilie.services.eliot.tice.webservices.rest.client.RestOperationDirectory
import org.vertx.groovy.core.Vertx
import org.vertx.groovy.core.http.HttpServerRequest

/**
 * Created by franck on 04/11/2014.
 */
class NotificationPublicationResultatsSeanceJobSpec extends IntegrationSpec {

    BootstrapService bootstrapService
    PreferencePersonneService preferencePersonneService
    NotificationSeanceService notificationSeanceService
    NotificationSeanceDaoService notificationSeanceDaoService
    NotificationRestService notificationRestService
    RestOperationDirectory restOperationDirectory = new RestOperationDirectory()
    def httpserver
    def port = 8796
    SujetService sujetService
    ModaliteActiviteService modaliteActiviteService
    def messageSource

    NotificationPublicationResultatsSeanceJob notificationPublicationResultatsSeanceJob
    Sujet sujet

    def setup() {
        bootstrapService
        bootstrapService.bootstrapJeuDeTestDevDemo()
        // preference personne eleve 1
        PreferencePersonne preferencePersonne = preferencePersonneService.getPreferenceForPersonne(bootstrapService.eleve1)
        preferencePersonne.notificationOnPublicationResultats = true
        preferencePersonne.codeSupportNotification = NotificationSupport.EMAIL.ordinal()
        preferencePersonne.save(flush: true, failOnError: true)
        // le job
        notificationPublicationResultatsSeanceJob = new NotificationPublicationResultatsSeanceJob(
                notificationSeanceService: notificationSeanceService,
                notificationRestService: notificationRestService,
                notificationSeanceDaoService: notificationSeanceDaoService,
                messageSource: messageSource
        )
        // le sujet
        sujet = sujetService.createSujet(bootstrapService.enseignant1,"un sujet")
        // la mise en place de la doublure du web service
        setupWebService()

    }

    def cleanup() {
        setdownWebService()
    }



    def "l'execution du job de publication ne fait rien si aucune séance ayant publier ses résultats n'existe"() {
        given:"une séance dont la date de publication n'est pas encore passée"
        Date now = new Date()
        ModaliteActivite seance1 = modaliteActiviteService.createModaliteActivite(
                [sujet: sujet,
                 structureEnseignement: bootstrapService.classe1ere,
                        dateDebut: now-10,
                        dateFin: now-8,
                        datePublicationResultats: now+1
                ],
                sujet.proprietaire
        )

        when: "le job est exécuté"
        notificationPublicationResultatsSeanceJob.execute()

        then:"il ne se passe rien"
        seance1.dateNotificationPublicationResultats == null

        when:"la publication des résultat est passée"
        seance1.datePublicationResultats = now - 1
        seance1.save()

        and: "le job est exécuté de nouveau"
        notificationPublicationResultatsSeanceJob.execute()

        then: "la notification est envoyée"
        def dateNotif = seance1.dateNotificationPublicationResultats
        dateNotif != null

        when: " le job est executé à nouveau"
        notificationPublicationResultatsSeanceJob.execute()

        then: " la notification ne repart pas"
        seance1.dateNotificationPublicationResultats == dateNotif

    }


    private setupWebService() {
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
                operationName: "postNotification",
                method: Method.POST,
                requestBodyTemplate: '''
                                                    {
                                                        "etablissementIdExterne": "$etablissementIdExterne",
                                                        "demandeurIdExterne": "$demandeurIdExterne",
                                                        "titre": $titre,
                                                        "message": $message,
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

    private setdownWebService() {
        httpserver.close()
    }
}
