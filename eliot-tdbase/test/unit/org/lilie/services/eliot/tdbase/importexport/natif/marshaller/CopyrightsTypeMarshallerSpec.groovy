package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.lilie.services.eliot.tdbase.importexport.dto.CopyrightsTypeDto
import org.lilie.services.eliot.tice.CopyrightsType
import spock.lang.Specification

/**
 * @author John Tranier
 */
class CopyrightsTypeMarshallerSpec extends Specification {

  CopyrightsTypeMarshaller copyrightsTypeMarshaller

  def setup() {
    copyrightsTypeMarshaller = new CopyrightsTypeMarshaller()
  }

  def "testMarshall - cas général"(Boolean optionCcPaternite,
                                   Boolean optionCcPasUtilisationCommerciale,
                                   Boolean optionCcPasModification,
                                   Boolean optionCcPartageViral,
                                   Boolean optionTousDroitsReserves) {
    given:
    CopyrightsType copyrightsType = new CopyrightsType(
        code: "code",
        presentation: "presentation",
        lien: "lien",
        logo: "logo",
        optionCcPaternite: optionCcPaternite,
        optionCcPasUtilisationCommerciale: optionCcPasUtilisationCommerciale,
        optionCcPasModification: optionCcPasModification,
        optionCcPartageViral: optionCcPartageViral,
        optionTousDroitsReserves: optionTousDroitsReserves,
    )

    Map representation = copyrightsTypeMarshaller.marshall(copyrightsType)

    expect:
    representation.size() == 9
    representation.code == copyrightsType.code
    representation.presentation == copyrightsType.presentation
    representation.lien == copyrightsType.lien
    representation.logo == copyrightsType.logo
    representation.optionCcPaternite == copyrightsType.optionCcPaternite
    representation.optionCcPasUtilisationCommerciale == copyrightsType.optionCcPasUtilisationCommerciale
    representation.optionCcPasModification == copyrightsType.optionCcPasModification
    representation.optionCcPartageViral == copyrightsType.optionCcPartageViral
    representation.optionTousDroitsReserves == copyrightsType.optionTousDroitsReserves

    where:
    optionCcPaternite << [true, false]
    optionCcPasUtilisationCommerciale << [true, false]
    optionCcPasModification << [true, false]
    optionCcPartageViral << [true, false]
    optionTousDroitsReserves << [true, false]
  }

  def "testMarshall - argument null"() {
    expect:
    copyrightsTypeMarshaller.marshall(null) == null
  }

  def "testParse - cas général"(String code) {
    given:
    String json = "{code: '$code'}"

    CopyrightsTypeDto copyrightsTypeDto =
      CopyrightsTypeMarshaller.parse(
          JSON.parse(json)
      )

    expect:
    copyrightsTypeDto.code == code

    where:
    code = 'code'
  }

  def "testParse - erreur code manquant"() {
    given:
    String json = '{}'

    when:
    CopyrightsTypeMarshaller.parse(
        JSON.parse(json)
    )

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'metadonnees.copyrightsType.code'
  }
}
