package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tice.scolarite.Niveau
import spock.lang.Specification

/**
 * @author John Tranier
 */
class NiveauMarshallerSpec extends Specification {

  NiveauMarshaller niveauMarshaller = new NiveauMarshaller()

  def "testMarshall - cas général"(Niveau niveau) {
    given:
    Map representation = niveauMarshaller.marshall(niveau)

    expect:
    representation.size() == 3
    representation.libelleCourt == niveau.libelleCourt
    representation.libelleEdition == niveau.libelleEdition
    representation.libelleLong == niveau.libelleLong

    where:
    niveau = new Niveau(
        libelleEdition: 'libelleEdition',
        libelleCourt: 'libelleCourt',
        libelleLong: 'libelleLong'
    )
  }

  def "testMarshall - argument null"() {
    expect:
    niveauMarshaller.marshall(null) == null
  }
}
