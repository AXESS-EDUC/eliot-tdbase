package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.importexport.dto.ExportDto
import org.lilie.services.eliot.tdbase.importexport.dto.PersonneDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionDto
import org.lilie.services.eliot.tdbase.importexport.dto.SujetDto
import org.lilie.services.eliot.tice.annuaire.Personne
import spock.lang.Specification

/**
 * @author John Tranier
 */
class ExportMarshallerSpec extends Specification {

  SujetMarshaller sujetMarshaller
  QuestionMarshaller questionMarshaller
  PersonneMarshaller personneMarshaller
  ExportMarshaller exportMarshaller

  def setup() {
    sujetMarshaller = Mock(SujetMarshaller)
    questionMarshaller = Mock(QuestionMarshaller)
    personneMarshaller = Mock(PersonneMarshaller)
    exportMarshaller = new ExportMarshaller(
        sujetMarshaller: sujetMarshaller,
        questionMarshaller: questionMarshaller,
        personneMarshaller: personneMarshaller
    )
  }

  def "testMarshall - sujet OK"() {
    given:
    Sujet sujet = new Sujet()
    Date date = new Date()
    Personne exporteur = new Personne()
    String formatVersion = "1.0"

    Map sujetRepresentation = [map: 'sujet']
    sujetMarshaller.marshall(sujet) >> sujetRepresentation

    Map exporteurRepresentation = [map: 'personne']
    personneMarshaller.marshall(exporteur) >> exporteurRepresentation

    Map exportRepresentation = exportMarshaller.marshall(
        sujet,
        date,
        exporteur,
        formatVersion
    )

    expect:
    exportRepresentation.class == ExportClass.EXPORT.name()
    exportRepresentation.size() == 3
    exportRepresentation.metadonnees.size() == 3
    exportRepresentation.metadonnees.date == date
    exportRepresentation.metadonnees.exporteur == exporteurRepresentation
    exportRepresentation.metadonnees.formatVersion == formatVersion
    exportRepresentation.artefact == sujetRepresentation
  }

  def "testMarshall - question OK"() {
    given:
    Question question = new Question()
    Date date = new Date()
    Personne exporteur = new Personne()
    String formatVersion = "1.0"

    Map questionRepresentation = [map: 'question']
    questionMarshaller.marshall(question) >> questionRepresentation

    Map exporteurRepresentation = [map: 'personne']
    personneMarshaller.marshall(exporteur) >> exporteurRepresentation

    Map exportRepresentation = exportMarshaller.marshall(
        question,
        date,
        exporteur,
        formatVersion
    )

    expect:
    exportRepresentation.class == ExportClass.EXPORT.name()
    exportRepresentation.size() == 3
    exportRepresentation.metadonnees.size() == 3
    exportRepresentation.metadonnees.date == date
    exportRepresentation.metadonnees.exporteur == exporteurRepresentation
    exportRepresentation.metadonnees.formatVersion == formatVersion
    exportRepresentation.artefact == questionRepresentation
  }

  def "testParse - sujet OK"() {
    given:
    Date date = MarshallerHelper.normaliseDate(new Date())
    String formatVersion = "1.0"
    String json = """
    {
      class: ${ExportClass.EXPORT},
      metadonnees: {
        date: '${MarshallerHelper.ISO_DATE_FORMAT.format(date)}',
        exporteur: {},
        formatVersion: '$formatVersion'
      },
      artefact: {
        class: '${ExportClass.SUJET.name()}'
      }
    }
    """

    PersonneDto personneDto = new PersonneDto()
    PersonneMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      personneDto
    }

    SujetDto sujetDto = new SujetDto()
    SujetMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      sujetDto
    }

    ExportDto exportDto = ExportMarshaller.parse(JSON.parse(json))

    expect:
    exportDto.date == date
    exportDto.exporteur == personneDto
    exportDto.formatVersion == formatVersion
    exportDto.artefact == sujetDto

    cleanup:
    PersonneMarshaller.metaClass = null
    SujetMarshaller.metaClass = null

  }

  def "testParse - question OK"(ExportClass exportClass) {
    given:
    Date date = MarshallerHelper.normaliseDate(new Date())
    String formatVersion = "1.0"
    String json = """
    {
      class: ${ExportClass.EXPORT},
      metadonnees: {
        date: '${MarshallerHelper.ISO_DATE_FORMAT.format(date)}',
        exporteur: {},
        formatVersion: '$formatVersion'
      },
      artefact: {
        class: '${exportClass.name()}'
      }
    }
    """

    PersonneDto personneDto = new PersonneDto()
    PersonneMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      personneDto
    }

    QuestionDto questionDto = Mock(QuestionDto)
    QuestionMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      questionDto
    }

    ExportDto exportDto = ExportMarshaller.parse(JSON.parse(json))

    expect:
    exportDto.date == date
    exportDto.exporteur == personneDto
    exportDto.formatVersion == formatVersion
    exportDto.artefact == questionDto

    cleanup:
    PersonneMarshaller.metaClass = null
    QuestionMarshaller.metaClass = null

    where:
    exportClass << [ExportClass.QUESTION_ATOMIQUE, ExportClass.QUESTION_COMPOSITE]
  }
}
