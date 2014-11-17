package org.lilie.services.eliot.tdbase.preferences

import grails.test.mixin.Mock
import grails.test.mixin.TestFor
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.utils.contract.PreConditionException
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.services.ServiceUnitTestMixin} for usage instructions
 */
@TestFor(PreferencePersonneService)
class PreferencePersonneServiceSpec extends Specification {

    PreferencePersonneService preferencePersonneService
    Personne personne

    def setup() {
        preferencePersonneService = Spy(PreferencePersonneService)
        personne = Mock(Personne)

    }

    void "La mise à jour d'une preference Personne ne peut se faire que par la personne concernée par la préférence"() {
        given:"une préférence Personne"
        PreferencePersonne preferencePersonne = Mock(PreferencePersonne) {
            getPersonne() >> personne
        }

        when:"la mise à jour de la préférence est déclenchée par une autre personne"
        preferencePersonneService.updatePreferencePersonne(preferencePersonne, Mock(Personne))

        then:"une violation de précondition est déclenchée"
        thrown(PreConditionException)

    }

    void "La récupération d'une préférence déclenche la création de la préférence si elle n'existe pas"() {
        given: "une personne sans préférence"
        PreferencePersonne.metaClass.static.findByPersonne = { personne -> null }
        PreferencePersonne.metaClass.save = { -> null }

        when: "la récupération de la préférence personne est déclenchée"
        preferencePersonneService.getPreferenceForPersonne(personne)

        then: "la création de la préférence est déclenchée"
        1 * preferencePersonneService.createPreferenceForPersonne(personne)

    }
}
