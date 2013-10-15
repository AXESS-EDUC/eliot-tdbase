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

import com.pentila.emawsconnector.manager.EvaluationObjectManager
import com.pentila.emawsconnector.utils.EmaWSConnector
import com.pentila.evalcomp.domain.definition.Referentiel as EmaEvalReferentiel
import org.codehaus.groovy.grails.commons.GrailsApplication
import org.lilie.services.eliot.competence.Referentiel as EliotReferentiel
import org.lilie.services.eliot.competence.ReferentielService
import org.lilie.services.eliot.competence.SourceReferentiel
import org.lilie.services.eliot.tdbase.emaeval.emawsconnector.ReferentielMarshaller
import org.springframework.transaction.annotation.Transactional

/**
 * Service de gestion de la liaison EmaEval
 *
 * @author John Tranier
 */
class EmaEvalService {

  static transactional = false

  final static REFERENTIEL_PALIER_3_NOM = "Palier 3"

  @SuppressWarnings('GrailsStatelessService') // singleton
  GrailsApplication grailsApplication
  ReferentielService referentielService

  @SuppressWarnings('GrailsStatelessService') // singleton
  ReferentielMarshaller emaEvalReferentielMarshaller

  /**
   * Importe un référentiel obtenu par les WS d'EmaEval dans la base de référentiel d'Eliot
   * @param emaEvalReferentiel
   */
  @Transactional
  void importeReferentielDansEliot(EmaEvalReferentiel emaEvalReferentiel) {
    referentielService.importeReferentiel(
        emaEvalReferentielMarshaller.parseReferentiel(emaEvalReferentiel)
    )
  }

  /**
   * @return Le référentiel "Palier 3" dans la base de référentiel d'Eliot
   */
  EliotReferentiel getEliotReferentielPalier3() {

    EliotReferentiel referentiel = (EliotReferentiel)EliotReferentiel.withCriteria(uniqueResult: true) {
      eq('nom', REFERENTIEL_PALIER_3_NOM)
      idExterneList {
        eq('sourceReferentiel', SourceReferentiel.EMA_EVAL)
      }
    }

    return referentiel
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

  /**
   * Récupère, par webservice, un référentiel EmaEval correspondant à un référentiel Eliot
   * @param eliotReferentiel
   * @return
   */
  EmaEvalReferentiel findEmaEvalReferentielByEliotReferentiel(EliotReferentiel eliotReferentiel) {
    String idExterne = eliotReferentiel.getIdExterne(SourceReferentiel.EMA_EVAL)
    if(!idExterne) {
      throw new IllegalStateException(
          "Le référentiel Eliot ${eliotReferentiel.id} n'est pas rattaché à un identifiant " +
              "externe pour la source EmaEval"
      )
    }

    return findEmaEvalReferentielById(Long.parseLong(idExterne))
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



