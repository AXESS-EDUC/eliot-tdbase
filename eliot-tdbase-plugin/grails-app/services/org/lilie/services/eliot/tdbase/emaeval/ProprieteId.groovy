/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 *  This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *   <http://www.gnu.org/licenses/> and
 *   <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tdbase.emaeval

/**
 * Identifie chaque propriété de la liaison TD Base / EmaEval
 *
 * Note d'implémentation :
 * Chaque propriété est associée à l'identifiant (long) utilisé en base, ce qui permet
 * d'utiliser le cache de niveau 2 d'Hibernate.
 *
 *
 * @author John Tranier
 */
public enum ProprieteId {
  REFERENTIEL_STATUT(1), // valeur : "OK" indique que le référentiel est correctement initialisé
  PLAN_TDBASE_ID(2), // valeur : contient l'id emaeval du plan s'il est correctement initialisé
  SCENARIO_EVALUATION_DIRECTE_ID(3), // valeur : contient l'id emaeval du scenario s'il est correctement initialisé
  METHODE_EVALUATION_BOOLEENNE_ID(4) // valeur : contient l'id emaeval de la méthode d'évaluation si elle est correctement initialisée

  // id en base dans la table emaeval_interface.propriete de cette propriété
  private final long dbId

  private ProprieteId(long dbId) {
    this.dbId = dbId
  }
  /**
   * @return id en base dans la table emaeval_interface.propriete de cette propriété
   */
  long getDbId() {
    return dbId
  }

  /**
   * Utilisé par GORM pour assurer le mapping avec cette énumération
   * dans les classes du domaines
   * @return
   */
  String getId() {
    return this
  }
}