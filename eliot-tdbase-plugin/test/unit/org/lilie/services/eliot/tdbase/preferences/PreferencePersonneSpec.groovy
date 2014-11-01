package org.lilie.services.eliot.tdbase.preferences

import grails.test.mixin.TestMixin
import grails.test.mixin.support.GrailsUnitTestMixin
import org.lilie.services.eliot.tice.annuaire.Personne
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.support.GrailsUnitTestMixin} for usage instructions
 */
@TestMixin(GrailsUnitTestMixin)
class PreferencePersonneSpec extends Specification {

    PreferencePersonne preferencePersonne

    def setup() {
    }

    def cleanup() {
    }

    void "la création d'une préférence personne valide initialise l'abonnement des notifications"() {
        when:"une nouvelle préférence personne est crée"
        preferencePersonne = new PreferencePersonne(personne: Mock(Personne))

        then:"les abonnements aux notifications sont activés"
        preferencePersonne.notificationOnCreationSeance
        preferencePersonne.notificationOnPublicationResultats

    }
}