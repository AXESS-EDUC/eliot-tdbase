package org.lilie.services.eliot.tdbase.importexport

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tice.annuaire.Personne
import spock.lang.Specification

/**
 * @author John Tranier
 */
class QuestionExporterServiceSpec extends Specification {
  QuestionService questionService
  SujetService sujetService
  QuestionExporterService questionExporterService

  def setup() {
    questionService = Mock(QuestionService)
    sujetService = Mock(SujetService)
    questionExporterService = new QuestionExporterService(
        questionService: questionService,
        sujetService: sujetService
    )
  }

  def "testGetQuestionPourExport - question atomique OK"() {
    given:
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
    given:
    Question question = new Question(exercice: new Sujet())
    Personne exporteur = new Personne()

    when:
    Question questionPourExport = questionExporterService.getQuestionPourExport(question, exporteur)

      then:
    1 * sujetService.marquePaternite(question.exercice, exporteur)

    then:
    questionPourExport == question
  }
}
