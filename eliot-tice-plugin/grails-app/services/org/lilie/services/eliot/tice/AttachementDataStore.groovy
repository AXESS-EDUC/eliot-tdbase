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

import org.lilie.services.eliot.tice.jackrabbit.core.data.version_2_4_0.DataStoreException
import org.lilie.services.eliot.tice.jackrabbit.core.data.version_2_4_0.FileDataStore

/**
 * Classe représentant le FileDataStore utilisé pour stocker les fichiers dans
 * eliot-tdbase,...
 * Cette classe étend la classe FileDataStore fournie par Jackrabbit.
 * L'objectif est de fournir une  classe d'initialisation à Spring pour lever
 * une exception si le dossier devant contenir les fichiers n'est pas crée, ou
 * ne permet pas l'écriture des fichiers
 * @author franck Silvestre
 */
class AttachementDataStore extends FileDataStore {

  /**
   *  Classe initialisant le dataStore
   *  Si le dossier racine devant contenir les fichiers n'existe pas ou ne dispose
   *  pas des droits nécessaires alors la méthode lève une exception
   * @throws org.lilie.services.eliot.tice.jackrabbit.core.data.version_2_4_0.DataStoreException
   */
  def initFileDataStore() throws DataStoreException {
    if (getPath() == null) {
      def message = """
      attachementdatastore.path.null
      Verififier le parametre de configuration 'eliot.fichiers.racine'.
      """
      throw new DataStoreException(message);
    }
    File rootDir = new File(getPath());
    if (!rootDir.exists()) {
      def message = """
      attachementdatastore.path.doesnotexist : ${getPath()} .
      Modifier le parametre de configuration 'eliot.fichiers.racine'
      OU
      creer le dossier ${getPath()} avec les droits en ecriture pour l'application.
      """
      throw new DataStoreException(message);
    }
    if (!rootDir.isDirectory()) {
      def message = """
      attachementdatastore.path.isnotdirectory : ${getPath()} .
      Modifier le parametre de configuration 'eliot.fichiers.racine'
      OU
      creer le dossier ${getPath()} avec les droits en ecriture pour l'application.
      """
      throw new DataStoreException(message);
    }
    if (!rootDir.canWrite()) {
      def message = """
      attachementdatastore.path.nowriteaccess : ${getPath()} .
      Modifier le parametre de configuration 'eliot.fichiers.racine'
      OU
      donner les droits en ecriture pour l'application sur dossier ${getPath()}.
      """
      throw new DataStoreException(message);
    }
    super.init("");
  }
}
