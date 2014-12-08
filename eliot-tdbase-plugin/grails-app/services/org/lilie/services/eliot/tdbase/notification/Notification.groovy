package org.lilie.services.eliot.tdbase.notification

import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement

/**
 * Created by franck on 04/11/2014.
 */
public class Notification {
    Etablissement etablissement
    Personne demandeur
    String titre
    String message

}
