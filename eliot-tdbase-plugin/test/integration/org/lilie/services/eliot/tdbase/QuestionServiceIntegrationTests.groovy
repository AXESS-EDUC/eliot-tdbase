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

import org.hibernate.SessionFactory
import org.lilie.services.eliot.tdbase.impl.decimal.DecimalSpecification
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeService
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement
import org.lilie.services.eliot.tice.Publication
import org.lilie.services.eliot.tice.utils.BootstrapService

/**
 *
 * @author franck Silvestre
 */
class QuestionServiceIntegrationTests extends GroovyTestCase {

    private static final String SUJET_1_TITRE = "Sujet test 1"

    Personne personne1
    Personne personne2
    StructureEnseignement struct1ere
    SessionFactory sessionFactory

    BootstrapService bootstrapService
    QuestionService questionService
    SujetService sujetService
    ModaliteActiviteService modaliteActiviteService
    ArtefactAutorisationService artefactAutorisationService
    GroupeService groupeService


    protected void setUp() {
        super.setUp()
        bootstrapService.bootstrapForIntegrationTest()
        personne1 = bootstrapService.enseignant1
        personne2 = bootstrapService.enseignant2
        struct1ere = bootstrapService.classe1ere
    }

    protected void tearDown() {
        super.tearDown()
    }


    void testQuestionEstDistribue() {
        Sujet sujet2 = sujetService.createSujet(personne1, SUJET_1_TITRE)
        assertFalse(sujet2.hasErrors())
        def sujet1 = Sujet.get(sujet2.id)
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

        assertNotNull(sujet1.questionsSequences)

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
        assertFalse(seance1.hasErrors())
        assertTrue(quest1.estDistribue())
        modaliteActiviteService.updateProprietes(seance1, [dateFin: now - 5], personne1)
        assertFalse(quest1.estDistribue())
    }

    void testSupprimeQuestion() {

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

        assertNotNull(sujet1.questionsSequences)
        def quest2 = Question.findById(quest1.id)
        questionService.supprimeQuestion(quest2, personne1)
        // flush necessaire sinon suppression non visible
        sessionFactory.currentSession.flush()
        def quest3 = Question.findById(quest1.id)
        assertNull(quest3)
        def sujetQuests = SujetSequenceQuestions.findAllBySujet(sujet1)
        assertEquals(0, sujetQuests.size())

    }

    void testPartageQuestion() {
        artefactAutorisationService.partageArtefactCCActive = true
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
        assertEquals(CopyrightsTypeEnum.TousDroitsReserves.copyrightsType, quest1.copyrightsType)
        assertNull(quest1.publication)

        questionService.partageQuestion(quest1, personne1)
        assertEquals(CopyrightsTypeEnum.CC_BY_NC.copyrightsType, quest1.copyrightsType)
        assertEquals(CopyrightsTypeEnum.CC_BY_NC.copyrightsType, quest1.publication.copyrightsType)
        assertNotNull(quest1.publication)
    }

    void testDesactivationPartageSurPartageQuestion() {
        artefactAutorisationService.partageArtefactCCActive = false
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
        assertEquals(CopyrightsTypeEnum.TousDroitsReserves.copyrightsType, quest1.copyrightsType)
        assertNull(quest1.publication)
        assertFalse(artefactAutorisationService.utilisateurPeutPartageArtefact(personne1, quest1))
    }

    void testSupprimeQuestionAvecPartage() {
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
        questionService.partageQuestion(quest1, personne1)
        assertNotNull(quest1.publication)
        sujetService.insertQuestionInSujet(quest1, sujet1, personne1)

        assertNotNull(sujet1.questionsSequences)
        def quest2 = Question.findById(quest1.id)
        def idPub = quest2.publication.id
        questionService.supprimeQuestion(quest2, personne1)
        // flush necessaire sinon suppression non visible
        sessionFactory.currentSession.flush()
        def quest3 = Question.findById(quest1.id)
        assertNull(quest3)
        def sujetQuests = SujetSequenceQuestions.findAllBySujet(sujet1)
        assertEquals(0, sujetQuests.size())

        def publi = Publication.findById(idPub)
        assertNull(publi)


    }

  void testFindQuestionsMasquees() {
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

    def res

    res = questionService.findQuestions(personne1, null, null, null, null, null, null, null, null)
    assertEquals(1, res.size())

    questionService.masque(personne1, quest1)

    res = questionService.findQuestions(personne1, null, null, null, null, null, null, null, null)
    assertEquals(0, res.size())

    res = questionService.findQuestions(personne1, null, null, null, null, null, null, null, null, true)
    assertEquals(1, res.size())

    res = questionService.findQuestions(personne2, null, null, null, null, null, null, null, null)
    assertEquals(0, res.size())

    questionService.annuleMasque(personne1, quest1)

    res = questionService.findQuestions(personne1, null, null, null, null, null, null, null, null)
    assertEquals(1, res.size())

    res = questionService.findQuestions(personne1, null, null, null, null, null, null, null, null, true)
    assertEquals(1, res.size())

  }

}
