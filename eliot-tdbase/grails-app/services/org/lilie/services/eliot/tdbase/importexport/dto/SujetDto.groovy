package org.lilie.services.eliot.tdbase.importexport.dto

/**
 * @author John Tranier
 */
class SujetDto {
  String titre
  PersonneDto proprietaire
  String type

  int versionSujet
  String presentation
  String annotationPrivee
  Integer dureeMinutes
  Float noteMax
  Float noteAutoMax
  Float noteEnseignantMax
  Boolean accesSequentiel // TODO à quoi ça sert ?
  Boolean ordreQuestionsAleatoire
  String paternite

  CopyrightsTypeDto copyrightsType

  // TODO List<SujetSequenceQuestions> questionsSequences
}
