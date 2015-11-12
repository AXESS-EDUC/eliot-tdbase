package org.lilie.services.eliot.tdbase.importexport

import org.lilie.services.eliot.tdbase.ReferentielEliot
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.SujetType
import org.lilie.services.eliot.tdbase.SujetTypeEnum
import org.lilie.services.eliot.tdbase.importexport.dto.SujetDto
import org.lilie.services.eliot.tdbase.importexport.dto.SujetSequenceQuestionsDto
import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * Service d'import de sujet
 *
 * @author John Tranier
 */
class SujetImporterService {

  static transactional = true

  SujetService sujetService
  QuestionImporterService questionImporterService

  Sujet importeSujet(SujetDto sujetDto,
                     Personne importeur,
                     ReferentielEliot referentielEliot = null) {

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
            copyrightsType: copyrightsType,
            matiereBcn: referentielEliot?.matiereBcn,
            niveau: referentielEliot?.niveau
        ],
        importeur
    )

    sujetDto.questionsSequences.each { SujetSequenceQuestionsDto sujetSequenceQuestionsDto ->
      questionImporterService.importeQuestion(
          sujetSequenceQuestionsDto.question,
          sujet,
          importeur,
          referentielEliot,
          sujetSequenceQuestionsDto.referentielSujetSequenceQuestions
      )
    }

    return sujet
  }
}
