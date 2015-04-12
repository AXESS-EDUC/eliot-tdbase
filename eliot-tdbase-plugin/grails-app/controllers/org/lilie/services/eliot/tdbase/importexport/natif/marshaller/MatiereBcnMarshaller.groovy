package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.codehaus.groovy.grails.web.json.JSONElement
import org.codehaus.groovy.grails.web.json.JSONObject
import org.lilie.services.eliot.tdbase.importexport.dto.MatiereBcnDto
import org.lilie.services.eliot.tice.nomenclature.MatiereBcn

/**
 * Marshaller qui permet de convertir une matière en une représentation à base de Map
 * qui pourra ensuite être convertie en XML ou en JSON
 *
 * @author John Tranier
 */
class MatiereBcnMarshaller {

  @SuppressWarnings('ReturnsNullInsteadOfEmptyCollection')
  Map marshall(MatiereBcn matiereBcn) {
    if(!matiereBcn) {
      return null
    }

    return [
        class: ExportClass.MATIERE_BCN.name(),
        identifiant: matiereBcn.id,
        bcnId: matiereBcn.bcnId,
        libelleLong: matiereBcn.libelleLong,
        libelleCourt: matiereBcn.libelleCourt,
        libelleEdition: matiereBcn.libelleEdition
    ]
  }

  static MatiereBcnDto parse(JSONElement jsonElement) {
    MarshallerHelper.checkClass(ExportClass.MATIERE_BCN, jsonElement)
    return new MatiereBcnDto(
        identifiant: MarshallerHelper.jsonObjectToObject(jsonElement.identifiant),
        bcnId: MarshallerHelper.jsonObjectToObject(jsonElement.bcnId),
        libelleLong: MarshallerHelper.jsonObjectToString(jsonElement.libelleLong),
        libelleCourt: MarshallerHelper.jsonObjectToString(jsonElement.libelleCourt),
        libelleEdition: MarshallerHelper.jsonObjectToString(jsonElement.libelleEdition)
    )
  }

  static parse(JSONObject.Null jsonElement) {
    return null
  }
}

