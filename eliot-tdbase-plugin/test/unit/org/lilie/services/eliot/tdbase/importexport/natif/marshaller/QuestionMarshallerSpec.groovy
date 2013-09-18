package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionType
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.importexport.dto.AttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.CopyrightsTypeDto
import org.lilie.services.eliot.tdbase.importexport.dto.EtablissementDto
import org.lilie.services.eliot.tdbase.importexport.dto.MatiereDto
import org.lilie.services.eliot.tdbase.importexport.dto.NiveauDto
import org.lilie.services.eliot.tdbase.importexport.dto.PersonneDto
import org.lilie.services.eliot.tdbase.importexport.dto.PrincipalAttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAtomiqueDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionCompositeDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionDto
import spock.lang.Specification

/**
 * @author John Tranier
 */
class QuestionMarshallerSpec extends Specification {

  PersonneMarshaller personneMarshaller
  EtablissementMarshaller etablissementMarshaller
  MatiereMarshaller matiereMarshaller
  NiveauMarshaller niveauMarshaller
  CopyrightsTypeMarshaller copyrightsTypeMarshaller
  AttachementMarchaller attachementMarchaller
  QuestionCompositeMarshaller questionCompositeMarshaller

  QuestionMarshaller questionMarshaller

  def setup() {
    personneMarshaller = Mock(PersonneMarshaller)
    etablissementMarshaller = Mock(EtablissementMarshaller)
    matiereMarshaller = Mock(MatiereMarshaller)
    niveauMarshaller = Mock(NiveauMarshaller)
    copyrightsTypeMarshaller = Mock(CopyrightsTypeMarshaller)
    attachementMarchaller = Mock(AttachementMarchaller)
    questionCompositeMarshaller = Mock(QuestionCompositeMarshaller)

    questionMarshaller = new QuestionMarshaller(
        personneMarshaller: personneMarshaller,
        etablissementMarshaller: etablissementMarshaller,
        matiereMarshaller: matiereMarshaller,
        niveauMarshaller: niveauMarshaller,
        copyrightsTypeMarshaller: copyrightsTypeMarshaller,
        attachementMarchaller: attachementMarchaller,
        questionCompositeMarshaller: questionCompositeMarshaller
    )
  }

  def "testMarshall - question atomique OK"(String paternite) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    Question question = new Question(
        id: 100,
        type: new QuestionType(code: "code"),
        titre: "titre",
        dateCreated: new Date() - 1,
        lastUpdated: new Date(),
        versionQuestion: 10,
        estAutonome: true,
        paternite: paternite,
        specification: "{json: 'specification'}"
    )

    Map personneRepresentation = [map: 'personne']
    Map etablissementRepresentation = [map: 'etablissement']
    Map matiereRepresentation = [map: 'matiere']
    Map niveauRepresentation = [map: 'niveau']
    Map copyrightsTypeRepresentation = [map: 'copyrightsType']
    Map principalAttachementRepresentation = [map: 'principalAttachement']
    List questionAttachementsRepresentation = [[map: 'attachement']]

    personneMarshaller.marshall(_) >> personneRepresentation
    etablissementMarshaller.marshall(_) >> etablissementRepresentation
    matiereMarshaller.marshall(_) >> matiereRepresentation
    niveauMarshaller.marshall(_) >> niveauRepresentation
    copyrightsTypeMarshaller.marshall(_) >> copyrightsTypeRepresentation
    attachementMarchaller.marshallPrincipalAttachement(_, _, attachementDataStore) >> principalAttachementRepresentation
    attachementMarchaller.marshallQuestionAttachements(_, attachementDataStore) >> questionAttachementsRepresentation

    Map questionRepresentation = questionMarshaller.marshall(question, attachementDataStore)

    expect:
    questionRepresentation.size() == 8
    questionRepresentation.class == ExportClass.QUESTION_ATOMIQUE.name()
    questionRepresentation.type == question.type.code
    questionRepresentation.titre == question.titre
    questionRepresentation.id == question.id.toString()

    questionRepresentation.metadonnees.size() == 8
    questionRepresentation.metadonnees.dateCreated == question.dateCreated
    questionRepresentation.metadonnees.lastUpdated == question.lastUpdated
    questionRepresentation.metadonnees.versionQuestion == question.versionQuestion
    questionRepresentation.metadonnees.estAutonome == question.estAutonome
    questionRepresentation.metadonnees.copyrightsType == copyrightsTypeRepresentation
    question.paternite ?
      questionRepresentation.metadonnees.paternite == JSON.parse(question.paternite) :
      questionRepresentation.metadonnees.paternite == null

    questionRepresentation.metadonnees.referentielEliot.etablissement == etablissementRepresentation
    questionRepresentation.metadonnees.referentielEliot.matiere == matiereRepresentation
    questionRepresentation.metadonnees.referentielEliot.niveau == niveauRepresentation

    question.specification ?
      questionRepresentation.specification == JSON.parse(question.specification) :
      questionRepresentation.specification == null

    questionRepresentation.principalAttachement == principalAttachementRepresentation
    questionRepresentation.questionAttachements == questionAttachementsRepresentation

    where:
    paternite << [null, "", "{json: 'paternite'}"]
  }

  def "testMarshall – question composite OK"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    Question questionComposite = new Question(
        exercice: new Sujet()
    )
    Map questionCompositeRepresentation = [map: 'questionComposite']

    when:
    Map resultat = questionMarshaller.marshall(questionComposite, attachementDataStore)

    then:
    1 * questionCompositeMarshaller.marshall(
        questionComposite,
        attachementDataStore
    ) >> questionCompositeRepresentation

    then:
    resultat == questionCompositeRepresentation

  }

  def "testMarshall - argument null"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    QuestionMarshaller questionMarshaller = new QuestionMarshaller()

    when:
    questionMarshaller.marshall(null, attachementDataStore)

    then:
    thrown(IllegalArgumentException)
  }

  def "testParse - question atomique OK"(Date dateCreated,
                                         Date lastUpdated,
                                         Boolean estAutonome,
                                         String paternite,
                                         CopyrightsTypeDto copyrightsType,
                                         EtablissementDto etablissement,
                                         MatiereDto matiere,
                                         NiveauDto niveau,
                                         PrincipalAttachementDto principalAttachement,
                                         List<QuestionAttachementDto> questionAttachements) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    String type = 'type'
    String titre = 'titre'
    PersonneDto proprietaire = new PersonneDto()
    int versionQuestion = 1
    String specification = 'specification'

    PersonneMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      return proprietaire
    }

    CopyrightsTypeMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      return copyrightsType
    }

    EtablissementMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      return etablissement
    }

    MatiereMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      return matiere
    }

    NiveauMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      return niveau
    }

    AttachementMarchaller.metaClass.static.parsePrincipalAttachement = {
      JSONElement jsonElement, AttachementDataStore attachementDataStore2 ->
      return principalAttachement
    }
    AttachementMarchaller.metaClass.static.parseAllQuestionAttachement = {
      JSONArray jsonArray, AttachementDataStore attachementDataStore2 ->
      return questionAttachements
    }

    String json = """
      {
        class: '${ExportClass.QUESTION_ATOMIQUE}',
        type: '$type',
        titre: '$titre',
        metadonnees: {
          proprietaire: {mock: 'proprietaire'},
          dateCreated: ${dateCreated ? "'" + MarshallerHelper.ISO_DATE_FORMAT.format(dateCreated) + "'" : null},
          lastUpdated: ${lastUpdated ? "'" + MarshallerHelper.ISO_DATE_FORMAT.format(lastUpdated) + "'" : null},
          versionQuestion: $versionQuestion,
          estAutonome: $estAutonome,
          paternite: ${MarshallerHelper.asJsonString(paternite)},
          copyrightsType: {mock: 'copyrightsType'},
          referentielEliot: {
            etablissement: {mock: 'etablissement'},
            matiere: {mock: 'matiere'},
            niveau: {mock: 'niveau'}
          }
        },
        specification: '$specification',
        principalAttachement: {mock: 'principalAttachement'},
        questionAttachements: [{mock: 'attachement'}]
      }
    """

    QuestionDto questionDto = QuestionMarshaller.parse(
        JSON.parse(json),
        attachementDataStore
    )

    expect:
    questionDto instanceof QuestionAtomiqueDto
    questionDto.type == type
    questionDto.titre == titre
    questionDto.proprietaire == proprietaire
    questionDto.dateCreated == dateCreated
    questionDto.lastUpdated == lastUpdated
    questionDto.versionQuestion == versionQuestion
    questionDto.paternite == paternite
    questionDto.copyrightsType == copyrightsType
    questionDto.etablissement == etablissement
    questionDto.matiere == matiere
    questionDto.niveau == niveau
    questionDto.specification == specification
    questionDto.principalAttachement == principalAttachement
    questionDto.questionAttachements == questionAttachements

    cleanup:
    PersonneMarshaller.metaClass = null
    CopyrightsTypeMarshaller.metaClass = null
    EtablissementMarshaller.metaClass = null
    MatiereMarshaller.metaClass = null
    NiveauMarshaller.metaClass = null
    AttachementMarchaller.metaClass = null

    where:
    dateCreated << [MarshallerHelper.normaliseDate(new Date()) - 1, null]
    lastUpdated << [MarshallerHelper.normaliseDate(new Date()), null]
    estAutonome << [true, null]
    paternite << [null, "{json: paternite}"]
    copyrightsType = new CopyrightsTypeDto()
    etablissement << [null, new EtablissementDto()]
    matiere << [null, new MatiereDto()]
    niveau << [null, new NiveauDto()]
    principalAttachement << [null, new PrincipalAttachementDto()]
    questionAttachements << [
        [],
        [new QuestionAttachementDto(), new QuestionAttachementDto()]
    ]
  }

  def "testParse - question composite OK"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    QuestionCompositeDto questionCompositeDto = new QuestionCompositeDto()

    QuestionCompositeMarshaller.metaClass.static.parse = {
      JSONElement jsonElement, AttachementDataStore attachementDataStore2 ->
      return questionCompositeDto
    }

    String json = """
    {
      class: '${ExportClass.QUESTION_COMPOSITE}',
      type: '${QuestionTypeEnum.Composite.name()}'
    }
    """

    expect:
    QuestionMarshaller.parse(JSON.parse(json), attachementDataStore) ==
        QuestionCompositeMarshaller.parse(JSON.parse(json), attachementDataStore)

    cleanup:
    QuestionCompositeMarshaller.metaClass = null
  }

  def "testParse - erreur type null"(String json) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement, attachementDataStore)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'type'

    where:
    json << [
        "{class: '${ExportClass.QUESTION_ATOMIQUE}'}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: null}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}',type: ''}"
    ]
  }

  def "testParse - erreur titre null"(String json) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement, attachementDataStore)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'titre'

    where:
    json << [
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type'}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: null}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: ''}"
    ]
  }

  def "testParse - erreur metadonnees absentes"(String json) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement, attachementDataStore)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'metadonnees'

    where:
    json << [
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre'}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: 'simple chaine'}"
    ]
  }

  def "testParse - erreur proprietaire incorrect"(String json) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement, attachementDataStore)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'metadonnees.proprietaire'

    where:
    json << [
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {}}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: null}}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: 'simple chaine'}}"
    ]
  }

  def "testParse - erreur copyrightsType incorrect"(String json) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement, attachementDataStore)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'metadonnees.copyrightsType'

    where:
    json << [
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: {}}}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: null}}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: ''}}"
    ]
  }

  def "testParse - erreur specification absente"(String json) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement, attachementDataStore)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'specification'

    where:
    json << [
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: null}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: ''}"
    ]
  }

  def "testParse - erreur principalAttachement incorrect"(String json) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement, attachementDataStore)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'principalAttachement'

    where:
    json << [
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: 'specification'}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: 'specification', principalAttachement: ''}"
    ]
  }

  def "testParse - erreur questionAttachements incorrect"(String json) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement, attachementDataStore)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'questionAttachements'

    where:
    json << [
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: 'specification', principalAttachement: {}}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: 'specification', principalAttachement: {}, questionAttachements: null}",
        "{class: '${ExportClass.QUESTION_ATOMIQUE}', type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: 'specification', principalAttachement: {}, questionAttachements: {}}"
    ]
  }

}
