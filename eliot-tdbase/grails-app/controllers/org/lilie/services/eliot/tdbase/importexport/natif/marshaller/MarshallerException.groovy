package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

/**
 * Exception qui peut se produire lors du Marshalling ou du Parsing d'un sujet ou d'une question
 * pour le format JSON natif d'eliot-tdbase.
 *
 * Cette exception exprime que la structure de données incorrecte (attribut obligatoire absent ou
 * de type incorrect).
 *
 * @author John Tranier
 */
class MarshallerException extends IllegalStateException {

  String attribut

  MarshallerException(String message, String attribut) {
    super(message)
    this.attribut = attribut
  }

}
