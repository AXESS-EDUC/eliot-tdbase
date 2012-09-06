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
  OrigineEnum origine = OrigineEnum.AUTO

  Set<Enseignement> enseignements
  Set<RelPeriodeService> relPeriodeServices
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

  static belongsTo = [
          Periode // identifiant du proprietaire dans la relation N:N
          // Service ne peut pas exister sans une période où il est enseigné
  ]

  static hasMany = [
          enseignements: Enseignement,
          relPeriodeServices: RelPeriodeService,
          sousServices: SousService
  ]

  static constraints = {
    structureEnseignement(nullable: false)
    matiere(nullable: false)
    modaliteCours(nullable: true) // modalité cours n'est plus exigée
    nbHeures(nullable: true)
    coEns(nullable: true)
    origine(nullable: true)
    servicePrincipal(nullable: false)
  }

  static transients = [
          'libelle',
          'anneeScolaire',
          'periodes',
          'evaluable',
          'coeffPourPeriode'
  ]

  String toString() {
    return "${id}"
  }

  static mapping = {
    table 'ent.service'
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.services_id_seq']
    structureEnseignement  fetch: 'join'
    matiere fetch: 'join'
    modaliteCours fetch: 'join'
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

  /**
   * Retourne la liste des périodes rattachée au service
   * @return List < Periode >
   * @author bper
   */
  List<Periode> getPeriodes() {
    return this.relPeriodeServices.collect {it.periode}
  }

  /**
   * Coeff du service pour une période données
   * @param periode
   * @return
   * @author msan
   */
  BigDecimal getCoeffPourPeriode(Periode periode) {
    RelPeriodeService rel = this.relPeriodeServices.find {it.periode.id == periode.id}
    return rel ? rel.coeff : RelPeriodeService.COEFF_PAR_DEFAUT
  }

  /**
   * Evaluabilité du service pour une période données
   * @param periode
   * @return true si le service est evaluable pour la période donnée, sinon false
   * @author msan
   */
  Boolean isEvaluable(Periode periode) {
    RelPeriodeService rel = this.relPeriodeServices.find {it.periode.id == periode.id}
    return rel ? rel.evaluable : RelPeriodeService.EVALUABILITE_PAR_DEFAUT
  }

  /**
   * Evaluabilité du service pour un type de période
   * @param typePeriode
   * @return true si le service est evaluable au moins pour une des périodes
   * du type donné, sinon false
   * @author bper
   */
  Boolean isEvaluable(TypePeriode typePeriode) {
    return !this.relPeriodeServices.isEmpty() ?
           this.relPeriodeServices.any {it.evaluable} :
           RelPeriodeService.EVALUABILITE_PAR_DEFAUT
  }

  /**
   * Service optionel
   * @param periode
   * @return true si le service est optionnel pour la période donnée, sinon false
   * @author bper
   */
  Boolean isOption(Periode periode) {
    RelPeriodeService rel = this.relPeriodeServices.find {it.periode.id == periode.id}
    return rel ? rel.option : RelPeriodeService.OPTION_PAR_DEFAUT
  }

  /**
   * Retourne les sous-services correspondant à un type de période
   * @param typePeriode
   * @return List < SousService >
   * @author bper
   */
  List<SousService> getSousServices(TypePeriode typePeriode) {
    return (this.sousServices.findAll {it.typePeriode.id == typePeriode.id} as List).sort {it.ordre}
  }

}


