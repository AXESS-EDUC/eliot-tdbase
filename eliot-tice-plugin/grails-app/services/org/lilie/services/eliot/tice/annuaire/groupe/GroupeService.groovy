/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 *  This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *   <http://www.gnu.org/licenses/> and
 *   <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tice.annuaire.groupe

import org.hibernate.SQLQuery
import org.hibernate.Session
import org.hibernate.SessionFactory
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.FonctionService
import org.lilie.services.eliot.tice.scolarite.PersonneProprietesScolarite
import org.lilie.services.eliot.tice.scolarite.ProprietesScolarite
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement

/**
 * Service d'interrogation des groupes (scolarité & ENT)
 * @author John Tranier
 */
class GroupeService {

    static transactional = false

    SessionFactory sessionFactory
    FonctionService fonctionService

    private final static String FIND_ALL_GROUPE_SCOLARITE_FOR_PERSONNE = """
        SELECT {ps.*}
        FROM ent.personne_propriete_scolarite pps
        INNER JOIN ent.propriete_scolarite ps ON pps.propriete_scolarite_id = ps.id
        WHERE pps.personne_id = :personneId
        AND pps.est_active = true

        UNION

        SELECT {ps.*}
        FROM ent.propriete_scolarite ps
        INNER JOIN ent.fonction f_parent
        ON ps.fonction_id = f_parent.id AND f_parent.code = 'PERS_REL_ELEVE'
        WHERE EXISTS (
        SELECT *
          FROM ent.personne_propriete_scolarite pps_eleve
          INNER JOIN ent.personne p_eleve ON pps_eleve.personne_id = p_eleve.id
          INNER JOIN ent.propriete_scolarite ps_eleve ON pps_eleve.propriete_scolarite_id = ps_eleve.id
          INNER JOIN ent.structure_enseignement se ON ps_eleve.structure_enseignement_id = se.id
          INNER JOIN ent.fonction f_eleve ON ps_eleve.fonction_id = f_eleve.id
          INNER JOIN ent.responsable_eleve AS resp ON pps_eleve.personne_id = resp.eleve_id
          WHERE resp.personne_id = :personneId
          AND resp.est_active = true
          AND f_eleve.code = 'ELEVE'
          AND pps_eleve.est_active = true
          AND se.id = ps.structure_enseignement_id
)
    """

    /**
     * Liste toutes les personnes d'un groupe de scolarité (représenté par la propriété de scolarité associée)
     * @param proprietesScolarite
     * @return
     */
    List<Personne> findAllPersonneInGroupeScolarite(ProprietesScolarite proprietesScolarite) {
        assert proprietesScolarite
        List<PersonneProprietesScolarite> ppsList =
                PersonneProprietesScolarite.findAllByProprietesScolariteAndEstActive(
                        proprietesScolarite,
                        true
                )

        return (ppsList*.personne as Set).toList()
    }

    /**
     * Liste tous les groupes de scolarité (représentés par des ProprietesScolarite)
     * d'une personne (dans tous ses établissements) qui peuvent être affectés à une séance
     * @param personne
     * @return
     */
    List<ProprietesScolarite> findAllGroupeScolariteForPersonne(Personne personne) {
        Session session = sessionFactory.getCurrentSession()

        SQLQuery sqlQuery = session.createSQLQuery(
                FIND_ALL_GROUPE_SCOLARITE_FOR_PERSONNE
        )
        sqlQuery.setParameterList('personneId', personne.id)
        sqlQuery.addEntity('ps', ProprietesScolarite)

        return sqlQuery.list()
    }

    /**
     *
     * @param structureEnseignement
     * @return le groupe de scolarité correspondant au groupe
     * des élèves d'une structure d'enseignement
     */
    ProprietesScolarite findGroupeScolariteEleveForStructureEnseignement(StructureEnseignement structureEnseignement) {
        return ProprietesScolarite.withCriteria(uniqueResult: true) {
            eq('structureEnseignement', structureEnseignement)
            eq('fonction', fonctionService.fonctionEleve())
            isNull('responsableStructureEnseignement')
        }
    }

    /**
     * Teste si un groupe de scolarité correspond à un groupe scolarité élève
     * @param groupeScolarite
     * @return
     */
    boolean isGroupeScolariteEleve(ProprietesScolarite groupeScolarite) {
        return groupeScolarite.structureEnseignement &&
                groupeScolarite.fonction == fonctionService.fonctionEleve() &&
                !groupeScolarite.responsableStructureEnseignement
    }

    /**
     * Recherche de groupe de scolarité
     * @param personne
     * @param critere
     * @return
     */
    RechercheGroupeResultat rechercheGroupeScolarite(Personne personne,
                                                     RechercheGroupeCritere critere) {
        // TODO Implémentation provisoire en attendant de recevoir les infos d'Axess
        List<ProprietesScolarite> groupeScolariteList = ProprietesScolarite.withCriteria {
            or {
                eq('etablissement', critere.etablissement)
                'structureEnseignement' {
                    eq('etablissement', critere.etablissement)
                }
            }
            eq('fonction', critere.fonction)
        }

        return new RechercheGroupeResultat(
                groupes: groupeScolariteList,
                nombreTotal: groupeScolariteList.size()
        )
    }
}
