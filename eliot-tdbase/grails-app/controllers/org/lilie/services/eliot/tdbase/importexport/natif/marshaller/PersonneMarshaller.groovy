package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.importexport.dto.PersonneDto
import org.lilie.services.eliot.tice.annuaire.Personne

/**
 * Marshaller qui permet de convertir un objet Personne en une représentation à base
 * de Map qui pourra ensuite être convertie en XML ou en JSON
 *
 * @author John Tranier
 */
class PersonneMarshaller {

  @SuppressWarnings('ReturnsNullInsteadOfEmptyCollection')
  Map marshall(Personne personne) {
    if (!personne) {
      return null
    }

    MarshallerHelper.checkIsNotNull('personne.identifiant', personne.autorite.identifiant)

    return [
        class: ExportClass.PERSONNE.name(),
        nom: personne.nom,
        prenom: personne.prenom,
        identifiant: personne.autorite.identifiant
    ]
  }

  static PersonneDto parse(JSONElement jsonElement) {
    MarshallerHelper.checkClass(ExportClass.PERSONNE, jsonElement)
    MarshallerHelper.checkIsNotNull('personne.identifiant', jsonElement.identifiant)

    return new PersonneDto(
        nom: MarshallerHelper.jsonObjectToString(jsonElement.nom),
        prenom: MarshallerHelper.jsonObjectToString(jsonElement.prenom),
        identifiant: jsonElement.identifiant
    )
  }
}

