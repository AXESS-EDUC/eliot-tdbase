package org.lilie.services.eliot.tdbase.impl

import org.lilie.services.eliot.tdbase.QuestionSpecification

/**
 * Implémentation partielle de l'interface QuestionSpecification commune à tous les types
 * de spécification qui ne contiennent aucune référence à des QuestionAttachement
 * @author John Tranier
 */
abstract class AbstractQuestionSpecificationSansAttachement implements QuestionSpecification {

  @Override
  QuestionSpecification actualiseAllQuestionAttachementId(Map<Long, Long> tableCorrespondanceId) {
    // Aucun id à actualiser dans cette spécification
    return this
  }

  @Override
  QuestionSpecification remplaceQuestionAttachementId(Long ancienId, Long nouvelId) {
    // Aucun id à actualiser dans cette spécification
    return this
  }

  @Override
  List<Long> getAllQuestionAttachementId() {
    // Aucun QuestionAttachement utilisé dans cette spécification
    return []
  }
}
