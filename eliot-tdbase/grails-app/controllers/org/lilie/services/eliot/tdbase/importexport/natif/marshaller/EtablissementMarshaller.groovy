package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.codehaus.groovy.grails.web.json.JSONElement
import org.codehaus.groovy.grails.web.json.JSONObject
import org.lilie.services.eliot.tdbase.importexport.dto.EtablissementDto
import org.lilie.services.eliot.tice.scolarite.Etablissement

/**
 * Marshaller qui permet de convertir un établissement en un représentation à base
 * de Map qui pourra ensuite être convertie en XML ou en JSON
 *
 * @author John Tranier
 */
class EtablissementMarshaller {

  @SuppressWarnings('ReturnsNullInsteadOfEmptyCollection')
  Map marshall(Etablissement etablissement) {
    if (!etablissement) {
      return null
    }

    return [
        class: ExportClass.ETABLISSEMENT.name(),
        nom: etablissement.nomAffichage,
        idExterne: etablissement.idExterne,
        uai: etablissement.uai,
        codePorteurENT: etablissement.codePorteurENT
    ]
  }

  static EtablissementDto parse(JSONElement jsonElement) {
    MarshallerHelper.checkClass(ExportClass.ETABLISSEMENT, jsonElement)
    return new EtablissementDto(
        nom: MarshallerHelper.jsonObjectToString(jsonElement.nom),
        idExterne: MarshallerHelper.jsonObjectToString(jsonElement.idExterne),
        uai: MarshallerHelper.jsonObjectToString(jsonElement.uai),
        codePorteurENT: MarshallerHelper.jsonObjectToString(jsonElement.codePorteurENT)
    )
  }

  static parse(JSONObject.Null jsonElement) {
    return null
  }

}

