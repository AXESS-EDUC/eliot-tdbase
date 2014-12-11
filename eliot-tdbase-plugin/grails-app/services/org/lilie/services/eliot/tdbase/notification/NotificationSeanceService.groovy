package org.lilie.services.eliot.tdbase.notification

import org.lilie.services.eliot.tdbase.ModaliteActivite
import org.lilie.services.eliot.tice.annuaire.Personne

class NotificationSeanceService {

    public static final String UNKNOWN = "__INCONNU__"
    NotificationSeanceDaoService notificationSeanceDaoService

    /**
     * Obtient la notification par email correspondant à la publication des résultats sur une séance donnée
     * @param demandeur le demandeur de la notification
     * @param titre le titre de la notification
     * @param message le message de la notification
     * @param modaliteActivite la séance
     * @return la notification créée
     */
    Notification getEmailNotificationOnPublicationResultatsForSeance(Personne demandeur, String titre, String message,
                                                                     ModaliteActivite modaliteActivite) {
        def destinatairesIdExt = notificationSeanceDaoService.findAllEmailDestinatairesForPublicationResultats(modaliteActivite)
        def support = NotificationSupport.EMAIL
        def etabIdExt = modaliteActivite.etablissement.idExterne
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
     * @return la notification créée
     */
    Notification getSmsNotificationOnPublicationResultatsForSeance(Personne demandeur, String titre, String message,
                                                                   ModaliteActivite modaliteActivite) {
        def destinatairesIdExt = notificationSeanceDaoService.findAllSmsDestinatairesForPublicationResultats(modaliteActivite)
        def support = NotificationSupport.SMS
        def etabIdExt = modaliteActivite.etablissement.idExterne
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
     * @return la notification créée
     */
    Notification getEmailNotificationOnCreationSeanceForSeance(Personne demandeur, String titre, String message,
                                                               ModaliteActivite modaliteActivite) {
        def destinatairesIdExt = notificationSeanceDaoService.findAllEmailDestinatairesForCreationSeance(modaliteActivite)
        def support = NotificationSupport.EMAIL
        def etabIdExt = modaliteActivite.structureEnseignement.etablissement.idExterne ?: UNKNOWN
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
     * @return la notification créée
     */
    Notification getSmsNotificationOnCreationSeanceForSeance(Personne demandeur, String titre, String message,
                                                             ModaliteActivite modaliteActivite) {
        def destinatairesIdExt = notificationSeanceDaoService.findAllSmsDestinatairesForCreationSeance(modaliteActivite)
        def support = NotificationSupport.SMS
        def etabIdExt = modaliteActivite.structureEnseignement.etablissement.idExterne ?: UNKNOWN
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
