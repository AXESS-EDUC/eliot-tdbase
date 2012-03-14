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

package org.lilie.services.eliot.tice.securite

import org.lilie.services.eliot.tice.securite.acl.TypeAutorite
import org.lilie.services.eliot.tice.securite.acl.Autorite


class DomainAutorite implements Autorite {

  public static final String ID_EXTERNE_DEFAULT_AUTORITE = "AUTORITE_PAR_DEFAUT"

  String type
  String identifiant
  String idSts

  Boolean estActive = false
  Long importId
  Date dateDesactivation
  String nomEntiteCible
  Long idEnregistrementCible

  static constraints = {
    type(inList: TypeAutorite.values().collect { it.libelle })
    idSts nullable: true
    dateDesactivation nullable: true
    importId nullable: true
    nomEntiteCible nullable: true
    idEnregistrementCible nullable: true
  }

  static mapping = {
    table('securite.autorite')
    cache usage: 'read-write'
    id column: 'id', generator: 'sequence', params: [sequence: 'securite.autorite_id_seq']
    idEnregistrementCible column: 'enregistrement_cible_id'
    identifiant column: 'id_externe'
  }

  /**
   * Méthode retournant les permissions de l'autorité sur l'item passé en paramètre
   */
  public int findPermissionsOnItem(DomainItem item) {
    return DomainAutorisation.findByAutoriteAndItem(this, item)?.valeurPermissions ?: 0;
  }

  /**
   * Retourne une chaine de caractère qui encode cette autorité
   * Le format d'encodage est : #type,#idExterne
   */
  public String encodeAsString() {
    return "T$type-ID$identifiant"
  }


  boolean equals(o) {
    if (this.is(o)) {
      return true;
    }

    if (!(o instanceof DomainAutorite)) {
      return false;
    }

    DomainAutorite autorite = (DomainAutorite) o;

    if (identifiant != autorite.identifiant) {
      return false;
    }
    if (type != autorite.type) {
      return false;
    }

    return true;
  }

  int hashCode() {
    int result;

    result = type.hashCode();
    result = 31 * result + identifiant.hashCode();
    return result;
  }


  public String toString() {
    return "DomainAutorite{" +
           "id='" + id + '\'' +
           ", type='" + type + '\'' +
           ", identifiant ='" + identifiant + '\'' +
           '}';
  }
}
