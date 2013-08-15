package org.lilie.services.eliot.tdbase.importexport.natif

import grails.test.mixin.Mock
import grails.test.mixin.TestFor
import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.ArtefactAutorisationService
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionType
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.impl.multiplechoice.MultipleChoiceSpecification
import org.lilie.services.eliot.tdbase.impl.multiplechoice.MultipleChoiceSpecificationReponsePossible
import org.lilie.services.eliot.tdbase.importexport.dto.AttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.CopyrightsTypeDto
import org.lilie.services.eliot.tdbase.importexport.dto.PrincipalAttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAtomiqueDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionCompositeDto
import org.lilie.services.eliot.tdbase.importexport.dto.SujetDto
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.QuestionMarshaller
import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
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
    byte[] jsonBlob = "jsonBlob".bytes
    Sujet sujet = null
    Personne importeur = null

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> false

    when:
    questionImporterService.importeQuestion(
        jsonBlob,
        sujet,
        importeur
    )

    then:
    thrown(Error)

  }

  def "testImporteQuestion - Erreur de parsing"() {
    given:
    def jsonBlob = "jsonBlob".getBytes()
    def sujet = null
    def importeur = null

    String erreurMessage = "erreur"

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> true
    QuestionMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      throw new IllegalStateException(erreurMessage)
    }


    when:
    questionImporterService.importeQuestion(
        jsonBlob,
        sujet,
        importeur
    )

    then:
    def e = thrown(IllegalStateException)
    e.message == erreurMessage

    cleanup:
    QuestionMarshaller.metaClass = null
  }

  def "testImporteQuestion - questionType incorrect"() {
    given:
    def jsonBlob = "jsonBlob".getBytes()
    def sujet = null
    def importeur = null

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> true
    QuestionMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      new QuestionAtomiqueDto(
          type: "Question type incorrect"
      )
    }


    when:
    questionImporterService.importeQuestion(
        jsonBlob,
        sujet,
        importeur
    )

    then:
    def e = thrown(IllegalArgumentException)
    e.message.startsWith("No enum constant org.lilie.services.eliot.tdbase.QuestionTypeEnum.Question")

    cleanup:
    QuestionMarshaller.metaClass = null
  }

  def "testImporteQuestion - copyrightsType incorrect"() {
    given:
    def jsonBlob = "jsonBlob".getBytes()
    def sujet = null
    def importeur = null

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> true
    String codeCopyrightsTypeIncorrect = "codeCopyrightsTypeIncorrect"
    QuestionMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      new QuestionAtomiqueDto(
          type: QuestionTypeEnum.MultipleChoice.name(),
          copyrightsType: new CopyrightsTypeDto(
              code: codeCopyrightsTypeIncorrect
          )
      )
    }

    when:
    questionImporterService.importeQuestion(
        jsonBlob,
        sujet,
        importeur
    )

    then:
    def e = thrown(IllegalArgumentException)
    e.message == "Le code '$codeCopyrightsTypeIncorrect' ne correspond pas à un type de copyrights connu"

    cleanup:
    QuestionMarshaller.metaClass = null
  }

  def "testImporteQuestion - specification incorrecte"() {
    given:
    def jsonBlob = "jsonBlob".getBytes()
    def sujet = null
    def importeur = null

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> true

    QuestionTypeEnum questionTypeEnum = QuestionTypeEnum.MultipleChoice

    QuestionMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      new QuestionAtomiqueDto(
          type: questionTypeEnum.name(),
          copyrightsType: new CopyrightsTypeDto(
              code: CopyrightsTypeEnum.TousDroitsReserves.code
          )
      )
    }

    questionService.questionSpecificationServiceForQuestionType(_) >> { QuestionType questionType ->
      QuestionSpecificationService questionSpecificationService = Mock(QuestionSpecificationService)

      questionSpecificationService.getObjectFromSpecification(_) >> { String specification ->
        throw new IllegalStateException("Erreur simulée")
      }

      return questionSpecificationService
    }

    when:
    questionImporterService.importeQuestion(
        jsonBlob,
        sujet,
        importeur
    )

    then:
    def e = thrown(IllegalStateException)
    e.message == "Erreur simulée"

    cleanup:
    QuestionMarshaller.metaClass = null
  }

  def "testImporteQuestion - Echec de création de la question"() {
    given:
    def jsonBlob = "jsonBlob".getBytes()
    def sujet = null
    def importeur = null

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> true

    QuestionMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      new QuestionAtomiqueDto(
          type: QuestionTypeEnum.MultipleChoice.name(),
          copyrightsType: new CopyrightsTypeDto(
              code: CopyrightsTypeEnum.TousDroitsReserves.code
          )
      )
    }

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

    questionService.createQuestionAndInsertInSujet(_, _, _, _, _, _, _) >> {
      throw new IllegalStateException(
          "Echec de création de la question"
      )
    }

    when:
    questionImporterService.importeQuestion(
        jsonBlob,
        sujet,
        importeur
    )

    then:
    def e = thrown(IllegalStateException)
    e.message == "Echec de création de la question"

    cleanup:
    QuestionMarshaller.metaClass = null
  }

  def "testImporteQuestion - question atomique OK"(Matiere matiere,
                                                   Niveau niveau,
                                                   PrincipalAttachementDto principalAttachementDto,
                                                   List<AttachementDto> questionAttachementsDto) {
    given:
    def jsonBlob = "jsonBlob".getBytes()
    def sujet = new Sujet()
    def importeur = new Personne()
    CopyrightsTypeEnum copyrightsTypeEnum = CopyrightsTypeEnum.TousDroitsReserves

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

    QuestionMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      return questionAtomiqueDto
    }

    questionService.questionSpecificationServiceForQuestionType({
      assert it.id == questionTypeEnum.id
      return true
    }) >> { QuestionType questionType ->
      QuestionSpecificationService questionSpecificationService = Mock(QuestionSpecificationService)

      questionSpecificationService.getObjectFromSpecification(_) >> { String specification ->
        return multipleChoiceSpecification
      }

      return questionSpecificationService
    }

    1 * questionService.createQuestionAndInsertInSujet(
        {
          assert it.titre == questionAtomiqueDto.titre
          assert it.type.code == QuestionTypeEnum.MultipleChoice.name()
          assert it.matiere == matiere
          assert it.niveau == niveau
          assert it.estAutonome == questionAtomiqueDto.estAutonome
          assert it.paternite == questionAtomiqueDto.paternite
          assert it.versionQuestion == questionAtomiqueDto.versionQuestion
          assert it.copyrightsType.code == copyrightsTypeEnum.code
          return true
        },
        multipleChoiceSpecification,
        sujet,
        importeur,
        null,
        null,
        null
    ) >> question

    when:
    Question questionImportee = questionImporterService.importeQuestion(
        jsonBlob,
        sujet,
        importeur,
        matiere,
        niveau
    )

    then:
    if (principalAttachementDto) {
      1 * attachementImporterService.importePrincipalAttachement(questionAtomiqueDto.principalAttachement, question)
    } else {
      0 * attachementImporterService.importePrincipalAttachement(_)
    }

    1 * attachementImporterService.importeQuestionAttachements(questionAtomiqueDto.questionAttachements, question)
    questionImportee == question

    cleanup:
    QuestionMarshaller.metaClass = null

    where:
    matiere << [null, null, new Matiere()]
    niveau << [null, null, new Niveau()]

    principalAttachementDto << [
        null, null, new PrincipalAttachementDto()
    ]

    questionAttachementsDto << [
        [],
        [new AttachementDto()],
        [new AttachementDto(), new AttachementDto(), new AttachementDto()]
    ]
  }

  def "testImporteQuestion - question composite OK"(Matiere matiere,
                                                    Niveau niveau,
                                                    Integer rang,
                                                    Float noteSeuilPoursuite,
                                                    Float points) {
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
        matiere,
        niveau,
        rang,
        noteSeuilPoursuite,
        points
    )

    then:
    1 * sujetImporterService.importeSujet(
        exerciceDto,
        importeur,
        matiere,
        niveau
    ) >> exercice

    then:
    1 * sujetService.insertQuestionInSujet(
        questionComposite,
        sujet,
        importeur,
        rang,
        noteSeuilPoursuite,
        points
    )

    then:
    questionImportee == questionComposite


    where:
    matiere << [null, new Matiere()]
    niveau << [null, new Niveau()]
    rang << [null, 4]
    noteSeuilPoursuite << [null, 8.0]
    points << [null, 3.0]
  }

}
