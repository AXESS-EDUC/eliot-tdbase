package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionType
import org.lilie.services.eliot.tdbase.importexport.dto.AttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.CopyrightsTypeDto
import org.lilie.services.eliot.tdbase.importexport.dto.EtablissementDto
import org.lilie.services.eliot.tdbase.importexport.dto.MatiereDto
import org.lilie.services.eliot.tdbase.importexport.dto.NiveauDto
import org.lilie.services.eliot.tdbase.importexport.dto.PersonneDto
import org.lilie.services.eliot.tdbase.importexport.dto.PrincipalAttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionDto
import spock.lang.Specification

/**
 * @author John Tranier
 */
class QuestionMarshallerSpec extends Specification {

  def "testMashall - cas général"(String paternite) {
    given:
    Question question = new Question(
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

  def "testMarshall - argument null"() {
    setup:
    QuestionMarshaller questionMarshaller = new QuestionMarshaller()

    when:
    questionMarshaller.marshall(null)

    then:
    thrown(IllegalArgumentException)
  }

  def "testParse - cas général"(String type,
                                String titre,
                                PersonneDto proprietaire,
                                Date dateCreated,
                                Date lastUpdated,
                                int versionQuestion,
                                Boolean estAutonome,
                                String paternite,
                                CopyrightsTypeDto copyrightsType,
                                EtablissementDto etablissement,
                                MatiereDto matiere,
                                NiveauDto niveau,
                                String specification,
                                PrincipalAttachementDto principalAttachement,
                                List<AttachementDto> questionAttachements) {
    given:
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

    AttachementMarchaller.metaClass.static.parsePrincipalAttachement = { JSONElement jsonElement ->
      return principalAttachement
    }
    AttachementMarchaller.metaClass.static.parseQuestionAttachements = { JSONArray jsonArray ->
      return questionAttachements
    }

    String json = """
      {
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
        JSON.parse(json)
    )

    expect:
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
    type = 'type'
    titre = 'titre'
    proprietaire = new PersonneDto()
    dateCreated << [normaliseDate(new Date()) - 1, null]
    lastUpdated << [normaliseDate(new Date()), null]
    versionQuestion = 1
    estAutonome << [true, null]
    paternite << [null, "{json: paternite}"]
    copyrightsType = new CopyrightsTypeDto()
    etablissement << [null, new EtablissementDto()]
    matiere << [null, new MatiereDto()]
    niveau << [null, new NiveauDto()]
    specification = 'specification'
    principalAttachement << [null, new PrincipalAttachementDto()]
    questionAttachements << [
        [],
        [new AttachementDto(), new AttachementDto()]
    ]
  }

  private static Date normaliseDate(Date date) {
    return MarshallerHelper.ISO_DATE_FORMAT.parse(
        MarshallerHelper.ISO_DATE_FORMAT.format(date)
    )
  }

  def "testParse - erreur type null"(String json) {
    given:
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'type'

    where:
    json << [
        "{}",
        "{type: null}",
        "{type: ''}"
    ]
  }

  def "testParse - erreur titre null"(String json) {
    given:
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'titre'

    where:
    json << [
        "{type: 'type'}",
        "{type: 'type', titre: null}",
        "{type: 'type', titre: ''}"
    ]
  }

  def "testParse - erreur metadonnees absentes"(String json) {
    given:
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'metadonnees'

    where:
    json << [
        "{type: 'type', titre: 'titre'}",
        "{type: 'type', titre: 'titre', metadonnees: 'simple chaine'}"
    ]
  }

  def "testParse - erreur proprietaire incorrect"(String json) {
    given:
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'metadonnees.proprietaire'

    where:
    json << [
        "{type: 'type', titre: 'titre', metadonnees: {}}",
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: null}}",
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: 'simple chaine'}}"
    ]
  }

  def "testParse - erreur copyrightsType incorrect"(String json) {
    given:
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'metadonnees.copyrightsType'

    where:
    json << [
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: {}}}",
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: null}}",
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: ''}}"
    ]
  }

  def "testParse - erreur specification absente"(String json) {
    given:
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'specification'

    where:
    json << [
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}}",
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: null}",
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: ''}"
    ]
  }

  def "testParse - erreur principalAttachement incorrect"(String json) {
    given:
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'principalAttachement'

    where:
    json << [
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: 'specification'}",
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: 'specification', principalAttachement: ''}"
    ]
  }

  def "testParse - erreur questionAttachements incorrect"(String json) {
    given:
    JSONElement jsonElement = JSON.parse(json)

    when:
    QuestionMarshaller.parse(jsonElement)

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'questionAttachements'

    where:
    json << [
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: 'specification', principalAttachement: {}}",
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: 'specification', principalAttachement: {}, questionAttachements: null}",
        "{type: 'type', titre: 'titre', metadonnees: {proprietaire: {}, copyrightsType: {}}, specification: 'specification', principalAttachement: {}, questionAttachements: {}}"
    ]
  }
}
