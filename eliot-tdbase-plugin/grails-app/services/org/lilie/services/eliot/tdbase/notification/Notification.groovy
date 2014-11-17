package org.lilie.services.eliot.tdbase.notification

import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * Created by franck on 04/11/2014.
 */
public interface Notification {

    def doNotifie(Set<Personne> personnesToNotifier)

}