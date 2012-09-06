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
import org.lilie.services.eliot.tice.securite.Perimetre
import org.lilie.services.eliot.tice.scolarite.*

class BootstrapService {

  static transactional = false
  public static final String DEMO_ENVIRONMENT = "demo"
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


  private List<ProprietesScolarite> proprietesScolariteListUtilisateur1 = []

  /**
   * Initialise l'application au lancement avec un jeu de test
   */
  def bootstrapJeuDeTestDevDemo() {
    initialiseAnneeScolaireEnvDevelopmentTest()
    initialiseEtablissementsEnvDevelopmentTest()
    initialiseMatieresEnvDevelopmentTest()
    initialiseNiveauxEnvDevelopmentTest()

    initialiseStructuresEnseignementsEnvDevelopmentTest()
    initialiseProprietesScolaritesEnseignantEnvDevelopmentTest()
    initialiseEnseignant1EnvDevelopment()
    initialiseProfilsScolaritesEnseignant1EnvDevelopment()
    initialiseEleve1EnvDevelopment()
    initialiseProprietesScolaritesEleveEnvDevelopmentTest()
    initialiseProfilsScolaritesEleve1EnvDevelopment()
    changeLoginAliasMotdePassePourEnseignant1()
    initialiseEleve2EnvDevelopment()
    initialiseRespEleve1EnvDevelopment()
    initialisePorteurEnt()
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
      initialiseProprietesScolaritesEleveEnvDevelopmentTest()
      initialisePorteurEnt()
    }

  }

  def findStruct1ere() {
    Etablissement lycee = Etablissement.findByUai(UAI_LYCEE)
    return StructureEnseignement.findByIdExterne("${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA")
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



  private def initialiseEnseignant1EnvDevelopment() {
    if (!utilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN)) {
      utilisateurService.createUtilisateur(UTILISATEUR_1_LOGIN,
                                           UTILISATEUR_1_PASSWORD,
                                           UTILISATEUR_1_NOM,
                                           UTILISATEUR_1_PRENOM)
    }
  }



  private def initialiseStructuresEnseignementsEnvDevelopmentTest() {
    if (!StructureEnseignement.findAllByCodeLike("${CODE_STRUCTURE_PREFIXE}%")) {
      Niveau niveau6 = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_5")
      Niveau niveauPrem = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_1")
      Niveau niveauTerm = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_2")
      Etablissement lycee = Etablissement.findByUai(UAI_LYCEE)
      Etablissement college = Etablissement.findByUai(UAI_COLLEGE)
      AnneeScolaire anneeScolaire = AnneeScolaire.findByAnneeEnCours(true)
      new StructureEnseignement(etablissement: college,
                                anneeScolaire: anneeScolaire,
                                code: "${CODE_STRUCTURE_PREFIXE}_6ème1",
                                idExterne: "${college.uai}.${CODE_STRUCTURE_PREFIXE}_6ème1",
                                type: StructureEnseignement.TYPE_CLASSE,
                                niveau: niveau6,
                                actif: true).save()
      new StructureEnseignement(etablissement: lycee,
                                anneeScolaire: anneeScolaire,
                                code: "${CODE_STRUCTURE_PREFIXE}_1ereA",
                                idExterne: "${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA",
                                type: StructureEnseignement.TYPE_CLASSE,
                                niveau: niveauPrem,
                                actif: true).save()
      new StructureEnseignement(etablissement: lycee,
                                anneeScolaire: anneeScolaire,
                                code: "${CODE_STRUCTURE_PREFIXE}_1ereA_G1",
                                idExterne: "${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA_G1",
                                type: StructureEnseignement.TYPE_GROUPE,
                                actif: true).save()
      new StructureEnseignement(etablissement: lycee,
                                anneeScolaire: anneeScolaire,
                                code: "${CODE_STRUCTURE_PREFIXE}_Terminale_D",
                                idExterne: "${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_Terminale_D",
                                type: StructureEnseignement.TYPE_CLASSE,
                                niveau: niveauTerm,
                                actif: true).save(flush: true)

    }
  }

  private def initialiseEtablissementsEnvDevelopmentTest() {
    if (!Etablissement.findAllByUaiLike("${UAI_PREFIXE}%")) {
      new Etablissement(codePorteurENT: DEFAULT_CODE_PORTEUR_ENT,
                        uai: UAI_LYCEE,
                        nomAffichage: "Lycée Montaigne",
                        idExterne: UAI_LYCEE).save()
      new Etablissement(codePorteurENT: DEFAULT_CODE_PORTEUR_ENT,
                        uai: UAI_COLLEGE,
                        nomAffichage: "Collège Pascal",
                        idExterne: UAI_COLLEGE).save(flush: true)
    }
  }

  private def initialiseAnneeScolaireEnvDevelopmentTest() {
    if (!AnneeScolaire.findByAnneeEnCours(true)) {
      new AnneeScolaire(code: "${CODE_ANNEE_SCOLAIRE_PREFIXE}_2011-2012",
                        anneeEnCours: true,).save(flush: true)
    }
  }



  private def initialiseMatieresEnvDevelopmentTest() {
    if (!Matiere.findAllByCodeGestionLike("${CODE_GESTION_PREFIXE}%")) {
      AnneeScolaire anneeScolaire = AnneeScolaire.findByAnneeEnCours(true)
      Etablissement lycee = Etablissement.findByUai(UAI_LYCEE)
      Etablissement college = Etablissement.findByUai(UAI_COLLEGE)
      def mat1 = new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_1",
                             etablissement: lycee,
                             libelleEdition: "Mathématiques",
                             libelleCourt: "Mathématiques",
                             libelleLong: "Mathématiques",
                             anneeScolaire: anneeScolaire)
      mat1.save()

      new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_2",
                  etablissement: lycee,
                  libelleEdition: "SES",
                  libelleCourt: "SES",
                  libelleLong: "SES",
                  anneeScolaire: anneeScolaire).save()
      new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_3",
                  etablissement: lycee,
                  libelleEdition: "SES Spécialité",
                  libelleCourt: "SES Spécialité",
                  libelleLong: "SES Spécialité",
                  anneeScolaire: anneeScolaire).save()
      new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_4",
                  etablissement: college,
                  libelleEdition: "Histoire",
                  libelleCourt: "Histoire",
                  libelleLong: "Histoire",
                  anneeScolaire: anneeScolaire).save()
      new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_5",
                  etablissement: college,
                  libelleEdition: "Géographie",
                  libelleCourt: "Géographie",
                  libelleLong: "Géographie",
                  anneeScolaire: anneeScolaire).save()
      new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_6",
                  etablissement: lycee,
                  libelleEdition: "Communication",
                  libelleCourt: "Communication",
                  libelleLong: "Communication",
                  anneeScolaire: anneeScolaire).save()
      new Matiere(codeGestion: "${CODE_GESTION_PREFIXE}_7",
                  etablissement: lycee,
                  libelleEdition: "Anglais",
                  libelleCourt: "Anglais",
                  libelleLong: "Anglais",
                  anneeScolaire: anneeScolaire).save(flush: true)
    }
  }

  private def initialiseNiveauxEnvDevelopmentTest() {
    if (!Niveau.findAllByLibelleCourtLike("${CODE_MEFSTAT4_PREFIXE}%")) {
      new Niveau(libelleCourt: "${CODE_MEFSTAT4_PREFIXE}_1",
                 libelleLong: "Première").save()
      new Niveau(libelleCourt: "${CODE_MEFSTAT4_PREFIXE}_2",
                 libelleLong: "Terminale").save()
      new Niveau(libelleCourt: "${CODE_MEFSTAT4_PREFIXE}_3",
                 libelleLong: "BTS 1").save()
      new Niveau(libelleCourt: "${CODE_MEFSTAT4_PREFIXE}_4",
                 libelleLong: "BTS 2").save()
      new Niveau(libelleCourt: "${CODE_MEFSTAT4_PREFIXE}_5",
                 libelleLong: "6ème").save(flush: true)

    }
  }


  private def initialiseProprietesScolaritesEnseignantEnvDevelopmentTest() {
    Etablissement lycee = Etablissement.findByUai(UAI_LYCEE)
    if (!ProprietesScolarite.findAllByEtablissementAndFonction(lycee, fonctionService.fonctionEnseignant())) {
      Etablissement college = Etablissement.findByUai(UAI_COLLEGE)
      AnneeScolaire anneeScolaire = AnneeScolaire.findByAnneeEnCours(true)
      Niveau niveau6 = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_5")
      Niveau niveauPrem = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_1")
      Niveau niveauTerm = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_2")
      Matiere matiereMaths = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_1")
      Matiere matiereSES = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_2")
      Matiere matiereHistoire = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_4")
      StructureEnseignement struct6eme = StructureEnseignement.findByIdExterne("${college.uai}.${CODE_STRUCTURE_PREFIXE}_6ème1")
      StructureEnseignement struct1ere = StructureEnseignement.findByIdExterne("${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA")
      StructureEnseignement structGr1ere = StructureEnseignement.findByIdExterne("${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA_G1")
      StructureEnseignement structTerm = StructureEnseignement.findByIdExterne("${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_Terminale_D")

      def prop1 = new ProprietesScolarite(anneeScolaire: anneeScolaire,
                                          fonction: fonctionService.fonctionEnseignant(),
                                          etablissement: college,
                                          matiere: matiereHistoire,
                                          niveau: niveau6,
                                          structureEnseignement: struct6eme).save()

      if (prop1.hasErrors()) {
        prop1.errors.allErrors.each {
          println ">>>>> PROP ERROR $it"
        }
      }

      new ProprietesScolarite(anneeScolaire: anneeScolaire,
                              fonction: fonctionService.fonctionEnseignant(),
                              etablissement: lycee,
                              matiere: matiereSES,
                              niveau: niveauPrem,
                              structureEnseignement: structGr1ere).save()

      new ProprietesScolarite(anneeScolaire: anneeScolaire,
                              fonction: fonctionService.fonctionEnseignant(),
                              etablissement: lycee,
                              matiere: matiereMaths,
                              niveau: niveauTerm,
                              structureEnseignement: structTerm).save()

      new ProprietesScolarite(anneeScolaire: anneeScolaire,
                              fonction: fonctionService.fonctionEnseignant(),
                              etablissement: lycee,
                              matiere: matiereMaths,
                              niveau: niveauPrem,
                              structureEnseignement: struct1ere).save(flush: true)

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

  private def initialiseEleve1EnvDevelopment() {
    if (!utilisateurService.findUtilisateur(ELEVE_1_LOGIN)) {
      utilisateurService.createUtilisateur(ELEVE_1_LOGIN,
                                           ELEVE_1_PASSWORD,
                                           ELEVE_1_NOM,
                                           ELEVE_1_PRENOM)
    }
  }

  private def initialiseProprietesScolaritesEleveEnvDevelopmentTest() {
    Etablissement lycee = Etablissement.findByUai(UAI_LYCEE)
    if (!ProprietesScolarite.findAllByEtablissementAndFonction(lycee, fonctionService.fonctionEleve())) {
      Etablissement college = Etablissement.findByUai(UAI_COLLEGE)
      AnneeScolaire anneeScolaire = AnneeScolaire.findByAnneeEnCours(true)
      Niveau niveau6 = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_5")
      Niveau niveauPrem = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_1")
      Niveau niveauTerm = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_2")
      Matiere matiereMaths = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_1")
      Matiere matiereSES = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_2")
      Matiere matiereHistoire = Matiere.findByCodeGestion("${CODE_GESTION_PREFIXE}_4")
      StructureEnseignement struct6eme = StructureEnseignement.findByIdExterne("${college.uai}.${CODE_STRUCTURE_PREFIXE}_6ème1")
      StructureEnseignement struct1ere = StructureEnseignement.findByIdExterne("${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA")
      StructureEnseignement structGr1ere = StructureEnseignement.findByIdExterne("${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_1ereA_G1")
      StructureEnseignement structTerm = StructureEnseignement.findByIdExterne("${lycee.uai}.${CODE_STRUCTURE_PREFIXE}_Terminale_D")

      def prop1 = new ProprietesScolarite(anneeScolaire: anneeScolaire,
                                          fonction: fonctionService.fonctionEleve(),
                                          etablissement: college,
                                          matiere: matiereHistoire,
                                          niveau: niveau6,
                                          structureEnseignement: struct6eme).save()

      if (prop1.hasErrors()) {
        prop1.errors.allErrors.each {
          println ">>>>> PROP ERROR $it"
        }
      }

      new ProprietesScolarite(anneeScolaire: anneeScolaire,
                              fonction: fonctionService.fonctionEleve(),
                              etablissement: lycee,
                              matiere: matiereSES,
                              niveau: niveauPrem,
                              structureEnseignement: structGr1ere).save()

      new ProprietesScolarite(anneeScolaire: anneeScolaire,
                              fonction: fonctionService.fonctionEleve(),
                              etablissement: lycee,
                              matiere: matiereMaths,
                              niveau: niveauTerm,
                              structureEnseignement: structTerm).save()

      new ProprietesScolarite(anneeScolaire: anneeScolaire,
                              fonction: fonctionService.fonctionEleve(),
                              etablissement: lycee,
                              matiere: matiereMaths,
                              niveau: niveauPrem,
                              structureEnseignement: struct1ere).save(flush: true)

    }

  }

  private def initialiseProfilsScolaritesEleve1EnvDevelopment() {
    Utilisateur elv1 = utilisateurService.findUtilisateur(ELEVE_1_LOGIN)
    Personne pers1 = Personne.get(elv1.personneId)
    Niveau niveauPrem = Niveau.findByLibelleCourt("${CODE_MEFSTAT4_PREFIXE}_1")

    if (!profilScolariteService.findProprietesScolaritesForPersonne(pers1)) {
      def props = ProprietesScolarite.findAllByFonctionAndNiveau(fonctionService.fonctionEleve(), niveauPrem)
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

      def props = ProprietesScolarite.findAllByFonctionAndNiveau(fonctionService.fonctionEleve(), niveauPrem)
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
      Perimetre perimetre = new Perimetre(estActive: true,
                                          nomEntiteCible: PorteurEnt.class.name).save()
      porteurEnt = new PorteurEnt(code: DEFAULT_CODE_PORTEUR_ENT,
                                  perimetre: perimetre,
                                  urlAccesEnt: DEFAULT_URL_ACCES_ENT,
                                  urlRetourLogout: DEFAULT_URL_RETOUR_LOGOUT,
                                  nom: 'Porteur Default pour tests et dev',
                                  nomCourt: 'Porteur Default').save()
      perimetre.enregistrementCibleId = porteurEnt.id
      perimetre.save()
    }


  }

  // methode utilitaires

  private ResponsableEleve createResponsableEleve(Personne resp, Personne eleve) {
    ResponsableEleve responsableEleve = new ResponsableEleve(personne: resp,
                                                             eleve: eleve,
                                                             estActive: true,
                                                             responsableLegal: 1).save()
    def profilsEleve = profilScolariteService.findProprietesScolaritesForPersonne(eleve)
    def propsResp = []
    profilsEleve.each { ProprietesScolarite props ->
      if (props.fonction == fonctionService.fonctionEleve()) {
        propsResp << new ProprietesScolarite(anneeScolaire: props.anneeScolaire,
                                             fonction: fonctionService.fonctionResponsableEleve(),
                                             etablissement: props.etablissement,
                                             matiere: props.matiere,
                                             niveau: props.niveau,
                                             structureEnseignement: props.structureEnseignement).save()
      }
    }
    addProprietesScolariteToPersonne(propsResp, resp)
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
      ppp.save()
      if (ppp.hasErrors()) {
        ppp.errors.allErrors.each {
          println ">>>>> PPP ERROR $it"
        }
      }
    }
    sessionFactory.currentSession.flush()

  }


}
