package org.lilie.services.eliot.tdbase.preferences

import grails.test.mixin.TestMixin
import grails.test.mixin.support.GrailsUnitTestMixin
import org.lilie.services.eliot.tice.annuaire.Personne
import spock.lang.Specification
import spock.lang.Unroll

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
        when: "une nouvelle préférence personne est crée"
        preferencePersonne = new PreferencePersonne(personne: Mock(Personne))

        then: "les abonnements aux notifications ne pas sont activés"
        !preferencePersonne.notificationOnCreationSeance
        !preferencePersonne.notificationOnPublicationResultats
        preferencePersonne.codeSupportNotification == null

    }

    @Unroll
    void "lorsqu'une notification est active au moins, le code support notification est renseigné correctement"() {
        given: "une préférence personne"
        preferencePersonne = new PreferencePersonne(personne: Mock(Personne))

        when: "les préférences sont modifiées avec au moins une notification active"
        preferencePersonne.notificationOnPublicationResultats = notifPubliRes
        preferencePersonne.notificationOnCreationSeance = notifCreatSean
        preferencePersonne.codeSupportNotification = codeSupp

        then: "les préférences sont valides que si le code support est correctement paramétré"
        preferencePersonne.validate() == prefIsValide

        where:
        notifPubliRes | notifCreatSean | codeSupp                        | prefIsValide
        false         | false          | null                            | true
        true          | false          | null                            | false
        true          | false          | 0                               | false // 0 n'est pas un code valide
        true          | false          | SupportNotification.E_MAIL.code | true

    }

}