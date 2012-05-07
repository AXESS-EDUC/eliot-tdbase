package org.lilie.services.eliot.tdbase.xml

import org.lilie.services.eliot.tdbase.Sujet

import org.springframework.context.ApplicationContext
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement

import org.lilie.services.eliot.tdbase.utils.TdBaseInitialisationTestService
import org.lilie.services.eliot.tdbase.SujetService
import org.springframework.context.ApplicationContextAware



class MoodleQuizExporterServiceIntegrationTest extends GroovyTestCase implements ApplicationContextAware {

  private static final String SUJET_TITRE = "Sujet test 1"
  static final INPUT = 'org/lilie/services/eliot/tdbase/xml/exemples/quiz-exemple-20120229-0812.xml'


  ApplicationContext applicationContext
  Utilisateur utilisateur1
  Personne personne1
  Utilisateur utilisateur2
  Personne personne2
  StructureEnseignement struct1ere


  TdBaseInitialisationTestService tdBaseInitialisationTestService
  SujetService sujetService
  MoodleQuizImporterService moodleQuizImporterService
  MoodleQuizExporterService moodleQuizExporterService

  protected void setUp() {
    super.setUp()
    utilisateur1 = tdBaseInitialisationTestService.getUtilisateur1()
    personne1 = utilisateur1.personne
    utilisateur2 = tdBaseInitialisationTestService.getUtilisateur2()
    personne2 = utilisateur2.personne
    struct1ere = tdBaseInitialisationTestService.findStructure1ere()
  }

  protected void tearDown() {
    super.tearDown()
  }

  void testRoundTrip() {
    Sujet sujet = sujetService.createSujet(personne1, SUJET_TITRE)
    assertFalse(sujet.hasErrors())

    def xmlInput = applicationContext.getResource("classpath:$INPUT").getInputStream().bytes

    MoodleQuizImportReport report = moodleQuizImporterService.importMoodleQuiz(
            xmlInput, sujet, sujet.matiere, sujet.niveau, personne1
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
            xmlOutput.bytes, sujet2, sujet2.matiere, sujet2.niveau, personne1
    )

    assert report2.nombreItemsTraites == 7
    assert report2.itemsImportes.size() == 7
    assert report2.itemsNonImportes.size() == 0
  }
}
