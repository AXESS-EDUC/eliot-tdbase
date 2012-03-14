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
 * The Ressource entity.
 *
 * @author
 *
 *
 */
class Ressource {
  static mapping = {
    table 'entcdt.ressource'
    id column: 'id', generator: 'sequence', params: [sequence: 'entcdt.ressource_id_seq']
    activite column: 'id_activite'
    fichier column: 'id_fichier'
    version false
  }
  Long id
  //Long idFichier
  Fichier fichier
  String url
  Long ordre
  String description
  Boolean estPubliee = Boolean.FALSE
  Date datePublication
  Activite activite

  static belongsTo = [activite: Activite]

  static constraints = {
    id(max: 9999999999L)
    version(max: 9999999999L)
    ordre(max: 9999999999L, nullable: false)
    datePublication(nullable: true)
    activite(nullable: false)
    estPubliee(nullable: false)
    fichier(nullable: true)
    url(nullable: true, url: true)
    description(nullable: true)
  }

  String toString() {
    return "${id}"
  }


  int hashCode() {
    int result;

    result = (id != null ? id.hashCode() : 0);
    result = 31 * result + (fichier != null ? fichier.hashCode() : 0);
    result = 31 * result + (url != null ? url.hashCode() : 0);
    result = 31 * result + (ordre != null ? ordre.hashCode() : 0);
    result = 31 * result + (description != null ? description.hashCode() : 0);
    result = 31 * result + (estPubliee != null ? estPubliee.hashCode() : 0);
    result = 31 * result + (datePublication != null ? datePublication.hashCode() : 0);
    return result;
  }
/**
 * Retourne 'true' si l'objet o est égal à celui-ci
 * Attention: le test d'égalité ne se base que sur datePublication, description, estPubliee, fichier, ordre, url
 */
  boolean equals(o) {
    if (this.is(o)) {
      return true;
    }

    if (!(o instanceof Ressource)) {
      return false;
    }

    Ressource ressource = (Ressource) o;

    if (datePublication ? !datePublication.equals(ressource.datePublication) : ressource.datePublication != null) {
      return false;
    }
    if (description ? !description.equals(ressource.description) : ressource.description != null) {
      return false;
    }
    if (estPubliee ? !estPubliee.equals(ressource.estPubliee) : ressource.estPubliee != null) {
      return false;
    }
    if (fichier ? !fichier.equals(ressource.fichier) : ressource.fichier != null) {
      return false;
    }
    if (ordre != null ? !ordre.equals(ressource.ordre) : ressource.ordre != null) {
      return false;
    }
    if (url ? !url.equals(ressource.url) : ressource.url != null) {
      return false;
    }

    return true;
  }

}
