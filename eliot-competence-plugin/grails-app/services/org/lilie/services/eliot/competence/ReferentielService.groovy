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

import org.hibernate.FetchMode

/**
 * Service de gestion des référentiels de compétences d'Eliot
 *
 * @author John Tranier
 */
class ReferentielService {

  static transactional = true

  @SuppressWarnings('GrailsStatelessService') // singleton
  DomaineImporter domaineImporter

  /**
   * Importe un référentiel de compétence
   * @param referentielDto description du référentiel à importer
   * @return le référentiel créé en base
   */
  Referentiel importeReferentiel(ReferentielDto referentielDto) {
    assert referentielDto

    Referentiel referentiel = new Referentiel(
        nom: referentielDto.nom,
        description: referentielDto.description,
        referentielVersion: referentielDto.version,
        dateVersion: referentielDto.dateVersion,
        urlReference: referentielDto.urlReference
    )

    if (referentielDto.idExterne && referentielDto.sourceReferentiel) {
      referentiel.addToIdExterneList(
          new ReferentielIdExterne(
              idExterne: referentielDto.idExterne,
              sourceReferentiel: referentielDto.sourceReferentiel
          )
      )
    }

    referentiel.save(flush: true, failOnError: true)

    referentielDto.allDomaine.each { DomaineDto domaineDto ->
      Domaine domaine = domaineImporter.importeDomaine(referentiel, null, domaineDto)
      referentiel.addToAllDomaine(domaine)
    }

    referentiel.save(flush: true, failOnError: true)
    return referentiel
  }

  /**
   * Récupère un référentiel par son nom
   *
   * Note : cette méthode fetche l'ensemble du contenu du référentiel.
   * Il est donc possible de parcourir l'ensemnble des domaines et des compétences du
   * référentiel à partir de l'objet Referentiel retourné sans générer de nouvelles
   * requêtes en base
   *
   * @param nom nom du référentiel
   * @return
   */
  Referentiel fetchReferentielByNom(String nom) {

    def c = Referentiel.createCriteria()
    Referentiel referentiel = c.get {
      eq('nom', nom)
      fetchMode('allDomaine', FetchMode.JOIN)
      fetchMode('allDomaine.allSousDomaine', FetchMode.JOIN)
      fetchMode('allDomaine.allCompetence', FetchMode.JOIN)
    }

    if (!referentiel) {
      throw new IllegalStateException("Le référentiel $nom n'existe pas")
    }

    return referentiel
  }

  /**
   * Récupère un référentiel par son id
   *
   * Note : cette méthode fetche l'ensemble du contenu du référentiel.
   * Il est donc possible de parcourir l'ensemnble des domaines et des compétences du
   * référentiel à partir de l'objet Referentiel retourné sans générer de nouvelles
   * requêtes en base
   *
   * @param nom nom du référentiel
   * @return
   */
  Referentiel fetchReferentielById(Long id) {

    def c = Referentiel.createCriteria()
    Referentiel referentiel = c.get {
      eq('id', id)
      fetchMode('allDomaine', FetchMode.JOIN)
      fetchMode('allDomaine.allSousDomaine', FetchMode.JOIN)
      fetchMode('allDomaine.allCompetence', FetchMode.JOIN)
    }

    if (!referentiel) {
      throw new IllegalStateException("Le référentiel d'id $id n'existe pas")
    }

    return referentiel
  }
}

/**
 * Permet d'importer un domaine dans un référentiel
 *
 * Note : cette classe n'est pas un service car elle ne prend pas en charge la persistance
 * Elle se contente d'attacher le domaine (et tout son contenu) à un référentiel.
 * La persistence en base reste à la charge de l'appelant (le domaine persistera à
 * l'enregistrement du référentiel)
 *
 * @author John Tranier
 */
class DomaineImporter {

  CompetenceImporter competenceImporter

  Domaine importeDomaine(Referentiel referentiel,
                         Domaine domaineParent,
                         DomaineDto domaineDto) {

    Domaine domaine = new Domaine(
        referentiel: referentiel,
        domaineParent: domaineParent,
        nom: domaineDto.nom,
        description: domaineDto.description
    )

    if(domaineDto.idExterne && domaineDto.sourceReferentiel) {
      domaine.addToIdExterneList(
          new DomaineIdExterne(
              idExterne: domaineDto.idExterne,
              sourceReferentiel: domaineDto.sourceReferentiel
          )
      )
    }
    domaine.save(flush: true, failOnError: true)

    domaineDto.allSousDomaine.each { DomaineDto sousDomaineDto ->
      Domaine sousDomaine = importeDomaine(referentiel, domaine, sousDomaineDto)
      domaine.addToAllSousDomaine(sousDomaine)
    }

    domaineDto.allCompetence.each { CompetenceDto competenceDto ->
      Competence competence = competenceImporter.importeCompetence(domaine, competenceDto)
      domaine.addToAllCompetence(competence)
    }

    return domaine
  }
}

/**
 * Permet d'importer une compétence dans un domaine
 *
 * Note : cette classe n'est pas un service car elle ne prend pas en charge la persistance
 * La compétence persistera en base à l'enregistrement du domaine (lui-même étant dépendant
 * de l'enregistrement de son référentiel)
 *
 * @author John Tranier
 */
class CompetenceImporter {

  Competence importeCompetence(Domaine domaine, CompetenceDto competenceDto) {
    Competence competence = new Competence(
        domaine: domaine,
        referentiel: domaine.referentiel,
        nom: competenceDto.nom,
        description: competenceDto.description
    )

    if(competenceDto.idExterne && competenceDto.sourceReferentiel) {
      competence.addToIdExterneList(
          new CompetenceIdExterne(
              idExterne: competenceDto.idExterne,
              sourceReferentiel: competenceDto.sourceReferentiel)
      )
    }

    competence.save(flush: true, failOnError: true)

    return competence
  }
}
