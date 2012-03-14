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

package org.lilie.services.eliot.tice.annuaire.impl

import org.lilie.services.eliot.tice.annuaire.UtilisateurService
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.securite.acl.TypeAutorite
import org.lilie.services.eliot.tice.annuaire.Personne
import grails.plugins.springsecurity.SpringSecurityService

/**
 *
 * @author franck Silvestre
 */
class LilieUtilisateurService implements UtilisateurService {

  static transactional = false
  static final int LONGUEUR_PREFIXE_LOGIN = 2

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
  Utilisateur createUtilisateur(
          String login,
          String password,
          String nom,
          String prenom,
          String email,
          Date dateNaissance) {
    throw new UnsupportedOperationException("Eliot in Lilie : operation non supportee")
  }

  /**
   * Recherche l'utilisateur correspondant au  login ou alias de login passé
   * en paramètre
   *
   * @param login l'identifiant de l'utilisateur retourne par CAS
   * recherché
   * @return l'utilisateur trouvé ou null
   */
  Utilisateur findUtilisateur(String login) {
    // e login cas est de la forme UTnnnnnnnnnnnn
    // il faut donc parser...
    // on considere que la declaration CD, AL,... est OK puisque CAS est passé
    if (!login) {
      return null
    }
    def idExterne = login.substring(LONGUEUR_PREFIXE_LOGIN)
    def autorite = DomainAutorite.findByIdentifiantAndType(idExterne, TypeAutorite.PERSONNE.libelle)
    if (!autorite) {
      return null
    }

    Personne personne = Personne.findByAutorite(autorite)
    if (personne == null) {
      throw new IllegalStateException(
              "annuaire.no_personne_fot_autorite : ${login}"
      )
    }
    return utilisateurForLoginAndPersonne(login, personne)
  }

  /**
   * Retourne la liste des utilisateurs correspondants aux critères spécifiés
   * @param patternNom
   * @param patternPrenom
   * @param dateAvantNaissance
   * @param dateApresNaissance
   * @param paginationAndSortingSpec une map spécifiant la pagination et l'ordre
   * de tri. exemple : [sort: "nom", order:"asc", offset:10, max:20]
   * @return
   */
  List<Utilisateur> findUtilisateurs(String patternNom, String patternPrenom,
                                     Date dateAvantNaissance, Date dateApresNaissance,
                                     Map paginationAndSortingSpec
  ) {
    throw new UnsupportedOperationException("Eliot in Lilie : operation non supportee")
  }

  /**
   * Met à jour l'alias de login de l'utilisateur caractérisé par le login passé
   * en paramètre
   * @param login le login de l'utilisateur
   * @param aliasLogin l'alias du login de l'utilisateur concerné
   */
  void setAliasLogin(String login, String loginAlias) {
    throw new UnsupportedOperationException("Eliot in Lilie : operation non supportee")
  }

  /**
   * Desactive le compte d'un utilisateur
   * @param login le login de l'utilisateur
   * @return l'utilisateur suspendu
   */
  Utilisateur desactiveUtilisateur(String login) {
    throw new UnsupportedOperationException("Eliot in Lilie : operation non supportee")
  }

  /**
   * Reactive le compte d'un utilisateur
   * @param login le login de l'utilisateur
   * @return l'utilisateur suspendu
   */
  Utilisateur reactiveUtilisateur(String login) {
    throw new UnsupportedOperationException("Eliot in Lilie : operation non supportee")
  }

  /**
   * Met à jour les données d'un utilisateur.
   * Le cas d'utilisation standard : récupération d'un objet de type Utilisateur,
   * modification de l'objet récupérer et soumettre l'objet modifié à la présente
   * méthode.
   * Seules les propriétés password,nom,prenom,email,dateNaissance sont modifiables
   * Le login et le login alias ne sont pas modifiable via cette méthode
   * @param login le login de l'utilisateur à mettre à jour
   * @param utilisateurModel l'utilisateur contenant les nouvelles valeurs
   * @return l'utilisateur avec ses nouvelles valeurs
   */
  Utilisateur updateUtilisateur(String login, Utilisateur utilisateur) {
    throw new UnsupportedOperationException("Eliot in Lilie : operation non supportee")
  }

  /**
   * Retourne l'utilisateur correspondant à un compte utilisateur
   * @param compteUtilisateur le compte utilisateur
   * @return l'utilisateur
   */
  private Utilisateur utilisateurForLoginAndPersonne(String login, Personne personne) {
    // creer l'utilisateur à retourner

    DomainAutorite autorite = personne.autorite
    // le login est le password : utilisee uniquement quand CAS n'est pas actif
    // en mode Lilie quand on est en mode non CAS
    String encodedPassword = springSecurityService.encodePassword(
            login, login)

    Utilisateur utilisateur = new Utilisateur(
            login: login,
            loginAlias: null,
            password: encodedPassword,
            dateDerniereConnexion: null,
            compteActive: true,
            compteExpire: false,
            compteVerrouille: false,
            passwordExpire: false,
            compteUtilisateurId: null,
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
