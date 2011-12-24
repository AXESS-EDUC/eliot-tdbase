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
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.Publication
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.utils.StringUtils
import org.springframework.transaction.annotation.Transactional

class SujetService {

  static transactional = false

  QuestionService questionService
  ArtefactAutorisationService artefactAutorisationService

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
            copyrightsType: CopyrightsTypeEnum.TousDroitsReserves.copyrightsType
    )
    sujet.save()
    return sujet
  }

  /**
   * Recopie un sujet
   * @param sujet le sujet à recopier
   * @param proprietaire le proprietaire
   * @return la copie du sujet
   */
  @Transactional
  Sujet recopieSujet(Sujet sujet, Personne proprietaire) {
    // verification securité
    assert (artefactAutorisationService.utilisateurPeutDupliquerArtefact(proprietaire,sujet))

    Sujet sujetCopie = new Sujet(
            proprietaire: proprietaire,
            titre: sujet.titre + " (Copie)",
            titreNormalise: sujet.titreNormalise,
            presentation: sujet.presentation,
            presentationNormalise: sujet.presentationNormalise,
            accesPublic: false,
            accesSequentiel: sujet.accesSequentiel,
            ordreQuestionsAleatoire: sujet.ordreQuestionsAleatoire,
            publie: false,
            copyrightsType: sujet.copyrightsType
    )
    sujetCopie.save()
    // recopie de la séquence de questions (ce n'est pas une copie en profondeur)
    sujet.questionsSequences.each { SujetSequenceQuestions sujetQuestion ->
      SujetSequenceQuestions copieSujetSequence = new SujetSequenceQuestions(
              question: sujetQuestion.question,
              sujet: sujetCopie,
              noteSeuilPoursuite: sujetQuestion.noteSeuilPoursuite
      )
      sujetCopie.addToQuestionsSequences(copieSujetSequence)
      sujetCopie.save()
    }
    // repertorie l'ateriorité
    sujetCopie.paternite = sujet.paternite
    return sujetCopie
  }

  /**
   * Change le titre du sujet
   * @param sujet le sujet à modifier
   * @param nouveauTitre le titre
   * @return le sujet
   */
  Sujet updateTitreSujet(Sujet leSujet, String nouveauTitre, Personne proprietaire) {
    // verif securite
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire,leSujet))

    leSujet.titre = nouveauTitre
    leSujet.titreNormalise = StringUtils.normalise(nouveauTitre)
    leSujet.save()
    return leSujet
  }

  /**
   * Modifie les proprietes du sujet passé en paramètre
   * @param sujet le sujet
   * @param proprietes les nouvelles proprietes
   * @param proprietaire le proprietaire
   * @return le sujet
   */
  Sujet updateProprietes(Sujet leSujet, Map proprietes, Personne proprietaire) {
    // verif securite
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire,leSujet))

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
   * Supprime un sujet
   * @param sujet la question à supprimer
   * @param supprimeur la personne tentant la suppression
   */
  @Transactional
  def supprimeSujet(Sujet leSujet, Personne supprimeur) {
    assert (artefactAutorisationService.utilisateurPeutSupprimerArtefact(
            supprimeur, leSujet))
    def sujetQuests = SujetSequenceQuestions.where {
      sujet == leSujet
    }
    sujetQuests.deleteAll()
    if (leSujet.estPartage()) {
      leSujet.publication.delete()
    }
    leSujet.delete()
  }

  /**
   *  Partage un sujet
   * @param leSujet le sujet à partager
   * @param partageur la personne souhaitant partager
   */
  @Transactional
  def partageSujet(Sujet leSujet, Personne partageur) {
    assert (artefactAutorisationService.utilisateurPeutPartageArtefact(
            partageur, leSujet))
    CopyrightsType ct = CopyrightsTypeEnum.CC_BY_NC.copyrightsType
    Publication publication = new Publication(dateDebut: new Date(),
                                              copyrightsType: ct)
    publication.save()
    leSujet.copyrightsType = ct
    leSujet.publication = publication
    // il faut partager les questions qui ne sont pas partagées
    leSujet.questionsSequences.each {
      def question = it.question
      if (!question.estPartage()) {
        questionService.partageQuestion(question,partageur)
      }
    }
    leSujet.save()
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
   * @param rang le rang d'insertion
   * @return le sujet modifié
   */
  @Transactional
  Sujet insertQuestionInSujet(Question question, Sujet leSujet,
                              Personne proprietaire, Integer rang = null) {

    // verif securite
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire,leSujet))
    assert (artefactAutorisationService.utilisateurPeutReutiliserArtefact(proprietaire,question))

    if (!question.estPartage() && leSujet.estPartage()) {
      questionService.partageQuestion(question,proprietaire)
    }

    def sequence = new SujetSequenceQuestions(
            question: question,
            sujet: leSujet,
            rang: leSujet.questionsSequences?.size()
    )
    leSujet.addToQuestionsSequences(sequence)
    leSujet.lastUpdated = new Date()
    leSujet.save(flush: true)
    if (rang != null && rang < leSujet.questionsSequences.size() - 1) {
      // il faut insérer au rang correct
      def idxSujQuest = leSujet.questionsSequences.size() - 1
      while (idxSujQuest != rang) {
        def idxSujQuestPrec = idxSujQuest - 1
        def sujQuest = leSujet.questionsSequences[idxSujQuest]
        def sujQuestPrec = leSujet.questionsSequences[idxSujQuestPrec]
        leSujet.questionsSequences[idxSujQuest] = sujQuestPrec
        leSujet.questionsSequences[idxSujQuestPrec] = sujQuest
        idxSujQuest = idxSujQuestPrec
      }
      leSujet.save(flush: true)
    }
  }

  /**
   * Inverse une question avec sa précédente dans un sujet
   * @param sujetQuestion la question à inverser
   * @param proprietaire le proprietaire du sujet
   * @return le sujet modifié
   */
  @Transactional
  Sujet inverseQuestionAvecLaPrecedente(SujetSequenceQuestions sujetQuestion,
                                        Personne proprietaire) {

    Sujet leSujet =  sujetQuestion.sujet
    // verif securite
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire,leSujet))


    def idx = sujetQuestion.rang
    if (idx == 0) { // on ne fait rien
      return sujetQuestion.sujet
    }
    def idxPrec = sujetQuestion.rang - 1

    def squestPrec = leSujet.questionsSequences[idxPrec]
    def squest = leSujet.questionsSequences[idx]
    leSujet.lastUpdated = new Date()
    leSujet.questionsSequences[idx] = squestPrec
    leSujet.questionsSequences[idxPrec] = squest
    leSujet.save(flush: true)
    // refresh sinon la collection n'est pas raffraichie : raison possible
    // pour suppression modelisation to many
    leSujet.refresh()
    return leSujet
  }

  /**
   * Inverse une question avec sa suivante dans un sujet
   * @param sujetQuestion la question à inverser
   * @param proprietaire le proprietaire du sujet
   * @return le sujet modifié
   */
  @Transactional
  Sujet inverseQuestionAvecLaSuivante(SujetSequenceQuestions sujetQuestion,
                                      Personne proprietaire) {
    Sujet leSujet =  sujetQuestion.sujet
        // verif securite
        assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire,leSujet))

    def idx = sujetQuestion.rang
    if (idx == sujetQuestion.sujet.questionsSequences.size() - 1) { // on ne fait rien
      return sujetQuestion.sujet
    }
    def idxSuiv = sujetQuestion.rang + 1
    def squestSuiv = leSujet.questionsSequences[idxSuiv]
    def squest = leSujet.questionsSequences[idx]
    leSujet.questionsSequences[idx] = squestSuiv
    leSujet.questionsSequences[idxSuiv] = squest
    leSujet.lastUpdated = new Date()
    leSujet.save(flush: true)
    leSujet.refresh()
    return leSujet
  }

/**
 * Supprime une question d'un sujet
 * @param sujetQuestion le sujet et la question
 * @param proprietaire le propriétaire
 * @return le sujet modifié
 */
  @Transactional
  Sujet supprimeQuestionFromSujet(SujetSequenceQuestions sujetQuestion,
                                  Personne proprietaire) {
    // verif securite
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(
            proprietaire, sujetQuestion.sujet
    ))

    Sujet leSujet = sujetQuestion.sujet
    SujetSequenceQuestions squest = leSujet.questionsSequences[sujetQuestion.rang]
    leSujet.removeFromQuestionsSequences(squest)
    def reponsesFiltre = Reponse.where {
      sujetQuestion == squest
    }
    reponsesFiltre.deleteAll()
    squest.delete()
    leSujet.lastUpdated = new Date()
    leSujet.save()
    return leSujet
  }

  /**
   * Modifie le nombre de points associé à une question dans un sujet
   * @param sujetQuestion le sujet et la question
   * @param proprietaire le propriétaire
   * @return le sujet modifié
   */
  @Transactional
  SujetSequenceQuestions updatePointsForQuestion(Float newPoints,
                                                 SujetSequenceQuestions sujetQuestion,
                                                 Personne proprietaire) {

    assert (sujetQuestion.sujet.proprietaire == proprietaire)

    sujetQuestion.points = newPoints
    if (sujetQuestion.save()) {
      def leSujet = sujetQuestion.sujet
      leSujet.lastUpdated = new Date()
      leSujet.save()
    }
    return sujetQuestion
  }



}