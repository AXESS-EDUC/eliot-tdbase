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

import groovy.json.JsonBuilder
import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissementService
import org.lilie.services.eliot.tdbase.securite.RoleApplicatif
import org.lilie.services.eliot.tdbase.securite.SecuriteSessionService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeService
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeType
import org.lilie.services.eliot.tice.annuaire.groupe.RechercheGroupeCritere
import org.lilie.services.eliot.tice.annuaire.groupe.RechercheGroupeResultat
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.Fonction
import org.lilie.services.eliot.tice.scolarite.FonctionService
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.scolarite.ProprietesScolarite
import org.lilie.services.eliot.tice.scolarite.ScolariteService
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement
import org.lilie.services.eliot.tice.utils.BreadcrumpsService
import org.lilie.services.eliot.tice.utils.NumberUtils

class SeanceController {

    static scope = "singleton"

    static defaultAction = "liste"

    BreadcrumpsService breadcrumpsServiceProxy
    ModaliteActiviteService modaliteActiviteService
    CopieService copieService
    ProfilScolariteService profilScolariteService
    ScolariteService scolariteService
    CahierTextesService cahierTextesService
    NotesService notesService
    SecuriteSessionService securiteSessionServiceProxy
    GroupeService groupeService
    FonctionService fonctionService
    PreferenceEtablissementService preferenceEtablissementService
/**
 *
 * Action "edite"
 */
    def edite() {
        ModaliteActivite modaliteActivite
        Personne personne = authenticatedPersonne
        def afficheLienCreationDevoir = false
        def afficheLienCreationActivite = false
        def afficheActiviteCreee = false
        def afficheDevoirCree = false
        def lienBookmarkable = null
        List<ServiceInfo> services = []
        List<CahierTextesInfo> cahiers = []
        List<ChapitreInfo> chapitres = []
        if (params.creation) {
            modaliteActivite = new ModaliteActivite(enseignant: personne)
            params.bcInit = true
        } else {
            modaliteActivite = ModaliteActivite.get(params.id)
            lienBookmarkable = createLink(
                    controller: "accueil", action: "activite",
                    id: modaliteActivite.id,
                    absolute: true,
                    params: [sujetId: modaliteActivite.sujetId]
            )

            def strongCheck = grailsApplication.config.eliot.interfacage.strongCheck as Boolean

            if (modaliteActiviteService.canBindModaliteActiviteToDevoir(modaliteActivite, personne)) {

                afficheLienCreationDevoir =
                        modaliteActiviteService.canCreateNotesDevoirForModaliteActivite(
                                modaliteActivite,
                                personne,
                                strongCheck
                        )


                if (!afficheLienCreationDevoir) {
                    afficheDevoirCree = modaliteActiviteService.modaliteActiviteHasNotesDevoir(modaliteActivite,
                            personne,
                            strongCheck)
                } else {
                    services = notesService.findServicesEvaluablesByModaliteActivite(
                            modaliteActivite,
                            personne,
                            codePorteur
                    )
                }
            }

            if (modaliteActiviteService.canBindModaliteActiviteToTextesActivite(modaliteActivite, personne)) {
                afficheLienCreationActivite =
                        modaliteActiviteService.canCreateTextesActiviteForModaliteActivite(
                                modaliteActivite,
                                personne,
                                strongCheck
                        )

                if (!afficheLienCreationActivite) {
                    afficheActiviteCreee = modaliteActiviteService.modaliteActiviteHasTextesActivite(
                            modaliteActivite,
                            personne,
                            strongCheck
                    )
                } else {
                    cahiers = cahierTextesService.findCahiersTextesInfoByModaliteActivite(
                            modaliteActivite,
                            personne,
                            codePorteur
                    )
                }
            }
        }

        breadcrumpsServiceProxy.manageBreadcrumps(
                params,
                message(code: "seance.edite.titre"),
                [services: services]
        )

        def etablissements = securiteSessionServiceProxy.etablissementList
        def structureEnseignementList =
                profilScolariteService.findProprietesScolariteWithStructureForPersonne(
                        personne,
                        etablissements
                )*.structureEnseignement.unique {a, b -> a.id <=> b.id }.sort { it.nomAffichage }

        List<GroupeType> groupeTypeList =
                groupeService.hasGroupeEnt(securiteSessionServiceProxy.currentEtablissement) ?
                        [GroupeType.SCOLARITE, GroupeType.ENT] :
                        [GroupeType.SCOLARITE]

        render(
                view: '/seance/edite',
                model: [
                        liens                      : breadcrumpsServiceProxy.liens,
                        currentEtablissement       : securiteSessionServiceProxy.currentEtablissement,
                        etablissements             : etablissements,
                        fonctionList               : preferenceEtablissementService.getFonctionListForRoleApprenant(
                                personne,
                                securiteSessionServiceProxy.currentEtablissement
                        ),
                        groupeTypeList             : groupeTypeList,
                        lienBookmarkable           : lienBookmarkable,
                        afficheLienCreationDevoir  : afficheLienCreationDevoir,
                        afficheLienCreationActivite: afficheLienCreationActivite,
                        afficheActiviteCreee       : afficheActiviteCreee,
                        afficheDevoirCree          : afficheDevoirCree,
                        modaliteActivite           : modaliteActivite,
                        structureEnseignementList  : structureEnseignementList,
                        cahiers                    : cahiers,
                        chapitres                  : chapitres,
                        services                   : services,
                        competencesEvaluables      : modaliteActivite.sujet.hasCompetence()
                ]
        )
    }

    /**
     *
     * Action recherche autre groupe
     */
    def rechercheAutreGroupe(RechercheGroupeCommand command) {
        Personne personne = authenticatedPersonne
        Etablissement etablissement
        if (command.etablissementId) {
            etablissement = Etablissement.get(command.etablissementId)
        } else {
            etablissement = securiteSessionServiceProxy.currentEtablissement
            command.etablissementId = etablissement.id
        }

        List<Fonction> fonctionList =
                preferenceEtablissementService.getFonctionListForRoleApprenant(
                        personne,
                        etablissement
                )

        assert command.fonctionId
        Fonction fonction = Fonction.get(command.fonctionId)
        assert fonction

        def codePattern = null
        if (command.patternCode) {
            codePattern = command.patternCode
        }
        def limit = grailsApplication.config.eliot.listes.groupes.maxrecherche
        RechercheGroupeResultat rechercheGroupeResultat =
                groupeService.rechercheGroupe(
                        personne,
                        new RechercheGroupeCritere(
                                etablissement: etablissement,
                                fonction: fonction,
                                motCle: codePattern,
                                limit: limit
                        ),
                        command.groupeType,
                        codePorteur
                )

        List<GroupeType> groupeTypeList =
                groupeService.hasGroupeEnt(etablissement) ?
                        [GroupeType.SCOLARITE, GroupeType.ENT] :
                        [GroupeType.SCOLARITE]

        render(view: "/seance/_selectAutreGroupe",
                model: [
                        rechercheGroupeCommand: command,
                        etablissements        : securiteSessionServiceProxy.etablissementList,
                        fonctionId            : fonction.id,
                        fonctionList          : fonctionList,
                        groupeTypeList        : groupeTypeList,
                        groupeList            : rechercheGroupeResultat.groupes,
                        totalCount            : rechercheGroupeResultat.nombreTotal
                ]
        )
    }

    def updateNiveaux() {
        Personne personne = authenticatedPersonne
        def etabId = params.etablissementId
        def etabs = null
        if (etabId == 'null') {
            etabs = securiteSessionServiceProxy.etablissementList
        } else {
            etabs = [Etablissement.get(etabId as Long)]
        }
        def niveaux = scolariteService.findNiveauxForEtablissement(etabs)
        render(view: "/seance/_selectNiveaux", model: [niveaux: niveaux])
    }

    /**
     * Action updateFonctionList
     */
    def updateFonctionList() {
        Personne personne = authenticatedPersonne

        Etablissement etablissement = Etablissement.load(params.etablissementId)
        List<Fonction> fonctionList =
                preferenceEtablissementService.getFonctionListForRoleApprenant(
                        personne,
                        etablissement
                )

        Fonction fonction = fonctionList.contains(fonctionService.fonctionEleve()) ?
                fonctionService.fonctionEleve() :
                fonctionList.first()

        render(
                view: "/seance/_selectFonction",
                model: [
                        fonctionList: fonctionList,
                        fonctionId  : fonction.id
                ]
        )
    }

    /**
     * Action updateGroupeTypeList
     */
    def updateGroupeTypeList() {
        GroupeType groupeType = params.groupeType ?
                GroupeType.valueOf(params.groupeType) :
                null

        Etablissement etablissement = Etablissement.load(params.etablissementId)

        List<GroupeType> groupeTypeList =
                groupeService.hasGroupeEnt(etablissement) ?
                        [GroupeType.SCOLARITE, GroupeType.ENT] :
                        [GroupeType.SCOLARITE]

        if (!groupeType || !groupeTypeList.contains(groupeType)) {
            groupeType = groupeTypeList.first()
        }

        render(
                view: "/seance/_selectGroupeType",
                model: [
                        groupeTypeList: groupeTypeList,
                        groupeType    : groupeType
                ]
        )
    }

    /**
     * Action updateChapitres
     */
    def updateChapitres() {
        assert grailsApplication.config.eliot.interfacage.textes

        Personne personne = authenticatedPersonne
        List<ChapitreInfo> chapitres = []
        if (params.cahierId != 'null') {
            def cahierId = params.cahierId as Long
            chapitres = cahierTextesService.getChapitreInfosForCahierId(
                    cahierId,
                    personne,
                    codePorteur
            )
        }
        render(view: "/seance/_selectChapitres", model: [chapitres: chapitres])
    }

    /**
     *
     * Action "enregistre"
     */
    def enregistre() {
        ModaliteActivite modaliteActivite
        Personne personne = authenticatedPersonne

        def groupeId
        GroupeType groupeType = null
        def structureEnseignementId = params.structureEnseignementId

        // Si une structure d'enseignement est fournie, on récupère le groupe scolarité élève correspondant
        if (structureEnseignementId && structureEnseignementId != 'null') {
            StructureEnseignement structureEnseignement =
                    StructureEnseignement.load(structureEnseignementId)

            groupeId = groupeService.findGroupeScolariteEleveForStructureEnseignement(
                    structureEnseignement
            ).id
            groupeType = GroupeType.SCOLARITE
        } else if (params.groupeType && params.groupeType != 'null') {
            groupeType = GroupeType.valueOf(params.groupeType)
            groupeId = params.groupeId
        }

        switch (groupeType) {
            case GroupeType.SCOLARITE:
                ProprietesScolarite props = ProprietesScolarite.get(
                        groupeId
                )
                params.'groupeScolarite.id' = groupeId

                if (props.matiere) {
                    params.'matiere.id' = props.matiere.id
                }

                break

            case GroupeType.ENT:
                params.'groupeEnt.id' = groupeId
                break
        }

        if (params.id) {
            modaliteActivite = ModaliteActivite.get(params.id)
            modaliteActiviteService.updateProprietes(modaliteActivite, params, personne)
        } else {
            modaliteActivite = modaliteActiviteService.createModaliteActivite(
                    params,
                    personne
            )
        }

        if (!modaliteActivite.hasErrors()) {

            flash.messageCode = "seance.enregistre.succes"

            if (grailsApplication.config.eliot.interfacage.textes) {
                tryInsertActiviteForModaliteActivite(modaliteActivite, params, personne)
            }
            if (grailsApplication.config.eliot.interfacage.notes) {
                tryInsertDevoirForModaliteActivite(modaliteActivite, params, personne)
            }
            redirect(action: "edite", id: modaliteActivite.id, params: [bcInit: true])
        } else {
            def etablissements = securiteSessionServiceProxy.etablissementList
            def structureEnseignementList =
                    profilScolariteService.findProprietesScolariteWithStructureForPersonne(
                            personne,
                            etablissements
                    )*.structureEnseignement.unique {a, b -> a.id <=> b.id }.sort { it.nomAffichage }

            List<GroupeType> groupeTypeList =
                    groupeService.hasGroupeEnt(securiteSessionServiceProxy.currentEtablissement) ?
                            [GroupeType.SCOLARITE, GroupeType.ENT] :
                            [GroupeType.SCOLARITE]

            render(
                    view: '/seance/edite',
                    model: [
                            liens                    : breadcrumpsServiceProxy.liens,
                            currentEtablissement     : securiteSessionServiceProxy.currentEtablissement,
                            etablissements           : etablissements,
                            fonctionList             : preferenceEtablissementService.getFonctionListForRoleApprenant(
                                    personne,
                                    securiteSessionServiceProxy.currentEtablissement
                            ),
                            groupeTypeList           : groupeTypeList,
                            modaliteActivite         : modaliteActivite,
                            structureEnseignementList: structureEnseignementList,
                            competencesEvaluables    : modaliteActivite.sujet.hasCompetence()
                    ]
            )
        }
    }

/**
 *
 * Action "recherche"
 */
    def liste() {
        def maxItems = grailsApplication.config.eliot.listes.max
        params.max = Math.min(params.max ? params.int('max') : maxItems, 100)
        breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "seance.liste.titre"))
        Personne personne = authenticatedPersonne
        def modalitesActivites = modaliteActiviteService.findModalitesActivitesForEnseignant(personne,
                params)
        boolean affichePager = false
        if (modalitesActivites.totalCount > maxItems) {
            affichePager = true
        }
        render(view: '/seance/liste', model: [liens       : breadcrumpsServiceProxy.liens,
                                              seances     : modalitesActivites,
                                              affichePager: affichePager])
    }

    /**
     *
     * Action supprime une séance
     */
    def supprime() {
        ModaliteActivite seance = ModaliteActivite.get(params.id)
        Personne personne = authenticatedPersonne
        if (seance.activiteId) {
            flash.messageSuppressionTextesCode = "seance.suppression.activitenonsupprimee"
        }
        if (seance.evaluationId) {
            flash.messageSuppressionNotesCode = "seance.suppression.devoirnonsupprime"
        }
        modaliteActiviteService.supprimeModaliteActivite(seance,
                personne)
        flash.messageSuppressionCode = "seance.suppression.succes"
        redirect(action: "liste", params: [bcInit: true])
    }

    /**
     *
     * Action liste résultats
     */
    def listeResultats() {
        breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "seance.resultats.titre"))

        ModaliteActivite seance = ModaliteActivite.get(params.id)
        Personne personne = authenticatedPersonne
        def strongCheck = grailsApplication.config.eliot.interfacage.strongCheck as Boolean
        def afficheLienMiseAjourNote = modaliteActiviteService.modaliteActiviteHasNotesDevoir(seance,
                personne,
                strongCheck)
        def copies = copieService.findCopiesRemisesForModaliteActivite(seance,
                personne)
        def elevesSansCopies = copieService.findElevesSansCopieForModaliteActivite(seance,
                copies,
                personne)
        render(
                view: '/seance/listeResultats',
                model: [
                        liens                   : breadcrumpsServiceProxy.liens,
                        seance                  : seance,
                        afficheLienMiseAjourNote: afficheLienMiseAjourNote,
                        copies                  : copies,
                        elevesSansCopies        : elevesSansCopies
                ]
        )
    }

    /**
     * Action de mise à jour des notes
     */
    def updateNotesDevoir() {
        assert grailsApplication.config.eliot.interfacage.notes

        ModaliteActivite seance = ModaliteActivite.get(params.id)
        Personne personne = authenticatedPersonne
        def copies = copieService.findCopiesRemisesForModaliteActivite(
                seance,
                personne
        )
        def notes = [:]
        copies.each { Copie copie ->
            notes.put(copie.eleveId, copie.correctionNoteFinale)
        }
        Long res = notesService.updateNotes(seance, personne, codePorteur)
        if (res == null) {
            flash.messageErreurNotesCode = "seance.updatenotes.echec"
        } else {
            flash.messageCode = "seance.updatenotes.succes"
            flash.messageArgs = [res]
        }
        redirect(action: 'listeResultats', id: seance.id, controller: 'seance')
    }

    /**
     *
     * Action visualise copie
     */
    def visualiseCopie() {
        breadcrumpsServiceProxy.manageBreadcrumps(params, message(code: "copie.visualisation.titre"))
        ModaliteActivite seance = ModaliteActivite.get(params.id)
        Personne personne = authenticatedPersonne
        List<Copie> copies = copieService.findCopiesRemisesForModaliteActivite(seance,
                personne,
                params)
        render(view: '/seance/copie/corrige', model: [liens : breadcrumpsServiceProxy.liens,
                                                      copies: copies,
                                                      seance: seance])
    }

    /**
     *
     * Action visualise copie
     */
    def enregistreCopie(CopieNotationCommand copieNotation) {
        Personne personne = authenticatedPersonne
        ModaliteActivite seance = ModaliteActivite.get(params.id)
        def allErrors = null
        if (!copieNotation.hasErrors()) {
            Copie copie = Copie.get(copieNotation.copieId)
            copieService.updateAnnotationAndModulationForCopie(copieNotation.copieAnnotation,
                    copieNotation.copiePointsModulation,
                    copie,
                    personne)
            if (!copie.hasErrors()) {
                request.messageCode = "copie.correction.succes"
            } else {
                copie.errors.allErrors.each {
                    copieNotation.errors.reject("copie.${it.code}")
                }
            }
        }
        List<Copie> copies = copieService.findCopiesRemisesForModaliteActivite(seance,
                personne,
                params)
        render(view: '/seance/copie/corrige', model: [liens        : breadcrumpsServiceProxy.liens,
                                                      copies       : copies,
                                                      seance       : seance,
                                                      copieNotation: copieNotation

        ])
    }

    /**
     *
     * Action pour mettre à jour la note d'une réponse
     */
    def updateReponseNote(UpdateReponseNoteCommand nvelleNote) {
        Personne enseignant = authenticatedPersonne
        try {
            // deduit l'id de l'objet réponse à modifier
            def reponse = Reponse.get(nvelleNote.element_id)
            // récupère la nouvelle valeur
            def points = nvelleNote.update_value
            // met à jour
            def copie = copieService.updateNoteForReponse(points, reponse, enseignant)
            if (copie.hasErrors()) {
                render new JsonBuilder([nvelleNote.element_id.toString(), params.original_html]).toString()
            } else {
                def noteRep = NumberUtils.formatFloat(points)
                def noteFinale = NumberUtils.formatFloat(copie.correctionNoteFinale)
                render new JsonBuilder([nvelleNote.element_id.toString(), noteRep, noteFinale]).toString()
            }
        } catch (Exception e) {
            log.info(e.message)
            render new JsonBuilder([nvelleNote.element_id.toString(), params.original_html]).toString()
        }
    }

    /**
     * Essayer de creer l'activité dans le cahier de textes
     * @param modaliteActivite la séance
     * @param params les params de la requête
     * @param personne la personne déclenchant l'opération
     */
    private tryInsertActiviteForModaliteActivite(ModaliteActivite modaliteActivite, def params, Personne personne) {
        // lien vers cahier de textes
        Long cahierId = null
        Long chapitreId = null
        ContexteActivite activiteContext = ContexteActivite.CLA
        if (params.cahierId && params.cahierId != 'null') {
            cahierId = params.cahierId as Long
            if (params.chapitreId && params.chapitreId != 'null') {
                chapitreId = params.chapitreId as Long
            }
            if (params.activiteContexteId) {
                activiteContext = ContexteActivite.valueOf(ContexteActivite.class,
                        params.activiteContexteId)
            }
            String urlSeance = createLink(controller: "accueil", action: "activite",
                    id: modaliteActivite.id, absolute: true,
                    params: [sujetId: modaliteActivite.sujetId])
            // hack pour que l'url soit valide dans tous les cas
            urlSeance = urlSeance.replaceFirst("localhost", "127.0.0.1")

            def description = ""
            Long actId = cahierTextesService.createTextesActivite(
                    cahierId,
                    chapitreId,
                    activiteContext,
                    modaliteActivite,
                    description,
                    urlSeance,
                    personne,
                    codePorteur
            )

            if (!actId) {
                flash.messageTextesCode = "seance.enregistre.liencahiertextes.erreur"
            }
        }
    }

    /**
     * Essayer de creer le devoir dans le module notes
     * @param modaliteActivite la séance
     * @param params les params de la requête
     * @param personne la personne déclenchant l'opération
     */
    private tryInsertDevoirForModaliteActivite(ModaliteActivite modaliteActivite, def params, Personne personne) {
        // lien vers notes
        String serviceId = null
        if (params.serviceId && params.serviceId != 'null') {
            serviceId = params.serviceId
            List<ServiceInfo> services = breadcrumpsServiceProxy.getValeurPropriete('services')
            ServiceInfo service = services.find { it.id == serviceId }
            Long evalId = null
            if (service) {
                evalId = notesService.createDevoir(service, modaliteActivite,
                        personne, codePorteur)
            }
            if (!evalId) {
                flash.messageNotesCode = "seance.enregistre.liennotes.erreur"
            }
        }
    }
}


class CopieNotationCommand {
    Long copieId
    String copieAnnotation
    Float copiePointsModulation

}

class UpdateReponseNoteCommand {
    Long element_id
    Float update_value
}

class RechercheGroupeCommand {
    String patternCode
    Long etablissementId
    Long fonctionId
    GroupeType groupeType


}