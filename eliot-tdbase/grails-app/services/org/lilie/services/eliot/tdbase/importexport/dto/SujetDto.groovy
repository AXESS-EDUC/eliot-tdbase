package org.lilie.services.eliot.tdbase.importexport.dto

/**
 * @author John Tranier
 */
class SujetDto implements ArtefactDto {
  String titre
  PersonneDto proprietaire
  String type // Type.nom

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
