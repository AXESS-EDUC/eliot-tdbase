package org.lilie.services.eliot.tdbase.notification

import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * Created by franck on 04/11/2014.
 */
abstract class AbstractNotification implements Notification {

    @Override
    final def doNotifie(Set<Personne> personnesToNotifier) {

    }

    final def doNotifie() {
        doNotifie(findAllPersonnesToNotifier())
    }

    abstract Set findAllPersonnesToNotifier()

}
