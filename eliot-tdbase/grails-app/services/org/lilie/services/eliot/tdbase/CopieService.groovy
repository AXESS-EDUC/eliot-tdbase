/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 * Lilie is free software. You can redistribute it and/or modify since
 * you respect the terms of either (at least one of the both license) :
 * - under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * - the CeCILL-C as published by CeCILL-C; either version 1 of the
 * License, or any later version
 *
 * There are special exceptions to the terms and conditions of the
 * licenses as they are applied to this software. View the full text of
 * the exception in file LICENSE.txt in the directory of this software
 * distribution.
 *
 * Lilie is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Licenses for more details.
 *
 * You should have received a copy of the GNU General Public License
 * and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */





package org.lilie.services.eliot.tdbase

import org.gcontracts.annotations.Requires
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.springframework.transaction.annotation.Transactional

/**
 * Service de gestion des copies
 * @author franck silvestre
 */
class CopieService {

  static transactional = false
  ProfilScolariteService profilScolariteService
  ReponseService reponseService

  /**
   * Récupère la copie d'un élève pour une séance
   * @param seance la séance
   * @param eleve l'élève
   * @return la copie
   */
  @Requires({
    seance.structureEnseignement in
    profilScolariteService.findStructuresEnseignementForPersonne(eleve)
  })
  @Transactional
  Copie getCopieForModaliteActiviteAndEleve(ModaliteActivite seance, Personne eleve) {
    Copie copie = Copie.findByModaliteActiviteAndEleve(seance, eleve)
    if (copie == null) {
      copie = new Copie(
              modaliteActivite: seance,
              eleve: eleve,
              sujet: seance.sujet
      )
      if (!copie.save() || copie.hasErrors()) {
        return copie
      }
    }
    // pour chaque question du sujet, on crée un obejt de type réponse ;
    // on test la nécessité de creer la réponse car si le sujet a été modifié
    // alors que la copie a déjà été créé, il faut créé la réponse adhoc pour
    // la ou les questions ajoutées
    seance.sujet.questionsSequences.each {
      if (it.question.type.interaction) {
        Reponse reponse = Reponse.findByCopieAndSujetQuestion(copie, it)
        if (reponse == null) {
          reponseService.createReponse(
                  copie,
                  it,
                  eleve
          )
        }
      }
    }

    return copie
  }

  /**
   * Met à jour la copie en prenant en compte la liste de réponses soumises
   * @param copie la copie
   * @param reponsesCopie les réponses soumises
   * @param eleve l'élève
   * @return la copie mise à jour
   */
  @Transactional
  @Requires({copie.eleve == eleve && copie.estModifiable()})
  def updateCopieForListeReponsesCopie(Copie copie,
                                       List<ReponseCopie> reponsesCopie,
                                       Personne eleve) {
    def noteGlobale = 0
    def nbGlobalPoints = 0
    reponsesCopie.each { ReponseCopie reponseCopie ->
      Reponse reponse = reponseCopie.reponse
      reponseService.updateSpecificationAndEvalue(reponse,
                                          reponseCopie.specificationObject,
                                          eleve)
      noteGlobale += reponse.correctionNoteAutomatique
      nbGlobalPoints += reponse.sujetQuestion.points
    }
    copie.dateRemise = new Date()
    if (noteGlobale < 0) {
      noteGlobale = 0
    }
    copie.correctionNoteAutomatique = noteGlobale

    // todofsil : c'est le nb de points sur le quel est noté le sujet
    copie.correctionNoteCorrecteur = nbGlobalPoints
    copie.save()
  }

}

class ReponseCopie {
  Reponse reponse
  def specificationObject
}
