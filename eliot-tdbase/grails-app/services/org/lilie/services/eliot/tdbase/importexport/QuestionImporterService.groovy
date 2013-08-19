package org.lilie.services.eliot.tdbase.importexport

import org.lilie.services.eliot.tdbase.ArtefactAutorisationService
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionType
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.ReferentielEliot
import org.lilie.services.eliot.tdbase.ReferentielSujetSequenceQuestions
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAtomiqueDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionCompositeDto
import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.annuaire.Personne
import org.springframework.context.ApplicationContext
import org.springframework.context.ApplicationContextAware

/**
 * Service d'import de questions au format JSON natif eliot-tdbase
 * TODO reprendre cette javadoc
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

    sujetService.insertQuestionInSujet(
        exercice.questionComposite,
        sujet,
        importeur,
        referentielSujetSequenceQuestions
    )

    return exercice.questionComposite
  }

  /**
   * Importe une question à partir de sa description au format QuestionDto
   * dans un sujet
   */
  Question importeQuestion(QuestionAtomiqueDto questionDto, // TODO réduire le nb de param
                           Sujet sujet,
                           Personne importeur,
                           ReferentielEliot referentielEliot = null,
                           ReferentielSujetSequenceQuestions referentielSujetSequenceQuestions = null) {
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet))

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

    Question question = questionService.createQuestionAndInsertInSujet(
        [
            titre: questionDto.titre,
            type: questionType,
            matiere: referentielEliot?.matiere,
            niveau: referentielEliot?.niveau,
            estAutonome: questionDto.estAutonome,
            paternite: questionDto.paternite,
            versionQuestion: questionDto.versionQuestion,
            copyrightsType: copyrightsType
        ],
        objSpec,
        sujet,
        importeur,
        referentielSujetSequenceQuestions
    )

    if (questionDto.principalAttachement) {
      attachementImporterService.importePrincipalAttachement(questionDto.principalAttachement, question)
    }

    attachementImporterService.importeQuestionAttachements(questionDto.questionAttachements, question)

    return question
  }
}
