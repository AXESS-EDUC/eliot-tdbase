/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */





package org.lilie.services.eliot.tdbase


import org.springframework.transaction.annotation.Transactional
import org.hibernate.FetchMode



/**
 * Service de gestion des copies
 * @author franck silvestre
 */
class CopieJobService {

  static transactional = false
  ReponseService reponseService

  /**
   * Supprime les copies jetables
   * @param nbJoursPasses le nombre de jours passés après la date de dernier
   * enregistrement
   * @return  le rapport de suppression
   */
  @Transactional
  SupprimeCopiesJetablesRapport supprimeCopiesJetablesForNombreJoursPasses(
          Integer nbJoursPasses = 10) {
    Date now = new Date()
    if (nbJoursPasses == null) {
      nbJoursPasses = 10
    }
    Date dateDernierEnregistrement = now - nbJoursPasses
    def crit = Copie.createCriteria()
    def copies = crit.list {
      eq 'estJetable', true
      lt 'dateEnregistrement', dateDernierEnregistrement
      fetchMode('reponses',FetchMode.EAGER)
    }
    def rapport = new SupprimeCopiesJetablesRapport()
    rapport.dateDernierEnregistrementCopiesSupprimees = dateDernierEnregistrement
    copies.each { copie ->
      rapport.nombreDeCopiesSupprimees += 1
      def reponses = []
      reponses.addAll(copie.reponses)
      reponses.each { reponse ->
        rapport.nombreDeReponsesSupprimees += 1
        reponseService.supprimeReponse(reponse, null)
      }
      copie.delete(flush: true)
    }
    rapport
  }


}

class SupprimeCopiesJetablesRapport {
  Long nombreDeCopiesSupprimees = 0
  Long nombreDeReponsesSupprimees = 0
  Date dateDernierEnregistrementCopiesSupprimees
}
