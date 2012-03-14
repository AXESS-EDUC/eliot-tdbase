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

package org.lilie.services.eliot.tice.textes

/**
 * The DateActivite entity.
 *
 * @author
 *
 *
 */
class DateActivite {
  static mapping = {
    table 'entcdt.date_activite'
    id column: 'id', generator: 'sequence', params: [sequence: 'entcdt.date_activite_id_seq']
    activite column: 'id_activite'
    sort dateActivite: 'desc'
    version false
  }
  Long id
  Date dateActivite
  Date dateEcheance
  Long duree

  static belongsTo = [activite: Activite]

  static constraints = {
    id(max: 9999999999L)
    version(max: 9999999999L)
    dateActivite(nullable: true)
    dateEcheance(nullable: true)
    duree(nullable: true, max: 9999999999L)
  }

  String toString() {
    return "${id}"
  }

  /**
   * Retourne une copie de la date
   * Important: la copie ne correspond pas à la même entrée dans la base (les propriétés 'id' et 'version' ne sont pas copiées) 
   */
  DateActivite retourneCopie() {
    return new DateActivite(dateActivite: dateActivite, dateEcheance: dateEcheance, duree: duree)
  }


  int hashCode() {
    int result;

    result = (id != null ? id.hashCode() : 0);
    result = 31 * result + (dateActivite != null ? dateActivite.hashCode() : 0);
    result = 31 * result + (dateEcheance != null ? dateEcheance.hashCode() : 0);
    result = 31 * result + (duree != null ? duree.hashCode() : 0);
    return result;
  }
/**
 * Retourne 'true' si l'objet 'o' est égal à celui-ci
 * Attention: le test d'égalité ne se base que sur dateActivite, dateEcheance et duree
 */
  boolean equals(o) {
    if (this.is(o)) {
      return true;
    }

    if (!(o instanceof DateActivite)) {
      return false;
    }

    DateActivite that = (DateActivite) o;

    if (dateActivite ? !dateActivite.equals(that.dateActivite) : that.dateActivite != null) {
      return false;
    }
    if (dateEcheance ? !dateEcheance.equals(that.dateEcheance) : that.dateEcheance != null) {
      return false;
    }
    if (duree ? !duree.equals(that.duree) : that.duree != null) {
      return false;
    }

    return true;
  }
}
