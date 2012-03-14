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
 * Classe permettant la gestion des permissions sur un item
 *
 * @author franck silvestre
 * @author JTRA
 */
public abstract class PermissionsManager {

  private Item item;
  private Autorite autorite;
  private AclSecuritySession session;

  /**
   * Construit un Permission Manager sur un item en contrôlant que la session
   * en cours dispose des droits pour modifier les permissions
   *
   * @param item
   * @param session
   * @throws AutorisationException
   */
  public PermissionsManager(Item item, Autorite autorite, AclSecuritySession session)
  throws AutorisationException {
    this.item = item;
    this.session = session;
    AccessManager accessManager = new AccessManager(item, session);
    if (!accessManager.peutModifierLesPermissions()) {
      throw AutorisationException.modificationPermissionsException();
    }
    this.autorite = autorite;
  }

  /**
   * Ajoute la permission de consulter l'item
   *
   */
  public abstract void addPermissionConsultation();

  /**
   * Ajoute la permission de modifier l'item
   *
   */
  public abstract void addPermissionModification();

  /**
   * Ajoute la permission de consulter les permissions sur l'item
   *
   */
  public abstract void addPermissionConsultationPermissions();

  /**
   * Ajoute la permission de modifier les permissions sur l'item
   */
  public abstract void addPermissionModificationPermissions();

  /**
   * Ajoute la permission de supprimer l'item
   */
  public abstract void addPermissionSuppression();

  /**
   * Supprime la permission de consulter l'item
   */
  public abstract void deletePermissionConsultation();

  /**
   * Supprime la permission de modifier l'item
   */
  public abstract void deletePermissionModification();

  /**
   * supprime la permission de consulter les permissions sur l'item
   */
  public abstract void deletePermissionConsultationPermissions();

  /**
   * Supprimela permission de modifier les permissions sur l'item
   */
  public abstract void deletePermissionModificationPermissions();

  /**
   * Ajoute la permission de supprimer l'item
   */
  public abstract void deletePermissionSuppression();

  /**
   * Getter pour l'item
   * @return l'item
   */
  public Item getItem() {
    return item;
  }

  /**
   * Getter pour l'autorité
   * @return l'autoritePers1
   */
  public Autorite getAutorite() {
    return autorite;
  }
}
