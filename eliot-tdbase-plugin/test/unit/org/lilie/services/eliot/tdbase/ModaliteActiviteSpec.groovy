package org.lilie.services.eliot.tdbase

import grails.test.mixin.TestMixin
import grails.test.mixin.support.GrailsUnitTestMixin
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.ProprietesScolarite
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.support.GrailsUnitTestMixin} for usage instructions
 */
@TestMixin(GrailsUnitTestMixin)
class ModaliteActiviteSpec extends Specification {

    ModaliteActivite modaliteActivite
    Date now

    def setup() {
        now = new Date()
    }

    def cleanup() {
    }

    void "une seance nouvelle cree avec un groupe scolarité, enseignant et  sujet est initialisée de manière  valide"() {
        given: "une nouvelle seance avec sujet et structure enseignement"
        modaliteActivite = new ModaliteActivite(sujet: Mock(Sujet),
                groupeScolarite: new ProprietesScolarite(),
                enseignant: Mock(Personne),
                datePublicationResultats: null
        )

        when: "on valide la séance"
        def isValide = modaliteActivite.validate()

        then: "la séance est valide"
        isValide
        !modaliteActivite.hasErrors()

        and:"initialisée correctement"
        modaliteActivite.notifierMaintenant
        modaliteActivite.notifierAvantOuverture
        modaliteActivite.notifierNJoursAvant == 1
        modaliteActivite.dateFin.after(modaliteActivite.dateDebut)

        when:"une date de publication est specifiee supérieure à la date de fin"
        modaliteActivite.datePublicationResultats = modaliteActivite.dateFin + 1


        and:"la séance est validée"
        isValide = modaliteActivite.validate()

        then: "la séance reste valide"
        isValide

        when:"une date de publication est specifiee égale à la date de fin"
        modaliteActivite.datePublicationResultats = modaliteActivite.dateFin


        and:"la séance est validée"
        isValide = modaliteActivite.validate()

        then: "la séance reste valide"
        isValide
    }

    void "une seance crée avec une date de publication avant la date de fin n'est pas valide"() {
        given: "une nouvelle seance avec sujet et structure enseignement"
        modaliteActivite = new ModaliteActivite(sujet: Mock(Sujet),
                groupeScolarite: Mock(ProprietesScolarite),
                enseignant: Mock(Personne)
        )
        and: "une date publication positionnée avant la date de fin"
        modaliteActivite.dateDebut = now
        modaliteActivite.dateFin = now+2
        modaliteActivite.datePublicationResultats = now+1


        when: "on valide la séance"
        def isValide = modaliteActivite.validate()

        then: "la séance est valide"
        !isValide
        modaliteActivite.hasErrors()
    }

    void "une seance finie sans date de publication de resultats a ses resultats publies"(){
        given: "une  seance terminee sans date de publication"
        modaliteActivite = new ModaliteActivite(sujet: Mock(Sujet),
                groupeScolarite: Mock(ProprietesScolarite),
                enseignant: Mock(Personne),
                dateDebut: now -2,
                dateFin: now-1,
                datePublicationResultats: null
        )

        expect:"les resultats sont publies"
        modaliteActivite.hasResultatsPublies()
    }

    void "une seance finie avec date de publication de resultats passée a ses resultats publies"(){
        given: "une  seance terminee sans date de publication"
        modaliteActivite = new ModaliteActivite(sujet: Mock(Sujet),
                groupeScolarite: Mock(ProprietesScolarite),
                enseignant: Mock(Personne),
                dateDebut: now -2,
                dateFin: now-1,
                datePublicationResultats: now -1
        )

        expect:"les resultats sont publies"
        modaliteActivite.hasResultatsPublies()
    }

    void "une seance non finie avec ou sans date de publication de resultats a ses resultats non publies"(){
        given: "une  seance terminee sans date de publication"
        modaliteActivite = new ModaliteActivite(sujet: Mock(Sujet),
                groupeScolarite: Mock(ProprietesScolarite),
                enseignant: Mock(Personne),
                dateDebut: now -2,
                dateFin: now+1,
                datePublicationResultats: null
        )

        expect:"les resultats ne sont pas publies"
        !modaliteActivite.hasResultatsPublies()

        when: "une date de publication est specifiee"
        modaliteActivite.datePublicationResultats = modaliteActivite.dateFin+1

        then: "les resultats ne sont pas publies"
        !modaliteActivite.hasResultatsPublies()
    }
}