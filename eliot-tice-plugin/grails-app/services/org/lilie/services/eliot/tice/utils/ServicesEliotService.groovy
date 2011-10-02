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



package org.lilie.services.eliot.tice.utils

import org.codehaus.groovy.grails.commons.ConfigurationHolder
import org.lilie.services.eliot.tice.annuaire.Personne

class ServicesEliotService {

  static transactional = false
  private static final String NOM_DOSSIER_DOCUMENTS = "Documents"

  /**
   * Retourne le chemin correspondant à l'espace de fichiers
   * de la personne pour le service passé en paramètre. Le chemin est relatif
   * à la racine de l'espace de fichier
   * @param personne la personne
   * @param serviceEliotEnum le service concerné
   * @return le chemin
   */
  String getCheminRelatifEspaceFichierForPersonneAndServiceEliot(
          Personne personne,
          ServiceEliotEnum serviceEliotEnum) {
    def fsep = File.separator
    def persId = personne.id.toString().padLeft(20, '0')
    persId << fsep << serviceEliotEnum.name() << fsep << NOM_DOSSIER_DOCUMENTS << fsep
  }

  /**
   * Rétourne le chemin racine pour le stocakge des fichiers
   * @param config le config object
   * @return le chemin
   */
  String getCheminRacineEspaceFichier(def config = ConfigurationHolder.config) {
    String chemin = config.eliot.fichiers.racine
    if (chemin.endsWith(File.separator)) {
      return chemin
    }
    return chemin + File.separator
  }

  /**
   * Retourne le chemin correspondant à l'espace de fichiers
   * de la personne pour le service passé en paramètre. Le chemin est absolu.
   *
   * @param personne la personne
   * @param serviceEliotEnum le service concerné
   * @param config le config object
   * @return le chemin
   */
  String getCheminAbsoluEspaceFichierForPersonneAndServiceEliot(
          Personne personne,
          ServiceEliotEnum serviceEliotEnum,
          def config = ConfigurationHolder.config) {
      getCheminRacineEspaceFichier(config) <<
      getCheminRelatifEspaceFichierForPersonneAndServiceEliot(
              personne,
              serviceEliotEnum
      )
  }
}

enum ServiceEliotEnum {
  tdbase,
  textes,
  notes,
  absences,
  agenda,
  docs
}