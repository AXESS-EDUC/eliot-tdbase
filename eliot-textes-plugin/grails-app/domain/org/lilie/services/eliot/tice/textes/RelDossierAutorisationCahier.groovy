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

import org.lilie.services.eliot.tice.securite.DomainAutorisation
import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.HashConstantes

/**
 * Jointure entre Dossier et l'Autorisation d'un Item de Cahier de texte
 */
class RelDossierAutorisationCahier implements Serializable {


  Long ordre
  DomainAutorisation autorisation

  static mapping = {
    table 'entcdt.rel_dossier_autorisation_cahier'
    dossier column: 'id_dossier'
    autorisation column: 'id_autorisation'
    id composite: ['dossier', 'autorisation']
    version false
  }

  static belongsTo = [dossier: Dossier, autorisation: DomainAutorisation]

  static constraints = {
    version(max: 9999999999L)
    dossier(nullable: false)
    autorisation(nullable: false)
    ordre(nullable: false)
  }

  String toString() {
    return "dossier:${dossier} a10n:${autorisation} ordre:${ordre}"
  }

  /**
   * Cherche la relation pour un dossier, un cahier de textes et une autorite
   */
  static RelDossierAutorisationCahier chercheByDossierAndCahierAndAutorite(Dossier dossier, CahierDeTextes cdt, DomainAutorite autorite) {
    RelDossierAutorisationCahier rel
    DomainAutorisation auto = DomainAutorisation.findByAutoriteAndItem(autorite, cdt.item)

    if (auto) {
      rel = RelDossierAutorisationCahier.findByDossierAndAutorisation(dossier, auto)
    }

    return rel
  }

  /**
   * Cherche les relations pour un dossier et une autorite
   */
  static Collection<RelDossierAutorisationCahier> chercheByDossierAndAutorite(Dossier dossier,
                                                                              DomainAutorite autorite) {
    Collection<DomainAutorisation> userAutos = DomainAutorisation.findAllByAutorite(autorite) // pour utiliser dans le IN pour chercher RelDossierAutorisationCahier r WHERE r.autorisation.authotite = Authorite
    // Cherche tous les Rels pour l'autorité et dossier
    // RelDossierAutorisationCahier belongsTo Autorisation belongsTo Autorite
    List<RelDossierAutorisationCahier> rels = []
    if (userAutos) {
      rels = RelDossierAutorisationCahier.withCriteria {
        and {
          eq("dossier", dossier)
          'in'("autorisation", userAutos)
        }
      }
    }
    return rels
  }

  def int hashCode() {
    if (dossier?.id && autorisation?.id) {
      return (((dossier.id % HashConstantes.MAX_16BITS) *
              HashConstantes.MAX_16BITS) + (autorisation.id % HashConstantes.MAX_16BITS))
    } else {
      return super.hashCode()
    }
  }

  def boolean equals(Object o) {
    return ((this.dossier.id == o.dossier.id) &&
            (this.autorisation.id == o.autorisation.id))
  }
}
