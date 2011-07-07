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

package org.lilie.services.eliot.tice.notes

import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.scolarite.Periode
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement
import org.lilie.services.eliot.tice.scolarite.Service
import org.lilie.services.eliot.tice.scolarite.Enseignement
import org.lilie.services.eliot.tice.scolarite.SousService

/**
 * Information sur le dernière changement d'une moyenne.
 * (moyenne qui a besoin d'être recalculée est appelée dirty)
 * @author msan
 */
class DirtyMoyenne {

  Long id
  Date dateChangement // date de dernière changement de cette moyenne
  DomainAutorite eleve
  StructureEnseignement classe
  Periode periode
  Service service
  Enseignement enseignement
  SousService sousService
  TypeMoyenneEnum typeMoyenne

  static constraints = {
    dateChangement (nullable:false)
    eleve (nullable:true, validator: eleveValidator)
    classe (nullable:true, validator: classeValidator)
    periode (nullable:false)
    service (nullable:true, validator: serviceValidator)
    enseignement (nullable:true, validator: enseignementValidator)
    sousService (nullable:true, validator: sousServiceValidator)
    typeMoyenne (nullable:false)
  }

  static mapping = {
    table('entnotes.dirty_moyenne')
    id column: 'id',
            generator: 'sequence',
            params: [sequence: 'entnotes.dirty_moyenne_id_seq']
    version false // on veut pesimistic locking
    dateChangement column: 'date_changement'
    eleve column: 'eleve_id'
    classe column: 'classe_id'
    periode column: 'periode_id'
    service column: 'service_id'
    // pour enseignement - la declaration d'une cle composite ne fonctionne qu'implicitement
    sousService column: 'sous_service_id'
    typeMoyenne column: 'type_moyenne'
  }

  String toString() {
    return "$typeMoyenne $id $classe $eleve $periode $service $enseignement $sousService $dateChangement"
  }

  /**
   * Eleve doit ne pas être null pour les moyennes Eleve*
   */
  static eleveValidator = {val, DirtyMoyenne dm ->
    return ([
            TypeMoyenneEnum.ELEVE_ENSEIGNEMENT_PERIODE,
            TypeMoyenneEnum.ELEVE_PERIODE,
            TypeMoyenneEnum.ELEVE_SERVICE_PERIODE,
            TypeMoyenneEnum.ELEVE_SOUS_SERVICE_PERIODE].
            contains(dm.typeMoyenne) ? (val!=null) : true)
  }

  /**
   * Classe doit ne pas être null pour les moyennes Classe*
   */
  static classeValidator = {val, DirtyMoyenne dm ->
    return ([
            TypeMoyenneEnum.CLASSE_ENSEIGNEMENT_PERIODE,
            TypeMoyenneEnum.CLASSE_PERIODE,
            TypeMoyenneEnum.CLASSE_SERVICE_PERIODE,
            TypeMoyenneEnum.CLASSE_SOUS_SERVICE_PERIODE].
            contains(dm.typeMoyenne) ? (val!=null) : true)
  }

  /**
   * Service doit ne pas être null pour les moyennes *Service
   */
  static serviceValidator = {val, DirtyMoyenne dm ->
    return ([
            TypeMoyenneEnum.ELEVE_SERVICE_PERIODE,
            TypeMoyenneEnum.ELEVE_SOUS_SERVICE_PERIODE,
            TypeMoyenneEnum.CLASSE_SERVICE_PERIODE,
            TypeMoyenneEnum.CLASSE_SOUS_SERVICE_PERIODE].
            contains(dm.typeMoyenne) ? (val!=null) : true)
  }

  /**
   * Enseignement doit ne pas être null pour les moyennes *Enseignement
   */
  static enseignementValidator = {val, DirtyMoyenne dm ->
    return ([
            TypeMoyenneEnum.ELEVE_ENSEIGNEMENT_PERIODE,
            TypeMoyenneEnum.CLASSE_ENSEIGNEMENT_PERIODE].
            contains(dm.typeMoyenne) ? (val!=null) : true)
  }

  /**
   * SousService doit ne pas être null pour les moyennes *SousService
   */
  static sousServiceValidator = {val, DirtyMoyenne dm ->
    return ([
            TypeMoyenneEnum.ELEVE_SOUS_SERVICE_PERIODE,
            TypeMoyenneEnum.CLASSE_SOUS_SERVICE_PERIODE].
            contains(dm.typeMoyenne) ? (val!=null) : true)
  }
}
