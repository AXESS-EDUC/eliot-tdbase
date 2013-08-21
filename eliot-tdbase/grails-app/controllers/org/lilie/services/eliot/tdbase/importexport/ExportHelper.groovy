package org.lilie.services.eliot.tdbase.importexport

import org.lilie.services.eliot.tdbase.Artefact
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.Sujet

/**
 * @author John Tranier
 */
class ExportHelper {

  final static String TYPE_SUJET = 'sujet'
  final static String TYPE_QUESTION = 'question'

  static String getFileName(Artefact artefact, Format format) {
    if (!artefact) {
      throw new IllegalArgumentException("artefact ne peut pas être null")
    }
    if (!format) {
      throw new IllegalArgumentException("format ne peut pas être null")
    }

    if (format != Format.NATIF_JSON) {
      throw new IllegalStateException('Non implémenté')
    }

    String type = ""
    switch (artefact.class) {
      case Question:
        type = TYPE_QUESTION
        break

      case Sujet:
        type = TYPE_SUJET
        break

      default:
        throw new IllegalStateException("Non implémenté")
    }

    String intitule = artefact.titreNormalise.substring(
        0,
        Math.min(20, artefact.titreNormalise.size())
    )

    return "${type}-${intitule}.tdbase"
  }
}
