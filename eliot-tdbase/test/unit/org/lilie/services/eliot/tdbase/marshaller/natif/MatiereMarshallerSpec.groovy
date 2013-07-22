package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tice.scolarite.Matiere
import spock.lang.Specification

/**
 * @author John Tranier
 */
class MatiereMarshallerSpec extends Specification {

  MatiereMarshaller matiereMarshaller = new MatiereMarshaller()

  def "MatiereMarshaller - cas général"(Matiere matiere) {
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

  def "MatiereMarshaller - argument null"() {
    expect:
    matiereMarshaller.marshall(null) == null
  }
}
