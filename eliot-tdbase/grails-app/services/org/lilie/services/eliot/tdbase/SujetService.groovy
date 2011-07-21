package org.lilie.services.eliot.tdbase

import org.springframework.transaction.annotation.Transactional
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.CopyrightsType

class SujetService {

  static transactional = false

  /**
   * Créé un sujet
   * @param proprietaire le proprietaire du sujet
   * @param titre le titre du sujet
   * @return  le sujet créé
   */
  @Transactional
  Sujet createSujet(Personne proprietaire,String titre) {
    Sujet sujet = new Sujet(
            proprietaire: proprietaire,
            titre: titre,
            accesPublic: false,
            accesSequentiel: false,
            ordreQuestionsAleatoire: false,
            versionSujet: 1,
            copyrightsType: CopyrightsType.getDefault()
    )
    sujet.save()
    return sujet
  }


}
