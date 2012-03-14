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

package org.lilie.services.eliot.tice.textes;


import org.lilie.services.eliot.tice.scolarite.Service
import org.lilie.services.eliot.tice.securite.DomainItem
import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.securite.DomainAutorisation
import org.lilie.services.eliot.tice.scolarite.AnneeScolaire

/**
 * The CahierDeTextes entity.
 *
 * @author atua
 * @author fsil
 * @author msan
 */
class CahierDeTextes {


  static mapping = {
    table 'entcdt.cahier_de_textes'
    id column: 'id', generator: 'sequence', params: [sequence: 'entcdt.cahier_de_textes_id_seq']
    item column: 'id_item', fetch: 'join'
    service column: 'id_service', fetch: 'join'
    fichier column: 'id_fichier'
    anneeScolaire column: 'annee_scolaire_id', fetch: 'join'
    parentIncorporation column: 'id_parent_incorporation'
    version false
    cache true
  }

  Long id
  Fichier fichier    //tmp
  Service service
  String nom
  String description
  Boolean estVise = Boolean.FALSE // par défaut
  Date dateCreation = new Date()
  DomainItem item
  AnneeScolaire anneeScolaire
  Boolean droitsIncomplets = Boolean.FALSE
  CahierDeTextes parentIncorporation = null

  static hasMany = [
          relCahierActeurs: RelCahierActeur,
          relCahierGroupes: RelCahierGroupe,
          activites: Activite,
          cahiersIncorpores: CahierDeTextes
  ]

  static constraints = {
    id(max: 9999999999L)
    version(max: 9999999999L)
    //idFichier(nullable: true, max: 9999999999L)
    fichier(nullable: true)   //tmp
    nom(size: 1..255, blank: false)
    service(nullable: true)
    estVise(nullable: true)
    anneeScolaire(nullable: true)
    parentIncorporation(nullable: true)
  }

  String toString() {
    return "${id}"
  }

  //FichierService fichierService //tmp

  static transients = [
          'proprietaire',
          'dossierParent',
          'fichierService'
  ]

  /**
   * Retourne le nom personnalisé du cahier.
   * @param acteur
   */
  String nomAffichage(DomainAutorite acteur) {
    return nomAffichage(acteur, true)
  }

  /**
   * Renvoie le nom personnalisé du cahier de textes s'il existe, sinon le nom
   * original du cahier.
   * @param cdt le cahier de textes
   * @param acteur l'acteur dont on veut récupérer le nom personnalisé
   */
  String nomAffichage(DomainAutorite acteur, boolean detail) {
    // Si l'instance n'est pas enregistrée en base (cas d'un visa par exemple)
    if (this.id == null) {
      return nom
    }

    RelCahierActeur rel = RelCahierActeur.findByCahierDeTextesAndActeur(
            this,
            acteur,
            [cache: true]
    )

    String alias = rel?.aliasNom
    if (alias) {
      return detail ? alias + " (" + nom + ")" : alias
    } else {
      return nom
    }
  }

  private DomainAutorite proprietaire

  /**
   * Cherche le proprietaire de ce cahier
   * Le fait de proprieté est exprimé par le presentce d'autorisation avec proprietaire=true
   */
  DomainAutorite getProprietaire() {
    if (proprietaire == null) {
      DomainAutorisation autorisation
      if (this?.item) {
        autorisation = DomainAutorisation.findByItemAndProprietaire(this.item, true)
      }
      proprietaire = autorisation?.autorite
    }
    return proprietaire
  }

  /**
   * Cherche dossier parent pour un utilisateur.
   * Null si cahier n'as pas un dossier parent.
   */
  Dossier getDossierParent(DomainAutorite autorite) {
    Dossier dossier = null

    if (this && this.item && autorite) {
      DomainAutorisation autorisation = DomainAutorisation.findByItemAndAutorite(this.item, autorite)
      if (autorisation) {
        RelDossierAutorisationCahier rel = RelDossierAutorisationCahier.findByAutorisation(autorisation)
        if (rel) {
          dossier = rel.dossier
        }
      }
    }
    return dossier
  }

  boolean estPrive() {
    return service == null
  }

  /**
   * @return <code>true</code> si le cdt est vide, <code>false</code> sinon.
   */
  boolean estVide() {
    def critActivites = Activite.createCriteria()
    def listeActivites = critActivites.list {
      eq("cahierDeTextes", this)
    }
    if (listeActivites.size() > 0) {
      return false
    }
    def critChapitres = Chapitre.createCriteria()
    def listeChapitres = critChapitres.list {
      eq("cahierDeTextes", this)
    }
    return (listeChapitres.size() == 0)
  }


  boolean equals(o) {
    if (this.is(o)) {
      return true;
    }

    if (getClass() != o.class) {
      return false;
    }

    CahierDeTextes that = (CahierDeTextes) o;

    if (id != that.id) {
      return false;
    }

    return true;
  }

  int hashCode() {
    return (id != null ? id.hashCode() : 0);
  }
}
