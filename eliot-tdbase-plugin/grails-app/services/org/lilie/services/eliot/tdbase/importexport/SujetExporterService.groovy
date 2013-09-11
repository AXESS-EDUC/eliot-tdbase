package org.lilie.services.eliot.tdbase.importexport

import org.lilie.services.eliot.tdbase.ArtefactAutorisationService
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * Service dédié à l'export d'un sujet
 *
 * Ce service prend en charge :
 *  - la gestion de la sécurité
 *  - les opérations éventuelles à effectuer sur la question à exporter
 *  - la récupération des données nécessaires à l'export (le marshalling de la question depuis
 * un contrôleur ne devrait pas générer de nouvelles requêtes Hibernate)
 *
 * @author John Tranier
 */
class SujetExporterService {
  static transactional = true

  SujetService sujetService
  ArtefactAutorisationService artefactAutorisationService

  Sujet getSujetPourExport(Sujet sujet, Personne exporteur) {
    assert artefactAutorisationService.utilisateurPeutReutiliserArtefact(exporteur, sujet)

    // TODO fetcher les données

    return sujet
  }
}
