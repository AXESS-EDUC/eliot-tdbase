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
package org.lilie.services.eliot.competence

import org.springframework.transaction.annotation.Transactional

/**
 * Service permettant d'initialiser un jeu de données de test
 * pour les référentiels de compétence
 *
 * @author John Tranier
 */
class ReferentielBootstrapService {

  static transactional = false

  ReferentielService referentielService

  @Transactional
  void initialiseReferentielTest() {
    referentielService.importeReferentiel(
        new ReferentielDto(
            nom: "Test",
            description: "Référentiel de test",
            allDomaine: [
                new DomaineDto(
                    nom: "Maîtrise de la langue française",
                    allSousDomaine: [
                        new DomaineDto(
                            nom: "Lire",
                            allCompetence: [
                                new CompetenceDto(nom: "Adapter son mode de lecture à la nature du texte proposé et à l'objectif poursuivi"),
                                new CompetenceDto(nom: "Repérer les informations dans un texte à partir des éléments explicites et des éléments implicites nécessaires"),
                                new CompetenceDto(nom: "Utiliser ses capacités de raisonnement, ses connaissances sur la langue, savoir faire appel à des outils appropriés pour lire"),
                                new CompetenceDto(nom: "Dégager, par écrit ou oralement, l'essentiel d'un texte lu"),
                                new CompetenceDto(nom: "Manifester, par des moyens divers, sa compréhension de textes variés")
                            ]
                        ),
                        new DomaineDto(
                            nom: "Écrire",
                            allCompetence: [
                                new CompetenceDto(nom: "Reproduire un document sans erreur et avec une présentation adaptée"),
                                new CompetenceDto(nom: "Écrire lisiblement un texte, spontanément ou sous la dictée, en respectant l'orthographe et la grammaire"),
                                new CompetenceDto(nom: "Rédiger un texte bref, cohérent et ponctué, en réponse à une question ou à partir de consignes données"),
                                new CompetenceDto(nom: "Utiliser ses capacités de raisonnement, ses connaissances sur la langue, savoir faire appel à des outils variés pour améliorer son texte")
                            ]
                        ),
                        new DomaineDto(
                            nom: "Dire",
                            allCompetence: [
                                new CompetenceDto(nom: "Formuler clairement un propos simple"),
                                new CompetenceDto(nom: "Développer de façon suivie un propos en public sur un sujet déterminé"),
                                new CompetenceDto(nom: "Adapter sa prise de parole à la situation de communication"),
                                new CompetenceDto(nom: "Participer à un débat, à un échange verbal")
                            ]
                        )
                    ]
                ),
                new DomaineDto(
                    nom: "Pratique d'une langue vivante étrangère",
                    allSousDomaine: [
                        new DomaineDto(
                            nom: "Réagir et dialoguer",
                            allCompetence: [
                                new CompetenceDto(nom: "Établir un contact social"),
                                new CompetenceDto(nom: "Dialoguer sur des sujets familiers"),
                                new CompetenceDto(nom: "Demander et donner des informations"),
                                new CompetenceDto(nom: "Réagir à des propositions")
                            ]
                        ),
                        new DomaineDto(
                            nom: "écouter et comprendre",
                            allCompetence: [
                                new CompetenceDto(nom: "Comprendre un message oral pour réaliser une tâche"),
                                new CompetenceDto(nom: "Comprendre les points essentiels d'un message oral (conversation, information, récit, exposé)")
                            ]
                        )
                    ]
                )
            ]
        )
    )
  }
}
