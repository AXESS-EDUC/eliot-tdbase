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
 * Fichier.
 * @author
 */
class Fichier {
  static mapping = {
    table 'entcdt.fichier'
    id column: 'id', generator: 'sequence', params: [sequence: 'entcdt.fichier_id_seq']
    version false
  }
  Long id
  String nom
  byte[] blob
  Ressource ressource
  CahierDeTextes cahierDeTextes

  static belongsTo = [ressource: Ressource, cahierDeTextes: CahierDeTextes]

  int hashCode() {
    int result;

    result = (id != null ? id.hashCode() : 0);
    result = 31 * result + (nom != null ? nom.hashCode() : 0);
    result = 31 * result + (blob != null ? Arrays.hashCode(blob) : 0);
    return result;
  }

  static constraints = {
    id(max: 9999999999L)
    version(max: 9999999999L)
    nom(nullable: true)
    blob(nullable: false)

    ressource(nullable: true)
    cahierDeTextes(nullable: true)
  }

  String toString() {
    return "${id} ${nom}"
  }

  /**
   * Retourne 'true' si l'objet 'o' est égal à celui-ci
   * Attention: le test d'égalité ne se base que sur le nom du fichier et le blob 
   */
  boolean equals(o) {
    if (this.is(o)) {
      return true;
    }

    if (!(o instanceof Fichier)) {
      return false;
    }

    Fichier fichier = (Fichier) o;

    if (!java.util.Arrays.equals(blob, fichier.blob)) {
      return false;
    }
    if (nom ? !nom.equals(fichier.nom) : fichier.nom != null) {
      return false;
    }

    return true;
  }
}
