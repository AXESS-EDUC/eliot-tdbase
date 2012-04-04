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

package org.lilie.services.eliot.tice.annuaire

import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.Regime

/**
 * @author jbui
 */

public class Personne {


  static final String NOM_TABLE = 'ent.personne'

  DomainAutorite autorite
  String nom
  String prenom
  Civilite civilite
  String telephonePro
  String telephonePerso
  String telephonePortable
  String fax
  String adresse
  String codePostal
  String ville
  String pays
  Date dateNaissance
  String sexe
  String photo
  Etablissement etablissementRattachement
  String email
  String nomNormalise // Nom en majuscule sans accent
  String prenomNormalise // Prénom en majuscule sans accent
  Regime regime

  static mapping = {
    table(Personne.NOM_TABLE)
    cache usage: 'read-write'
    version false
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.personne_id_seq']
    autorite fetch: 'join'
  }

  static transients = ['nomAffichage']

  static constraints = {
    civilite(nullable: true)
    telephonePro(nullable: true)
    telephonePerso(nullable: true)
    telephonePortable(nullable: true)
    fax(nullable: true)
    adresse(nullable: true)
    codePostal(nullable: true)
    ville(nullable: true)
    pays(nullable: true)
    dateNaissance(nullable: true)
    sexe(nullable: true)
    photo(nullable: true)
    //autorite nullable: false //,unique: true géré en base
    etablissementRattachement(nullable: true)
    email(nullable: true)
    nomNormalise(nullable: true)
    prenomNormalise(nullable: true)
    regime(nullable: true)
  }

  /**
   *
   * @return le nom d'affichage
   */
  String getNomAffichage() {
    "$nom $prenom"
  }

}