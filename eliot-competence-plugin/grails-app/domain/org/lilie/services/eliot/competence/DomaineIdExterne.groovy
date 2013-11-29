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

/**
 * Représente l'identifiant d'un domaine sur une source externe
 *
 * Ce domaine est introduit pour permettre de stocker les idExternes de différentes sources
 *
 * @author John Tranier
 */
class DomaineIdExterne {

  String idExterne
  SourceReferentiel sourceReferentiel

  static belongsTo = [domaine: Domaine]

  static mapping = {
    table 'competence.domaine_id_externe'
    id column: 'id', generator: 'sequence', params: [sequence: 'competence.domaine_id_externe_id_seq']
    sourceReferentiel column: 'source'
    version false
    cache true
  }

  static constraints = {
    idExterne nullable: false, blank: false, unique: 'sourceReferentiel'
    sourceReferentiel nullable: false
  }

  boolean equals(o) {
    if (this.is(o)) return true
    if (getClass() != o.class) return false

    CompetenceIdExterne that = (CompetenceIdExterne) o

    if (idExterne != that.idExterne) return false
    if (sourceReferentiel != that.sourceReferentiel) return false

    return true
  }

  int hashCode() {
    int result
    result = idExterne.hashCode()
    result = 31 * result + sourceReferentiel.hashCode()
    return result
  }

  @Override
  public String toString() {
    return "CompetenceIdExterne{" +
        "sourceReferentiel=" + sourceReferentiel +
        ", idExterne='" + idExterne + '\'' +
        '}';
  }
}
