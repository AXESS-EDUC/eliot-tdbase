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

import org.codehaus.groovy.grails.commons.GrailsApplication
import org.lilie.services.eliot.tdbase.emaeval.CampagneProxyService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeService
import org.lilie.services.eliot.tice.notes.Evaluation
import org.lilie.services.eliot.tice.scolarite.FonctionService
import org.lilie.services.eliot.tice.scolarite.ProfilScolariteService
import org.lilie.services.eliot.tice.textes.Activite
import org.springframework.transaction.annotation.Transactional

/**
 * Service de gestion des questions
 * @author franck silvestre
 */
class ModaliteActiviteService {

    static transactional = false

    GrailsApplication grailsApplication
    ProfilScolariteService profilScolariteService
    GroupeService groupeService
    CopieService copieService
    CampagneProxyService campagneProxyService
    FonctionService fonctionService

    /**
     * Créé une séance (modaliteActivite)
     * @param proprietes les propriétés
     * @param proprietaire le proprietaire
     * @return la séance créée
     */
    @Transactional
    ModaliteActivite createModaliteActivite(Map proprietes, Personne proprietaire) {
        ModaliteActivite modaliteActivite = new ModaliteActivite(enseignant: proprietaire)
        modaliteActivite.properties = proprietes
        modaliteActivite.save(flush: true)

        if (modaliteActivite.optionEvaluerCompetences && !modaliteActivite.hasErrors()) {
            campagneProxyService.promesseCreeCampagne(modaliteActivite)
        }

        return modaliteActivite
    }

    /**
     * Modifie les proprietes de la question passée en paramètre
     * @param modaliteActivite la séance
     * @param proprietes les nouvelles proprietes
     * @param proprietaire le proprietaire
     * @return la séance modifiée
     */
    @Transactional
    ModaliteActivite updateProprietes(ModaliteActivite modaliteActivite,
                                      Map proprietes,
                                      Personne proprietaire) {

        assert (modaliteActivite.enseignant == proprietaire)

        Boolean originalOptionEvaluerCompetences = modaliteActivite.optionEvaluerCompetences

        modaliteActivite.properties = proprietes

        // Si changement de l'option Evaluer les compétences
        if ((originalOptionEvaluerCompetences as boolean) != (modaliteActivite.optionEvaluerCompetences as boolean)) {
            if (modaliteActivite.optionEvaluerCompetences) {
                campagneProxyService.promesseCreeCampagne(modaliteActivite)
            } else {
                campagneProxyService.promesseSupprimeCampagne(modaliteActivite)
            }
        }

        modaliteActivite.save(flush: true)
        return modaliteActivite
    }

    /**
     * Recherche de séance
     * @param chercheur la personne effectuant la recherche
     * @param paginationAndSortingSpec les specifications pour l'ordre et
     * la pagination
     * @return la liste des séance
     */
    List<ModaliteActivite> findModalitesActivitesForEnseignant(Personne chercheur,
                                                               Map paginationAndSortingSpec = null) {

        assert (chercheur != null)

        if (paginationAndSortingSpec == null) {
            paginationAndSortingSpec = [:]
        }

        def criteria = ModaliteActivite.createCriteria()
        List<ModaliteActivite> seances = criteria.list(paginationAndSortingSpec) {
            eq 'enseignant', chercheur

            if (paginationAndSortingSpec) {
                def sortArg = paginationAndSortingSpec['sort'] ?: 'dateDebut'
                def orderArg = paginationAndSortingSpec['order'] ?: 'desc'
                if (sortArg) {
                    order "${sortArg}", orderArg
                }

            }
        }
        return seances
    }

    /**
     * Recherche de séances pour profil élève
     * @param chercheur la personne effectuant la recherche
     * @param paginationAndSortingSpec les specifications pour l'ordre et
     * la pagination
     * @return la liste des séances
     */
    List<ModaliteActivite> findModalitesActivitesForApprenant(Personne chercheur,
                                                              Map paginationAndSortingSpec = null) {

        assert (chercheur != null)

        if (paginationAndSortingSpec == null) {
            paginationAndSortingSpec = [:]
        }
        // TODO : quelle stratégie pour les non élèves qui ont le profil apprenant ?
        def seances = []
        def groupeScolariteList = groupeService.findAllGroupeScolariteForPersonne(chercheur)
        if (!groupeScolariteList.isEmpty()) {
            Date now = new Date()
            def criteria = ModaliteActivite.createCriteria()
            seances = criteria.list(paginationAndSortingSpec) {
                inList 'groupeScolarite', groupeScolariteList
                le 'dateDebut', now
                ge 'dateFin', now
                if (paginationAndSortingSpec) {
                    def sortArg = paginationAndSortingSpec['sort'] ?: 'dateDebut'
                    def orderArg = paginationAndSortingSpec['order'] ?: 'desc'
                    if (sortArg) {
                        order "${sortArg}", orderArg
                    }
                }
            }
        }
        seances
    }

    /**
     * Supprime une modalite activité
     * @param modaliteActivite la modalite à supprimer
     * @param personne la personne déclenchant la suppression
     */
    @Transactional
    def supprimeModaliteActivite(ModaliteActivite modaliteActivite, Personne personne) {

        assert (modaliteActivite?.enseignant == personne)

        copieService.supprimeCopiesForModaliteActivite(modaliteActivite, personne)

        campagneProxyService.promesseSupprimeCampagne(modaliteActivite)

        modaliteActivite.delete()
    }

    /**
     * Teste si la séance peut être liée à une activité du cahier de textes
     * @param modaliteActivite
     * @param personne
     * @return
     */
    boolean canBindModaliteActiviteToTextesActivite(ModaliteActivite modaliteActivite,
                                                    Personne personne) {
        assert (modaliteActivite?.enseignant == personne)

        grailsApplication.config.eliot.interfacage.textes &&
                modaliteActivite.groupeScolarite &&
                groupeService.isGroupeScolariteEleve(modaliteActivite.groupeScolarite)
    }

    /**
     * Indique si il est possible de créer une activité dans le cahier de texte
     * @param modaliteActivite la modalite activité
     * @param personne la personne déclenchant l'opération
     * @return true si il est possible de creer une activité dans le cahier de textes
     */
    boolean canCreateTextesActiviteForModaliteActivite(ModaliteActivite modaliteActivite,
                                                       Personne personne,
                                                       Boolean strongCheck = true) {
        assert (modaliteActivite?.enseignant == personne)

        modaliteActivite.groupeScolarite &&
                groupeService.isGroupeScolariteEleve(modaliteActivite.groupeScolarite) &&
                !modaliteActiviteHasTextesActivite(modaliteActivite, personne, strongCheck)
    }

    /**
     * Indique si la modalité activité à une activité du cahier de textes attachée
     * @param modaliteActivite la modalite activité
     * @param personne la personne déclenchant l'opération
     * @return true si la modalité activité a une activité de cahier de textes associée
     */
    boolean modaliteActiviteHasTextesActivite(ModaliteActivite modaliteActivite,
                                              Personne personne,
                                              Boolean strongCheck = true) {
        assert (modaliteActivite?.enseignant == personne)
        Long actId = modaliteActivite.activiteId
        if (!actId) {
            return false
        }
        // note technique
        // le check de l'existence d'une activité s'effectue sans web services pour des
        // raisons  de perf
        if (strongCheck) {
            Activite act = Activite.get(actId)
            if (!act) {
                modaliteActivite.activiteId = null
                if (modaliteActivite.save()) {
                    return false
                }
            }
        }
        return true
    }

    /**
     * Vérifie si cette séance peut être liée à un devoir
     * @param modaliteActivite
     * @param personne
     * @return
     */
    boolean canBindModaliteActiviteToDevoir(ModaliteActivite modaliteActivite,
                                            Personne personne) {

        assert (modaliteActivite?.enseignant == personne)

        return grailsApplication.config.eliot.interfacage.notes &&
                modaliteActivite.groupeScolarite &&
                groupeService.isGroupeScolariteEleve(modaliteActivite.groupeScolarite)
    }

    /**
     * verifie si il est possible de créer un devoir dans Notes (suppose que
     * la séance peut être liée à un devoir)
     * @param modaliteActivite la modalite activité
     * @param personne la personne déclenchant l'opération
     * @return true si il est possible de creer un devoir dans Notes
     */
    boolean canCreateNotesDevoirForModaliteActivite(ModaliteActivite modaliteActivite,
                                                    Personne personne,
                                                    Boolean strongCheck = true) {
        assert (modaliteActivite?.enseignant == personne)

        !modaliteActiviteHasNotesDevoir(modaliteActivite, personne, strongCheck)
    }

    /**
     * Indique si la modalité activité a un devoir de Notes attaché
     * @param modaliteActivite la modalite activité
     * @param personne la personne déclenchant l'opération
     * @return true si la modalité activité a un devoir Notes associé
     */
    boolean modaliteActiviteHasNotesDevoir(ModaliteActivite modaliteActivite,
                                           Personne personne,
                                           Boolean strongCheck = true) {
        assert (modaliteActivite?.enseignant == personne)
        Long evalId = modaliteActivite.evaluationId
        if (!evalId) {
            return false
        }
        // note technique
        // le check de l'existence d'un devoir s'effectue sans web services pour des
        // raisons  de perf
        if (strongCheck) {
            Evaluation eval = Evaluation.get(evalId)
            if (!eval) {
                modaliteActivite.evaluationId = null
                if (modaliteActivite.save()) {
                    return false
                }
            }
        }
        return true
    }

}


