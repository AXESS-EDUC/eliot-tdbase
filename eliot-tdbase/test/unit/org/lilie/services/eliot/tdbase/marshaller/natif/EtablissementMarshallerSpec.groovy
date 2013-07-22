package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tice.scolarite.Etablissement
import spock.lang.Specification

/**
 * @author John Tranier
 */
class EtablissementMarshallerSpec extends Specification {

  EtablissementMarshaller etablissementMarshaller = new EtablissementMarshaller()

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
}
