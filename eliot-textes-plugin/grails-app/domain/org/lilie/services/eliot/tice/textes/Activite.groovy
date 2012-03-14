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

package org.lilie.services.eliot.tice.textes


import java.text.SimpleDateFormat
import org.lilie.services.eliot.tice.securite.DomainItem
import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.discussion.Discussion

/**
 * The Activite entity.
 * @author atua
 * @author fsil
 * @author jduf
 */
class Activite {

  // datePublication est omitté intentionellement. Ce colon n'est plus utilisé

  Long id
  DomainItem item
  Date dateCreation
  Date dateModification
  Date datePublication
  String titre
  String objectif
  String enonce
  String description
  String annotationPrivee
  Long ordre
  Boolean estPubliee = Boolean.FALSE
  Boolean estTerminee = Boolean.FALSE
  String codeMatiere

  TypeActivite typeActivite
  ContexteActivite contexteActivite
  Chapitre chapitre
  CahierDeTextes cahierDeTextes
  DomainAutorite auteur

  // Liste des propriétés qui sont exportées lors d'un appel à la méthode exporteDans(<Activite>)
  private static proprieteAExporter = [
          'titre',
          'objectif',
          'enonce',
          'description',
          'annotationPrivee',
          'codeMatiere',
          'typeActivite',
          'contexteActivite',
          'auteur'
  ]

  static hasMany = [
          ressources: Ressource,
          dates: DateActivite,
          relActiviteActeurs: RelActiviteActeur
  ]

  static belongsTo = [cahierDeTextes: CahierDeTextes, chapitre: Chapitre]

  static constraints = {
    id(max: 9999999999L)
    version(max: 9999999999L)
    item(nullable: true)
    dateModification(nullable: true)
    datePublication(nullable: true)
    chapitre(nullable: true)
    titre(size: 0..512, nullable: true)
    ordre(max: 9999999999L)
    codeMatiere(size: 0..30, nullable: true)
    cahierDeTextes(nullable: false)
    typeActivite(nullable: true)
    contexteActivite(nullable: true)
    ressources(nullable: true)
    dates(nullable: true)
  }

  /**
   * Méthode retournant la discussion associée à une activité
   * @return la discussion
   */
  Discussion getDiscussion() {
    return Discussion.findByItemCible(item)
  }

  /**
   * Méthode retournant le résumé de l'activité
   * @return le resume
   */
  String getResume() {
    String prefix = "${cahierDeTextes.service?.matiere?.libelleLong} - "
    if (typeActivite) {
      prefix += "${typeActivite.nom} -"
    }
    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy")
    "${df.format(datePlusRecente())} : ${prefix} ${titre}."
  }

  String toSimpleString() {
    return "${titre} (${cahierDeTextes.nom})"
  }

  String toString() {
    return "${id}"
  }

  boolean enClasse() {
    contexteActivite?.code == ContexteActivite.CODE_CLASSE
  }

  boolean alaMaison() {
    contexteActivite?.code == ContexteActivite.CODE_MAISON
  }

  boolean estDevoir() {
    return typeActivite?.code in [
            TypeActivite.CODE_DEVOIR,
            TypeActivite.CODE_DEVOIR_SURVEILLE
    ]
  }

  boolean estTermineeForActeur(DomainAutorite acteur) {
    RelActiviteActeur rel =
      relActiviteActeurs.find { RelActiviteActeur rel -> rel.acteur?.idExterne == acteur?.idExterne }
    return rel && rel.estTermine
  }

  Date datePlusRecente() {
    if (!dates?.isEmpty()) {
      if (enClasse()) {
        List datesSorted = dates.sort {DateActivite date1, DateActivite date2 ->
          if (!date1.dateActivite) {
            -1
          } else if (!date2.dateActivite) {
            1
          } else {
            date1.dateActivite.compareTo(date2.dateActivite)
          }
        }
        datesSorted.reverse()
        DateActivite date = (DateActivite) datesSorted[0]
        return date.dateActivite
      }
      if (alaMaison()) {
        DateActivite date = dates ? (DateActivite) dates.asList()[0] : null
        return date?.dateEcheance
      }
    }
    return null
  }

  /**
   * Positionne date d'écheance. A utiliser pour travail maison
   * Le seul date d'échéance est possible pour travail maison. Pas de durée est reseignée
   * @return date d'écheance
   */
  DateActivite positionneDateEcheance(Date dateEcheance) {
    // cherche si date echeance exist déjà
    DateActivite date = null
    if (this.id != null) {
      date = DateActivite.findByActiviteAndDateEcheanceIsNotNull(this)
    }
    if (dateEcheance == null) {
      if (date) {
        // enléve date
        this.removeFromDates(date)
        date.delete()
        date = null
      }
    } else {
      if (!date) { // crée nouvele date , dans l'autre cas on réutilise date existant
        date = new DateActivite()
        date.setActivite(this)
      }
      date.setDateEcheance(dateEcheance)
      date.save()
    }

    return date
  }

  /**
   * Ajoute date d'activité. A utiliser pour travail en classe
   * Plusieurs dates d'activité sont possible pour travail en classe
   * @return date d'activité
   */
  DateActivite ajouteDateActivite(Date dateActivite, Long duree) {
    DateActivite date = new DateActivite()
    date.setDateActivite(dateActivite)
    date.setDuree(duree)
    date.setActivite(this)
    date.save()
    return date
  }

//  public TreeNode parent() {
//    return chapitre
//  }
//
//  public void setParent(TreeNode parent) {
//    if (parent instanceof Chapitre)
//      chapitre = parent
//  }

  /**
   * Exporte les propriétés propres au contenu de l'activité courantes dans l'activité passée en paramètre
   * @param activiteDestination : l'activité dans laquelle l'exportation est effectué
   * @return l'activité exportée   
   */
  Activite exporteDans(Activite activiteDestination) {
    proprieteAExporter.each {activiteDestination."$it" = this."$it"}

    return activiteDestination
  }

  static transients = ['discussion', 'resume']

  static mapping = {
    table 'entcdt.activite'
    id column: 'id', generator: 'sequence', params: [sequence: 'entcdt.activite_id_seq']
    item column: 'id_item', fetch: 'join'
    typeActivite column: 'id_type_activite'
    contexteActivite column: 'id_contexte_activite'
    chapitre column: 'id_chapitre'
    cahierDeTextes column: 'id_cahier_de_textes'
    auteur column: 'id_auteur'
    version false
  }
}
