package org.lilie.services.eliot.tdbase.importexport

import org.lilie.services.eliot.tdbase.Artefact
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.Sujet
import spock.lang.Specification

/**
 * @author John Tranier
 */
class ExportHelperSpec extends Specification {

  def "testGetFileName - erreur: format non implémenté"() {
    Artefact artefact = new Sujet()

    when:
    ExportHelper.getFileName(artefact, Format.MOODLE_XML)

    then:
    def e = thrown(IllegalStateException)
    e.message == "Non implémenté"
  }

  def "testGetFileName - erreur: classe d'Artefact non implémenté"() {
    Artefact artefact = Mock(Artefact)

    when:
    ExportHelper.getFileName(artefact, Format.NATIF_JSON)

    then:
    def e = thrown(IllegalStateException)
    e.message == "Non implémenté"
  }

  def "testGetFileName - erreur: artefact null"() {
    when:
    ExportHelper.getFileName(null, Format.NATIF_JSON)

    then:
    def e = thrown(IllegalArgumentException)
    e.message == "artefact ne peut pas être null"
  }

  def "testGetFileName - erreur: format null"() {
    when:
    ExportHelper.getFileName(Mock(Artefact), null)

    then:
    def e = thrown(IllegalArgumentException)
    e.message == "format ne peut pas être null"
  }

  def "testGetFileName - OK"(Artefact artefact) {
    given:
    String fileName = ExportHelper.getFileName(artefact, Format.NATIF_JSON)

    expect:
    fileName.endsWith('.tdbase')
    if(artefact instanceof Sujet) {
      fileName.startsWith(ExportHelper.TYPE_SUJET)
    }
    else if(artefact instanceof Question) {
      fileName.startsWith(ExportHelper.TYPE_QUESTION)
    }


    where:
    artefact << [
        new Sujet(titreNormalise: 'sujet-titreNormalise'),
        new Question(titreNormalise: 'question-titreNormalise')
    ]
  }
}
