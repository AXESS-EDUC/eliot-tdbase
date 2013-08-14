package org.lilie.services.eliot.tdbase.importexport.dto

/**
 * @author John Tranier
 */
class SujetDto {
  String titre
  PersonneDto proprietaire
  long type // TODO est-ce qu'on ne peut pas passer par un code ?

  int versionSujet
  String presentation
  String annotationPrivee
  Integer dureeMinutes
  Float noteMax
  Float noteAutoMax
  Float noteEnseignantMax
  Boolean accesSequentiel
  Boolean ordreQuestionsAleatoire
  String paternite

  CopyrightsTypeDto copyrightsType

  List<SujetSequenceQuestionsDto> questionsSequences
}
