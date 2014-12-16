package org.lilie.services.eliot.tdbase.notification

import org.lilie.services.eliot.tdbase.ModaliteActivite
import org.lilie.services.eliot.tdbase.webservices.rest.client.NotificationRestService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.springframework.transaction.annotation.Transactional

class NotificationSeanceService {

    static transactional = false

    public static final String UNKNOWN = "__INCONNU__"

    NotificationSeanceDaoService notificationSeanceDaoService
    NotificationRestService notificationRestService

    /**
     * Obtient la notification par email correspondant à la publication des résultats sur une séance donnée
     * @param demandeur le demandeur de la notification
     * @param titre le titre de la notification
     * @param message le message de la notification
     * @param modaliteActivite la séance
     * @return la notification créée ou null si il n'y a pas de destinataires
     */
    Notification getEmailNotificationOnPublicationResultatsForSeance(Personne demandeur, String titre, String message,
                                                                     ModaliteActivite modaliteActivite) {
        def destinatairesIdExt = notificationSeanceDaoService.findAllEmailDestinatairesForPublicationResultats(modaliteActivite)
        if (destinatairesIdExt.isEmpty()) {
            return null
        }
        def support = NotificationSupport.EMAIL
        def etabIdExt = modaliteActivite.findEtablissement().idExterne
        def demandIdExt = demandeur.idExterne
        Notification notification = new Notification(
                etablissementIdExerne: etabIdExt,
                demandeurIdexterne: demandIdExt,
                titre: titre,
                message:message,
                destinatairesIdExterne: destinatairesIdExt,
                supports: [support]
        )
        notification
    }

    /**
     * Obtient la notification par sms correspondant à la publication des résultats sur une séance donnée
     * @param demandeur le demandeur de la notification
     * @param titre le titre de la notification
     * @param message le message de la notification
     * @param modaliteActivite la séance
     * @return la notification créée ou null si il n'y a pas de destinataires
     */
    Notification getSmsNotificationOnPublicationResultatsForSeance(Personne demandeur, String titre, String message,
                                                                   ModaliteActivite modaliteActivite) {
        def destinatairesIdExt = notificationSeanceDaoService.findAllSmsDestinatairesForPublicationResultats(modaliteActivite)
        if (destinatairesIdExt.isEmpty()) {
            return null
        }
        def support = NotificationSupport.SMS
        def etabIdExt = modaliteActivite.findEtablissement().idExterne
        def demandIdExt = demandeur.idExterne
        Notification notification = new Notification(
                etablissementIdExerne: etabIdExt,
                demandeurIdexterne: demandIdExt,
                titre: titre,
                message:message,
                destinatairesIdExterne: destinatairesIdExt,
                supports: [support]
        )
        notification
    }

    /**
     * Obtient la notification par email correspondant à la création d'un séance
     * @param demandeur le demandeur de la notification
     * @param titre le titre de la notification
     * @param message le message de la notification
     * @param modaliteActivite la séance
     * @return la notification créée ou null si il n'y a pas de destinataires
     */
    Notification getEmailNotificationOnCreationSeanceForSeance(Personne demandeur, String titre, String message,
                                                               ModaliteActivite modaliteActivite) {
        def destinatairesIdExt = notificationSeanceDaoService.findAllEmailDestinatairesForCreationSeance(modaliteActivite)
        if (destinatairesIdExt.isEmpty()) {
            return null
        }
        def support = NotificationSupport.EMAIL
        def etabIdExt = modaliteActivite.findEtablissement().idExterne ?: UNKNOWN
        def demandIdExt = demandeur.idExterne
        Notification notification = new Notification(
                etablissementIdExerne: etabIdExt,
                demandeurIdexterne: demandIdExt,
                titre: titre,
                message:message,
                destinatairesIdExterne: destinatairesIdExt,
                supports: [support]
        )
        notification
    }

    /**
     * Obtient la notification par sms correspondant à la création d'un séance
     * @param demandeur le demandeur de la notification
     * @param titre le titre de la notification
     * @param message le message de la notification
     * @param modaliteActivite la séance
     * @return la notification créée ou null si il n'y a pas de destinataires
     */
    Notification getSmsNotificationOnCreationSeanceForSeance(Personne demandeur, String titre, String message,
                                                             ModaliteActivite modaliteActivite) {
        def destinatairesIdExt = notificationSeanceDaoService.findAllSmsDestinatairesForCreationSeance(modaliteActivite)
        if (destinatairesIdExt.isEmpty()) {
            return null
        }
        def support = NotificationSupport.SMS
        def etabIdExt = modaliteActivite.findEtablissement().idExterne ?: UNKNOWN
        def demandIdExt = demandeur.idExterne
        Notification notification = new Notification(
                etablissementIdExerne: etabIdExt,
                demandeurIdexterne: demandIdExt,
                titre: titre,
                message:message,
                destinatairesIdExterne: destinatairesIdExt,
                supports: [support]
        )
        notification
    }



}
