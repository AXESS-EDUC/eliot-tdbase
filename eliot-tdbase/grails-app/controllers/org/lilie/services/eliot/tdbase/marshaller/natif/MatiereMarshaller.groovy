package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tice.scolarite.Matiere

/**
 * Marshaller qui permet de convertir une matière en une représentation à base de Map
 * qui pourra ensuite être convertie en XML ou en JSON
 *
 * @author John Tranier
 */
class MatiereMarshaller {

  Map marshall(Matiere matiere) {
    if(!matiere) {
      return null
    }

    return [
        identifiant: matiere.id,
        codeSts: matiere.codeSts,
        codeGestion: matiere.codeGestion,
        libelleLong: matiere.libelleLong,
        libelleCourt: matiere.libelleCourt,
        libelleEdition: matiere.libelleEdition
    ]
  }
}
