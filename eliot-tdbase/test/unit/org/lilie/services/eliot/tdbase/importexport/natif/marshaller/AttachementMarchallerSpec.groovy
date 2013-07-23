package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONObject
import org.lilie.services.eliot.tdbase.QuestionAttachement
import org.lilie.services.eliot.tdbase.importexport.dto.AttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.PrincipalAttachementDto
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
    attachementRepresentation.size() == 1
    attachementRepresentation.attachement.size() == 5
    attachementRepresentation.attachement.nom == attachement.nom
    attachementRepresentation.attachement.nomFichierOriginal == attachement.nomFichierOriginal
    attachementRepresentation.attachement.typeMime == attachement.typeMime
    attachementRepresentation.attachement.blob == blobBase64
    attachementRepresentation.attachement.estInsereDansLaQuestion == estInsereDansLaQuestion

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
      assert questionAttachementsRepresentation[i].size() == 5
      assert questionAttachementsRepresentation[i].nom == questionAttachement.attachement.nom
      assert questionAttachementsRepresentation[i].nomFichierOriginal == questionAttachement.attachement.nomFichierOriginal
      assert questionAttachementsRepresentation[i].typeMime == questionAttachement.attachement.typeMime
      assert questionAttachementsRepresentation[i].blob == attachementService.encodeToBase64(questionAttachement.attachement)
      assert questionAttachementsRepresentation[i].estInsereDansLaQuestion == questionAttachement.estInsereDansLaQuestion
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
          attachement: genereAttachement(it),
          estInsereDansLaQuestion: it % 2 == 0
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

  def "testParsePrincipalAttachement - cas général"(String nom,
                                                    String nomFichierOriginal,
                                                    String typeMime,
                                                    String blob,
                                                    Boolean estInsereDansLaQuestion) {
    given:
    String json = """
      {
        attachement: {
          nom: ${MarshallerHelper.asJsonString(nom)},
          nomFichierOriginal: ${MarshallerHelper.asJsonString(nomFichierOriginal)},
          typeMime: ${MarshallerHelper.asJsonString(typeMime)},
          blob: ${MarshallerHelper.asJsonString(blob)},
          estInsereDansLaQuestion: $estInsereDansLaQuestion
        }
      }
    """

    PrincipalAttachementDto principalAttachementDto =
      AttachementMarchaller.parsePrincipalAttachement(
          JSON.parse(json)
      )

    expect:
    principalAttachementDto.attachement.nom == nom
    principalAttachementDto.attachement.nomFichierOriginal == nomFichierOriginal
    principalAttachementDto.attachement.typeMime == typeMime
    principalAttachementDto.attachement.blob == blob
    principalAttachementDto.attachement.estInsereDansLaQuestion == estInsereDansLaQuestion

    where:
    nom = 'nom'
    nomFichierOriginal = 'nomFichierOriginal'
    typeMime = 'typeMime'
    blob = 'blob'
    estInsereDansLaQuestion << [true, false]
  }

  def "testParsePrincipalAttachement - erreur attachement absent"() {
    given:
    String json = '{}'

    when:
    AttachementMarchaller.parsePrincipalAttachement(
        JSON.parse(json)
    )

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'principalAttachement.attachement'
  }

  def "testParsePrincipalAttachement - erreur attachement.nom manquant"() {
    given:
    String json = """
      {
        attachement: {}
      }
    """

    when:
    AttachementMarchaller.parsePrincipalAttachement(
        JSON.parse(json)
    )

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'principalAttachement.attachement.nom'
  }

  def "testParsePrincipalAttachement - erreur attachement.nomFichierOriginal manquant"() {
    given:
    String json = """
      {
        attachement: {
          nom: 'nom'
        }
      }
    """

    when:
    AttachementMarchaller.parsePrincipalAttachement(
        JSON.parse(json)
    )

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'principalAttachement.attachement.nomFichierOriginal'
  }

  def "testParsePrincipalAttachement - erreur attachement.typeMime manquant"() {
    given:
    String json = """
      {
        attachement: {
          nom: 'nom',
          nomFichierOriginal: 'nomFichierOriginal'
        }
      }
    """

    when:
    AttachementMarchaller.parsePrincipalAttachement(
        JSON.parse(json)
    )

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'principalAttachement.attachement.typeMime'
  }

  def "testParsePrincipalAttachement - erreur attachement.blob manquant"() {
    given:
    String json = """
      {
        attachement: {
          nom: 'nom',
          nomFichierOriginal: 'nomFichierOriginal',
          typeMime: 'typeMime',
        }
      }
    """

    when:
    AttachementMarchaller.parsePrincipalAttachement(
        JSON.parse(json)
    )

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'principalAttachement.attachement.blob'
  }

  def "testParsePrincipalAttachement - JSONObject.Null"() {
    expect:
    AttachementMarchaller.parsePrincipalAttachement(new JSONObject.Null()) == null
  }

  def "testParseQuestionAttachements - cas général"() {
    given:
    String json = """
      [
        {
          nom: 'nom1',
          nomFichierOriginal: 'nomFichierOriginal1',
          typeMime: 'typeMime1',
          blob: 'blob1',
          estInsereDansLaQuestion:  true
        },
        {
          nom: 'nom2',
          nomFichierOriginal: 'nomFichierOriginal2',
          typeMime: 'typeMime2',
          blob: 'blob2',
          estInsereDansLaQuestion:  false
        }
      ]
    """

    List<AttachementDto> questionAttachementsDto =
      AttachementMarchaller.parseQuestionAttachements(
          (JSONArray)JSON.parse(json)
      )

    expect:
    questionAttachementsDto.size() == 2
    questionAttachementsDto[0].nom == 'nom1'
    questionAttachementsDto[0].nomFichierOriginal == 'nomFichierOriginal1'
    questionAttachementsDto[0].typeMime == 'typeMime1'
    questionAttachementsDto[0].blob == 'blob1'
    questionAttachementsDto[0].estInsereDansLaQuestion
    questionAttachementsDto[1].nom == 'nom2'
    questionAttachementsDto[1].nomFichierOriginal == 'nomFichierOriginal2'
    questionAttachementsDto[1].typeMime == 'typeMime2'
    questionAttachementsDto[1].blob == 'blob2'
    !questionAttachementsDto[1].estInsereDansLaQuestion
  }

}
