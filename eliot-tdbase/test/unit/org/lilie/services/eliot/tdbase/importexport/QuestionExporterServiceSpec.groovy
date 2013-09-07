package org.lilie.services.eliot.tdbase.importexport

import org.lilie.services.eliot.tdbase.ArtefactAutorisationService
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tice.annuaire.Personne
import spock.lang.Specification

/**
 * @author John Tranier
 */
class QuestionExporterServiceSpec extends Specification {
  QuestionService questionService
  QuestionExporterService questionExporterService
  ArtefactAutorisationService artefactAutorisationService

  def setup() {
    questionService = Mock(QuestionService)
    artefactAutorisationService = Mock(ArtefactAutorisationService)
    questionExporterService = new QuestionExporterService(
        questionService: questionService,
        artefactAutorisationService: artefactAutorisationService
    )
  }

  def "testGetQuestionPourExport - OK"() {
    given:
    Question question = new Question()
    Personne exporteur = new Personne()

    when:
    Question questionPourExport = questionExporterService.getQuestionPourExport(question, exporteur)

    then:
    1 * artefactAutorisationService.utilisateurPeutReutiliserArtefact(exporteur, question) >> true

    then:
    questionPourExport == question
  }

  def "testGetQuestionPourExport - erreur : artefact non réutilisable par l'utilisateur"() {
    given:
    Question question = new Question()
    Personne exporteur = new Personne()

    when:
    questionExporterService.getQuestionPourExport(question, exporteur)

    then:
    1 * artefactAutorisationService.utilisateurPeutReutiliserArtefact(exporteur, question) >> false

    then:
    thrown(Error)
  }

}
