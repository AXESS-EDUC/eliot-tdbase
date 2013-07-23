package org.lilie.services.eliot.tdbase.importexport.dto

/**
 * @author John Tranier
 */
class AttachementDto {
  String nom
  String nomFichierOriginal
  String typeMime
  String blob // Encodé en base64
  Boolean estInsereDansLaQuestion
}
