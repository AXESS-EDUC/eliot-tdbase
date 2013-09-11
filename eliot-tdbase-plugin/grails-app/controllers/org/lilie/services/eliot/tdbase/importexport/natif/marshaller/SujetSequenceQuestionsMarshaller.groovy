package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.ReferentielSujetSequenceQuestions
import org.lilie.services.eliot.tdbase.SujetSequenceQuestions
import org.lilie.services.eliot.tdbase.importexport.dto.SujetSequenceQuestionsDto

/**
 * Marshaller qui permet de convertir une séquence de question d'un sujet en une représentation à base de Map
 * qui pourra ensuite être convertie en XML ou en JSON
 *
 * @author John Tranier
 */
class SujetSequenceQuestionsMarshaller {

  QuestionMarshaller questionMarshaller

  Map marshall(SujetSequenceQuestions sujetSequenceQuestions, AttachementDataStore attachementDataStore) {
    if (!sujetSequenceQuestions) {
      throw new IllegalArgumentException("sujetSequenceQuestions ne peut pas être null")
    }

    MarshallerHelper.checkIsNotNull('rang', sujetSequenceQuestions.rang)
    MarshallerHelper.checkIsNotNull('question', sujetSequenceQuestions.question)
    MarshallerHelper.checkIsNotNull('points', sujetSequenceQuestions.points)

    Map representation = [
        class: ExportClass.SUJET_SEQUENCE_QUESTIONS.name(),
        rang: sujetSequenceQuestions.rang,
        noteSeuilPoursuite: sujetSequenceQuestions.noteSeuilPoursuite,
        points: sujetSequenceQuestions.points,
        question: questionMarshaller.marshall(sujetSequenceQuestions.question, attachementDataStore)
    ]

    return representation
  }

  static SujetSequenceQuestionsDto parse(JSONElement jsonElement,
                                         AttachementDataStore attachementDataStore) {
    MarshallerHelper.checkClass(ExportClass.SUJET_SEQUENCE_QUESTIONS, jsonElement)
    MarshallerHelper.checkIsNotNull('rang', jsonElement.rang)
    MarshallerHelper.checkIsNotNull('points', jsonElement.points)
    MarshallerHelper.checkIsJsonElement('question', jsonElement.question)

    return new SujetSequenceQuestionsDto(
        referentielSujetSequenceQuestions: new ReferentielSujetSequenceQuestions(
            rang: jsonElement.rang,
            noteSeuilPoursuite: MarshallerHelper.jsonObjectToObject(jsonElement.noteSeuilPoursuite),
            points: MarshallerHelper.jsonObjectToObject(jsonElement.points)
        ),
        question: QuestionMarshaller.parse(jsonElement.question, attachementDataStore)
    )
  }
}
