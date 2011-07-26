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



/**
 * @author franck silvestre
 */
package org.lilie.services.eliot.tice.scolarite


/**
 * Classe de service pour gestion les utilisateurs
 */
class FonctionService  {

  static transactional = false

  /**
   * Retourne la fonction à partir de son libelle
   * @param fonctionLibelleEnum  le libelle de fonction issue de l'enum
   * FonctionLibelle
   * @return la fonction
   */
  Fonction fonctionForFonctionLibelle(FonctionEnum fonctionLibelleEnum) {
    return Fonction.get(fonctionLibelleEnum.id)
  }

  /**
   *
   * @return la fonction correspondant à un enseignant
   */
  Fonction fonctionEnseignant() {
    return fonctionForFonctionLibelle(FonctionEnum.ENS)
  }

  /**
   *
   * @return la fonction correspondant à un élève
   */
  Fonction fonctionEleve() {
    return fonctionForFonctionLibelle(FonctionEnum.ELEVE)
  }

  /**
   *
   * @return la fonction correspondant à un responsable eleve
   */
  Fonction fonctionResponsableEleve() {
    return fonctionForFonctionLibelle(FonctionEnum.PERS_REL_ELEVE)
  }

  /**
   *
   * @return la fonction correspondant à un personnel de direction
   */
  Fonction fonctionDirection() {
    return fonctionForFonctionLibelle(FonctionEnum.DIR)
  }

  /**
   *
   * @return la fonction correspondant à un CPE
   */
  Fonction fonctionEducation() {
    return fonctionForFonctionLibelle(FonctionEnum.EDU)
  }

  /**
   *
   * @return la fonction correspondant à un CPE
   */
  Fonction fonctionDocumentation() {
    return fonctionForFonctionLibelle(FonctionEnum.DOC)
  }

  /**
   *
   * @return la fonction correspondant à un chef de travaux
   */
  Fonction fonctionChefTravaux() {
    return fonctionForFonctionLibelle(FonctionEnum.CTR)
  }

  /**
   *
   * @return la fonction correspondant à un administrateur local
   */
  Fonction fonctionAdministrateurLocal() {
    return fonctionForFonctionLibelle(FonctionEnum.AL)
  }

  /**
   *
   * @return la fonction correspondant à un administrateur central
   */
  Fonction fonctionAdministrateurCentral() {
    return fonctionForFonctionLibelle(FonctionEnum.AC)
  }

}

/**
 * Enumeration des fonctions
 * <ul>
 *  <li>AC - adminsitrateur central</li>
 *  <li>AL - adminsitrateur local</li>
 *  <li>CD - correspondant déploiement</li>
 *  <li>UI - invité</li>
 *  <li>ELEVE - élève</li>
 *  <li>PERS_REL_ELEVE - responsable élève</li>
 *  <li>ENS - enseignant</li>
 *  <li>DIR - direction</li>
 *  <li>EDU - CPE</li>
 *  <li>DOC - Documentation</li>
 *  <li>CFC - Conseiller Formation continue</li>
 *  <li>CTR - Chef de travaux</li>
 *  <li>ADF - Personnel administratif</li>
 *  <li>ALB - Laboratoire</li>
 *  <li>ASE - Assistant étranger</li>
 *  <li>LAB - Personnel de laboratoire</li>
 *  <li>MDS - Personnel medico-social</li>
 *  <li>OUV - Personnel ouviriers et de service</li>
 *  <li>SUR - Surveillance</li>
 * </ul>
 */
enum FonctionEnum {
  AC(1),
  AL(2),
  CD(3),
  UI(4),
  ELEVE(5),
  PERS_REL_ELEVE(6),
  ENS(7),
  DIR(8),
  EDU(9),
  DOC(10),
  CFC(11),
  CTR(12),
  ADF(13),
  ALB(14),
  ASE(15),
  LAB(16),
  MDS(17),
  OUV(18),
  SUR(19)
  //ORI(20),
  //AED(21),
  //AVS(22),
  //APP(23)


  private Long id

  private FonctionEnum(Long id) {
    this.id = id
  }

  public Long getId() {
    return id
  }

  public String toRole() {
    "ROLE_${this.toString()}"
  }

}
