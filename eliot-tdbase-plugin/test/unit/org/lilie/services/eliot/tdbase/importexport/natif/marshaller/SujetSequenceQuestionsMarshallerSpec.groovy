package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.SujetSequenceQuestions
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAtomiqueDto
import org.lilie.services.eliot.tdbase.importexport.dto.SujetSequenceQuestionsDto
import spock.lang.Specification

/**
 * @author John Tranier
 */
class SujetSequenceQuestionsMarshallerSpec extends Specification {

  def "testMarshall - cas général"(Float noteSeuilPoursuite) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
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
    1 * questionMarshaller.marshall(question, attachementDataStore) >> questionRepresentation

    SujetSequenceQuestionsMarshaller sujetSequenceQuestionsMarshaller = new SujetSequenceQuestionsMarshaller(
        questionMarshaller: questionMarshaller
    )

    when:
    Map representation = sujetSequenceQuestionsMarshaller.marshall(
        sujetSequenceQuestions,
        attachementDataStore
    )

    then:
    representation.size() == 5
    representation.class == ExportClass.SUJET_SEQUENCE_QUESTIONS.name()
    representation.rang == rang
    representation.noteSeuilPoursuite == noteSeuilPoursuite
    representation.points == points
    representation.question == questionRepresentation

    where:
    noteSeuilPoursuite << [null, 2.0]
  }

  def "testMarshall - argument null"() {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    SujetSequenceQuestionsMarshaller sujetSequenceQuestionsMarshaller = new SujetSequenceQuestionsMarshaller()

    when:
    sujetSequenceQuestionsMarshaller.marshall(null, attachementDataStore)

    then:
    def e = thrown(IllegalArgumentException)
    e.message == "sujetSequenceQuestions ne peut pas être null"
  }

  def "testParse - cas général"(Float noteSeuilPoursuite) {
    given:
    AttachementDataStore attachementDataStore = new AttachementDataStore()
    int rang = 2
    Float points = 2.0
    QuestionAtomiqueDto questionDto = new QuestionAtomiqueDto()

    QuestionMarshaller.metaClass.static.parse = { JSONElement jsonElement, AttachementDataStore attachementDataStore2 ->
      return questionDto
    }

    String json = """
    {
      class: '${ExportClass.SUJET_SEQUENCE_QUESTIONS}',
      rang: $rang,
      noteSeuilPoursuite: $noteSeuilPoursuite,
      points: $points,
      question: {}
    }
    """

    SujetSequenceQuestionsDto sequenceQuestionsDto = SujetSequenceQuestionsMarshaller.parse(
        JSON.parse(json),
        attachementDataStore
    )

    expect:
    sequenceQuestionsDto.referentielSujetSequenceQuestions.rang == rang
    sequenceQuestionsDto.referentielSujetSequenceQuestions.noteSeuilPoursuite == noteSeuilPoursuite
    sequenceQuestionsDto.referentielSujetSequenceQuestions.points == points
    sequenceQuestionsDto.question == questionDto

    cleanup:
    QuestionMarshaller.metaClass = null

    where:
    noteSeuilPoursuite << [null, 10.0]
  }
}
