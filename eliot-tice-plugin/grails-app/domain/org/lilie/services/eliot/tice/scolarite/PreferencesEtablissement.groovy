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

/**
 * Préférences pour un établissement : données communes
 * Modules impliqués : Notes (agrège les Distinctions )
 *
 * @author bcro
 *
 */

class PreferencesEtablissement {

  Etablissement etablissement
  AnneeScolaire anneeScolaire

  int nbAnneesConservationArchivesBulletins = 3
  int nbAnneesConservationArchivesCdt = 2

  // infos de publipostage
  String nomEtablissement
  String adresse1Etablissement
  String adresse2Etablissement
  String codePostalEtablissement
  String villeEtablissement
  // blob de la signature
  byte[] logoEtablissement

  //static hasMany = [distinctions: Distinction]

  static constraints = {
    nomEtablissement(nullable: true)
    adresse1Etablissement(nullable: true)
    adresse2Etablissement(nullable: true)
    codePostalEtablissement(nullable: true)
    villeEtablissement(nullable: true)
    logoEtablissement(nullable: true)
  }

  static mapping = {

    table('ent.preferences_etablissement')

    id column: 'id',
       generator: 'sequence',
       params: [sequence: 'ent.preferences_etablissement_id_seq']

    etablissement column: 'etablissement_id'
    nbAnneesConservationArchivesBulletins column: 'nb_annees_conservation_archives_bulletins'
    nbAnneesConservationArchivesCdt column: 'nb_annees_conservation_archives_cdt'
    nomEtablissement column: 'nom_etablissement'
    adresse1Etablissement column: 'adresse_1_etablissement'
    adresse2Etablissement column: 'adresse_2_etablissement'
    codePostalEtablissement column: 'code_postal_etablissement'
    villeEtablissement column: 'ville_etablissement'
    logoEtablissement column: 'logo_etablissement'
  }
}
