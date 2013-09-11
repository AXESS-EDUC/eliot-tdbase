package org.lilie.services.eliot.tdbase.importexport

import org.lilie.services.eliot.tdbase.ArtefactAutorisationService
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * Service dédié à l'export d'une question
 *
 * Ce service prend en charge :
 *  - la gestion de la sécurité
 *  - les opérations éventuelles à effectuer sur la question à exporter
 *  - la récupération des données nécessaires à l'export (le marshalling de la question depuis
 * un contrôleur ne devrait pas générer de nouvelles requêtes Hibernate)
 *
 * @author John Tranier
 */
class QuestionExporterService {

  static transactional = true

  QuestionService questionService
  ArtefactAutorisationService artefactAutorisationService

  Question getQuestionPourExport(Question question, Personne exporteur) {
    assert artefactAutorisationService.utilisateurPeutReutiliserArtefact(exporteur, question)

    // TODO fetcher les données

    return question
  }
}
