/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 *  This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
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
 *   <http://www.gnu.org/licenses/> and
 *   <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tdbase.emaeval

import com.pentila.evalcomp.domain.definition.Referentiel as EmaEvalReferentiel
import grails.plugin.spock.UnitSpec
import org.lilie.services.eliot.competence.Referentiel as EliotReferentiel
import org.lilie.services.eliot.competence.ReferentielDto
import org.lilie.services.eliot.competence.ReferentielIdExterne
import org.lilie.services.eliot.competence.ReferentielService
import org.lilie.services.eliot.competence.SourceReferentiel
import org.lilie.services.eliot.tdbase.emaeval.emawsconnector.ReferentielMarshaller

/**
 * @author John Tranier
 */
class EmaEvalServiceSpec extends UnitSpec {
  EmaEvalService emaEvalService
  ReferentielService referentielService
  ReferentielMarshaller referentielMarshaller

  void setup() {
    referentielMarshaller = Mock(ReferentielMarshaller)
    referentielService = Mock(ReferentielService)
    emaEvalService = new EmaEvalService(
        referentielService: referentielService,
        emaEvalReferentielMarshaller: referentielMarshaller
    )
  }

  def "testImporteReferentielDansEliot"() {
    given:
    EmaEvalReferentiel emaEvalReferentiel = new EmaEvalReferentiel()
    ReferentielDto eliotReferentielDto = new ReferentielDto()

    referentielMarshaller.parseReferentiel(emaEvalReferentiel) >> eliotReferentielDto

    when:
    emaEvalService.importeReferentielDansEliot(emaEvalReferentiel)

    then:
    1 * referentielService.importeReferentiel(eliotReferentielDto)
  }

  def "testVerifieCorrespondanceReferentiel - OK"() {
    given:
    String nom = 'nom'
    String version = 'version'

    EliotReferentiel eliotReferentiel = new EliotReferentiel(
        nom: nom,
        referentielVersion: version
    )

    EmaEvalReferentiel emaEvalReferentiel = new EmaEvalReferentiel(
        name: nom,
        version: version
    )

    when:
    emaEvalService.verifieCorrespondanceReferentiel(eliotReferentiel, emaEvalReferentiel)

    then:
    notThrown(Throwable)
  }

  def "testVerifieCorrespondanceReferentiel - erreur : noms différents"() {
    given:
    String nom = 'nom'
    String version = 'version'

    EliotReferentiel eliotReferentiel = new EliotReferentiel(
        nom: nom,
        referentielVersion: version,
        idExterneList: [
            new ReferentielIdExterne(
                idExterne: '1',
                sourceReferentiel: SourceReferentiel.EMA_EVAL
            )
        ] as Set
    )

    EmaEvalReferentiel emaEvalReferentiel = new EmaEvalReferentiel(
        name: nom + ' modifié',
        version: version
    )

    when:
    emaEvalService.verifieCorrespondanceReferentiel(eliotReferentiel, emaEvalReferentiel)

    then:
    thrown(IllegalStateException)
  }

  def "testVerifieCorrespondanceReferentiel - erreur : versions différentes"() {
    given:
    String nom = 'nom'
    String version = 'version'

    EliotReferentiel eliotReferentiel = new EliotReferentiel(
        nom: nom,
        referentielVersion: version
    )

    EmaEvalReferentiel emaEvalReferentiel = new EmaEvalReferentiel(
        name: nom,
        version: version + ' modifiée'
    )

    when:
    emaEvalService.verifieCorrespondanceReferentiel(eliotReferentiel, emaEvalReferentiel)

    then:
    thrown(IllegalStateException)
  }
}
