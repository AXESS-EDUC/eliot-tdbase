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
public enum IntervalleEnum {
  S1(TypeIntervalleEnum.SEMESTRE, 1),
  S2(TypeIntervalleEnum.SEMESTRE, 2),
  T1(TypeIntervalleEnum.TRIMESTRE, 1),
  T2(TypeIntervalleEnum.TRIMESTRE, 2),
  T3(TypeIntervalleEnum.TRIMESTRE, 3),
  ANNEE(TypeIntervalleEnum.ANNEE, 4)

  private final TypeIntervalleEnum typeIntervalle
  private final Integer ordre

  private IntervalleEnum(TypeIntervalleEnum typeIntervalle, Integer ordre) {
    this.typeIntervalle = typeIntervalle
    this.ordre = ordre
  }

  public TypeIntervalleEnum getTypeIntevalle() {
    return this.typeIntervalle
  }

  public Integer getOrdre() {
    return this.ordre
  }

  /**
   * Interval est Trimestre ou Semestre
   * @return true/false
   * @author msan
   */
  public Boolean isXmestre() {
    return this.typeIntevalle.isXmestre()
  }

  /**
   * Retourne une intervalle "équivalent" :
   * T1 <=> S1, T2 <=> S2, T3 => null, ANNEE => null
   * @param intervalle
   * @return
   * @author bper
   */
  public IntervalleEnum getIntevalleEquivalent() {
    switch (this) {
      case (IntervalleEnum.T1): return IntervalleEnum.S1
      case (IntervalleEnum.T2): return IntervalleEnum.S2
      case (IntervalleEnum.T3): return null
      case (IntervalleEnum.S1): return IntervalleEnum.T1
      case (IntervalleEnum.S2): return IntervalleEnum.T2
      case (IntervalleEnum.ANNEE): return null
    }
  }

  String getId() {
    return this
  }


}