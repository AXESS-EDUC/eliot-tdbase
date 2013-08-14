package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.SujetSequenceQuestions
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionDto
import org.lilie.services.eliot.tdbase.importexport.dto.SujetSequenceQuestionsDto
import spock.lang.Specification

/**
 * @author John Tranier
 */
class SujetSequenceQuestionsMarshallerSpec extends Specification {

  def "testMarshall - cas général"(Float noteSeuilPoursuite) {
    given:
    int rang = 3
    Float points = 5.0
    Question question = new Question()

    SujetSequenceQuestions sujetSequenceQuestions = new SujetSequenceQuestions(
        rang: rang,
        noteSeuilPoursuite: noteSeuilPoursuite,
        points: points,
        question: question
    )

    Map questionRepresentation = [map: 'question']

    QuestionMarshaller questionMarshaller = Mock(QuestionMarshaller)
    1 * questionMarshaller.marshall(question) >> questionRepresentation

    SujetSequenceQuestionsMarshaller sujetSequenceQuestionsMarshaller = new SujetSequenceQuestionsMarshaller(
        questionMarshaller: questionMarshaller
    )

    when:
    Map representation = sujetSequenceQuestionsMarshaller.marshall(sujetSequenceQuestions)

    then:
    representation.size() == 4
    representation.rang == rang
    representation.noteSeuilPoursuite == noteSeuilPoursuite
    representation.points == points
    representation.question == questionRepresentation

    where:
    noteSeuilPoursuite << [null, 2.0]
  }

  def "testMarshall - argument null"() {
    given:
    SujetSequenceQuestionsMarshaller sujetSequenceQuestionsMarshaller = new SujetSequenceQuestionsMarshaller()

    when:
    sujetSequenceQuestionsMarshaller.marshall(null)

    then:
    def e = thrown(IllegalArgumentException)
    e.message == "sujetSequenceQuestions ne peut pas être null"
  }

  def "testParse - cas général"(Float noteSeuilPoursuite) {
    given:
    int rang = 2
    Float points = 2.0
    QuestionDto questionDto = new QuestionDto()

    QuestionMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      return questionDto
    }

    String json = """
    {
      rang: $rang,
      noteSeuilPoursuite: $noteSeuilPoursuite,
      points: $points,
      question: {}
    }
    """

    SujetSequenceQuestionsDto sequenceQuestionsDto = SujetSequenceQuestionsMarshaller.parse(JSON.parse(json))

    expect:
    sequenceQuestionsDto.rang == rang
    sequenceQuestionsDto.noteSeuilPoursuite == noteSeuilPoursuite
    sequenceQuestionsDto.points == points
    sequenceQuestionsDto.question == questionDto

    cleanup:
    QuestionMarshaller.metaClass = null

    where:
    noteSeuilPoursuite << [null, 10.0]
  }
}
