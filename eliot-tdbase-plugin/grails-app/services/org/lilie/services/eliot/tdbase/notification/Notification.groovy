package org.lilie.services.eliot.tdbase.notification

import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement

/**
 * Created by franck on 04/11/2014.
 */
public class Notification {
    String etablissementIdExerne
    String demandeurIdexterne
    String titre
    String message
    List<String> destinatairesIdExterne
    List<NotificationSupport> supports

    String toString() {
        """$titre
            $message
        """
    }
}

