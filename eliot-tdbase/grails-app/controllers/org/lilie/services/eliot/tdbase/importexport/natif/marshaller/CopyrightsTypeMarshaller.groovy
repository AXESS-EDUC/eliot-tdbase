package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.importexport.dto.CopyrightsTypeDto
import org.lilie.services.eliot.tice.CopyrightsType

/**
 * Marshaller qui permet de convertir un CopyrightsType en une représentation de type String
 *
 * @author John Tranier
 */
class CopyrightsTypeMarshaller {

  @SuppressWarnings('ReturnsNullInsteadOfEmptyCollection')
  Map marshall(CopyrightsType copyrightsType) {
    if (!copyrightsType) {
      return null
    }

    return [
        code: copyrightsType.code,
        presentation: copyrightsType.presentation,
        lien:  copyrightsType.lien,
        logo: copyrightsType.logo,
        optionCcPaternite: copyrightsType.optionCcPaternite,
        optionCcPasUtilisationCommerciale: copyrightsType.optionCcPasUtilisationCommerciale,
        optionCcPasModification: copyrightsType.optionCcPasModification,
        optionCcPartageViral: copyrightsType.optionCcPartageViral,
        optionTousDroitsReserves: copyrightsType.optionTousDroitsReserves
    ]
  }

  static CopyrightsTypeDto parse(JSONElement jsonElement) {
    MarshallerHelper.checkIsNotNull('metadonnees.copyrightsType.code', jsonElement.code)

    return new CopyrightsTypeDto(
        code: jsonElement.code,
        presentation: jsonElement.presentation,
        lien:  jsonElement.lien,
        logo: jsonElement.logo,
        optionCcPasUtilisationCommerciale: jsonElement.optionCcPasUtilisationCommerciale,
        optionCcPasModification: jsonElement.optionCcPasModification,
        optionCcPartageViral: jsonElement.optionCcPartageViral,
        optionTousDroitsReserves: jsonElement.optionTousDroitsReserves
    )
  }
}

