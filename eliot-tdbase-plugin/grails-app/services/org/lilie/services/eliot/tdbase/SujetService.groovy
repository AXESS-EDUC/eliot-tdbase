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

import org.hibernate.Session
import org.hibernate.SessionFactory
import org.lilie.services.eliot.tice.Attachement
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
  CopieService copieService
  ReponseService reponseService
  SessionFactory sessionFactory

  /**
   * Créé un sujet
   * @param proprietaire le proprietaire du sujet
   * @param titre le titre du sujet
   * @return le sujet créé
   */
  @Transactional
  Sujet createSujet(Personne proprietaire, String titre) {
    Sujet sujet = new Sujet(proprietaire: proprietaire,
                            titre: titre,
                            titreNormalise: StringUtils.normalise(titre),
                            accesPublic: false,
                            accesSequentiel: false,
                            ordreQuestionsAleatoire: false,
                            publie: false,
                            versionSujet: 1,
                            copyrightsType: CopyrightsTypeEnum.TousDroitsReserves.copyrightsType,
                            sujetType: SujetTypeEnum.Sujet.sujetType)
    sujet.save(flush: true)
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
    assert (artefactAutorisationService.utilisateurPeutDupliquerArtefact(proprietaire, sujet))

    Sujet sujetCopie = new Sujet(proprietaire: proprietaire,
                                 titre: sujet.titre + " (Copie)",
                                 titreNormalise: sujet.titreNormalise,
                                 presentation: sujet.presentation,
                                 presentationNormalise: sujet.presentationNormalise,
                                 accesPublic: false,
                                 accesSequentiel: sujet.accesSequentiel,
                                 ordreQuestionsAleatoire: sujet.ordreQuestionsAleatoire,
                                 publie: false,
                                 copyrightsType: sujet.copyrightsType,
                                 sujetType: sujet.sujetType)
    sujetCopie.save()
    // recopie de la séquence de questions (ce n'est pas une copie en profondeur)
    sujet.questionsSequences.each { SujetSequenceQuestions sujetQuestion ->
      SujetSequenceQuestions copieSujetSequence = new SujetSequenceQuestions(question: sujetQuestion.question,
                                                                             sujet: sujetCopie,
                                                                             noteSeuilPoursuite: sujetQuestion.noteSeuilPoursuite)
      sujetCopie.addToQuestionsSequences(copieSujetSequence)
      copieSujetSequence.save()
    }
    // repertorie l'ateriorité
    sujetCopie.paternite = sujet.paternite
    sujetCopie.save()
    if (sujetCopie.estUnExercice()) {
      createQuestionCompositeForExercice(sujetCopie, proprietaire)
    }
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
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire, leSujet))

    leSujet.titre = nouveauTitre
    leSujet.titreNormalise = StringUtils.normalise(nouveauTitre)
    leSujet.save()
    if (leSujet.estUnExercice()) {
      def question = leSujet.questionComposite
      updateTitreQuestionComposite(nouveauTitre, question)
    }
    return leSujet
  }

  /**
   * Modifie les proprietes du sujet passé en paramètre
   * @param sujet le sujet
   * @param proprietes les nouvelles proprietes
   * @param proprietaire le proprietaire
   * @return le sujet
   */
  @Transactional
  Sujet updateProprietes(Sujet leSujet, Map proprietes, Personne proprietaire) {
    // verif securite
    if (leSujet.id != null) { // sujet existant
      assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire, leSujet))
    } else { // sujet venant d'être créé
      leSujet.proprietaire = proprietaire
      leSujet.copyrightsType = CopyrightsType.getDefault()
    }
    if (proprietes.titre && leSujet.titre != proprietes.titre) {
      leSujet.titreNormalise = StringUtils.normalise(proprietes.titre)
    }
    if (proprietes.presentation && leSujet.presentation != proprietes.presentation) {
      leSujet.presentationNormalise = StringUtils.normalise(proprietes.presentation)
    }
    leSujet.properties = proprietes
    if (leSujet.save(flush: true)) {

      // traitement de la question associee au sujet si le sujet est un exercice
      def question = leSujet.questionComposite
      if (leSujet.estUnExercice()) {
        if (!question) {
          createQuestionCompositeForExercice(leSujet, proprietaire)
        } else {
          // il faut mettre a jour le titre de la question
          updateTitreQuestionComposite(leSujet.titre, question)
        }
      } else {
        // si le sujet était un exercice mais ne l'est plus, suppression de
        // la question associée
        if (question) {
          supprimeQuestionComposite(question, proprietaire)
        }
      }
    }
    return leSujet
  }

  /**
   * Supprime un sujet
   * @param sujet la question à supprimer
   * @param supprimeur la personne tentant la suppression
   */
  @Transactional
  def supprimeSujet(Sujet leSujet, Personne supprimeur) {
    assert (artefactAutorisationService.utilisateurPeutSupprimerArtefact(supprimeur, leSujet))

    // si le sujet est un exercice, suppression de la question associée
    def question = leSujet.questionComposite
    if (question) {
      supprimeQuestionComposite(question, supprimeur)
    }
    // suppression des copies jetables attachees au sujet
    copieService.supprimeCopiesJetablesForSujet(leSujet)

    // suppression des sujetQuestions
    def sujetQuests = SujetSequenceQuestions.where {
      sujet == leSujet
    }
    sujetQuests.deleteAll()

    // suppression de la publication si necessaire
    if (leSujet.estPartage()) {
      leSujet.publication.delete()
    }
    // on supprime enfin le sujet
    leSujet.delete()
  }

/**
 *  Partage un sujet
 * @param leSujet le sujet à partager
 * @param partageur la personne souhaitant partager
 */
  @Transactional
  def partageSujet(Sujet leSujet, Personne partageur) {
    assert (artefactAutorisationService.utilisateurPeutPartageArtefact(partageur, leSujet))
    CopyrightsType ct = CopyrightsTypeEnum.CC_BY_NC.copyrightsType
    Publication publication = new Publication(dateDebut: new Date(),
                                              copyrightsType: ct)
    publication.save()
    leSujet.copyrightsType = ct
    leSujet.publication = publication
    leSujet.publie = true
    // il faut partager les questions qui ne sont pas partagées
    leSujet.questionsSequences.each {
      def question = it.question
      if (question.estComposite()) {
        partageSujet(question.exercice, partageur)
      } else {
        if (!question.estPartage()) {
          questionService.partageQuestion(question, partageur)
        }
      }
    }
    // mise à jour de la paternite
    PaterniteItem paterniteItem = new PaterniteItem(auteur: "${partageur.nomAffichage}",
                                                    copyrightDescription: "${ct.presentation}",
                                                    copyrighLien: "${ct.lien}",
                                                    datePublication: publication.dateDebut,
                                                    oeuvreEnCours: true)
    Paternite paternite = new Paternite(leSujet.paternite)
    paternite.paterniteItems.each {
      it.oeuvreEnCours = false
    }
    paternite.addPaterniteItem(paterniteItem)
    leSujet.paternite = paternite.toString()
    leSujet.save()
    // si le sujet est un exercice, partage de la question associee
    def question = leSujet.questionComposite
    if (question) {
      partageQuestionComposite(question)
    }

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
 * @param uniquementSujetsChercheur flag indiquant si la recherche ne porte
 * que sur les sujets du chercheur
 * @return la liste des sujets
 */
  List<Sujet> findSujets(Personne chercheur,
                         String patternTitre,
                         String patternAuteur,
                         String patternPresentation,
                         Matiere matiere,
                         Niveau niveau,
                         SujetType sujetType,
                         Boolean uniquementSujetsChercheur = false,
                         Map paginationAndSortingSpec = null) {
    if (!chercheur) {
      throw new IllegalArgumentException("sujet.recherche.chercheur.null")
    }
    if (paginationAndSortingSpec == null) {
      paginationAndSortingSpec = [:]
    }

    def criteria = Sujet.createCriteria()
    List<Sujet> sujets = criteria.list(paginationAndSortingSpec) {
      if (matiere) {
        eq "matiere", matiere
      }
      if (niveau) {
        eq "niveau", niveau
      }
      if (sujetType) {
        eq "sujetType", sujetType
      }
      if (uniquementSujetsChercheur) {
        eq 'proprietaire', chercheur
      } else {
        or {
          eq 'proprietaire', chercheur
          eq 'publie', true
        }
        if (patternAuteur) {
          String patternAuteurNormalise = "%${StringUtils.normalise(patternAuteur)}%"
          proprietaire {
            or {
              like "nomNormalise", patternAuteurNormalise
              like "prenomNormalise", patternAuteurNormalise
            }
          }
        }
      }

      if (patternTitre) {
        like "titreNormalise", "%${StringUtils.normalise(patternTitre)}%"
      }
      if (patternPresentation) {
        like "presentationNormalise", "%${StringUtils.normalise(patternPresentation)}%"
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
 * @param proprietaire la personne effectuant la recherche
 * @param paginationAndSortingSpec les specifications pour l'ordre et
 * la pagination
 * @return la liste des sujets
 */
  List<Sujet> findSujetsForProprietaire(Personne proprietaire,
                                        Map paginationAndSortingSpec = null) {
    if (!proprietaire) {
      throw new IllegalArgumentException("sujet.recherche.chercheur.null")
    }
    if (paginationAndSortingSpec == null) {
      paginationAndSortingSpec = [:]
    }

    def criteria = Sujet.createCriteria()
    List<Sujet> sujets = criteria.list(paginationAndSortingSpec) {
      eq 'proprietaire', proprietaire
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
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire, leSujet))
    assert (artefactAutorisationService.utilisateurPeutReutiliserArtefact(proprietaire, question))
    assert (!insertionQuestionCompositeInExercice(question, leSujet))

    if (!question.estPartage() && leSujet.estPartage()) {
      questionService.partageQuestion(question, proprietaire)
    }

    def sequence = new SujetSequenceQuestions(question: question,
                                              sujet: leSujet,
                                              rang: leSujet.questionsSequences?.size())
    leSujet.addToQuestionsSequences(sequence)
    sequence.save()
    if (sequence.hasErrors()) {
      sequence.errors.allErrors.each {
        leSujet.errors.reject(it.code, it.arguments, it.defaultMessage)
      }
      leSujet.removeFromQuestionsSequences(sequence)
      return leSujet
    }

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
    leSujet.refresh()
    return leSujet
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

    Sujet leSujet = sujetQuestion.sujet
    // verif securite
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire, leSujet))

    sujetQuestion.refresh()
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
    Sujet leSujet = sujetQuestion.sujet
    // verif securite
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire, leSujet))

    sujetQuestion.refresh()
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
    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire, sujetQuestion.sujet))

    Sujet leSujet = sujetQuestion.sujet
    leSujet.removeFromQuestionsSequences(sujetQuestion)
    def reponses = Reponse.findAllBySujetQuestion(sujetQuestion)
    reponses.each {
      reponseService.supprimeReponse(it, proprietaire)
    }
    def question = sujetQuestion.question
    if (question.estComposite()) {
      def exercice = question.exercice
      def questSujts = []
      questSujts.addAll(exercice.questionsSequences)
      questSujts.each {
        exercice.removeFromQuestionsSequences(it)
        def reponsesEx = Reponse.findAllBySujetQuestion(it)
        reponsesEx.each {
          reponseService.supprimeReponse(it, proprietaire)
        }
      }
    }

    sujetQuestion.delete()
    leSujet.lastUpdated = new Date()
    leSujet.save(flush: true)
    leSujet.refresh()
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

    assert (artefactAutorisationService.utilisateurPeutModifierArtefact(proprietaire, sujetQuestion.sujet))

    sujetQuestion.points = newPoints
    if (sujetQuestion.save()) {
      def leSujet = sujetQuestion.sujet
      leSujet.lastUpdated = new Date()
      leSujet.save()
    }
    if (sujetQuestion.hasErrors()) {
      log.error(sujetQuestion.errors.allErrors.toListString())
    }
    return sujetQuestion
  }

  /**
   * Recherche les attachements disponibles dans un sujet
   * @param sujet le sujet
   * @param personne la personne accedant aux attachements
   * @return la liste des attachements disponibles dans le sujet
   */
  Set<Attachement> findAttachementsDisponiblesForSujet(Sujet sujet, Personne personne) {
    assert (artefactAutorisationService.utilisateurPeutReutiliserArtefact(personne, sujet))
    Session session = sessionFactory.currentSession
    def res = [] as Set
    def query1 = session.createSQLQuery("\
        select attach.* from \
        tice.attachement attach, \
        td.question quest,\
        td.sujet_sequence_questions sujetQuest \
        where \
        attach.id = quest.attachement_id and\
        quest.id = sujetQuest.question_id and\
        sujetQuest.sujet_id = ?").addEntity("attach", Attachement.class)

    res.addAll(query1.setLong(0, sujet.id).list())

    def query2 = session.createSQLQuery("\
    select attach.* from \
    tice.attachement attach, \
    td.question_attachement questAttach, \
    td.sujet_sequence_questions sujetQuest \
    where \
    attach.id = questAttach.attachement_id and\
    questAttach.question_id = sujetQuest.question_id and\
    sujetQuest.sujet_id = ?").addEntity("attach", Attachement.class)
    res.addAll(query2.setLong(0, sujet.id).list())

    res

  }

  /**
   * Créé une question composite correspondant à un exercice
   * @param sujet l'exercice
   * @param proprietaire le proprietaire
   * @return la question créée
   */
  @Transactional
  private Question createQuestionCompositeForExercice(Sujet exercice, Personne proprietaire) {
    Question question = new Question(proprietaire: proprietaire,
                                     titreNormalise: exercice.titreNormalise,
                                     publie: false,
                                     versionQuestion: 1,
                                     copyrightsType: CopyrightsTypeEnum.TousDroitsReserves.copyrightsType,
                                     specification: "{}")
    question.properties = exercice.properties
    question.type = QuestionTypeEnum.Composite.questionType
    question.exercice = exercice
    question.save(flush: true)
    return question
  }

  /**
   * Supprime une question composite
   * @param question la question à supprimer
   * @param supprimeur la personne tentant la suppression
   */
  @Transactional
  private def supprimeQuestionComposite(Question laQuestion, Personne supprimeur) {
    assert (laQuestion.estComposite())

    // supression des réponses et des sujetQuestions
    def sujetQuestions = SujetSequenceQuestions.findAllByQuestion(laQuestion)
    sujetQuestions.each {
      supprimeQuestionFromSujet(it, supprimeur)
    }
    // on ne supprime pas les attachements (il n'y en a pas)
    // on ne supprime pas la publication, elle est attachée au sujet si
    // il y en une

    laQuestion.delete()
  }

  /**
   *  Partage une question
   * @param laQuestion la question à partager
   * @param partageur la personne souhaitant partager
   */
  @Transactional
  private def partageQuestionComposite(Question laQuestion) {
    assert (laQuestion.estComposite())
    def exercice = laQuestion.exercice
    laQuestion.copyrightsType = exercice.copyrightsType
    laQuestion.publication = exercice.publication
    laQuestion.publie = true
    laQuestion.paternite = exercice.paternite
    laQuestion.save()
  }

  /**
   * Modifie les proprietes de la question passée en paramètre
   * @param question la question
   * @param proprietes les nouvelles proprietes
   * @param specificationObject l'objet specification
   * @param proprietaire le proprietaire
   * @return la question
   */
  @Transactional
  private Question updateTitreQuestionComposite(String nvtitre, Question laQuestion) {

    assert (laQuestion.estComposite())

    if (nvtitre && laQuestion.titre != nvtitre) {
      laQuestion.titreNormalise = StringUtils.normalise(nvtitre)
      laQuestion.titre = nvtitre
    }

    laQuestion.save(flush: true)
    return laQuestion
  }

  /**
   * Indique si la question à insérer dans le sujet est une question composite
   * à insérer dans un sujet de type  exercice
   * @param question la question à insérer
   * @param sujet le sujet
   * @return true si la question est composite et le sujet est un exercice
   */
  private boolean insertionQuestionCompositeInExercice(Question question, Sujet sujet) {
    if (question.estComposite() && sujet.estUnExercice()) {
      return true
    }
    return false
  }

}