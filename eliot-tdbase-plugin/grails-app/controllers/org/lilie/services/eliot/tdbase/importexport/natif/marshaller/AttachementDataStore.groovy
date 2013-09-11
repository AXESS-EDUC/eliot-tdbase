package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.lilie.services.eliot.tice.Attachement
import org.lilie.services.eliot.tice.AttachementService

/**
 * DataStore permettant de répertorier, en fonction de leur chemins, tous les attachements
 * à inclure dans un export d'une question ou d'un sujet au format natif dans le but
 * de garantir l'unicité des attachements inclus dans le fichier d'export
 *
 * @author John Tranier
 */
class AttachementDataStore {

  AttachementService attachementService

  Map<String, String> datastore = [:] // associe le contenu d'un attachement encodé en base 64 à son chemin

  void addAttachement(Attachement attachement) {
    if (!datastore.containsKey(attachement.chemin)) {
      datastore.put(
          attachement.chemin,
          attachementService.encodeToBase64(attachement)
      )
    }
  }

  void addAttachementFromJson(String chemin, String blobBase64) {
    datastore.put(
        chemin,
        blobBase64
    )
  }

  String getBlobBase64(String chemin) {
    String blob = datastore.get(chemin)

    if(!blob) {
      throw new IllegalStateException("Aucun attachement pour le chemin '$chemin'")
    }

    return blob
  }

}
