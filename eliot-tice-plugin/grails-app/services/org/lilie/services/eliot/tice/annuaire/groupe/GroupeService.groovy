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
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.Fonction
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
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
    RechercheGroupeRestService rechercheGroupeRestService

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
     * @param groupeScolarite
     * @return
     */
    List<Personne> findAllPersonneInGroupeScolarite(ProprietesScolarite groupeScolarite) {
        assert groupeScolarite

        if (groupeScolarite.fonction != FonctionEnum.PERS_REL_ELEVE.fonction) {
            List<PersonneProprietesScolarite> ppsList =
                    PersonneProprietesScolarite.findAllByProprietesScolariteAndEstActive(
                            groupeScolarite,
                            true
                    )

            return (ppsList*.personne as Set).toList()
        } else {

            if (!groupeScolarite.structureEnseignementId) {
                throw new IllegalStateException(
                        "Les groupes scolarité parents sans structure d'enseignement" +
                                " ne sont pas supportés."
                )
            }

            String sql = """
    SELECT p.*
    FROM ent.personne p
    WHERE EXISTS (
        SELECT 1
        FROM ent.personne_propriete_scolarite pps_eleve
        INNER JOIN ent.personne p_eleve ON pps_eleve.personne_id = p_eleve.id
        INNER JOIN ent.propriete_scolarite ps_eleve ON pps_eleve.propriete_scolarite_id = ps_eleve.id
        INNER JOIN ent.fonction f_eleve ON ps_eleve.fonction_id = f_eleve.id
        INNER JOIN ent.responsable_eleve resp ON pps_eleve.personne_id = resp.eleve_id
        WHERE resp.personne_id = p.id
        AND resp.est_active = true
        AND f_eleve.code = 'ELEVE'
        AND pps_eleve.est_active = true
        AND ps_eleve.structure_enseignement_id = :structure_enseignement_id
        LIMIT 1
    )
"""
            Session session = sessionFactory.getCurrentSession()
            SQLQuery sqlQuery = session.createSQLQuery(sql)
            sqlQuery.setLong('structure_enseignement_id', groupeScolarite.structureEnseignementId)
            sqlQuery.addEntity(Personne)
            return sqlQuery.list()
        }

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
     * Liste tous les groupes ENT auquel un utilisateur est rattaché
     * @param personne
     * @return
     */
    List<GroupeEnt> findAllGroupeEntForPersonne(Personne personne) {
        RelGroupeEntPersonne.findAllByPersonne(personne)*.groupeEnt
    }

    /**
     * Liste tous les groupes ENT auquel un utilisateur est rattaché, et qui sont
     * associés à un des établissements de la liste fournie
     * @param personne
     * @param etablissementList
     * @return
     */
    List<GroupeEnt> findAllGroupeEntInEtablissementListForPersonne(Personne personne,
                                                                   List<Etablissement> etablissementList) {
        String sql = """
          SELECT g.*
          FROM ent.rel_groupe_ent_personne rgp
          INNER JOIN ent.groupe_ent g ON rgp.groupe_ent_id = g.id
          WHERE g.etablissement_id IN (:etablissementIdList)
          AND rgp.personne_id = :personneId
        """

        Session session = sessionFactory.getCurrentSession()
        SQLQuery sqlQuery = session.createSQLQuery(sql)
        sqlQuery.setParameterList('etablissementIdList', etablissementList*.id)
        sqlQuery.setLong('personneId', personne.id)
        sqlQuery.addEntity(GroupeEnt)
        return sqlQuery.list()
    }

    List<Personne> findAllPersonneForGroupeEntAndFonctionIn(GroupeEnt groupeEnt,
                                                            List<Fonction> fonctionList) {
        Session session = sessionFactory.getCurrentSession()

        String sqlGeneral = """
            -- cas général
            SELECT  p.*
            FROM ent.groupe_ent g
            INNER JOIN ent.rel_groupe_ent_personne rgp ON rgp.groupe_ent_id = g.id
            INNER JOIN ent.personne p ON rgp.personne_id = p.id
            INNER JOIN ent.personne_propriete_scolarite pps ON (pps.personne_id = p.id AND pps.est_active IS TRUE)
            INNER JOIN ent.propriete_scolarite ps ON (pps.propriete_scolarite_id = ps.id)
            INNER JOIN ent.fonction f ON ps.fonction_id = f.id
            WHERE g.id = :groupeEntId AND f.id IN (:fonctionIdList) AND (ps.etablissement_id = g.etablissement_id)

            UNION

            SELECT  p.*
            FROM ent.groupe_ent g
            INNER JOIN ent.rel_groupe_ent_personne rgp ON rgp.groupe_ent_id = g.id
            INNER JOIN ent.personne p ON rgp.personne_id = p.id
            INNER JOIN ent.personne_propriete_scolarite pps ON (pps.personne_id = p.id AND pps.est_active IS TRUE)
            INNER JOIN ent.propriete_scolarite ps ON (pps.propriete_scolarite_id = ps.id)
            INNER JOIN ent.structure_enseignement se ON ps.structure_enseignement_id = se.id
            INNER JOIN ent.fonction f ON ps.fonction_id = f.id
            WHERE g.id = :groupeEntId AND f.id IN (:fonctionIdList) AND (se.etablissement_id = g.etablissement_id)
"""
        String sqlComplementParent = """
            UNION ALL

            SELECT p.*
            FROM ent.groupe_ent g
            INNER JOIN ent.rel_groupe_ent_personne rgp ON rgp.groupe_ent_id = g.id
            INNER JOIN ent.personne p ON rgp.personne_id = p.id
            WHERE g.id = :groupeEntId
            AND EXISTS (
              SELECT 1
              FROM ent.personne_propriete_scolarite pps_eleve
              INNER JOIN ent.personne p_eleve ON pps_eleve.personne_id = p_eleve.id
              INNER JOIN ent.propriete_scolarite ps_eleve ON pps_eleve.propriete_scolarite_id = ps_eleve.id
              INNER JOIN ent.structure_enseignement se ON ps_eleve.structure_enseignement_id = se.id
              INNER JOIN ent.responsable_eleve resp ON pps_eleve.personne_id = resp.eleve_id
              WHERE resp.personne_id = p.id AND se.etablissement_id = g.etablissement_id
              LIMIT 1
            )

        """

        String sqlComplementAdminLocal = """
            UNION ALL

            SELECT  p.*
            FROM ent.groupe_ent g
            INNER JOIN ent.rel_groupe_ent_personne rgp ON rgp.groupe_ent_id = g.id
            INNER JOIN ent.personne p ON rgp.personne_id = p.id
            INNER JOIN ent.personne_propriete_scolarite pps ON (pps.personne_id = p.id AND pps.est_active IS TRUE)
            INNER JOIN ent.propriete_scolarite ps ON (pps.propriete_scolarite_id = ps.id)
            INNER JOIN ent.fonction f ON ps.fonction_id = f.id
            WHERE f.code = 'AL' AND ps.porteur_ent_id = :porteur_ent_id
        """

        String sql = sqlGeneral
        if (fonctionList.contains(FonctionEnum.PERS_REL_ELEVE.fonction)) {
            sql += sqlComplementParent
        }

        if (fonctionList.contains(FonctionEnum.AL.fonction)) {
            sql += sqlComplementAdminLocal
        }

        SQLQuery sqlQuery = session.createSQLQuery(sql)
        sqlQuery.setLong('groupeEntId', groupeEnt.id)
        sqlQuery.setParameterList('fonctionIdList', fonctionList*.id)
        if (fonctionList.contains(FonctionEnum.AL.fonction)) {
            sqlQuery.setLong('porteur_ent_id', groupeEnt.etablissement.porteurEntId)
        }
        sqlQuery.addEntity(Personne)
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
     * Recherche de groupe (scolarité ou ENT)
     * @param personne
     * @param critere
     * @param groupeType
     * @param codePorteur
     * @return
     */
    RechercheGroupeResultat rechercheGroupe(Personne personne,
                                            RechercheGroupeCritere critere,
                                            GroupeType groupeType,
                                            String codePorteur = null) {
        switch (groupeType) {
            case GroupeType.SCOLARITE:
                return rechercheGroupeScolarite(personne, critere, codePorteur)
            case GroupeType.ENT:
                return rechercheGroupeEnt(personne, critere, codePorteur)
            default:
                throw new IllegalStateException(
                        "Ce type de groupe n'est pas géré : $groupeType"
                )
        }
    }

    /**
     * Recherche de groupes de scolarité
     * @param personne
     * @param critere
     * @return
     */
    RechercheGroupeResultat rechercheGroupeScolarite(Personne personne,
                                                     RechercheGroupeCritere critere,
                                                     String codePorteur = null) {

        def resultat = rechercheGroupeRestService.rechercheGroupeList(
                personne,
                critere,
                GroupeType.SCOLARITE,
                codePorteur
        )

        if (!resultat) {
            return new RechercheGroupeResultat()
        }

        return new RechercheGroupeResultat(
                groupes: resultat.groupes.collect {
                    if (it.type != GroupeType.SCOLARITE.name()) {
                        throw new IllegalStateException(
                                "Le groupe n'est pas un groupe scolarité: ${it}"
                        )
                    }

                    return new GroupeScolariteProxy(
                            id: it.id,
                            nomAffichage: it."nom-affichage"
                    )
                },
                nombreTotal: resultat."nombre-total"
        )
    }

    /**
     * Recherche de groupes ENT
     * @param personne
     * @param critere
     * @param codePorteur
     * @return
     */
    RechercheGroupeResultat rechercheGroupeEnt(Personne personne,
                                               RechercheGroupeCritere critere,
                                               String codePorteur = null) {
        def resultat = rechercheGroupeRestService.rechercheGroupeList(
                personne,
                critere,
                GroupeType.ENT,
                codePorteur
        )

        if (!resultat) {
            return new RechercheGroupeResultat()
        }

        return new RechercheGroupeResultat(
                groupes: resultat.groupes.collect {
                    if (it.type != GroupeType.ENT.name()) {
                        throw new IllegalStateException(
                                "Le groupe n'est pas un groupe ENT: ${it}"
                        )
                    }

                    return GroupeEnt.load(it.id)
                },
                nombreTotal: resultat."nombre-total"
        )
    }

    /**
     * Teste si un établissement a des groupes ENT
     * @param etablissement
     * @return
     */
    boolean hasGroupeEnt(Etablissement etablissement) {
        GroupeEnt.findByEtablissement(etablissement) as boolean
    }
}
