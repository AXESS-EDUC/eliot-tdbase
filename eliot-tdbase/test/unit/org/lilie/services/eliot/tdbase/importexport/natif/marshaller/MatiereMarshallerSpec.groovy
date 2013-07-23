package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONObject
import org.lilie.services.eliot.tdbase.importexport.dto.MatiereDto
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MarshallerHelper
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MatiereMarshaller
import org.lilie.services.eliot.tice.scolarite.Matiere
import spock.lang.Specification

/**
 * @author John Tranier
 */
class MatiereMarshallerSpec extends Specification {

  MatiereMarshaller matiereMarshaller

  def setup() {
    matiereMarshaller = new MatiereMarshaller()
  }

  def "testMarshall - cas général"(Matiere matiere) {
    given:
    Map representation = matiereMarshaller.marshall(matiere)

    expect:
    representation.size() == 6
    representation.identifiant == matiere.id
    representation.codeSts == matiere.codeSts
    representation.codeGestion == matiere.codeGestion
    representation.libelleLong == matiere.libelleLong
    representation.libelleCourt == matiere.libelleCourt
    representation.libelleEdition == matiere.libelleEdition

    where:
    matiere = new Matiere(
        id: 123,
        codeSts: "codeSts",
        codeGestion: "codeGestion",
        libelleLong: "libelleLong",
        libelleCourt: "libelleCourt",
        libelleEdition: "libelleEdition"
    )
  }

  def "testMarshall - argument null"() {
    expect:
    matiereMarshaller.marshall(null) == null
  }

  def "testParse - cas général"(Long identifiant,
                                String codeSts,
                                String codeGestion,
                                String libelleLong,
                                String libelleCourt,
                                String libelleEdition) {
    given:
    String json = """
      {
        identifiant: $identifiant,
        codeSts: ${MarshallerHelper.asJsonString(codeSts)},
        codeGestion: ${MarshallerHelper.asJsonString(codeGestion)},
        libelleLong: ${MarshallerHelper.asJsonString(libelleLong)},
        libelleCourt: ${MarshallerHelper.asJsonString(libelleCourt)},
        libelleEdition: ${MarshallerHelper.asJsonString(libelleEdition)}
      }
    """

    MatiereDto matiereDto = MatiereMarshaller.parse(
        JSON.parse(json)
    )

    expect:
    matiereDto.identifiant == identifiant
    matiereDto.codeSts == codeSts
    matiereDto.codeGestion == codeGestion
    matiereDto.libelleLong == libelleLong
    matiereDto.libelleCourt == libelleCourt
    matiereDto.libelleEdition == libelleEdition

    where:
    identifiant << [null, 123]
    codeSts << [null, 'codeSts']
    codeGestion << [null, 'codeGestion']
    libelleLong << [null, 'libelleLong']
    libelleCourt << [null, 'libelleCourt']
    libelleEdition << [null, 'libelleEdition']
  }

  def "testParse - JSONObject.Null"() {
    expect:
    MatiereMarshaller.parse(new JSONObject.Null()) == null
  }
}
