package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import spock.lang.Specification

/**
 * @author John Tranier
 */
class AttachementDataStoreSpec extends Specification {

  def "testGetBlobBase64 - chemin inexistant"() {
    given:
    String chemin = "unkown"
    AttachementDataStore attachementDataStore = new AttachementDataStore()

    when:
    attachementDataStore.getBlobBase64(chemin)

    then:
    def e = thrown(IllegalStateException)
    e.message == "Aucun attachement pour le chemin '$chemin'"
  }
}
