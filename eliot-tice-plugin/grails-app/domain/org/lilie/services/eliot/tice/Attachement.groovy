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

package org.lilie.services.eliot.tice

/**
 * Classe représentant une fichier attaché à un objet du domaine
 * @author franck Silvestre
 */
class Attachement {

  private static final ArrayList<String> TYPES_MIME_IMG_AFFICHABLE = [
          'image/gif',
          'image/jpeg',
          'image/png'
  ]

  String chemin
  String nom
  String nomFichierOriginal
  Integer taille
  Dimension dimension
  String typeMime
  boolean aSupprimer

  static constraints = {
    taille(nullable: true)
    typeMime(nullable: true)
    nomFichierOriginal(nullable: true)
    dimension(nullable: true)
  }

  static mapping = {
    table('tice.attachement')
    version(false)
    id(column: 'id', generator: 'sequence', params: [sequence: 'tice.attachement_id_seq'])
    cache(true)
  }

  static transients = ['estUneImageAffichable', 'estUnTexteAffichable']

  static embedded = ['dimension']

  boolean estUneImageAffichable() {
    return typeMime in TYPES_MIME_IMG_AFFICHABLE
  }

  boolean estUnTexteAffichable() {
    return typeMime?.startsWith('text/')
  }

  /**
   * Calcule la dimension rendu en fonction d'une dimension max donnée.
   * @param dimMax
   * @return
   */
  Dimension calculeDimensionRendu(Dimension dimMax) {
    def l = dimension.largeur
    def h = dimension.hauteur
    def ratio = [l / dimMax.largeur, h / dimMax.hauteur].max()

    if (ratio > 1) {
      l = (l / ratio as Double).trunc()
      h = (h / ratio as Double).trunc()
    }
    assert (l <= dimMax.largeur && h <= dimMax.hauteur)
    new Dimension(largeur: l, hauteur: h)
  }

}

class Dimension implements Comparable<Dimension> {
  Integer largeur
  Integer hauteur

  String toString() {
    "dim    h: $hauteur     l: $largeur"
  }

  @Override
  int compareTo(Dimension other) {
    if (largeur == other.largeur && hauteur == other.hauteur) {
      return 0
    }

    if (largeur > other.largeur || hauteur > other.hauteur) {
      return 1
    }

    return -1

  }
}