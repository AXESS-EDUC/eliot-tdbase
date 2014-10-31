package org.lilie.services.eliot.tdbase.preferences

import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import org.lilie.services.eliot.tice.utils.contract.Contract

/**
 * Created by franck on 31/10/2014.
 */
class PreferenceNotifications {

    boolean notificationOnCreationSeance = true
    boolean notificationOnPublicationResultats = true

    PreferenceNotifications() {}

    PreferenceNotifications(String jsonString) {
        Contract.requires(jsonString != null)
        def slurper = new JsonSlurper()
        Map aPrefMap = [:]
        try {
            aPrefMap = slurper.parseText(jsonString)
        } catch (Exception e) {}
        Contract.requires(aPrefMap.containsKey("notificationOnCreationSeance") &&
                aPrefMap.containsKey("notificationOnPublicationResultats"))
        notificationOnCreationSeance = aPrefMap.notificationOnCreationSeance
        notificationOnPublicationResultats = aPrefMap.notificationOnPublicationResultats
    }

    String toJsonString() {
        def builder = new JsonBuilder()
        builder.call([
                notificationOnCreationSeance      : notificationOnCreationSeance,
                notificationOnPublicationResultats: notificationOnPublicationResultats
        ])
        builder.toString()
    }

}
