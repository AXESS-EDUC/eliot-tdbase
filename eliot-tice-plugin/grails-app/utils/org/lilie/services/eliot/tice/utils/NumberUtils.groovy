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

package org.lilie.services.eliot.tice.utils

import java.text.DecimalFormat

/**
 *
 * @author franck Silvestre
 */
class NumberUtils {

  private static DecimalFormat defaultDecimalFormat

  /**
   * Formate un Float à la forme de la locale courante
   * @param nb le nombre à formater
   * @return la chaîne de caractère correspondant au format
   */
  static String formatFloat(Float nb) {
    if (nb == null) {
      return ''
    }
    if (defaultDecimalFormat == null) {
      synchronized (NumberUtils.class) {
        if (defaultDecimalFormat == null) {
          defaultDecimalFormat = new DecimalFormat("##0.00")
        }
      }
    }
    defaultDecimalFormat.format(nb)
  }

  /**
   * Verifie l'egalite de deux nombres f1 et f2 à la precision prêt :
   * f2 = f1 +|- precision
   * @param f1 le premier nombre
   * @param f2 le second nombre auquel on compare le premier nombre
   * @param precision la précision
   * @return true en cas d'egalite
   */
  static boolean egaliteAvecPrecision(Float f1, Float f2, Float precision) {
    if (f1 == null || f2 == null) {
      throw new IllegalArgumentException("Un des deux nombres est null")
    }
    // l'ajout ou la soustraction de 0.000001 est pour detourner le pb
    // du calcul sur nombre flottant en Java
    def valMin = f1 - precision - 0.000001
    def valMax = f1 + precision + 0.000001
    if (f2 <= valMax &&
        f2 >= valMin) {
      return true
    }
    false
  }
}
