/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 *  This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *   <http://www.gnu.org/licenses/> and
 *   <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tdbase.notification

import org.lilie.services.eliot.tdbase.ModaliteActivite
import org.lilie.services.eliot.tdbase.webservices.rest.client.NotificationRestService


/**
 * Job prenant en charge la gestion asynchrone des campagnes EmaEval associées
 * aux séances TD Base
 *
 * @author John Tranier
 */
class NotificationPublicationResultatsSeanceJob {
    def concurrent = false

    private final static int BATCH_SIZE = 20

    NotificationSeanceDaoService notificationSeanceDaoService
    NotificationRestService notificationRestService
    NotificationSeanceService notificationSeanceService
    def messageSource

    Locale frLocale = new Locale("fr")

    def getTriggers() {
        return config.eliot.tdbase.notifications.seance.publicationResultats.trigger
    }

    def execute() {
        log.info "Exécution du NotificationPublicationResultatsSeanceJob"

        def seances = notificationSeanceDaoService.findAllSeancesWithPublicationResultatsToNotifie(BATCH_SIZE)
        seances.each {
            onPublicationResultats(it)
        }
    }

    private onPublicationResultats(ModaliteActivite seance) {
        def titre = messageSource.getMessage("notification.seance.publicationResultats.titre",null, frLocale)
        def message = messageSource.getMessage("notification.seance.publicationResultats.message",
                getStringsForPublicationresultats(seance),
                frLocale)
        Notification notificationSms = notificationSeanceService.getSmsNotificationOnPublicationResultatsForSeance(
                seance.enseignant,
                titre,
                message,
                seance
        )
        Notification notificationEmail = notificationSeanceService.getEmailNotificationOnPublicationResultatsForSeance(
                seance.enseignant,
                titre,
                message,
                seance
        )
        postNotification(notificationEmail, seance)
        postNotification(notificationSms, seance)

    }

    private postNotification(Notification notification, ModaliteActivite seance) {
        if (notification == null) {
            return
        }
        try {
            log.error("try envoi notification : ${notification}")
            def rep = notificationRestService.postNotification(notification)
            if (rep.success == false) {
                log.error(rep.message)
            } else {
                seance.dateNotificationPublicationResultats = new Date()
                seance.save()
            }
        } catch (Exception e) {
            log.error(e.message)
        }
    }

    private def getStringsForPublicationresultats(ModaliteActivite seance) {
        [
                seance.sujet.titre,
                seance.datePublicationResultats.format("dd/MM/YYYY"),
                seance.datePublicationResultats.format("HH:mm")
        ].toArray()
    }
}
