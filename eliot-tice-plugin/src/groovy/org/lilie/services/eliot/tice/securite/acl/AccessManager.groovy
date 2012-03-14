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



package org.lilie.services.eliot.tice.securite.acl;

/**
 * Classe permettant la gestion des accès à un item à partir d'une session
 *
 * @author franck silvestre
 */
public class AccessManager {

  private Item item;
  private AclSecuritySession session;
  private Integer permissionsOnItem;
  private Boolean sessionEstProprietaireItem;
  private Boolean sessionEstTypeEliot;
  private List<Autorisation> autorisations;

  /**
   * Créer un access manager à partir d'un item et une session donnés
   *
   * @param item
   * @param session
   */
  public AccessManager(Item item, AclSecuritySession session) {
    this.item = item;
    this.session = session;
  }

  /**
   * Methode indiquant si la session est autorisée à consulter le contenu de l'item donné
   *
   * @return true si l'action est permise
   */
  public boolean peutConsulterLeContenu() {
    return verifiePermission(Permission.PEUT_CONSULTER_CONTENU);

  }

  /**
   * Methode indiquant si la session est autorisée à modifier le contenu de
   * l'item donné
   *
   * @return true si l'action est permise
   */
  public boolean peutModifierLeContenu() {
    return verifiePermission(Permission.PEUT_MODIFIER_CONTENU);
  }

  /**
   * Methode indiquant si la session est autorisée à consulter les permissions
   * sur l'item donné
   *
   * @return true si l'action est permise
   */
  public boolean peutConsulterLesPermissions() {
    return verifiePermission(Permission.PEUT_CONSULTER_PERMISSIONS);
  }

  /**
   * Methode indiquant si la session est autorisée à modifier les permissions
   * sur l'item donné
   *
   * @return true si l'action est permise
   */
  public boolean peutModifierLesPermissions() {
    return verifiePermission(Permission.PEUT_MODIFIER_PERMISSIONS);
  }

  /**
   * Methode indiquant si la session est autorisée à supprimer l'item donné
   *
   * @return true si l'action est permise
   */
  public boolean peutSupprimer() {
    return verifiePermission(Permission.PEUT_SUPPRIMER);
  }


  private List<Autorisation> getAutorisations() {
    if (autorisations == null) {
      autorisations = session.findAutorisationsOnItem(item);
    }
    return autorisations;
  }


  private int getPermissionsOnItem() {
    if (permissionsOnItem == null) {
      List<Autorisation> autorisations = getAutorisations();
      int permissions = 0;
      for (Autorisation autorisation: autorisations) {
        permissions = autorisation.getValeurPermissions() | permissions;
      }
      permissionsOnItem = permissions;
    }
    return permissionsOnItem;
  }

  public boolean sessionEstProprietaireItem() {
    if (sessionEstProprietaireItem == null) {
      List<Autorisation> autorisations = getAutorisations();
      sessionEstProprietaireItem = false;
      for (Autorisation autorisation: autorisations) {
        if (autorisation.autoriteEstProprietaire()) {
          sessionEstProprietaireItem = true;
          break;
        }
      }
    }
    return sessionEstProprietaireItem;
  }

  private boolean sessionEstTypeEliot() {
    if (sessionEstTypeEliot == null) {
      sessionEstTypeEliot = session.getDefaultAutorite().getType().equals(
              TypeAutorite.ELIOT.libelle
      );
    }
    return sessionEstTypeEliot;
  }


  private boolean verifiePermission(int permission) {
    if (sessionEstTypeEliot()) return true;
    if (sessionEstProprietaireItem()) return true;
    return (getPermissionsOnItem() | permission) == getPermissionsOnItem();
  }

}
