package org.lilie.services.eliot.tdbase.notification

import grails.plugin.spock.IntegrationSpec
import groovy.sql.GroovyRowResult
import org.lilie.services.eliot.tdbase.preferences.PreferencePersonne
import org.lilie.services.eliot.tdbase.preferences.PreferencePersonneService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.utils.BootstrapService

/**
 * Created by franck on 04/11/2014.
 */
class NotificationSeanceDaoServiceSpec extends IntegrationSpec {

    BootstrapService bootstrapService
    PreferencePersonneService preferencePersonneService
    NotificationSeanceDaoService notification
    def groovySql

    def setup() {
        bootstrapService
        bootstrapService.bootstrapJeuDeTestDevDemo()
        notification = new NotificationSeanceDaoService(groovySql: groovySql)
        PreferencePersonne preferencePersonne = preferencePersonneService.getPreferenceForPersonne(bootstrapService.eleve1)
        preferencePersonne.notificationOnPublicationResultats = true
        preferencePersonne.codeSupportNotification = NotificationSupport.SMS.ordinal()
        preferencePersonne.save(flush: true, failOnError: true)
        PreferencePersonne preferencePersonne2 = preferencePersonneService.getPreferenceForPersonne(bootstrapService.eleve2)
        preferencePersonne2.notificationOnPublicationResultats = true
        preferencePersonne2.notificationOnCreationSeance = true
        preferencePersonne2.codeSupportNotification = NotificationSupport.E_MAIL_AND_SMS.ordinal()
        preferencePersonne2.save(flush: true, failOnError: true)
    }

    def "la recupération des personnes à notifier pour une structure enseignement"() {
        given: "une structure d'enseignement"
        def struct = bootstrapService.classe1ere

        when:"on récupère les personnes à notifier par sms pour la publication de resultats"
        def pers = notification.findAllPersonnesToNotifierForStructurEnseignementAndSupportAndEvenement(struct,
                NotificationSupport.SMS,NotificationSeanceDaoService.PUBLICATION_RESULTATS)

        then:"on récupère 2 personnes ayant une preference conforme"
        pers.size() == 2
        pers.each { GroovyRowResult row ->
            def personne = Personne.get(row.get('personne_id'))
            PreferencePersonne pref = PreferencePersonne.findByPersonne(personne)
            pref.notificationOnPublicationResultats
            pref.codeSupportNotification == NotificationSupport.SMS.ordinal() || pref.codeSupportNotification == NotificationSupport.E_MAIL_AND_SMS.ordinal()
            personne.autorite.identifiant == row.get('personne_id_externe')
        }

        when:"on récupère les personnes à notifier par sms pour la publication de resultats"
        pers = notification.findAllPersonnesToNotifierForStructurEnseignementAndSupportAndEvenement(struct,
                NotificationSupport.EMAIL,NotificationSeanceDaoService.CREATION_SEANCE)

        then:"on récupère 1 personne ayant une preference conforme"
        pers.size() == 1
        pers.each { GroovyRowResult row ->
            def personne = Personne.get(row.get('personne_id'))
            personne == bootstrapService.eleve2
            PreferencePersonne pref = PreferencePersonne.findByPersonne(personne)
            pref.notificationOnCreationSeance
            pref.codeSupportNotification == NotificationSupport.EMAIL.ordinal() || pref.codeSupportNotification == NotificationSupport.E_MAIL_AND_SMS.ordinal()
            personne.autorite.identifiant == row.get('personne_id_externe')
        }
    }

}
