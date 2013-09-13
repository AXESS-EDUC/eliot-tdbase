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

import grails.plugin.spock.IntegrationSpec

/**
 * @author John Tranier
 */
class ReferentielServiceIntegrationSpec extends IntegrationSpec {

  ReferentielService referentielService

  /**
   * Une validation exhaustive de l'import est réalisée par les différents tests unitaires
   * Ce test a uniquement vocation à valider
   *
   * @author John Tranier
   */
  def testImporteReferentiel() {
    given:
    int nbDomaineRacine = 3
    int nbSousDomaineParDomaine = 2
    int nbCompetenceParSousDomaine = 3

    ReferentielDto referentielDto = genereReferentielDto(
        'test',
        nbDomaineRacine,
        nbCompetenceParSousDomaine,
        nbSousDomaineParDomaine
    )

    when:
    referentielService.importeReferentiel(referentielDto)

    then:
    Referentiel referentiel = Referentiel.findByNom(referentielDto.nom)
    referentiel.allDomaine.size() == nbDomaineRacine
    referentiel.allDomaine.each { Domaine domaine ->
      assert !domaine.allCompetence
      assert domaine.allSousDomaine.size() == nbSousDomaineParDomaine
      assert domaine.allSousDomaine.every { Domaine sousDomaine ->
        !sousDomaine.allSousDomaine &&
            sousDomaine.allCompetence.size() == 3
      }
    }

  }

  private ReferentielDto genereReferentielDto(String referentielNom,
                                              int nbDomaineRacine,
                                              nbCompetenceParSousDomaine,
                                              nbSousDomaineParDomaine) {
    Collection<DomaineDto> allDomaineRacine = []
    nbDomaineRacine.times { int numDomaineRacine ->

      DomaineDto domaineRacineDto = new DomaineDto(
          nom: "domaineRacine $numDomaineRacine"
      )

      nbSousDomaineParDomaine.times { int numSousDomaine ->
        DomaineDto sousDomaineDto = new DomaineDto(
            nom: "sous domaine ${numDomaineRacine}.${numSousDomaine}"
        )

        nbCompetenceParSousDomaine.times { int numCompetence ->
          CompetenceDto competenceDto = new CompetenceDto(
              nom: "compétence ${numDomaineRacine}.${numSousDomaine}.${numCompetence}"
          )

          sousDomaineDto.allCompetence << competenceDto
        }


        domaineRacineDto.allSousDomaine << sousDomaineDto
      }

      allDomaineRacine << domaineRacineDto
    }

    String referentielDescription = "description $referentielNom"

    return new ReferentielDto(
        nom: referentielNom,
        description: referentielDescription,
        allDomaine: allDomaineRacine
    )
  }

  def "testFetchReferentielByNom - OK"() {
    given:
    String referentielNom = 'test'
    ReferentielDto referentielDto = genereReferentielDto(
        referentielNom,
        2,
        2,
        2
    )
    referentielService.importeReferentiel(referentielDto)

    expect:
    referentielService.fetchReferentielByNom(referentielNom).nom == referentielNom
  }

  def "testFetchReferentielByNom - erreur : référentiel inexistant"() {
    given:
    String referentielNom = 'inexistant'
    when:
    referentielService.fetchReferentielByNom(referentielNom)

    then:
    def e = thrown(IllegalStateException)
    e.message.startsWith("Le référentiel $referentielNom n'existe pas")
  }
}
