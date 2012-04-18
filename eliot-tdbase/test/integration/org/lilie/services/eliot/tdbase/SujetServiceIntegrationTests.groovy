package org.lilie.services.eliot.tdbase

import org.hibernate.SessionFactory
import org.lilie.services.eliot.tdbase.impl.decimal.DecimalSpecification
import org.lilie.services.eliot.tdbase.utils.TdBaseInitialisationTestService
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement

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

  Utilisateur utilisateur1
  Personne personne1
  Utilisateur utilisateur2
  Personne personne2
  StructureEnseignement struct1ere
  SessionFactory sessionFactory

  TdBaseInitialisationTestService tdBaseInitialisationTestService
  SujetService sujetService
  ModaliteActiviteService modaliteActiviteService
  QuestionService questionService


  protected void setUp() {
    super.setUp()
    utilisateur1 = tdBaseInitialisationTestService.getUtilisateur1()
    personne1 = utilisateur1.personne
    utilisateur2 = tdBaseInitialisationTestService.getUtilisateur2()
    personne2 = utilisateur2.personne
    struct1ere = tdBaseInitialisationTestService.findStructure1ere()
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

      Sujet sujet = sujetService.updateProprietes(new Sujet(),[titre: SUJET_2_TITRE],personne1)
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
    res = sujetService.findSujets(personne2, null, null,
                                      null, null, null, null, true)

    assertEquals(0, res.size())

    res = sujetService.findSujets(personne1, null, null,
                                  null, null, null, null)

    assertEquals(1, res.size())

    // tests sur le titre et la presentation avec prise en compte des accents
    //

    def propsSujet1 = [
            titre: "titre : Un sujet avé des accents àgravê",
            'sujetType.id': 1
    ]
    sujetService.updateProprietes(sujet1, propsSujet1, personne1)

    res = sujetService.findSujets(personne1, "avê", null,
                                  null, null, null, null)

    assertEquals(1, res.size())

    propsSujet1 = [
            titre: SUJET_1_TITRE,
            presentation: "pres : Un sujet avé des accents àgravê",
            'sujetType.id': 1
    ]
    sujetService.updateProprietes(sujet1, propsSujet1, personne1)

    res = sujetService.findSujets(personne1, null, null,
                                  "avê", null, null, null)

    assertEquals(1, res.size())

  }

  void testSujetEstDistribue() {
    Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)
    assertFalse(sujet1.hasErrors())
    def now = new Date()
    def dateDebut = now - 10
    def dateFin = now + 10
    def props = [
            dateDebut: dateDebut,
            dateFin: dateFin,
            sujet: sujet1,
            structureEnseignement: struct1ere
    ]
    ModaliteActivite seance1 = modaliteActiviteService.createModaliteActivite(
            props,
            personne1
    )
    assertTrue(sujet1.estDistribue())
    modaliteActiviteService.updateProprietes(seance1, [dateFin: now - 5], personne1)
    assertFalse(sujet1.estDistribue())
  }

  void testSupprimeSujet() {
    Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)
    Question quest1 = questionService.createQuestion(
            [
                    titre: "Question 1",
                    type: QuestionTypeEnum.Decimal.questionType,
                    estAutonome: true
            ],
            new DecimalSpecification(libelle: "question", valeur: 15),
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
    Sujet sujet1 = sujetService.createSujet(personne1, SUJET_1_TITRE)
    Question quest1 = questionService.createQuestion(
            [
                    titre: "Question 1",
                    type: QuestionTypeEnum.Decimal.questionType,
                    estAutonome: true
            ],
            new DecimalSpecification(libelle: "question", valeur: 15),
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

}
