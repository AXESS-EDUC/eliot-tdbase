package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONElement
import org.codehaus.groovy.grails.web.json.JSONObject
import org.lilie.services.eliot.tdbase.QuestionAttachement
import org.lilie.services.eliot.tdbase.importexport.dto.AttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.PrincipalAttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAttachementDto
import org.lilie.services.eliot.tice.Attachement

/**
 * Marshaller qui permet de convertir des Attachement et des QuestionsAttachements dans une représentation
 * à base de List et de Map qui pourra ensuite être convertie en JSON ou en XML
 *
 * @author John Tranier
 */
class AttachementMarchaller {

  @SuppressWarnings('ReturnsNullInsteadOfEmptyCollection')
  Map marshallPrincipalAttachement(Attachement principalAttachement,
                                   estInsereDansLaQuestion,
                                   AttachementDataStore attachementDataStore) {
    if (!principalAttachement) {
      return null
    }

    return [
        class: ExportClass.PRINCIPAL_ATTACHEMENT.name(),
        attachement: marshallAttachement(
            principalAttachement,
            estInsereDansLaQuestion,
            attachementDataStore
        )
    ]
  }

  List marshallQuestionAttachements(Collection<QuestionAttachement> questionAttachements,
                                    AttachementDataStore attachementDataStore) {
    if (!questionAttachements) {
      return []
    }

    return questionAttachements.collect { QuestionAttachement questionAttachement ->
      Map attachementRepresentation = marshallAttachement(
          questionAttachement.attachement,
          questionAttachement.estInsereDansLaQuestion,
          attachementDataStore
      )

      return [
          class: ExportClass.QUESTION_ATTACHEMENT.name(),
          id: questionAttachement.id,
          attachement: attachementRepresentation
      ]
    }
  }

  private Map marshallAttachement(Attachement attachement,
                                  Boolean estInsereDansLaQuestion,
                                  AttachementDataStore attachementDataStore) {

    attachementDataStore.addAttachement(attachement)

    return [
        class: ExportClass.ATTACHEMENT.name(),
        nom: attachement.nom,
        nomFichierOriginal: attachement.nomFichierOriginal,
        typeMime: attachement.typeMime,
        chemin: attachement.chemin,
        estInsereDansLaQuestion: estInsereDansLaQuestion
    ]
  }

  static PrincipalAttachementDto parsePrincipalAttachement(JSONElement jsonElement,
                                                           AttachementDataStore attachementDataStore) {
    MarshallerHelper.checkClass(ExportClass.PRINCIPAL_ATTACHEMENT, jsonElement)
    MarshallerHelper.checkIsJsonElement('attachement', jsonElement.attachement)
    return new PrincipalAttachementDto(
        attachement: parseAttachement(jsonElement.attachement, attachementDataStore)
    )
  }

  static parsePrincipalAttachement(JSONObject.Null ignore, AttachementDataStore attachementDataStore) {
    return null
  }

  static List<QuestionAttachementDto> parseAllQuestionAttachement(JSONArray jsonArray,
                                                                  AttachementDataStore attachementDataStore) {
    jsonArray.collect {
      parseQuestionAttachement((JSONElement) it, attachementDataStore)
    }
  }

  static QuestionAttachementDto parseQuestionAttachement(JSONElement jsonElement,
                                                         AttachementDataStore attachementDataStore) {
    MarshallerHelper.checkClass(ExportClass.QUESTION_ATTACHEMENT, jsonElement)
    MarshallerHelper.checkIsNotNull('questionAttachement.id', jsonElement.id)
    MarshallerHelper.checkIsJsonElement('questionAttachement.attachement', jsonElement.attachement)

    return new QuestionAttachementDto(
        id: jsonElement.id,
        attachement: parseAttachement(jsonElement.attachement, attachementDataStore)
    )
  }

  static AttachementDto parseAttachement(JSONElement jsonElement,
                                         AttachementDataStore attachementDataStore) {
    MarshallerHelper.checkClass(ExportClass.ATTACHEMENT, jsonElement)
    MarshallerHelper.checkIsNotNull('attachement.nom', jsonElement.nom)
    MarshallerHelper.checkIsNotNull('attachement.nomFichierOriginal', jsonElement.nomFichierOriginal)
    MarshallerHelper.checkIsNotNull('attachement.typeMime', jsonElement.typeMime)
    MarshallerHelper.checkIsNotNull('attachement.chemin', jsonElement.chemin)

    return new AttachementDto(
        questionAttachementId: jsonElement.questionAttachementId,
        nom: jsonElement.nom,
        nomFichierOriginal: jsonElement.nomFichierOriginal,
        typeMime: jsonElement.typeMime,
        chemin: jsonElement.chemin,
        estInsereDansLaQuestion: jsonElement.estInsereDansLaQuestion,
        blob: attachementDataStore.getBlobBase64(jsonElement.chemin)
    )
  }
}


