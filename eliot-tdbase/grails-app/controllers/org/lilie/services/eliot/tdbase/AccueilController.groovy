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

package org.lilie.services.eliot.tdbase

import grails.plugins.springsecurity.SpringSecurityService
import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.lilie.services.eliot.tdbase.securite.SecuriteSessionService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.FonctionService

class AccueilController {

    static scope = "singleton"

    FonctionService fonctionService
    CopieService copieService
    SecuriteSessionService securiteSessionServiceProxy
    SpringSecurityService springSecurityService

    /**
     * Accueil tdbase
     */
    def index() {
        if (SpringSecurityUtils.ifAllGranted(RoleApplicatif.ELEVE.authority)) {
            redirect(controller: 'activite', action: 'index', params: [bcInit: true])
        } else if (SpringSecurityUtils.ifAllGranted(RoleApplicatif.PARENT.authority)) {
            redirect(controller: 'resultats', action: 'liste', params: [bcInit: true])
        } else if (SpringSecurityUtils.ifAllGranted(RoleApplicatif.ENSEIGNANT.authority)){
            redirect(controller: 'dashboard', action: 'index', params: [bcInit: true])
        } else if (SpringSecurityUtils.ifAllGranted(RoleApplicatif.ADMINISTRATEUR.authority)) {
            redirect(controller: 'preferences', action: 'index',params: [bcInit: true])
        } else if (SpringSecurityUtils.ifAllGranted(RoleApplicatif.SUPER_ADMINISTRATEUR.authority)) {
            redirect(controller: 'maintenance', action: 'index', params: [bcInit: true])
        } else {
            redirect(controller: 'resultats', action: 'liste', params: [bcInit: true])
        }
    }

    def changeEtablissement() {
        def personne = authenticatedPersonne
        Etablissement etablissement = Etablissement.get(params.id)
        securiteSessionServiceProxy.onChangeEtablissement(personne, etablissement)
        springSecurityService.reauthenticate(securiteSessionServiceProxy.login)
        index()
    }

    def changeRoleApplicatif() {
        def personne = authenticatedPersonne
        RoleApplicatif roleApplicatif = RoleApplicatif.valueOf(params.roleApplicatif)
        securiteSessionServiceProxy.onChangeRoleApplicatif(personne,roleApplicatif)
        springSecurityService.reauthenticate(securiteSessionServiceProxy.login)
        index()
    }

    /**
     * Accueil activite : lien d'accès à une séance ou à un sujet via le cahier de
     * textes ou une URL externe
     */
    def activite() {
        params.bcInit = true
        def seance = ModaliteActivite.get(params.id)
        if (SpringSecurityUtils.ifAllGranted(RoleApplicatif.ELEVE.authority)) {
            if (!seance) {
                flash.messageCode = "seance.nondisponible"
                redirect(controller: 'activite', action: 'listeSeances', params: params)
            } else if (seance.estOuverte()) {
                redirect(controller: 'activite', action: 'travailleCopie', params: params)
            } else {
                Personne personne = authenticatedPersonne
                Copie copie = copieService.getCopieForModaliteActiviteAndEleve(seance, personne)
                redirect(controller: 'activite', action: 'visualiseCopie', id: copie.id, params: [bcInit: true])
            }
        } else if (SpringSecurityUtils.ifAllGranted(RoleApplicatif.PARENT.authority)) {
            if (!seance) {
                flash.messageCode = "seance.nondisponible"
            } else if (seance.estOuverte()) {
                flash.messageCode = "seance.resultats.nondisponible"
            }
            redirect(controller: 'resultats', action: 'liste', params: [bcInit: true])
        } else {
            if (!seance) {
                flash.messageCode = "seance.nondisponible.sujet.disponible"
                redirect(controller: 'sujet', action: 'teste', id: params.sujetId, params: [bcInit: true])
            } else {
                redirect(controller: 'seance', action: 'listeResultats', params: params)
            }
        }
    }

/**
 * Hack pour requête Jmol
 */
    def ignore() {
        render("Canceled")
    }


}


