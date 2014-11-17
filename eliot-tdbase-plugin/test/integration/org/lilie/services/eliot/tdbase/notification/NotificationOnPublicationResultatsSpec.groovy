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
class NotificationOnPublicationResultatsSpec extends IntegrationSpec {

    BootstrapService bootstrapService
    PreferencePersonneService preferencePersonneService
    NotificationOnPublicationResultats notificationOnPublicationResultats
    def groovySql

    def setup() {
        bootstrapService
        bootstrapService.bootstrapJeuDeTestDevDemo()
        notificationOnPublicationResultats = new NotificationOnPublicationResultats(groovySql: groovySql)
        PreferencePersonne preferencePersonne = preferencePersonneService.getPreferenceForPersonne(bootstrapService.eleve1)
        preferencePersonne.notificationOnPublicationResultats = true
        preferencePersonne.save(flush: true)
    }

    def "la recupération des personnes à notifier pour une structure enseignement"() {
        given: "une structure d'enseignement"
        def struct = bootstrapService.classe1ere

        when:"on récupère les personnes à notifier"
        def pers = notificationOnPublicationResultats.findAllPersonnesToNotifierForStructurEnseignement(struct)

        then:"on récupère les personnes ayant une preference conforme ou n'ayant pas de preferences"
        pers.each { GroovyRowResult row ->
            def personne = Personne.get(row.get('personne_id'))
            PreferencePersonne pref = PreferencePersonne.findByPersonne(personne)
            pref == null || pref.notificationOnPublicationResultats
        }
    }

}
