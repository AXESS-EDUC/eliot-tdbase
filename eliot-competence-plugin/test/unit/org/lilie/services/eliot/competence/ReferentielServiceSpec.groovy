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
package org.lilie.services.eliot.competence

import grails.plugin.spock.UnitSpec

/**
 * @author John Tranier
 */
class ReferentielServiceSpec extends UnitSpec {

  ReferentielService referentielService
  DomaineImporter domaineImporter

  def setup() {
    domaineImporter = Mock(DomaineImporter)
    referentielService = new ReferentielService(
        domaineImporter: domaineImporter
    )

    mockDomain(Referentiel)
    mockDomain(ReferentielIdExterne)
  }

  def "testImporteReferentiel"(int nbDomaine) {
    given:
    String referentielNom = "nom"
    String referentielDescription = "description"
    String version = "version"
    String dateVersion = "dateVersion"
    String idExterne = "idExterne"

    List<DomaineDto> allDomaineDto = []
    nbDomaine.times {
      allDomaineDto << new DomaineDto(nom: "domaine $it")
    }

    ReferentielDto referentielDto = new ReferentielDto(
        nom: referentielNom,
        description: referentielDescription,
        allDomaine: allDomaineDto,
        version: version,
        dateVersion: dateVersion,
        idExterne: idExterne,
        sourceReferentiel: SourceReferentiel.EMA_EVAL
    )

    when:
    Referentiel referentiel = referentielService.importeReferentiel(referentielDto)

    then:
    interaction {
      allDomaineDto.each { DomaineDto domaineDto ->
        1 * domaineImporter.importeDomaine(_, null, domaineDto) >> new Domaine(
            nom: domaineDto.nom
        )
      }
    }


    referentiel.nom == referentielNom
    referentiel.description == referentielDescription
    referentiel.dateVersion == referentielDto.dateVersion
    referentiel.referentielVersion == referentielDto.version

    referentiel.idExterneList.size() == 1
    referentiel.idExterneList.every {
      assert it.idExterne == idExterne
      assert it.sourceReferentiel == SourceReferentiel.EMA_EVAL
      return true
    }

    if(nbDomaine == 0) {
      assert !referentiel.allDomaine
    }
    else {
      referentiel.allDomaine.size() == nbDomaine
      // On vérifie qu'un domaine a bien été ajouté dans le référentiel pour chaque DomaineDto
      allDomaineDto.each { DomaineDto domaineDto ->
        assert referentiel.allDomaine.find { Domaine domaine ->
          return domaine.nom == domaineDto.nom
        }
      }
    }

    where:
    nbDomaine << [0, 1, 2]
  }
}
