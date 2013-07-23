package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.codehaus.groovy.grails.web.json.JSONElement
import org.codehaus.groovy.grails.web.json.JSONObject
import org.lilie.services.eliot.tdbase.importexport.dto.NiveauDto
import org.lilie.services.eliot.tice.scolarite.Niveau

/**
 * Marshaller qui permet de convertir un niveau en une représentation à base de Map
 * qui pourra ensuite être convertie en XML ou JSON
 *
 * @author John Tranier
 */
class NiveauMarshaller {

  @SuppressWarnings('ReturnsNullInsteadOfEmptyCollection')
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

  static NiveauDto parse(JSONElement jsonElement) {
    return new NiveauDto(
        libelleCourt: MarshallerHelper.jsonObjectToString(jsonElement.libelleCourt),
        libelleLong: MarshallerHelper.jsonObjectToString(jsonElement.libelleLong),
        libelleEdition: MarshallerHelper.jsonObjectToString(jsonElement.libelleEdition)
    )
  }

  static parse(JSONObject.Null jsonElement) {
    return null
  }
}

