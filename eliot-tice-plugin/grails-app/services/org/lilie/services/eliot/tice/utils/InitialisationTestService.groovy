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



package org.lilie.services.eliot.tice.utils

import org.lilie.services.eliot.tice.annuaire.UtilisateurService
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.scolarite.ProprietesScolarite
import org.lilie.services.eliot.tice.scolarite.FonctionService
import org.lilie.services.eliot.tice.annuaire.Personne

class InitialisationTestService {


  private static final String ENSEIGNANT_1_LOGIN = "mary.dupond"
  private static final String ENSEIGNANT_1_PASSWORD = "password"
  private static final String ENSEIGNANT_1_NOM = "dupond"
  private static final String ENSEIGNANT_1_PRENOM = "mary"

  private static final String ENSEIGNANT_2_LOGIN = "paul.durand"
  private static final String ENSEIGNANT_2_PASSWORD = "password"
  private static final String ENSEIGNANT_2_NOM = "durand"
  private static final String ENSEIGNANT_2_PRENOM = "paul"

  UtilisateurService utilisateurService
  FonctionService fonctionService
  BootstrapService bootstrapService

  /**
   *
   * @return  l'utilisateur  correspondant à l'utilisateur 1 (sans profils de
   * scolarite)
   */
  Utilisateur getUtilisateur1() {
    utilisateurService.createUtilisateur(
            ENSEIGNANT_1_LOGIN,
            ENSEIGNANT_1_PASSWORD,
            ENSEIGNANT_1_NOM,
            ENSEIGNANT_1_PRENOM,
            null,
            new Date().parse("d/M/yyyy", "21/3/1972")
    )
  }

  /**
   *
   * @return  l'utilisateur  correspondant à l'utilisateur 2 (sans profils de
   * scolarite)
   */
  Utilisateur getUtilisateur2() {
    utilisateurService.createUtilisateur(
            ENSEIGNANT_2_LOGIN,
            ENSEIGNANT_2_PASSWORD,
            ENSEIGNANT_2_NOM,
            ENSEIGNANT_2_PRENOM,
            null,
            new Date().parse("d/M/yyyy", "19/5/1980")
    )
  }


  /**
   *
   * @return l'utilisateur 1 avec les proprietes de scolarite correspondant
   * à l'enseignant 1
   */
  Utilisateur getEnseignant1() {
    Utilisateur ens1 = getUtilisateur1()
    bootstrapService.bootstrapForIntegrationTest()
    def props = ProprietesScolarite.findAllByFonction(fonctionService.fonctionEnseignant())
    bootstrapService.addProprietesScolariteToPersonne(props,Personne.get(ens1.personneId))
    return  ens1
  }


}
