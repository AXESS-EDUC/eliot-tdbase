package org.lilie.services.eliot.tdbase.notification

import grails.plugin.spock.IntegrationSpec
import groovy.sql.GroovyRowResult
import org.lilie.services.eliot.tdbase.preferences.PreferencePersonne
import org.lilie.services.eliot.tdbase.preferences.PreferencePersonneService
import org.lilie.services.eliot.tdbase.preferences.SupportNotification
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.utils.BootstrapService

/**
 * Created by franck on 04/11/2014.
 */
class NotificationSeanceServiceSpec extends IntegrationSpec {

    BootstrapService bootstrapService
    PreferencePersonneService preferencePersonneService
    NotificationSeanceService notification
    def groovySql

    def setup() {
        bootstrapService
        bootstrapService.bootstrapJeuDeTestDevDemo()
        notification = new NotificationSeanceService(groovySql: groovySql)
        PreferencePersonne preferencePersonne = preferencePersonneService.getPreferenceForPersonne(bootstrapService.eleve1)
        preferencePersonne.notificationOnPublicationResultats = true
        preferencePersonne.codeSupportNotification = SupportNotification.SMS.ordinal()
        preferencePersonne.save(flush: true, failOnError: true)
        PreferencePersonne preferencePersonne2 = preferencePersonneService.getPreferenceForPersonne(bootstrapService.eleve2)
        preferencePersonne2.notificationOnPublicationResultats = true
        preferencePersonne2.notificationOnCreationSeance = true
        preferencePersonne2.codeSupportNotification = SupportNotification.E_MAIL_AND_SMS.ordinal()
        preferencePersonne2.save(flush: true, failOnError: true)
    }

    def "la recupération des personnes à notifier pour une structure enseignement"() {
        given: "une structure d'enseignement"
        def struct = bootstrapService.classe1ere

        when:"on récupère les personnes à notifier par sms pour la publication de resultats"
        def pers = notification.findAllPersonnesToNotifierForStructurEnseignementAndSupportAndEvenement(struct,
                SupportNotification.SMS,NotificationSeanceService.PUBLICATION_RESULTATS)

        then:"on récupère 2 personnes ayant une preference conforme"
        pers.size() == 2
        pers.each { GroovyRowResult row ->
            def personne = Personne.get(row.get('personne_id'))
            PreferencePersonne pref = PreferencePersonne.findByPersonne(personne)
            pref.notificationOnPublicationResultats
            pref.codeSupportNotification == SupportNotification.SMS.ordinal() || pref.codeSupportNotification == SupportNotification.E_MAIL_AND_SMS.ordinal()
            personne.autorite.identifiant == row.get('personne_id_externe')
        }

        when:"on récupère les personnes à notifier par sms pour la publication de resultats"
        pers = notification.findAllPersonnesToNotifierForStructurEnseignementAndSupportAndEvenement(struct,
                SupportNotification.E_MAIL,NotificationSeanceService.CREATION_SEANCE)

        then:"on récupère 1 personne ayant une preference conforme"
        pers.size() == 1
        pers.each { GroovyRowResult row ->
            def personne = Personne.get(row.get('personne_id'))
            personne == bootstrapService.eleve2
            PreferencePersonne pref = PreferencePersonne.findByPersonne(personne)
            pref.notificationOnCreationSeance
            pref.codeSupportNotification == SupportNotification.E_MAIL.ordinal() || pref.codeSupportNotification == SupportNotification.E_MAIL_AND_SMS.ordinal()
            personne.autorite.identifiant == row.get('personne_id_externe')
        }
    }

}
