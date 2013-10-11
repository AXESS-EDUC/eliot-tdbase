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

import com.pentila.emawsconnector.manager.EvaluationObjectManager
import com.pentila.emawsconnector.utils.EmaWSConnector
import com.pentila.evalcomp.domain.definition.Competence
import com.pentila.evalcomp.domain.definition.Domain
import com.pentila.evalcomp.domain.definition.Referentiel as EmaEvalReferentiel
import org.codehaus.groovy.grails.commons.GrailsApplication
import org.lilie.services.eliot.competence.CompetenceDto
import org.lilie.services.eliot.competence.DomaineDto
import org.lilie.services.eliot.competence.Referentiel as EliotReferentiel
import org.lilie.services.eliot.competence.ReferentielDto
import org.lilie.services.eliot.competence.ReferentielService
import org.lilie.services.eliot.competence.SourceReferentiel
import org.springframework.transaction.annotation.Transactional

/**
 * Service de gestion de la liaison EmaEval
 *
 * @author John Tranier
 */
class EmaEvalService {

  static transactional = false

  final static REFERENTIEL_PALIER_3_NOM = "Palier 3"

  GrailsApplication grailsApplication
  ReferentielService referentielService

  /**
   * Importe un référentiel obtenu par les WS d'EmaEval dans la base de référentiel d'Eliot
   * @param emaEvalReferentiel
   */
  @Transactional
  void importeReferentielDansEliot(EmaEvalReferentiel emaEvalReferentiel) {
    referentielService.importeReferentiel(parseReferentiel(emaEvalReferentiel))
  }

  /**
   * Converti un référentiel EmaEval dans un ReferentielDto d'Eliot
   * @param emaEvalReferentiel
   * @return
   */
  private ReferentielDto parseReferentiel(EmaEvalReferentiel emaEvalReferentiel) {
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

  /**
   * @return Le référentiel "Palier 3" dans la base de référentiel d'Eliot
   */
  EliotReferentiel getEliotReferentielPalier3() {
    return EliotReferentiel.findByNom(REFERENTIEL_PALIER_3_NOM) // TODO il faut fetcher l'idExterne
  }

  /**
   * Récupère un référentiel EmaEval à partir de son nom en effectuant un appel aux
   * webservices d'EmaEval
   * @param name
   * @return
   */
  EmaEvalReferentiel findEmaEvalReferentielByName(String name) {
    assert grailsApplication.config.eliot.interfacage.emaeval.actif

    String url = grailsApplication.config.eliot.interfacage.emaeval.url
    EmaWSConnector emaWSConnector = new EmaWSConnector(url, 'xml', 'login') // Apparemment le webservice getAllReferentiels ne nécessite pas de login spécifique
    EvaluationObjectManager evaluationObjectManager = new EvaluationObjectManager(emaWSConnector)

    return evaluationObjectManager.allReferentiels.find { EmaEvalReferentiel emaEvalReferentiel ->
      emaEvalReferentiel.name == name
    }
  }

  EmaEvalReferentiel findEmaEvalReferentielByEliotReferentiel(EliotReferentiel eliotReferentiel) {
    return findEmaEvalReferentielById(
        Long.parseLong(eliotReferentiel.getIdExterne(SourceReferentiel.EMA_EVAL))
    )
  }

  /**
   * Récupère un référentiel EmaEval à partir de son ID en effectuant un appel aux
   * webservices d'EmaEval
   * @param id
   * @return
   */
  EmaEvalReferentiel findEmaEvalReferentielById(Long id) {
    assert grailsApplication.config.eliot.interfacage.emaeval.actif

    String url = grailsApplication.config.eliot.interfacage.emaeval.url
    EmaWSConnector emaWSConnector = new EmaWSConnector(url, 'xml', 'login') // Apparemment le webservice getAllReferentiels ne nécessite pas de login spécifique
    EvaluationObjectManager evaluationObjectManager = new EvaluationObjectManager(emaWSConnector)
    return evaluationObjectManager.getReferentiel(id)
  }

  /**
   * Vérifie la correspondance entre le référentiel Eliot et le référentiel EmaEval
   *
   * La vérification de la correspondance est effectuée en vérifiant :
   *  - que les 2 référentiels portent le même nom
   *  - que les 2 référentiels portent la même version
   *
   */
  void verifieCorrespondanceReferentiel(EliotReferentiel eliotReferentiel,
                                        EmaEvalReferentiel emaEvalReferentiel) {

      if (emaEvalReferentiel.name != eliotReferentiel.nom) {
        throw new IllegalStateException(
            """
          Dans la base eliot-scolarité, le référentiel "${eliotReferentiel.nom}" est associé au
          référentiel d'id ${eliotReferentiel.getIdExterne(SourceReferentiel.EMA_EVAL)} dans EmaEval.
          Le nom du référentiel retourné par EmaEval ne correspond pas (${emaEvalReferentiel.name}).
          """
        )
      }

      if (emaEvalReferentiel.version != eliotReferentiel.referentielVersion) {
        throw new IllegalStateException(
            """
          Les versions du référentiel "${eliotReferentiel.nom}" ne correspondent pas
          (Eliot : ${eliotReferentiel.referentielVersion}, EmaEval: ${emaEvalReferentiel.version}).
          """
        )
      }
  }
}



