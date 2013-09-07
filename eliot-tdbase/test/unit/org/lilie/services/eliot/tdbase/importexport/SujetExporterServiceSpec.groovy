package org.lilie.services.eliot.tdbase.importexport

import org.lilie.services.eliot.tdbase.ArtefactAutorisationService
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tice.annuaire.Personne
import spock.lang.Specification

/**
 * @author John Tranier
 */
class SujetExporterServiceSpec extends Specification {
  SujetService sujetService
  SujetExporterService sujetExporterService
  ArtefactAutorisationService artefactAutorisationService

  def setup() {
    sujetService = Mock(SujetService)
    artefactAutorisationService = Mock(ArtefactAutorisationService)
    sujetExporterService = new SujetExporterService(
        sujetService: sujetService,
        artefactAutorisationService: artefactAutorisationService
    )
  }

  def "testGetSujetPourExport - OK"() {
    given:
    Sujet sujet = new Sujet()
    Personne exporteur = new Personne()

    when:
    Sujet sujetPourExport = sujetExporterService.getSujetPourExport(sujet, exporteur)

    then:
    1 * artefactAutorisationService.utilisateurPeutReutiliserArtefact(exporteur, sujet) >> true

    then:
    sujetPourExport == sujet
  }

  def "testGetSujetPourExport - erreur : l'utilisateur ne peut pas réutiliser le sujet"() {
    given:
    Sujet sujet = new Sujet()
    Personne exporteur = new Personne()

    when:
    sujetExporterService.getSujetPourExport(sujet, exporteur)

    then:
    1 * artefactAutorisationService.utilisateurPeutReutiliserArtefact(exporteur, sujet) >> false

    then:
    thrown(Error)
  }
}
