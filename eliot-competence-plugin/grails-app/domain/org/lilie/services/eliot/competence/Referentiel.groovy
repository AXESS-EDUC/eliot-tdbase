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
 * Représente un référentiel de compétence Eliot
 *
 * @author John Tranier
 */
class Referentiel {

  String nom
  String description
  String referentielVersion
  String dateVersion
  String urlReference

  static hasMany = [
      allDomaine: Domaine,
      idExterneList: ReferentielIdExterne
  ]

  static mapping = {
    table 'competence.referentiel'
    id column: 'id', generator: 'sequence', params: [sequence: 'competence.referentiel_id_seq']
    idExterneList lazy: false
    version false
    cache true
  }

  static constraints = {
    nom blank: false, unique: true
    description nullable: true
    referentielVersion nullable: true
    dateVersion nullable: true
    urlReference nullable: true
  }

  Collection<Domaine> getDomaineRacineList() {
    allDomaine.grep { Domaine domaine -> !domaine.domaineParent }
  }

  /**
   * Affiche en console le contenu d'un référentiel
   */
  void print() {
    println "=== Référentiel $nom"
    allDomaine.each { Domaine domaine ->
      domaine.print()
    }
  }

  boolean equals(o) {
    if (this.is(o)) return true
    if (getClass() != o.class) return false

    Referentiel that = (Referentiel) o

    if (nom != that.nom) return false

    return true
  }

  int hashCode() {
    return nom.hashCode()
  }


  @Override
  public String toString() {
    return nom
  }
}
