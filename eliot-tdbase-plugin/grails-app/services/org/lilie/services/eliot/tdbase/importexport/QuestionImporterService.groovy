package org.lilie.services.eliot.tdbase.importexport

import org.lilie.services.eliot.tdbase.ArtefactAutorisationService
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionAttachement
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionType
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.ReferentielEliot
import org.lilie.services.eliot.tdbase.ReferentielSujetSequenceQuestions
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAtomiqueDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAttachementDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionCompositeDto
import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.annuaire.Personne
import org.springframework.context.ApplicationContext
import org.springframework.context.ApplicationContextAware

/**
 * Service d'import de questions
 * @author John Tranier
 */
@SuppressWarnings('GrailsStatelessService')
class QuestionImporterService implements ApplicationContextAware {

  static transactional = true

  ArtefactAutorisationService artefactAutorisationService
  QuestionService questionService
  SujetService sujetService
  AttachementImporterService attachementImporterService

  ApplicationContext applicationContext
  SujetImporterService sujetImporterServiceBean // Note : injection manuelle pour éviter de tomber dans une dépendance circulaire

  SujetImporterService getSujetImporterService() {
    if (!sujetImporterServiceBean) {
      sujetImporterServiceBean = applicationContext.getBean('sujetImporterService')
    }
    return sujetImporterServiceBean
  }

  Question importeQuestion(QuestionCompositeDto questionDto,
                           Sujet sujet,
                           Personne importeur,
                           ReferentielEliot referentielEliot = null,
                           ReferentielSujetSequenceQuestions referentielSujetSequenceQuestions = null) {
    Sujet exercice = sujetImporterService.importeSujet(
        questionDto.exercice,
        importeur,
        referentielEliot
    )

    if (sujet) {
      sujetService.insertQuestionInSujet(
          exercice.questionComposite,
          sujet,
          importeur,
          referentielSujetSequenceQuestions
      )
    }

    return exercice.questionComposite
  }

  /**
   * Importe une question à partir de sa description au format QuestionDto
   * dans un sujet
   */
  Question importeQuestion(QuestionAtomiqueDto questionDto,
                           Sujet sujet,
                           Personne importeur,
                           ReferentielEliot referentielEliot = null,
                           ReferentielSujetSequenceQuestions referentielSujetSequenceQuestions = null) {

    if (sujet) {
      assert (artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet))
    }

    // Récupération du QuestionType & du QuestionSpecificationService
    QuestionType questionType = QuestionTypeEnum.valueOf(questionDto.type).questionType
    QuestionSpecificationService specService = questionService.questionSpecificationServiceForQuestionType(
        questionType
    )

    // Récupération du copyrightsType
    CopyrightsType copyrightsType = CopyrightsTypeEnum.parseFromCode(
        questionDto.copyrightsType.code
    ).copyrightsType

    // permet de securiser l'import :
    // on traduit en objet specification
    // on reutilise le Question service
    def objSpec = specService.getObjectFromSpecification(questionDto.specification)

    Question question = questionService.createQuestion(
        [
            titre: questionDto.titre,
            type: questionType,
            matiereBcn: referentielEliot?.matiereBcn,
            niveau: referentielEliot?.niveau,
            estAutonome: questionDto.estAutonome,
            paternite: questionDto.paternite,
            versionQuestion: questionDto.versionQuestion,
            copyrightsType: copyrightsType
        ],
        objSpec,
        importeur
    )
    assert !question.hasErrors()

    if (sujet) {
      sujetService.insertQuestionInSujet(
          question,
          sujet,
          importeur,
          referentielSujetSequenceQuestions
      )
    }

    if (questionDto.principalAttachement) {
      attachementImporterService.importePrincipalAttachement(questionDto.principalAttachement, question)
    }

    if (questionDto.questionAttachements) {
      List<QuestionAttachement> allCreatedQuestionAttachement =
        attachementImporterService.importeQuestionAttachements(questionDto.questionAttachements, question)

      Map tableCorrespondanceId = creeTableCorrespondanceId(
          questionDto.questionAttachements,
          allCreatedQuestionAttachement
      )

      def specification = question.specificationObject.actualiseAllQuestionAttachementId(tableCorrespondanceId)
      questionService.updateQuestionSpecificationForObject(question, specification)
      question.save(flush: true, failOnError: true)
    }

    return question
  }

  Map<Long, Long> creeTableCorrespondanceId(List<QuestionAttachementDto> allQuestionAttachementDto,
                                            List<QuestionAttachement> allCreatedQuestionAttachement) {
    assert allQuestionAttachementDto != null
    assert allCreatedQuestionAttachement != null

    Map<Long, Long> tableCorrespondanceId = [:]
    assert allQuestionAttachementDto.size() == allCreatedQuestionAttachement.size()

    allQuestionAttachementDto.eachWithIndex { QuestionAttachementDto questionAttachementDto, int i ->
      QuestionAttachement questionAttachement = allCreatedQuestionAttachement[i]
      assert questionAttachementDto.attachement.chemin == questionAttachement.attachement.chemin
      tableCorrespondanceId[questionAttachementDto.id] = questionAttachement.id
    }

    return tableCorrespondanceId
  }
}
