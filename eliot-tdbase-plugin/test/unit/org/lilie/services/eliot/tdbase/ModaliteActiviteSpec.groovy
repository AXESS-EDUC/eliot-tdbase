package org.lilie.services.eliot.tdbase

import grails.test.mixin.TestMixin
import grails.test.mixin.support.GrailsUnitTestMixin
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.support.GrailsUnitTestMixin} for usage instructions
 */
@TestMixin(GrailsUnitTestMixin)
class ModaliteActiviteSpec extends Specification {

    ModaliteActivite modaliteActivite

    def setup() {
    }

    def cleanup() {
    }

    void "une seance nouvelle cree avec structure d'enseignement, enseignant et  sujet est initialisée de manière  valide"() {
        given: "une nouvelle seance avec sujet et structure enseignement"
        modaliteActivite = new ModaliteActivite(sujet: Mock(Sujet),
                structureEnseignement: Mock(StructureEnseignement),
                enseignant: Mock(Personne)
        )

        when: "on valide la séance"
        def isValide = modaliteActivite.validate()

        then: "la séance est valide"
        isValide
        !modaliteActivite.hasErrors()

        and:"initialisée correctement"
        modaliteActivite.notifierMaintenant
        modaliteActivite.notifierNJoursAvant == 1
        modaliteActivite.datePublicationResultats.after(modaliteActivite.dateFin)
        modaliteActivite.dateFin.after(modaliteActivite.dateDebut)

    }

    void "une seance crée avec une date de publication avant la date de fin n'est pas valide"() {
        given: "une nouvelle seance avec sujet et structure enseignement"
        modaliteActivite = new ModaliteActivite(sujet: Mock(Sujet),
                structureEnseignement: Mock(StructureEnseignement),
                enseignant: Mock(Personne)
        )
        and: "une date publication positionnée avant la date de fin"
        modaliteActivite.dateDebut = new Date()
        modaliteActivite.dateFin = new Date()+2
        modaliteActivite.datePublicationResultats = new Date()+1


        when: "on valide la séance"
        def isValide = modaliteActivite.validate()

        then: "la séance est valide"
        !isValide
        modaliteActivite.hasErrors()
    }
}