package org.lilie.services.eliot.tdbase.importexport

import grails.test.mixin.TestFor
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionAttachementService
import org.lilie.services.eliot.tdbase.importexport.dto.AttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.PrincipalAttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAttachementDto
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MarshallerHelper
import org.lilie.services.eliot.tice.Attachement
import org.lilie.services.eliot.tice.AttachementService
import spock.lang.Specification

/**
 * @author John Tranier
 */
@TestFor(AttachementImporterService)
class AttachementImporterServiceSpec extends Specification {

  AttachementImporterService attachementImporterService
  AttachementService attachementService
  QuestionAttachementService questionAttachementService

  def setup() {
    attachementService = Mock(AttachementService)
    questionAttachementService = Mock(QuestionAttachementService)

    def mockConfig = new ConfigObject()
    mockConfig.eliot.fichiers.importexport.maxsize.mega = 25

    attachementImporterService = new AttachementImporterService(
        attachementService: attachementService,
        questionAttachementService: questionAttachementService,
        grailsApplication: [config: mockConfig]
    )
  }

  def "testImportePrincipalAttachement"(String blob,
                                        Boolean estInsereDansLaQuestion,
                                        Attachement attachement,
                                        Question question) {
    given:
    AttachementDto attachementDto = new AttachementDto(
        nom: 'nom',
        nomFichierOriginal: 'nomFichierOriginal',
        typeMime: 'typeMime',
        blob: MarshallerHelper.encodeAsBase64(blob),
        estInsereDansLaQuestion: estInsereDansLaQuestion
    )

    PrincipalAttachementDto principalAttachementDto = new PrincipalAttachementDto(
        attachement: attachementDto
    )

    when:
    attachementImporterService.importePrincipalAttachement(principalAttachementDto, question)

    then:
    1 * attachementService.createAttachement(
        {
          it.taille == blob.size() &&
              it.typeMime == attachementDto.typeMime &&
              it.nom == attachementDto.nom &&
              it.nomFichierOriginal == attachementDto.nomFichierOriginal &&
              it.inputStream
        },
        _
    ) >> attachement

    then:
    1 * questionAttachementService.createPrincipalAttachementForQuestion(
        attachement,
        question,
        estInsereDansLaQuestion
    )

    where:
    blob = "blob"
    estInsereDansLaQuestion << [true, false, null]
    attachement = new Attachement()
    question = new Question()
  }

  def "testImporteQuestionAttachements"(int nbAttachement, Question question) {
    given:
    List<QuestionAttachementDto> allQuestionAttachementDto = genereQuestionAttachementsDto(nbAttachement)

    when:
    attachementImporterService.importeQuestionAttachements(
        allQuestionAttachementDto,
        question
    )

    then:
    nbAttachement * attachementService.createAttachement(_, _)
    nbAttachement * questionAttachementService.createAttachementForQuestion(
        _,
        question,
        _
    )

    where:
    nbAttachement << [0, 1, 4]
    question = new Question()
  }

  private List<QuestionAttachementDto> genereQuestionAttachementsDto(int nbAttachement) {
    List<AttachementDto> allAttachementDto = []

    nbAttachement.times {
      allAttachementDto << new QuestionAttachementDto(
          id: it,
          attachement: new AttachementDto(
              nom: "nom-$nbAttachement",
              nomFichierOriginal: "nomFichierOriginal-$nbAttachement",
              typeMime: "typeMime-$nbAttachement",
              blob: MarshallerHelper.encodeAsBase64("blob-$nbAttachement"),
              estInsereDansLaQuestion: true
          )
      )

    }

    return allAttachementDto
  }
}
