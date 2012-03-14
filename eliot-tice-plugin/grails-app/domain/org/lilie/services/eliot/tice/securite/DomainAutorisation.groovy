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

import org.lilie.services.eliot.tice.securite.acl.Permission
import org.lilie.services.eliot.tice.securite.acl.Autorisation
import org.lilie.services.eliot.tice.securite.acl.Item
import org.lilie.services.eliot.tice.securite.acl.Autorite

class DomainAutorisation implements Autorisation {

  DomainItem item
  DomainAutorite autorite
  int valeurPermissionsExplicite
  Boolean proprietaire = Boolean.FALSE // DomainAutorite est propriétaire d'DomainItem
  DomainAutorisation autorisationHeritee

  static belongsTo = [DomainItem, DomainAutorite]

  static constraints = {
    // contrainte sur autorisation heritee
    autorisationHeritee nullable: true, validator: { autorHeritee, autorisation ->
      if (autorHeritee &&
          autorisation.proprietaire) {
        return false
      }
      return true
    }
    // contrainte sur valeurPermissionExplicite
    valeurPermissionsExplicite validator: { valeurPermission, autorisation ->
      if (valeurPermission > 0 &&
          autorisation.proprietaire) {
        return false
      }
      return true
    }
    // contrainte sur proprietaire
    proprietaire validator: { autorEstProprietaire, autorisation ->
      if (autorEstProprietaire &&
          (autorisation.valeurPermissionsExplicite > 0 ||
           autorisation.autorisationHeritee != null)) {
        return false
      }
      return true
    }

  }

  static mapping = {
    table('securite.autorisation')
    id column: 'id', generator: 'sequence', params: [sequence: 'securite.autorisation_id_seq']
  }

  static transients = ['valeurPermissions']

  /**
   * Méthode retournant l'autorité concernée par l'autorisation
   * @return l'autorité
   */
  Autorite autorite() {
    return autorite
  }

  /**
   * Méthode retournant l'item concernée par l'autorisation
   * @return l'item
   */
  Item item() {
    return item
  }

  /**
   * Méthode indiquant si l'autroité est propriétaire de l'item
   * @return true si l'autorité est propriétaire false sinon
   */
  boolean autoriteEstProprietaire() {
    return proprietaire
  }

  /**
   * Méthode retournant la valeur des permissions de l'autorité sur l'item :
   * valeur calculée à partir des permissions explicites et des permissions
   * héritées
   * @return la valeur des permissions
   */
  int getValeurPermissions() {
    int res = valeurPermissionsExplicite
    if (autorisationHeritee) {
      res = res | autorisationHeritee.valeurPermissions
    }
    return res
  }

  /**
   * Methode indiquant si l'autorisation permet de consulter le contenu
   *
   * @return true si l'action est permise
   */
  public boolean autoriseConsulterLeContenu() {
    if (autoriteEstProprietaire()) return true;
    return verifiePermission(
            Permission.PEUT_CONSULTER_CONTENU
    );

  }

  /**
   * Methode indiquant si l'autorisation permet de modifier le contenu
   *
   * @return true si l'action est permise
   */
  public boolean autoriseModifierLeContenu() {
    if (autoriteEstProprietaire()) return true;
    return verifiePermission(
            Permission.PEUT_MODIFIER_CONTENU
    );
  }

  /**
   * Methode indiquant si l'autorisation permet de consulter les permissions
   *
   * @return true si l'action est permise
   */
  public boolean autoriseConsulterLesPermissions() {
    if (autoriteEstProprietaire()) return true;
    return verifiePermission(
            Permission.PEUT_CONSULTER_PERMISSIONS
    );
  }

  /**
   * Methode indiquant si l'autorisation permet de modifier les permissions
   * sur l'item donné
   *
   * @return true si l'action est permise
   */
  public boolean autoriseModifierLesPermissions() {
    if (autoriteEstProprietaire()) return true;
    return verifiePermission(
            Permission.PEUT_MODIFIER_PERMISSIONS
    );
  }

  /**
   * Methode indiquant si si l'autorisation permet de supprimer
   *
   * @return true si l'action est permise
   */
  public boolean autoriseSupprimer() {
    if (autoriteEstProprietaire()) return true;
    return verifiePermission(
            Permission.PEUT_SUPPRIMER
    );
  }




  private boolean verifiePermission(int permission) {
    return (getValeurPermissions() | permission) == getValeurPermissions();
  }

}