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


package org.lilie.services.eliot.tice.scolarite

import org.hibernate.SQLQuery
import org.hibernate.Session
import org.hibernate.SessionFactory
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.PorteurEnt
import org.lilie.services.eliot.tice.util.Pagination
import org.lilie.services.eliot.tice.utils.StringUtils


/**
 *
 * @author franck Silvestre
 */
public class ProfilScolariteService {

    ScolariteService scolariteService
    SessionFactory sessionFactory

    static transactional = false

    /**
     * Récupère les profils de scolarite correspondant à la personne
     * passée en paramètre
     * @param personne la personne dont on cherche les profils scolarite
     * @return les proprietes scolarites correspant à la personne
     */
    List<ProprietesScolarite> findProprietesScolaritesForPersonne(Personne personne) {
        List<PersonneProprietesScolarite> profils =
                PersonneProprietesScolarite.findAllByPersonneAndEstActive(personne, true)
        return profils*.proprietesScolarite
    }

    /**
     * Récupère les fonctions occupées par la personne passée en paramètre, tout
     * établissement confondu
     * @param Personne la personne
     * @return la liste des fonctions
     */
    List<Fonction> findFonctionsForPersonne(Personne personne) {
        List<PersonneProprietesScolarite> profils =
                PersonneProprietesScolarite.findAllByPersonneAndEstActive(personne, true, [cache: true])
        List<Fonction> fonctions = []
        profils.each {
            Fonction fonction = it.proprietesScolarite.fonction
            if (fonction && !fonctions.contains(fonction)) {
                fonctions << fonction
            }
        }
        return fonctions
    }

    /**
     * Récupère les fonctions occupées par la personne passée en paramètre, pour
     * un établissement donné
     * @param Personne la personne
     * @return la liste des fonctions
     */
    Set findFonctionsForPersonneAndEtablissement(Personne personne, Etablissement etablissement, Boolean returnFontionEnum = true) {
        List<PersonneProprietesScolarite> profils =
                PersonneProprietesScolarite.findAllByPersonneAndEstActive(personne, true, [cache: true])
        Set<Fonction> fonctions = new HashSet<Fonction>()
        profils.each {
            if (it.proprietesScolarite.etablissement == etablissement ||
                    it.proprietesScolarite.structureEnseignement?.etablissement == etablissement) {
                Fonction fonction = it.proprietesScolarite.fonction
                if (fonction) {
                    if (returnFontionEnum) {
                        fonctions << FonctionEnum.valueOf(fonction.code)
                    } else {
                        fonctions << fonction
                    }
                }
            }
        }
        return fonctions
    }

    /**
     * Récupère les matières caractérisant la personne passée en paramètre, tout
     * établissement confondu
     * @param Personne la personne
     * @return la liste des matières
     */
    List<Matiere> findMatieresForPersonne(Personne personne) {
        List<PersonneProprietesScolarite> profils =
                PersonneProprietesScolarite.findAllByPersonneAndEstActive(personne, true, [cache: true])
        List<Matiere> matieres = []
        profils.each {
            Matiere matiere = it.proprietesScolarite.matiere
            if (matiere && !matieres.contains(matiere)) {
                matieres << matiere
            }
        }
        return matieres
    }

    /**
     * Récupère les niveaux caractérisant la personne passée en paramètre, tout
     * établissement confondu
     * @param Personne la personne
     * @return la liste des niveaux
     */
    List<Niveau> findNiveauxForPersonne(Personne personne) {
        List<StructureEnseignement> structs =
                findStructuresEnseignementForPersonne(personne)
        List<Niveau> niveaux = []

        structs.each { struct ->
            def niveauxByStruct = scolariteService.findNiveauxForStructureEnseignement(struct)
            niveauxByStruct.each { niveau ->
                if (niveau && !niveaux.contains(niveau)) {
                    niveaux.add(niveau)
                }
            }
        }
        return niveaux
    }

    /**
     * Récupère les établissements caractérisant la personne passée en paramètre
     * @param Personne la personne
     * @return la liste des établissements
     */
    Set<Etablissement> findEtablissementsForPersonne(Personne personne) {
        Set<Etablissement> etablissements = new HashSet<Etablissement>()
        // test d'abord si la personne est responsable eleves
        List<Personne> eleves = findElevesForResponsable(personne)
        if (eleves) { // si oui, on recupere les etablissements des enfants associés
            eleves.each {
                etablissements.addAll(findEtablissementsForPersonne(it))
            }
        } else { // sinon on parcours les profils
            List<PersonneProprietesScolarite> profils =
                    PersonneProprietesScolarite.findAllByPersonneAndEstActive(personne, true, [cache: true])

            profils.each {
                Etablissement etablissement = it.proprietesScolarite.etablissement
                StructureEnseignement structureEnseignement = it.proprietesScolarite.structureEnseignement
                if (etablissement) {
                    etablissements << etablissement
                }
                if (structureEnseignement) {
                    etablissements << structureEnseignement.etablissement
                }
            }
        }
        etablissements
    }

    /**
     * Récupère les établissements et fonctions associées d'une personne
     * @param personne la personne
     * @return une map contenant pour chaque établissement la liste des fonctions de la personne
     */
    Map<Etablissement, Set<FonctionEnum>> findEtablissementsAndFonctionsForPersonne(Personne personne) {
        def res = [:]
        // test d'abord si la personne est responsable eleves
        List<Personne> eleves = findElevesForResponsable(personne)
        if (eleves) { // si oui, on recupere les etablissements des enfants associés
            eleves.each {
                def etabsEleve = findEtablissementsForPersonne(it) // todo : find etablissement for eleves
                etabsEleve.each { etab ->
                    HashSet<FonctionEnum> fcts = res.get(etab)
                    if (!fcts) {
                        fcts = new HashSet<FonctionEnum>()
                        res.put(etab, fcts)
                    }
                    fcts.add(FonctionEnum.PERS_REL_ELEVE)
                }
            }
        } else { // sinon on parcours les profils
            List<PersonneProprietesScolarite> profils =
                    PersonneProprietesScolarite.findAllByPersonneAndEstActive(personne, true, [cache: true])

            profils.each {
                def fonction = it.proprietesScolarite.fonction
                def porteurENT = it.proprietesScolarite.porteurEnt
                if (fonction && !porteurENT) { // on ne traite que les fcts d'établissement
                    Etablissement etablissement = it.proprietesScolarite.etablissement
                    StructureEnseignement structureEnseignement = it.proprietesScolarite.structureEnseignement
                    def etab = etablissement ?: structureEnseignement.etablissement
                    HashSet<FonctionEnum> fcts = res.get(etab)
                    if (!fcts) {
                        fcts = new HashSet<FonctionEnum>()
                        res.put(etab, fcts)
                    }
                    fcts.add(FonctionEnum.valueOf(fonction.code))
                }
            }
        }
        res
    }

    /**
     * Récupère les structures d'enseignement (classes / divisions) caractérisant la
     * personne passée en paramètre, tout établissement confondu
     * @param Personne la personne
     * @return la liste des structures d'enseignements
     */
    List<StructureEnseignement> findStructuresEnseignementForPersonne(Personne personne,
                                                                      Fonction withFonction = null) {
        List<PersonneProprietesScolarite> profils =
                PersonneProprietesScolarite.findAllByPersonneAndEstActive(
                        personne,
                        true,
                        [cache: true]
                )

        List<StructureEnseignement> structures = []
        profils.each {
            def keep = true
            StructureEnseignement structureEnseignement =
                    it.proprietesScolarite.structureEnseignement

            if (!structureEnseignement) {
                keep = false
            }
            if (keep && withFonction && it.proprietesScolarite.fonction != withFonction) {
                keep = false
            }
            if (keep && !structures.contains(structureEnseignement)) {
                structures << structureEnseignement
            }
        }
        return structures
    }

    /**
     * Récupère les propriétés de scolarité d'une personne référençant une structure
     * s'enseignement
     * @param personne la personne
     * @return la liste des propriétés de scolarité
     */
    List<ProprietesScolarite> findProprietesScolariteWithStructureForPersonne(Personne personne,
                                                                              Collection<Etablissement> etablissements = null) {
        def props = new HashSet()
        List<PersonneProprietesScolarite> profils =
                PersonneProprietesScolarite.findAllByPersonneAndEstActive(
                        personne,
                        true,
                        [cache: true]
                )

        profils.each {
            StructureEnseignement structureEnseignement =
                    it.proprietesScolarite.structureEnseignement

            if (structureEnseignement) {
                if (!etablissements || etablissements.contains(structureEnseignement.etablissement)) {
                    props << it.proprietesScolarite
                }
            }
        }
        props.sort { it.structureEnseignement.nomAffichage }
    }

    /**
     * Méthode recherchant la liste des élèves d'une structure d'enseignement
     * @param struct la structure d'enseignement
     * @return la liste des eleves
     */
    List<Personne> findElevesForStructureEnseignement(StructureEnseignement struct) {
        def criteria = PersonneProprietesScolarite.createCriteria()
        def personneProprietesScolarites = criteria.list {
            proprietesScolarite {
                eq 'structureEnseignement', struct
                eq 'fonction', FonctionEnum.ELEVE.fonction
            }
            eq 'estActive', true
            personne {
                order 'nom', 'asc'
            }
            join 'personne'
        }
        def eleves = []
        if (personneProprietesScolarites) {
            eleves = personneProprietesScolarites*.personne
        }
        return eleves
    }

    /**
     * Méthode recherchant la liste des élèves d'un responsable
     * @param responsable le responsable élève
     * @return la liste des eleves du responsable
     */
    List<Personne> findElevesForResponsable(Personne responsable) {
        def criteria = ResponsableEleve.createCriteria()
        def respEleves = criteria.list {
            eq 'personne', responsable
            eq 'estActive', true
            join 'eleve'
        }
        def eleves = []
        if (respEleves) {
            eleves = respEleves*.eleve
        }
        return eleves
    }

    /**
     * Méthode indiquant si une personne est responsable d'un élève
     * @param personne le responsable présumé
     * @param eleve l'élève
     * @return true si la personne est bien responsable de l'eleve
     */
    boolean personneEstResponsableEleve(Personne personne, Personne eleve = null) {
        def criteria = ResponsableEleve.createCriteria()
        def countRespEleves = criteria.count {
            eq 'personne', personne
            if (eleve) {
                eq 'eleve', eleve
            }
            eq 'estActive', true
        }
        return countRespEleves > 0
    }

    /**
     * Indique si une personne dirige un établissement
     * @param personne la personne
     * @param etablissement l'établissement
     * @return true si la personne dirige l'établissement
     */
    boolean personneEstPersonnelDirectionForEtablissement(Personne personne, Etablissement etablissement) {
        def criteria = PersonneProprietesScolarite.createCriteria()
        def countPPS = criteria.count {
            eq 'personne', personne
            proprietesScolarite {
                eq 'etablissement', etablissement
                eq 'fonction', FonctionEnum.DIR.fonction
            }
            eq 'estActive', true
        }
        return countPPS > 0
    }

    /**
     * Indique si une personne administre  un établissement
     * @param personne la personne
     * @param etablissement l'établissement
     * @return true si la personne administre l'établissement
     */
    boolean personneEstAdministrateurLocalForEtablissement(Personne personne, Etablissement etablissement) {
        def criteria = PersonneProprietesScolarite.createCriteria()
        def countPPS = criteria.count {
            eq 'personne', personne
            proprietesScolarite {
                eq 'etablissement', etablissement
                eq 'fonction', FonctionEnum.AL.fonction
            }
            eq 'estActive', true
        }
        return countPPS > 0
    }

    /**
     * Indique si une personne est administrateur central
     * @param personne la personne
     * @param porteurEnt le porteur ENT
     * @return true si la personne est admin central
     */
    boolean personneEstAdministrateurCentral(Personne personne, PorteurEnt porteurEnt = null) {
        def criteria = PersonneProprietesScolarite.createCriteria()
        def countPPS = criteria.count {
            eq 'personne', personne
            proprietesScolarite {
                if (porteurEnt) {
                    eq 'porteurEnt', porteurEnt
                }
                or {
                    eq 'fonction', FonctionEnum.CD.fonction
                    eq 'fonction', FonctionEnum.AC.fonction
                }

            }
            eq 'estActive', true
        }
        return countPPS > 0
    }

    /**
     * Récupère les établissements administrés par la personne passée en paramètre
     * @param personne
     * @return
     */
    Set<Etablissement> findEtablissementsAdministresForPersonne(Personne personne) {
        def criteria = PersonneProprietesScolarite.createCriteria()
        def pps = criteria.list {
            eq 'personne', personne
            proprietesScolarite {
                or {
                    eq 'fonction', FonctionEnum.AL.fonction
                    eq 'fonction', FonctionEnum.DIR.fonction
                }
            }
            eq 'estActive', true
            join 'proprietesScolarite'
            join 'proprietesScolarite.etablissement'
        }
        def etabs = pps.collect { it.proprietesScolarite.etablissement }
        etabs
    }

    /**
     * Récupère la liste des personnes qui possèdent une des fonctions données sur l'établissement donné
     * @param etablissement
     * @param fonctionList
     * @return
     */
    List<Personne> rechercheAllPersonneForEtablissementAndFonctionIn(Etablissement etablissement,
                                                                     List<Fonction> fonctionList,
                                                                     String motCle = "",
                                                                     Pagination pagination = null) {

        String motCleNormalise = motCle ? StringUtils.normalise(motCle) : null

        String sqlGeneral = """
          SELECT  p.*
            FROM ent.personne p
            INNER JOIN ent.personne_propriete_scolarite pps ON (pps.personne_id = p.id AND pps.est_active IS TRUE)
            INNER JOIN ent.propriete_scolarite ps ON (pps.propriete_scolarite_id = ps.id)
            INNER JOIN ent.fonction f ON ps.fonction_id = f.id
            WHERE f.id IN (:fonctionIdList) AND (ps.etablissement_id = :etablissementId)
"""
        if (motCleNormalise) {
            sqlGeneral += """
            AND (
                p.nom_normalise LIKE '%${motCleNormalise}%'
                  OR
                p.prenom_normalise LIKE '%${motCleNormalise}%'
            )
"""
        }

        sqlGeneral += """
            UNION

            SELECT  p.*
            FROM ent.personne p
            INNER JOIN ent.personne_propriete_scolarite pps ON (pps.personne_id = p.id AND pps.est_active IS TRUE)
            INNER JOIN ent.propriete_scolarite ps ON (pps.propriete_scolarite_id = ps.id)
            INNER JOIN ent.structure_enseignement se ON ps.structure_enseignement_id = se.id
            INNER JOIN ent.fonction f ON ps.fonction_id = f.id
            WHERE f.id IN (:fonctionIdList) AND (se.etablissement_id = :etablissementId)
"""
        if (motCleNormalise) {
            sqlGeneral += """
            AND (
                p.nom_normalise LIKE '%${motCleNormalise}%'
                  OR
                p.prenom_normalise LIKE '%${motCleNormalise}%'
            )
"""
        }


        String sqlComplementParent = """
          UNION ALL

            SELECT p.*
            FROM ent.personne p
            WHERE EXISTS (
              SELECT 1
              FROM ent.personne_propriete_scolarite pps_eleve
              INNER JOIN ent.personne p_eleve ON pps_eleve.personne_id = p_eleve.id
              INNER JOIN ent.propriete_scolarite ps_eleve ON pps_eleve.propriete_scolarite_id = ps_eleve.id
              INNER JOIN ent.structure_enseignement se ON ps_eleve.structure_enseignement_id = se.id
              INNER JOIN ent.responsable_eleve resp ON pps_eleve.personne_id = resp.eleve_id
              WHERE resp.personne_id = p.id AND se.etablissement_id = :etablissementId
              LIMIT 1
            )
"""
        if (motCleNormalise) {
            sqlComplementParent += """
            AND (
                p.nom_normalise LIKE '%${motCleNormalise}%'
                  OR
                p.prenom_normalise LIKE '%${motCleNormalise}%'
            )
"""
        }


        String sqlComplementAdminLocal = """
          UNION ALL

            SELECT  p.*
            FROM ent.personne p ON rgp.personne_id = p.id
            INNER JOIN ent.personne_propriete_scolarite pps ON (pps.personne_id = p.id AND pps.est_active IS TRUE)
            INNER JOIN ent.propriete_scolarite ps ON (pps.propriete_scolarite_id = ps.id)
            INNER JOIN ent.fonction f ON ps.fonction_id = f.id
            WHERE f.code = 'AL' AND ps.porteur_ent_id = :porteur_ent_id
"""
        if (motCleNormalise) {
            sqlComplementAdminLocal += """
            AND (
                p.nom_normalise LIKE '%${motCleNormalise}%'
                  OR
                p.prenom_normalise LIKE '%${motCleNormalise}%'
            )
"""
        }



        String sql = sqlGeneral
        if (fonctionList.contains(FonctionEnum.PERS_REL_ELEVE.fonction)) {
            sql += sqlComplementParent
        }

        if (fonctionList.contains(FonctionEnum.AL.fonction)) {
            sql += sqlComplementAdminLocal
        }

        sql += """
            ORDER BY nom_normalise, prenom_normalise
"""

        if (pagination) {
            sql += """
            LIMIT ${pagination.max} OFFSET ${pagination.offset}
"""
        }

        Session session = sessionFactory.getCurrentSession()
        SQLQuery sqlQuery = session.createSQLQuery(sql)
        sqlQuery.setLong('etablissementId', etablissement.id)
        sqlQuery.setParameterList('fonctionIdList', fonctionList*.id)
        if (fonctionList.contains(FonctionEnum.AL.fonction)) {
            sqlQuery.setLong('porteur_ent_id', etablissement.porteurEntId)
        }
        sqlQuery.addEntity(Personne)
        return sqlQuery.list()
    }
}