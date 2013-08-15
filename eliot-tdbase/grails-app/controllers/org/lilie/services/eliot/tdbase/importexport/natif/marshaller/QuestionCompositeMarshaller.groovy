package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionCompositeDto

/**
 * Marshaller qui permet de convertir une question composite en une représentation à base de Map
 * qui pourra ensuite être convertie en XML ou en JSON
 *
 * @author John Tranier
 */
class QuestionCompositeMarshaller {

  SujetMarshaller sujetMarshaller

  Map marshall(Question question) {
    if(!question.exercice) {
      throw new IllegalArgumentException("$question n'est pas une question de type Composite")
    }

    Map representation = [
        type: question.type.code,
        exercice: sujetMarshaller.marshall(question.exercice)
    ]

    return representation
  }

  static QuestionCompositeDto parse(JSONElement jsonElement) {
    if(jsonElement.type != QuestionTypeEnum.Composite.name()) {
      throw new MarshallerException(
          "Le type de la question n'est pas Composite",
          'type'
      )
    }
    MarshallerHelper.checkIsJsonElement('exercice', jsonElement.exercice)

    return new QuestionCompositeDto(
        exercice: SujetMarshaller.parse(jsonElement.exercice)
    )
  }
}
