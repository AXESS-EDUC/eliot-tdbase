package org.lilie.services.eliot.tdbase.marshaller.natif

import grails.converters.JSON
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionType
import spock.lang.Specification

/**
 * @author John Tranier
 */
class QuestionMarshallerSpec extends Specification {

  def "testMashall - cas général"(String paternite,
                                  Question question,
                                  Map personneRepresentation,
                                  Map etablissementRepresentation,
                                  Map matiereRepresentation,
                                  Map niveauRepresentation,
                                  String copyrightsTypeRepresentation,
                                  Map principalAttachementRepresentation,
                                  List questionAttachementsRepresentation) {
    given:
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

    AttachementMarchaller attachementMarchaller = Mock(AttachementMarchaller)
    attachementMarchaller.marshallPrincipalAttachement(_, _) >> principalAttachementRepresentation
    attachementMarchaller.marshallQuestionAttachements(_) >> questionAttachementsRepresentation

    QuestionMarshaller questionMarshaller = new QuestionMarshaller(
        personneMarshaller: personneMarshaller,
        etablissementMarshaller: etablissementMarshaller,
        matiereMarshaller: matiereMarshaller,
        niveauMarshaller: niveauMarshaller,
        copyrightsTypeMarshaller: copyrightsTypeMarshaller,
        attachementMarchaller: attachementMarchaller
    )

    Map questionRepresentation = questionMarshaller.marshall(question)

    expect:
    questionRepresentation.size() == 6
    questionRepresentation.type == question.type.code
    questionRepresentation.titre == question.titre

    questionRepresentation.metadonnees.size() == 8
    questionRepresentation.metadonnees.dateCreated == question.dateCreated
    questionRepresentation.metadonnees.lastUpdated == question.lastUpdated
    questionRepresentation.metadonnees.versionQuestion == question.versionQuestion
    questionRepresentation.metadonnees.estAutonome == question.estAutonome
    questionRepresentation.metadonnees.copyrightsType == copyrightsTypeRepresentation
    question.paternite ?
      questionRepresentation.metadonnees.paternite == JSON.parse(question.paternite) :
      questionRepresentation.metadonnees.paternite == null

    questionRepresentation.metadonnees.referentiel.etablissement == etablissementRepresentation
    questionRepresentation.metadonnees.referentiel.matiere == matiereRepresentation
    questionRepresentation.metadonnees.referentiel.niveau == niveauRepresentation

    question.specification ?
      questionRepresentation.specification == JSON.parse(question.specification) :
      questionRepresentation.specification == null

    questionRepresentation.principalAttachement == principalAttachementRepresentation
    questionRepresentation.questionAttachements == questionAttachementsRepresentation

    where:
    paternite << [null, "", "{json: 'paternite'}"]

    question = new Question(
        type: new QuestionType(code: "code"),
        titre: "titre",
        dateCreated: new Date() - 1,
        lastUpdated: new Date(),
        versionQuestion: 10,
        estAutonome: true,
        paternite: paternite,
        specification: "{json: 'specification'}"
    )

    personneRepresentation = [map: 'personne']
    etablissementRepresentation = [map: 'etablissement']
    matiereRepresentation = [map: 'matiere']
    niveauRepresentation = [map: 'niveau']
    copyrightsTypeRepresentation = [map: 'copyrightsType']
    principalAttachementRepresentation = [map: 'principalAttachement']
    questionAttachementsRepresentation = [[map: 'attachement']]
  }

  def "testMarshall - argument null"() {
    setup:
    QuestionMarshaller questionMarshaller = new QuestionMarshaller()

    when:
    questionMarshaller.marshall(null)

    then:
    thrown(IllegalArgumentException)
  }

}
