package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionType
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionCompositeDto
import org.lilie.services.eliot.tdbase.importexport.dto.SujetDto
import spock.lang.Specification

/**
 * @author John Tranier
 */
class QuestionCompositeMarshallerSpec extends Specification {
  SujetMarshaller sujetMarshaller
  QuestionCompositeMarshaller questionCompositeMarshaller

  def setup() {
    sujetMarshaller = Mock(SujetMarshaller)
    questionCompositeMarshaller = new QuestionCompositeMarshaller(
        sujetMarshaller: sujetMarshaller
    )
  }

  def "testMarshall - erreur : la question n'est pas composite"(){
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    Question question = new Question(
        exercice: null
    )

    when:
    questionCompositeMarshaller.marshall(question, attachementDataStore)

    then:
    def e = thrown(IllegalArgumentException)
    e.message == "$question n'est pas une question de type Composite"
  }

  def "testMarshall - OK"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    Sujet exercice = new Sujet()
    Question question = new Question(
        type: new QuestionType(
            code: QuestionTypeEnum.Composite.name()
        ),
        id: 123,
        exercice: exercice
    )

    Map exerciceRepresentation = [map: 'exercice']

    sujetMarshaller.marshall(exercice, attachementDataStore) >> exerciceRepresentation

    Map questionCompositeRepresentation = questionCompositeMarshaller.marshall(
        question,
        attachementDataStore
    )

    expect:
    questionCompositeRepresentation.size() == 3
    questionCompositeRepresentation.class == ExportClass.QUESTION_COMPOSITE.name()
    questionCompositeRepresentation.exercice == exerciceRepresentation
    questionCompositeRepresentation.id == question.id.toString()
  }

  def "testParse - Erreur : exercice manquant"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    String json = """
    {
      class: '${ExportClass.QUESTION_COMPOSITE}'
    }
    """

    when:
    QuestionCompositeMarshaller.parse(JSON.parse(json), attachementDataStore)

    then:
    def e = thrown(MarshallerException)
    e.attribut == 'exercice'
  }

  def "testParse - OK"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    String json = """
    {
      class: '${ExportClass.QUESTION_COMPOSITE}',
      exercice: {}
    }
    """

    SujetDto exerciceDto = new SujetDto()
    SujetMarshaller.metaClass.static.parse = { JSONElement jsonElement, AttachementDataStore attachementDataStore2 ->
      return exerciceDto
    }

    QuestionCompositeDto questionCompositeDto = QuestionCompositeMarshaller.parse(
        JSON.parse(json),
        attachementDataStore
    )

    expect:
    questionCompositeDto.exercice == exerciceDto

    cleanup:
    SujetMarshaller.metaClass = null
  }
}
