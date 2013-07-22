package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tdbase.QuestionAttachement
import org.lilie.services.eliot.tice.Attachement
import org.lilie.services.eliot.tice.AttachementService

/**
 * Marshaller qui permet de convertir des Attachement et des QuestionsAttachements dans une représentation
 * à base de List et de Map qui pourra ensuite être convertie en JSON ou en XML
 *
 * @author John Tranier
 */
class AttachementMarchaller {

  AttachementService attachementService

  Map marshallPrincipalAttachement(Attachement principalAttachement, estInsereDansLaQuestion) {
    if(!principalAttachement) {
      return null
    }

    return [
        attachement: marshallAttachement(principalAttachement),
        estInsereDansLaQuestion: estInsereDansLaQuestion
    ]
  }

  List marshallQuestionAttachements(SortedSet<QuestionAttachement> questionAttachements) {
    if(!questionAttachements) {
      return []
    }

    return questionAttachements.collect {marshallAttachement(it.attachement)}
  }

  private Map marshallAttachement(Attachement attachement) {
    return [
        nom: attachement.nom,
        nomFichierOriginal: attachement.nomFichierOriginal,
        typeMime: attachement.typeMime,
        blob: attachementService.encodeToBase64(attachement)
    ]
  }

}
