package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONObject
import org.lilie.services.eliot.tdbase.QuestionAttachement
import org.lilie.services.eliot.tdbase.importexport.dto.PrincipalAttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAttachementDto
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
    attachementMarchaller = new AttachementMarchaller()
  }

  def "testMarshallPrincipalAttachement - argument null"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    expect:
    attachementMarchaller.marshallPrincipalAttachement(null, null, attachementDataStore) == null
  }

  def "testMarshallPrincipalAttachement - cas général"(Boolean estInsereDansLaQuestion) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore(attachementService: attachementService)
    String chemin = 'chemin'
    String blobBase64 = "blob"
    Attachement attachement = new Attachement(
        nom: 'nom',
        nomFichierOriginal: 'nomFichier',
        typeMime: 'typeMime',
        chemin: chemin
    )

    attachementService.encodeToBase64(attachement) >> blobBase64
    Map attachementRepresentation = attachementMarchaller.marshallPrincipalAttachement(
        attachement,
        estInsereDansLaQuestion,
        attachementDataStore
    )

    expect:
    attachementRepresentation.size() == 2
    attachementRepresentation.class == ExportClass.PRINCIPAL_ATTACHEMENT.name()
    attachementRepresentation.attachement.size() == 6
    attachementRepresentation.attachement.class == ExportClass.ATTACHEMENT.name()
    attachementRepresentation.attachement.nom == attachement.nom
    attachementRepresentation.attachement.nomFichierOriginal == attachement.nomFichierOriginal
    attachementRepresentation.attachement.typeMime == attachement.typeMime
    attachementRepresentation.attachement.chemin == chemin
    attachementRepresentation.attachement.estInsereDansLaQuestion == estInsereDansLaQuestion
    attachementDataStore.getBlobBase64(chemin) == blobBase64
    where:

    estInsereDansLaQuestion << [null, true, false]
  }

  def "testMarshallQuestionAttachements - argument vide"(List<QuestionAttachement> questionAttachements) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()

    expect:
    attachementMarchaller.marshallQuestionAttachements(questionAttachements, attachementDataStore) == []

    where:
    questionAttachements << [null, []]
  }

  def "testMarshallQuestionAttachements - cas général"(List<QuestionAttachement> questionAttachements) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore(attachementService: attachementService)
    attachementService.encodeToBase64(_) >> { arg ->
      arg.nom
    }

    List questionAttachementsRepresentation = attachementMarchaller.marshallQuestionAttachements(
        questionAttachements,
        attachementDataStore
    )

    expect:
    questionAttachements.size() == questionAttachements.size()
    questionAttachements.eachWithIndex { QuestionAttachement questionAttachement, int i ->
      assert questionAttachementsRepresentation[i].size() == 3
      assert questionAttachementsRepresentation[i].class == ExportClass.QUESTION_ATTACHEMENT.name()
      assert questionAttachementsRepresentation[i].id == questionAttachement.id
      assert questionAttachementsRepresentation[i].attachement
      assert questionAttachementsRepresentation[i].attachement.size() == 6
      assert questionAttachementsRepresentation[i].attachement.nom == questionAttachement.attachement.nom
      assert questionAttachementsRepresentation[i].attachement.nomFichierOriginal == questionAttachement.attachement.nomFichierOriginal
      assert questionAttachementsRepresentation[i].attachement.typeMime == questionAttachement.attachement.typeMime
      assert questionAttachementsRepresentation[i].attachement.chemin == questionAttachement.attachement.chemin
      assert questionAttachementsRepresentation[i].attachement.estInsereDansLaQuestion == questionAttachement.estInsereDansLaQuestion

      attachementDataStore.getBlobBase64(questionAttachement.attachement.chemin) ==
          attachementService.encodeToBase64(questionAttachement.attachement)
    }

    where:
    questionAttachements << [
        genereQuestionAttachements(1),
        genereQuestionAttachements(3)
    ]
  }

  private List<QuestionAttachement> genereQuestionAttachements(int nbAttachement) {
    List<QuestionAttachement> questionAttachements = []

    nbAttachement.times {
      questionAttachements << new QuestionAttachement(
          id: it,
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
        typeMime: "typeMime$num",
        chemin: "chemin$num"
    )
  }

  def "testParsePrincipalAttachement - cas général"(Boolean estInsereDansLaQuestion) {
    given:
    String nom = 'nom'
    String nomFichierOriginal = 'nomFichierOriginal'
    String typeMime = 'typeMime'
    String chemin = 'chemin'
    String blob = 'blob'

    AttachementDataStore attachementDataStore = new AttachementDataStore()
     attachementDataStore.addAttachementFromJson(chemin, blob)

    String json = """
      {
        class: '${ExportClass.PRINCIPAL_ATTACHEMENT}',
        attachement: {
          class: '${ExportClass.ATTACHEMENT}',
          nom: ${MarshallerHelper.asJsonString(nom)},
          nomFichierOriginal: ${MarshallerHelper.asJsonString(nomFichierOriginal)},
          typeMime: ${MarshallerHelper.asJsonString(typeMime)},
          chemin: ${MarshallerHelper.asJsonString(chemin)},
          estInsereDansLaQuestion: $estInsereDansLaQuestion
        }
      }
    """

    PrincipalAttachementDto principalAttachementDto =
      AttachementMarchaller.parsePrincipalAttachement(
          JSON.parse(json),
          attachementDataStore
      )

    expect:
    principalAttachementDto.attachement.nom == nom
    principalAttachementDto.attachement.nomFichierOriginal == nomFichierOriginal
    principalAttachementDto.attachement.typeMime == typeMime
    principalAttachementDto.attachement.blob == blob
    principalAttachementDto.attachement.estInsereDansLaQuestion == estInsereDansLaQuestion

    where:
    estInsereDansLaQuestion << [true, false]
  }

  def "testParsePrincipalAttachement - erreur attachement absent"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    String json = """
    {
      class: '${ExportClass.PRINCIPAL_ATTACHEMENT}'
    }
    """

    when:
    AttachementMarchaller.parsePrincipalAttachement(
        JSON.parse(json),
        attachementDataStore
    )

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'attachement'
  }

  def "testParsePrincipalAttachement - erreur attachement.nom manquant"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    String json = """
      {
        class: '${ExportClass.PRINCIPAL_ATTACHEMENT}',
        attachement: {
          class: '${ExportClass.ATTACHEMENT}'
        }
      }
    """

    when:
    AttachementMarchaller.parsePrincipalAttachement(
        JSON.parse(json),
        attachementDataStore
    )

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'attachement.nom'
  }

  def "testParsePrincipalAttachement - erreur attachement.nomFichierOriginal manquant"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    String json = """
      {
        class: '${ExportClass.PRINCIPAL_ATTACHEMENT}',
        attachement: {
          class: '${ExportClass.ATTACHEMENT}',
          nom: 'nom'
        }
      }
    """

    when:
    AttachementMarchaller.parsePrincipalAttachement(
        JSON.parse(json),
        attachementDataStore
    )

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'attachement.nomFichierOriginal'
  }

  def "testParsePrincipalAttachement - erreur attachement.typeMime manquant"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    String json = """
      {
        class: '${ExportClass.PRINCIPAL_ATTACHEMENT}',
        attachement: {
          class: '${ExportClass.ATTACHEMENT}',
          nom: 'nom',
          nomFichierOriginal: 'nomFichierOriginal'
        }
      }
    """

    when:
    AttachementMarchaller.parsePrincipalAttachement(
        JSON.parse(json),
        attachementDataStore
    )

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'attachement.typeMime'
  }

  def "testParsePrincipalAttachement - erreur attachement.chemin manquant"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    String json = """
      {
        class: '${ExportClass.PRINCIPAL_ATTACHEMENT}',
        attachement: {
          class: '${ExportClass.ATTACHEMENT}',
          nom: 'nom',
          nomFichierOriginal: 'nomFichierOriginal',
          typeMime: 'typeMime',
        }
      }
    """

    when:
    AttachementMarchaller.parsePrincipalAttachement(
        JSON.parse(json),
        attachementDataStore
    )

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'attachement.chemin'
  }

  def "testParsePrincipalAttachement - JSONObject.Null"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    expect:
    AttachementMarchaller.parsePrincipalAttachement(
        new JSONObject.Null(),
        attachementDataStore
    ) == null
  }

  def "testParseQuestionAttachements - cas général"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    attachementDataStore.addAttachementFromJson('chemin1', 'blob1')
    attachementDataStore.addAttachementFromJson('chemin2', 'blob2')

    String json = """
      [
        {
          class: '${ExportClass.QUESTION_ATTACHEMENT}',
          id: 1,
          attachement: {
            class: '${ExportClass.ATTACHEMENT}',
            nom: 'nom1',
            nomFichierOriginal: 'nomFichierOriginal1',
            typeMime: 'typeMime1',
            chemin: 'chemin1',
            estInsereDansLaQuestion:  true
          }
        },
        {
          class: '${ExportClass.QUESTION_ATTACHEMENT}',
          id: 2,
          attachement: {
            class: '${ExportClass.ATTACHEMENT}',
            nom: 'nom2',
            nomFichierOriginal: 'nomFichierOriginal2',
            typeMime: 'typeMime2',
            chemin: 'chemin2',
            estInsereDansLaQuestion:  false
          }
        }
      ]
    """

    List<QuestionAttachementDto> questionAttachementsDto =
      AttachementMarchaller.parseAllQuestionAttachement(
          (JSONArray)JSON.parse(json),
          attachementDataStore
      )

    expect:
    questionAttachementsDto.size() == 2
    questionAttachementsDto[0].id == 1
    questionAttachementsDto[0].attachement.nom == 'nom1'
    questionAttachementsDto[0].attachement.nomFichierOriginal == 'nomFichierOriginal1'
    questionAttachementsDto[0].attachement.typeMime == 'typeMime1'
    questionAttachementsDto[0].attachement.blob == 'blob1'
    questionAttachementsDto[0].attachement.estInsereDansLaQuestion

    questionAttachementsDto[1].id == 2
    questionAttachementsDto[1].attachement.nom == 'nom2'
    questionAttachementsDto[1].attachement.nomFichierOriginal == 'nomFichierOriginal2'
    questionAttachementsDto[1].attachement.typeMime == 'typeMime2'
    questionAttachementsDto[1].attachement.blob == 'blob2'
    !questionAttachementsDto[1].attachement.estInsereDansLaQuestion
  }

}
