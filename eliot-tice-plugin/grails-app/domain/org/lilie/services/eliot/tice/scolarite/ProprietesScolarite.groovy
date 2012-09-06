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

import org.lilie.services.eliot.tice.annuaire.SourceImport
import org.lilie.services.eliot.tice.annuaire.PorteurEnt

/**
 * Table des propriétés des groupes virtuels
 * @author othe
 */
class ProprietesScolarite {

  Etablissement etablissement
  StructureEnseignement structureEnseignement
  AnneeScolaire anneeScolaire
  Niveau niveau
  Matiere matiere
  Mef mef
  Fonction fonction
  Boolean responsableStructureEnseignement
  PorteurEnt porteurEnt


  static constraints = {
    etablissement(nullable: true)
    structureEnseignement(nullable: true)
    anneeScolaire(nullable: true)
    fonction(nullable: true)
    niveau(nullable: true)
    matiere(nullable: true)
    mef(nullable: true)
    porteurEnt(nullable: true)
    responsableStructureEnseignement(nullable: true)
  }

  static transients = ['structureEnseignementNomAffichage']

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

  static mapping = {
    table('ent.propriete_scolarite')
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.propriete_scolarite_id_seq']
    version false
    mef column: 'mef_id'
  }

}
