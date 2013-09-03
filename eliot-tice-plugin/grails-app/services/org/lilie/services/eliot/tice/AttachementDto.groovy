package org.lilie.services.eliot.tice

/**
 * @author John Tranier
 */
class AttachementDto {
  long taille
  String typeMime
  String nom
  String nomFichierOriginal
  byte[] bytes

  InputStream getInputStream() {
    return new ByteArrayInputStream(bytes)
  }
}
