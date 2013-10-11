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
 * Une représente une compétence
 *  - une compétence appartient à un référentiel de compétence
 *  - une compétence appartient à un domaine de compétence (qui lui aussi fait nécessairement
 *  parti du référentiel de compétence)
 *
 * Contrainte : le nom d'une compétence doit être unique au sein d'un référentiel
 *
 * @author John Tranier
 */
// Je ne vois pas actuellement comment redéfinir proprement la méthode equals
// S'appuyer sur les identifiants n'est pas une bonne approche car ils sont modifiés au 1er enregistrement
// Définir l'égalité ici nécessite de traverser des relations, ce qui génèreraient des requêtes en base
@SuppressWarnings('GrailsDomainHasEquals')
class Competence {

  static belongsTo = [domaine: Domaine]

  // Note : le choix d'associer la compétence au référentiel est délibéré.
  // Cette information est redondante avec le domaine (qui porte aussi le référentiel),
  // mais cette redondance permet de récupérer en 1 seule requête toutes les compétences
  // d'un référentiel (sans quoi il faudrait itérer sur toutes l'arborescence des domaines)
  Referentiel referentiel

  String nom
  String description

  static hasMany = [
      idExterneList: CompetenceIdExterne
  ]

  static mapping = {
    table 'competence.competence'
    id column: 'id', generator: 'sequence', params: [sequence: 'competence.competence_id_seq']
    domaine column: 'domaine_id'
    referentiel column: 'referentiel_id'
    idExterneList cache: 'nonstrict-read-write'
    version false
    cache 'nonstrict-read-write'
  }

  static constraints = {
    nom blank: false
    description nullable: true
    domaine validator: { val, obj ->
      val.referentiel == obj.referentiel
    }
  }

  /**
   * Affiche en console une compétence
   * @param indent niveau du domaine parent dans le référentiel (0 pour un domaine racine)
   */
  void print(int indent) {
    (indent+3).times { print "=== "}
    println "Compéntence $nom"
  }


  @Override
  public String toString() {
    return "${domaine.toString()}/$nom"
  }
}
