package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tdbase.QuestionAttachement
import org.lilie.services.eliot.tice.Attachement
import org.lilie.services.eliot.tice.AttachementService
import spock.lang.Specification

/**
 * @author John Tranier
 */
class AttachementMarchallerSpec extends Specification {

  AttachementMarchaller attachementMarchaller
  AttachementService attachementService

  void setup() {
    attachementService = Mock(AttachementService)
    attachementMarchaller = new AttachementMarchaller(
        attachementService: attachementService
    )
  }

  def "testMarshallPrincipalAttachement - argument null"() {
    expect:
    attachementMarchaller.marshallPrincipalAttachement(null, null) == null
  }

  def "testMarshallPrincipalAttachement - cas général"(String blobBase64,
                                                       Boolean estInsereDansLaQuestion,
                                                       Attachement attachement) {
    given:
    attachementService.encodeToBase64(attachement) >> blobBase64
    Map attachementRepresentation = attachementMarchaller.marshallPrincipalAttachement(
        attachement,
        estInsereDansLaQuestion
    )

    expect:
    attachementRepresentation.size() == 2
    attachementRepresentation.attachement.size() == 4
    attachementRepresentation.attachement.nom == attachement.nom
    attachementRepresentation.attachement.nomFichierOriginal == attachement.nomFichierOriginal
    attachementRepresentation.attachement.typeMime == attachement.typeMime
    attachementRepresentation.attachement.blob == blobBase64
    attachementRepresentation.estInsereDansLaQuestion == estInsereDansLaQuestion

    where:
    blobBase64 = "blob"
    estInsereDansLaQuestion << [null, true, false]
    attachement = new Attachement(
        nom: 'nom',
        nomFichierOriginal: 'nomFichier',
        typeMime: 'typeMime'
    )
  }

  def "testMarshallQuestionAttachements - argument vide"(SortedSet<QuestionAttachement> questionAttachements) {

    expect:
    attachementMarchaller.marshallQuestionAttachements(questionAttachements) == []

    where:
    questionAttachements << [null, [] as SortedSet]
  }

  def "testMarshallQuestionAttachements - cas général"(SortedSet<QuestionAttachement> questionAttachements) {
    given:
    attachementService.encodeToBase64(_) >> { arg ->
      arg.nom
    }

    List questionAttachementsRepresentation = attachementMarchaller.marshallQuestionAttachements(
        questionAttachements
    )

    expect:
    questionAttachements.size() == questionAttachements.size()
    questionAttachements.eachWithIndex { QuestionAttachement questionAttachement, int i ->
      questionAttachementsRepresentation[i].size() == 4
      questionAttachementsRepresentation[i].nom == questionAttachement.attachement.nom
      questionAttachementsRepresentation[i].nomFichierOriginal == questionAttachement.attachement.nomFichierOriginal
      questionAttachementsRepresentation[i].typeMime == questionAttachement.attachement.typeMime
      questionAttachementsRepresentation[i].blob == attachementService.encodeToBase64(questionAttachement.attachement)
    }

    where:
    questionAttachements << [
        genereQuestionAttachements(1),
        genereQuestionAttachements(3)
    ]
  }

  private SortedSet<QuestionAttachement> genereQuestionAttachements(int nbAttachement) {
    SortedSet<QuestionAttachement> questionAttachements = [] as SortedSet

    nbAttachement.times {
      questionAttachements << new QuestionAttachement(
          rang: it,
          attachement: genereAttachement(it)
      )

    }

    return questionAttachements
  }

  private Attachement genereAttachement(int num) {
    return new Attachement(
        nom: "nom$num",
        nomFichierOriginal: "nomFichier$num",
        typeMime: "typeMime$num"
    )
  }
}
