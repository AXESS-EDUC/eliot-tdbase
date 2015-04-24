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

import org.lilie.services.eliot.tdbase.preferences.PreferenceEtablissementService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeAnnuaire
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeEnt
import org.lilie.services.eliot.tice.annuaire.groupe.GroupeService
import org.lilie.services.eliot.tice.nomenclature.MatiereBcn
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.Fonction
import org.lilie.services.eliot.tice.scolarite.ProprietesScolarite

/**
 * Classe représentant les modalités de l'activité d'un groupe d'élèves pour traiter
 * un sujet en ligne
 * @author franck Silvestre
 */
class ModaliteActivite {

    GroupeService groupeService
    PreferenceEtablissementService preferenceEtablissementService

    Date dateRemiseReponses = new Date()

    Date dateDebut = new Date()
    Date dateFin = new Date() + 1

    Sujet sujet

    Personne responsable
    Etablissement etablissement

    Personne enseignant

    // Une séance doit être associé à un groupeScolarite ou (exclusif) un groupeEnt
    ProprietesScolarite groupeScolarite
    GroupeEnt groupeEnt

    MatiereBcn matiereBcn

    Long activiteId
    Long evaluationId

    Boolean copieAmeliorable = true
    Boolean optionEvaluerCompetences

    Date datePublicationResultats = dateFin
    Date dateNotificationPublicationResultats
    Date dateNotificationOuvertureSeance
    Date dateRappelNotificationOuvertureSeance
    Boolean notifierMaintenant = true
    Boolean notifierAvantOuverture = true
    Integer notifierNJoursAvant = 1

    Boolean decompteTemps = false
    Integer dureeMinutes
  
    static constraints = {
        responsable(nullable: true)
        etablissement(nullable: true)
        activiteId(nullable: true)
        evaluationId(nullable: true)
        dateFin(validator: { val, obj ->
            if (!val.after(obj.dateDebut)) {
                return ['invalid.dateFinAvantDateDebut']
            }
        })
        datePublicationResultats(nullable: true, validator: { val, obj ->
            if (val == null || val == obj.dateFin) {
                return true
            }
            if (val && obj.dateFin.after(val)) {
                return ['invalid.datePublicationAvantDateFin']
            }
        })
        dateNotificationPublicationResultats nullable: true
        dateNotificationOuvertureSeance nullable: true
        dateRappelNotificationOuvertureSeance nullable: true
  
        matiereBcn(nullable: true)

        optionEvaluerCompetences(nullable: true)

        dureeMinutes(nullable: true, validator: { val, obj ->
          if (obj.decompteTemps && val == null) {
            return ['invalid.dureeMinuteObligatoire']
          }
          return true
        })

        groupeScolarite(nullable: true, validator: { val, obj ->
            if(!obj.groupeScolarite &&! obj.groupeEnt) {
                return ['modaliteActivite.groupeScolarite.nullable']
            }

            if(obj.groupeScolarite && obj.groupeEnt) {
                return ['modaliteActivite.groupe.scolariteAndEnt']
            }

            return true
        })
        groupeEnt(nullable: true)
    }

    static mapping = {
        table('td.modalite_activite')
        version(false)
        id(column: 'id', generator: 'sequence', params: [sequence: 'td.modalite_activite_id_seq'])
        notifierNJoursAvant(column: 'notifier_n_jours_avant')
        groupeScolarite(column: 'propriete_scolarite_id')
        cache(true)
    }

    static transients = [
            'groupeLibelle',
            'estOuverte',
            'estPerimee',
            'groupeService',
            'preferenceEtablissementService',
            'structureEnseignementId',
            'groupe'
    ]

    GroupeAnnuaire getGroupe() {
        return groupeScolarite ?: groupeEnt
    }

    Etablissement findEtablissement() {
        if (etablissement != null) {
            return etablissement
        }
        groupeScolarite.etablissement ?: groupeScolarite.structureEnseignement?.etablissement
    }

    /**
     * @return l'identifiant de la structure d'enseignement UNIQUEMENT Si
     * la séance est associée à groupe scolarité élève, null sinon
     */
    Long getStructureEnseignementId() {
        if (!groupeScolarite || !groupeService.isGroupeScolariteEleve(groupeScolarite)) {
            return null
        }

        groupeScolarite.structureEnseignementId
    }

    /**
     *
     * @return la liste des personnes devant rendre une copie pour cette séance
     */
    List<Personne> getPersonnesDevantRendreCopie() {
        if (groupeScolarite) {
            // Vérifie que le groupe est associé à une fonction disposant du rôle apprenant dans l'établissement
            List<Fonction> fonctionListForRoleApprenant =
                    preferenceEtablissementService.getFonctionListForRoleApprenant(
                            null,
                            groupeScolarite.etablissement()
                    )
            if(!fonctionListForRoleApprenant.contains(groupeScolarite.fonction)) {
                return [] // La fonction du groupe ne correspond pas au rôle apprenant
            }

            return groupeService.findAllPersonneInGroupeScolarite(groupeScolarite)
        } else {
            return groupeService.findAllPersonneForGroupeEntAndFonctionIn(
                    groupeEnt,
                    preferenceEtablissementService.getFonctionListForRoleApprenant(
                            null,
                            groupeEnt.etablissement
                    )
            )
        }

    }

    /**
     *
     * @return le libelle de la structure d'enseignement concernée
     */
    String getGroupeLibelle() {
        return groupe.nomAffichage
    }

    /**
     *
     * @return true si la séance est ouverte
     */
    boolean estOuverte() {
        Date now = new Date()
        now.before(dateFin) && now.after(dateDebut)
    }

    /**
     *
     * @return true si la séance est terminée
     */
    boolean estPerimee() {
        Date now = new Date()
        now.after(dateFin)
    }

    boolean hasResultatsPublies() {
        Date now = new Date()
        if (datePublicationResultats == null) {
            now.after(dateFin)
        } else {
            now.after(datePublicationResultats)
        }
    }
}
