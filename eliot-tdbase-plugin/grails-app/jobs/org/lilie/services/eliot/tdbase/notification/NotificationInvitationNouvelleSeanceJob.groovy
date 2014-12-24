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

import org.codehaus.groovy.grails.web.mapping.LinkGenerator
import org.lilie.services.eliot.tdbase.ModaliteActivite
import org.lilie.services.eliot.tdbase.webservices.rest.client.NotificationRestService


/**
 * Job prenant en charge la gestion asynchrone des campagnes EmaEval associées
 * aux séances TD Base
 *
 * @author John Tranier
 */
class NotificationInvitationNouvelleSeanceJob {
    def concurrent = false

    private final static int BATCH_SIZE = 20

    NotificationSeanceDaoService notificationSeanceDaoService
    NotificationRestService notificationRestService
    NotificationSeanceService notificationSeanceService
    def messageSource
    LinkGenerator grailsLinkGenerator

    Locale frLocale = new Locale("fr")

    def getTriggers() {
        return config.eliot.tdbase.notifications.seance.invitation.trigger
    }

    def execute() {
        log.info "Exécution du NotificationInvitationNouvelleSeanceJob"

        def seances = notificationSeanceDaoService.findAllSeancesWithInvitationToNotifie(BATCH_SIZE)
        seances.each {
            onOuvertureSeance(it)
        }
    }

    private onOuvertureSeance(ModaliteActivite seance) {
        def titre = messageSource.getMessage("notification.seance.invitation.titre",null, frLocale)
        def message = messageSource.getMessage("notification.seance.invitation.message", getStringsForInvitation(seance), frLocale)
        Notification notificationSms = notificationSeanceService.getSmsNotificationOnCreationSeanceForSeance(
                seance.enseignant,
                titre,
                message,
                seance
        )
        Notification notificationEmail = notificationSeanceService.getEmailNotificationOnCreationSeanceForSeance(
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
            log.debug("try envoi notification : ${notification}")
            def rep = notificationRestService.postNotification(notification)
            if (rep.success == false) {
                log.error(rep.message)
            } else {
                seance.dateNotificationOuvertureSeance = new Date()
                seance.save()
            }
        } catch (Exception e) {
            log.error(e.message)
        }
    }

    private def getStringsForInvitation(ModaliteActivite seance) {
        [
                seance.sujet.titre,
                seance.dateDebut.format("dd/MM/yyyy"),
                seance.dateDebut.format("HH:mm"),
                seance.dateFin.format("dd/MM/yyyy"),
                seance.dateFin.format("HH:mm"),
                grailsLinkGenerator.link(controller: "accueil", action: "activite",
                        id: seance.id,
                        absolute: true,
                        params: [sujetId: seance.sujetId])
        ].toArray()
    }
}
