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
 * Relation Service - Période
 * @author bper
 * @author msan
 */
class RelPeriodeService {

  static Boolean EVALUABILITE_PAR_DEFAUT = Boolean.FALSE
  static Boolean OPTION_PAR_DEFAUT = Boolean.FALSE
  static BigDecimal COEFF_PAR_DEFAUT = 1

  Long id
  Periode periode
  Service service
  BigDecimal coeff = COEFF_PAR_DEFAUT // par défaut le coeff est 1
  Boolean option = OPTION_PAR_DEFAUT // par défaut l'option est false
  Integer ordre
  Boolean evaluable = EVALUABILITE_PAR_DEFAUT // par défaut service n'est pas évaluable

  static belongsTo = [periode: Periode, service: Service]

  static constraints = {
    service nullable: false, validator: {it.servicePrincipal} // Le relation peut etre créée uniquement pour un service principal
    periode nullable: false
    coeff nullable: true
    option nullable: false
    ordre nullable: true
    evaluable nullable: false
  }

  static mapping = {
    table 'ent.rel_periode_service'
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.rel_periode_service_id_seq']
    version true
    service column: 'service_id', fetch: 'join'
    periode column: 'periode_id', fetch: 'join'
    coeff column: 'coeff'
    option column: 'option'
    ordre column: 'ordre'
    evaluable column: 'evaluable'
  }

  public String toString() {
    return "Service: $service Periode: $periode ordre: $ordre"
  }

}
