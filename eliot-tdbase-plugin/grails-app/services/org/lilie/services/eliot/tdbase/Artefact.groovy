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

/**
 * Un artefact représente une question ou un sujet
 * @author franck Silvestre
 */
public interface Artefact {

  /**
   * Le propriétaire d'un artefact est l'utilisateur qui a créé l'emprunte
   * mémoire sur l'espace de l'ENT correspondant à l'artefact. Il est par
   * exemple le créateur initial d'un item ou d'un sujet. Si un utilisateur
   * duplique un artefact, alors il devient propriétaire du nouvel artefact
   * issue de la duplication.
   * @return le proprietaire de l'artefact
   */
  Personne getProprietaire()

  /**
   * Un artefact est paratagé si il est distribué sous licence Creative Commons
   * CC BY-NC. Un artefact ne peut être paratagé que par volonté de son
   * propriétaire
   * @return true si l'artefact est partagé
   */
  boolean estPartage()

  /**
   * Un artefact est distribué lorsqu'il est mis à disposition pour une
   * interaction pédagogique. Par exemple un sujet est distribué quand il est
   * associé à une séance. Un item est distribué quand il est attaché à un
   * sujet distribué.
   * @return true si l'artefact est distribué
   */
  boolean estDistribue()

  /**
   * Un artefact est invariant lorsqu'un utilisateur ne peut pas le modifier ou
   * le supprimer ou le creer directement.
   * Par exemple : une question compositie est "invariante" car elle n'est gérée
   * que par l'intermediaire de la gestion du sujet qu'elle reference.
   * @return true si l'artefact est invariant
   */
  boolean estInvariant()

  /**
   * Vrai si l'artefact peut être presenté sous forme de Moodle XML.
   * @return true si l'artefact est presentable en Moodle XML.
   */
  boolean estPresentableEnMoodleXML()

  /**
   * Vrai si l'artefact peut-être supprimeé l'artefact.
   * Cette méthode est appeler après avoir vérifier que l'artefact est modifiable
   * @return  true si artefact  peut être supprimé
   */
  boolean estSupprimableQuandArtefactEstModifiable()

}