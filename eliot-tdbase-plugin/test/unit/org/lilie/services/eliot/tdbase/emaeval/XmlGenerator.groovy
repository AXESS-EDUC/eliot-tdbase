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

package org.lilie.services.eliot.tdbase.emaeval

import org.lilie.services.eliot.competence.ReferentielDto

/**
 * Classe utilitaire fournissant des méthodes pour générer
 * des fragments de code XML pour les tests
 *
 * @author John Tranier
 */
class XmlGenerator {

  static String genereXmlCompetence(String nom, String description, String idExterne) {
    return """
      <com.pentila.evalcomp.domain.definition.Competence>
          <description>$description</description>
          <id>$idExterne</id>
          <name>$nom</name>
      </com.pentila.evalcomp.domain.definition.Competence>
    """
  }

  static String genereXmlCompetenceList(int nbCompetence) {
    if (nbCompetence == 0) {
      return "<competences/>"
    }

    String xml = "<competences>"
    nbCompetence.times {
      xml += genereXmlCompetence("nom-$it", "description-$it", "$it")
    }
    xml += "</competences>"

    return xml
  }

  static String genereXmlDomaine(String nom,
                                 String description,
                                 String idExterne,
                                 int nbSousDomaine,
                                 int nbCompetence) {
    return """
      <com.pentila.evalcomp.domain.definition.Domain>
          <description>$description</description>
          <id>$idExterne</id>
          <name>$nom</name>
          ${genereXmlCompetenceList(nbCompetence)}
          ${genereXmlDomaineList(nbSousDomaine)}
      </com.pentila.evalcomp.domain.definition.Domain>
    """
  }

  static genereXmlDomaineList(int nbDomaine) {
    if(nbDomaine == 0) {
      return "<domains/>"
    }

    String xml = "<domains>"
    nbDomaine.times {
      xml += genereXmlDomaine("nom-$it", "description-$it", "$it", 0, 0)
    }
    xml += "</domains>"
  }

  static genereXmlReferentiel(ReferentielDto referentielDto, int nbDomaine) {
    return """
    <com.pentila.evalcomp.domain.definition.Referentiel>
      <description>${referentielDto.description}</description>
      <id>${referentielDto.idExterne}</id>
      <name>${referentielDto.nom}</name>
      <version>${referentielDto.version}</version>
      <dateVersion>${referentielDto.dateVersion}</dateVersion>
      <reference>${referentielDto.urlReference}</reference>
      ${genereXmlDomaineList(nbDomaine)}
    </com.pentila.evalcomp.domain.definition.Referentiel>
    """
  }
}
