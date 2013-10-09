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

package org.lilie.services.eliot.emaeval

import groovy.util.slurpersupport.GPathResult
import org.lilie.services.eliot.competence.DomaineDto
import org.lilie.services.eliot.competence.ReferentielDto
import org.lilie.services.eliot.competence.SourceReferentiel

/**
 * Permet de parser un référentiel au format XML EmaEval
 *
 * @author John Tranier
 */
class ReferentielMarshaller {

  private final static String TAG_NAME = "com.pentila.evalcomp.domain.definition.Referentiel"

  DomaineMarshaller domaineMarshaller = new DomaineMarshaller()

  ReferentielDto parse(GPathResult xmlReferentiel) {
    assert xmlReferentiel.name() == TAG_NAME

    String name = xmlReferentiel.":name".text()
    String idExterne = xmlReferentiel.id.text()
    String description = xmlReferentiel.description.text()
    String version = xmlReferentiel.version.text()
    String dateVersion = xmlReferentiel.dateVersion.text()
    String urlReference = xmlReferentiel.reference.text()

    assert name
    assert idExterne

    List<DomaineDto> domaineDtoList = []
    xmlReferentiel.domains.children().each { GPathResult xmlDomaine ->
      domaineDtoList << domaineMarshaller.parse(xmlDomaine)
    }

    assert domaineDtoList

    return new ReferentielDto(
        nom: name,
        description: description,
        idExterne: idExterne,
        sourceReferentiel: SourceReferentiel.EMA_EVAL,
        version: version,
        dateVersion: dateVersion,
        urlReference: urlReference,
        allDomaine: domaineDtoList
    )
  }
}
