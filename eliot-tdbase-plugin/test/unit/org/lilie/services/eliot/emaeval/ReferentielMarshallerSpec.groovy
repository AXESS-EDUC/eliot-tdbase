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
import org.lilie.services.eliot.competence.ReferentielDto
import org.lilie.services.eliot.competence.SourceReferentiel
import org.springframework.core.io.ClassPathResource
import spock.lang.Specification

/**
 * @author John Tranier
 */
class ReferentielMarshallerSpec extends Specification {

  /**
   * Ce test ne sert qu'à vérifier que le chargement d'un fichier complet d'EmaEval
   * ne génère aucun problème.
   *
   * Il n'a pas vocation à vérifier de manière exhaustive les propriété du fichier parsé
   * (ces vérifications sont faites dans les autres tests unitaires qui portent sur des
   * données atomiques créées manuellement)
   */
  def "testParse - Fichier XML complet"() {
    given:
    GPathResult xml = new XmlSlurper().parse(
        new ClassPathResource('org/lilie/services/eliot/emaeval/referentiel_get.xml').inputStream
    )

    ReferentielMarshaller referentielMarshaller = new ReferentielMarshaller()

    when:
    ReferentielDto referentielDto = referentielMarshaller.parse(xml)

    then:
    referentielDto.nom == "Palier 1"
  }

  def "testParse - OK"(int nbDomaine) {
    given:
    String nom = "Un référentiel"
    String description = "Une description"
    String idExterne = "123"
    String version = "1"
    String dateVersion = "7 août 2012"
    String urlReference = "URL"

    String xml = XmlGenerator.genereXmlReferentiel(
        new ReferentielDto(
            nom: nom,
            description: description,
            idExterne: idExterne,
            version: version,
            dateVersion: dateVersion,
            urlReference: urlReference
        ),
        nbDomaine
    )

    DomaineMarshaller domaineMarshaller = Mock(DomaineMarshaller)
    ReferentielMarshaller referentielMarshaller = new ReferentielMarshaller(
        domaineMarshaller: domaineMarshaller
    )

    when:
    ReferentielDto referentielDto = referentielMarshaller.parse(
        new XmlSlurper().parseText(xml)
    )

    then:
    referentielDto.nom == nom
    referentielDto.description == description
    referentielDto.idExterne == idExterne
    referentielDto.sourceReferentiel == SourceReferentiel.EMA_EVAL
    referentielDto.version == version
    referentielDto.dateVersion == dateVersion
    referentielDto.urlReference == urlReference
    nbDomaine * domaineMarshaller.parse(_)

    where:
    nbDomaine << [1, 2]
  }
}
