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

import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.utils.StringUtils
import org.springframework.transaction.annotation.Transactional

//todofsil : mettre en place controle securite
class SujetService {

  static transactional = false

  QuestionService questionService

  /**
   * Créé un sujet
   * @param proprietaire le proprietaire du sujet
   * @param titre le titre du sujet
   * @return le sujet créé
   */
  @Transactional
  Sujet createSujet(Personne proprietaire, String titre) {
    Sujet sujet = new Sujet(
            proprietaire: proprietaire,
            titre: titre,
            titreNormalise: StringUtils.normalise(titre),
            accesPublic: false,
            accesSequentiel: false,
            ordreQuestionsAleatoire: false,
            publie: false,
            versionSujet: 1,
            copyrightsType: CopyrightsType.getDefault()
    )
    sujet.save()
    return sujet
  }

  /**
   * Retourne la dernière version éditable d'un sujet pour un proprietaire donné
   * @param sujet le sujet
   * @param proprietaire le proprietaire
   * @return le sujet éditable
   */
  Sujet getDerniereVersionSujetForProprietaire(Sujet sujet, Personne proprietaire) {
    if (sujet.proprietaire == proprietaire && !sujet.publie) {
      return sujet
    } else {
      return recopieSujet(sujet, proprietaire)
    }
  }

  /**
   * Recopie un sujet
   * - si le proprietaire de la copie est le proprietaire de l'original, on
   * incrémente la version ; on ne crée pas de nouvelle branche :
   * le sujet départ branche de la nouvelle version
   * est le sujet départ branche de la version précédente
   * - si le proprietaire de la copie est différent de l'original, on incrémente
   * la version ; on créé une nouvelle branche : le sujet départ branche de la
   * copie est le sujet recopié
   * @param sujet le sujet à recopier
   * @param proprietaire le proprietaire
   * @return la copie du sujet
   */
  @Transactional
  Sujet recopieSujet(Sujet sujet, Personne proprietaire) {
    // todofsil : implémenter le contrôle de sécurité
    def versionSujet = 1
    def sujetDepartBranche = sujet.sujetDepartBranche
    if (sujet.proprietaire == proprietaire) {
      versionSujet = sujet.versionSujet + 1
    } else {
      sujetDepartBranche = sujet
    }
    Sujet sujetCopie = new Sujet(
            proprietaire: proprietaire,
            titre: sujet.titre,
            titreNormalise: sujet.titreNormalise,
            presentation: sujet.presentation,
            presentationNormalise: sujet.presentationNormalise,
            accesPublic: false,
            accesSequentiel: sujet.accesSequentiel,
            ordreQuestionsAleatoire: sujet.ordreQuestionsAleatoire,
            publie: false,
            versionSujet: versionSujet,
            sujetDepartBranche: sujetDepartBranche,
            copyrightsType: sujet.copyrightsType,
    )
    sujetCopie.save()
    // recopie de la séquence de questions
    sujetCopie.questionsSequences.each { SujetSequenceQuestions sujetQuestion ->
      SujetSequenceQuestions copieSujetSequence = new SujetSequenceQuestions(
              question: sujetQuestion.question,
              sujet: sujetCopie,
              noteSeuilPoursuite: sujetQuestion.noteSeuilPoursuite
      )
      sujetCopie.addToQuestionsSequences(copieSujetSequence)
      sujetCopie.save()
    }
    return sujetCopie
  }

  /**
   * Change le titre du sujet
   * @param sujet le sujet à modifier
   * @param nouveauTitre le titre
   * @return le sujet
   */
  Sujet updateTitreSujet(Sujet sujet, String nouveauTitre, Personne proprietaire) {
    // verifie que c'est sur la derniere version du sujet editable que l'on
    // travaille
    Sujet leSujet = getDerniereVersionSujetForProprietaire(sujet, proprietaire)
    leSujet.titre = nouveauTitre
    leSujet.titreNormalise = StringUtils.normalise(nouveauTitre)
    leSujet.save()
    return sujet
  }

  /**
   * Modifie les proprietes du sujet passé en paramètre
   * @param sujet le sujet
   * @param proprietes les nouvelles proprietes
   * @param proprietaire le proprietaire
   * @return le sujet
   */
  Sujet updateProprietes(Sujet sujet, Map proprietes, Personne proprietaire) {
    // verifie que c'est sur la derniere version du sujet editable que l'on
    // travaille
    Sujet leSujet = getDerniereVersionSujetForProprietaire(sujet, proprietaire)

    if (proprietes.titre && leSujet.titre != proprietes.titre) {
      leSujet.titreNormalise = StringUtils.normalise(proprietes.titre)
    }
    if (proprietes.presentation && leSujet.presentation != proprietes.presentation) {
      leSujet.presentationNormalise = StringUtils.normalise(proprietes.presentation)
    }
    leSujet.properties = proprietes
    leSujet.save()
    return leSujet
  }

  /**
   * Recherche de sujets
   * @param chercheur la personne effectuant la recherche
   * @param patternTitre le pattern saisi pour le titre
   * @param patternAuteur le pattern saisi pour l'auteur
   * @param patternPresentation le pattern saisi pour la presentation
   * @param matiere la matiere
   * @param niveau le niveau
   * @param paginationAndSortingSpec les specifications pour l'ordre et
   * la pagination
   * @return la liste des sujets
   */
  List<Sujet> findSujets(Personne chercheur,
                         String patternTitre,
                         String patternAuteur,
                         String patternPresentation,
                         Matiere matiere,
                         Niveau niveau,
                         SujetType sujetType,
                         Map paginationAndSortingSpec = null) {
    // todofsil : gerer les index de manière efficace couplée avec présentation
    // paramètre de recherche ad-hoc
    if (!chercheur) {
      throw new IllegalArgumentException("sujet.recherche.chercheur.null")
    }
    if (paginationAndSortingSpec == null) {
      paginationAndSortingSpec = [:]
    }

    def criteria = Sujet.createCriteria()
    List<Sujet> sujets = criteria.list(paginationAndSortingSpec) {
      if (patternAuteur) {
        String patternAuteurNormalise = "%${StringUtils.normalise(patternAuteur)}%"
        proprietaire {
          or {
            like "nomNormalise", patternAuteurNormalise
            like "prenomNormalise", patternAuteurNormalise
          }
        }
      }
      if (patternTitre) {
        like "titreNormalise", "%${StringUtils.normalise(patternTitre)}%"
      }
      if (patternPresentation) {
        like "presentationNormalise", "%${StringUtils.normalise(patternPresentation)}%"
      }
      if (matiere) {
        eq "matiere", matiere
      }
      if (niveau) {
        eq "niveau", niveau
      }
      if (sujetType) {
        eq "sujetType", sujetType
      }
      or {
        eq 'proprietaire', chercheur
        eq 'publie', true
      }
      if (paginationAndSortingSpec) {
        def sortArg = paginationAndSortingSpec['sort'] ?: 'lastUpdated'
        def orderArg = paginationAndSortingSpec['order'] ?: 'desc'
        if (sortArg) {
          order "${sortArg}", orderArg
        }

      }
    }
    return sujets
  }

  /**
   * Recherche de tous les sujet pour un proprietaire donné
   * @param chercheur la personne effectuant la recherche
   * @param paginationAndSortingSpec les specifications pour l'ordre et
   * la pagination
   * @return la liste des sujets
   */
  List<Sujet> findSujetsForProprietaire(Personne proprietaire,
                                        Map paginationAndSortingSpec = null) {
    return findSujets(proprietaire, null, null, null, null, null, null,
                      paginationAndSortingSpec)
  }

  /**
   *
   * @return la liste de tous les types de sujet
   */
  List<SujetType> getAllSujetTypes() {
    return SujetType.getAll()
  }



  /**
   * Insert une question dans un sujet sujet
   * @param question la question
   * @param sujet le sujet
   * @param proprietaire le propriétaire
   */
  @Transactional
  Sujet insertQuestionInSujet(Question question, Sujet sujet,
                            Personne proprietaire, Integer rang = null) {
    Sujet leSujet = getDerniereVersionSujetForProprietaire(sujet, proprietaire)
    def sequence = new SujetSequenceQuestions(
            question: question,
            sujet: leSujet
    )
    leSujet.addToQuestionsSequences(sequence)
    leSujet.lastUpdated = new Date()
    leSujet.save()
    return leSujet
  }

  /**
   * Inverse une question avec sa précédente dans un sujet
   * @param sujetQuestion la question à inverser
   * @param proprietaire le proprietaire du sujet
   * @return  le sujet modifié
   */
  Sujet inverseQuestionAvecLaPrecedente(SujetSequenceQuestions sujetQuestion,
                                        Personne proprietaire) {
    Sujet leSujet = getDerniereVersionSujetForProprietaire(sujetQuestion.sujet,
                                                           proprietaire)
    def idx = sujetQuestion.rang
    def idxPrec = sujetQuestion.rang - 1
    if (idx == 0) {
       idxPrec = leSujet.questionsSequences.size() - 1
    }
    def squestPrec = leSujet.questionsSequences[idxPrec]
    def squest = leSujet.questionsSequences[idx]
    leSujet.questionsSequences[idx] = squestPrec
    leSujet.questionsSequences[idxPrec] = squest
    leSujet.lastUpdated = new Date()
    leSujet.save(flush:true)
    return leSujet
  }

  /**
   * Inverse une question avec sa suivante dans un sujet
   * @param sujetQuestion la question à inverser
   * @param proprietaire le proprietaire du sujet
   * @return  le sujet modifié
   */
  Sujet inverseQuestionAvecLaSuivante(SujetSequenceQuestions sujetQuestion,
                                        Personne proprietaire) {
    Sujet leSujet = getDerniereVersionSujetForProprietaire(sujetQuestion.sujet,
                                                           proprietaire)
    def idx = sujetQuestion.rang
    def idxSuiv = sujetQuestion.rang + 1
    if (idx == leSujet.questionsSequences.size() - 1) {
       idxSuiv = 0
    }
    def squestSuiv = leSujet.questionsSequences[idxSuiv]
    def squest = leSujet.questionsSequences[idx]
    leSujet.questionsSequences[idx] = squestSuiv
    leSujet.questionsSequences[idxSuiv] = squest
    leSujet.lastUpdated = new Date()
    leSujet.save(flush:true)
    return leSujet
  }

/**
   * Supprime une question d'un sujet
   * @param question la question
   * @param sujet le sujet
   * @param proprietaire le propriétaire
   * @return le sujet modifié
   */
  @Transactional
  Sujet supprimeQuestionFromSujet(SujetSequenceQuestions sujetQuestion,
                            Personne proprietaire) {
    Sujet leSujet = getDerniereVersionSujetForProprietaire(sujetQuestion.sujet, proprietaire)
    SujetSequenceQuestions squest = leSujet.questionsSequences[sujetQuestion.rang]
    leSujet.removeFromQuestionsSequences(squest)
    squest.delete()
    leSujet.lastUpdated = new Date()
    leSujet.save()
    return leSujet
  }

}
