package org.lilie.services.eliot.tdbase.importexport.natif

import grails.converters.JSON
import org.lilie.services.eliot.tdbase.ArtefactAutorisationService
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.QuestionType
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAtomiqueDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionCompositeDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionDto
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.QuestionMarshaller
import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.springframework.context.ApplicationContext
import org.springframework.context.ApplicationContextAware

/**
 * Service d'import de questions au format JSON natif eliot-tdbase
 * @author John Tranier
 */
class QuestionImporterService implements ApplicationContextAware {

  static transactional = true

  ArtefactAutorisationService artefactAutorisationService
  QuestionService questionService
  SujetService sujetService
  AttachementImporterService attachementImporterService
  ApplicationContext applicationContext
  SujetImporterService sujetImporterServiceBean // Note injection manuelle pour éviter de tomber dans une dépendance circulaire

  SujetImporterService getSujetImporterService() {
    if (!sujetImporterServiceBean) {
      sujetImporterServiceBean = applicationContext.getBean('sujetImporterService')
    }
    return sujetImporterServiceBean
  }

/**
 * Importe une question depuis un fichier JSON au format natif eliot-tdbase
 * dans un sujet
 */
  Question importeQuestion(byte[] jsonBlob, // TODO ce service ne devrait pas dépendre du format & ne devrait donc pas être dans le package natif
                           Sujet sujet,
                           Personne importeur,
                           Matiere matiere = null,
                           Niveau niveau = null,
                           Integer rang = null,
                           Float noteSeuilPoursuite = null,
                           Float points = null) {
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(importeur, sujet))

    QuestionDto questionDto = QuestionMarshaller.parse(
        JSON.parse(new ByteArrayInputStream(jsonBlob), 'UTF-8')
    )

    return importeQuestion(
        questionDto,
        sujet,
        importeur,
        matiere,
        niveau,
        rang,
        noteSeuilPoursuite,
        points
    )
  }

  Question importeQuestion(QuestionDto questionDto,
                           Sujet sujet,
                           Personne importeur,
                           Matiere matiere = null,
                           Niveau niveau = null,
                           Integer rang = null,
                           Float noteSeuilPoursuite = null,
                           Float points = null) {
    if (questionDto instanceof QuestionAtomiqueDto) {
      return importeQuestion(
          questionDto,
          sujet,
          importeur,
          matiere,
          niveau,
          rang,
          noteSeuilPoursuite,
          points
      )
    } else if (questionDto instanceof QuestionCompositeDto) {

      return importeQuestion(
          questionDto,
          sujet,
          importeur,
          matiere,
          niveau,
          rang,
          noteSeuilPoursuite,
          points
      )
    }

    throw new IllegalStateException(
        "questionDto est une instance de ${questionDto.class} : gestion non implémentée"
    )
  }

  Question importeQuestion(QuestionCompositeDto questionDto,
                           Sujet sujet,
                           Personne importeur,
                           Matiere matiere = null,
                           Niveau niveau = null,
                           Integer rang = null,
                           Float noteSeuilPoursuite = null,
                           Float points = null) {
    Sujet exercice = sujetImporterService.importeSujet(
        questionDto.exercice,
        importeur,
        matiere,
        niveau
    )

    sujetService.insertQuestionInSujet(
        exercice.questionComposite,
        sujet,
        importeur,
        rang,
        noteSeuilPoursuite,
        points
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
                           Matiere matiere = null,
                           Niveau niveau = null,
                           Integer rang = null,
                           Float noteSeuilPoursuite = null,
                           Float points = null) {
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
            matiere: matiere,
            niveau: niveau,
            estAutonome: questionDto.estAutonome,
            paternite: questionDto.paternite,
            versionQuestion: questionDto.versionQuestion,
            copyrightsType: copyrightsType
        ],
        objSpec,
        sujet,
        importeur,
        rang,
        noteSeuilPoursuite,
        points
    )

    if (questionDto.principalAttachement) {
      attachementImporterService.importePrincipalAttachement(questionDto.principalAttachement, question)
    }

    attachementImporterService.importeQuestionAttachements(questionDto.questionAttachements, question)

    return question
  }
}
