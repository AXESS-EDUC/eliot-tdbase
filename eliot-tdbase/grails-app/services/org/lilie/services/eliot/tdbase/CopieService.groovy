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
     * Récupère la copie de teste d'une personne pour un sujet
     * @param sujet le sujet
     * @param personne la personne
     * @return la copie
     */
    @Transactional
    Copie getCopieTestForSujetAndPersonne(Sujet sujet, Personne personne) {
      Copie copie = Copie.findBySujetAndEleve(sujet, personne)
      if (copie == null) {
        copie = new Copie(
                eleve: personne,
                sujet: sujet,
                estJetable: true
        )
        if (!copie.save() || copie.hasErrors()) {
          return copie
        }
      }
      // pour chaque question du sujet, on crée un obejt de type réponse ;
      // on test la nécessité de creer la réponse car si le sujet a été modifié
      // alors que la copie a déjà été créé, il faut créé la réponse adhoc pour
      // la ou les questions ajoutées
      sujet.questionsSequences.each {
        if (it.question.type.interaction) {
          Reponse reponse = Reponse.findByCopieAndSujetQuestion(copie, it)
          if (reponse == null) {
            reponseService.createReponse(
                    copie,
                    it,
                    personne
            )
          }
        }
      }

      return copie
    }


  /**
   * Récupère la copie d'un élève pour une séance
   * @param seance la séance
   * @param eleve l'élève
   * @return la copie
   */
  @Transactional
  Copie getCopieForModaliteActiviteAndEleve(ModaliteActivite seance, Personne eleve) {

    assert (seance.structureEnseignement in
        profilScolariteService.findStructuresEnseignementForPersonne(eleve))

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
  Copie updateCopieForListeReponsesCopie(Copie copie,
                                       List<ReponseCopie> reponsesCopie,
                                       Personne eleve) {

    assert (copie.eleve == eleve && copie.estModifiable())

    def noteGlobaleAuto = 0
    def nbGlobalPointsAuto = 0
    def nbGlobalPointsCorrecteur = 0
    reponsesCopie.each { ReponseCopie reponseCopie ->
      Reponse reponse = reponseCopie.reponse
      reponseService.updateSpecificationAndEvalue(reponse,
                                                  reponseCopie.specificationObject,
                                                  eleve)
      if (reponse.correctionNoteAutomatique != null) {
        noteGlobaleAuto += reponse.correctionNoteAutomatique
        nbGlobalPointsAuto += reponse.sujetQuestion.points
      } else {
        nbGlobalPointsCorrecteur += reponse.sujetQuestion.points
      }
    }
    copie.dateRemise = new Date()
    if (noteGlobaleAuto < 0) {
      noteGlobaleAuto = 0
    }
    copie.correctionNoteAutomatique = noteGlobaleAuto

    copie.maxPointsAutomatique = nbGlobalPointsAuto
    copie.maxPointsCorrecteur = nbGlobalPointsCorrecteur
    copie.maxPoints = nbGlobalPointsAuto + nbGlobalPointsCorrecteur
    if (nbGlobalPointsCorrecteur > 0) {
      if (copie.correctionNoteCorrecteur != null) {
        copie.correctionNoteFinale = copie.correctionNoteAutomatique + copie.correctionNoteCorrecteur
      }
    } else {
      copie.correctionNoteFinale = copie.correctionNoteAutomatique
    }
    copie.correctionNoteFinale += copie.pointsModulation
    copie.save()
    return copie
  }

  /**
   * Met à jour la notation de la copie
   * @param copie la copie
   * @param enseignant l'enseignant qui corrige
   * @return la copie mise à jour
   */
  @Transactional
  Copie updateAnnotationAndModulationForCopie(
          String annotation,
          Float pointsModulation,
          Copie copie,
          Personne enseignant) {

    assert (copie.modaliteActivite.enseignant == enseignant)

    copie.correctionAnnotation = annotation
    copie.pointsModulation = pointsModulation
    copie.correctionNoteFinale = copie.recalculeNoteFinale()
    copie.save()
    return copie
  }

/**
 * Recherche les copies en visualisation élève  (profil élève)
 * @param chercheur la personne effectuant la recherche
 * @param paginationAndSortingSpec les specifications pour l'ordre et
 * la pagination
 * @return la liste des copies
 */
  List<Copie> findCopiesEnVisualisationForApprenant(Personne chercheur,
                                                    Map paginationAndSortingSpec = [:]) {

    assert (chercheur != null)

    def structs = profilScolariteService.findStructuresEnseignementForPersonne(chercheur)
    Date now = new Date()
    def criteria = Copie.createCriteria()
    List<Copie> copies = criteria.list(paginationAndSortingSpec) {
      eq 'eleve', chercheur
      modaliteActivite {
        inList 'structureEnseignement', structs
        lt 'dateFin', now
      }
      if (paginationAndSortingSpec) {
        def sortArg = paginationAndSortingSpec['sort'] ?: 'dateRemise'
        def orderArg = paginationAndSortingSpec['order'] ?: 'desc'
        if (sortArg) {
          order "${sortArg}", orderArg
        }

      }
    }
    return copies
  }

  /**
   * Recherche les copies en visualisation élève  (profil parent)
   * @param chercheur le parent effectuant la recherche
   * @param apprenant l'élève
   * @param paginationAndSortingSpec les specifications pour l'ordre et
   * la pagination
   * @return la liste des copies
   */
    List<Copie> findCopiesEnVisualisationForResponsableAndApprenant(Personne chercheur,
                                                      Personne apprenant,
                                                      Map paginationAndSortingSpec = [:]) {

      assert (profilScolariteService.personneEstResponsableEleve(chercheur,apprenant))

      def copies = findCopiesEnVisualisationForApprenant(apprenant,paginationAndSortingSpec)
      return copies
    }

  /**
   *
   * @param seance la séance
   * @param chercheur la personne déclenchant la recherche
   * @param paginationSpec les specifications la pagination
   * @return
   */
  List<Copie> findCopiesForModaliteActivite(ModaliteActivite seance,
                                            Personne chercheur,
                                            Map paginationSpec = [:]) {

    assert (seance?.enseignant == chercheur)

    def criteria = Copie.createCriteria()
    List<Copie> copies = criteria.list(paginationSpec) {
      eq 'modaliteActivite', seance
      eleve {
        order 'nom', 'asc'
      }
      join 'eleve'
    }
    return copies
  }

}

class ReponseCopie {
  Reponse reponse
  def specificationObject
}
