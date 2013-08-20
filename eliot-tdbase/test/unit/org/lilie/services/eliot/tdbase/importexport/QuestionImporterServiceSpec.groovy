package org.lilie.services.eliot.tdbase.importexport

import grails.test.mixin.Mock
import grails.test.mixin.TestFor
import org.lilie.services.eliot.tdbase.ArtefactAutorisationService
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionType
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.ReferentielEliot
import org.lilie.services.eliot.tdbase.ReferentielSujetSequenceQuestions
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.impl.multiplechoice.MultipleChoiceSpecification
import org.lilie.services.eliot.tdbase.impl.multiplechoice.MultipleChoiceSpecificationReponsePossible
import org.lilie.services.eliot.tdbase.importexport.dto.AttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.CopyrightsTypeDto
import org.lilie.services.eliot.tdbase.importexport.dto.PrincipalAttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAtomiqueDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionCompositeDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionDto
import org.lilie.services.eliot.tdbase.importexport.dto.SujetDto
import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.springframework.context.ApplicationContext
import spock.lang.Specification

/**
 * @author John Tranier
 */
@TestFor(QuestionImporterService)
@Mock([QuestionType, CopyrightsType])
class QuestionImporterServiceSpec extends Specification {

  QuestionImporterService questionImporterService
  ArtefactAutorisationService artefactAutorisationService
  QuestionService questionService
  SujetService sujetService
  AttachementImporterService attachementImporterService
  SujetImporterService sujetImporterService


  def setup() {
    artefactAutorisationService = Mock(ArtefactAutorisationService)
    questionService = Mock(QuestionService)
    attachementImporterService = Mock(AttachementImporterService)
    sujetImporterService = Mock(SujetImporterService)
    sujetService = Mock(SujetService)

    questionImporterService = new QuestionImporterService(
        artefactAutorisationService: artefactAutorisationService,
        questionService: questionService,
        sujetService: sujetService,
        attachementImporterService: attachementImporterService,
        sujetImporterServiceBean: sujetImporterService
    )

    // Crée le type de question d'id 1
    new QuestionType(
        nom: "MultipleChoice",
        nomAnglais: "MultipleChoice",
        code: "MultipleChoice",
        interaction: true
    ).save(failOnError: true)

    new CopyrightsType(
        code: CopyrightsTypeEnum.TousDroitsReserves.code
    ).save(failOnError: true)
  }

  def "testImporteQuestion - Importeur n'a pas l'autorisation de modifier le sujet"() {
    given:
    QuestionDto questionDto = new QuestionAtomiqueDto()
    Sujet sujet = new Sujet()
    Personne importeur = new Personne()

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> false

    when:
    questionImporterService.importeQuestion(
        questionDto,
        sujet,
        importeur
    )

    then:
    thrown(Error)

  }

  def "testImporteQuestion - questionType incorrect"() {
    given:
    QuestionDto questionDto = new QuestionAtomiqueDto(
        type: "Question type incorrect"
    )

    def sujet = new Sujet()
    def importeur = new Personne()

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> true

    when:
    questionImporterService.importeQuestion(
        questionDto,
        sujet,
        importeur
    )

    then:
    def e = thrown(IllegalArgumentException)
    e.message.startsWith("No enum constant org.lilie.services.eliot.tdbase.QuestionTypeEnum.Question")
  }

  def "testImporteQuestion - copyrightsType incorrect"() {
    given:
    String codeCopyrightsTypeIncorrect = "codeCopyrightsTypeIncorrect"
    QuestionDto questionDto = new QuestionAtomiqueDto(
        type: QuestionTypeEnum.MultipleChoice.name(),
        copyrightsType: new CopyrightsTypeDto(
            code: codeCopyrightsTypeIncorrect
        )
    )
    def sujet = new Sujet()
    def importeur = new Personne()

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> true


    when:
    questionImporterService.importeQuestion(
        questionDto,
        sujet,
        importeur
    )

    then:
    def e = thrown(IllegalArgumentException)
    e.message == "Le code '$codeCopyrightsTypeIncorrect' ne correspond pas à un type de copyrights connu"
  }

  def "testImporteQuestion - specification incorrecte"() {
    given:
    QuestionTypeEnum questionTypeEnum = QuestionTypeEnum.MultipleChoice
    QuestionDto questionDto = new QuestionAtomiqueDto(
        type: questionTypeEnum.name(),
        copyrightsType: new CopyrightsTypeDto(
            code: CopyrightsTypeEnum.TousDroitsReserves.code
        )
    )
    def sujet = new Sujet()
    def importeur = new Personne()

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> true

    questionService.questionSpecificationServiceForQuestionType(_) >> { QuestionType questionType ->
      QuestionSpecificationService questionSpecificationService = Mock(QuestionSpecificationService)

      questionSpecificationService.getObjectFromSpecification(_) >> { String specification ->
        throw new IllegalStateException("Erreur simulée")
      }

      return questionSpecificationService
    }

    when:
    questionImporterService.importeQuestion(
        questionDto,
        sujet,
        importeur
    )

    then:
    def e = thrown(IllegalStateException)
    e.message == "Erreur simulée"
  }

  def "testImporteQuestion - Echec de création de la question"() {
    given:
    QuestionDto questionDto = new QuestionAtomiqueDto(
        type: QuestionTypeEnum.MultipleChoice.name(),
        copyrightsType: new CopyrightsTypeDto(
            code: CopyrightsTypeEnum.TousDroitsReserves.code
        )
    )
    def sujet = new Sujet()
    def importeur = new Personne()

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> true

    questionService.questionSpecificationServiceForQuestionType(_) >> { QuestionType questionType ->
      QuestionSpecificationService questionSpecificationService = Mock(QuestionSpecificationService)

      questionSpecificationService.getObjectFromSpecification(_) >> { String specification ->
        return new MultipleChoiceSpecification(
            libelle: "libelle",
            correction: "correction",
            reponses: [
                new MultipleChoiceSpecificationReponsePossible(),
                new MultipleChoiceSpecificationReponsePossible()
            ]
        )
      }

      return questionSpecificationService
    }

    questionService.createQuestion(_, _, _) >> {
      throw new IllegalStateException(
          "Echec de création de la question"
      )
    }

    when:
    questionImporterService.importeQuestion(
        questionDto,
        sujet,
        importeur
    )

    then:
    def e = thrown(IllegalStateException)
    e.message == "Echec de création de la question"
  }

  def "testImporteQuestion - question atomique OK"(ReferentielEliot referentielEliot,
                                                   PrincipalAttachementDto principalAttachementDto,
                                                   List<AttachementDto> questionAttachementsDto) {
    given:
    CopyrightsTypeEnum copyrightsTypeEnum = CopyrightsTypeEnum.TousDroitsReserves
    QuestionTypeEnum questionTypeEnum = QuestionTypeEnum.MultipleChoice

    QuestionAtomiqueDto questionAtomiqueDto = new QuestionAtomiqueDto(
        titre: "titre",
        type: questionTypeEnum.name(),
        copyrightsType: new CopyrightsTypeDto(
            code: copyrightsTypeEnum.code
        ),
        estAutonome: true,
        paternite: "paternite",
        principalAttachement: principalAttachementDto,
        questionAttachements: questionAttachementsDto
    )

    def sujet = new Sujet()
    def importeur = new Personne()


    Question question = new Question()

    MultipleChoiceSpecification multipleChoiceSpecification = new MultipleChoiceSpecification(
        libelle: "libelle",
        correction: "correction",
        reponses: [
            new MultipleChoiceSpecificationReponsePossible(),
            new MultipleChoiceSpecificationReponsePossible()
        ]
    )

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> true

    questionService.questionSpecificationServiceForQuestionType {
      assert it.id == questionTypeEnum.id
      return true
    } >> { QuestionType questionType ->
      QuestionSpecificationService questionSpecificationService = Mock(QuestionSpecificationService)

      questionSpecificationService.getObjectFromSpecification(_) >> { String specification ->
        return multipleChoiceSpecification
      }

      return questionSpecificationService
    }

    when:
    Question questionImportee = questionImporterService.importeQuestion(
        (QuestionAtomiqueDto)questionAtomiqueDto,
        sujet,
        importeur,
        referentielEliot
    )

    then:
    1 * questionService.createQuestion(
        {
          assert it.titre == questionAtomiqueDto.titre
          assert it.type.code == QuestionTypeEnum.MultipleChoice.name()
          assert it.matiere == referentielEliot?.matiere
          assert it.niveau == referentielEliot?.niveau
          assert it.estAutonome == questionAtomiqueDto.estAutonome
          assert it.paternite == questionAtomiqueDto.paternite
          assert it.versionQuestion == questionAtomiqueDto.versionQuestion
          assert it.copyrightsType.code == copyrightsTypeEnum.code
          return true
        },
        multipleChoiceSpecification,
        importeur
    ) >> question

    1 * sujetService.insertQuestionInSujet(
        question,
        sujet,
        importeur,
        null
    )

    if (principalAttachementDto) {
      1 * attachementImporterService.importePrincipalAttachement(questionAtomiqueDto.principalAttachement, question)
    } else {
      0 * attachementImporterService.importePrincipalAttachement(_)
    }

    1 * attachementImporterService.importeQuestionAttachements(questionAtomiqueDto.questionAttachements, question)
    questionImportee == question

    where:
    referentielEliot << [
        null,
        null,
        new ReferentielEliot(
            matiere: new Matiere(),
            niveau: new Niveau()
        )
    ]

    principalAttachementDto << [
        null, null, new PrincipalAttachementDto()
    ]

    questionAttachementsDto << [
        [],
        [new AttachementDto()],
        [new AttachementDto(), new AttachementDto(), new AttachementDto()]
    ]
  }

  def "testImporteQuestion - question composite OK"(ReferentielEliot referentielEliot,
                                                    ReferentielSujetSequenceQuestions referentielSujetSequenceQuestions) {
    given:
    SujetDto exerciceDto = new SujetDto()
    Question questionComposite = new Question()
    Sujet exercice = Mock(Sujet)
    exercice.getQuestionComposite() >> questionComposite
    QuestionCompositeDto questionCompositeDto = new QuestionCompositeDto(
        exercice: exerciceDto
    )
    Sujet sujet = new Sujet()
    Personne importeur = new Personne()

    when:
    Question questionImportee = questionImporterService.importeQuestion(
        questionCompositeDto,
        sujet,
        importeur,
        referentielEliot,
        referentielSujetSequenceQuestions
    )

    then:
    1 * sujetImporterService.importeSujet(
        exerciceDto,
        importeur,
        referentielEliot
    ) >> exercice

    then:
    1 * sujetService.insertQuestionInSujet(
        questionComposite,
        sujet,
        importeur,
        referentielSujetSequenceQuestions
    )

    then:
    questionImportee == questionComposite


    where:
    referentielEliot << [
        null,
        new ReferentielEliot(
            matiere: new Matiere(),
            niveau: new Niveau()
        )
    ]
    referentielSujetSequenceQuestions << [
        null,
        new ReferentielSujetSequenceQuestions(
            rang: 4,
            noteSeuilPoursuite: 8.0,
            points: 3.0
        )
    ]
  }


  def "testGetSujetImporterService"() {
    given:
    ApplicationContext applicationContext = Mock(ApplicationContext)
    questionImporterService.sujetImporterServiceBean = null
    questionImporterService.applicationContext = applicationContext

    applicationContext.getBean('sujetImporterService') >> sujetImporterService



    expect:
    questionImporterService.sujetImporterService == sujetImporterService
  }
}
