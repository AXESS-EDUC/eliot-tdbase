package org.lilie.services.eliot.tdbase.xml

import org.lilie.services.eliot.tdbase.ReferentielEliot
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tice.utils.BootstrapService
import org.springframework.context.ApplicationContext
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement

import org.lilie.services.eliot.tdbase.SujetService
import org.springframework.context.ApplicationContextAware



class MoodleQuizExporterServiceIntegrationTest extends GroovyTestCase implements ApplicationContextAware {

  private static final String SUJET_TITRE = "Sujet test 1"
  static final INPUT = 'org/lilie/services/eliot/tdbase/xml/exemples/quiz-exemple-20120229-0812.xml'


  ApplicationContext applicationContext
  Personne personne1
  Personne personne2
  StructureEnseignement struct1ere


  BootstrapService bootstrapService
  SujetService sujetService
  MoodleQuizImporterService moodleQuizImporterService
  MoodleQuizExporterService moodleQuizExporterService

  protected void setUp() {
    super.setUp()
    bootstrapService.bootstrapForIntegrationTest()
    personne1 = bootstrapService.enseignant1
    personne2 = bootstrapService.enseignant2
    struct1ere = bootstrapService.classe1ere
  }

  protected void tearDown() {
    super.tearDown()
  }

  void testRoundTrip() {
    Sujet sujet = sujetService.createSujet(personne1, SUJET_TITRE)
    assertFalse(sujet.hasErrors())

    def xmlInput = applicationContext.getResource("classpath:$INPUT").getInputStream().bytes

    MoodleQuizImportReport report = moodleQuizImporterService.importMoodleQuiz(
        xmlInput,
        sujet,
        new ReferentielEliot(
            matiere: sujet.matiere,
            niveau: sujet.niveau
        ),
        personne1
    )
    assert report.nombreItemsTraites == 11
    assert report.itemsImportes.size() == 9
    assert report.itemsNonImportes.size() == 2

    def xmlOutput = moodleQuizExporterService.toMoodleQuiz(sujet)

    // check that base64 encoding and decoding works.

    println xmlOutput
    assertTrue(xmlOutput.contains("4AAQSkZJRgABAQEAqwCrAAD"))

    Sujet sujet2 = sujetService.createSujet(personne1, SUJET_TITRE + "Re-import")
    MoodleQuizImportReport report2 = moodleQuizImporterService.importMoodleQuiz(
        xmlOutput.bytes,
        sujet2,
        new ReferentielEliot(
            matiere: sujet2.matiere,
            niveau: sujet2.niveau
        ),
        personne1
    )

    assert report2.nombreItemsTraites == 7
    assert report2.itemsImportes.size() == 7
    assert report2.itemsNonImportes.size() == 0
  }
}
