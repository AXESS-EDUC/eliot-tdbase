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
/**
 *
 * @author franck Silvestre
 */
public class ScolariteService {

  static transactional = false

  /**
   * Récupère les niveaux pour une structure d'enseignement
   * @param struct la structure d'enseignement
   * @return la liste des niveaux
   */
  List<Niveau> findNiveauxForStructureEnseignement(StructureEnseignement struct) {
    def niveaux = []
    if (struct.isClasse()) {
      niveaux.add(struct.niveau)
    } else if (struct.isGroupe()) {
      niveaux = struct.classes*.niveau
    }
    niveaux
  }



  /**
   * Recherche de structures d'enseignements de l'année en cours
   * @param etablissement l'établissement
   * @param patternCode le pattern de code
   * @param niveau le niveau general
   * @param paginationAndSortingSpec les specifications pour l'ordre et
   * la pagination
   * @param uniquementQuestionsChercheur flag indiquant si on recherche que
   * les items du chercheur
   * @return la liste des questions
   */
  List<StructureEnseignement> findStructuresEnseignement(Collection<Etablissement> etablissements,
                                                         String patternCode = null,
                                                         Niveau niveau = null,
                                                         Integer limiteResults = 200,
                                                         Map paginationAndSortingSpec = [:]) {

    AnneeScolaire anneeScolaire = AnneeScolaire.findByAnneeEnCours(true, [cache: true])
    if (!anneeScolaire) {
      throw new IllegalArgumentException("structures.recherche.anneescolaire.null")
    }
    if (!etablissements) {
      throw new IllegalArgumentException("structures.recherche.etablissements.vide")
    }

    def criteria = StructureEnseignement.createCriteria()
    List<StructureEnseignement> structures = criteria.list(paginationAndSortingSpec) {
      eq "anneeScolaire", anneeScolaire
      eq "actif", true
      or {
        etablissements.each {
          eq "etablissement", it
        }
      }
      if (patternCode) {
        def patternCodeX = "%${patternCode}%"
        ilike "code", patternCodeX
      }
      if (niveau) {
        or {
          eq "niveau", niveau
          classes {
            eq "niveau", niveau
          }
        }
      }
      maxResults(limiteResults)
      def sortArg = paginationAndSortingSpec['sort'] ?: 'code'
      def orderArg = paginationAndSortingSpec['order'] ?: 'asc'
      if (sortArg) {
        order "${sortArg}", orderArg
      }

    }
    return structures
  }

  /**
   * Récupère les niveaux de différents établissements
   * @param etablissements
   * @return la liste des niveaux des différents établissements
   */
  List<Niveau> findNiveauxForEtablissement(Collection<Etablissement> etablissements) {
    AnneeScolaire anneeScolaire = AnneeScolaire.findByAnneeEnCours(true, [cache: true])
    if (!anneeScolaire) {
      throw new IllegalArgumentException("structures.recherche.anneescolaire.null")
    }
    if (!etablissements) {
      throw new IllegalArgumentException("structures.recherche.etablissements.vide")
    }
    def criteria = StructureEnseignement.createCriteria()
    def niveaux = criteria.list() {
      eq "anneeScolaire", anneeScolaire
      eq "actif", true
      eq "type", StructureEnseignement.TYPE_CLASSE
      or {
        etablissements.each {
          eq "etablissement", it
        }
      }
      niveau {
        order 'libelleLong', 'asc'
      }
      projections {
        niveau {
          groupProperty("libelleLong")
        }
        groupProperty "niveau"

      }


    }
    def niveauxRes = niveaux.collect {
      ((List) it)[1]
    }
    niveauxRes
  }

}