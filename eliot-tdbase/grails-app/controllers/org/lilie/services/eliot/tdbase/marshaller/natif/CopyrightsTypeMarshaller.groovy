package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tice.CopyrightsType

/**
 * Marshaller qui permet de convertir un CopyrightsType en une représentation de type String
 *
 * @author John Tranier
 */
class CopyrightsTypeMarshaller {

  String marshall(CopyrightsType copyrightsType) {
    if(!copyrightsType) {
      return null
    }

    return copyrightsType.code
  }
}
