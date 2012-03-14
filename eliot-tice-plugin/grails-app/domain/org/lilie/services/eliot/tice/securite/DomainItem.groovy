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

import org.lilie.services.eliot.tice.securite.acl.Autorisation
import org.lilie.services.eliot.tice.securite.acl.Item
import org.lilie.services.eliot.tice.securite.acl.TypeAutorite

class DomainItem implements Item {

  String type

  Boolean estActive = false
  Long importId
  Date dateDesactivation
  String nomEntiteCible
  Long idEnregistrementCible

  //Supprimer un DomainItem supprimer aussi ses fils
  static belongsTo = [itemParent: DomainItem]
  static hasMany = [itemsFils: DomainItem, autorisations: DomainAutorisation]

  static mappedBy = [itemsFils: 'itemParent']

  static transients = ['identifiant', 'parentItem']

  /**
   * @return l'id de l'item sous forme de String
   */
  public String getIdentifiant() {
    return id as String;
  }

  /**
   * @return l'item parent de l'item courant
   */
  public Item getParentItem() {
    return itemParent
  }

  /**
   * Méthode retournant toutes les autorisations
   * @return la liste des toutes les autorisations
   */
  public List<Autorisation> findAllAutorisations() {
    if (itemParent) {
      return itemParent.findAllAutorisations()
    }
    return findAllAutorisationsPourType()
  }

  /**
   * Méthode retournant toutes les autorisations des groupes
   * @return la liste des autorisations
   */
  public List<Autorisation> findAllGroupePersonnesAutorisations() {
    if (itemParent) {
      return itemParent.findAllGroupePersonnesAutorisations()
    }
    return findAllAutorisationsPourType(TypeAutorite.GROUPE_PERSONNE.libelle)
  }

  /**
   * Méthode retournant toutes les autorisations des personnes
   * @return la liste des autorisations
   */
  public List<Autorisation> findAllPersonneAutorisations() {
    if (itemParent) {
      return itemParent.findAllPersonneAutorisations()
    }
    return findAllAutorisationsPourType(TypeAutorite.PERSONNE.libelle)
  }

  /**
   * Méthode retournant toutes les autorisations des personnes propriétaires
   * @return la liste des autorisations
   */
  public List<Autorisation> findAllPersonneProprietaireAutorisations() {
    if (itemParent) {
      return itemParent.findAllPersonneProprietaireAutorisations()
    }
    return DomainAutorisation.withCriteria {
      and {
        eq("item", this)
        eq("proprietaire", true)
        autorite {
          eq("type", TypeAutorite.PERSONNE.libelle)
        }
      }
    }
  }

  /*
  * Méthode retournant toutes les autorisations de'un type d'autoritée
  * @return la liste des autorisations
  */

  private List<Autorisation> findAllAutorisationsPourType(String autoriteType = null) {
    return DomainAutorisation.withCriteria {
      and {
        eq("item", this)
        if (autoriteType) {
          autorite {
            eq("type", autoriteType)
          }
        }
      }
    }
  }



  static constraints = {
    itemParent(nullable: true)
    importId(nullable: true)
    dateDesactivation(nullable: true)
    nomEntiteCible(nullable: true)
    idEnregistrementCible(nullable: true)
  }

  static mapping = {
    table('securite.item')
    id column: 'id', generator: 'sequence', params: [sequence: 'securite.item_id_seq']
    idEnregistrementCible column: 'enregistrement_cible_id'
  }
}
