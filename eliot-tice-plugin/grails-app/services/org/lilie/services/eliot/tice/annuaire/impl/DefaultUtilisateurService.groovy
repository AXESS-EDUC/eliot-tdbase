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

/**
 * @author franck silvestre
 */
package org.lilie.services.eliot.tice.annuaire.impl

import org.hibernate.SessionFactory
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.securite.acl.TypeAutorite
import org.springframework.transaction.annotation.Transactional
import org.hibernate.metadata.ClassMetadata
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.UtilisateurService
import org.lilie.services.eliot.tice.securite.CompteUtilisateur

/**
 * Classe de service pour gestion les utilisateurs
 */
class DefaultUtilisateurService implements UtilisateurService{

  static transactional = false

  SessionFactory sessionFactory

  /**
   * Creer un nouvel utilisateur
   * @param login le login de l'utilisateur
   * @param password le mot de passe de l'utilisateur
   * @param nom le nom de l'utilisateur
   * @param prenom le prenom de l'utilisateur
   * @param email l'email de l'utilisateur
   * @param dateNaissance la date de naissance de l'utilisateur
   * @return le nouvel utilisateur
   */
  @Transactional
  Utilisateur createUtilisateur(
          String login,
          String password,
          String nom,
          String prenom,
          String email = null,
          Date dateNaissance = null) {

    // cree l'autorite
    String nomEntiteCible = personneNomEntite
    DomainAutorite domainAutorite = new DomainAutorite(
            identifiant: "${nomEntiteCible}.login",
            estActive: true,
            type: TypeAutorite.PERSONNE.libelle
    ).save(failOnError: true)

    // cree la personne
    Personne personne = new Personne(
            nom: nom,
            prenom: prenom,
            email: email,
            dateNaissance: dateNaissance,
            autorite: domainAutorite
    ).save(failOnError: true)

    // finit la mise à jour de l'autorite
    domainAutorite.nomEntiteCible = personneNomEntite
    domainAutorite.idEnregistrementCible = personne.id
    domainAutorite.save(failOnError: true)

    // cree le compte utilisateur
    CompteUtilisateur compteUtilisateur = new CompteUtilisateur(
            login: login,
            password: password,
            compteActive: true,
            compteVerrouille: false,
            passwordExpire: false,
            compteExpire: false,
            personne: personne
    ).save(failOnError:true, flush:true)


    // cree l'utilisateur retourné
    Utilisateur utilisateur = new Utilisateur(
            login: login,
            compteActive: true,
            compteVerrouille: false,
            compteExpire: false,
            passwordExpire: false,
            nom: nom,
            prenom: prenom,
            email: email,
            dateNaissance: dateNaissance,
            compteUtilisateurId: compteUtilisateur.id,
            personneId: personne.id,
            autoriteId: domainAutorite.id
    )

    return utilisateur

  }

  private getPersonneNomEntite() {
    ClassMetadata metaData = sessionFactory.getClassMetadata(Personne.class)
    metaData.tableName
  }
}
