package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tice.CopyrightsType
import spock.lang.Specification

/**
 * @author John Tranier
 */
class CopyrightsTypeMarshallerSpec extends Specification {

  CopyrightsTypeMarshaller copyrightsTypeMarshaller = new CopyrightsTypeMarshaller()

  def "testMarshall - cas général"(CopyrightsType copyrightsType) {
    given:
    String representation = copyrightsTypeMarshaller.marshall(copyrightsType)

    expect:
    representation == copyrightsType.code

    where:
    copyrightsType = new CopyrightsType(code: "code")
  }

  def "testMarshall - argument null"() {
    expect:
    copyrightsTypeMarshaller.marshall(null) == null
  }

}
