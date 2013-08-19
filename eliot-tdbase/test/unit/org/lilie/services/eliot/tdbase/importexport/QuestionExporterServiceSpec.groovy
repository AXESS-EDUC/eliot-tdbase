package org.lilie.services.eliot.tdbase.importexport

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tice.annuaire.Personne
import spock.lang.Specification

/**
 * @author John Tranier
 */
class QuestionExporterServiceSpec extends Specification {
  QuestionService questionService
  QuestionExporterService questionExporterService

  def setup() {
    questionService = Mock(QuestionService)
    questionExporterService = new QuestionExporterService(
        questionService: questionService
    )
  }

  def "testGetQuestionPourExport - question atomique OK"() {
    Question question = new Question()
    Personne exporteur = new Personne()

    when:
    Question questionPourExport = questionExporterService.getQuestionPourExport(question, exporteur)

    then:
    1 * questionService.marquePaternite(question, exporteur)

    then:
    questionPourExport == question
  }

  def "testGetQuestionPourExport - question composite OK"() {
    Question question = new Question(exercice: new Sujet())
    Personne exporteur = new Personne()

    expect:
    questionExporterService.getQuestionPourExport(question, exporteur) == question
  }

  // TODO tester le cas d'une question inexistante
}
