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

import org.lilie.services.eliot.tice.annuaire.PorteurEnt
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeAnnuaire
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeType

/**
 * Table des propriétés des groupes virtuels
 * @author othe
 */
class ProprietesScolarite extends GroupeAnnuaire {

  Long id
  Etablissement etablissement
  StructureEnseignement structureEnseignement
  AnneeScolaire anneeScolaire
  Matiere matiere
  Fonction fonction
  Boolean responsableStructureEnseignement
  PorteurEnt porteurEnt
  // DomainAutorite autorite TODO A ajouter quand on branchera le nouveau schéma Eliot

  static transients = ['structureEnseignementNomAffichage', 'groupeType']

  static constraints = {
    etablissement(nullable: true)
    structureEnseignement(nullable: true)
    anneeScolaire(nullable: true)
    fonction(nullable: true)
    matiere(nullable: true)
    porteurEnt(nullable: true)
    responsableStructureEnseignement(nullable: true)
  }

  static mapping = {
    table('ent.propriete_scolarite')
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.propriete_scolarite_id_seq']
    version false
  }

  /**
   * Méthode copiée & adaptée du socle Eliot
   * @return
   */
  @Override
  String getNomAffichage() {
    String nom

    if (etablissementId) {
      switch (fonction.code) {
        case FonctionEnum.ELEVE.name():
          nom = "Elèves de l'établissement"
          break
        case FonctionEnum.PERS_REL_ELEVE.name():
          nom = "Parents de l'établissement"
          break
        case FonctionEnum.ENS.name():
          if (matiereId) {
            nom = "Enseignants de l'établissement (${matiere.codeGestion})"
          } else {
            nom = "Enseignants de l'établissement"
          }
          break
        case FonctionEnum.AL.name():
          nom = "Administrateur local de l'établissement"
          break
        default:
          nom = "Personnel d'établissement (${fonction.libelle})"
      }
    } else if (structureEnseignementId) {
      switch (fonction.code) {
        case FonctionEnum.ELEVE.name():
          if (responsableStructureEnseignement) {
            nom = "Elèves délégués ($structureEnseignement.code)"
          } else {
            nom = "Elèves ($structureEnseignement.code)"
          }
          break
        case FonctionEnum.PERS_REL_ELEVE.name():
          nom = "Parents ($structureEnseignement.code)"
          break
        case FonctionEnum.ENS.name():
          if (responsableStructureEnseignement) {
            nom = "Enseignants principaux ($structureEnseignement.code)"
          }
          else {
            nom = "Enseignants ($structureEnseignement.code)"
          }
          break
        default:
          throw new IllegalStateException(
              "Les groupes de fonction ${fonction.code} ne sont pas gérés pour " +
                  "la portée \"structure d'enseignement\". Groupe illégal: $this")
      }
    } else {
      switch (fonction.code) {
        case FonctionEnum.PERS_REL_ELEVE.name():
          nom = "Parents de l'ENT"
          break
        case FonctionEnum.CD.name():
          nom = "Correspondants de déploiment"
          break
        default:
          throw new IllegalStateException(
              "Les groupes de fonction ${fonction.code} ne sont pas gérés pour " +
                  "la portée \"porteur ENT\". Groupe illégal: $this")
      }
    }
    return nom
  }
/**
   *
   * @return le nom de la structure avec matière associée si il y a
   */
  String getStructureEnseignementNomAffichage() {
    if (!structureEnseignement) {
      return null
    }
    def matLib = matiere?.libelleLong
    def suffixe = ''
    if (matLib) {
      suffixe = " (${matLib})"
    }
    structureEnseignement?.nomAffichage + suffixe
  }

  /**
   * @return l'établissement auquel ce groupe est attaché (soit directement, soit par une structure d'enseignement)
   */
  Etablissement etablissement() {
    return etablissement ?: structureEnseignement?.etablissement
  }

  @Override
  GroupeType getGroupeType() {
    return GroupeType.SCOLARITE
  }
}
