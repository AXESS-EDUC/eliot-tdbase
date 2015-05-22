package org.lilie.services.eliot.tdbase

import org.lilie.services.eliot.tdbase.impl.decimal.DecimalSpecification
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeService
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement
import org.lilie.services.eliot.tice.utils.BootstrapService

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

/**
 *
 * @author franck Silvestre
 */
class SujetServiceIntegrationTests extends GroovyTestCase {

    private static final String SUJET_1_TITRE = "Sujet test 1"
    private static final String SUJET_2_TITRE = "Sujet test 2"

    Personne personne1
    Personne personne2
    Personne personne3
    StructureEnseignement struct1ere

    BootstrapService bootstrapService
    SujetService sujetService
    ModaliteActiviteService modaliteActiviteService
    QuestionService questionService
    ArtefactAutorisationService artefactAutorisationService
    GroupeService groupeService


    protected void setUp() {
        super.setUp()
        bootstrapService.bootstrapForIntegrationTest()
        personne1 = bootstrapService.enseignant1
        personne2 = bootstrapService.enseignant2
        personne3 = bootstrapService.persDirection1
        struct1ere = bootstrapService.classe1ere
    }

    protected void tearDown() {
        super.tearDown()
    }

    void testCreateSujet() {

        Sujet sujet = sujetService.createSujet(personne1, SUJET_1_TITRE)
        assertNotNull(sujet)
        if (sujet.hasErrors()) {
            log.error(sujet.errors.allErrors.toListString())
        }
        assertFalse(sujet.hasErrors())

        assertEquals(personne1, sujet.proprietaire)
        assertFalse(sujet.accesPublic)
        assertFalse(sujet.accesSequentiel)
        assertFalse(sujet.ordreQuestionsAleatoire)
        assertEquals(CopyrightsTypeEnum.TousDroitsReserves.copyrightsType, sujet.copyrightsType)
    }

    void testCreateSujetWithCreateOrUpdateSujet() {

        Sujet sujet = sujetService.updateProprietes(new Sujet(), [titre: SUJET_2_TITRE], personne1)
        assertNotNull(sujet)
        if (sujet.hasErrors()) {
            log.error(sujet.errors.allErrors.toListString())
        }
        assertFalse(sujet.hasErrors())

        assertEquals(personne1, sujet.proprietaire)
        assertFalse(sujet.accesPublic)
        assertFalse(sujet.accesSequentiel)
        assertFalse(sujet.ordreQuestionsAleatoire)
        assertEquals(CopyrightsTypeEnum.TousDroitsReserves.copyrightsType, sujet.copyrightsType)
    }

    void testCreateSujetCollaboratifFrom() {
        given: "Un sujet vide non collaboratif"
        Sujet sujetInitial = sujetService.createSujet(personne1, SUJET_1_TITRE)
        assertNotNull(sujetInitial)
        assertNotNull(sujetInitial.id)

        when: "Crée un sujet collaboratif à partir du sujet précédent"
        Sujet sujetCollaboratif = sujetService.createSujetCollaboratifFrom(
                personne1,
                sujetInitial,
                [personne2] as Set
        )

        then:
        assertNotNull(sujetCollaboratif)
        assertNotNull(sujetCollaboratif.id)
        assertTrue(sujetCollaboratif.id != sujetInitial.id)
        assertTrue(sujetCollaboratif.estCollaboratif())
        assertEquals(
                [personne2] as Set,
                sujetCollaboratif.contributeurs
        )
        assertFalse(sujetCollaboratif.termine)
        assertEquals(sujetInitial.titre, sujetCollaboratif.titre)
        assertEquals(sujetInitial.titreNormalise, sujetCollaboratif.titreNormalise)

        given: "On ajoute 2 questions au sujet initial"
        Question question1 = questionService.createQuestion(
                [
                        titre      : "Question 1",
                        type       : QuestionTypeEnum.Decimal.questionType,
                        estAutonome: true
                ],
                new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
                personne1
        )
        sujetService.insertQuestionInSujet(
                question1,
                sujetInitial,
                personne1
        )
        Question question2 = questionService.createQuestion(
                [
                        titre      : "Question 2",
                        type       : QuestionTypeEnum.Decimal.questionType,
                        estAutonome: true
                ],
                new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
                personne1
        )
        sujetService.insertQuestionInSujet(
                question2,
                sujetInitial,
                personne1
        )

        when: "On crée un nouveau sujet collaboratif à partir du sujetInitial modifié"
        sujetCollaboratif = sujetService.createSujetCollaboratifFrom(
                personne1,
                sujetInitial,
                [personne2] as Set
        )

        then:
        assertNotNull(sujetCollaboratif)
        assertNotNull(sujetCollaboratif.id)
        assertTrue(sujetInitial.id != sujetCollaboratif.id)
        assertTrue(sujetCollaboratif.estCollaboratif())
        assertEquals(
                2,
                sujetCollaboratif.questions.size()
        )
        sujetCollaboratif.questions*.each {
            assertTrue(it.estCollaboratif())
            assertEquals(
                    [personne2] as Set,
                    it.contributeurs
            )
        }

        given: "Transforme le sujet initial en exercice"
        Sujet exercice = sujetService.updateProprietes(
                sujetInitial,
                [sujetType: SujetTypeEnum.Exercice.sujetType],
                personne1
        )
        assertTrue(exercice.estUnExercice())

        and: "Crée un nouveau sujet et y ajoute l'exercice"
        Sujet sujetAvecExercice = sujetService.createSujet(
                personne1,
                'Sujet avec exercice'
        )
        assertNotNull(sujetAvecExercice)
        assertNotNull(sujetAvecExercice.id)
        sujetService.insertQuestionInSujet(
                exercice.questionComposite,
                sujetAvecExercice,
                personne1
        )

        when: "Crée un sujet collaboratif à partir du sujet contenant un exercice"
        sujetCollaboratif = sujetService.createSujetCollaboratifFrom(
                personne1,
                sujetAvecExercice,
                [personne2] as Set
        )

        then:
        assertNotNull(sujetCollaboratif)
        assertNotNull(sujetCollaboratif.id)
        assertTrue(sujetCollaboratif.estCollaboratif())
        assertEquals(
                1,
                sujetCollaboratif.questions.size()
        )
        Question questionCompositeCollaborative = sujetCollaboratif.questions.get(0)
        assertTrue(questionCompositeCollaborative.estComposite())
        assertTrue(questionCompositeCollaborative.estCollaboratif())
        Sujet exerciceCollaboratif = questionCompositeCollaborative.exercice
        assertTrue(exerciceCollaboratif.estCollaboratif())
        assertTrue(exerciceCollaboratif.id != exercice.id)
        assertEquals(
                [personne2] as Set,
                exerciceCollaboratif.contributeurs
        )
        assertEquals(
                [personne2] as Set,
                questionCompositeCollaborative.contributeurs
        )
        exerciceCollaboratif.questions.each {
            assertTrue(it.estCollaboratif())
            assertEquals(
                    [personne2] as Set,
                    it.contributeurs
            )
        }
    }

    void testUpdateProprietesSujetCollaboratif() {
      given: "Un sujet non collaboratif"
      Sujet sujetInitial = sujetService.createSujet(personne1, SUJET_1_TITRE)

      when: "On rend le sujet collaboratif en ajoutant un contributeur"
      Sujet sujet = sujetService.updateProprietes(
          sujetInitial,
          [contributeurIds: [personne2.id]],
          personne1
      )
      assertNotNull(sujet)
      if (sujet.hasErrors()) {
        log.error(sujet.errors.allErrors.toListString())
      }
      assertFalse(sujet.hasErrors())

      then: "On obtient un sujet collaboratif par duplication du sujet initial"
      assertEquals(personne1, sujet.proprietaire)
      assertTrue(sujet.collaboratif)
      assertEquals(sujet.contributeurs.size(), 1)
      assertTrue(sujetInitial.id != sujet.id)

      assertEquals(
          [personne2.id] as Set,
          sujet.contributeurs*.id as Set
      )

      given: "On ajoute un nouveau contributeur au sujet collaboratif"
      Sujet sujet2 = sujetService.updateProprietes(
          sujet,
          [
              contributeurIds: [
                  personne2.id,
                  personne3.id
              ]
          ],
          personne1
      )

      then: "Le nouveau contributeur est ajouté au sujet (sans duplication)"
      assertEquals(
          [personne2.id, personne3.id] as Set,
          sujet2.contributeurs*.id as Set
      )
      assertEquals(sujet.id, sujet2.id)
    }

    void testUpdateProprietesSujetCollaboratifAvecQuestion() {

      given: "Un sujet comprenant une question"
      Sujet sujetInitial = sujetService.createSujet(personne1, SUJET_1_TITRE)
      assertNotNull(sujetInitial)
      assertNotNull(sujetInitial.id)

      Question question1 = questionService.createQuestion(
          [
              titre      : "Question 1",
              type       : QuestionTypeEnum.Decimal.questionType,
              estAutonome: true
          ],
          new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
          personne1
      )

      sujetService.insertQuestionInSujet(
          question1,
          sujetInitial,
          personne1
      )

      when: "On rend le sujet collaboratif en ajoutant un contributeur"
      Sujet sujet = sujetService.updateProprietes(
          sujetInitial,
          [contributeurIds: [personne2.id]],
          personne1
      )
      assertNotNull(sujet)
      if (sujet.hasErrors()) {
        log.error(sujet.errors.allErrors.toListString())
      }
      assertFalse(sujet.hasErrors())

      then: "On obtient un sujet collaboratif par duplication"
      assertEquals(personne1, sujet.proprietaire)
      assertTrue(sujet.collaboratif)
      assertTrue(sujetInitial.id != sujet.id)

      assertEquals(
          [personne2.id] as Set,
          sujet.contributeurs*.id as Set
      )

      and: "La question du sujet collaboratif est une question collaborative obtenue par duplication de la question initiale"
      assertEquals(sujet.questions.size(), 1)
      Question questionCollaborative = sujet.questions[0]

      assertTrue(questionCollaborative.collaboratif)
      assertTrue(questionCollaborative.id != question1.id)
      assertEquals(
          [personne2.id] as Set,
          questionCollaborative.contributeurs*.id as Set
      )
      assertEquals(question1.titre, questionCollaborative.titre)
      assertEquals(question1.specification, questionCollaborative.specification)
    }

  void testUpdateProprietesSujetCollaboratifAvecExercice() {
    given: "Une question"
    Question question1 = questionService.createQuestion(
        [
            titre      : "Question 1",
            type       : QuestionTypeEnum.Decimal.questionType,
            estAutonome: true
        ],
        new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
        personne1
    )
    assertNotNull(question1)
    assertNotNull(question1.id)


    and: "Un exercice intégrant la question"
    Sujet exercice = sujetService.createSujet(personne1, 'Exercice')
    assertNotNull(exercice)
    assertNotNull(exercice.id)
    sujetService.updateProprietes(
        exercice,
        [
            sujetType: SujetTypeEnum.Exercice.sujetType
        ],
        personne1
    )
    sujetService.insertQuestionInSujet(
        question1,
        exercice,
        personne1
    )

    and: "Un sujet intégrant l'exercice"
    Sujet sujet = sujetService.createSujet(personne1, 'Sujet')
    assertNotNull(sujet)
    assertNotNull(sujet.id)
    sujetService.insertQuestionInSujet(
        exercice.questionComposite,
        sujet,
        personne1
    )

    when: "On ajoute un contributeur au sujet pour le rendre collaboratif"
    Sujet sujetCollaboratif = sujetService.updateProprietes(
        sujet,
        [contributeurIds: [personne2.id]],
        personne1
    )


    then: "On obtient un sujet collaboratif par duplication"
    assertNotNull(sujetCollaboratif)
    assertFalse(sujetCollaboratif.hasErrors())
    assertTrue(sujetCollaboratif.id != sujet.id)
    assertTrue(sujetCollaboratif.estCollaboratif())
    assertEquals(
        [personne2.id] as Set,
        sujetCollaboratif.contributeurs*.id as Set
    )

    and: "L'exercice du sujet collaboratif est collaboratif, et c'est une duplication de l'exercice initial"
    Sujet exerciceCollaboratif = sujetCollaboratif.questions[0].exercice
    assertTrue(exerciceCollaboratif.estCollaboratif())
    assertTrue(exercice.id != exerciceCollaboratif.id)
    assertTrue(exerciceCollaboratif.questionComposite.estCollaboratif())
    assertEquals(
        sujetCollaboratif.id,
        exerciceCollaboratif.questionComposite.sujetLieId
    )
    assertEquals(
        [personne2.id] as Set,
        exerciceCollaboratif.contributeurs*.id as Set
    )
    assertEquals(
        [personne2.id] as Set,
        exerciceCollaboratif.questionComposite.contributeurs*.id as Set
    )

    and: "La question de l'exercice collaboratif est collaborative"
    Question questionCollaborative = exerciceCollaboratif.questions[0]
    assertTrue(questionCollaborative.estCollaboratif())
    assertTrue(question1.id != questionCollaborative.id)
    assertEquals(
        [personne2.id] as Set,
        questionCollaborative.contributeurs*.id as Set
    )
    assertEquals(
        exerciceCollaboratif.id,
        questionCollaborative.sujetLieId
    )
    assertEquals(
        question1.titre,
        questionCollaborative.titre
    )
    assertEquals(
        question1.specification,
        questionCollaborative.specification
    )
  }

  void testUpdateProprietesExerciceCollaboratif() {
    given: "Une question"
    Question question1 = questionService.createQuestion(
        [
            titre      : "Question 1",
            type       : QuestionTypeEnum.Decimal.questionType,
            estAutonome: true
        ],
        new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
        personne1
    )
    assertNotNull(question1)
    assertNotNull(question1.id)


    and: "Un exercice intégrant la question"
    Sujet exercice = sujetService.createSujet(personne1, 'Exercice')
    assertNotNull(exercice)
    assertNotNull(exercice.id)
    sujetService.updateProprietes(
        exercice,
        [
            sujetType: SujetTypeEnum.Exercice.sujetType
        ],
        personne1
    )
    sujetService.insertQuestionInSujet(
        question1,
        exercice,
        personne1
    )

    when: "On rend l'exercice collaboratif"
    Sujet exerciceCollaboratif = sujetService.updateProprietes(
        exercice,
        [contributeurIds: [personne2.id]],
        personne1
    )

    then: "L'exercice collaboratif est une duplication de l'exercice original"
    assertNotNull(exerciceCollaboratif)
    assertNotNull(exerciceCollaboratif.id)
    assertTrue(exercice.id != exerciceCollaboratif.id)
    assertTrue(exerciceCollaboratif.estCollaboratif())
    assertEquals(
        [personne2.id] as Set,
        exerciceCollaboratif.contributeurs*.id as Set
    )

    and: "La question composite de l'exercice collaboratif est collaborative, est n'est liée à aucun sujet"
    assertTrue(exerciceCollaboratif.questionComposite.estCollaboratif())
    assertNull(exerciceCollaboratif.questionComposite.sujetLie)
    assertEquals(
        [personne2.id] as Set,
        exerciceCollaboratif.questionComposite.contributeurs*.id as Set
    )

    and: "On ne peut pas ajouter de nouveaux contributeurs à l'exercice collaboratif"
    try {
      sujetService.updateProprietes(
          exerciceCollaboratif,
          [contributeurIds: [personne2.id, personne3.id]],
          personne1
      )

      assertFalse(true) // Une exception doit être levée
    }
    catch(IllegalStateException ignore) {
      // Résultat attendu
    }
  }

    void testFindSujetsForProprietaire() {
        Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)
        assertFalse(sujet1.hasErrors())
        Sujet sujet2 = sujetService.createSujet(personne1, SUJET_1_TITRE)
        assertFalse(sujet2.hasErrors())
        assertEquals(2, Sujet.count())
        def sujets1 = sujetService.findSujetsForProprietaire(personne1)
        assertEquals(2, sujets1.size())

        def sujets2 = sujetService.findSujetsForProprietaire(personne2)
        assertEquals(0, sujets2.size())

    }

    void testFindSujets() {
        Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)
        assertFalse(sujet1.hasErrors())

        // tests pour vérifier que la propriété ou le caractère publié
        // conditionne les résultats de recherche


        def res = sujetService.findSujets(personne2, null, null,
                null, null, null, null)

        assertEquals(0, res.size())

        res = sujetService.findSujets(personne1, null, null,
                null, null, null, null)

        assertEquals(1, res.size())

        sujetService.updateProprietes(sujet1, [publie: true], personne1)
        res = sujetService.findSujets(personne2, null, null,
                null, null, null, null)

        assertEquals(1, res.size())

        // verification du fonctionnement du flag "uniquementSujetChercheurs")
        res = sujetService.findSujets(
                personne2,
                null,
                null,
                null,
                null,
                null,
                true
        )

        assertEquals(0, res.size())

        res = sujetService.findSujets(personne1, null, null,
                null, null, null, null)

        assertEquals(1, res.size())

        // tests sur le titre et la presentation avec prise en compte des accents
        //

        def propsSujet1 = [
                titre         : "titre : Un sujet avé des accents àgravê",
                'sujetType.id': 1
        ]
        sujetService.updateProprietes(sujet1, propsSujet1, personne1)

        res = sujetService.findSujets(personne1, "avê", null,
                null, null, null, null)

        assertEquals(1, res.size())

        propsSujet1 = [
                titre         : SUJET_1_TITRE,
                presentation  : "pres : Un sujet avé des accents àgravê",
                'sujetType.id': 1
        ]
        sujetService.updateProprietes(sujet1, propsSujet1, personne1)

        res = sujetService.findSujets(personne1, null, null,
                "avê", null, null, null)

        assertEquals(1, res.size())

    }

    void testFindSujetsCollaboratifs() {
      Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)
      assertFalse(sujet1.hasErrors())

      def res = sujetService.findSujets(personne2, null, null,
          null, null, null, null)

      assertEquals(0, res.size())


      sujetService.updateProprietes(sujet1, [contributeurIds: [personne2.id]], personne1)

      res = sujetService.findSujets(personne2, null, null,
          null, null, null, null)

      assertEquals(1, res.size())

    }

    void testFindSujetsMasques() {
      Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)
      assertFalse(sujet1.hasErrors())

      def res = sujetService.findSujets(personne1, null, null, null, null, null, null)
      assertEquals(1, res.size())

      sujetService.masque(personne1, sujet1)
      res = sujetService.findSujets(personne1, null, null, null, null, null, null)
      assertEquals(0, res.size())
      res = sujetService.findSujets(personne1, null, null, null, null, null, null, null, true)
      assertEquals(1, res.size())

      sujetService.annuleMasque(personne1, sujet1)
      res = sujetService.findSujets(personne1, null, null, null, null, null, null)
      assertEquals(1, res.size())
      res = sujetService.findSujets(personne1, null, null, null, null, null, null, null, true)
      assertEquals(1, res.size())

      res = sujetService.findSujets(personne2, null, null, null, null, null, null)
      assertEquals(0, res.size())

      sujetService.updateProprietes(sujet1, [contributeurIds: [personne2.id]], personne1)

      res = sujetService.findSujets(personne2, null, null, null, null, null, null)
      assertEquals(1, res.size())
      Sujet sujetCollaboratif = res[0]

      sujetService.masque(personne2, sujetCollaboratif)
      res = sujetService.findSujets(personne2, null, null, null, null, null, null)
      assertEquals(0, res.size())
      res = sujetService.findSujets(personne2, null, null, null, null, null, null, null, true)
      assertEquals(1, res.size())

      res = sujetService.findSujets(personne1, null, null, null, null, null, null)
      assertEquals(2, res.size())

      sujetService.annuleMasque(personne2, sujetCollaboratif)
      res = sujetService.findSujets(personne2, null, null, null, null, null, null)
      assertEquals(1, res.size())
      res = sujetService.findSujets(personne2, null, null, null, null, null, null, null, true)
      assertEquals(1, res.size())

      res = sujetService.findSujets(personne1, null, null, null, null, null, null)
      assertEquals(2, res.size())

    }

    void testSujetEstDistribue() {
        Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)
        assertFalse(sujet1.hasErrors())
        def now = new Date()
        def dateDebut = now - 10
        def dateFin = now + 10
        def props = [
                dateDebut               : dateDebut,
                dateFin                 : dateFin,
                datePublicationResultats: dateFin + 2,
                sujet                   : sujet1,
                groupeScolarite         :
                        groupeService.findGroupeScolariteEleveForStructureEnseignement(
                                struct1ere
                        )
        ]
        ModaliteActivite seance1 = modaliteActiviteService.createModaliteActivite(
                props,
                personne1
        )
        if (seance1.hasErrors()) {
            println seance1.errors
        }
        assertTrue(sujet1.estDistribue())
        modaliteActiviteService.updateProprietes(seance1, [dateFin: now - 5], personne1)
        assertFalse(sujet1.estDistribue())
    }

    void testSupprimeSujet() {
        Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)
        Question quest1 = questionService.createQuestion(
                [
                        titre      : "Question 1",
                        type       : QuestionTypeEnum.Decimal.questionType,
                        estAutonome: true
                ],
                new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
                personne1,
        )
        assertFalse(quest1.hasErrors())
        sujetService.insertQuestionInSujet(quest1, sujet1, personne1)

        assertEquals(1, sujet1.questionsSequences.size())

        sujetService.supprimeSujet(sujet1, personne1)

        def sujetQuests = SujetSequenceQuestions.findAllByQuestion(quest1)
        assertEquals(0, sujetQuests.size())
        assertNull(Sujet.get(sujet1.id))
    }

    void testPartageSujet() {
        artefactAutorisationService.partageArtefactCCActive = true
        Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)
        Question quest1 = questionService.createQuestion(
                [
                        titre      : "Question 1",
                        type       : QuestionTypeEnum.Decimal.questionType,
                        estAutonome: true
                ],
                new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
                personne1,
        )
        assertFalse(quest1.hasErrors())
        sujetService.insertQuestionInSujet(quest1, sujet1, personne1)

        assertEquals(1, sujet1.questionsSequences.size())

        assertEquals(CopyrightsTypeEnum.TousDroitsReserves.copyrightsType, sujet1.copyrightsType)
        assertNull(sujet1.publication)

        sujetService.partageSujet(sujet1, personne1)

        assertEquals(CopyrightsTypeEnum.CC_BY_NC.copyrightsType, quest1.copyrightsType)
        assertEquals(CopyrightsTypeEnum.CC_BY_NC.copyrightsType, quest1.publication.copyrightsType)
        assertNotNull(quest1.publication)

        assertEquals(CopyrightsTypeEnum.CC_BY_NC.copyrightsType, sujet1.copyrightsType)
        assertEquals(CopyrightsTypeEnum.CC_BY_NC.copyrightsType, sujet1.publication.copyrightsType)
        assertNotNull(sujet1.publication)

    }

    void testDesactivationPartageSurPartageSujet() {
        artefactAutorisationService.partageArtefactCCActive = false
        Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)
        Question quest1 = questionService.createQuestion(
                [
                        titre      : "Question 1",
                        type       : QuestionTypeEnum.Decimal.questionType,
                        estAutonome: true
                ],
                new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
                personne1,
        )
        assertFalse(quest1.hasErrors())
        sujetService.insertQuestionInSujet(quest1, sujet1, personne1)

        assertEquals(1, sujet1.questionsSequences.size())

        assertEquals(CopyrightsTypeEnum.TousDroitsReserves.copyrightsType, sujet1.copyrightsType)
        assertNull(sujet1.publication)

        assertFalse(artefactAutorisationService.utilisateurPeutPartageArtefact(personne1, sujet1))
    }

  void "testInsertQuestionInSujet - Insérer une question non collaborative dans un sujet collaboratif"() {
    given: "Un sujet collaboratif"
    Sujet sujet = sujetService.createSujet(personne1, SUJET_1_TITRE)
    assertNotNull(sujet.id)
    sujet = sujetService.updateProprietes(
        sujet,
        [contributeurIds: [personne2.id]],
        personne1
    )
    assertTrue(sujet.estCollaboratif())

    and: "Une question non collaborative"
    Question question = questionService.createQuestion(
        [
            titre      : "Question 1",
            type       : QuestionTypeEnum.Decimal.questionType,
            estAutonome: true
        ],
        new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
        personne1
    )
    assertNotNull(question.id)

    when: "On insère la question dans le sujet"
    sujetService.insertQuestionInSujet(
        question,
        sujet,
        personne1
    )

    then: "La question insérée est une duplication collaborative de la question originale"
    Question questionCollaborative = sujet.questions[0]
    assertTrue(questionCollaborative.estCollaboratif())
    assertEquals(sujet.id, questionCollaborative.sujetLieId)
    assertEquals(
        [personne2.id] as Set,
        questionCollaborative.contributeurs*.id as Set
    )
    assertTrue(questionCollaborative.id != question.id)
    assertEquals(question.titre, questionCollaborative.titre)
    assertEquals(question.specification, questionCollaborative.specification)
  }

  void "testInsertQuestionInSujet - Insérer une question collaborative dans un sujet collaboratif auquel elle est liée"() {
    given: "Un sujet collaboratif"
    Sujet sujet = sujetService.createSujet(personne1, SUJET_1_TITRE)
    assertNotNull(sujet.id)
    sujet = sujetService.updateProprietes(
        sujet,
        [contributeurIds: [personne2.id]],
        personne1
    )
    assertTrue(sujet.estCollaboratif())

    and: "Une question non collaborative"
    Question question = questionService.createQuestion(
        [
            titre      : "Question 1",
            type       : QuestionTypeEnum.Decimal.questionType,
            estAutonome: true
        ],
        new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
        personne1
    )
    assertNotNull(question.id)

    and: "On insère la question dans le sujet"
    sujetService.insertQuestionInSujet(
        question,
        sujet,
        personne1
    )
    Question questionCollaborative = sujet.questions[0]

    and: "On retire la question du sujet"
    sujet = sujetService.supprimeQuestionFromSujet(
        sujet.questionsSequences[0],
        personne1
    )
    assertEquals(0, sujet.questions.size())

    when: "On insère à nouveau la question collaborative dans son sujet"
    sujetService.insertQuestionInSujet(
        questionCollaborative,
        sujet,
        personne1
    )

    then: "La question collaborative est directement insérée (sans duplication)"
    Question questionInseree = sujet.questions[0]
    assertEquals(questionCollaborative.id, questionInseree.id)
    assertEquals(2, Question.findAll().size())
  }

  void "testInsertQuestionInSujet - Insérer une question collaborative dans un sujet collaboratif auquel elle n'est pas liée"() {
    given: "Un sujet collaboratif comprenant une question"
    Sujet sujet = sujetService.createSujet(personne1, SUJET_1_TITRE)
    assertNotNull(sujet.id)
    sujet = sujetService.updateProprietes(
        sujet,
        [contributeurIds: [personne2.id]],
        personne1
    )
    assertTrue(sujet.estCollaboratif())

    Question question = questionService.createQuestion(
        [
            titre      : "Question 1",
            type       : QuestionTypeEnum.Decimal.questionType,
            estAutonome: true
        ],
        new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
        personne1
    )
    assertNotNull(question.id)

    sujetService.insertQuestionInSujet(
        question,
        sujet,
        personne1
    )
    Question questionCollaborative = sujet.questions[0]

    and: "Un autre sujet collaboratif"
    Sujet sujet2 = sujetService.createSujet(personne1, SUJET_1_TITRE)
    assertNotNull(sujet2.id)
    sujet2 = sujetService.updateProprietes(
        sujet2,
        [contributeurIds: [personne3.id]],
        personne1
    )
    assertTrue(sujet2.estCollaboratif())

    when: "On insère la question collaborative dans le 2eme sujet"
    sujetService.insertQuestionInSujet(
        questionCollaborative,
        sujet2,
        personne1
    )

    then: "La question collaborative insérée est une duplication de la question originale"
    Question questionInseree = sujet2.questions[0]
    assertTrue(questionInseree.estCollaboratif())
    assertTrue(questionCollaborative.id != questionInseree.id)
    assertEquals(sujet2.id, questionInseree.sujetLieId)
    assertEquals(questionCollaborative.titre, questionInseree.titre)
    assertEquals(questionCollaborative.specification, questionInseree.specification)
    assertEquals(3, Question.findAll().size())
  }

  void "testInsertQuestionInSujet - Insérer une question collaborative dans un sujet non collaboratif"() {
    given: "Un sujet collaboratif comprenant une question"
    Sujet sujet = sujetService.createSujet(personne1, SUJET_1_TITRE)
    assertNotNull(sujet.id)
    sujet = sujetService.updateProprietes(
        sujet,
        [contributeurIds: [personne2.id]],
        personne1
    )
    assertTrue(sujet.estCollaboratif())

    Question question = questionService.createQuestion(
        [
            titre      : "Question 1",
            type       : QuestionTypeEnum.Decimal.questionType,
            estAutonome: true
        ],
        new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
        personne1
    )
    assertNotNull(question.id)

    sujetService.insertQuestionInSujet(
        question,
        sujet,
        personne1
    )
    Question questionCollaborative = sujet.questions[0]

    and: "Un autre sujet, non collaboratif"
    Sujet sujetNonCollaboratif = sujetService.createSujet(personne1, SUJET_1_TITRE)
    assertNotNull(sujetNonCollaboratif.id)

    when: "On insère la question collaborative dans le sujet non-collaboratif"
    sujetService.insertQuestionInSujet(
        questionCollaborative,
        sujetNonCollaboratif,
        personne1
    )

    then: "La question insérée est une duplication de la question collaborative"
    Question questionInseree = sujetNonCollaboratif.questions[0]
    assertFalse(questionInseree.estCollaboratif())
    assertTrue(questionInseree.id != questionCollaborative.id)
    assertEquals(3, Question.findAll().size()) // On a la question originale, la duplication collaborative, et la duplication non-collaborative
  }

  void testFinaliseSujet() {
    Sujet sujet = sujetService.createSujet(personne1, SUJET_1_TITRE)
    assertTrue(artefactAutorisationService.utilisateurPeutModifierArtefact(personne1, sujet))
    assertTrue(artefactAutorisationService.utilisateurPeutCreerSeance(personne1, sujet))
    assertTrue(artefactAutorisationService.utilisateurPeutAjouterItem(personne1, sujet))

    sujet = sujetService.updateProprietes(sujet, [contributeurIds: [personne2.id]], personne1)
    assertTrue(artefactAutorisationService.utilisateurPeutModifierArtefact(personne1, sujet))
    assertFalse(artefactAutorisationService.utilisateurPeutCreerSeance(personne1, sujet))
    assertTrue(artefactAutorisationService.utilisateurPeutAjouterItem(personne1, sujet))

    sujetService.finalise(sujet, sujet.lastUpdated, personne1)
    assertFalse(artefactAutorisationService.utilisateurPeutModifierArtefact(personne1, sujet))
    assertTrue(artefactAutorisationService.utilisateurPeutCreerSeance(personne1, sujet))
    assertFalse(artefactAutorisationService.utilisateurPeutAjouterItem(personne1, sujet))

    sujetService.annuleFinalise(sujet, personne1)
    assertTrue(artefactAutorisationService.utilisateurPeutModifierArtefact(personne1, sujet))
    assertFalse(artefactAutorisationService.utilisateurPeutCreerSeance(personne1, sujet))
    assertTrue(artefactAutorisationService.utilisateurPeutAjouterItem(personne1, sujet))
  }

  void testCreateQuestionCompositeForExercice() {
    Sujet sujet = sujetService.createSujet(personne1, SUJET_1_TITRE)

    Question question = sujetService.createQuestionCompositeForExercice(sujet, personne1)

    assertEquals(question.proprietaireId, sujet.proprietaireId)
    assertEquals(question.titre, sujet.titre)
    assertEquals(question.type, QuestionTypeEnum.Composite.questionType)
    assertEquals(question.exerciceId, sujet.id)
  }

  void testCreateQuestionCompositeForExerciceCollaboratif() {
    Sujet sujet = sujetService.updateProprietes(
        sujetService.createSujet(personne1, SUJET_1_TITRE),
        [contributeurIds: [personne2.id]],
        personne1
    )

    Question question = sujetService.createQuestionCompositeForExercice(sujet, personne1)

    assertEquals(question.proprietaireId, sujet.proprietaireId)
    assertEquals(question.titre, sujet.titre)
    assertEquals(question.type, QuestionTypeEnum.Composite.questionType)
    assertEquals(question.exerciceId, sujet.id)
    assertTrue(question.collaboratif)
    assertEquals(question.contributeurs.size(), sujet.contributeurs.size())
  }

  void testRecopieSujet() {
    Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)

    sujetService.insertQuestionInSujet(
        questionService.createQuestion(
            [
                titre      : "Question 1",
                type       : QuestionTypeEnum.Decimal.questionType,
                estAutonome: true
            ],
            new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
            personne1,
        ),
        sujet1,
        personne1)

    sujetService.insertQuestionInSujet(
        questionService.createQuestion(
            [
                titre      : "Question 2",
                type       : QuestionTypeEnum.Decimal.questionType,
                estAutonome: true
            ],
            new DecimalSpecification(libelle: "question", valeur: 15, precision: 0),
            personne1,
        ),
        sujet1,
        personne1)

    Sujet sujet2 = sujetService.recopieSujet(sujet1, personne1)

    assertEquals(sujet2.proprietaireId, personne1.id)
    assertEquals(sujet1.titre + " (Copie)", sujet2.titre)
    assertEquals(sujet1.questionsSequences.size(), sujet2.questionsSequences.size())
  }

}
