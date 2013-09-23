package org.lilie.services.eliot.tdbase.patch

import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionAttachement
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.springframework.context.ApplicationContext

/**
 * Patch à appliquer pour corriger l'anomalie TDB-40
 *
 * Descriptif de l'anomalie :
 * Pour certains types de question, la spécification contient des références aux identifiants des attachements
 * de la question (QuestionAttachement). En cas de copie d'une question, les QuestionAttachement de la question
 * sont dupliqués, mais les références dans la spécification ne sont pas mis à jour.
 *
 * Descriptif du correctif :
 * - Contrôle tous les types de questions impactés par l'anomalie (Document, FileUpload, FillGraphics & GraphicMatch)
 * - Un questionAttachementId référencé dans une spécification est considéré comme correct s'il est bien attaché à la
 * bonne question
 * - Si un questionAttachementId ne correspond plus à un QuestionAttachement en base, sa valeur est remplacée par null
 * dans la spécification (cela constitue une perte de données, mais permet de revenir à un état cohérent)
 * - Si un questionAttachementId correspond à un QuestionAttachement lié à une autre question (i.e. l'original de la
 * copie) le correctif suivant est appliqué :
 *    + Création d'un nouveau QuestionAttachement pour la question traitée & l'attachement lié au questionAttachement
 *    actuel
 *    + Remplacement dans la spécification du questionAttachementId par l'id du QuestionAttachement nouvellement créé
 *
 * @author John Tranier
 */
class PatchTDB40 implements Patch {

  ApplicationContext applicationContext

  final static String CODE = "TDB-40"
  private final static int BATCH_SIZE = 25

  void execute() {
    log.info "Applique le patch TDB-40"

    def criteria = Question.createCriteria()
    def allQuestionId = criteria.list {
      projections {
        property 'id'
      }
      'type' {
        'in'(
            'code',
            [
                QuestionTypeEnum.Document.name(),
                QuestionTypeEnum.FileUpload.name(),
                QuestionTypeEnum.FillGraphics.name(),
                QuestionTypeEnum.GraphicMatch.name()
            ]
        )
      }
    }

    allQuestionId.eachWithIndex { Long questionId, int num ->
      Question question = Question.get(questionId)
      verifieEtCorrigeSiNecessaire(question)

      if(num % BATCH_SIZE == 0) {
        cleanUpGorm()
      }
    }
  }

  private void verifieEtCorrigeSiNecessaire(Question question) {
    log.info "Vérifie la question ${question.id}"

    QuestionService questionService = applicationContext.getBean('questionService')

    QuestionSpecification questionSpecification = question.specificationObject
    List<Long> allQuestionAttachementId = questionSpecification.allQuestionAttachementId

    allQuestionAttachementId.each { Long questionAttachementId ->
      QuestionAttachement questionAttachement = QuestionAttachement.get(questionAttachementId)

      if (!questionAttachement) {
        log.info "Le questionAttachement n'existe plus : suppression de la spécification"

        // L'attachement n'existe plus, la seule solution est le mettre à null dans la spécification pour revenir à un état cohérent
        questionSpecification.remplaceQuestionAttachementId(questionAttachementId, null)
        return // sortie de l'itération du each
      }

      if (isQuestionAttachementCorrect(question, questionAttachement)) {
        log.info "Le questionAttachement ${questionAttachementId} est correct"
      } else {
        log.info "Le questionAttachement $questionAttachementId est incorrect : mise en oeuvre de la correction"
        QuestionAttachement questionAttachementCorrect = questionService.recopieQuestionAttachement(
            question,
            questionAttachement
        )

        questionSpecification.remplaceQuestionAttachementId(
            questionAttachementId,
            questionAttachementCorrect.id
        )
      }
    }

    questionService.updateQuestionSpecificationForObject(question, questionSpecification)
    question.save()
  }

  private boolean isQuestionAttachementCorrect(Question question, QuestionAttachement questionAttachement) {
    return questionAttachement.question.id == question.id
  }

  private void cleanUpGorm() {
    PatchExecution.withSession { def session ->
      session.flush()
      session.clear()
    }
  }
}
