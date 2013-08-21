package org.lilie.services.eliot.tdbase.importexport

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

  def setup() {
    sujetService = Mock(SujetService)
    sujetExporterService = new SujetExporterService(
        sujetService: sujetService
    )
  }

  def "testGetSujetPourExport - OK"() {
    given:
    Sujet sujet = new Sujet()
    Personne exporteur = new Personne()

    when:
    Sujet sujetPourExport = sujetExporterService.getSujetPourExport(sujet, exporteur)

    then:
    1 * sujetService.marquePaternite(sujet, exporteur)

    then:
    sujetPourExport == sujet
  }
}
