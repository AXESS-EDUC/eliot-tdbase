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

/**
 * Interface de Specifications.
 */
public interface Specification {
  /**
   * Marshalling des membres de la classe vers une map
   * @return map des valeurs sous forme des Strings
   */
  Map toMap()

  /**
   *
   * @return le code du type de question
   */
  String getQuestionTypeCode()
}

/**
 * Interface de marquage.
 */
public interface QuestionSpecification extends Specification {

  /**
   * Actualise toutes les références à des identifiants de questionAttachementId
   * en remplaçant les identifiants actuels par ceux qui leur sont associé dans la Map
   * tableCorrespondanceId
   *
   * Cette méthode doit être appelé à l'import d'une question car les identifiants son
   * locaux à un environnement (dans le cas d'un import / export, l'environnement d'export
   * peut être différent de l'environnement d'import)
   *
   * @param tableCorrespondanceId
   */
  QuestionSpecification actualiseAllQuestionAttachementId(Map<Long, Long> tableCorrespondanceId)

  /**
   * Remplace toutes les références à un QuestionAttachementId par un nouvel id
   * @param ancienId
   * @param nouvelId
   * @return
   */
  QuestionSpecification remplaceQuestionAttachementId(Long ancienId, Long nouvelId)

  /**
   * @return tous les QuestionAttachementId référencés dans cette spécification
   */
  List<Long> getAllQuestionAttachementId()
}

/**
 * Interface de marquage.
 */
public interface ReponseSpecification extends Specification {

  /**
   * Evalue la reponse.
   * @param maximumPoints le points maximals que l'on peut
   * atteindre si la reponse est correcte.
   * @return le points en fonction de la qualité de la reponse.
   */
  float evaluate(float maximumPoints);

}