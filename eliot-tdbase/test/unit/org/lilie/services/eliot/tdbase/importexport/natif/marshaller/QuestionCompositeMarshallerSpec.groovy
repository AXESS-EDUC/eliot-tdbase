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
    Question question = new Question(
        exercice: null
    )

    when:
    questionCompositeMarshaller.marshall(question)

    then:
    def e = thrown(IllegalArgumentException)
    e.message == "$question n'est pas une question de type Composite"
  }

  def "testMarshall - OK"() {
    given:
    Sujet exercice = new Sujet()
    Question question = new Question(
        type: new QuestionType(
            code: QuestionTypeEnum.Composite.name()
        ),
        exercice: exercice
    )

    Map exerciceRepresentation = [map: 'exercice']

    sujetMarshaller.marshall(exercice) >> exerciceRepresentation

    Map questionCompositeRepresentation = questionCompositeMarshaller.marshall(question)

    expect:
    questionCompositeRepresentation.size() == 3
    questionCompositeRepresentation.class == ExportClass.QUESTION_COMPOSITE.name()
    questionCompositeRepresentation.type == QuestionTypeEnum.Composite.name()
    questionCompositeRepresentation.exercice == exerciceRepresentation
  }

  def "testParse - Erreur : ne correspond pas à une question composite"() {
    given:
    String json = """
    {
      class: '${ExportClass.QUESTION_COMPOSITE}',
      type: 'incorrect'
    }
    """

    when:
    QuestionCompositeMarshaller.parse(JSON.parse(json))

    then:
    def e = thrown(MarshallerException)
    e.attribut == 'type'
    e.message == "Le type de la question n'est pas Composite"
  }

  def "testParse - Erreur : exercice manquant"() {
    given:
    String json = """
    {
      class: '${ExportClass.QUESTION_COMPOSITE}',
      type: '${QuestionTypeEnum.Composite.name()}'
    }
    """

    when:
    QuestionCompositeMarshaller.parse(JSON.parse(json))

    then:
    def e = thrown(MarshallerException)
    e.attribut == 'exercice'
  }

  def "testParse - OK"() {
    given:
    String json = """
    {
      class: '${ExportClass.QUESTION_COMPOSITE}',
      type: '${QuestionTypeEnum.Composite.name()}',
      exercice: {}
    }
    """
    // TODO Supprimer l'attribut type qui est inutile

    SujetDto exerciceDto = new SujetDto()
    SujetMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      return exerciceDto
    }

    QuestionCompositeDto questionCompositeDto = QuestionCompositeMarshaller.parse(
        JSON.parse(json)
    )

    expect:
    questionCompositeDto.exercice == exerciceDto

    cleanup:
    SujetMarshaller.metaClass = null
  }
}
