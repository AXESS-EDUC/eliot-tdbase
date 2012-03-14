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

import grails.plugins.springsecurity.SpringSecurityService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.UtilisateurService
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.securite.CompteUtilisateur
import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.securite.acl.TypeAutorite
import org.lilie.services.eliot.tice.utils.StringUtils
import org.springframework.security.core.GrantedAuthority
import org.springframework.transaction.annotation.Transactional

/**
 * Classe de service pour gestion les utilisateurs
 */
class DefaultUtilisateurService implements UtilisateurService {

  static transactional = false

  SpringSecurityService springSecurityService

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
            identifiant: "${nomEntiteCible}.${login}",
            estActive: true,
            type: TypeAutorite.PERSONNE.libelle
    ).save(failOnError: true)

    // cree la personne
    Personne personne = new Personne(
            nom: nom,
            prenom: prenom,
            email: email,
            dateNaissance: dateNaissance,
            autorite: domainAutorite,
            nomNormalise: StringUtils.normalise(nom),
            prenomNormalise: StringUtils.normalise(prenom)
    ).save(failOnError: true)

    // finit la mise à jour de l'autorite
    domainAutorite.nomEntiteCible = personneNomEntite
    domainAutorite.idEnregistrementCible = personne.id
    domainAutorite.save(failOnError: true)

    // cree le compte utilisateur
    String encodedPassword = springSecurityService.encodePassword(
            password, login)
    CompteUtilisateur compteUtilisateur = new CompteUtilisateur(
            login: login,
            password: encodedPassword,
            compteActive: true,
            compteVerrouille: false,
            passwordExpire: false,
            compteExpire: false,
            personne: personne
    ).save(failOnError: true, flush: true)

    return utilisateurForCompteUtilisateur(compteUtilisateur)

  }

  /**
   * @see UtilisateurService
   */
  @Transactional
  Utilisateur findUtilisateur(String login) {
    if (!login) {
      return null
    }
    // cherche le compte utilisateur avec personne et autorite associée
    def criteria = CompteUtilisateur.createCriteria()
    CompteUtilisateur compteUtilisateur = criteria.get {
      or {
        eq 'login', login
        eq 'loginAlias', login
      }
      join 'personne'
      join 'personne.autorite'
    }
    if (!compteUtilisateur) {
      return null
    }

    return utilisateurForCompteUtilisateur(compteUtilisateur)
  }

  /**
   *
   * @see UtilisateurService
   */
  void setAliasLogin(String login, String aliasLogin) {
    if (!login) {
      throw new IllegalStateException(
              "annuaire.login_null_ou_vide")
    }
    // cherche le compte utilisateur
    CompteUtilisateur compteUtilisateur = CompteUtilisateur.findByLogin(login)
    if (compteUtilisateur == null) {
      throw new IllegalStateException(
              "annuaire.no_user_avec_login : ${login}")
    }

    String oldLoginAlias = compteUtilisateur.loginAlias

    // un login ou un alias correspondant à l'alias
    CompteUtilisateur compteUtilisateur2 = CompteUtilisateur.findByLoginOrLoginAlias(
            aliasLogin,
            aliasLogin)
    if (compteUtilisateur2) {
      throw new IllegalStateException(
              "annuaire.alias_login_deja_utilise : ${aliasLogin}")
    }

    compteUtilisateur.loginAlias = aliasLogin
    compteUtilisateur.save(failOnError: true)

    // reverifie unicité login/loginAlias correspondant à l'alias
    List<CompteUtilisateur> comptes = CompteUtilisateur.findAllByLoginOrLoginAlias(
            aliasLogin,
            aliasLogin)

    if (comptes.size() > 1) {
      compteUtilisateur.loginAlias = oldLoginAlias
      compteUtilisateur.save(failOnError: true)
      throw new IllegalStateException(
              "annuaire.alias_login_deja_utilise : ${aliasLogin}")
    }

  }

  /**
   *
   * @see UtilisateurService
   */
  Utilisateur desactiveUtilisateur(String login) {
    if (!login) {
      throw new IllegalStateException(
              "annuaire.login_null_ou_vide")
    }

    // cherche le compte utilisateur avec personne et autorite associée
    def criteria = CompteUtilisateur.createCriteria()
    CompteUtilisateur compteUtilisateur = criteria.get {
      or {
        eq 'login', login
      }
      join 'personne'
      join 'personne.autorite'
    }
    if (compteUtilisateur == null) {
      throw new IllegalStateException(
              "annuaire.no_user_avec_login : ${login}")
    }

    compteUtilisateur.compteActive = false
    compteUtilisateur.save(failOnError: true)

    return utilisateurForCompteUtilisateur(compteUtilisateur)

  }

  /**
   *
   * @see UtilisateurService
   */
  Utilisateur reactiveUtilisateur(String login) {
    if (!login) {
      throw new IllegalStateException(
              "annuaire.login_null_ou_vide")
    }

    // cherche le compte utilisateur avec personne et autorite associée
    def criteria = CompteUtilisateur.createCriteria()
    CompteUtilisateur compteUtilisateur = criteria.get {
      or {
        eq 'login', login
      }
      join 'personne'
      join 'personne.autorite'
    }
    if (compteUtilisateur == null) {
      throw new IllegalStateException(
              "annuaire.no_user_avec_login : ${login}")
    }

    if (compteUtilisateur.compteActive == false) {
      compteUtilisateur.compteActive = true
      compteUtilisateur.save(failOnError: true)
    }

    return utilisateurForCompteUtilisateur(compteUtilisateur)
  }

  /**
   *
   * @see UtilisateurService
   */
  @Transactional
  Utilisateur updateUtilisateur(String login, Utilisateur utilisateur) {
    if (!login) {
      throw new IllegalStateException(
              "annuaire.login_null_ou_vide")
    }

    // cherche le compte utilisateur avec personne et autorite associée
    def criteria = CompteUtilisateur.createCriteria()
    CompteUtilisateur compteUtilisateur = criteria.get {
      or {
        eq 'login', login
      }
      join 'personne'
      join 'personne.autorite'
    }
    if (compteUtilisateur == null) {
      throw new IllegalStateException(
              "annuaire.no_user_avec_login : ${login}")
    }
    String encodedPassword = springSecurityService.encodePassword(
            utilisateur.password, login)
    if (compteUtilisateur.password != encodedPassword) {
      compteUtilisateur.password = encodedPassword
      compteUtilisateur.save(failOnError: true)
    }
    Personne personne = compteUtilisateur.personne
    if (personne.nom != utilisateur.nom) {
      personne.nom = utilisateur.nom
      personne.nomNormalise = StringUtils.normalise(utilisateur.nom)
    }
    if (personne.prenom != utilisateur.prenom) {
      personne.prenom = utilisateur.prenom
      personne.prenomNormalise = StringUtils.normalise(utilisateur.prenom)
    }
    if (personne.email != utilisateur.email) {
      personne.email = utilisateur.email
    }
    if (personne.dateNaissance != utilisateur.dateNaissance) {
      personne.dateNaissance = utilisateur.dateNaissance
    }
    personne.save(failOnError: true)

    return utilisateurForCompteUtilisateur(compteUtilisateur)
  }

  /**
   *
   * @see UtilisateurService
   */
  List<Utilisateur> findUtilisateurs(String patternNom,
                                     String patternPrenom,
                                     Date dateAvantNaissance,
                                     Date dateApresNaissance,
                                     Map paginationAndSortingSpec = null) {
    def criteria = CompteUtilisateur.createCriteria()
    List<CompteUtilisateur> compteUtilisateurs = criteria.list {
      personne {
        if (patternNom) {
          like "nomNormalise", "%${StringUtils.normalise(patternNom)}%"
        }
        if (patternPrenom) {
          like "prenomNormalise", "%${StringUtils.normalise(patternPrenom)}%"
        }
        if (dateAvantNaissance) {
          ge "dateNaissance", dateAvantNaissance
        }
        if (dateApresNaissance) {
          le "dateNaissance", dateApresNaissance
        }
        if (paginationAndSortingSpec) {
          def sortArg = paginationAndSortingSpec['sort'] ?: 'nom'
          def orderArg = paginationAndSortingSpec['order'] ?: 'asc'
          if (sortArg) {
            order "${sortArg}", orderArg
          }
        }
      }
      if (paginationAndSortingSpec) {
        def maxArg = paginationAndSortingSpec['max']
        if (maxArg) {
          maxResults maxArg
        }
        def offsetArg = paginationAndSortingSpec['offset']
        if (offsetArg) {
          firstResult offsetArg
        }
      }
    }
    def utilisateurs = []
    for (CompteUtilisateur compteUtilisateur: compteUtilisateurs) {
      utilisateurs << utilisateurForCompteUtilisateur(compteUtilisateur)
    }
    return utilisateurs
  }

  // -------------- private methods --------------------------------------------

  /**
   * Retourne le nom de l'entitité personne
   * @return le nom de l'entité personne
   */
  private getPersonneNomEntite() {
    Personne.NOM_TABLE
  }

  /**
   * Retourne l'utilisateur correspondant à un compte utilisateur
   * @param compteUtilisateur le compte utilisateur
   * @return l'utilisateur
   */
  private Utilisateur utilisateurForCompteUtilisateur(CompteUtilisateur compteUtilisateur) {
    // creer l'utilisateur à retourner

    Personne personne = compteUtilisateur.personne
    DomainAutorite autorite = personne.autorite

    Utilisateur utilisateur = new Utilisateur(
            login: compteUtilisateur.login,
            loginAlias: compteUtilisateur.loginAlias,
            password: compteUtilisateur.password,
            dateDerniereConnexion: compteUtilisateur.dateDerniereConnexion,
            compteActive: compteUtilisateur.compteActive,
            compteExpire: compteUtilisateur.compteExpire,
            compteVerrouille: compteUtilisateur.compteVerrouille,
            passwordExpire: compteUtilisateur.passwordExpire,
            compteUtilisateurId: compteUtilisateur.id,
            nom: personne.nom,
            prenom: personne.prenom,
            dateNaissance: personne.dateNaissance,
            email: personne.email,
            sexe: personne.sexe,
            personneId: personne.id,
            autoriteId: autorite.id
    )
    return utilisateur
  }
}
