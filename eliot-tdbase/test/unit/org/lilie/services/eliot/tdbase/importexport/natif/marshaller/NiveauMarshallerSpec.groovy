package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONObject
import org.lilie.services.eliot.tdbase.importexport.dto.NiveauDto
import org.lilie.services.eliot.tice.scolarite.Niveau
import spock.lang.Specification

/**
 * @author John Tranier
 */
class NiveauMarshallerSpec extends Specification {

  NiveauMarshaller niveauMarshaller = new NiveauMarshaller()

  def "testMarshall - cas général"() {
    given:
    Niveau niveau = new Niveau(
        libelleEdition: 'libelleEdition',
        libelleCourt: 'libelleCourt',
        libelleLong: 'libelleLong'
    )
    Map representation = niveauMarshaller.marshall(niveau)

    expect:
    representation.size() == 4
    representation.class == ExportClass.NIVEAU.name()
    representation.libelleCourt == niveau.libelleCourt
    representation.libelleEdition == niveau.libelleEdition
    representation.libelleLong == niveau.libelleLong
  }

  def "testMarshall - argument null"() {
    expect:
    niveauMarshaller.marshall(null) == null
  }

  def "testParse - cas général"(String libelleCourt, String libelleLong, String libelleEdition) {
    given:
    String json = """
      {
        class: '${ExportClass.NIVEAU}',
        libelleCourt: ${MarshallerHelper.asJsonString(libelleCourt)},
        libelleLong: ${MarshallerHelper.asJsonString(libelleLong)},
        libelleEdition: ${MarshallerHelper.asJsonString(libelleEdition)}
      }
    """

    NiveauDto niveauDto = NiveauMarshaller.parse(
        JSON.parse(json)
    )

    expect:
    niveauDto.libelleCourt == libelleCourt
    niveauDto.libelleLong == libelleLong
    niveauDto.libelleEdition == libelleEdition

    where:
    libelleCourt << [null, 'libelleCourt']
    libelleLong << [null, 'libelleLong']
    libelleEdition << [null, 'libelleEdition']
  }

  def "testParse - JSONObject.Null"() {
    expect:
    NiveauMarshaller.parse(new JSONObject.Null()) == null
  }
}
