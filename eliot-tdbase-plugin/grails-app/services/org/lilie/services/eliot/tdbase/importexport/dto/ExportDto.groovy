package org.lilie.services.eliot.tdbase.importexport.dto

/**
 * Décrit un export
 * @author John Tranier
 */
class ExportDto {
  Date date
  PersonneDto exporteur
  String formatVersion
  ArtefactDto artefact

  SujetDto getSujet() {
    if(!(artefact instanceof SujetDto)) {
      throw new IllegalStateException(
          "Cet export ne correspond pas à un sujet (${artefact?.class})"
      )
    }

    return (SujetDto)artefact
  }

  QuestionDto getQuestion() {
    if(!(artefact instanceof QuestionDto)) {
      throw new IllegalStateException(
          "Cet export ne correspond pas à une question (${artefact?.class})"
      )
    }

    return (QuestionDto)artefact
  }
}
