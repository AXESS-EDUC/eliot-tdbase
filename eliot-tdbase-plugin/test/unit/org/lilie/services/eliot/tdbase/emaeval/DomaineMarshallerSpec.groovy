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

import org.lilie.services.eliot.competence.DomaineDto
import org.lilie.services.eliot.competence.SourceReferentiel
import org.lilie.services.eliot.tdbase.emaeval.xml.CompetenceMarshaller
import org.lilie.services.eliot.tdbase.emaeval.xml.DomaineMarshaller
import spock.lang.Specification

/**
 * @author John Tranier
 */
class DomaineMarshallerSpec extends Specification {

  def "testParse - OK"(int nbSousDomaine, int nbCompetence) {
    given:
    String nom = "Une compétence"
    String description = "La description"
    String idExterne = "123"

    String xml = XmlGenerator.genereXmlDomaine(
        nom,
        description,
        idExterne,
        nbSousDomaine,
        nbCompetence
    )

    CompetenceMarshaller competenceMarshaller = Mock(CompetenceMarshaller)
    DomaineMarshaller domaineMarshaller = new DomaineMarshaller(
        competenceMarshaller: competenceMarshaller
    )

    when:
    DomaineDto domaineDto = domaineMarshaller.parse(
        new XmlSlurper().parseText(xml)
    )

    then:
    domaineDto.nom == nom
    domaineDto.description == description
    domaineDto.idExterne == idExterne
    domaineDto.sourceReferentiel == SourceReferentiel.EMA_EVAL
    nbCompetence * competenceMarshaller.parse(_)
    if(nbSousDomaine) {
      domaineDto.allSousDomaine.size() == nbSousDomaine
    }
    else {
      !domaineDto.allSousDomaine
    }


    where:
    nbSousDomaine << [0, 1, 3]
    nbCompetence << [0, 1, 3]
  }

}
