package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tice.scolarite.Niveau

/**
 * Marshaller qui permet de convertir un niveau en une représentation à base de Map
 * qui pourra ensuite être convertie en XML ou JSON
 *
 * @author John Tranier
 */
class NiveauMarshaller {

  Map marshall(Niveau niveau) {
    if(!niveau) {
      return null
    }

    return [
        libelleCourt: niveau.libelleCourt,
        libelleLong: niveau.libelleLong,
        libelleEdition: niveau.libelleEdition
    ]
  }
}
