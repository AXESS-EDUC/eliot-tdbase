package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONElement

/**
 * Marshaller qui permet de convertir un AttachementDatastore en une représentation à base de Map
 * qui pourra ensuite être convertie en XML ou en JSON
 *
 * @author John Tranier
 */
class AttachementDatastoreMarshaller {

  List marshall(AttachementDataStore attachementDataStore) {
    List representation = []

    attachementDataStore.datastore.each { String chemin, String blobBase64 ->
      representation << [
          chemin: chemin,
          blob: blobBase64
      ]
    }

    return representation
  }

  static AttachementDataStore parse(JSONArray jsonArray) {
    AttachementDataStore attachementDataStore = new AttachementDataStore()

    jsonArray.each { JSONElement jsonElement ->
      MarshallerHelper.checkIsNotNull('chemin', jsonElement.chemin)
      MarshallerHelper.checkIsNotNull('blob', jsonElement.blob)

      attachementDataStore.addAttachementFromJson(jsonElement.chemin, jsonElement.blob)
    }

    return attachementDataStore
  }
}
