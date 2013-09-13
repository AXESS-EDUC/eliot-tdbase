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
 * Représente un domaine de compétence
 *  - un domaine de compétence fait parti d'un référentiel de compétence
 *  - un domaine de compétence est constitué de sous domaines et de compétences
 *  - les constituants (sous domaines & compétences) ne sont pas ordonnés
 *
 * Contrainte : le nom d'un domaine doit être unique au sein d'un référentiel
 *
 * @author John Tranier
 */

// Je ne vois pas actuellement comment redéfinir proprement la méthode equals
// S'appuyer sur les identifiants n'est pas une bonne approche car ils sont modifiés au 1er enregistrement
// Définir l'égalité ici nécessite de traverser des relations, ce qui génèreraient des requêtes en base
@SuppressWarnings('GrailsDomainHasEquals')
class Domaine {

  static belongsTo = [
      domaineParent: Domaine,
      referentiel: Referentiel
  ]

  String nom
  String description

  static hasMany = [
      allSousDomaine: Domaine,
      allCompetence: Competence
  ]

  static mapping = {
    table 'competence.domaine'
    id column: 'id', generator: 'sequence', params: [sequence: 'competence.domaine_id_seq']
    domaineParent column: 'domaine_parent_id'
    referentiel column: 'referentiel_id'
    version false
    cache true
  }

  static constraints = {
    domaineParent nullable: true
    nom blank: false, unique: 'referentiel'
    description nullable: true
    domaineParent validator: { val, obj ->
      !val || val.referentiel == obj.referentiel
    }
  }

  /**
   * Affiche en console le contenu d'un domaine
   * @param indent niveau du domaine dans le référentiel (0 pour les domaines racines)
   */
  void print(int indent = 0) {
    (indent + 2).times { print "=== "}
    println "Domaine $nom"
    allSousDomaine.each { Domaine sousDomaine ->
      sousDomaine.print(indent + 1)
    }
    allCompetence.each { Competence competence ->
      competence.print(indent)
    }
  }


  @Override
  public String toString() {
    if(domaineParent) {
      return "${domaineParent.toString()}/$nom"
    }
    else {
      return "${referentiel.toString()}/$nom"
    }
  }
}
