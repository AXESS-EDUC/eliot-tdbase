package org.lilie.services.eliot.tice

/**
 * Décrit une erreur liée à l'upload d'un attachement
 * @author John Tranier
 */
class AttachementUploadException extends IllegalArgumentException {

  AttachementUploadException(String s) {
    super(s)
  }

  AttachementUploadException(String s, Throwable throwable) {
    super(s, throwable)
  }

}
