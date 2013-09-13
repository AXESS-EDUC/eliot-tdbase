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
class DomaineImporterSpec extends UnitSpec {
  CompetenceImporter competenceImporter
  DomaineImporter domaineImporter

  def setup() {
    competenceImporter = Mock(CompetenceImporter)
    domaineImporter = new DomaineImporter(
        competenceImporter: competenceImporter
    )

    mockDomain(Domaine)
  }

  def "testImporteDomaine"(Domaine domaineParent, int nbSousDomaine, int nbCompetence) {
    given:
    Referentiel referentiel = new Referentiel()

    String domaineNom = "nom"
    String domaineDescription = "description"

    List<DomaineDto> allSousDomaineDto = []
    nbSousDomaine.times {
      allSousDomaineDto << new DomaineDto(
          nom: "sous-domaine $it",
          description: "description sous-domaine $it"
      )
    }

    List<CompetenceDto> allCompetenceDto = []
    nbCompetence.times {
      allCompetenceDto << new CompetenceDto(
          nom: "competence $it"
      )
    }

    DomaineDto domaineDto = new DomaineDto(
        nom: domaineNom,
        description: domaineDescription,
        allSousDomaine: allSousDomaineDto,
        allCompetence: allCompetenceDto
    )

    // Note d'implémentation
    // L'approche suivante a été mise en place pour tester le comportement récursif
    // de la méthode :
    //  - Un Mock de DomaineImporter est créé pour recevoir et valider tous les appels récursifs
    //  - La méthode importeDomaine est surchargée au niveau de la métaclasse de telle sorte que
    //     + L'appel initial est envoyé à la méthode originale
    //     + Les appels suivants (les appels récursifs) sont transmis au mock

    DomaineImporter mockDomaineImporter = Mock(DomaineImporter)

    def originalMethodeImporteDomaine = DomaineImporter.metaClass.getMetaMethod(
        "importeDomaine",
        [Referentiel, Domaine, DomaineDto] as Class[]
    )

    domaineImporter.metaClass.importeDomaine = {
      Referentiel paramReferentiel, Domaine paramDomaineParent, DomaineDto paramDomaineDto ->
        if (paramDomaineDto == domaineDto) {
          originalMethodeImporteDomaine.invoke(
              delegate,
              [paramReferentiel, paramDomaineParent, paramDomaineDto] as Object[]
          )
        } else {
          mockDomaineImporter.importeDomaine(
              paramReferentiel,
              paramDomaineParent,
              paramDomaineDto
          )
        }
    }

    when:
    Domaine domaine = domaineImporter.importeDomaine(
        referentiel,
        domaineParent,
        domaineDto
    )

    then:
    interaction {
      allSousDomaineDto.each { DomaineDto sousDomaineDto ->
        1 * mockDomaineImporter.importeDomaine(
            referentiel,
            _ as Domaine,
            sousDomaineDto
        ) >> new Domaine(nom: sousDomaineDto.nom)
      }
    }

    interaction {
      allCompetenceDto.each { CompetenceDto competenceDto ->
        1 * competenceImporter.importeCompetence(
            _ as Domaine,
            competenceDto
        ) >> new Competence(nom: competenceDto.nom)
      }
    }
    domaine.nom == domaineNom
    domaine.description == domaineDescription
    domaine.referentiel == referentiel
    domaine.domaineParent == domaineParent

    if (nbCompetence == 0) {
      assert !domaine.allCompetence
    } else {
      // On vérifie qu'une compétence a bien été ajoutée dans le domaine pour chaque competenceDto
      allCompetenceDto.each { CompetenceDto competenceDto ->
        assert domaine.allCompetence.find { Competence competence ->
          return competence.nom == competenceDto.nom
        }
      }
    }

    cleanup:
    domaineImporter.metaClass.importeDomaine = null

    where:
    domaineParent << [null, new Domaine()]
    nbSousDomaine << [0, 2]
    nbCompetence << [0, 2]
  }
}
