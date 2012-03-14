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

class AnneeScolaire {

  String code
  Boolean anneeEnCours

  static constraints = {
    code(maxSize: 30, unique: true)
    anneeEnCours(nullable: true)
  }

  static mapping = {
    table('ent.annee_scolaire')
    cache usage: 'read-write'
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.annee_scolaire_id_seq']
  }

  /**
   * Méthode utilitaire
   * Retourne l'année de début de cette année scolaire
   * (ex : 2009 pour l'année scolaire 2009-2010)
   * Important : cette méthode suppose que le code de l'année scolaire est sous
   * la forme 2009-2010
   */
  public String extraitAnneeDebut() {
    return code.split('-')[0]
  }

  /**
   * Méthode utilitaire
   * Retourne l'année de fin de cette année scolaire
   * (ex : 2010 pour l'année scolaire 2009-2010)
   * Important : cette méthode suppose que le code de l'année scolaire est sous
   * la forme 2009-2010
   */
  public String extraitAnneeFin() {
    return code.split('-')[1]
  }

  /**
   * Méthode utilitaire
   * Retourne l'année de début de cette année scolaire
   * (ex : 2009 pour l'année scolaire 2009-2010)
   * Important : cette méthode suppose que le code de l'année scolaire est sous
   * la forme 2009-2010
   */
  public Integer extraitAnneeDebutInteger() {
    String debut = code.split('-')[0]
    return debut ? Integer.parseInt(debut) : null
  }

  /**
   * Méthode utilitaire
   * Retourne l'année de fin de cette année scolaire
   * (ex : 2010 pour l'année scolaire 2009-2010)
   * Important : cette méthode suppose que le code de l'année scolaire est sous
   * la forme 2009-2010
   */
  public Integer extraitAnneeFinInteger() {
    String fin = code.split('-')[1]
    return fin ? Integer.parseInt(fin) : null
  }
}
