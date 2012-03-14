package org.lilie.services.eliot.tdbase.xml

import groovy.json.JsonSlurper
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetSequenceQuestions
import org.lilie.services.eliot.tdbase.QuestionType

/**
 * Created by IntelliJ IDEA.
 * User: bert
 * Date: 08/03/12
 * Time: 14:54
 * To change this template use File | Settings | File Templates.
 */
class MoodleQuizExporterServiceIntegrationTest extends GroovyTestCase {

  /**
   * The path of the question json file relative to the location of this class.
   */
  static final QUESTIONS = 'exemples/questions.json'

  MoodleQuizExporterService moodleQuizExporterService
  QuestionService questionService

  void testIntegrationExport() {
    List<Map> questionSpecs = new JsonSlurper().parseText(getQuestionsJson())

    def questionSequences = questionSpecs.collect {
      def type = QuestionType.findByCode(it['questionTypeCode'])
      def question = new Question(specification: it, type: type)
      new SujetSequenceQuestions(question: question)
    }

    Sujet sujet = new Sujet(questionsSequences: questionSequences)

    println moodleQuizExporterService.toMoodleQuiz(sujet)
  }

  /**
   * Loads the contents of the question json file.
   */
  private String getQuestionsJson() {
    def stream = getClass().getResourceAsStream(QUESTIONS)
    stream?.text
  }
}
