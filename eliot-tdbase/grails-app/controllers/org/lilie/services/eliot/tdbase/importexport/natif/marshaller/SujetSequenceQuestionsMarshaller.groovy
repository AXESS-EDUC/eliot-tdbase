package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.lilie.services.eliot.tdbase.SujetSequenceQuestions

/**
 * Marshaller qui permet de convertir une séquence de question d'un sujet en une représentation à base de Map
 * qui pourra ensuite être convertie en XML ou en JSON
 *
 * @author John Tranier
 */
class SujetSequenceQuestionsMarshaller {

  QuestionMarshaller questionMarshaller

  Map marshall(SujetSequenceQuestions sujetSequenceQuestions) {
    if (!sujetSequenceQuestions) {
      throw new IllegalArgumentException("sujetSequenceQuestions ne peut pas être null")
    }

    Map representation = [
        rang: sujetSequenceQuestions.rang,
        noteSeuilPoursuite: sujetSequenceQuestions.noteSeuilPoursuite,
        points: sujetSequenceQuestions.points,
        question: questionMarshaller.marshall(sujetSequenceQuestions.question)
    ]

    return representation
  }
}
