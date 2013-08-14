package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetSequenceQuestions
import org.lilie.services.eliot.tdbase.SujetType
import spock.lang.Specification

/**
 * @author John Tranier
 */
class SujetMarshallerSpec extends Specification {

  def "testMarshall - cas général"(String paternite, List<SujetSequenceQuestions> questionsSequences) {
    given:
    Sujet sujet = new Sujet(
        sujetType: new SujetType(id: 2),
        titre: 'titre',
        dateCreated: new Date() - 1,
        lastUpdated: new Date(),
        presentation: 'presentation',
        annotationPrivee: 'annotationPrivee',
        dureeMinutes: 180,
        noteMax: 20,
        noteAutoMax: 12,
        noteEnseignantMax: 8,
        accesSequentiel: true,
        ordreQuestionsAleatoire: true,
        paternite: paternite,
        questionsSequences: questionsSequences
    )

    Map personneRepresentation = [map: 'personne']
    Map etablissementRepresentation = [map: 'etablissement']
    Map matiereRepresentation = [map: 'matiere']
    Map niveauRepresentation = [map: 'niveau']
    Map copyrightsTypeRepresentation = [map: 'copyrightsType']

    PersonneMarshaller personneMarshaller = Mock(PersonneMarshaller)
    personneMarshaller.marshall(_) >> personneRepresentation

    EtablissementMarshaller etablissementMarshaller = Mock(EtablissementMarshaller)
    etablissementMarshaller.marshall(_) >> etablissementRepresentation

    MatiereMarshaller matiereMarshaller = Mock(MatiereMarshaller)
    matiereMarshaller.marshall(_) >> matiereRepresentation

    NiveauMarshaller niveauMarshaller = Mock(NiveauMarshaller)
    niveauMarshaller.marshall(_) >> niveauRepresentation

    CopyrightsTypeMarshaller copyrightsTypeMarshaller = Mock(CopyrightsTypeMarshaller)
    copyrightsTypeMarshaller.marshall(_) >> copyrightsTypeRepresentation

    SujetSequenceQuestionsMarshaller sujetSequenceQuestionsMarshaller = Mock(SujetSequenceQuestionsMarshaller)
    sujetSequenceQuestionsMarshaller.marshall(_) >> { SujetSequenceQuestions sujetSequenceQuestions ->
      return [
          map: 'sujetSequenceQuestions',
          rang: sujetSequenceQuestions.rang
      ]
    }

    SujetMarshaller sujetMarshaller = new SujetMarshaller(
        personneMarshaller: personneMarshaller,
        copyrightsTypeMarshaller: copyrightsTypeMarshaller,
        etablissementMarshaller: etablissementMarshaller,
        matiereMarshaller: matiereMarshaller,
        niveauMarshaller: niveauMarshaller,
        sujetSequenceQuestionsMarshaller: sujetSequenceQuestionsMarshaller
    )

    Map sujetRepresentation = sujetMarshaller.marshall(sujet)

    expect:
    sujetRepresentation.size() == 4
    sujetRepresentation.titre == sujet.titre
    sujetRepresentation.metadonnees.size() == 7
    sujetRepresentation.metadonnees.versionSujet == sujet.versionSujet
    sujetRepresentation.metadonnees.dateCreated == sujet.dateCreated
    sujetRepresentation.metadonnees.lastUpdated == sujet.lastUpdated
    sujet.paternite ?
      sujetRepresentation.metadonnees.paternite == JSON.parse(sujet.paternite) :
      sujetRepresentation.metadonnees.paternite == null
    sujetRepresentation.metadonnees.proprietaire == personneRepresentation
    sujetRepresentation.metadonnees.copyrightsType == copyrightsTypeRepresentation
    sujetRepresentation.metadonnees.referentielEliot.size() == 3
    sujetRepresentation.metadonnees.referentielEliot.etablissement == etablissementRepresentation
    sujetRepresentation.metadonnees.referentielEliot.matiere == matiereRepresentation
    sujetRepresentation.metadonnees.referentielEliot.niveau == niveauRepresentation
    sujetRepresentation.specification.size() == 9
    sujetRepresentation.specification.presentation == sujet.presentation
    sujetRepresentation.specification.annotationPrivee == sujet.annotationPrivee
    sujetRepresentation.specification.dureeMinutes == sujet.dureeMinutes
    sujetRepresentation.specification.noteMax == sujet.noteMax
    sujetRepresentation.specification.noteAutoMax == sujet.noteAutoMax
    sujetRepresentation.specification.noteEnseignantMax == sujet.noteEnseignantMax
    sujetRepresentation.specification.accesSequentiel == sujet.accesSequentiel
    sujetRepresentation.specification.ordreQuestionsAleatoire == sujet.ordreQuestionsAleatoire
    if(questionsSequences) {
      sujetRepresentation.specification.questionsSequences.size() == questionsSequences.size()
      sujetRepresentation.specification.questionsSequences.eachWithIndex { def questionSequence, int i ->
        assert questionSequence.rang == i
      }
    }
    else {
      sujetRepresentation.specification.questionsSequences == []
    }

    where:
    paternite << [null, null, "", "{json: 'paternite'}"]
    questionsSequences << [
        null,
        [],
        [new SujetSequenceQuestions(rang: 0)],
        [new SujetSequenceQuestions(rang: 0), new SujetSequenceQuestions(rang: 1)]
    ]
  }

  def "testMarshall - argument null"() {
    setup:
    SujetMarshaller sujetMarshaller = new SujetMarshaller()

    when:
    sujetMarshaller.marshall(null)

    then:
    thrown(IllegalArgumentException)
  }
}
