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
 * @author bper
 */
class TypePeriode {

  Integer id
  Etablissement etablissement

  String libelle
  IntervalleEnum intervalle
  NaturePeriodeEnum nature

  static transients = [
          'isAnnee',
          'isNotation',
          'ordre',
          'typeIntervalle'
  ]

  static constraints = {
    etablissement nullable: true, validator: etablissementValidator
    libelle(maxSize: 50, nullable: true)
    nature nullable: false
    intervalle nullable: true, validator: intervalleValidator
  }

  /**
   * Validation de l'intervalle :
   * 1. L'intervalle ne doit pas etre null si c'est une période de notation
   * 2. L'intervalle doit etre null si c'est une autre période
   */
  static intervalleValidator = {val, obj ->
    if (obj.nature == NaturePeriodeEnum.NOTATION) {
      return (val != null)
    } else {
      return (val == null)
    }
  }

  /**
   * Les périodes de notation sont communes à tous les établissements => etablissement == null
   * D'autres périodes sont propres à chaque établissements => etablissement != null
   */
  static etablissementValidator = {val, obj ->
    if (obj.nature == NaturePeriodeEnum.NOTATION) {
      return (val == null)
    } else {
      return (val != null)
    }
  }

  static mapping = {
    table('ent.type_periode')
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.type_periode_id_seq']
    libelle column: 'libelle'
    nature column: 'nature'
    intervalle column: 'intervalle' //unique dans la BDD
    etablissement column: 'etablissement_id'
    version true
  }

  Boolean isAnnee() {
    return (this.intervalle == IntervalleEnum.ANNEE)
  }

  Boolean isNotation() {
    return (this.nature == NaturePeriodeEnum.NOTATION)
  }

  Boolean isExamen() {
    return (this.nature == NaturePeriodeEnum.EXAMEN)
  }

  /**
   * TypePeriode est Trimestre ou Semestre
   * @return true/false
   * @author msan
   */
  Boolean isXmestre() {
    if (this.intervalle != null) {
      return (this.intervalle.isXmestre())
    } else {
      return false
    }
  }

  Integer getOrdre() {
    return (this.intervalle != null) ? this.intervalle.getOrdre() : null
  }

  String getLibelle() {
    return (this.intervalle != null) ? this.intervalle.toString() : this.libelle
  }

  TypeIntervalleEnum getTypeIntervalle() {
    return (this.intervalle != null) ? this.intervalle.getTypeIntevalle() : null
  }

  public String toString() {
    return this.libelle
  }

}
