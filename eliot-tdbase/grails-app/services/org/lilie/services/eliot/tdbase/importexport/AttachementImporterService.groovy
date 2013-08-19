package org.lilie.services.eliot.tdbase.importexport

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionAttachementService
import org.lilie.services.eliot.tdbase.importexport.dto.AttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.PrincipalAttachementDto
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MarshallerHelper
import org.lilie.services.eliot.tice.Attachement
import org.lilie.services.eliot.tice.AttachementService

/**
 * Service d'import d'attachements au format JSON natif eliot-tdbase
 *
 * @author John Tranier
 */
class AttachementImporterService {

  static transactional = true

  AttachementService attachementService
  QuestionAttachementService questionAttachementService

  void importePrincipalAttachement(PrincipalAttachementDto principalAttachementDto,
                                   Question question) {

    Attachement attachement = importeAttachement(principalAttachementDto.attachement)

    questionAttachementService.createPrincipalAttachementForQuestion(
        attachement,
        question,
        principalAttachementDto.attachement.estInsereDansLaQuestion
    )
  }

  void importeQuestionAttachements(List<AttachementDto> questionAttachementsDto,
                                   Question question) {
    questionAttachementsDto.eachWithIndex { AttachementDto attachementDto, int rang ->
      Attachement attachement = importeAttachement(attachementDto)

      questionAttachementService.createAttachementForQuestion(
          attachement,
          question,
          attachementDto.estInsereDansLaQuestion,
          rang
      )

    }
  }

  private Attachement importeAttachement(AttachementDto attachementDto) {
    def decodedBytes = MarshallerHelper.getDecodedBytes(attachementDto.blob)

    return attachementService.createAttachement(
        new org.lilie.services.eliot.tice.AttachementDto(
            taille: decodedBytes.length,
            typeMime: attachementDto.typeMime,
            nom: attachementDto.nom,
            nomFichierOriginal: attachementDto.nomFichierOriginal,
            inputStream: new ByteArrayInputStream(decodedBytes)
        )
    )
  }

}
