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

package org.lilie.services.eliot.tice.scolarite

/**
 * Classe représentant une structure d'enseignement
 * @author fsil
 * @author msan
 * @author bper
 */

public class StructureEnseignement {

  static transients = [
          'nomAffichage',
          'isClasse',
          'isGroupe'
  ]

  static final String TYPE_CLASSE = "CLASSE"
  static final String TYPE_GROUPE = "GROUPE"

  Long id
  AnneeScolaire anneeScolaire
  String idExterne
  String type
  Etablissement etablissement
  String code
  Niveau niveau

  /**
   * Numéro de version de l'import STS qui a engendré la création ou la
   * modification de cette structure d'enseignement
   * -1 si cette structure n'a pas été créée durant un import STS
   */
  int versionImportSts = -1

  /**
   * Indique si cette structure d'enseignement existe dans les données du
   * dernier import STS
   * Lorsqu'un structure d'enseignement existe en base, mais pas dans les données
   * d'un import STS, la propriété actif passe à false
   */
  boolean actif = true

  static hasMany = [
          groupes: StructureEnseignement,
          classes: StructureEnseignement,
          filieres: Filiere
  ]

  static constraints = {
    idExterne(nullable: false, maxSize: 128)
    type(nullable: false, inList: [TYPE_CLASSE, TYPE_GROUPE])
    etablissement(nullable: false)
    code(nullable: true)
    niveau(nullable: true)
  }

  static mapping = {
    table('ent.structure_enseignement')
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.structure_enseignement_id_seq']
    etablissement column: 'etablissement_id', fetch: 'join'
    anneeScolaire column: 'annee_scolaire_id', fetch: 'join'
    groupes joinTable: [name: 'ent.rel_classe_groupe', key: 'classe_id', column: 'groupe_id']
    classes joinTable: [name: 'ent.rel_classe_groupe', key: 'groupe_id', column: 'classe_id']
    filieres joinTable: [name: 'ent.rel_classe_filiere', key: 'classe_id', column: 'filiere_id']
    cache true
  }



  boolean equals(o) {
    if (this.is(o)) return true;

    if (getClass() != o.class) return false;

    StructureEnseignement that = (StructureEnseignement) o;

    if (anneeScolaire != that.anneeScolaire) return false;
    if (code != that.code) return false;
    if (etablissement != that.etablissement) return false;
    if (type != that.type) return false;

    return true;
  }

  int hashCode() {
    int result;

    result = (anneeScolaire != null ? anneeScolaire.hashCode() : 0);
    result = 31 * result + (type != null ? type.hashCode() : 0);
    result = 31 * result + (etablissement != null ? etablissement.hashCode() : 0);
    result = 31 * result + (code != null ? code.hashCode() : 0);
    return result;
  }

  /**
   * Nom utilisable pour l'affichage
   * @return nom utilisable pour l'affichage
   */
  String getNomAffichage() {
    String nomAffichage = null
    if (type == TYPE_CLASSE) {
      nomAffichage = code
    } else {
      // Si groupe avec une seul classe - Classe (Groupe)
      // Sinon Groupe
      if (classes?.size() == 1) {
        nomAffichage = classes.iterator().next().code + "(" + code + ")"
      } else {
        nomAffichage = code
      }
    }
    return nomAffichage
  }

  /**
   * True si la structure est une classe
   * @return
   */
  Boolean isClasse() {
    return type == TYPE_CLASSE
  }

  /**
   * True si la structure est un groupe
   * @return
   */
  Boolean isGroupe() {
    return type == TYPE_GROUPE
  }

  /**
   * True si la structure est un regroupement des classes
   * @return
   * @author bper
   */
  Boolean isRegroupement() {
    return (isGroupe() && this.classes?.size() > 1)
  }

  /**
   * True si la structure est un groupe local d'une classes (une partie de la classe)
   * @return
   * @author msan
   */
  Boolean isGroupeDedoublement() {
    return (isGroupe() && this.classes?.size() == 1)
  }


}