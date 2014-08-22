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
import org.lilie.services.eliot.tice.annuaire.PorteurEnt
import org.lilie.services.eliot.tice.annuaire.UtilisateurService
import org.lilie.services.eliot.tice.annuaire.data.Utilisateur
import org.lilie.services.eliot.tice.scolarite.*

class BootstrapService {

  static transactional = false
  private static final String DEFAULT_URL_ACCES_ENT = "http://localhost:8080/eliot-tdbase"
  private static final String DEFAULT_URL_RETOUR_LOGOUT = "http://localhost:8080/eliot-tdbase"



  UtilisateurService utilisateurService
  FonctionService fonctionService
  ProfilScolariteService profilScolariteService
  SessionFactory sessionFactory

  static final String DEFAULT_CODE_PORTEUR_ENT = "ENT"

  private static final String UTILISATEUR_1_LOGIN = "_test_mary"
  private static final String UTILISATEUR_1_LOGIN_ALIAS = "ens1"
  private static final String UTILISATEUR_1_PASSWORD = "ens1"
  private static final String UTILISATEUR_1_NOM = "dupond"
  private static final String UTILISATEUR_1_PRENOM = "mary"

  private static final String UTILISATEUR_2_LOGIN = "_test_francky"
  private static final String UTILISATEUR_2_LOGIN_ALIAS = "ens2"
  private static final String UTILISATEUR_2_PASSWORD = "ens2"
  private static final String UTILISATEUR_2_NOM = "dupond"
  private static final String UTILISATEUR_2_PRENOM = "francky"

  private static final String ELEVE_1_LOGIN = "elv1"
  private static final String ELEVE_1_PASSWORD = "elv1"
  private static final String ELEVE_1_NOM = "durand"
  private static final String ELEVE_1_PRENOM = "paul"
  private static final String ELEVE_2_LOGIN = "elv2"
  private static final String ELEVE_2_PASSWORD = "elv2"
  private static final String ELEVE_2_NOM = "Durandine"
  private static final String ELEVE_2_PRENOM = "Pauline"

  private static final String RESP_1_LOGIN = "resp1"
  private static final String RESP_1_PASSWORD = "resp1"
  private static final String RESP_1_NOM = "Durand"
  private static final String RESP_1_PRENOM = "Emilie"



  private static final String UAI_LYCEE = 'TEST_L'
  private static final String UAI_COLLEGE = 'TEST_C'
  private static final String UAI_PREFIXE = 'TEST_'

  private static final String CODE_GESTION_PREFIXE = 'TEST_'
  private static final String CODE_MEFSTAT4_PREFIXE = 'TEST_'

  private static final String CODE_ANNEE_SCOLAIRE_PREFIXE = 'TEST_'
  private static final String CODE_STRUCTURE_PREFIXE = 'TEST_'

  /**
   * Initialise l'application au lancement avec un jeu de test
   */
  def bootstrapJeuDeTestDevDemo() {
    initialisePorteurEnt()
    initialiseAnneeScolaireEnvDevelopmentTest()
    initialiseEtablissementsEnvDevelopmentTest()

    initialiseMatieresEnvDevelopmentTest()
    initialiseNiveauxEnvDevelopmentTest()

    initialiseStructuresEnseignementsEnvDevelopmentTest()

    initialiseProprietesScolaritesEnseignantEnvDevelopmentTest()
    initialiseEnseignant1EnvDevelopment()
    initialiseEnseignant2EnvDevelopment()
    initialiseProfilsScolaritesEnseignant1EnvDevelopment()
    initialiseProfilsScolaritesEnseignant2EnvDevelopment()
    initialiseEleve1EnvDevelopment()
    initialiseProprietesScolaritesEleveEnvDevelopmentTest()
    initialiseProfilsScolaritesEleve1EnvDevelopment()
    changeLoginAliasMotdePassePourEnseignant1()
    changeLoginAliasMotdePassePourEnseignant2()
    initialiseEleve2EnvDevelopment()
    initialiseRespEleve1EnvDevelopment()
  }

  /**
   * Initialise les données pour des tests d'intégration
   */
  def bootstrapForIntegrationTest() {
    if (Environment.current == Environment.TEST) {
      initialisePorteurEnt()
      initialiseAnneeScolaireEnvDevelopmentTest()
      initialiseEtablissementsEnvDevelopmentTest()

      initialiseMatieresEnvDevelopmentTest()
      initialiseNiveauxEnvDevelopmentTest()
      initialiseStructuresEnseignementsEnvDevelopmentTest()

      initialiseProprietesScolaritesEnseignantEnvDevelopmentTest()
      initialiseProprietesScolaritesEleveEnvDevelopmentTest()
    }

  }



  private def changeLoginAliasMotdePassePourEnseignant1() {
    def ens1 = utilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN_ALIAS)
    if (!ens1) {
      ens1 = utilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN)
      if (ens1) {
        utilisateurService.setAliasLogin(UTILISATEUR_1_LOGIN, UTILISATEUR_1_LOGIN_ALIAS)
        ens1.password = UTILISATEUR_1_PASSWORD
        utilisateurService.updateUtilisateur(UTILISATEUR_1_LOGIN, ens1)
      }
    }
  }

    private def changeLoginAliasMotdePassePourEnseignant2() {
        def ens = utilisateurService.findUtilisateur(UTILISATEUR_2_LOGIN_ALIAS)
        if (!ens) {
            ens = utilisateurService.findUtilisateur(UTILISATEUR_2_LOGIN)
            if (ens) {
                utilisateurService.setAliasLogin(UTILISATEUR_2_LOGIN, UTILISATEUR_2_LOGIN_ALIAS)
                ens.password = UTILISATEUR_2_PASSWORD
                utilisateurService.updateUtilisateur(UTILISATEUR_2_LOGIN, ens)
            }
        }
    }



  private def initialiseEnseignant1EnvDevelopment() {
    if (!utilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN)) {
      utilisateurService.createUtilisateur(UTILISATEUR_1_LOGIN,
          UTILISATEUR_1_PASSWORD,
          UTILISATEUR_1_NOM,
          UTILISATEUR_1_PRENOM)
    }
  }

    private def initialiseEnseignant2EnvDevelopment() {
        if (!utilisateurService.findUtilisateur(UTILISATEUR_2_LOGIN)) {
            utilisateurService.createUtilisateur(UTILISATEUR_2_LOGIN,
                    UTILISATEUR_2_PASSWORD,
                    UTILISATEUR_2_NOM,
                    UTILISATEUR_2_PRENOM)
        }
    }

  StructureEnseignement classe1ere
  StructureEnseignement classe6eme
  StructureEnseignement grpe1ere
  StructureEnseignement classeTerminale

  private def initialiseStructuresEnseignementsEnvDevelopmentTest() {
    if (!StructureEnseignement.findAllByCodeLike("${CODE_STRUCTURE_PREFIXE}%")) {
      classe6eme = new StructureEnseignement(etablissement: leCollege,
          anneeScolaire: anneeScolaire,
          code: "${CODE_STRUCTURE_PREFIXE}_6ème1",
          idExterne: "${leCollege.uai}.${CODE_STRUCTURE_PREFIXE}_6ème1",
          type: StructureEnseignement.TYPE_CLASSE,
          niveau: nivSixieme,
          groupeEnt: false,
          actif: true).save(failOnError: true)
      classe1ere = new StructureEnseignement(etablissement: leLycee,
          anneeScolaire: anneeScolaire,
          code: "${CODE_STRUCTURE_PREFIXE}_1ereA",
          idExterne: "${leLycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA",
          type: StructureEnseignement.TYPE_CLASSE,
          niveau: nivPremiere,
          groupeEnt: false,
          actif: true).save(failOnError: true)
      
      grpe1ere = new StructureEnseignement(etablissement: leLycee,
          anneeScolaire: anneeScolaire,
          code: "${CODE_STRUCTURE_PREFIXE}_1ereA_G1",
          idExterne: "${leLycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA_G1",
          type: StructureEnseignement.TYPE_GROUPE,
          groupeEnt: true,
          actif: true).save(failOnError: true)


      classeTerminale = new StructureEnseignement(etablissement: leLycee,
          anneeScolaire: anneeScolaire,
          code: "${CODE_STRUCTURE_PREFIXE}_Terminale_D",
          idExterne: "${leLycee.uai}.${CODE_STRUCTURE_PREFIXE}_Terminale_D",
          type: StructureEnseignement.TYPE_CLASSE,
          niveau: nivTerminale,
          groupeEnt: false,
          actif: true).save(failOnError: true)

      grpe1ere.addToClasses(classe1ere)
      grpe1ere.addToClasses(classeTerminale)
      grpe1ere.save(failOnError: true, flush: true)

    } else {
      classe6eme = StructureEnseignement.findByCode("${CODE_STRUCTURE_PREFIXE}_6ème1")
      classe1ere = StructureEnseignement.findByCode("${CODE_STRUCTURE_PREFIXE}_1ereA")
      grpe1ere = StructureEnseignement.findByCode("${CODE_STRUCTURE_PREFIXE}_1ereA_G1")
      classeTerminale = StructureEnseignement.findByCode("${CODE_STRUCTURE_PREFIXE}_Terminale_D")
      grpe1ere.groupeEnt = true
      grpe1ere.save(failOnError: true, flush: true)
    }
  }

  Etablissement leLycee
  Etablissement leCollege

  private def initialiseEtablissementsEnvDevelopmentTest() {
    if (!Etablissement.findAllByUaiLike("${UAI_PREFIXE}%")) {
      leLycee = new Etablissement(
          uai: UAI_LYCEE,
          nomAffichage: "Lycée Montaigne",
          idExterne: UAI_LYCEE).save(failOnError: true)
      leCollege = new Etablissement(
          uai: UAI_COLLEGE,
          nomAffichage: "Collège Pascal",
          idExterne: UAI_COLLEGE).save(failOnError: true, flush: true)
    } else {
      leLycee = Etablissement.findByUai(UAI_LYCEE)
      leCollege = Etablissement.findByUai(UAI_COLLEGE)
    }
  }

  AnneeScolaire anneeScolaire

  private def initialiseAnneeScolaireEnvDevelopmentTest() {
    anneeScolaire = AnneeScolaire.findByAnneeEnCours(true)
    if (!anneeScolaire) {
      anneeScolaire = new AnneeScolaire(code: "${CODE_ANNEE_SCOLAIRE_PREFIXE}_2011-2012",
          anneeEnCours: true).save(flush: true, failOnError: true)
    }
    assert anneeScolaire != null

  }


  Matiere matiereSES
  Matiere matiereSESSpe
  Matiere matiereHistoire
  Matiere matiereGeographie
  Matiere matiereCommunication
  Matiere matiereAnglais
  Matiere matiereMaths

  private def initialiseMatieresEnvDevelopmentTest() {
    if (!Matiere.findAllByCodeGestionLike("${CODE_GESTION_PREFIXE}%")) {

      matiereMaths = new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_1",
          etablissement: leLycee,
          libelleEdition: "Mathématiques",
          libelleCourt: "Mathématiques",
          libelleLong: "Mathématiques",
          anneeScolaire: anneeScolaire).save(failOnError: true)

      matiereSES = new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_2",
          etablissement: leLycee,
          libelleEdition: "SES",
          libelleCourt: "SES",
          libelleLong: "SES",
          anneeScolaire: anneeScolaire).save(failOnError: true)
      matiereSESSpe = new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_3",
          etablissement: leLycee,
          libelleEdition: "SES Spécialité",
          libelleCourt: "SES Spécialité",
          libelleLong: "SES Spécialité",
          anneeScolaire: anneeScolaire).save(failOnError: true)
      matiereHistoire = new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_4",
          etablissement: leCollege,
          libelleEdition: "Histoire",
          libelleCourt: "Histoire",
          libelleLong: "Histoire",
          anneeScolaire: anneeScolaire).save(failOnError: true)
      matiereGeographie = new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_5",
          etablissement: leCollege,
          libelleEdition: "Géographie",
          libelleCourt: "Géographie",
          libelleLong: "Géographie",
          anneeScolaire: anneeScolaire).save(failOnError: true)
      matiereCommunication = new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_6",
          etablissement: leLycee,
          libelleEdition: "Communication",
          libelleCourt: "Communication",
          libelleLong: "Communication",
          anneeScolaire: anneeScolaire).save(failOnError: true)
      matiereAnglais = new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_7",
          etablissement: leLycee,
          libelleEdition: "Anglais",
          libelleCourt: "Anglais",
          libelleLong: "Anglais",
          anneeScolaire: anneeScolaire).save(failOnError: true, flush: true)
    } else {
      matiereMaths = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_1")
      matiereSES = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_2")
      matiereSESSpe = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_3")
      matiereHistoire = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_4")
      matiereGeographie = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_5")
      matiereCommunication = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_6")
      matiereAnglais = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_7")
    }
  }

  Niveau nivPremiere
  Niveau nivTerminale
  Niveau nivSixieme
  Niveau nivBTS1
  Niveau nivBTS2

  private def initialiseNiveauxEnvDevelopmentTest() {
    if (!Niveau.findAllByLibelleCourtLike("${CODE_MEFSTAT4_PREFIXE}%")) {
      nivPremiere = new Niveau(libelleCourt: "${CODE_MEFSTAT4_PREFIXE}_1",
          libelleLong: "Première").save(failOnError: true)
      nivTerminale = new Niveau(libelleCourt: "${CODE_MEFSTAT4_PREFIXE}_2",
          libelleLong: "Terminale").save(failOnError: true)
      nivBTS1 = new Niveau(libelleCourt: "${CODE_MEFSTAT4_PREFIXE}_3",
          libelleLong: "BTS 1").save(failOnError: true)
      nivBTS2 = new Niveau(libelleCourt: "${CODE_MEFSTAT4_PREFIXE}_4",
          libelleLong: "BTS 2").save(failOnError: true)
      nivSixieme = new Niveau(libelleCourt: "${CODE_MEFSTAT4_PREFIXE}_5",
          libelleLong: "6ème").save(failOnError: true, flush: true)

    } else {
      nivPremiere = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_1")
      nivTerminale = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_2")
      nivBTS1 = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_3")
      nivBTS2 = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_4")
      nivSixieme = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_5")
    }
  }





  private def initialiseProprietesScolaritesEnseignantEnvDevelopmentTest() {

    Fonction fonctionEnseignant = fonctionService.fonctionEnseignant()

    if (!ProprietesScolarite.findAllByStructureEnseignementAndFonctionAndAnneeScolaire(
        classe6eme,
        fonctionEnseignant,
        anneeScolaire
    )) {
      new ProprietesScolarite(anneeScolaire: anneeScolaire,
          fonction: fonctionEnseignant,
          structureEnseignement: classe6eme).save(failOnError: true)
    }

    if (!ProprietesScolarite.findAllByStructureEnseignementAndFonctionAndAnneeScolaire(
        grpe1ere,
        fonctionEnseignant,
        anneeScolaire
    )) {
      new ProprietesScolarite(anneeScolaire: anneeScolaire,
          fonction: fonctionEnseignant,
          structureEnseignement: grpe1ere).save(failOnError: true)
    }

    if (!ProprietesScolarite.findAllByStructureEnseignementAndFonctionAndAnneeScolaire(
        classeTerminale,
        fonctionEnseignant,
        anneeScolaire
    )) {
      new ProprietesScolarite(anneeScolaire: anneeScolaire,
          fonction: fonctionEnseignant,
          structureEnseignement: classeTerminale).save(failOnError: true)
    }

    if (!ProprietesScolarite.findAllByStructureEnseignementAndFonctionAndAnneeScolaire(
        classe1ere,
        fonctionEnseignant,
        anneeScolaire
    )) {
      new ProprietesScolarite(anneeScolaire: anneeScolaire,
          fonction: fonctionEnseignant,
          structureEnseignement: classe1ere).save(failOnError: true)
    }

    if (!ProprietesScolarite.findAllByEtablissementAndFonctionAndAnneeScolaireAndMatiere(
        leCollege,
        fonctionEnseignant,
        anneeScolaire,
        matiereHistoire
    )) {
      new ProprietesScolarite(anneeScolaire: anneeScolaire,
          fonction: fonctionEnseignant,
          etablissement: leCollege,
          matiere: matiereHistoire).save(failOnError: true)
    }

    if (!ProprietesScolarite.findAllByEtablissementAndFonctionAndAnneeScolaireAndMatiere(
        leLycee,
        fonctionEnseignant,
        anneeScolaire,
        matiereSES
    )) {
      new ProprietesScolarite(anneeScolaire: anneeScolaire,
          fonction: fonctionEnseignant,
          etablissement: leLycee,
          matiere: matiereSES).save(failOnError: true)
    }

    if (!ProprietesScolarite.findAllByEtablissementAndFonctionAndAnneeScolaireAndMatiere(
        leLycee,
        fonctionEnseignant,
        anneeScolaire,
        matiereMaths
    )) {
      new ProprietesScolarite(anneeScolaire: anneeScolaire,
          fonction: fonctionEnseignant,
          etablissement: leLycee,
          matiere: matiereMaths).save(failOnError: true)
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

    private def initialiseProfilsScolaritesEnseignant2EnvDevelopment() {
        Utilisateur ens2 = utilisateurService.findUtilisateur(UTILISATEUR_2_LOGIN)
        Personne pers2 = Personne.get(ens2.personneId)
        if (!profilScolariteService.findProprietesScolaritesForPersonne(pers2)) {
            def props = ProprietesScolarite.findAllByFonction(fonctionService.fonctionEnseignant())
            addProprietesScolariteToPersonne(props, pers2)
        }
    }

  private def initialiseEleve1EnvDevelopment() {
    if (!utilisateurService.findUtilisateur(ELEVE_1_LOGIN)) {
      utilisateurService.createUtilisateur(ELEVE_1_LOGIN,
          ELEVE_1_PASSWORD,
          ELEVE_1_NOM,
          ELEVE_1_PRENOM)
    }
  }

  private def initialiseProprietesScolaritesEleveEnvDevelopmentTest() {

    Fonction fonctionEleve = fonctionService.fonctionEleve()

    if (!ProprietesScolarite.findByStructureEnseignementAndFonctionAndAnneeScolaire(
        classe6eme,
        fonctionEleve,
        anneeScolaire
    )){
      new ProprietesScolarite(anneeScolaire: anneeScolaire,
          fonction: fonctionEleve,
          structureEnseignement: classe6eme).save(failOnError: true)
    }

    if (!ProprietesScolarite.findByStructureEnseignementAndFonctionAndAnneeScolaire(
        grpe1ere,
        fonctionEleve,
        anneeScolaire
    )){
      new ProprietesScolarite(anneeScolaire: anneeScolaire,
          fonction: fonctionEleve,
          structureEnseignement: grpe1ere).save(failOnError: true)
    }

    if (!ProprietesScolarite.findByStructureEnseignementAndFonctionAndAnneeScolaire(
        classeTerminale,
        fonctionEleve,
        anneeScolaire
    )){
      new ProprietesScolarite(anneeScolaire: anneeScolaire,
          fonction: fonctionEleve,
          structureEnseignement: classeTerminale).save(failOnError: true)
    }

    if (!ProprietesScolarite.findByStructureEnseignementAndFonctionAndAnneeScolaire(
        classe1ere,
        fonctionEleve,
        anneeScolaire
    )){
      new ProprietesScolarite(anneeScolaire: anneeScolaire,
          fonction: fonctionEleve,
          structureEnseignement: classe1ere).save(failOnError: true)
    }

  }

  private def initialiseProfilsScolaritesEleve1EnvDevelopment() {
    Utilisateur elv1 = utilisateurService.findUtilisateur(ELEVE_1_LOGIN)
    Personne pers1 = Personne.get(elv1.personneId)
    Niveau niveauPrem = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_1")

    if (!profilScolariteService.findProprietesScolaritesForPersonne(pers1)) {
      def props = ProprietesScolarite.findAllByFonction(fonctionService.fonctionEleve())
      addProprietesScolariteToPersonne(props, pers1)
    }
  }

  private def initialiseEleve2EnvDevelopment() {
    if (!utilisateurService.findUtilisateur(ELEVE_2_LOGIN)) {
      utilisateurService.createUtilisateur(ELEVE_2_LOGIN,
          ELEVE_2_PASSWORD,
          ELEVE_2_NOM,
          ELEVE_2_PRENOM)
      Utilisateur elv2 = utilisateurService.findUtilisateur(ELEVE_2_LOGIN)
      Personne pers = Personne.get(elv2.personneId)
      Niveau niveauPrem = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_1")

      def props = ProprietesScolarite.findAllByFonction(fonctionService.fonctionEleve())
      addProprietesScolariteToPersonne(props, pers)

    }
  }

  private def initialiseRespEleve1EnvDevelopment() {
    if (!utilisateurService.findUtilisateur(RESP_1_LOGIN)) {
      utilisateurService.createUtilisateur(RESP_1_LOGIN,
          RESP_1_PASSWORD,
          RESP_1_NOM,
          RESP_1_PRENOM)
      Utilisateur resp1 = utilisateurService.findUtilisateur(RESP_1_LOGIN)
      Personne pers = Personne.get(resp1.personneId)
      Utilisateur elv1 = utilisateurService.findUtilisateur(ELEVE_1_LOGIN)
      Personne perselv1 = Personne.get(elv1.personneId)
      Utilisateur elv2 = utilisateurService.findUtilisateur(ELEVE_2_LOGIN)
      Personne perselv2 = Personne.get(elv2.personneId)
      createResponsableEleve(pers, perselv1)
      createResponsableEleve(pers, perselv2)

    }
  }

  private def initialisePorteurEnt() {
    PorteurEnt porteurEnt = PorteurEnt.findByCode(DEFAULT_CODE_PORTEUR_ENT)
    if (!porteurEnt) {
      porteurEnt = new PorteurEnt(code: DEFAULT_CODE_PORTEUR_ENT,
          urlAccesEnt: DEFAULT_URL_ACCES_ENT,
          urlRetourLogout: DEFAULT_URL_RETOUR_LOGOUT,
          nom: 'Porteur Default pour tests et dev',
          nomCourt: 'Porteur Default',
          parDefaut: true).save(failOnError: true, flush: true)
    }
    return porteurEnt
  }

  // methode utilitaires

  private ResponsableEleve createResponsableEleve(Personne resp, Personne eleve) {
    ResponsableEleve responsableEleve = new ResponsableEleve(personne: resp,
        eleve: eleve,
        estActive: true,
        responsableLegal: 1).save(failOnError: true)
    // groupes auxquels appartient l'élève
    def groupes = profilScolariteService.findProprietesScolaritesForPersonne(eleve)
    def groupesDeRespEleve = []

    Fonction fonctionResp = fonctionService.fonctionResponsableEleve()
    Fonction fonctionEleve = fonctionService.fonctionEleve()

    // pour chaque groupe d'élèves auxquels appartient l'élève, on créé un groupe
    // de responsables d'élèves s'il n'existe pas déjà
    groupes.each { ProprietesScolarite groupe ->
      if (groupe.fonction == fonctionEleve) {
        PorteurEnt porteurEnt =
          groupe.structureEnseignement.etablissement.porteurEnt ?: initialisePorteurEnt()

        AnneeScolaire anneeScolaire = groupe.anneeScolaire

        ProprietesScolarite ps = ProprietesScolarite.createCriteria().get{
          eq 'anneeScolaire', anneeScolaire
          eq 'fonction', fonctionResp
          eq 'porteurEnt', porteurEnt
        }

        if (!ps){
          // créer un groupe de responsables élèves
          groupesDeRespEleve << new ProprietesScolarite(anneeScolaire: anneeScolaire,
              fonction: fonctionResp,
              porteurEnt: porteurEnt).save(flush : true, failOnError: true)
        }
      }
    }
    addProprietesScolariteToPersonne(groupesDeRespEleve, resp)
    return responsableEleve
  }

  /**
   * Ajoute les propriétés de scolarité à la personne passée en paramètre
   * @param proprietesScolariteList la liste des proprietes de scolarite à ajouter
   * @param personne la personne
   */
  private def addProprietesScolariteToPersonne(List<ProprietesScolarite> proprietesScolariteList,
                                               Personne personne) {
    proprietesScolariteList.each { ProprietesScolarite proprietesScolarite ->
      def ppp = new PersonneProprietesScolarite(personne: personne,
          proprietesScolarite: proprietesScolarite,
          estActive: true)
      ppp.save(failOnError: true)
      if (ppp.hasErrors()) {
        ppp.errors.allErrors.each {
          println ">>>>> PPP ERROR $it"
        }
      }
    }
    sessionFactory.currentSession.flush()

  }


}
