package org.lilie.services.eliot.tdbase.importexport

import grails.test.mixin.Mock
import org.lilie.services.eliot.tdbase.ReferentielEliot
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.SujetType
import org.lilie.services.eliot.tdbase.SujetTypeEnum
import org.lilie.services.eliot.tdbase.importexport.dto.CopyrightsTypeDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAtomiqueDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionDto
import org.lilie.services.eliot.tdbase.importexport.dto.SujetDto
import org.lilie.services.eliot.tdbase.importexport.dto.SujetSequenceQuestionsDto
import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import spock.lang.Specification

/**
 * @author John Tranier
 */
@Mock([CopyrightsType, SujetType])
class SujetImporterServiceSpec extends Specification {

  SujetService sujetService
  QuestionImporterService questionImporterService
  SujetImporterService sujetImporterService

  def setup() {
    sujetService = Mock(SujetService)
    questionImporterService = Mock(QuestionImporterService)

    sujetImporterService = new SujetImporterService(
        sujetService: sujetService,
        questionImporterService: questionImporterService
    )

    new CopyrightsType(
        code: CopyrightsTypeEnum.TousDroitsReserves.code
    ).save(failOnError: true)

    new SujetType(
        nom: SujetTypeEnum.Sujet.name()
    ).save(failOnError: true)
  }

  def "testImporteSujet - erreur copyrightsType incorrect"() {
    given:
    String codeCopyrightsTypeIncorrect = "codeCopyrightsTypeIncorrect"
    SujetDto sujetDto = new SujetDto(
        type: SujetTypeEnum.Sujet.name(),
        copyrightsType: new CopyrightsTypeDto(
            code: codeCopyrightsTypeIncorrect
        )
    )

    def importeur = null

    when:
    sujetImporterService.importeSujet(
        sujetDto,
        importeur
    )

    then:
    def e = thrown(IllegalArgumentException)
    e.message == "Le code '$codeCopyrightsTypeIncorrect' ne correspond pas à un type de copyrights connu"
  }

  def "testImporteSujet - OK"(List<SujetSequenceQuestionsDto> questionsSequences) {
    given:
    Personne importeur = new Personne()
    ReferentielEliot referentielEliot = new ReferentielEliot(
        matiere: new Matiere(),
        niveau: new Niveau()
    )

    String titre = "titre"
    int versionSujet = 3
    String presentation = "presentation"
    Integer dureeMinutes = 30
    Float noteMax = 20.0
    Float noteAutoMax = 12.0
    Float noteEnseignantMax = 8.0
    Boolean accesSequentiel = true
    Boolean ordreQurstionsAleatoire = false
    String paternite = "paternite"
    CopyrightsTypeEnum copyrightsTypeEnum = CopyrightsTypeEnum.TousDroitsReserves

    SujetDto sujetDto = new SujetDto(
        titre: titre,
        type: SujetTypeEnum.Sujet.name(),
        versionSujet: versionSujet,
        presentation: presentation,
        dureeMinutes: dureeMinutes,
        noteMax: noteMax,
        noteAutoMax: noteAutoMax,
        noteEnseignantMax: noteEnseignantMax,
        accesSequentiel: accesSequentiel,
        ordreQuestionsAleatoire: ordreQurstionsAleatoire,
        paternite: paternite,
        copyrightsType: new CopyrightsTypeDto(
            code: copyrightsTypeEnum.code
        ),
        questionsSequences: questionsSequences
    )

    Sujet sujet = new Sujet()

    when:
    Sujet sujetImporte = sujetImporterService.importeSujet(
        sujetDto,
        importeur,
        referentielEliot
    )

    then:
    1 * sujetService.updateProprietes(
        { it instanceof Sujet },
        {
          assert it.titre == titre
          assert it.sujetType.nom == SujetTypeEnum.Sujet.name()
          assert it.versionSujet == versionSujet
          assert it.presentation == presentation
          assert it.dureeMinutes == dureeMinutes
          assert it.noteMax == noteMax
          assert it.noteAutoMax == noteAutoMax
          assert it.noteEnseignantMax == noteEnseignantMax
          assert it.accesSequentiel == accesSequentiel
          assert it.ordreQuestionsAleatoire == ordreQurstionsAleatoire
          assert it.paternite == paternite
          assert it.copyrightsType.code == copyrightsTypeEnum.code
          return true
        },
        importeur
    ) >> sujet

    then:
    (questionsSequences.size()) * questionImporterService.importeQuestion(
        { it instanceof QuestionDto },
        sujet,
        importeur,
        referentielEliot,
        _
    )

    then:
    sujetImporte == sujet

    where:
    questionsSequences << [
        [],
        [new SujetSequenceQuestionsDto(question: new QuestionAtomiqueDto())],
        [new SujetSequenceQuestionsDto(question: new QuestionAtomiqueDto()), new SujetSequenceQuestionsDto(question: new QuestionAtomiqueDto())]
    ]
  }
}
