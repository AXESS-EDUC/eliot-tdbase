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

package org.lilie.services.eliot.tice.utils

import grails.util.Environment
import org.hibernate.SessionFactory
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.SourceImport
import org.lilie.services.eliot.tice.annuaire.UtilisateurService
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.scolarite.*

class BootstrapService {

  static transactional = false


  UtilisateurService utilisateurService
  FonctionService fonctionService
  ProfilScolariteService profilScolariteService
  SessionFactory sessionFactory

  private static final String UTILISATEUR_1_LOGIN = "_test_mary"
  private static final String UTILISATEUR_1_PASSWORD = "_test_"
  private static final String UTILISATEUR_1_NOM = "dupond"
  private static final String UTILISATEUR_1_PRENOM = "mary"

  private static final String DEFAULT_CODE_PORTEUR_ENT = "ENT"
  private static final String UAI_LYCEE = '****L'
  private static final String UAI_COLLEGE = '****C'
  private static final String UAI_PREFIXE = '****'

  private static final String CODE_GESTION_PREFIXE = '****'
  private static final String CODE_MEFSTAT4_PREFIXE = '**'

  private static final String CODE_ANNEE_SCOLAIRE_PREFIXE = '****'
  private static final String CODE_STRUCTURE_PREFIXE = '****'


  private List<ProprietesScolarite> proprietesScolariteListUtilisateur1 = []

  /**
   * Initialise l'application au lancement en mode développement
   */
  def bootstrapForDevelopment() {
    if (Environment.current == Environment.DEVELOPMENT) {
      initialiseEtablissementsEnvDevelopmentTest()
      initialiseMatieresEnvDevelopmentTest()
      initialiseNiveauxEnvDevelopmentTest()
      initialiseAnneeScolaireEnvDevelopmentTest()
      initialiseStructuresEnseignementsEnvDevelopmentTest()
      initialiseProprietesScolaritesEnseignantEnvDevelopmentTest()
      initialiseEnseignant1EnvDevelopment()
      initialiseProfilsScolaritesEnseignant1EnvDevelopment()
    }

  }

  /**
   * Initialise les données pour des tests d'intégration
   */
  def bootstrapForIntegrationTest() {
    if (Environment.current == Environment.TEST) {
      initialiseEtablissementsEnvDevelopmentTest()
      initialiseMatieresEnvDevelopmentTest()
      initialiseNiveauxEnvDevelopmentTest()
      initialiseAnneeScolaireEnvDevelopmentTest()
      initialiseStructuresEnseignementsEnvDevelopmentTest()
      initialiseProprietesScolaritesEnseignantEnvDevelopmentTest()
    }

  }

  /**
   * Ajoute les propriétés de scolarité à la personne passée en paramètre
   * @param proprietesScolariteList la liste des proprietes de scolarite à ajouter
   * @param personne la personne
   */
  def addProprietesScolariteToPersonne(List<ProprietesScolarite> proprietesScolariteList,
                                       Personne personne) {
    proprietesScolariteList.each { ProprietesScolarite proprietesScolarite ->
      new PersonneProprietesScolarite(
              personne: personne,
              proprietesScolarite: proprietesScolarite,
              estActive: true
      ).save()
    }
    sessionFactory.currentSession.flush()

  }

  private def initialiseEnseignant1EnvDevelopment() {
    if (!utilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN)) {
      utilisateurService.createUtilisateur(
              UTILISATEUR_1_LOGIN,
              UTILISATEUR_1_PASSWORD,
              UTILISATEUR_1_NOM,
              UTILISATEUR_1_PRENOM
      )
    }
  }



  private def initialiseStructuresEnseignementsEnvDevelopmentTest() {
    if (!StructureEnseignement.findAllByCodeLike("${CODE_STRUCTURE_PREFIXE}%")) {
      Etablissement lycee = Etablissement.findByUai(UAI_LYCEE)
      Etablissement college = Etablissement.findByUai(UAI_COLLEGE)
      AnneeScolaire anneeScolaire = AnneeScolaire.findByAnneeEnCours(true)
      new StructureEnseignement(
              etablissement: college,
              anneeScolaire: anneeScolaire,
              code: "${CODE_STRUCTURE_PREFIXE}_6ème1",
              idExterne: "${college.uai}.${CODE_STRUCTURE_PREFIXE}_6ème1",
              type: StructureEnseignement.TYPE_CLASSE,
              actif: true
      ).save()
      new StructureEnseignement(
              etablissement: lycee,
              anneeScolaire: anneeScolaire,
              code: "${CODE_STRUCTURE_PREFIXE}_1ereA",
              idExterne: "${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA",
              type: StructureEnseignement.TYPE_CLASSE,
              actif: true
      ).save()
      new StructureEnseignement(
              etablissement: lycee,
              anneeScolaire: anneeScolaire,
              code: "${CODE_STRUCTURE_PREFIXE}_1ereA_G1",
              idExterne: "${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA_G1",
              type: StructureEnseignement.TYPE_GROUPE,
              actif: true
      ).save()
      new StructureEnseignement(
              etablissement: lycee,
              anneeScolaire: anneeScolaire,
              code: "${CODE_STRUCTURE_PREFIXE}_Terminale_D",
              idExterne: "${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_Terminale_D",
              type: StructureEnseignement.TYPE_CLASSE,
              actif: true
      ).save(flush: true)

    }
  }

  private def initialiseEtablissementsEnvDevelopmentTest() {
    if (!Etablissement.findAllByUaiLike("${UAI_PREFIXE}%")) {
      new Etablissement(
              codePorteurENT: DEFAULT_CODE_PORTEUR_ENT,
              uai: UAI_LYCEE,
              nomAffichage: "Lycée Montaigne",
              idExterne: UAI_LYCEE
      ).save()
      new Etablissement(
              codePorteurENT: DEFAULT_CODE_PORTEUR_ENT,
              uai: UAI_COLLEGE,
              nomAffichage: "Collège Pascal",
              idExterne: UAI_COLLEGE
      ).save(flush: true)
    }
  }

  private def initialiseAnneeScolaireEnvDevelopmentTest() {
    if (!AnneeScolaire.findByAnneeEnCours(true)) {
      new AnneeScolaire(
              code: "${CODE_ANNEE_SCOLAIRE_PREFIXE}_2011-2012",
              anneeEnCours: true,
      ).save(flush: true)
    }
  }



  private def initialiseMatieresEnvDevelopmentTest() {
    if (!Matiere.findAllByCodeGestionLike("${CODE_GESTION_PREFIXE}%")) {
      Etablissement lycee = Etablissement.findByUai(UAI_LYCEE)
      Etablissement college = Etablissement.findByUai(UAI_COLLEGE)
      new Matiere(
              codeGestion: "${CODE_GESTION_PREFIXE}_1",
              etablissement: lycee,
              libelleLong: "Mathématiques"
      ).save()
      new Matiere(
              codeGestion: "${CODE_GESTION_PREFIXE}_2",
              etablissement: lycee,
              libelleLong: "SES"
      ).save()
      new Matiere(
              codeGestion: "${CODE_GESTION_PREFIXE}_3",
              etablissement: lycee,
              libelleLong: "SES Spécialité"
      ).save()
      new Matiere(
              codeGestion: "${CODE_GESTION_PREFIXE}_4",
              etablissement: college,
              libelleLong: "Histoire"
      ).save()
      new Matiere(
              codeGestion: "${CODE_GESTION_PREFIXE}_5",
              etablissement: college,
              libelleLong: "Géographie"
      ).save()
      new Matiere(
              codeGestion: "${CODE_GESTION_PREFIXE}_6",
              etablissement: lycee,
              libelleLong: "Communication"
      ).save()
      new Matiere(
              codeGestion: "${CODE_GESTION_PREFIXE}_7",
              etablissement: lycee,
              libelleLong: "Anglais"
      ).save(flush: true)
    }
  }

  private def initialiseNiveauxEnvDevelopmentTest() {
    if (!Niveau.findAllByCodeMefstat4Like("${CODE_MEFSTAT4_PREFIXE}%")) {
      new Niveau(
              codeMefstat4: "${CODE_MEFSTAT4_PREFIXE}_1",
              libelleLong: "Première"
      ).save()
      new Niveau(
              codeMefstat4: "${CODE_MEFSTAT4_PREFIXE}_2",
              libelleLong: "Terminale"
      ).save()
      new Niveau(
              codeMefstat4: "${CODE_MEFSTAT4_PREFIXE}_3",
              libelleLong: "BTS 1"
      ).save()
      new Niveau(
              codeMefstat4: "${CODE_MEFSTAT4_PREFIXE}_4",
              libelleLong: "BTS 2"
      ).save()
      new Niveau(
              codeMefstat4: "${CODE_MEFSTAT4_PREFIXE}_5",
              libelleLong: "6ème"
      ).save(flush: true)

    }
  }


  private def initialiseProprietesScolaritesEnseignantEnvDevelopmentTest() {
    Etablissement lycee = Etablissement.findByUai(UAI_LYCEE)
    if (!ProprietesScolarite.findAllByEtablissement(lycee)) {
      Etablissement college = Etablissement.findByUai(UAI_COLLEGE)
      AnneeScolaire anneeScolaire = AnneeScolaire.findByAnneeEnCours(true)
      Niveau niveau6 = Niveau.findByCodeMefstat4("${CODE_MEFSTAT4_PREFIXE}_5")
      Niveau niveauPrem = Niveau.findByCodeMefstat4("${CODE_MEFSTAT4_PREFIXE}_1")
      Niveau niveauTerm = Niveau.findByCodeMefstat4("${CODE_MEFSTAT4_PREFIXE}_2")
      Matiere matiereMaths = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_1")
      Matiere matiereSES = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_2")
      Matiere matiereHistoire = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_4")
      StructureEnseignement struct6eme = StructureEnseignement.findByIdExterne("${college.uai}.${CODE_STRUCTURE_PREFIXE}_6ème1")
      StructureEnseignement struct1ere = StructureEnseignement.findByIdExterne("${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA")
      StructureEnseignement structGr1ere = StructureEnseignement.findByIdExterne("${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA_G1")
      StructureEnseignement structTerm = StructureEnseignement.findByIdExterne("${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_Terminale_D")
      SourceImport sourceImport = SourceImport.findByCode("STS")

      new ProprietesScolarite(
              source: sourceImport,
              anneeScolaire: anneeScolaire,
              fonction: fonctionService.fonctionEnseignant(),
              etablissement: college,
              matiere: matiereHistoire,
              niveau: niveau6,
              structureEnseignement: struct6eme
      ).save()

      new ProprietesScolarite(
              source: sourceImport,
              anneeScolaire: anneeScolaire,
              fonction: fonctionService.fonctionEnseignant(),
              etablissement: lycee,
              matiere: matiereSES,
              niveau: niveauPrem,
              structureEnseignement: structGr1ere
      ).save()

      new ProprietesScolarite(
              source: sourceImport,
              anneeScolaire: anneeScolaire,
              fonction: fonctionService.fonctionEnseignant(),
              etablissement: lycee,
              matiere: matiereMaths,
              niveau: niveauTerm,
              structureEnseignement: structTerm
      ).save()

      new ProprietesScolarite(
              source: sourceImport,
              anneeScolaire: anneeScolaire,
              fonction: fonctionService.fonctionEnseignant(),
              etablissement: lycee,
              matiere: matiereMaths,
              niveau: niveauPrem,
              structureEnseignement: struct1ere
      ).save(flush: true)

    }

  }

  private def initialiseProfilsScolaritesEnseignant1EnvDevelopment() {
    Utilisateur ens1 = utilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN)
    Personne pers1 = Personne.get(ens1.personneId)
    if (!profilScolariteService.findProprietesScolaritesForPersonne(pers1)) {
      def props = ProprietesScolarite.findAllByFonction(fonctionService.fonctionEnseignant())
      addProprietesScolariteToPersonne(props, pers1)
    }
  }

}
