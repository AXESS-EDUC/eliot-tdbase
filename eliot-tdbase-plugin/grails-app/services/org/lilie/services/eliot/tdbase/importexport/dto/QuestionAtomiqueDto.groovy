package org.lilie.services.eliot.tdbase.importexport.dto

/**
 * @author John Tranier
 */
public class QuestionAtomiqueDto implements QuestionDto {
  String type
  String titre
  PersonneDto proprietaire
  Date dateCreated
  Date lastUpdated
  int versionQuestion
  Boolean estAutonome
  String paternite
  CopyrightsTypeDto copyrightsType
  EtablissementDto etablissement
  MatiereDto matiere
  NiveauDto niveau
  String specification
  PrincipalAttachementDto principalAttachement
  List<QuestionAttachementDto> questionAttachements
}
