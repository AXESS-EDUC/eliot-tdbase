package org.lilie.services.eliot.tdbase.notification

import grails.plugin.spock.IntegrationSpec
import groovy.sql.GroovyRowResult
import org.lilie.services.eliot.tdbase.ModaliteActivite
import org.lilie.services.eliot.tdbase.ModaliteActiviteService
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.preferences.PreferencePersonne
import org.lilie.services.eliot.tdbase.preferences.PreferencePersonneService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeService
import org.lilie.services.eliot.tice.utils.BootstrapService

/**
 * Created by franck on 04/11/2014.
 */
class NotificationSeanceDaoServiceSpec extends IntegrationSpec {

    BootstrapService bootstrapService
    PreferencePersonneService preferencePersonneService
    NotificationSeanceDaoService notificationSeanceDaoService
    SujetService sujetService
    ModaliteActiviteService modaliteActiviteService
    GroupeService groupeService

    def groovySql

    def setup() {
        bootstrapService
        bootstrapService.bootstrapJeuDeTestDevDemo()
        notificationSeanceDaoService = new NotificationSeanceDaoService(groovySql: groovySql)
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

        when: "on récupère les personnes à notifier par sms pour la publication de resultats"
        def pers = notificationSeanceDaoService.findAllPersonnesToNotifierForGroupeScolariteAndSupportAndEvenement(
                groupeService.findGroupeScolariteEleveForStructureEnseignement(struct),
                NotificationSupport.SMS,
                NotificationSeanceDaoService.PUBLICATION_RESULTATS
        )

        then: "on récupère 2 personnes ayant une preference conforme"
        pers.size() == 2
        pers.each { GroovyRowResult row ->
            def personne = Personne.get(row.get('personne_id'))
            PreferencePersonne pref = PreferencePersonne.findByPersonne(personne)
            pref.notificationOnPublicationResultats
            pref.codeSupportNotification == NotificationSupport.SMS.ordinal() || pref.codeSupportNotification == NotificationSupport.E_MAIL_AND_SMS.ordinal()
            personne.autorite.identifiant == row.get('personne_id_externe')
        }

        when: "on récupère les personnes id externe à notifier par sms pour la publication de resultats"
        def persIds = notificationSeanceDaoService.findAllPersonnesIdExterneToNotifierForGroupeScolariteAndSupportAndEvenement(
                groupeService.findGroupeScolariteEleveForStructureEnseignement(struct),
                NotificationSupport.SMS,
                NotificationSeanceDaoService.PUBLICATION_RESULTATS
        )

        then: "on récupère les 2 id externes des personnes"
        persIds.size() == 2
        persIds.contains(bootstrapService.eleve1.autorite.identifiant)
        persIds.contains(bootstrapService.eleve2.autorite.identifiant)

        when: "on récupère les personnes à notifier par sms pour la publication de resultats"
        pers = notificationSeanceDaoService.findAllPersonnesToNotifierForGroupeScolariteAndSupportAndEvenement(
                groupeService.findGroupeScolariteEleveForStructureEnseignement(struct),
                NotificationSupport.EMAIL,
                NotificationSeanceDaoService.CREATION_SEANCE
        )

        then: "on récupère 1 personne ayant une preference conforme"
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

    def "la recupération des séances avec publication de résultats à notifier"() {
        given: "un sujet"
        Sujet sujet = sujetService.createSujet(bootstrapService.enseignant1, "un sujet")

        and: "une séance dont la date de publication n'est pas encore passée"
        Date now = new Date()
        modaliteActiviteService.createModaliteActivite(
                [
                        sujet                   : sujet,
                        groupeScolarite         : groupeService.findGroupeScolariteEleveForStructureEnseignement(
                                bootstrapService.classe1ere
                        ),
                        dateDebut               : now - 10,
                        dateFin                 : now - 8,
                        datePublicationResultats: now + 1
                ],
                sujet.proprietaire
        )
        and: "une séance dont la date de publication est passée depuis 4 jours et qui n'a pas été encore notifiée"
        ModaliteActivite seance2 = modaliteActiviteService.createModaliteActivite(
                [sujet                   : sujet,
                 groupeScolarite         :
                         groupeService.findGroupeScolariteEleveForStructureEnseignement(
                                 bootstrapService.classeTerminale
                         ),
                 dateDebut               : now - 10,
                 dateFin                 : now - 8,
                 datePublicationResultats: now - 4],
                sujet.proprietaire
        )
        and: "une séance dont la date de publication est passée depuis 3 jours et qui déjà été notifiée"
        modaliteActiviteService.createModaliteActivite(
                [
                        sujet                               : sujet,
                        groupeScolarite                     :
                                groupeService.findGroupeScolariteEleveForStructureEnseignement(
                                        bootstrapService.classeTerminale
                                ),
                        dateDebut                           : now - 10,
                        dateFin                             : now - 8,
                        datePublicationResultats            : now - 4,
                        dateNotificationPublicationResultats: now - 3
                ],
                sujet.proprietaire
        )

        when: "la recherche des séances ayant des notifications de résultats a publier est déclenchée"
        def res = notificationSeanceDaoService.findAllSeancesWithPublicationResultatsToNotifie()

        then: "seule la séance devant faire l'objet de la notification est retournée"
        res.size() == 1
        def seance = res.last()
        seance.id == seance2.id
    }

    def "la recuperation des seances à notifier maintenant"() {
        given: "un sujet"
        Sujet sujet = sujetService.createSujet(bootstrapService.enseignant1, "un sujet")

        and: "une séance non encore ouvert à notifier"
        Date now = new Date()
        ModaliteActivite seance1 = modaliteActiviteService.createModaliteActivite(
                [
                        sujet                   : sujet,
                        groupeScolarite         :
                                groupeService.findGroupeScolariteEleveForStructureEnseignement(
                                        bootstrapService.classe1ere
                                ),
                        dateDebut               : now + 1,
                        dateFin                 : now + 2,
                        datePublicationResultats: now + 3
                ],
                sujet.proprietaire
        )
        and: "une séance fermée et donc à ne plsu notifier"
        modaliteActiviteService.createModaliteActivite(
                [
                        sujet                   : sujet,
                        groupeScolarite         :
                                groupeService.findGroupeScolariteEleveForStructureEnseignement(
                                        bootstrapService.classeTerminale
                                ),
                        dateDebut               : now - 10,
                        dateFin                 : now - 8,
                        datePublicationResultats: now - 4
                ],
                sujet.proprietaire
        )
        and: "une séance non encore ouverte mais deja notifiee"
        modaliteActiviteService.createModaliteActivite(
                [
                        sujet                               : sujet,
                        groupeScolarite                     :
                                groupeService.findGroupeScolariteEleveForStructureEnseignement(
                                        bootstrapService.classeTerminale
                                ),
                        dateDebut                           : now + 1,
                        dateFin                             : now + 2,
                        datePublicationResultats            : now + 3,
                        dateNotificationPublicationResultats: null,
                        dateNotificationOuvertureSeance     : now - 2
                ],
                sujet.proprietaire
        )

        when: "la recherche des séances à notifier maintenant"
        def res = notificationSeanceDaoService.findAllSeancesWithInvitationToNotifie()

        then: "seule la séance devant faire l'objet de la notification est retournée"
        res.size() == 1
        def seance = res.last()
        seance.id == seance1.id
    }

    def "la recuperation des seances à notifier de nouveau aka rappel"() {
        given: "un sujet"
        Sujet sujet = sujetService.createSujet(bootstrapService.enseignant1, "un sujet")

        and: "une séance non encore ouvert à notifier avec rappel"
        Date now = new Date()
        ModaliteActivite seance1 = modaliteActiviteService.createModaliteActivite(
                [
                        sujet                   : sujet,
                        groupeScolarite         :
                                groupeService.findGroupeScolariteEleveForStructureEnseignement(
                                        bootstrapService.classe1ere
                                ),
                        dateDebut               : now + 1,
                        dateFin                 : now + 2,
                        datePublicationResultats: now + 3,
                        notifierNJoursAvant     : 2,
                ],
                sujet.proprietaire
        )

        and: "une séance non encore ouvert à notifier avec rappel"
        ModaliteActivite seance1bis = modaliteActiviteService.createModaliteActivite(
                [sujet                          : sujet,
                 groupeScolarite                :
                         groupeService.findGroupeScolariteEleveForStructureEnseignement(
                                 bootstrapService.classe6eme
                         ),
                 dateDebut                      : now + 1,
                 dateFin                        : now + 2,
                 datePublicationResultats       : now + 3,
                 dateNotificationOuvertureSeance: now - 5,
                 notifierNJoursAvant            : 2,
                ],
                sujet.proprietaire
        )
        and: "une séance fermée et donc à ne plus notifier"
        modaliteActiviteService.createModaliteActivite(
                [
                        sujet                   : sujet,
                        groupeScolarite         :
                                groupeService.findGroupeScolariteEleveForStructureEnseignement(
                                        bootstrapService.classeTerminale
                                ),
                        dateDebut               : now - 10,
                        dateFin                 : now - 8,
                        datePublicationResultats: now - 4],
                sujet.proprietaire
        )
        and: "une séance non encore ouverte mais deja notifiee"
        modaliteActiviteService.createModaliteActivite(
                [
                        sujet                                : sujet,
                        groupeScolarite                      :
                                groupeService.findGroupeScolariteEleveForStructureEnseignement(
                                        bootstrapService.classeTerminale
                                ),
                        dateDebut                            : now + 1,
                        dateFin                              : now + 2,
                        datePublicationResultats             : now + 3,
                        dateNotificationPublicationResultats : null,
                        dateRappelNotificationOuvertureSeance: now - 1
                ],
                sujet.proprietaire
        )

        when: "la recherche des séances à notifier de nouveau est décenchée"
        def res = notificationSeanceDaoService.findAllSeancesWithRappelInvitationToNotifie()

        then: "seule la séance devant faire l'objet de la notification est retournée"
        res.size() == 2
        res.contains(seance1)
        res.contains(seance1bis)
    }

}
