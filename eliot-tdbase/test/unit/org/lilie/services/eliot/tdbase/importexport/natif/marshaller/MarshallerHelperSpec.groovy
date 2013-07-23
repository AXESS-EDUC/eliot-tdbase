package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MarshallerHelper
import spock.lang.Specification

/**
 * @author John Tranier
 */
class MarshallerHelperSpec extends Specification {

  def "testGetDecodedBytes"(String data) {
    expect:
    MarshallerHelper.getDecodedBytes(
        MarshallerHelper.encodeAsBase64(data)
    ) == data.getBytes()

    where:
    data = 'Une chaîne à encoder'
  }
}
