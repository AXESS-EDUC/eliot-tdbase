package org.lilie.services.eliot.tdbase.importexport.natif

import grails.converters.JSON
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.SujetType
import org.lilie.services.eliot.tdbase.SujetTypeEnum
import org.lilie.services.eliot.tdbase.importexport.dto.SujetDto
import org.lilie.services.eliot.tdbase.importexport.dto.SujetSequenceQuestionsDto
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.SujetMarshaller
import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau

/**
 * Service d'import de sujet au format JSON natif eliot-tdbase
 *
 * @author John Tranier
 */
class SujetImporterService {

  static transactional = true

  SujetService sujetService
  QuestionImporterService questionImporterService

  Sujet importeSujet(byte[] jsonBlob,
                     Personne importeur,
                     Matiere matiere = null,
                     Niveau niveau = null) {
    SujetDto sujetDto = SujetMarshaller.parse(
        JSON.parse(new ByteArrayInputStream(jsonBlob), 'UTF-8')
    )

    importeSujet(
        sujetDto,
        importeur,
        matiere,
        niveau
    )
  }

  Sujet importeSujet(SujetDto sujetDto,
                     Personne importeur,
                     Matiere matiere = null,
                     Niveau niveau = null) {

    // Récupération du type
    SujetType sujetType = SujetTypeEnum.valueOf(sujetDto.type).sujetType

    // Récupération du copyrightsType
    CopyrightsType copyrightsType = CopyrightsTypeEnum.parseFromCode(
        sujetDto.copyrightsType.code
    ).copyrightsType

    Sujet sujet = sujetService.updateProprietes(
        new Sujet(),
        [
            titre: sujetDto.titre,
            sujetType: sujetType,
            versionSujet: sujetDto.versionSujet,
            presentation: sujetDto.presentation,
            dureeMinutes: sujetDto.dureeMinutes,
            noteMax: sujetDto.noteMax,
            noteAutoMax: sujetDto.noteAutoMax,
            noteEnseignantMax: sujetDto.noteEnseignantMax,
            accesSequentiel: sujetDto.accesSequentiel,
            ordreQuestionsAleatoire: sujetDto.ordreQuestionsAleatoire,
            paternite: sujetDto.paternite,
            copyrightsType: copyrightsType
        ],
        importeur
    )

    sujetDto.questionsSequences.each { SujetSequenceQuestionsDto sujetSequenceQuestionsDto ->
      questionImporterService.importeQuestion(
          sujetSequenceQuestionsDto.question,
          sujet,
          importeur,
          matiere,
          niveau,
          sujetSequenceQuestionsDto.rang,
          sujetSequenceQuestionsDto.noteSeuilPoursuite,
          sujetSequenceQuestionsDto.points
      )
    }

    return sujet
  }
}
