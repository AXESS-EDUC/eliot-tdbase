package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * Marshaller qui permet de convertir un objet Personne en une représentation à base
 * de Map qui pourra ensuite être convertie en XML ou en JSON
 *
 * @author John Tranier
 */
class PersonneMarshaller {

  Map marshall(Personne personne) {
    if (!personne) {
      return null
    }

    return [
        nom: personne.nom,
        prenom: personne.prenom,
        identifiant: personne.autorite.identifiant
    ]
  }
}
