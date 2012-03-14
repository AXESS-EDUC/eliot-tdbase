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

/**
 * Periode de scolarité
 * Chaque période est lié à une classe qui peut avoir les paramétres spécifiques
 * comme le date de début, date de fin ...
 *
 * @author bcro
 * @author msan
 * @author bper
 *
 */
class Periode implements Comparable {

  Long id
  TypePeriode typePeriode
  StructureEnseignement classe

  Date dateDebut
  Date dateFin
  Date dateFinSaisie
  Date datePublication

  static belongsTo = [
          typePeriode: TypePeriode
  ]

  static transients = [
          'isPeriodeAnnee',
          'isPeriodeNotation',
          'ordre',
          'libelle',
          'typeIntervalle',
          'intervalle',
          'nature',
          'verrouille',
          'publie'
  ]

  static constraints = {
    typePeriode(nullable: false)
    classe(nullable: false)
    dateDebut(nullable: true)
    dateFin(nullable: true)
    dateFinSaisie(nullable: true)
    datePublication(nullable: true)
  }

  // l'enregistrement dans le tableau de jointure rel_evaluation_periode est enlevé par
  // cascade quand la période est supprimée

  static mapping = {
    table('ent.periode')
    version false
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.periode_id_seq']
    typePeriode column: 'type_periode_id', fetch: 'join'
    dateDebut column: 'date_debut'
    dateFin column: 'date_fin'
    dateFinSaisie column: 'date_fin_saisie'
    datePublication column: 'date_publication'
    classe column: 'structure_enseignement_id'
  }

  String toString() {
    return "$id-${typePeriode.libelle}"
  }

  Boolean isPeriodeAnnee() {
    return this.typePeriode.isAnnee()
  }

  Boolean isPeriodeNotation() {
    return this.typePeriode.isNotation()
  }

  Boolean isPeriodeExamen() {
    return this.typePeriode.isExamen()
  }

  Integer getOrdre() {
    return this.typePeriode.getOrdre()
  }

  TypeIntervalleEnum getTypeIntervalle() {
    return this.typePeriode.getTypeIntervalle()
  }

  String getLibelle() {
    return this.typePeriode.libelle
  }

  IntervalleEnum getIntervalle() {
    return this.typePeriode.intervalle
  }

  NaturePeriodeEnum getNature() {
    return this.typePeriode.nature
  }

  /**
   * Periode est Trimestre ou Semestre
   * @return true/false
   * @author msan
   */
  Boolean isPeriodeXmestre() {
    return this.typePeriode.isXmestre()
  }

  /**
   * Retourne true si la date actuelle est entre les dates de debut et de fin,
   * sinon retourne false. Si une des dates (debut ou fin) est null retourne false.
   * @return true/false
   * @author bper
   */
  Boolean isPeriodeEnCours() {
    if (this.dateDebut && this.dateFin) {
      Calendar cal = GregorianCalendar.getInstance()
      cal.setTime(new Date())
      cal.set(Calendar.HOUR_OF_DAY, 0)
      cal.set(Calendar.MINUTE, 0)
      cal.set(Calendar.SECOND, 0)
      cal.set(Calendar.MILLISECOND, 0)
      Date now = cal.getTime()

      if (this.dateDebut.compareTo(now) <= 0 && this.dateFin.compareTo(now) >= 0) {
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }

  /**
   * Return true si la saisie des notes et des appréciations et bloquée pour
   * la période. Sinon retourne false.
   * @return true/false
   * @author bper
   */
  Boolean getVerrouille() {
    if (this.dateFinSaisie) {
      Calendar cal = GregorianCalendar.getInstance()
      cal.setTime(new Date())
      cal.set(Calendar.HOUR_OF_DAY, 0)
      cal.set(Calendar.MINUTE, 0)
      cal.set(Calendar.SECOND, 0)
      cal.set(Calendar.MILLISECOND, 0)
      Date now = cal.getTime()

      if (this.dateFinSaisie.compareTo(now) >= 0) {
        return false
      } else {
        return true
      }
    } else {
      return true
    }
  }

  /**
   * Return true si la date de publiation est dépassé. Sinon retourne false.
   * @return true/false
   * @author bper
   */
  Boolean getPublie() {
    if (this.datePublication) {
      Calendar cal = GregorianCalendar.getInstance()
      cal.setTime(new Date())
      cal.set(Calendar.HOUR_OF_DAY, 0)
      cal.set(Calendar.MINUTE, 0)
      cal.set(Calendar.SECOND, 0)
      cal.set(Calendar.MILLISECOND, 0)
      Date now = cal.getTime()

      if (this.datePublication.compareTo(now) >= 0) {
        return false
      } else {
        return true
      }
    } else {
      return false
    }
  }

  /**
   * Permet de trier les périodes
   * @param o - periode
   * @return
   * @author bper
   */
  public int compareTo(Object o) {
    Periode periode = (Periode) o
    if (this.typePeriode.isNotation()) {
      if (periode.typePeriode.isNotation()) {
        return this.ordre <=> periode.ordre // A et B Notation = trie par ordre
      } else {
        return -1 // A = Notation = a est première
      }
    } else if (periode.typePeriode.isNotation()) {
      return 1 // B = Notation = b est première
    } else { // A et B examen - trie par dateDebut
      return this.dateDebut <=> periode.dateDebut
    }
  }

}
