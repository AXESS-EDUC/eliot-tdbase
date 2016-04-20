package org.lilie.services.eliot.tdbase.notification

import grails.plugin.spock.IntegrationSpec
import groovyx.net.http.ContentType
import groovyx.net.http.Method
import org.codehaus.groovy.grails.web.mapping.LinkGenerator
import org.lilie.services.eliot.tdbase.ModaliteActivite
import org.lilie.services.eliot.tdbase.ModaliteActiviteService
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.preferences.PreferencePersonne
import org.lilie.services.eliot.tdbase.preferences.PreferencePersonneService
import org.lilie.services.eliot.tdbase.webservices.rest.client.NotificationRestService
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeService
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
class NotificationInvitationNouvelleSeanceJobSpec extends IntegrationSpec {

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
    LinkGenerator grailsLinkGenerator
    GroupeService groupeService

    NotificationInvitationNouvelleSeanceJob notificationInvitationNouvelleSeanceJob
    Sujet sujet

    def setup() {
        bootstrapService
        bootstrapService.bootstrapJeuDeTestDevDemo()
        // preference personne eleve 1
        PreferencePersonne preferencePersonne = preferencePersonneService.getPreferenceForPersonne(bootstrapService.eleve1)
        preferencePersonne.notificationOnCreationSeance = true
        preferencePersonne.codeSupportNotification = NotificationSupport.EMAIL.ordinal()
        preferencePersonne.save(flush: true, failOnError: true)
        // le job
        notificationInvitationNouvelleSeanceJob = new NotificationInvitationNouvelleSeanceJob(
                notificationSeanceService: notificationSeanceService,
                notificationRestService: notificationRestService,
                notificationSeanceDaoService: notificationSeanceDaoService,
                messageSource: messageSource,
                grailsLinkGenerator: grailsLinkGenerator
        )
        // le sujet
        sujet = sujetService.createSujet(bootstrapService.enseignant1, "un sujet")
        // la mise en place de la doublure du web service
        setupWebService()

    }

    def cleanup() {
        setdownWebService()
    }


    def "l'execution du job d'invitation immediate"() {
        given: "une séance dont la date de debut est passee"
        Date now = new Date()
        ModaliteActivite seance1 = modaliteActiviteService.createModaliteActivite(
                [
                        sujet                   : sujet,
                        groupeScolarite         :
                                groupeService.findGroupeScolariteEleveForStructureEnseignement(
                                        bootstrapService.classe1ere
                                ),
                        dateDebut               : now - 1,
                        dateFin                 : now + 2,
                        datePublicationResultats: now + 3
                ],
                sujet.proprietaire
        )

        when: "le job est exécuté"
        notificationInvitationNouvelleSeanceJob.execute()

        then: "il ne se passe rien"
        seance1.dateNotificationOuvertureSeance == null

        when: "la seance n'est pas encore ouverte"
        seance1.dateDebut = now + 1
        seance1.save(flush: true)

        and: "le job est exécuté de nouveau"
        notificationInvitationNouvelleSeanceJob.execute()

        then: "la notification est envoyée"
        def dateNotif = seance1.dateNotificationOuvertureSeance
        dateNotif != null

        when: " le job est executé à nouveau"
        notificationInvitationNouvelleSeanceJob.execute()

        then: " la notification ne repart pas"
        seance1.dateNotificationOuvertureSeance == dateNotif

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
