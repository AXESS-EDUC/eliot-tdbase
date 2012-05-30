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

package org.lilie.services.eliot.tice.textes

import org.lilie.services.eliot.tice.securite.DomainAutorite

/**
 * The Dossier entity.
 *
 * @author
 *
 *
 */
class Dossier {

  public static final String NOM_DOSSIER_PAR_DEFAUT = "Mes cahiers"
  public static final Long ID_DOSSIER_PAR_DEFAUT = -666

  public static final String NOM_DOSSIER_PARTAGE = "Cahiers partagés"
  public static final Long ID_DOSSIER_PARTAGE = -333

  public static final String NOM_DOSSIER_ARCHIVES_PARENT = "Archives"
  public static final Long ID_DOSSIER_ARCHIVES_PARENT = -2000
  // on part de premise que les IDs <= -2000 sont les IDs des dossiers d'archivage

  Long id
  String nom
  String description
  Boolean estDefaut
  Long ordre
  // Relation
  DomainAutorite proprietaire

  static belongsTo = [proprietaire: DomainAutorite]

  static hasMany = [relDossierAutorisationCahiers: RelDossierAutorisationCahier]

  static transients = [
          'estDossierArchive',
          'estDossierArchiveParent',
          'estDossierPartage',
          'estDossierParDefaut',
          'idDossierArchive',
          'idDossierArchiveParent'
  ]

  static constraints = {
    id(max: 9999999999L)
    version(max: 9999999999L)
    nom(size: 1..255, blank: false)
    description(nullable: true)
    estDefaut()
    ordre(nullable: true, max: 9999999999L)
  }

  static mapping = {
    table 'entcdt.dossier'
    id column: 'id', generator: 'sequence', params: [sequence: 'entcdt.dossier_id_seq']
    proprietaire column: 'acteur_id'
    version false
  }

  String toString() {
    return "${id}"
  }

  boolean estDossierParDefaut() {
    return id == ID_DOSSIER_PAR_DEFAUT && nom == NOM_DOSSIER_PAR_DEFAUT
  }

  boolean estDossierPartage() {
    return id == ID_DOSSIER_PARTAGE && nom == NOM_DOSSIER_PARTAGE
  }

  boolean estDossierArchiveParent() {
    return id == ID_DOSSIER_ARCHIVES_PARENT && nom == NOM_DOSSIER_ARCHIVES_PARENT
  }

  boolean estDossierArchive() {
    return (estIdDossierArchive(this.id))
  }

  static Boolean estIdDossierArchive(Long intId) {
    return intId <= ID_DOSSIER_ARCHIVES_PARENT
  }

  /**
   * Id de dossier Archives parent
   * @param annee
   * @return
   */
  static Long getIdDossierArchiveParent(Integer annee) {
    return ID_DOSSIER_ARCHIVES_PARENT
  }

  /**
   * 2010-2011 -> -2010, 2011-2012 -> -2011 ...
   * @param annee
   * @return
   */
  static Long getIdDossierArchive(Integer annee) {
    return (ID_DOSSIER_ARCHIVES_PARENT + (2000 - annee))
  }


  boolean equals(o) {
    if (this.is(o)) {
      return true;
    }
    if (!(o instanceof Dossier)) {
      return false;
    }
    Dossier dossier = (Dossier) o;
    if (description ? !description.equals(dossier.description) : dossier.description != null) {
      return false;
    }
    if (!estDefaut.equals(dossier.estDefaut)) {
      return false;
    }
    if (!id.equals(dossier.id)) {
      return false;
    }
    if (!nom.equals(dossier.nom)) {
      return false;
    }
    if (ordre ? !ordre.equals(dossier.ordre) : dossier.ordre != null) {
      return false;
    }
    if (proprietaire ? !proprietaire.equals(dossier.proprietaire) : dossier.proprietaire != null) {
      return false;
    }
    return true;
  }

  int hashCode() {
    int result;
    result = id.hashCode();
    result = 31 * result + nom.hashCode();
    result = 31 * result + (description ? description.hashCode() : 0);
    result = 31 * result + estDefaut.hashCode();
    result = 31 * result + (ordre ? ordre.hashCode() : 0);
    result = 31 * result + (proprietaire ? proprietaire.hashCode() : 0);
    return result;
  }

}
