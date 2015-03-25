package org.lilie.services.eliot.tdbase.notification

import groovy.sql.GroovyRowResult
import org.lilie.services.eliot.tdbase.ModaliteActivite
import org.lilie.services.eliot.tice.scolarite.ProprietesScolarite

/**
 * Created by franck on 04/11/2014.
 */
class NotificationSeanceDaoService {

    static final String PUBLICATION_RESULTATS = "publication_resultats"
    static final String CREATION_SEANCE = "creation_seance"

    def groovySql

    List<String> findAllEmailDestinatairesForPublicationResultats(ModaliteActivite modaliteActivite) {
        findAllPersonnesIdExterneToNotifierForGroupeScolariteAndSupportAndEvenement(
                modaliteActivite.groupeScolarite,
                NotificationSupport.EMAIL,
                PUBLICATION_RESULTATS
        )
    }

    List<String> findAllSmsDestinatairesForPublicationResultats(ModaliteActivite modaliteActivite) {
        findAllPersonnesIdExterneToNotifierForGroupeScolariteAndSupportAndEvenement(
                modaliteActivite.groupeScolarite,
                NotificationSupport.SMS,
                PUBLICATION_RESULTATS
        )
    }

    List<String> findAllEmailDestinatairesForCreationSeance(ModaliteActivite modaliteActivite) {
        findAllPersonnesIdExterneToNotifierForGroupeScolariteAndSupportAndEvenement(
                modaliteActivite.groupeScolarite,
                NotificationSupport.EMAIL,
                CREATION_SEANCE
        )
    }

    List<String> findAllSmsDestinatairesForCreationSeance(ModaliteActivite modaliteActivite) {
        findAllPersonnesIdExterneToNotifierForGroupeScolariteAndSupportAndEvenement(
                modaliteActivite.groupeScolarite,
                NotificationSupport.SMS,
                CREATION_SEANCE
        )
    }

    List<String> findAllPersonnesIdExterneToNotifierForGroupeScolariteAndSupportAndEvenement(
            ProprietesScolarite groupeScolarite,
            NotificationSupport supportNotification,
            String evenement) {
        def rows = findAllPersonnesToNotifierForGroupeScolariteAndSupportAndEvenement(
                groupeScolarite,
                supportNotification,
                evenement
        )
        def res = rows.collect { row -> row.get("personne_id_externe")}
        res
    }

    List<GroovyRowResult> findAllPersonnesToNotifierForGroupeScolariteAndSupportAndEvenement(
            ProprietesScolarite groupeScolarite,
            NotificationSupport supportNotification,
            String evenement) {
        def rows = null
        if (evenement == CREATION_SEANCE) {
            rows = groovySql.rows(
                    queryForCreationSeance(groupeScolarite, supportNotification)
            )
        } else if (evenement == PUBLICATION_RESULTATS) {
            rows = groovySql.rows(
                    queryForPublicationResultats(groupeScolarite, supportNotification)
            )
        }
        rows
    }

    List<ModaliteActivite> findAllSeancesWithPublicationResultatsToNotifie(int maxResult = 20) {
        def criteria = ModaliteActivite.createCriteria()
        Date now = new Date()
        int nbJoursPassesAutorisePourNotification = 5
        def res = criteria.list {
            isNull('dateNotificationPublicationResultats')
            between(
                    'datePublicationResultats',
                    now-nbJoursPassesAutorisePourNotification,
                    now
            )
            maxResults(maxResult)
        }
        res
    }

    List<ModaliteActivite> findAllSeancesWithInvitationToNotifie(int maxResult = 20) {
        def criteria = ModaliteActivite.createCriteria()
        Date now = new Date()
        def res = criteria.list {
            gt('dateDebut', now)
            eq('notifierMaintenant', true)
            isNull('dateNotificationOuvertureSeance')
            maxResults(maxResult)
        }
        res
    }

    List<ModaliteActivite> findAllSeancesWithRappelInvitationToNotifie(int maxResult = 20) {
        def criteria = ModaliteActivite.createCriteria()
        Date now = new Date()
        def res = criteria.list {
            gt('dateDebut', now)
            eq('notifierAvantOuverture',true)
            isNull('dateRappelNotificationOuvertureSeance')
            maxResults(maxResult)
        }
        res
    }

    // TODO A vérifier
    private def queryForPublicationResultats(ProprietesScolarite groupeScolarite,
                                             NotificationSupport supportNotification) {
        """select autorite.id_externe as personne_id_externe, personne.id as personne_id from ent.personne_propriete_scolarite as profil
    join td.preference_personne as preference on (profil.personne_id = preference.personne_id)
    join ent.propriete_scolarite as propScol on (profil.propriete_scolarite_id = propScol.id)
    join ent.personne as personne on (profil.personne_id = personne.id)
    join securite.autorite as autorite on (personne.autorite_id = autorite.id)
  where
    propScol.id = ${groupeScolarite.id} and
    profil.est_active = true and
    (preference.code_support_notification = ${supportNotification.ordinal()} or preference.code_support_notification = ${NotificationSupport.E_MAIL_AND_SMS.ordinal()}) and
    preference.notification_on_publication_resultats = true
    """
    }

    // TODO A vérifier
    private def queryForCreationSeance(ProprietesScolarite groupeScolarite,
                                       NotificationSupport supportNotification) {
        """select autorite.id_externe as personne_id_externe, personne.id as personne_id from ent.personne_propriete_scolarite as profil
    join td.preference_personne as preference on (profil.personne_id = preference.personne_id)
    join ent.propriete_scolarite as propScol on (profil.propriete_scolarite_id = propScol.id)
    join ent.personne as personne on (profil.personne_id = personne.id)
    join securite.autorite as autorite on (personne.autorite_id = autorite.id)
  where
    propScol.id = ${groupeScolarite.id} and
    profil.est_active = true and
    (preference.code_support_notification = ${supportNotification.ordinal()} or preference.code_support_notification = ${NotificationSupport.E_MAIL_AND_SMS.ordinal()}) and
    preference.notification_on_creation_seance = true
    """
    }


    
}
