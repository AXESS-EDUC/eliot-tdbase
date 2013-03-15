/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */



package org.lilie.services.eliot.tice.scolarite

import org.lilie.services.eliot.tice.annuaire.Personne
import org.springframework.transaction.annotation.Transactional

/**
 *
 * @author franck Silvestre
 */
public class ScolariteService {

  static transactional = false

  /**
   * Récupère les structures d'enseignement (classes / divisions)
   * @param etablissement l'établissement d'appartenance des structures
   * @return la liste des structures d'enseignements
   */
  List<StructureEnseignement> findStructuresEnseignement(Etablissement etablissement) {
    def structures = StructureEnseignement.findAllByEtablissementAndActif(etablissement,true)
    return structures
  }

  /**
   * Récupère les niveaux pour une structure d'enseignement
   * @param struct la structure d'enseignement
   * @return  la liste des niveaux
   */
  List <Niveau> findNiveauxForStructureEnseignement(StructureEnseignement struct) {
    def niveaux = []
    if (struct.isClasse()) {
      niveaux.add(struct.niveau)
    } else if (struct.isGroupe()) {
      niveaux = struct.classes*.niveau
    }
    niveaux
  }


}