package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tice.scolarite.Etablissement

/**
 * Marshaller qui permet de convertir un établissement en un représentation à base
 * de Map qui pourra ensuite être convertie en XML ou en JSON
 *
 * @author John Tranier
 */
class EtablissementMarshaller {

  Map marshall(Etablissement etablissement) {
    if (!etablissement) {
      return null
    }

    return [
        nom: etablissement.nomAffichage,
        idExterne: etablissement.idExterne,
        uai: etablissement.uai,
        codePorteurENT: etablissement.codePorteurENT
    ]
  }
}
