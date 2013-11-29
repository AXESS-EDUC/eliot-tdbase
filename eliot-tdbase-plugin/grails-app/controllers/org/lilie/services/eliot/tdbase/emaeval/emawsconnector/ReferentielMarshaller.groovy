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

package org.lilie.services.eliot.tdbase.emaeval.emawsconnector

import com.pentila.evalcomp.domain.definition.Competence
import com.pentila.evalcomp.domain.definition.Domain
import com.pentila.evalcomp.domain.definition.Referentiel
import org.lilie.services.eliot.competence.CompetenceDto
import org.lilie.services.eliot.competence.DomaineDto
import org.lilie.services.eliot.competence.ReferentielDto
import org.lilie.services.eliot.competence.SourceReferentiel

/**
 * Permet de convertir un Refentiel fournit par le connecteur aux webservices d'EmaEval
 * en un ReferentielDto d'Eliot
 *
 * @author John Tranier
 */
class ReferentielMarshaller {

  /**
   * Converti un référentiel EmaEval dans un ReferentielDto d'Eliot
   * @param emaEvalReferentiel
   * @return
   */
  ReferentielDto parseReferentiel(Referentiel emaEvalReferentiel) {
    return new ReferentielDto(
        nom: emaEvalReferentiel.name,
        description: emaEvalReferentiel.description,
        idExterne: emaEvalReferentiel.id,
        sourceReferentiel: SourceReferentiel.EMA_EVAL,
        version: emaEvalReferentiel.version,
        dateVersion: emaEvalReferentiel.dateVersion,
        urlReference: emaEvalReferentiel.reference,
        allDomaine: emaEvalReferentiel.domains.collect { parseDomaine(it) }
    )
  }

  /**
   * Converti un Domain d'EmaEval dans un DomainDto d'Eliot
   * @param emaEvalDomain
   * @return
   */
  private DomaineDto parseDomaine(Domain emaEvalDomain) {
    return new DomaineDto(
        nom: emaEvalDomain.name,
        description: emaEvalDomain.description,
        idExterne: emaEvalDomain.id,
        sourceReferentiel: SourceReferentiel.EMA_EVAL,
        allSousDomaine: emaEvalDomain.domains.collect { parseDomaine(it) },
        allCompetence: emaEvalDomain.competences.collect { parseCompetence(it) }
    )
  }

  /**
   * Converti une Competence d'EmaEval dans un CompetenceDto d'Eliot
   * @param emaEvalCompetence
   * @return
   */
  private CompetenceDto parseCompetence(Competence emaEvalCompetence) {
    return new CompetenceDto(
        nom: emaEvalCompetence.name,
        description: emaEvalCompetence.description,
        idExterne: emaEvalCompetence.id,
        sourceReferentiel: SourceReferentiel.EMA_EVAL
    )
  }
}
