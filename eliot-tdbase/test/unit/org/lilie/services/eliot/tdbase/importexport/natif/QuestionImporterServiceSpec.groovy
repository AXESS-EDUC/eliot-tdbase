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
import org.lilie.services.eliot.tdbase.impl.multiplechoice.MultipleChoiceSpecification
import org.lilie.services.eliot.tdbase.impl.multiplechoice.MultipleChoiceSpecificationReponsePossible
import org.lilie.services.eliot.tdbase.importexport.dto.AttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.CopyrightsTypeDto
import org.lilie.services.eliot.tdbase.importexport.dto.PrincipalAttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionDto
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
  AttachementImporterService attachementImporterService


  def setup() {
    artefactAutorisationService = Mock(ArtefactAutorisationService)
    questionService = Mock(QuestionService)
    attachementImporterService = Mock(AttachementImporterService)

    questionImporterService = new QuestionImporterService(
        artefactAutorisationService: artefactAutorisationService,
        questionService: questionService,
        attachementImporterService: attachementImporterService
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
    def jsonBlob = null
    def sujet = null
    def importeur = null

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

    artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet) >> true
    QuestionMarshaller.metaClass.static.parse = { JSONElement jsonElement ->
      throw new IllegalStateException("Specification")
    }


    when:
    questionImporterService.importeQuestion(
        jsonBlob,
        sujet,
        importeur
    )

    then:
    def e = thrown(IllegalStateException)
    e.message == "Specification"

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
      new QuestionDto(
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
      new QuestionDto(
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
      new QuestionDto(
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
      new QuestionDto(
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

    questionService.createQuestionAndInsertInSujet(_, _, _, _) >> {
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

  def "testImporteQuestion - question OK"(Matiere matiere,
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

    QuestionDto questionDto = new QuestionDto(
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
      return questionDto
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
          assert it.titre == questionDto.titre
          assert it.type.code == QuestionTypeEnum.MultipleChoice.name()
          assert it.matiere == matiere
          assert it.niveau == niveau
          assert it.estAutonome == questionDto.estAutonome
          assert it.paternite == questionDto.paternite
          assert it.versionQuestion == questionDto.versionQuestion
          assert it.copyrightsType.code == copyrightsTypeEnum.code
          return true
        },
        multipleChoiceSpecification,
        sujet,
        importeur
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
      1 * attachementImporterService.importePrincipalAttachement(questionDto.principalAttachement, question)
    } else {
      0 * attachementImporterService.importePrincipalAttachement(_)
    }

    1 * attachementImporterService.importeQuestionAttachements(questionDto.questionAttachements, question)
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
}
