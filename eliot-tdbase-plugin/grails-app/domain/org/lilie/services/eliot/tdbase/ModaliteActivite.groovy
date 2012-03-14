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

package org.lilie.services.eliot.tdbase

import org.lilie.services.eliot.tice.annuaire.GroupePersonnes
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.notes.Evaluation
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement
import org.lilie.services.eliot.tice.textes.Activite
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService

/**
 * Classe représentant les modalités de l'activité d'un groupe d'élèves pour traiter
 * un sujet en ligne
 * @author franck Silvestre
 */
class ModaliteActivite {

  ProfilScolariteService profilScolariteService

  Date dateRemiseReponses = new Date()

  Date dateDebut = new Date()
  Date dateFin = new Date()

  Sujet sujet

  Personne responsable
  GroupePersonnes groupe
  Etablissement etablissement

  Personne enseignant
  StructureEnseignement structureEnseignement
  Matiere matiere

  Activite activite
  Evaluation evaluation
  Boolean copieAmeliorable = true

  static constraints = {
    responsable(nullable: true)
    groupe(nullable: true)
    etablissement(nullable: true)
    activite(nullable: true)
    evaluation(nullable: true)
    structureEnseignement(nullable: true, validator: { val, obj ->
      if (val == null) {
        return (obj.groupe != null && obj.etablissement != null)
      }
      return true
    })
    matiere(nullable: true)
  }

  static transients = ['groupeLibelle', 'estOuverte', 'estPerimee','profilScolariteService']

  /**
   *
   * @return la liste des personnes devant rendre une copie pour cette séance
   */
  List<Personne> getPersonnesDevantRendreCopie() {
    if (structureEnseignement) {
      return profilScolariteService.findElevesForStructureEnseignement(structureEnseignement)
    } else {
      // groupes non implémentés
      return []
    }

  }

  /**
   *
   * @return le libelle du groupe ou de la structure d'enseignement concernée
   */
  String getGroupeLibelle() {
    if (structureEnseignement) {
      return structureEnseignement.nomAffichage
    } else if (groupe) {
      return groupe.nom
    }
    return ''
  }

  /**
   *
   * @return true si la séance est ouverte
   */
  boolean estOuverte() {
    Date now = new Date()
    now.before(dateFin) && now.after(dateDebut)
  }

  /**
   *
   * @return true si la séance est terminée
   */
  boolean estPerimee() {
    Date now = new Date()
    now.after(dateFin)
  }


  static mapping = {
    table('td.modalite_activite')
    version(false)
    id(column: 'id', generator: 'sequence', params: [sequence: 'td.modalite_activite_id_seq'])
    cache(true)
  }


}
