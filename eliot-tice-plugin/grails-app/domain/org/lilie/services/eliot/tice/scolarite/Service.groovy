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
 * Représente un service de scolarité
 * Un service de scolarité est caractisé de manière unique par :
 *   - l'année scolaire
 *   - la structure d'enseignement
 *   - la matière
 *   - la modalité cours
 * @author jduf
 * @author fsil
 * @author jtra
 * @author bper
 * @author msan
 */

public class Service {

  Long id
  StructureEnseignement structureEnseignement

  Matiere matiere
  ModaliteCours modaliteCours

  Double nbHeures
  Boolean coEns
  String libelleMatiere


  Set<Enseignement> enseignements
  Set<SousService> sousServices

  /*
   * Les services ayant les memes valeurs pour structureEnseignement, matiere et origine
   * sont considerés comme identique dans le module Notes. Un des ces service est donc
   * marqué comme principal pour etre utilisé dans Notes.
   */
  Boolean servicePrincipal = false

  /*
   * Numéro de version de l'import STS qui a engendré la création ou la
   * modification de ce service de scolarité
   * -1 si ce service de scolarité n'a pas été créée durant un import STS
   */
  int versionImportSts = -1

  /*
   * Indique si ce service de scolarité existe dans les données du
   * dernier import STS
   * Lorsqu'un service de scolarité existe en base, mais pas dans les données
   * d'un import STS, la propriété actif passe à false
   */
  boolean actif = true



  static hasMany = [
          enseignements: Enseignement,
          sousServices: SousService
  ]

  static constraints = {
    structureEnseignement(nullable: false)
    matiere(nullable: false)
    modaliteCours(nullable: true) // modalité cours n'est plus exigée
    nbHeures(nullable: true)
    coEns(nullable: true)
    libelleMatiere(nullable: true)
    servicePrincipal(nullable: false)
  }

  static transients = [
          'libelle',
          'anneeScolaire'
  ]

  String toString() {
    return "${id}"
  }

  static mapping = {
    table 'ent.service'
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.services_id_seq']
    structureEnseignement column: 'id_structure_enseignement', fetch: 'join'
    matiere column: 'id_matiere', fetch: 'join'
    modaliteCours column: 'id_modalite_cours', fetch: 'join'
    cache true
  }

  /**
   * Libellé de service/nseignement pour l'affichage
   * @return
   */
  String getLibelle() {
    return "${structureEnseignement.nomAffichage}-${matiere.codeGestion}"
  }

  /**
   * Année scolaire du service 
   * @return AnneeScolaire
   * @author bper
   */
  AnneeScolaire getAnneeScolaire() {
    return this.structureEnseignement?.anneeScolaire
  }


}
