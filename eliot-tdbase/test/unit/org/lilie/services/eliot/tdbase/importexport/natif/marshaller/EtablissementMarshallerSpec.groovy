package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONObject
import org.lilie.services.eliot.tdbase.importexport.dto.EtablissementDto
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.EtablissementMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MarshallerHelper
import org.lilie.services.eliot.tice.scolarite.Etablissement
import spock.lang.Specification

/**
 * @author John Tranier
 */
class EtablissementMarshallerSpec extends Specification {

  EtablissementMarshaller etablissementMarshaller

  def setup() {
    etablissementMarshaller = new EtablissementMarshaller()
  }

  def "testMarshall - cas général"(Etablissement etablissement) {
    given:
    Map representation = etablissementMarshaller.marshall(etablissement)

    expect:
    representation.size() == 4
    representation.nom == etablissement.nomAffichage
    representation.idExterne == etablissement.idExterne
    representation.uai == etablissement.uai
    representation.codePorteurENT == etablissement.codePorteurENT

    where:
    etablissement = new Etablissement(
        nomAffichage: "nomAffichage",
        idExterne: "idExterne",
        uai: "uai",
        codePorteurENT: "codePorteurENT"
    )
  }

  def "testMarshall - argument null"() {
    expect:
    etablissementMarshaller.marshall(null) == null
  }

  def "testParse - cas général"(String nom,
                                String idExterne,
                                String uai,
                                String codePorteurENT) {
    given:
    String json = """
      {
        nom: ${MarshallerHelper.asJsonString(nom)},
        idExterne: ${MarshallerHelper.asJsonString(idExterne)},
        uai: ${MarshallerHelper.asJsonString(uai)},
        codePorteurENT: ${MarshallerHelper.asJsonString(codePorteurENT)}
      }
    """

    EtablissementDto etablissementDto = EtablissementMarshaller.parse(
        JSON.parse(json)
    )

    expect:
    etablissementDto.nom == nom
    etablissementDto.idExterne == idExterne
    etablissementDto.uai == uai
    etablissementDto.codePorteurENT == codePorteurENT

    where:
    nom << [null, 'nom']
    idExterne << [null, 'idExterne']
    uai << [null, 'uai']
    codePorteurENT << [null, 'codePorteurENT']

  }

  def "testParse - JSONObject.Null"() {
    expect:
    EtablissementMarshaller.parse(new JSONObject.Null()) == null
  }
}
