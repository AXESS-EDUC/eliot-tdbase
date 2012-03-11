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

import org.lilie.services.eliot.tice.annuaire.Personne
import org.springframework.transaction.annotation.Transactional

/**
 *
 * @author franck Silvestre
 */
public class ProfilScolariteService {

  static transactional = false

  /**
   * Récupère les profils de scolarite correspondant à la personne
   * passée en paramètre
   * @param personne la personne dont on cherche les profils scolarite
   * @return les proprietes scolarites correspant à la personne
   */
  List<ProprietesScolarite> findProprietesScolaritesForPersonne(Personne personne) {
    List<PersonneProprietesScolarite> profils =
      PersonneProprietesScolarite.findAllByPersonneAndEstActive(personne, true)
    return profils*.proprietesScolarite
  }

  /**
   * Récupère les fonctions occupées par la personne passée en paramètre, tout
   * établissement confondu
   * @param Personne la personne
   * @return la liste des fonctions
   */
  @Transactional
  List<Fonction> findFonctionsForPersonne(Personne personne) {
    List<PersonneProprietesScolarite> profils =
      PersonneProprietesScolarite.findAllByPersonneAndEstActive(personne, true, [cache: true])
    List<Fonction> fonctions = []
    profils.collect {
      Fonction fonction = it.proprietesScolarite.fonction
      if (fonction && !fonctions.contains(fonction)) {
        fonctions << fonction
      }
    }
    return fonctions
  }

  /**
   * Récupère les matières caractérisant la personne passée en paramètre, tout
   * établissement confondu
   * @param Personne la personne
   * @return la liste des matières
   */
  List<Matiere> findMatieresForPersonne(Personne personne) {
    List<PersonneProprietesScolarite> profils =
      PersonneProprietesScolarite.findAllByPersonneAndEstActive(personne, true, [cache: true])
    List<Matiere> matieres = []
    profils.collect {
      Matiere matiere = it.proprietesScolarite.matiere
      if (matiere && !matieres.contains(matiere)) {
        matieres << matiere
      }
    }
    return matieres
  }

  /**
   * Récupère les niveaux caractérisant la personne passée en paramètre, tout
   * établissement confondu
   * @param Personne la personne
   * @return la liste des niveaux
   */
  List<Niveau> findNiveauxForPersonne(Personne personne) {
    List<PersonneProprietesScolarite> profils =
      PersonneProprietesScolarite.findAllByPersonneAndEstActive(personne, true, [cache: true])
    List<Niveau> niveaux = []
    profils.collect {
      Niveau niveau = it.proprietesScolarite.niveau
      if (niveau && !niveaux.contains(niveau)) {
        niveaux << niveau
      }
    }
    return niveaux
  }

  /**
   * Récupère les structures d'enseignement (classes / divisions) caractérisant la
   * personne passée en paramètre, tout établissement confondu
   * @param Personne la personne
   * @return la liste des structures d'enseignements
   */
  List<StructureEnseignement> findStructuresEnseignementForPersonne(Personne personne) {
    List<PersonneProprietesScolarite> profils =
      PersonneProprietesScolarite.findAllByPersonneAndEstActive(personne, true, [cache: true])
    List<StructureEnseignement> structures = []
    profils.collect {
      StructureEnseignement structureEnseignement = it.proprietesScolarite.structureEnseignement
      if (structureEnseignement && !structures.contains(structureEnseignement)) {
        structures << structureEnseignement
      }
    }
    return structures
  }

  /**
   * Récupère les propriétés de scolarité d'une personne référençant une structure
   * s'enseignement
   * @param personne la personne
   * @return la liste des propriétés de scolarité
   */
  List<ProprietesScolarite> findProprietesScolariteWithStructureForPersonne(Personne personne) {
    def props = []
    List<PersonneProprietesScolarite> profils =
      PersonneProprietesScolarite.findAllByPersonneAndEstActive(personne, true, [cache: true])
    profils.collect {
      StructureEnseignement structureEnseignement = it.proprietesScolarite.structureEnseignement
      if (structureEnseignement && !props.contains(it.proprietesScolarite)) {
        props << it.proprietesScolarite
      }
    }
    return props
  }

  /**
   * Méthode recherchant la liste des élèves d'une structure d'enseignement
   * @param struct la structure d'enseignement
   * @return la liste des eleves
   */
  List<Personne> findElevesForStructureEnseignement(StructureEnseignement struct) {
    def criteria = PersonneProprietesScolarite.createCriteria()
    def personneProprietesScolarites = criteria.list {
      proprietesScolarite {
        eq 'structureEnseignement', struct
        eq 'fonction', FonctionEnum.ELEVE.fonction
      }
      eq 'estActive', true
      personne {
        order 'nom', 'asc'
      }
      join 'personne'
    }
    def eleves = []
    if (personneProprietesScolarites) {
      eleves = personneProprietesScolarites*.personne
    }
    return eleves
  }

  /**
   * Méthode recherchant la liste des élèves d'un responsable
   * @param responsable le responsable élève
   * @return la liste des eleves du responsable
   */
  List<Personne> findElevesForResponsable(Personne responsable) {
    def criteria = ResponsableEleve.createCriteria()
    def respEleves = criteria.list {
      eq 'personne', responsable
      eq 'estActive', true
      join 'eleve'
    }
    def eleves = []
    if (respEleves) {
      eleves = respEleves*.eleve
    }
    return eleves
  }

  /**
   * Méthode indiquant si une personne est responsable d'un élève
   * @param personne le responsable présumé
   * @param eleve l'élève
   * @return true si la personne est bien responsable de l'eleve
   */
  boolean personneEstResponsableEleve(Personne personne, Personne eleve) {
    def criteria = ResponsableEleve.createCriteria()
    def countRespEleves = criteria.count {
      eq 'personne', personne
      eq 'eleve', eleve
      eq 'estActive', true
    }
    return countRespEleves > 0
  }


}