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
  Fonction fonctionForFonctionLibelle(FonctionLibelleEnum fonctionLibelleEnum) {
    return Fonction.get(fonctionLibelleEnum.id)
  }

  /**
   *
   * @return la fonction correspondant à un enseignant
   */
  Fonction fonctionEnseignant() {
    return fonctionForFonctionLibelle(FonctionLibelleEnum.ENSEIGNANT)
  }

  /**
   *
   * @return la fonction correspondant à un élève
   */
  Fonction fonctionEleve() {
    return fonctionForFonctionLibelle(FonctionLibelleEnum.ELEVE)
  }

  /**
   *
   * @return la fonction correspondant à un responsable eleve
   */
  Fonction fonctionResponsableEleve() {
    return fonctionForFonctionLibelle(FonctionLibelleEnum.PERS_REL_ELEVE)
  }

  /**
   *
   * @return la fonction correspondant à un personnel de direction
   */
  Fonction fonctionDirection() {
    return fonctionForFonctionLibelle(FonctionLibelleEnum.DIRECTION)
  }

  /**
   *
   * @return la fonction correspondant à un CPE
   */
  Fonction fonctionEducation() {
    return fonctionForFonctionLibelle(FonctionLibelleEnum.EDUCATION)
  }

  /**
   *
   * @return la fonction correspondant à un CPE
   */
  Fonction fonctionDocumentation() {
    return fonctionForFonctionLibelle(FonctionLibelleEnum.DOCUMENTATION)
  }

  /**
   *
   * @return la fonction correspondant à un chef de travaux
   */
  Fonction fonctionChefTravaux() {
    return fonctionForFonctionLibelle(FonctionLibelleEnum.CHEF_TRAVAUX)
  }

  /**
   *
   * @return la fonction correspondant à un administrateur local
   */
  Fonction fonctionAdministrateurLocal() {
    return fonctionForFonctionLibelle(FonctionLibelleEnum.ADMINISTRATEUR_LOCAL)
  }

  /**
   *
   * @return la fonction correspondant à un administrateur central
   */
  Fonction fonctionAdministrateurCentral() {
    return fonctionForFonctionLibelle(FonctionLibelleEnum.ADMINISTRATEUR_CENTRAL)
  }

}

enum FonctionLibelleEnum {
  ADMINISTRATEUR_CENTRAL(1),
  ADMINISTRATEUR_LOCAL(2),
  CORRESPONDANT_DEPLOIEMENT(3),
  INVITE(4),
  ELEVE(5),
  PERS_REL_ELEVE(6),
  ENSEIGNANT(7),
  DIRECTION(8),
  EDUCATION(9),
  DOCUMENTATION(10),
  CONSEILLER_FORMATION_CONTINUE(11),
  CHEF_TRAVAUX(12),
  PERSONNEL_ADMINISTRATIF(13),
  LABORATOIRE(14),
  ASSISTANT_ETRANGER(15),
  PERSONNEL_LABORATOIRE(16),
  PERSONNEL_MEDICO_SOCIAL(17),
  PERSONNEL_OUVRIER_SERVIVE(18),
  SURVEILLANCE(19),
  ORIENTATION(20),
  ASSISTANT_EDUCATION(21),
  AUXILIAIRE_VIE_SCOLAIRE(22),
  APPRENTISSAGE(23)


  private Long id

  private FonctionLibelleEnum(Long id) {
    this.id = id
  }

  public Long getId() {
    return id
  }

}
