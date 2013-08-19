package org.lilie.services.eliot.tdbase.importexport.dto

import spock.lang.Specification

/**
 * @author John Tranier
 */
class ExportDtoSpec extends Specification {

  def "testGetSujet - erreur: cet export ne correspond pas à un sujet"(ArtefactDto artefactDto) {
    given:
    ExportDto exportDto = new ExportDto(
        artefact: artefactDto
    )

    when:
    exportDto.sujet

    then:
    def e = thrown(IllegalStateException)
    e.message.startsWith("Cet export ne correspond pas à un sujet")

    where:
    artefactDto << [null, new QuestionAtomiqueDto()]
  }

  def "testGetSujet - OK"() {
    given:
    SujetDto sujetDto = new SujetDto()
    ExportDto exportDto = new ExportDto(
        artefact: sujetDto
    )

    expect:
    exportDto.sujet == sujetDto
  }

  def "testGetQuestion - erreur: cet export ne correspond pas à une question"(ArtefactDto artefactDto) {
    given:
    ExportDto exportDto = new ExportDto(
        artefact: artefactDto
    )

    when:
    exportDto.question

    then:
    def e = thrown(IllegalStateException)
    e.message.startsWith("Cet export ne correspond pas à une question")

    where:
    artefactDto << [null, new SujetDto()]
  }

  def "testGetQuestion - OK"() {
    given:
    QuestionDto questionDto = new QuestionAtomiqueDto()
    ExportDto exportDto = new ExportDto(
        artefact: questionDto
    )

    expect:
    exportDto.question == questionDto
  }
}
