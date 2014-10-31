package org.lilie.services.eliot.tdbase.preferences

import org.lilie.services.eliot.tice.utils.contract.PreConditionException
import spock.lang.Specification

/**
 * Created by franck on 31/10/2014.
 */
class PreferenceNotificationsSpec extends Specification {

    PreferenceNotifications preferenceNotifications

    def setup() {
        preferenceNotifications = new PreferenceNotifications()
    }

    def "la création d'une preferenceNotifications active les abonnements aux notifications"() {

        when: "on crée une nouvelle preferenceNotifications"
        preferenceNotifications = new PreferenceNotifications()

        then: "l'abonnement aux notifications lors de création de séance est activé"
        preferenceNotifications.notificationOnCreationSeance == true
        and: "l'abonnement aux notifications lors de la publication des résultat est activé"
        preferenceNotifications.notificationOnPublicationResultats == true
    }

    def "l'export en json d'une preferenceNotifications sérialise en json les propriétes de l'objet"() {
        given: "une preferenceNotification existante"
        preferenceNotifications

        when: "l'export en json est déclenché"
        def jsonPref = preferenceNotifications.toJsonString()

        then: "le json contient les deux propriétés de l'objet"
        jsonPref == '{"notificationOnCreationSeance":true,"notificationOnPublicationResultats":true}'
    }

    def "la création d'une preferenceNotifications à partir d'un Json valide initialise les abonnements conformément au json"() {
        given: "un json valide"
        def jsonPref = '{"notificationOnCreationSeance":true,"notificationOnPublicationResultats":false}'

        when: "une preferenceNotifications est crée à partir du Json"
        preferenceNotifications = new PreferenceNotifications(jsonPref)

        then: "les abonnements sont initialisés conformément au json"
        preferenceNotifications.notificationOnCreationSeance == true
        preferenceNotifications.notificationOnPublicationResultats == false
    }

    def "la création d'une preferenceNotifications à partir d'un Json non valide provoque une erreur"() {
        given: "un json non valide"
        jsonPref

        when: "une preferenceNotifications est crée à partir du Json"
        preferenceNotifications = new PreferenceNotifications(jsonPref)

        then: "une exception est levée"
        thrown(PreConditionException)

        where:
        jsonPref                                                                   | _
        ""                                                                         | _
        null                                                                       | _
        '{"notificationOnCreationSeance":true}'                                    | _
        '{"notificationOnCreationSeance " = icationOnPublicationResultats":false}' | _
    }


}
