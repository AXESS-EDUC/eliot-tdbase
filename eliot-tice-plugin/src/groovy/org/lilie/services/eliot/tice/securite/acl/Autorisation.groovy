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
 * Classe représentant une autorisation : lien entre une autoritePers1 un item et les permissions de l'un
 * sur l'autre
 * @author franck silvestre
 */
public interface Autorisation {

  /**
   * Méthode reptournant l'autorité
   * @return l'autorité
   */
  public Autorite autorite();

  /**
   * Méthode reptournant l'item
   * @return l'item
   */
  public Item item();

  /**
   * Méthode indiquant si l'autorité associée à l'autorisation est propriétaire
   * @return true si l'autorité est propriétaire
   */
  public boolean autoriteEstProprietaire();

  /**
   * Méthode reptournant la valeur des permissions
   * @return la valeur des permissions
   */
  public int getValeurPermissions();

  /**
   * Methode indiquant si l'autorisation permet de consulter le contenu
   *
   * @return true si l'action est permise
   */
  public boolean autoriseConsulterLeContenu();

  /**
   * Methode indiquant si l'autorisation permet de modifier le contenu
   *
   * @return true si l'action est permise
   */
  public boolean autoriseModifierLeContenu();

  /**
   * Methode indiquant si l'autorisation permet de consulter les permissions
   *
   * @return true si l'action est permise
   */
  public boolean autoriseConsulterLesPermissions();

  /**
   * Methode indiquant si l'autorisation permet de modifier les permissions
   * sur l'item donné
   *
   * @return true si l'action est permise
   */
  public boolean autoriseModifierLesPermissions();

  /**
   * Methode indiquant si si l'autorisation permet de supprimer
   *
   * @return true si l'action est permise
   */
  public boolean autoriseSupprimer();

}
