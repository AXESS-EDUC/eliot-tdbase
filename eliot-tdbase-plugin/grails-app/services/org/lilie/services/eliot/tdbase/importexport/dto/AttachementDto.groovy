package org.lilie.services.eliot.tdbase.importexport.dto

/**
 * @author John Tranier
 */
class AttachementDto {
  Long questionAttachementId
  String nom
  String nomFichierOriginal
  String typeMime
  String chemin
  String blob // Encodé en base64
  Boolean estInsereDansLaQuestion
}
