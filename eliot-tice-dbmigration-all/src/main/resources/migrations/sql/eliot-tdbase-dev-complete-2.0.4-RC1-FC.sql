--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
-- SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: aaf; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA aaf;


--
-- Name: bascule_annee; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA bascule_annee;


--
-- Name: ent; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ent;


--
-- Name: ent_2011_2012; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ent_2011_2012;


--
-- Name: entcdt; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA entcdt;


--
-- Name: entdemon; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA entdemon;


--
-- Name: entnotes; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA entnotes;


--
-- Name: entnotes_2011_2012; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA entnotes_2011_2012;


--
-- Name: enttemps; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA enttemps;


--
-- Name: enttemps_2011_2012; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA enttemps_2011_2012;


--
-- Name: forum; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA forum;


--
-- Name: impression; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA impression;


--
-- Name: securite; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA securite;


--
-- Name: td; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA td;


--
-- Name: tice; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tice;


--
-- Name: udt; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA udt;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

-- CloudFoundry - ne passe pas sur CloudFoundry
--CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

-- CloudFoundry - ne passe pas sur CloudFoundry
--COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = enttemps, pg_catalog;

--
-- Name: agenda_before_insert(); Type: FUNCTION; Schema: enttemps; Owner: -
--

CREATE FUNCTION agenda_before_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS '
      DECLARE
      code_type_agenda varchar(30); 
      agenda_id bigint; 

      BEGIN
      select code into code_type_agenda
      from enttemps.type_agenda as ta
      where ta.id = NEW.type_agenda_id; 

      -- Agenda de type calendrier scolaire
      IF code_type_agenda =''CSE'' THEN
      select agenda_id into agenda_id
      from enttemps.agenda as a
      join enttemps.type_agenda as t on (a.type_agenda_id = t.id)
      where t.code = ''CSE''
      and NEW.etablissement_id = a.etablissement_id; 

      IF FOUND THEN
      RAISE EXCEPTION ''Le calendrier scolaire existe déjà pour cet
      établissement''; 
      END IF; 

      ELSE
      --Agenda de type Structure d''enseignement
      IF code_type_agenda =''ETS'' THEN
      select agenda_id into agenda_id
      from enttemps.agenda as a
      join enttemps.type_agenda as t on (a.type_agenda_id = t.id)
      join ent.structure_enseignement as struct on (a.structure_enseignement_id
      = struct.id)
      where t.code = ''ETS''
      and NEW.structure_enseignement_id = a.structure_enseignement_id; 

      IF FOUND THEN
      RAISE EXCEPTION ''Agenda de structure existe déjà''; 
      END IF; 

      ELSE
      -- Agenda de type enseignant
      IF code_type_agenda =''ETE'' THEN
      select agenda_id into agenda_id
      from enttemps.agenda as a
      join enttemps.type_agenda as t on (a.type_agenda_id = t.id)
      join securite.autorite as aut on (a.enseignant_id = aut.id)
      where t.code = ''ETE''
      and NEW.etablissement_id = a.etablissement_id
      and NEW.enseignant_id = a.enseignant_id; 

      IF FOUND THEN
      RAISE EXCEPTION ''Agenda enseignant existe déjà''; 
      END IF; 

      END IF; 
      END IF; 
      END IF; 

      RETURN NEW; 
      END; 
      ';


SET search_path = aaf, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: import; Type: TABLE; Schema: aaf; Owner: -; Tablespace: 
--

CREATE TABLE import (
    id bigint NOT NULL,
    type_import character varying(32) NOT NULL,
    type_fichier character varying(32) NOT NULL,
    nom_fichier character varying(1024) NOT NULL,
    code_annee_scolaire character varying(16) NOT NULL,
    stats text,
    indice_fichier bigint,
    date_export_fichier timestamp without time zone,
    date_import timestamp without time zone NOT NULL,
    porteur character varying(128),
    academie character varying(128)
);


--
-- Name: import_id_seq; Type: SEQUENCE; Schema: aaf; Owner: -
--

CREATE SEQUENCE import_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_id_seq; Type: SEQUENCE SET; Schema: aaf; Owner: -
--

SELECT pg_catalog.setval('import_id_seq', 1, false);


--
-- Name: import_verrou; Type: TABLE; Schema: aaf; Owner: -; Tablespace: 
--

CREATE TABLE import_verrou (
    id bigint NOT NULL,
    verrou boolean DEFAULT false,
    import_id bigint,
    date_pose_verrou timestamp without time zone
);


SET search_path = bascule_annee, pg_catalog;

--
-- Name: etape; Type: TABLE; Schema: bascule_annee; Owner: -; Tablespace: 
--

CREATE TABLE etape (
    id bigint NOT NULL,
    index integer NOT NULL,
    module_code character varying(30) NOT NULL,
    etape_code character varying(128) NOT NULL,
    etat character varying(30) NOT NULL,
    date_debut timestamp with time zone,
    date_fin timestamp with time zone,
    operateur_id_externe character varying(128)
);


--
-- Name: etape_id_seq; Type: SEQUENCE; Schema: bascule_annee; Owner: -
--

CREATE SEQUENCE etape_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: etape_id_seq; Type: SEQUENCE SET; Schema: bascule_annee; Owner: -
--

SELECT pg_catalog.setval('etape_id_seq', 1, false);


--
-- Name: historique_id_seq; Type: SEQUENCE; Schema: bascule_annee; Owner: -
--

CREATE SEQUENCE historique_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: historique_id_seq; Type: SEQUENCE SET; Schema: bascule_annee; Owner: -
--

SELECT pg_catalog.setval('historique_id_seq', 1, false);


--
-- Name: verrou; Type: TABLE; Schema: bascule_annee; Owner: -; Tablespace: 
--

CREATE TABLE verrou (
    id bigint NOT NULL,
    module character varying(30) NOT NULL,
    operateur_id_externe character varying(128) NOT NULL,
    date_creation timestamp without time zone NOT NULL,
    nom character varying(30) NOT NULL
);


--
-- Name: verrou_id_seq; Type: SEQUENCE; Schema: bascule_annee; Owner: -
--

CREATE SEQUENCE verrou_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: verrou_id_seq; Type: SEQUENCE SET; Schema: bascule_annee; Owner: -
--

SELECT pg_catalog.setval('verrou_id_seq', 1, false);


SET search_path = ent, pg_catalog;

--
-- Name: annee_scolaire; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE annee_scolaire (
    code character varying(30) NOT NULL,
    version integer NOT NULL,
    annee_en_cours boolean,
    id bigint NOT NULL
);


--
-- Name: annee_scolaire_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE annee_scolaire_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: annee_scolaire_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('annee_scolaire_id_seq', 1, true);


--
-- Name: appartenance_groupe_groupe; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE appartenance_groupe_groupe (
    id bigint NOT NULL,
    groupe_personnes_parent_id bigint NOT NULL,
    groupe_personnes_enfant_id bigint NOT NULL
);


--
-- Name: appartenance_groupe_groupe_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE appartenance_groupe_groupe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appartenance_groupe_groupe_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('appartenance_groupe_groupe_id_seq', 1, false);


--
-- Name: appartenance_personne_groupe; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE appartenance_personne_groupe (
    id bigint NOT NULL,
    personne_id bigint NOT NULL,
    groupe_personnes_id bigint NOT NULL
);


--
-- Name: appartenance_personne_groupe_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE appartenance_personne_groupe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appartenance_personne_groupe_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('appartenance_personne_groupe_id_seq', 1, false);


--
-- Name: calendier_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE calendier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: calendier_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('calendier_id_seq', 1, false);


--
-- Name: calendrier; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE calendrier (
    id bigint NOT NULL,
    jour_semaine_ferie smallint NOT NULL,
    version integer NOT NULL,
    annee_scolaire_id bigint NOT NULL,
    premier_jour date NOT NULL,
    dernier_jour date NOT NULL,
    etablissement_id bigint NOT NULL
);


--
-- Name: civilite; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE civilite (
    id bigint NOT NULL,
    libelle character varying(5) NOT NULL
);


--
-- Name: civilite_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE civilite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: civilite_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('civilite_id_seq', 1, false);


--
-- Name: enseignement; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE enseignement (
    enseignant_id bigint NOT NULL,
    version integer NOT NULL,
    service_id integer NOT NULL,
    nb_heures double precision,
    version_import_sts integer DEFAULT (-1),
    actif boolean DEFAULT true,
    id bigint NOT NULL,
    origine character varying(10) DEFAULT 'AUTO'::character varying NOT NULL
);


--
-- Name: enseignement_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE enseignement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enseignement_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('enseignement_id_seq', 1, false);


--
-- Name: etablissement; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE etablissement (
    id bigint NOT NULL,
    id_externe character varying(128) NOT NULL,
    nom_affichage character varying(1024),
    version integer NOT NULL,
    uai character varying(10),
    version_import_sts integer DEFAULT 0,
    date_import_sts timestamp without time zone,
    code_porteur_ent character varying(10) DEFAULT 'CRIF'::character varying NOT NULL,
    perimetre_id bigint,
    porteur_ent_id bigint,
    etablissement_rattachement_id bigint,
    type_etablissement character varying(128),
    ministere_tutelle character varying(128),
    academie character varying(128),
    "precision" numeric DEFAULT 0.01 NOT NULL
);


--
-- Name: etablissement_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE etablissement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: etablissement_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('etablissement_id_seq', 1, false);


--
-- Name: fiche_eleve_commentaire; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE fiche_eleve_commentaire (
    id bigint NOT NULL,
    personne_id bigint NOT NULL,
    commentaire text
);


--
-- Name: fiche_eleve_commentaire_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE fiche_eleve_commentaire_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fiche_eleve_commentaire_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('fiche_eleve_commentaire_id_seq', 1, false);


--
-- Name: filiere; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE filiere (
    id bigint NOT NULL,
    id_externe character varying(30),
    libelle character varying(50),
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: filiere_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE filiere_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filiere_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('filiere_id_seq', 1, false);


--
-- Name: fonction; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE fonction (
    id bigint NOT NULL,
    code character varying(32) NOT NULL,
    libelle character varying(255)
);


--
-- Name: fonction_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE fonction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fonction_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('fonction_id_seq', 19, true);


--
-- Name: groupe_personnes; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE groupe_personnes (
    id bigint NOT NULL,
    nom character varying(512) NOT NULL,
    virtuel boolean DEFAULT false,
    autorite_id bigint NOT NULL,
    item_id bigint NOT NULL,
    propriete_scolarite_id bigint
);


--
-- Name: groupe_personnes_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE groupe_personnes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groupe_personnes_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('groupe_personnes_id_seq', 1, false);


--
-- Name: inscription_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE inscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inscription_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('inscription_id_seq', 1, false);


--
-- Name: matiere; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE matiere (
    version integer NOT NULL,
    id bigint NOT NULL,
    libelle_long character varying(255) NOT NULL,
    code_sts character varying(128),
    libelle_court character varying(255) NOT NULL,
    code_gestion character varying(255) NOT NULL,
    libelle_edition character varying(255) NOT NULL,
    etablissement_id bigint NOT NULL,
    origine character varying(10),
    specialite boolean DEFAULT false NOT NULL,
    annee_scolaire_id bigint NOT NULL
);


--
-- Name: matiere_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE matiere_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matiere_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('matiere_id_seq', 1, false);


--
-- Name: mef; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE mef (
    id bigint NOT NULL,
    code character varying(32) NOT NULL,
    formation character varying(255),
    specialite character varying(255),
    libelle_long character varying(255),
    libelle_edition character varying(255),
    mefstat11 character(11),
    mefstat4 character(4)
);


--
-- Name: mef_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE mef_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mef_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('mef_id_seq', 1, false);


--
-- Name: modalite_cours; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE modalite_cours (
    code_sts character varying(30) NOT NULL,
    version integer NOT NULL,
    libelle_court character varying(255),
    libelle_long character varying(1024),
    co_ens boolean,
    id bigint NOT NULL,
    no_ordre integer
);


--
-- Name: modalite_cours_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE modalite_cours_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modalite_cours_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('modalite_cours_id_seq', 1, false);


--
-- Name: modalite_matiere; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE modalite_matiere (
    id bigint NOT NULL,
    libelle character varying(1024) NOT NULL,
    code character varying(6) NOT NULL,
    etablissement_id bigint NOT NULL,
    version integer NOT NULL,
    annee_scolaire_id bigint NOT NULL
);


--
-- Name: modalite_matiere_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE modalite_matiere_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modalite_matiere_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('modalite_matiere_id_seq', 1, false);


--
-- Name: niveau; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE niveau (
    id bigint NOT NULL,
    libelle_court character varying(128),
    libelle_long character varying(255),
    libelle_edition character varying(255)
);


--
-- Name: niveau_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE niveau_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: niveau_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('niveau_id_seq', 1, true);


--
-- Name: periode; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE periode (
    id bigint NOT NULL,
    type_periode_id integer NOT NULL,
    date_debut date,
    date_fin date,
    date_fin_saisie date,
    date_publication_bulletins date,
    structure_enseignement_id bigint NOT NULL,
    date_publication_releves date
);


--
-- Name: periode_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periode_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('periode_id_seq', 6, true);


--
-- Name: personne; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE personne (
    id bigint NOT NULL,
    autorite_id bigint NOT NULL,
    nom character varying(40) NOT NULL,
    prenom character varying(40) NOT NULL,
    civilite_id integer,
    telephone_pro character varying(17),
    telephone_perso character varying(17),
    telephone_portable character varying(17),
    fax character varying(17),
    adresse character varying(150),
    code_postal character varying(10),
    ville character varying(50),
    pays character varying(30),
    date_naissance date,
    sexe character(1),
    photo character varying(50),
    etablissement_rattachement_id bigint,
    email character varying(256),
    nom_normalise character varying(40),
    prenom_normalise character varying(40),
    regime_id bigint,
    login character varying(128),
    numero_bureau character varying(16),
    id_sconet character varying(50)
);


--
-- Name: personne_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE personne_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: personne_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('personne_id_seq', 1, false);


--
-- Name: personne_propriete_scolarite; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE personne_propriete_scolarite (
    id bigint NOT NULL,
    personne_id bigint NOT NULL,
    propriete_scolarite_id bigint NOT NULL,
    est_active boolean DEFAULT false NOT NULL,
    aaf_import_id bigint,
    date_desactivation timestamp without time zone,
    date_debut timestamp without time zone,
    date_fin timestamp without time zone,
    compteur_references integer,
    udt_import_id bigint,
    actif_avant_suppression boolean,
    origine character varying(10) DEFAULT 'AUTO'::character varying NOT NULL
);


--
-- Name: personne_propriete_scolarite_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE personne_propriete_scolarite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: personne_propriete_scolarite_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('personne_propriete_scolarite_id_seq', 1, false);


--
-- Name: porteur_ent; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE porteur_ent (
    id bigint NOT NULL,
    code character varying(32) NOT NULL,
    perimetre_id bigint NOT NULL,
    nom character varying(256),
    nom_court character varying(128),
    email_projet character varying(256),
    url_retour_logout character varying(1024),
    url_acces_ent character varying(1024)
);


--
-- Name: porteur_ent_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE porteur_ent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: porteur_ent_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('porteur_ent_id_seq', 1, false);


--
-- Name: preference_etablissement; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE preference_etablissement (
    id bigint NOT NULL,
    etablissement_id bigint NOT NULL,
    nb_annees_conservation_archives_bulletins integer DEFAULT 5,
    nb_annees_conservation_archives_cdt integer DEFAULT 3,
    version integer DEFAULT 0 NOT NULL,
    nom_etablissement character varying(60),
    adresse_1_etablissement character varying(60),
    adresse_2_etablissement character varying(60),
    code_postal_etablissement character varying(10),
    ville_etablissement character varying(60),
    logo_etablissement bytea,
    cachet_etablissement bytea,
    lvs_active boolean DEFAULT false,
    lvs_url character varying(255),
    annee_scolaire_id bigint NOT NULL,
    magister_url character varying(255),
    magister_active boolean NOT NULL
);


--
-- Name: preference_etablissement_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE preference_etablissement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: preference_etablissement_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('preference_etablissement_id_seq', 1, false);


--
-- Name: preference_utilisateur_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE preference_utilisateur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: preference_utilisateur_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('preference_utilisateur_id_seq', 1, false);


--
-- Name: propriete_scolarite; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE propriete_scolarite (
    id bigint NOT NULL,
    etablissement_id bigint,
    structure_enseignement_id bigint,
    annee_scolaire_id bigint,
    niveau_id bigint,
    matiere_id bigint,
    mef_id bigint,
    fonction_id bigint,
    responsable_structure_enseignement boolean DEFAULT false,
    porteur_ent_id bigint
);


--
-- Name: propriete_scolarite_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE propriete_scolarite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: propriete_scolarite_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('propriete_scolarite_id_seq', 1, false);


--
-- Name: regime; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE regime (
    id bigint NOT NULL,
    code character varying(32) NOT NULL
);


--
-- Name: regime_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE regime_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regime_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('regime_id_seq', 3, true);


--
-- Name: rel_classe_filiere; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE rel_classe_filiere (
    classe_id bigint NOT NULL,
    filiere_id bigint NOT NULL
);


--
-- Name: rel_classe_groupe; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE rel_classe_groupe (
    classe_id bigint NOT NULL,
    groupe_id bigint NOT NULL
);


--
-- Name: rel_periode_service; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE rel_periode_service (
    id bigint NOT NULL,
    service_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    coeff numeric,
    version integer NOT NULL,
    option boolean DEFAULT false NOT NULL,
    ordre integer,
    evaluable boolean DEFAULT false NOT NULL
);


--
-- Name: rel_periode_service_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE rel_periode_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rel_periode_service_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('rel_periode_service_id_seq', 1, false);


--
-- Name: responsable_eleve; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE responsable_eleve (
    id bigint NOT NULL,
    responsable_legal integer,
    parent boolean DEFAULT true,
    personne_id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    est_active boolean DEFAULT true,
    import_id bigint,
    date_desactivation timestamp without time zone,
    est_validee boolean DEFAULT false,
    actif_avant_suppression boolean
);


--
-- Name: responsable_eleve_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE responsable_eleve_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: responsable_eleve_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('responsable_eleve_id_seq', 1, false);


--
-- Name: responsable_propriete_scolarite; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE responsable_propriete_scolarite (
    id bigint NOT NULL,
    responsable_eleve_id bigint NOT NULL,
    propriete_scolarite_id bigint NOT NULL,
    est_active boolean DEFAULT true,
    import_id bigint,
    date_desactivation timestamp without time zone,
    actif_avant_suppression boolean
);


--
-- Name: responsable_propriete_scolarite_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE responsable_propriete_scolarite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: responsable_propriete_scolarite_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('responsable_propriete_scolarite_id_seq', 1, false);


--
-- Name: service; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE service (
    id integer NOT NULL,
    version integer NOT NULL,
    nb_heures double precision,
    co_ens boolean,
    modalite_cours_id bigint,
    matiere_id bigint NOT NULL,
    structure_enseignement_id bigint,
    version_import_sts integer DEFAULT (-1),
    actif boolean DEFAULT true,
    origine character varying(10) DEFAULT 'AUTO'::character varying NOT NULL,
    service_principal boolean DEFAULT false NOT NULL
);


--
-- Name: services_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: ent; Owner: -
--

ALTER SEQUENCE services_id_seq OWNED BY service.id;


--
-- Name: services_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('services_id_seq', 1, false);


--
-- Name: signature; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE signature (
    id bigint NOT NULL,
    proprietaire_id bigint NOT NULL,
    version integer NOT NULL,
    titre character varying(150),
    image_signature bytea
);


--
-- Name: signature_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE signature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: signature_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('signature_id_seq', 1, false);


--
-- Name: source_import; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE source_import (
    id bigint NOT NULL,
    code character varying(30) NOT NULL,
    libelle character varying(30) NOT NULL
);


--
-- Name: sous_service; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE sous_service (
    id bigint NOT NULL,
    coeff numeric NOT NULL,
    service_id bigint NOT NULL,
    modalite_matiere_id bigint NOT NULL,
    version integer NOT NULL,
    ordre integer,
    evaluable boolean DEFAULT false NOT NULL,
    type_periode_id bigint NOT NULL
);


--
-- Name: sous_service_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE sous_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sous_service_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('sous_service_id_seq', 1, false);


--
-- Name: structure_enseignement; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE structure_enseignement (
    id bigint NOT NULL,
    id_externe character varying(128) NOT NULL,
    type character varying(128) NOT NULL,
    version integer NOT NULL,
    etablissement_id bigint NOT NULL,
    annee_scolaire_id bigint NOT NULL,
    type_intervalle character varying(30),
    code character varying(50) NOT NULL,
    version_import_sts integer DEFAULT (-1) NOT NULL,
    actif boolean DEFAULT true,
    niveau_id bigint,
    brevet_serie_id bigint,
    date_publication_brevet timestamp with time zone,
    CONSTRAINT chk_structure_enseignement_validite_niveau CHECK ((((niveau_id IS NULL) AND ((type)::text = 'GROUPE'::text)) OR ((niveau_id IS NOT NULL) AND ((type)::text = 'CLASSE'::text))))
);


--
-- Name: structure_enseignement_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE structure_enseignement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: structure_enseignement_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('structure_enseignement_id_seq', 1, false);


--
-- Name: type_periode; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE type_periode (
    id integer NOT NULL,
    libelle character varying(50),
    version integer NOT NULL,
    intervalle character varying(5),
    nature character varying(20) NOT NULL,
    etablissement_id bigint
);


--
-- Name: type_periode_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE type_periode_id_seq
    START WITH 1
    INCREMENT BY 7
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: type_periode_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('type_periode_id_seq', 5, true);


SET search_path = securite, pg_catalog;

--
-- Name: autorite; Type: TABLE; Schema: securite; Owner: -; Tablespace: 
--

CREATE TABLE autorite (
    id bigint NOT NULL,
    version integer NOT NULL,
    type character varying(128) NOT NULL,
    id_externe character varying(128) NOT NULL,
    est_active boolean DEFAULT true,
    import_id bigint,
    date_desactivation timestamp without time zone,
    nom_entite_cible character varying(128),
    enregistrement_cible_id bigint,
    id_sts character varying(128),
    etat character varying(20)
);


SET search_path = ent, pg_catalog;

--
-- Name: vue_annuaire; Type: VIEW; Schema: ent; Owner: -
--

CREATE VIEW vue_annuaire AS
    SELECT p.nom, p.prenom, e.nom_affichage AS nom_etab, se.code AS structure_code, se.type AS structure_type, se.actif AS structure_actif, f.code AS fonction_code, ps.responsable_structure_enseignement AS resp_structure, an.code AS annee_code, niv.libelle_court AS niveau_lib, mat.libelle_court AS matiere_lib, mef.code AS mef_code, p.id AS personne_id, p.autorite_id, pps.id AS pps_id, e.id AS etablissement_id, se.id AS structure_id, f.id AS fonction_id, an.id AS annee_id, niv.id AS niveau_id, mat.id AS matiere_id, mef.id AS mef_id, aut.id_externe FROM ((((((((((personne p JOIN personne_propriete_scolarite pps ON (((pps.personne_id = p.id) AND (pps.est_active = true)))) JOIN propriete_scolarite ps ON ((ps.id = pps.propriete_scolarite_id))) LEFT JOIN etablissement e ON ((e.id = ps.etablissement_id))) LEFT JOIN structure_enseignement se ON ((se.id = ps.structure_enseignement_id))) LEFT JOIN fonction f ON ((f.id = ps.fonction_id))) LEFT JOIN annee_scolaire an ON ((an.id = ps.annee_scolaire_id))) LEFT JOIN niveau niv ON ((niv.id = ps.niveau_id))) LEFT JOIN matiere mat ON ((mat.id = ps.matiere_id))) LEFT JOIN mef mef ON ((mef.id = ps.mef_id))) LEFT JOIN securite.autorite aut ON ((p.autorite_id = aut.id))) ORDER BY p.nom, p.prenom;


SET search_path = ent_2011_2012, pg_catalog;

--
-- Name: calendrier; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE calendrier (
    id bigint NOT NULL,
    jour_semaine_ferie smallint NOT NULL,
    version integer NOT NULL,
    annee_scolaire_id bigint NOT NULL,
    premier_jour date NOT NULL,
    dernier_jour date NOT NULL,
    etablissement_id bigint NOT NULL
);


--
-- Name: enseignement; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE enseignement (
    enseignant_id bigint NOT NULL,
    version integer NOT NULL,
    service_id integer NOT NULL,
    nb_heures double precision,
    version_import_sts integer DEFAULT (-1),
    actif boolean DEFAULT true,
    id bigint NOT NULL,
    origine character varying(10) DEFAULT 'AUTO'::character varying NOT NULL
);


--
-- Name: matiere; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE matiere (
    version integer NOT NULL,
    id bigint NOT NULL,
    libelle_long character varying(255) NOT NULL,
    code_sts character varying(128),
    libelle_court character varying(255) NOT NULL,
    code_gestion character varying(255) NOT NULL,
    libelle_edition character varying(255) NOT NULL,
    etablissement_id bigint NOT NULL,
    origine character varying(10),
    specialite boolean DEFAULT false NOT NULL,
    annee_scolaire_id bigint NOT NULL
);


--
-- Name: modalite_matiere; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE modalite_matiere (
    id bigint NOT NULL,
    libelle character varying(1024) NOT NULL,
    code character varying(6) NOT NULL,
    etablissement_id bigint NOT NULL,
    version integer NOT NULL,
    annee_scolaire_id bigint NOT NULL
);


--
-- Name: periode; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE periode (
    id bigint NOT NULL,
    type_periode_id integer NOT NULL,
    date_debut date,
    date_fin date,
    date_fin_saisie date,
    date_publication_bulletins date,
    structure_enseignement_id bigint NOT NULL,
    date_publication_releves date
);


--
-- Name: personne_propriete_scolarite; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE personne_propriete_scolarite (
    id bigint NOT NULL,
    personne_id bigint NOT NULL,
    propriete_scolarite_id bigint NOT NULL,
    est_active boolean DEFAULT false NOT NULL,
    aaf_import_id bigint,
    date_desactivation timestamp without time zone,
    date_debut timestamp without time zone,
    date_fin timestamp without time zone,
    compteur_references integer,
    udt_import_id bigint,
    origine character varying(10) DEFAULT 'AUTO'::character varying NOT NULL
);


--
-- Name: preference_etablissement; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE preference_etablissement (
    id bigint NOT NULL,
    etablissement_id bigint NOT NULL,
    nb_annees_conservation_archives_bulletins integer DEFAULT 5,
    nb_annees_conservation_archives_cdt integer DEFAULT 3,
    version integer DEFAULT 0 NOT NULL,
    nom_etablissement character varying(60),
    adresse_1_etablissement character varying(60),
    adresse_2_etablissement character varying(60),
    code_postal_etablissement character varying(10),
    ville_etablissement character varying(60),
    logo_etablissement bytea,
    cachet_etablissement bytea,
    lvs_active boolean DEFAULT false,
    lvs_url character varying(255),
    sms_fournisseur_etablissement_id bigint,
    annee_scolaire_id bigint NOT NULL
);


--
-- Name: propriete_scolarite; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE propriete_scolarite (
    id bigint NOT NULL,
    etablissement_id bigint,
    structure_enseignement_id bigint,
    annee_scolaire_id bigint,
    niveau_id bigint,
    matiere_id bigint,
    mef_id bigint,
    fonction_id bigint,
    responsable_structure_enseignement boolean DEFAULT false,
    porteur_ent_id bigint
);


--
-- Name: rel_classe_filiere; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE rel_classe_filiere (
    classe_id bigint NOT NULL,
    filiere_id bigint NOT NULL
);


--
-- Name: rel_classe_groupe; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE rel_classe_groupe (
    classe_id bigint NOT NULL,
    groupe_id bigint NOT NULL
);


--
-- Name: rel_periode_service; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE rel_periode_service (
    id bigint NOT NULL,
    service_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    coeff numeric,
    version integer NOT NULL,
    option boolean DEFAULT false NOT NULL,
    ordre integer,
    evaluable boolean DEFAULT false NOT NULL
);


--
-- Name: responsable_propriete_scolarite; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE responsable_propriete_scolarite (
    id bigint NOT NULL,
    responsable_eleve_id bigint NOT NULL,
    propriete_scolarite_id bigint NOT NULL,
    est_active boolean DEFAULT true,
    import_id bigint,
    date_desactivation timestamp without time zone
);


--
-- Name: service; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE service (
    id integer DEFAULT nextval('ent.services_id_seq'::regclass) NOT NULL,
    version integer NOT NULL,
    nb_heures double precision,
    co_ens boolean,
    modalite_cours_id bigint,
    matiere_id bigint NOT NULL,
    structure_enseignement_id bigint,
    version_import_sts integer DEFAULT (-1),
    actif boolean DEFAULT true,
    origine character varying(10) DEFAULT 'AUTO'::character varying NOT NULL,
    service_principal boolean DEFAULT false NOT NULL
);


--
-- Name: sous_service; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE sous_service (
    id bigint NOT NULL,
    coeff numeric NOT NULL,
    service_id bigint NOT NULL,
    modalite_matiere_id bigint NOT NULL,
    version integer NOT NULL,
    ordre integer,
    evaluable boolean DEFAULT false NOT NULL,
    type_periode_id bigint NOT NULL
);


--
-- Name: structure_enseignement; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE structure_enseignement (
    id bigint NOT NULL,
    id_externe character varying(128) NOT NULL,
    type character varying(128) NOT NULL,
    version integer NOT NULL,
    etablissement_id bigint NOT NULL,
    annee_scolaire_id bigint NOT NULL,
    type_intervalle character varying(30),
    code character varying(50) NOT NULL,
    version_import_sts integer DEFAULT (-1),
    actif boolean DEFAULT true,
    niveau_id bigint,
    brevet_serie_id bigint,
    date_publication_brevet timestamp with time zone,
    CONSTRAINT chk_structure_enseignement_validite_niveau CHECK ((((niveau_id IS NULL) AND ((type)::text = 'GROUPE'::text)) OR ((niveau_id IS NOT NULL) AND ((type)::text = 'CLASSE'::text))))
);


SET search_path = entcdt, pg_catalog;

--
-- Name: activite; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE activite (
    id bigint NOT NULL,
    auteur_id bigint NOT NULL,
    chapitre_id bigint,
    contexte_activite_id bigint,
    type_activite_id bigint,
    date_creation timestamp without time zone NOT NULL,
    date_modification timestamp without time zone,
    date_publication date,
    titre character varying(512),
    objectif text,
    enonce text,
    description text,
    annotation_privee text,
    ordre integer NOT NULL,
    est_publiee boolean DEFAULT false NOT NULL,
    est_terminee boolean DEFAULT false NOT NULL,
    code_matiere character varying(30),
    cahier_de_textes_id bigint NOT NULL,
    item_id bigint,
    CONSTRAINT chk_activite_date_publication CHECK (((date_publication IS NULL) OR ((date_publication IS NOT NULL) AND est_publiee)))
);


--
-- Name: activite_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE activite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activite_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('activite_id_seq', 1, false);


--
-- Name: cahier_de_textes; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE cahier_de_textes (
    id bigint NOT NULL,
    fichier_id bigint,
    service_id bigint,
    nom character varying(255) NOT NULL,
    description text,
    date_creation timestamp without time zone NOT NULL,
    item_id bigint NOT NULL,
    est_vise boolean DEFAULT false,
    annee_scolaire_id bigint,
    droits_incomplets boolean DEFAULT false,
    parent_incorporation_id bigint
);


--
-- Name: cahier_de_textes_copie_info_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE cahier_de_textes_copie_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cahier_de_textes_copie_info_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('cahier_de_textes_copie_info_id_seq', 1, false);


--
-- Name: cahier_de_textes_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE cahier_de_textes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cahier_de_textes_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('cahier_de_textes_id_seq', 1, false);


--
-- Name: chapitre; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE chapitre (
    id bigint NOT NULL,
    chapitre_parent_id bigint,
    auteur_id bigint NOT NULL,
    nom character varying(255) NOT NULL,
    description text,
    ordre integer DEFAULT 0 NOT NULL,
    cahier_de_textes_id bigint NOT NULL
);


--
-- Name: chapitre_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE chapitre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chapitre_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('chapitre_id_seq', 1, false);


--
-- Name: contexte_activite; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE contexte_activite (
    id bigint NOT NULL,
    code character varying(5) NOT NULL,
    nom character varying(255) NOT NULL,
    description text
);


--
-- Name: contexte_activite_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE contexte_activite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contexte_activite_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('contexte_activite_id_seq', 1, false);


--
-- Name: date_activite; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE date_activite (
    id bigint NOT NULL,
    activite_id bigint NOT NULL,
    date_activite timestamp without time zone,
    date_echeance timestamp without time zone,
    duree integer,
    evenement_id bigint
);


--
-- Name: date_activite_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE date_activite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: date_activite_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('date_activite_id_seq', 1, false);


--
-- Name: dossier; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE dossier (
    id bigint NOT NULL,
    acteur_id bigint NOT NULL,
    nom character varying(255) NOT NULL,
    description text,
    est_defaut boolean DEFAULT false NOT NULL,
    ordre integer
);


--
-- Name: dossier_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE dossier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dossier_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('dossier_id_seq', 1, false);


--
-- Name: fichier; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE fichier (
    id bigint NOT NULL,
    nom character varying,
    blob bytea,
    id_externe character varying(128),
    type_mime character varying(255),
    datastore_code character varying(20) NOT NULL,
    migration_erreur_nb integer DEFAULT 0 NOT NULL
);


--
-- Name: fichier_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE fichier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fichier_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('fichier_id_seq', 1, false);


--
-- Name: rel_activite_acteur; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE rel_activite_acteur (
    activite_id bigint NOT NULL,
    acteur_id bigint NOT NULL,
    annotation text,
    est_lu boolean DEFAULT false NOT NULL,
    est_termine boolean DEFAULT false NOT NULL,
    est_nouvelle boolean DEFAULT true NOT NULL,
    id bigint NOT NULL
);


--
-- Name: rel_activite_acteur_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE rel_activite_acteur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rel_activite_acteur_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('rel_activite_acteur_id_seq', 1, false);


--
-- Name: rel_cahier_acteur; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE rel_cahier_acteur (
    cahier_de_textes_id bigint NOT NULL,
    acteur_id bigint NOT NULL,
    sera_notifie boolean DEFAULT true NOT NULL,
    alias_nom character varying(255),
    id bigint NOT NULL
);


--
-- Name: rel_cahier_acteur_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE rel_cahier_acteur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rel_cahier_acteur_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('rel_cahier_acteur_id_seq', 1, false);


--
-- Name: rel_cahier_groupe; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE rel_cahier_groupe (
    cahier_de_textes_id bigint NOT NULL,
    groupe_id bigint NOT NULL,
    notification_obligatoire boolean DEFAULT false NOT NULL,
    id bigint NOT NULL
);


--
-- Name: rel_cahier_groupe_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE rel_cahier_groupe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rel_cahier_groupe_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('rel_cahier_groupe_id_seq', 1, false);


--
-- Name: rel_dossier_autorisation_cahier; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE rel_dossier_autorisation_cahier (
    dossier_id bigint NOT NULL,
    autorisation_id bigint NOT NULL,
    id bigint NOT NULL
);


--
-- Name: rel_dossier_autorisation_cahier_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE rel_dossier_autorisation_cahier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rel_dossier_autorisation_cahier_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('rel_dossier_autorisation_cahier_id_seq', 1, false);


--
-- Name: ressource; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE ressource (
    id bigint NOT NULL,
    activite_id bigint NOT NULL,
    fichier_id bigint,
    url text,
    ordre integer NOT NULL,
    description text,
    est_publiee boolean DEFAULT false NOT NULL,
    date_publication date,
    type_ressource character varying(3) NOT NULL,
    catalogue_ressource_id_externe character varying,
    CONSTRAINT chk_ressource_type_ressource CHECK (((((type_ressource)::text = 'URL'::text) OR ((type_ressource)::text = 'FIC'::text)) OR ((type_ressource)::text = 'CPA'::text))),
    CONSTRAINT chk_ressource_type_ressource_not_nulls CHECK ((((((((type_ressource)::text = 'CPA'::text) AND (catalogue_ressource_id_externe IS NOT NULL)) AND (fichier_id IS NULL)) AND (url IS NULL)) OR (((((type_ressource)::text = 'FIC'::text) AND (catalogue_ressource_id_externe IS NULL)) AND (fichier_id IS NOT NULL)) AND (url IS NULL))) OR (((((type_ressource)::text = 'URL'::text) AND (catalogue_ressource_id_externe IS NULL)) AND (fichier_id IS NULL)) AND (url IS NOT NULL))))
);


--
-- Name: ressource_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE ressource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ressource_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('ressource_id_seq', 1, false);


--
-- Name: textes_preferences_utilisateur; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE textes_preferences_utilisateur (
    id bigint NOT NULL,
    utilisateur_id bigint NOT NULL,
    date_derniere_notification timestamp without time zone
);


--
-- Name: textes_preferences_utilisateur_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE textes_preferences_utilisateur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: textes_preferences_utilisateur_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('textes_preferences_utilisateur_id_seq', 1, false);


--
-- Name: type_activite; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE type_activite (
    id bigint NOT NULL,
    code character varying(5),
    nom character varying(255) NOT NULL,
    description text,
    degre integer
);


--
-- Name: type_activite_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE type_activite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: type_activite_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('type_activite_id_seq', 1, true);


--
-- Name: visa; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE visa (
    id bigint NOT NULL,
    date_visee timestamp without time zone NOT NULL,
    auteur_personne_id bigint NOT NULL,
    cahier_vise_id bigint NOT NULL,
    commentaire text,
    etablissement_uai character varying(10) NOT NULL
);


--
-- Name: visa_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE visa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visa_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('visa_id_seq', 1, false);


SET search_path = entdemon, pg_catalog;

--
-- Name: demande_traitement; Type: TABLE; Schema: entdemon; Owner: -; Tablespace: 
--

CREATE TABLE demande_traitement (
    id bigint NOT NULL,
    date_demande timestamp without time zone NOT NULL,
    date_debut_execution_traitement timestamp without time zone,
    date_fin_execution_traitement timestamp without time zone,
    date_annulation_execution_traitement timestamp without time zone,
    statut character varying NOT NULL,
    traitement_type character varying(128) NOT NULL,
    traitement_rapport text,
    traitement_args text,
    demandeur_autorite_id bigint,
    etablissement_id bigint,
    annee_scolaire_id bigint,
    nom character varying(128)
);


--
-- Name: demande_traitement_id_seq; Type: SEQUENCE; Schema: entdemon; Owner: -
--

CREATE SEQUENCE demande_traitement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: demande_traitement_id_seq; Type: SEQUENCE SET; Schema: entdemon; Owner: -
--

SELECT pg_catalog.setval('demande_traitement_id_seq', 1, false);


SET search_path = entnotes, pg_catalog;

--
-- Name: appreciation_classe_enseignement_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE appreciation_classe_enseignement_periode (
    id bigint NOT NULL,
    classe_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    appreciation character varying(1024),
    version integer NOT NULL,
    enseignement_id bigint NOT NULL
);


--
-- Name: appreciation_classe_enseignement_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE appreciation_classe_enseignement_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appreciation_classe_enseignement_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('appreciation_classe_enseignement_periode_id_seq', 1, false);


--
-- Name: appreciation_eleve_enseignement_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE appreciation_eleve_enseignement_periode (
    id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    appreciation character varying(1024),
    version integer NOT NULL,
    enseignement_id bigint NOT NULL
);


--
-- Name: appreciation_eleve_enseignement_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE appreciation_eleve_enseignement_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appreciation_eleve_enseignement_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('appreciation_eleve_enseignement_periode_id_seq', 1, false);


--
-- Name: appreciation_eleve_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE appreciation_eleve_periode (
    id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    appreciation character varying(1024),
    avis_conseil_de_classe_id bigint,
    avis_orientation_id bigint,
    version integer NOT NULL
);


--
-- Name: appreciation_eleve_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE appreciation_eleve_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appreciation_eleve_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('appreciation_eleve_periode_id_seq', 1, false);


--
-- Name: avis_conseil_de_classe; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE avis_conseil_de_classe (
    id bigint NOT NULL,
    version integer NOT NULL,
    texte character varying(1024) NOT NULL,
    etablissement_id bigint NOT NULL,
    ordre integer
);


--
-- Name: avis_conseil_de_classe_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE avis_conseil_de_classe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: avis_conseil_de_classe_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('avis_conseil_de_classe_id_seq', 1, false);


--
-- Name: avis_orientation; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE avis_orientation (
    id bigint NOT NULL,
    version integer NOT NULL,
    texte character varying(1024) NOT NULL,
    etablissement_id bigint NOT NULL,
    ordre integer
);


--
-- Name: avis_orientation_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE avis_orientation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: avis_orientation_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('avis_orientation_id_seq', 1, false);


--
-- Name: brevet_epreuve; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE brevet_epreuve (
    id bigint NOT NULL,
    code integer NOT NULL,
    libelle character varying(256) NOT NULL,
    note_max integer,
    indicative boolean NOT NULL,
    optionnelle boolean NOT NULL,
    personnalisable boolean NOT NULL,
    notee boolean NOT NULL,
    epreuve_exclusive_id bigint,
    epreuve_matieres_a_heriter_id bigint,
    serie_id bigint NOT NULL
);


--
-- Name: brevet_epreuve_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE brevet_epreuve_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brevet_epreuve_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('brevet_epreuve_id_seq', 97, true);


--
-- Name: brevet_fiche; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE brevet_fiche (
    id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    annee_scolaire_id bigint NOT NULL,
    avis character varying(256)
);


--
-- Name: brevet_fiche_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE brevet_fiche_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brevet_fiche_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('brevet_fiche_id_seq', 1, false);


--
-- Name: brevet_note; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE brevet_note (
    id bigint NOT NULL,
    appreciation character varying(1024),
    valeur_numerique numeric,
    valeur_textuelle_id bigint,
    epreuve_id bigint NOT NULL,
    matiere_id bigint,
    fiche_id bigint NOT NULL
);


--
-- Name: brevet_note_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE brevet_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brevet_note_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('brevet_note_id_seq', 1, false);


--
-- Name: brevet_note_valeur_textuelle; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE brevet_note_valeur_textuelle (
    id bigint NOT NULL,
    valeur character varying(2) NOT NULL
);


--
-- Name: brevet_rel_epreuve_matiere; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE brevet_rel_epreuve_matiere (
    id bigint NOT NULL,
    epreuve_id bigint NOT NULL,
    matiere_id bigint NOT NULL
);


--
-- Name: brevet_rel_epreuve_matiere_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE brevet_rel_epreuve_matiere_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brevet_rel_epreuve_matiere_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('brevet_rel_epreuve_matiere_id_seq', 1, false);


--
-- Name: brevet_rel_epreuve_note_valeur_textuelle; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE brevet_rel_epreuve_note_valeur_textuelle (
    brevet_epreuve_id bigint NOT NULL,
    valeur_textuelle_id bigint NOT NULL
);


--
-- Name: brevet_rel_epreuve_note_valeur_textuelle_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE brevet_rel_epreuve_note_valeur_textuelle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brevet_rel_epreuve_note_valeur_textuelle_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('brevet_rel_epreuve_note_valeur_textuelle_id_seq', 1, false);


--
-- Name: brevet_serie; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE brevet_serie (
    id bigint NOT NULL,
    libelle_court character varying(128) NOT NULL,
    libelle_long character varying(256) NOT NULL,
    libelle_edition character varying(256) NOT NULL,
    annee_scolaire_id bigint NOT NULL
);


--
-- Name: brevet_serie_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE brevet_serie_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brevet_serie_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('brevet_serie_id_seq', 8, true);


--
-- Name: dernier_changement_dans_classe_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE dernier_changement_dans_classe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dernier_changement_dans_classe_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('dernier_changement_dans_classe_id_seq', 1, false);


--
-- Name: dirty_moyenne; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE dirty_moyenne (
    id bigint NOT NULL,
    date_changement timestamp without time zone NOT NULL,
    eleve_id bigint,
    classe_id bigint,
    periode_id bigint NOT NULL,
    service_id bigint,
    sous_service_id bigint,
    type_moyenne character varying(200) NOT NULL,
    enseignement_id bigint
);


--
-- Name: dirty_moyenne_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE dirty_moyenne_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dirty_moyenne_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('dirty_moyenne_id_seq', 1, false);


--
-- Name: evaluation; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE evaluation (
    id bigint NOT NULL,
    titre character varying(128) NOT NULL,
    date_evaluation date NOT NULL,
    description character varying(1024),
    coefficient numeric NOT NULL,
    note_max_possible numeric,
    est_publiable boolean NOT NULL,
    activite_id bigint,
    version integer DEFAULT 0 NOT NULL,
    date_creation timestamp without time zone DEFAULT now() NOT NULL,
    ordre integer DEFAULT 0 NOT NULL,
    moyenne numeric,
    modalite_matiere_id bigint,
    enseignement_id bigint NOT NULL,
    cree_par_webservice boolean DEFAULT false NOT NULL
);


--
-- Name: evaluation_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE evaluation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: evaluation_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('evaluation_id_seq', 1, false);


--
-- Name: info_calcul_moyennes_classe; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE info_calcul_moyennes_classe (
    id bigint NOT NULL,
    classe_id bigint NOT NULL,
    calcul_en_cours boolean DEFAULT false NOT NULL,
    date_debut_calcul timestamp without time zone,
    date_fin_calcul timestamp without time zone,
    version integer NOT NULL,
    date_verrou timestamp without time zone
);


--
-- Name: info_calcul_moyennes_classe_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE info_calcul_moyennes_classe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: info_calcul_moyennes_classe_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('info_calcul_moyennes_classe_id_seq', 1, false);


--
-- Name: modele_appreciation; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE modele_appreciation (
    id bigint NOT NULL,
    texte character varying(1024) NOT NULL,
    type character varying(1024) NOT NULL,
    version integer NOT NULL,
    ordre integer
);


--
-- Name: modele_appreciation_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE modele_appreciation_id_seq
    START WITH 10
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modele_appreciation_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('modele_appreciation_id_seq', 10, false);


--
-- Name: modele_appreciation_professeur; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE modele_appreciation_professeur (
    id bigint NOT NULL,
    autorite_id bigint NOT NULL,
    texte character varying(1024) NOT NULL,
    version integer NOT NULL
);


--
-- Name: modele_appreciation_professeur_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE modele_appreciation_professeur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modele_appreciation_professeur_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('modele_appreciation_professeur_id_seq', 1, false);


--
-- Name: note; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE note (
    id bigint NOT NULL,
    valeur_numerique numeric,
    evaluation_id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    note_textuelle_id bigint,
    CONSTRAINT chk_valeur_numerique_or_note_textuelle CHECK (((note_textuelle_id IS NULL) OR (valeur_numerique IS NULL)))
);


--
-- Name: note_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: note_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('note_id_seq', 1, false);


--
-- Name: note_textuelle; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE note_textuelle (
    id bigint NOT NULL,
    code character varying(4) NOT NULL,
    libelle character varying(15) NOT NULL,
    etablissement_id bigint NOT NULL,
    version integer NOT NULL,
    annee_scolaire_id bigint NOT NULL
);


--
-- Name: note_textuelle_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE note_textuelle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: note_textuelle_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('note_textuelle_id_seq', 1, false);


--
-- Name: rel_evaluation_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE rel_evaluation_periode (
    evaluation_id bigint NOT NULL,
    periode_id bigint NOT NULL
);


--
-- Name: resultat_classe_enseignement_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE resultat_classe_enseignement_periode (
    id bigint NOT NULL,
    structure_enseignement_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    moyenne numeric,
    moyenne_max numeric,
    moyenne_min numeric,
    enseignement_id bigint NOT NULL
);


--
-- Name: resultat_classe_enseignement_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_classe_enseignement_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resultat_classe_enseignement_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_classe_enseignement_periode_id_seq', 1, false);


--
-- Name: resultat_classe_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE resultat_classe_periode (
    structure_enseignement_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    moyenne numeric,
    moyenne_max numeric,
    moyenne_min numeric,
    id bigint NOT NULL
);


--
-- Name: resultat_classe_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_classe_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resultat_classe_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_classe_periode_id_seq', 1, false);


--
-- Name: resultat_classe_service_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE resultat_classe_service_periode (
    structure_enseignement_id bigint NOT NULL,
    service_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    moyenne numeric,
    moyenne_max numeric,
    moyenne_min numeric,
    id bigint NOT NULL
);


--
-- Name: resultat_classe_service_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_classe_service_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resultat_classe_service_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_classe_service_periode_id_seq', 1, false);


--
-- Name: resultat_classe_sous_service_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE resultat_classe_sous_service_periode (
    id bigint NOT NULL,
    moyenne numeric,
    resultat_classe_service_periode_id bigint NOT NULL,
    sous_service_id bigint NOT NULL,
    moyenne_max numeric,
    moyenne_min numeric
);


--
-- Name: resultat_classe_sous_service_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_classe_sous_service_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resultat_classe_sous_service_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_classe_sous_service_periode_id_seq', 1, false);


--
-- Name: resultat_eleve_enseignement_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE resultat_eleve_enseignement_periode (
    id bigint NOT NULL,
    periode_id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    moyenne numeric,
    enseignement_id bigint NOT NULL,
    note_textuelle_id bigint,
    CONSTRAINT chk_moyenne_or_note_textuelle CHECK (((note_textuelle_id IS NULL) OR (moyenne IS NULL)))
);


--
-- Name: resultat_eleve_enseignement_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_eleve_enseignement_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resultat_eleve_enseignement_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_eleve_enseignement_periode_id_seq', 1, false);


--
-- Name: resultat_eleve_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE resultat_eleve_periode (
    autorite_eleve_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    moyenne numeric,
    id bigint NOT NULL,
    note_textuelle_id bigint,
    CONSTRAINT chk_moyenne_or_note_textuelle CHECK (((note_textuelle_id IS NULL) OR (moyenne IS NULL)))
);


--
-- Name: resultat_eleve_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_eleve_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resultat_eleve_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_eleve_periode_id_seq', 1, false);


--
-- Name: resultat_eleve_service_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE resultat_eleve_service_periode (
    autorite_eleve_id bigint NOT NULL,
    service_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    moyenne numeric,
    id bigint NOT NULL,
    note_textuelle_id bigint,
    CONSTRAINT chk_moyenne_or_note_textuelle CHECK (((note_textuelle_id IS NULL) OR (moyenne IS NULL)))
);


--
-- Name: resultat_eleve_service_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_eleve_service_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resultat_eleve_service_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_eleve_service_periode_id_seq', 1, false);


--
-- Name: resultat_eleve_sous_service_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE resultat_eleve_sous_service_periode (
    id bigint NOT NULL,
    moyenne numeric,
    resultat_eleve_service_periode_id bigint NOT NULL,
    sous_service_id bigint NOT NULL,
    note_textuelle_id bigint,
    CONSTRAINT chk_moyenne_or_note_textuelle CHECK (((note_textuelle_id IS NULL) OR (moyenne IS NULL)))
);


--
-- Name: resultat_eleve_sous_service_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_eleve_sous_service_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resultat_eleve_sous_service_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_eleve_sous_service_periode_id_seq', 1, false);


SET search_path = entnotes_2011_2012, pg_catalog;

--
-- Name: appreciation_classe_enseignement_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE appreciation_classe_enseignement_periode (
    id bigint NOT NULL,
    classe_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    appreciation character varying(1024),
    version integer NOT NULL,
    enseignement_id bigint NOT NULL
);


--
-- Name: appreciation_eleve_enseignement_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE appreciation_eleve_enseignement_periode (
    id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    appreciation character varying(1024),
    version integer NOT NULL,
    enseignement_id bigint NOT NULL
);


--
-- Name: appreciation_eleve_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE appreciation_eleve_periode (
    id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    appreciation character varying(1024),
    avis_conseil_de_classe_id bigint,
    avis_orientation_id bigint,
    version integer NOT NULL
);


--
-- Name: brevet_epreuve; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE brevet_epreuve (
    id bigint NOT NULL,
    code integer NOT NULL,
    libelle character varying(256) NOT NULL,
    note_max integer,
    indicative boolean NOT NULL,
    optionnelle boolean NOT NULL,
    personnalisable boolean NOT NULL,
    notee boolean NOT NULL,
    epreuve_exclusive_id bigint,
    epreuve_matieres_a_heriter_id bigint,
    serie_id bigint NOT NULL
);


--
-- Name: brevet_fiche; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE brevet_fiche (
    id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    annee_scolaire_id bigint NOT NULL,
    avis character varying(256)
);


--
-- Name: brevet_note; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE brevet_note (
    id bigint NOT NULL,
    appreciation character varying(1024),
    valeur_numerique numeric,
    valeur_textuelle_id bigint,
    epreuve_id bigint NOT NULL,
    matiere_id bigint,
    fiche_id bigint NOT NULL
);


--
-- Name: brevet_rel_epreuve_matiere; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE brevet_rel_epreuve_matiere (
    id bigint NOT NULL,
    epreuve_id bigint NOT NULL,
    matiere_id bigint NOT NULL
);


--
-- Name: brevet_rel_epreuve_note_valeur_textuelle; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE brevet_rel_epreuve_note_valeur_textuelle (
    brevet_epreuve_id bigint NOT NULL,
    valeur_textuelle_id bigint NOT NULL
);


--
-- Name: brevet_serie; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE brevet_serie (
    id bigint NOT NULL,
    libelle_court character varying(128) NOT NULL,
    libelle_long character varying(256) NOT NULL,
    libelle_edition character varying(256) NOT NULL,
    annee_scolaire_id bigint NOT NULL
);


--
-- Name: evaluation; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE evaluation (
    id bigint NOT NULL,
    titre character varying(128) NOT NULL,
    date_evaluation date NOT NULL,
    description character varying(1024),
    coefficient numeric NOT NULL,
    note_max_possible numeric,
    est_publiable boolean NOT NULL,
    activite_id bigint,
    version integer DEFAULT 0 NOT NULL,
    date_creation timestamp without time zone DEFAULT now() NOT NULL,
    ordre integer DEFAULT 0 NOT NULL,
    moyenne numeric,
    modalite_matiere_id bigint,
    enseignement_id bigint NOT NULL,
    cree_par_webservice boolean DEFAULT false NOT NULL
);


--
-- Name: info_calcul_moyennes_classe; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE info_calcul_moyennes_classe (
    id bigint NOT NULL,
    classe_id bigint NOT NULL,
    calcul_en_cours boolean DEFAULT false NOT NULL,
    date_debut_calcul timestamp without time zone,
    date_fin_calcul timestamp without time zone,
    version integer NOT NULL,
    date_verrou timestamp without time zone
);


--
-- Name: note; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE note (
    id bigint NOT NULL,
    valeur_numerique numeric,
    evaluation_id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    note_textuelle_id bigint,
    CONSTRAINT chk_valeur_numerique_or_note_textuelle CHECK (((note_textuelle_id IS NULL) OR (valeur_numerique IS NULL)))
);


--
-- Name: note_textuelle; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE note_textuelle (
    id bigint NOT NULL,
    code character varying(4) NOT NULL,
    libelle character varying(15) NOT NULL,
    etablissement_id bigint NOT NULL,
    version integer NOT NULL,
    annee_scolaire_id bigint NOT NULL
);


--
-- Name: rel_evaluation_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE rel_evaluation_periode (
    evaluation_id bigint NOT NULL,
    periode_id bigint NOT NULL
);


--
-- Name: resultat_classe_enseignement_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE resultat_classe_enseignement_periode (
    id bigint NOT NULL,
    structure_enseignement_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    moyenne numeric,
    moyenne_max numeric,
    moyenne_min numeric,
    enseignement_id bigint NOT NULL
);


--
-- Name: resultat_classe_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE resultat_classe_periode (
    structure_enseignement_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    moyenne numeric,
    moyenne_max numeric,
    moyenne_min numeric,
    id bigint NOT NULL
);


--
-- Name: resultat_classe_service_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE resultat_classe_service_periode (
    structure_enseignement_id bigint NOT NULL,
    service_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    moyenne numeric,
    moyenne_max numeric,
    moyenne_min numeric,
    id bigint NOT NULL
);


--
-- Name: resultat_classe_sous_service_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE resultat_classe_sous_service_periode (
    id bigint NOT NULL,
    moyenne numeric,
    resultat_classe_service_periode_id bigint NOT NULL,
    sous_service_id bigint NOT NULL,
    moyenne_max numeric,
    moyenne_min numeric
);


--
-- Name: resultat_eleve_enseignement_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE resultat_eleve_enseignement_periode (
    id bigint NOT NULL,
    periode_id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    moyenne numeric,
    enseignement_id bigint NOT NULL,
    note_textuelle_id bigint,
    CONSTRAINT chk_moyenne_or_note_textuelle CHECK (((note_textuelle_id IS NULL) OR (moyenne IS NULL)))
);


--
-- Name: resultat_eleve_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE resultat_eleve_periode (
    autorite_eleve_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    moyenne numeric,
    id bigint NOT NULL,
    note_textuelle_id bigint,
    CONSTRAINT chk_moyenne_or_note_textuelle CHECK (((note_textuelle_id IS NULL) OR (moyenne IS NULL)))
);


--
-- Name: resultat_eleve_service_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE resultat_eleve_service_periode (
    autorite_eleve_id bigint NOT NULL,
    service_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    moyenne numeric,
    id bigint NOT NULL,
    note_textuelle_id bigint,
    CONSTRAINT chk_moyenne_or_note_textuelle CHECK (((note_textuelle_id IS NULL) OR (moyenne IS NULL)))
);


--
-- Name: resultat_eleve_sous_service_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE resultat_eleve_sous_service_periode (
    id bigint NOT NULL,
    moyenne numeric,
    resultat_eleve_service_periode_id bigint NOT NULL,
    sous_service_id bigint NOT NULL,
    note_textuelle_id bigint,
    CONSTRAINT chk_moyenne_or_note_textuelle CHECK (((note_textuelle_id IS NULL) OR (moyenne IS NULL)))
);


SET search_path = enttemps, pg_catalog;

--
-- Name: absence_journee; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE absence_journee (
    id bigint NOT NULL,
    etablissement_id bigint NOT NULL,
    date date NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: absence_journee_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE absence_journee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: absence_journee_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('absence_journee_id_seq', 1, false);


--
-- Name: agenda; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE agenda (
    id bigint NOT NULL,
    item_id bigint NOT NULL,
    type_agenda_id bigint NOT NULL,
    structure_enseignement_id bigint,
    nom character varying(256) NOT NULL,
    description text,
    date_creation timestamp without time zone NOT NULL,
    date_modification timestamp without time zone NOT NULL,
    etablissement_id bigint,
    enseignant_id bigint,
    droits_incomplets boolean DEFAULT false,
    couleur character varying(8)
);


--
-- Name: agenda_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE agenda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agenda_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('agenda_id_seq', 1, false);


--
-- Name: appel; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE appel (
    id bigint NOT NULL,
    evenement_id bigint NOT NULL,
    appelant_id bigint,
    operateur_saisie_id bigint NOT NULL,
    date_saisie timestamp without time zone NOT NULL,
    valide boolean DEFAULT false,
    date_heure_debut timestamp without time zone NOT NULL,
    date_heure_fin timestamp without time zone NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: appel_en_cours_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE appel_en_cours_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appel_en_cours_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('appel_en_cours_id_seq', 1, false);


--
-- Name: appel_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE appel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appel_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('appel_id_seq', 1, false);


--
-- Name: appel_ligne; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE appel_ligne (
    id bigint NOT NULL,
    appel_id bigint,
    autorite_id bigint NOT NULL,
    motif_id bigint NOT NULL,
    retard boolean DEFAULT false,
    presence boolean DEFAULT true,
    absence_justifiee boolean,
    heure_arrivee timestamp without time zone,
    depart_anticipe boolean DEFAULT false,
    heure_depart timestamp without time zone,
    absence_previsionnelle boolean DEFAULT false,
    commentaire_arrivee character varying(250),
    commentaire_depart character varying(250),
    heure_debut time without time zone,
    heure_fin time without time zone,
    sanction_id bigint,
    operateur_saisie_id bigint,
    date_saisie date,
    absence_journee_id bigint,
    demi_pension boolean DEFAULT false NOT NULL,
    internat boolean DEFAULT false NOT NULL,
    CONSTRAINT chk_appel_ligne_depart_anticipe_heure_depart CHECK (((depart_anticipe = false) OR (heure_depart IS NOT NULL))),
    CONSTRAINT chk_appel_ligne_heure_debut_heure_fin CHECK (((((appel_id IS NOT NULL) OR (demi_pension = true)) OR (internat = true)) OR ((heure_debut IS NOT NULL) AND (heure_fin IS NOT NULL)))),
    CONSTRAINT chk_appel_ligne_presence_retard_depart_anticipe CHECK (((presence = true) OR ((retard = false) AND (depart_anticipe = false)))),
    CONSTRAINT chk_appel_ligne_rattachement CHECK (((appel_id IS NOT NULL) OR (absence_journee_id IS NOT NULL))),
    CONSTRAINT chk_appel_ligne_retard_heure_arrivee CHECK (((retard = false) OR (heure_arrivee IS NOT NULL))),
    CONSTRAINT chk_appel_ligne_validite_retards_departs CHECK (((((retard = false) AND (depart_anticipe = false)) AND (presence = false)) OR ((absence_previsionnelle = false) AND (absence_justifiee = true))))
);


--
-- Name: appel_ligne_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE appel_ligne_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appel_ligne_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('appel_ligne_id_seq', 1, false);


--
-- Name: appel_plage_horaire; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE appel_plage_horaire (
    appel_id bigint NOT NULL,
    plage_horaire_id bigint NOT NULL
);


--
-- Name: date_exclue; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE date_exclue (
    id bigint NOT NULL,
    date_exclue date NOT NULL,
    evenement_id bigint NOT NULL
);


--
-- Name: date_exclue_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE date_exclue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: date_exclue_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('date_exclue_id_seq', 1, false);


--
-- Name: element_emploi_du_temps_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE element_emploi_du_temps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: element_emploi_du_temps_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('element_emploi_du_temps_id_seq', 1, false);


--
-- Name: evenement; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE evenement (
    id bigint NOT NULL,
    auteur_id bigint NOT NULL,
    objet character varying(1024) NOT NULL,
    lieu character varying(1024),
    description text,
    uid character varying(1024) NOT NULL,
    rappel character varying(32),
    confidentialite character varying(32),
    disponibilite character varying(32),
    date_heure_debut timestamp without time zone NOT NULL,
    date_heure_fin timestamp without time zone NOT NULL,
    date_creation timestamp without time zone NOT NULL,
    date_modification timestamp without time zone NOT NULL,
    recurrence boolean,
    frequence character varying,
    intervalle integer,
    date_debut_recurrence date,
    date_fin_recurrence date,
    occurence integer,
    agenda_maitre_id bigint NOT NULL,
    toute_la_journee boolean,
    critere character varying(10),
    type_id bigint NOT NULL,
    enseignement_id bigint,
    udt_evenement_ids character varying(1024)
);


--
-- Name: evenement_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE evenement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: evenement_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('evenement_id_seq', 1, false);


--
-- Name: groupe_motif; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE groupe_motif (
    id bigint NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL,
    libelle character varying(512) NOT NULL,
    modifiable boolean DEFAULT true
);


--
-- Name: groupe_motif_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE groupe_motif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groupe_motif_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('groupe_motif_id_seq', 1, false);


--
-- Name: incident; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE incident (
    id bigint NOT NULL,
    date timestamp without time zone NOT NULL,
    type_id bigint NOT NULL,
    lieu_id bigint NOT NULL,
    description character varying(300),
    etablissement_id bigint NOT NULL,
    gravite smallint NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('incident_id_seq', 1, false);


--
-- Name: lieu_incident; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE lieu_incident (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: lieu_incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE lieu_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lieu_incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('lieu_incident_id_seq', 1, false);


--
-- Name: motif; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE motif (
    id bigint NOT NULL,
    libelle character varying(512) NOT NULL,
    couleur character varying(32),
    groupe_motif_id bigint NOT NULL,
    modifiable boolean DEFAULT true
);


--
-- Name: motif_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE motif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: motif_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('motif_id_seq', 1, false);


--
-- Name: partenaire_a_prevenir; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE partenaire_a_prevenir (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: partenaire_a_prevenir_incident; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE partenaire_a_prevenir_incident (
    id bigint NOT NULL,
    incident_id bigint NOT NULL,
    partenaire_a_prevenir_id bigint NOT NULL
);


--
-- Name: partenaire_a_prevenir_incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE partenaire_a_prevenir_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: partenaire_a_prevenir_incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('partenaire_a_prevenir_incident_id_seq', 1, false);


--
-- Name: partenaire_prevenir_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE partenaire_prevenir_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: partenaire_prevenir_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('partenaire_prevenir_id_seq', 1, false);


--
-- Name: plage_horaire; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE plage_horaire (
    id bigint NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL,
    debut time without time zone NOT NULL,
    fin time without time zone NOT NULL,
    matin boolean NOT NULL,
    version integer NOT NULL,
    lundi boolean DEFAULT true,
    mardi boolean DEFAULT true,
    mercredi boolean DEFAULT true,
    jeudi boolean DEFAULT true,
    vendredi boolean DEFAULT true,
    samedi boolean DEFAULT true,
    dimanche boolean DEFAULT false
);


--
-- Name: plage_horaire_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE plage_horaire_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plage_horaire_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('plage_horaire_id_seq', 1, false);


--
-- Name: preference_etablissement_absences; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE preference_etablissement_absences (
    id bigint NOT NULL,
    etablissement_id bigint,
    pas_decompte_absences_retards character varying(10),
    param_item_id bigint,
    version integer,
    autorise_saisie_hors_edt boolean NOT NULL,
    longueur_plage real,
    annee_scolaire_id bigint NOT NULL
);


--
-- Name: preference_etablissement_absences_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE preference_etablissement_absences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: preference_etablissement_absences_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('preference_etablissement_absences_id_seq', 1, false);


--
-- Name: preference_utilisateur_agenda; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE preference_utilisateur_agenda (
    id bigint NOT NULL,
    utilisateur_id bigint NOT NULL,
    agenda_id bigint NOT NULL,
    nom_personnalise character varying(128),
    couleur character varying(32),
    notification boolean NOT NULL
);


--
-- Name: preference_utilisateur_agenda_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE preference_utilisateur_agenda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: preference_utilisateur_agenda_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('preference_utilisateur_agenda_id_seq', 1, false);


--
-- Name: protagoniste_incident; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE protagoniste_incident (
    id bigint NOT NULL,
    incident_id bigint NOT NULL,
    autorite_id bigint NOT NULL,
    qualite_id bigint NOT NULL,
    type character varying(10) NOT NULL
);


--
-- Name: protagoniste_incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE protagoniste_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: protagoniste_incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('protagoniste_incident_id_seq', 1, false);


--
-- Name: punition; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE punition (
    id bigint NOT NULL,
    date date NOT NULL,
    type_punition_id bigint NOT NULL,
    effectue boolean NOT NULL,
    description character varying(300),
    incident_id bigint,
    etablissement_id bigint NOT NULL,
    eleve_id bigint,
    censeur_id bigint,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: punition_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE punition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: punition_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('punition_id_seq', 1, false);


--
-- Name: qualite_protagoniste; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE qualite_protagoniste (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: qualite_protagoniste_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE qualite_protagoniste_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qualite_protagoniste_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('qualite_protagoniste_id_seq', 1, false);


--
-- Name: rel_agenda_evenement; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE rel_agenda_evenement (
    evenement_id bigint NOT NULL,
    agenda_id bigint NOT NULL,
    id bigint NOT NULL
);


--
-- Name: rel_agenda_evenement_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE rel_agenda_evenement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rel_agenda_evenement_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('rel_agenda_evenement_id_seq', 1, false);


--
-- Name: repeter_jour_annee; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE repeter_jour_annee (
    id bigint NOT NULL,
    jour_annee integer NOT NULL,
    evenement_id bigint NOT NULL
);


--
-- Name: repeter_jour_annee_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE repeter_jour_annee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repeter_jour_annee_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('repeter_jour_annee_id_seq', 1, false);


--
-- Name: repeter_jour_mois; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE repeter_jour_mois (
    id bigint NOT NULL,
    jour_mois integer NOT NULL,
    evenement_id bigint NOT NULL
);


--
-- Name: repeter_jour_mois_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE repeter_jour_mois_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repeter_jour_mois_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('repeter_jour_mois_id_seq', 1, false);


--
-- Name: repeter_jour_semaine; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE repeter_jour_semaine (
    id bigint NOT NULL,
    jour integer NOT NULL,
    evenement_id bigint NOT NULL
);


--
-- Name: repeter_jour_semaine_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE repeter_jour_semaine_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repeter_jour_semaine_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('repeter_jour_semaine_id_seq', 1, false);


--
-- Name: repeter_mois; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE repeter_mois (
    id bigint NOT NULL,
    mois integer NOT NULL,
    evenement_id bigint NOT NULL
);


--
-- Name: repeter_mois_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE repeter_mois_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repeter_mois_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('repeter_mois_id_seq', 1, false);


--
-- Name: repeter_semaine_annee; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE repeter_semaine_annee (
    id bigint NOT NULL,
    semaine_annee integer NOT NULL,
    evenement_id bigint NOT NULL
);


--
-- Name: repeter_semaine_annee_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE repeter_semaine_annee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repeter_semaine_annee_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('repeter_semaine_annee_id_seq', 1, false);


--
-- Name: sanction; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE sanction (
    id bigint NOT NULL,
    date date NOT NULL,
    type_sanction_id bigint NOT NULL,
    effectue boolean NOT NULL,
    eleve_id bigint NOT NULL,
    censeur_id bigint NOT NULL,
    description character varying(300),
    incident_id bigint,
    absence_liee boolean,
    debut_absence timestamp without time zone,
    fin_absence timestamp without time zone,
    motif_id bigint,
    etablissement_id bigint NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: sanction_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE sanction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sanction_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('sanction_id_seq', 1, false);


--
-- Name: type_agenda; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE type_agenda (
    id bigint NOT NULL,
    code character varying(30) NOT NULL,
    libelle character varying(255)
);


--
-- Name: type_agenda_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE type_agenda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: type_agenda_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('type_agenda_id_seq', 1, false);


--
-- Name: type_evenement; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE type_evenement (
    id bigint NOT NULL,
    type character varying(30) NOT NULL
);


--
-- Name: type_evenement_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE type_evenement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: type_evenement_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('type_evenement_id_seq', 7, true);


--
-- Name: type_incident; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE type_incident (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: type_incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE type_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: type_incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('type_incident_id_seq', 1, false);


--
-- Name: type_punition; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE type_punition (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: type_punition_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE type_punition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: type_punition_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('type_punition_id_seq', 1, false);


--
-- Name: type_sanction; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE type_sanction (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: type_sanction_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE type_sanction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: type_sanction_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('type_sanction_id_seq', 1, false);


SET search_path = enttemps_2011_2012, pg_catalog;

--
-- Name: absence_journee; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE absence_journee (
    id bigint NOT NULL,
    etablissement_id bigint NOT NULL,
    date date NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: agenda; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE agenda (
    id bigint NOT NULL,
    item_id bigint NOT NULL,
    type_agenda_id bigint NOT NULL,
    structure_enseignement_id bigint,
    nom character varying(256) NOT NULL,
    description text,
    date_creation timestamp without time zone NOT NULL,
    date_modification timestamp without time zone NOT NULL,
    etablissement_id bigint,
    enseignant_id bigint,
    droits_incomplets boolean DEFAULT false,
    couleur character varying(8)
);


--
-- Name: appel; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE appel (
    id bigint NOT NULL,
    evenement_id bigint NOT NULL,
    appelant_id bigint,
    operateur_saisie_id bigint NOT NULL,
    date_saisie timestamp without time zone NOT NULL,
    valide boolean DEFAULT false,
    date_heure_debut timestamp without time zone NOT NULL,
    date_heure_fin timestamp without time zone NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: appel_ligne; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE appel_ligne (
    id bigint NOT NULL,
    appel_id bigint,
    autorite_id bigint NOT NULL,
    motif_id bigint NOT NULL,
    retard boolean DEFAULT false,
    presence boolean DEFAULT true,
    absence_justifiee boolean,
    heure_arrivee timestamp without time zone,
    depart_anticipe boolean DEFAULT false,
    heure_depart timestamp without time zone,
    absence_previsionnelle boolean DEFAULT false,
    commentaire_arrivee character varying(250),
    commentaire_depart character varying(250),
    heure_debut time without time zone,
    heure_fin time without time zone,
    sanction_id bigint,
    operateur_saisie_id bigint,
    date_saisie date,
    absence_journee_id bigint,
    demi_pension boolean DEFAULT false NOT NULL,
    internat boolean DEFAULT false NOT NULL,
    CONSTRAINT chk_appel_ligne_depart_anticipe_heure_depart CHECK (((depart_anticipe = false) OR (heure_depart IS NOT NULL))),
    CONSTRAINT chk_appel_ligne_heure_debut_heure_fin CHECK (((((appel_id IS NOT NULL) OR (demi_pension = true)) OR (internat = true)) OR ((heure_debut IS NOT NULL) AND (heure_fin IS NOT NULL)))),
    CONSTRAINT chk_appel_ligne_presence_retard_depart_anticipe CHECK (((presence = true) OR ((retard = false) AND (depart_anticipe = false)))),
    CONSTRAINT chk_appel_ligne_rattachement CHECK (((appel_id IS NOT NULL) OR (absence_journee_id IS NOT NULL))),
    CONSTRAINT chk_appel_ligne_retard_heure_arrivee CHECK (((retard = false) OR (heure_arrivee IS NOT NULL))),
    CONSTRAINT chk_appel_ligne_validite_retards_departs CHECK (((((retard = false) AND (depart_anticipe = false)) AND (presence = false)) OR ((absence_previsionnelle = false) AND (absence_justifiee = true))))
);


--
-- Name: appel_plage_horaire; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE appel_plage_horaire (
    appel_id bigint NOT NULL,
    plage_horaire_id bigint NOT NULL
);


--
-- Name: calendrier; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE calendrier (
    id bigint NOT NULL,
    jour_semaine_ferie smallint NOT NULL,
    version integer NOT NULL,
    annee_scolaire_id bigint NOT NULL,
    premier_jour date NOT NULL,
    dernier_jour date NOT NULL,
    etablissement_id bigint NOT NULL
);


--
-- Name: evenement; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE evenement (
    id bigint NOT NULL,
    auteur_id bigint NOT NULL,
    objet character varying(1024) NOT NULL,
    lieu character varying(1024),
    description text,
    uid character varying(1024) NOT NULL,
    rappel character varying(32),
    confidentialite character varying(32),
    disponibilite character varying(32),
    date_heure_debut timestamp without time zone NOT NULL,
    date_heure_fin timestamp without time zone NOT NULL,
    date_creation timestamp without time zone NOT NULL,
    date_modification timestamp without time zone NOT NULL,
    recurrence boolean,
    frequence character varying,
    intervalle integer,
    date_debut_recurrence date,
    date_fin_recurrence date,
    occurence integer,
    agenda_maitre_id bigint NOT NULL,
    toute_la_journee boolean,
    critere character varying(10),
    type_id bigint NOT NULL,
    enseignement_id bigint,
    udt_evenement_ids character varying(1024)
);


--
-- Name: groupe_motif; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE groupe_motif (
    id bigint NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL,
    libelle character varying(512) NOT NULL,
    modifiable boolean DEFAULT true
);


--
-- Name: incident; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE incident (
    id bigint NOT NULL,
    date timestamp without time zone NOT NULL,
    type_id bigint NOT NULL,
    lieu_id bigint NOT NULL,
    description character varying(300),
    etablissement_id bigint NOT NULL,
    gravite smallint NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: lieu_incident; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE lieu_incident (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: motif; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE motif (
    id bigint NOT NULL,
    libelle character varying(512) NOT NULL,
    couleur character varying(32),
    groupe_motif_id bigint NOT NULL,
    modifiable boolean DEFAULT true
);


--
-- Name: partenaire_a_prevenir; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE partenaire_a_prevenir (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: partenaire_a_prevenir_incident; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE partenaire_a_prevenir_incident (
    id bigint NOT NULL,
    incident_id bigint NOT NULL,
    partenaire_a_prevenir_id bigint NOT NULL
);


--
-- Name: plage_horaire; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE plage_horaire (
    id bigint NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL,
    debut time without time zone NOT NULL,
    fin time without time zone NOT NULL,
    matin boolean NOT NULL,
    version integer NOT NULL,
    lundi boolean DEFAULT true,
    mardi boolean DEFAULT true,
    mercredi boolean DEFAULT true,
    jeudi boolean DEFAULT true,
    vendredi boolean DEFAULT true,
    samedi boolean DEFAULT true,
    dimanche boolean DEFAULT false
);


--
-- Name: preference_etablissement_absences; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE preference_etablissement_absences (
    id bigint NOT NULL,
    etablissement_id bigint,
    pas_decompte_absences_retards character varying(10),
    param_item_id bigint,
    version integer,
    autorise_saisie_hors_edt boolean NOT NULL,
    longueur_plage real,
    annee_scolaire_id bigint NOT NULL
);


--
-- Name: protagoniste_incident; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE protagoniste_incident (
    id bigint NOT NULL,
    incident_id bigint NOT NULL,
    autorite_id bigint NOT NULL,
    qualite_id bigint NOT NULL,
    type character varying(10) NOT NULL
);


--
-- Name: punition; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE punition (
    id bigint NOT NULL,
    date date NOT NULL,
    type_punition_id bigint NOT NULL,
    effectue boolean NOT NULL,
    description character varying(300),
    incident_id bigint,
    etablissement_id bigint NOT NULL,
    eleve_id bigint,
    censeur_id bigint,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: qualite_protagoniste; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE qualite_protagoniste (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: rel_agenda_evenement; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE rel_agenda_evenement (
    evenement_id bigint NOT NULL,
    agenda_id bigint NOT NULL,
    id bigint NOT NULL
);


--
-- Name: sanction; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE sanction (
    id bigint NOT NULL,
    date date NOT NULL,
    type_sanction_id bigint NOT NULL,
    effectue boolean NOT NULL,
    eleve_id bigint NOT NULL,
    censeur_id bigint NOT NULL,
    description character varying(300),
    incident_id bigint,
    absence_liee boolean,
    debut_absence timestamp without time zone,
    fin_absence timestamp without time zone,
    motif_id bigint,
    etablissement_id bigint NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: type_incident; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE type_incident (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: type_punition; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE type_punition (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- Name: type_sanction; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE type_sanction (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


SET search_path = forum, pg_catalog;

--
-- Name: commentaire; Type: TABLE; Schema: forum; Owner: -; Tablespace: 
--

CREATE TABLE commentaire (
    id bigint NOT NULL,
    version integer NOT NULL,
    discussion_id bigint NOT NULL,
    autorite_id bigint NOT NULL,
    contenu text NOT NULL,
    date_creation timestamp without time zone NOT NULL,
    code_etat_commentaire character varying(10) NOT NULL,
    libelle_auteur character varying(512)
);


--
-- Name: commentaire_id_seq; Type: SEQUENCE; Schema: forum; Owner: -
--

CREATE SEQUENCE commentaire_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commentaire_id_seq; Type: SEQUENCE OWNED BY; Schema: forum; Owner: -
--

ALTER SEQUENCE commentaire_id_seq OWNED BY commentaire.id;


--
-- Name: commentaire_id_seq; Type: SEQUENCE SET; Schema: forum; Owner: -
--

SELECT pg_catalog.setval('commentaire_id_seq', 1, false);


--
-- Name: commentaire_lu; Type: TABLE; Schema: forum; Owner: -; Tablespace: 
--

CREATE TABLE commentaire_lu (
    commentaire_id bigint NOT NULL,
    version integer NOT NULL,
    autorite_id bigint NOT NULL,
    date_lecture timestamp without time zone
);


--
-- Name: discussion; Type: TABLE; Schema: forum; Owner: -; Tablespace: 
--

CREATE TABLE discussion (
    id bigint NOT NULL,
    version integer NOT NULL,
    autorite_id bigint NOT NULL,
    code_etat_discussion character varying(10) NOT NULL,
    code_type_moderation character varying(10) NOT NULL,
    libelle character varying(200) NOT NULL,
    date_creation timestamp without time zone NOT NULL,
    item_cible_id bigint NOT NULL
);


--
-- Name: discussion_id_seq; Type: SEQUENCE; Schema: forum; Owner: -
--

CREATE SEQUENCE discussion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discussion_id_seq; Type: SEQUENCE OWNED BY; Schema: forum; Owner: -
--

ALTER SEQUENCE discussion_id_seq OWNED BY discussion.id;


--
-- Name: discussion_id_seq; Type: SEQUENCE SET; Schema: forum; Owner: -
--

SELECT pg_catalog.setval('discussion_id_seq', 1, false);


--
-- Name: etat_commentaire; Type: TABLE; Schema: forum; Owner: -; Tablespace: 
--

CREATE TABLE etat_commentaire (
    code character varying(10) NOT NULL,
    version integer NOT NULL,
    libelle character varying(60) NOT NULL
);


--
-- Name: etat_discussion; Type: TABLE; Schema: forum; Owner: -; Tablespace: 
--

CREATE TABLE etat_discussion (
    code character varying(10) NOT NULL,
    version integer NOT NULL,
    libelle character varying(60) NOT NULL
);


--
-- Name: type_moderation; Type: TABLE; Schema: forum; Owner: -; Tablespace: 
--

CREATE TABLE type_moderation (
    code character varying(10) NOT NULL,
    version integer NOT NULL,
    libelle character varying(60) NOT NULL
);


SET search_path = impression, pg_catalog;

--
-- Name: publipostage_suivi; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE publipostage_suivi (
    id bigint NOT NULL,
    media smallint,
    periode character varying(256),
    accuse_reception boolean,
    accuse_envoi boolean,
    classe_id bigint,
    personne_id bigint,
    operateur_id bigint,
    template_document_id bigint,
    date_envoi timestamp without time zone,
    version integer NOT NULL,
    type_fonctionnalite_id bigint NOT NULL,
    etablissement_id bigint NOT NULL,
    responsable_id bigint,
    sms_fournisseur_etablissement_id bigint,
    message_id_externe character varying(256),
    erreur smallint NOT NULL,
    statut character varying(30)
);


--
-- Name: publipostage_suivi_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE publipostage_suivi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publipostage_suivi_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('publipostage_suivi_id_seq', 1, false);


--
-- Name: sms_fournisseur; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE sms_fournisseur (
    id bigint NOT NULL,
    nom character varying(30),
    url_envoi_http character varying(256),
    url_envoi_https character varying(256),
    url_suivi_http character varying(256)
);


--
-- Name: sms_fournisseur_etablissement; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE sms_fournisseur_etablissement (
    id bigint NOT NULL,
    sms_fournisseur_id bigint,
    sms_login character varying(50),
    sms_mot_de_passe character varying(50),
    sms_identifiants_codes boolean,
    sms_https_envoi boolean,
    etablissement_id bigint NOT NULL,
    actif boolean
);


--
-- Name: sms_fournisseur_etablissement_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE sms_fournisseur_etablissement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sms_fournisseur_etablissement_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('sms_fournisseur_etablissement_id_seq', 1, false);


--
-- Name: sms_fournisseur_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE sms_fournisseur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sms_fournisseur_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('sms_fournisseur_id_seq', 1, false);


--
-- Name: template_champ_memo; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE template_champ_memo (
    id bigint NOT NULL,
    champ character varying(256) NOT NULL,
    template text,
    template_document_id bigint
);


--
-- Name: template_champ_memo_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_champ_memo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: template_champ_memo_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_champ_memo_id_seq', 1, false);


--
-- Name: template_document; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE template_document (
    id bigint NOT NULL,
    nom character varying(256) NOT NULL,
    descriptif text,
    media smallint,
    template_eliot_id bigint,
    etablissement_id bigint,
    code character varying(32),
    systeme boolean DEFAULT false NOT NULL,
    numero_version integer DEFAULT 0 NOT NULL,
    actif boolean DEFAULT true NOT NULL
);


--
-- Name: template_document_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: template_document_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_document_id_seq', 1, false);


--
-- Name: template_document_sous_template_eliot; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE template_document_sous_template_eliot (
    id bigint NOT NULL,
    param character varying(256),
    template_document_id bigint,
    template_eliot_id bigint
);


--
-- Name: template_document_sous_template_eliot_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_document_sous_template_eliot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: template_document_sous_template_eliot_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_document_sous_template_eliot_id_seq', 1, false);


--
-- Name: template_eliot; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE template_eliot (
    id bigint NOT NULL,
    nom character varying(256) NOT NULL,
    descriptif text,
    sous_rapport boolean,
    template_jasper_id bigint,
    type_donnees_id bigint,
    type_fonctionnalite_id bigint,
    code character varying(32) NOT NULL,
    numero_version integer NOT NULL,
    info_absences boolean DEFAULT false NOT NULL,
    info_retards boolean DEFAULT false NOT NULL,
    info_releve_notes boolean DEFAULT false NOT NULL,
    info_bulletin_notes boolean DEFAULT false NOT NULL,
    info_detail_absences boolean DEFAULT false NOT NULL,
    info_detail_retards boolean DEFAULT false NOT NULL
);


--
-- Name: template_eliot_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_eliot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: template_eliot_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_eliot_id_seq', 1, false);


--
-- Name: template_jasper; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE template_jasper (
    id bigint NOT NULL,
    jrxml text NOT NULL,
    sous_template_id bigint,
    jasper bytea,
    param character varying(256),
    template_dynamique_factory_classe character varying(255)
);


--
-- Name: template_jasper_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_jasper_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: template_jasper_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_jasper_id_seq', 1, false);


--
-- Name: template_type_donnees; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE template_type_donnees (
    id bigint NOT NULL,
    libelle character varying(256) NOT NULL,
    code character varying(32) NOT NULL
);


--
-- Name: template_type_donnees_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_type_donnees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: template_type_donnees_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_type_donnees_id_seq', 8, true);


--
-- Name: template_type_fonctionnalite; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE template_type_fonctionnalite (
    id bigint NOT NULL,
    libelle character varying(256) NOT NULL,
    parent_id bigint,
    code character varying(32) NOT NULL
);


--
-- Name: template_type_fonctionnalite_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_type_fonctionnalite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: template_type_fonctionnalite_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_type_fonctionnalite_id_seq', 12, true);


SET search_path = public, pg_catalog;




--
-- Name: eliot_version_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE eliot_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eliot_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('eliot_version_id_seq', 14, true);


--
-- Name: eliot_version; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eliot_version (
    id bigint DEFAULT nextval('eliot_version_id_seq'::regclass) NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    code character varying(128) NOT NULL
);


SET search_path = securite, pg_catalog;

--
-- Name: autorisation; Type: TABLE; Schema: securite; Owner: -; Tablespace: 
--

CREATE TABLE autorisation (
    id bigint NOT NULL,
    version integer NOT NULL,
    item_id bigint,
    autorite_id bigint NOT NULL,
    valeur_permissions_explicite integer NOT NULL,
    proprietaire boolean DEFAULT false NOT NULL,
    autorisation_heritee_id bigint,
    valeur_permissions_explicite_defaut integer DEFAULT 0 NOT NULL
);


--
-- Name: autorisation_id_seq; Type: SEQUENCE; Schema: securite; Owner: -
--

CREATE SEQUENCE autorisation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: autorisation_id_seq; Type: SEQUENCE SET; Schema: securite; Owner: -
--

SELECT pg_catalog.setval('autorisation_id_seq', 1, false);


--
-- Name: autorite_id_seq; Type: SEQUENCE; Schema: securite; Owner: -
--

CREATE SEQUENCE autorite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: autorite_id_seq; Type: SEQUENCE SET; Schema: securite; Owner: -
--

SELECT pg_catalog.setval('autorite_id_seq', 1, false);


--
-- Name: item; Type: TABLE; Schema: securite; Owner: -; Tablespace: 
--

CREATE TABLE item (
    id bigint NOT NULL,
    version integer NOT NULL,
    type character varying(128) NOT NULL,
    item_parent_id bigint,
    nom_entite_cible character varying(128),
    enregistrement_cible_id bigint,
    est_active boolean DEFAULT true,
    import_id bigint,
    date_desactivation timestamp without time zone
);


--
-- Name: item_id_seq; Type: SEQUENCE; Schema: securite; Owner: -
--

CREATE SEQUENCE item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_id_seq; Type: SEQUENCE SET; Schema: securite; Owner: -
--

SELECT pg_catalog.setval('item_id_seq', 1, false);


--
-- Name: perimetre; Type: TABLE; Schema: securite; Owner: -; Tablespace: 
--

CREATE TABLE perimetre (
    id bigint NOT NULL,
    nom_entite_cible character varying(128),
    enregistrement_cible_id bigint,
    est_active boolean DEFAULT true,
    import_id bigint,
    date_desactivation timestamp without time zone,
    perimetre_parent_id bigint
);


--
-- Name: perimetre_id_seq; Type: SEQUENCE; Schema: securite; Owner: -
--

CREATE SEQUENCE perimetre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: perimetre_id_seq; Type: SEQUENCE SET; Schema: securite; Owner: -
--

SELECT pg_catalog.setval('perimetre_id_seq', 1, false);


--
-- Name: perimetre_securite; Type: TABLE; Schema: securite; Owner: -; Tablespace: 
--

CREATE TABLE perimetre_securite (
    id bigint NOT NULL,
    item_id bigint NOT NULL,
    perimetre_id bigint NOT NULL
);


--
-- Name: perimetre_securite_id_seq; Type: SEQUENCE; Schema: securite; Owner: -
--

CREATE SEQUENCE perimetre_securite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: perimetre_securite_id_seq; Type: SEQUENCE SET; Schema: securite; Owner: -
--

SELECT pg_catalog.setval('perimetre_securite_id_seq', 1, false);


--
-- Name: permission; Type: TABLE; Schema: securite; Owner: -; Tablespace: 
--

CREATE TABLE permission (
    id bigint NOT NULL,
    version integer NOT NULL,
    nom character varying(128) NOT NULL,
    valeur integer NOT NULL
);


--
-- Name: permission_id_seq; Type: SEQUENCE; Schema: securite; Owner: -
--

CREATE SEQUENCE permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_id_seq; Type: SEQUENCE SET; Schema: securite; Owner: -
--

SELECT pg_catalog.setval('permission_id_seq', 5, true);


SET search_path = td, pg_catalog;

--
-- Name: copie; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE copie (
    id bigint NOT NULL,
    date_remise timestamp with time zone,
    sujet_id bigint NOT NULL,
    eleve_id bigint,
    correcteur_id bigint,
    correction_date timestamp with time zone,
    correction_annotation text,
    correction_note_automatique double precision,
    correction_note_finale double precision,
    modalite_activite_id bigint,
    correction_note_correcteur double precision,
    correction_note_non_numerique character varying(255),
    max_points double precision,
    max_points_automatique double precision,
    max_points_correcteur double precision,
    points_modulation double precision DEFAULT 0::double precision,
    est_jetable boolean DEFAULT false NOT NULL,
    date_enregistrement timestamp with time zone
);


--
-- Name: copie_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE copie_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: copie_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('copie_id_seq', 100, false);


--
-- Name: modalite_activite; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE modalite_activite (
    id bigint NOT NULL,
    date_remise_reponses timestamp with time zone NOT NULL,
    date_debut timestamp with time zone NOT NULL,
    date_fin timestamp with time zone NOT NULL,
    etablissement_id bigint,
    responsable_id bigint,
    groupe_id bigint,
    enseignant_id bigint NOT NULL,
    activite_id bigint,
    evaluation_id bigint,
    sujet_id bigint NOT NULL,
    copie_ameliorable boolean DEFAULT true NOT NULL,
    structure_enseignement_id bigint,
    matiere_id bigint
);


--
-- Name: modalite_activite_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE modalite_activite_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modalite_activite_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('modalite_activite_id_seq', 100, false);


--
-- Name: question; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE question (
    id bigint NOT NULL,
    titre text NOT NULL,
    est_autonome boolean DEFAULT true NOT NULL,
    specification text NOT NULL,
    version_question integer DEFAULT 1 NOT NULL,
    type_id bigint NOT NULL,
    proprietaire_id bigint NOT NULL,
    matiere_id bigint,
    etablissement_id bigint,
    niveau_id bigint,
    publication_id bigint,
    titre_normalise text,
    publie boolean DEFAULT false NOT NULL,
    date_created timestamp with time zone,
    last_updated timestamp with time zone,
    copyrights_type_id bigint NOT NULL,
    specification_normalise text,
    paternite text,
    exercice_id bigint,
    attachement_id bigint,
    principal_attachement_est_insere_dans_la_question boolean
);


--
-- Name: question_attachement; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE question_attachement (
    id bigint NOT NULL,
    question_id bigint NOT NULL,
    attachement_id bigint NOT NULL,
    rang integer DEFAULT 1,
    est_insere_dans_la_question boolean DEFAULT true NOT NULL
);


--
-- Name: question_attachement_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE question_attachement_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_attachement_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('question_attachement_id_seq', 100, false);


--
-- Name: question_export; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE question_export (
    id bigint NOT NULL,
    format_id bigint NOT NULL,
    export text NOT NULL,
    question_id bigint NOT NULL
);


--
-- Name: question_export_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE question_export_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_export_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('question_export_id_seq', 100, false);


--
-- Name: question_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE question_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('question_id_seq', 100, false);


--
-- Name: question_type; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE question_type (
    id bigint NOT NULL,
    nom character varying(255) NOT NULL,
    nom_anglais character varying(255),
    code character varying(255) DEFAULT 'Undefined'::character varying NOT NULL,
    interaction boolean DEFAULT true NOT NULL
);


--
-- Name: question_type_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE question_type_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_type_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('question_type_id_seq', 100, false);


--
-- Name: reponse; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE reponse (
    id bigint NOT NULL,
    specification text,
    copie_id bigint NOT NULL,
    correcteur_id bigint,
    correction_date timestamp with time zone,
    correction_annotation text,
    correction_note_automatique double precision,
    correction_note_finale double precision,
    correction_note_correcteur double precision,
    correction_note_non_numerique character varying(255),
    eleve_id bigint,
    sujet_question_id bigint NOT NULL,
    rang integer
);


--
-- Name: reponse_attachement; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE reponse_attachement (
    id bigint NOT NULL,
    reponse_id bigint NOT NULL,
    attachement_id bigint NOT NULL,
    rang integer DEFAULT 1
);


--
-- Name: reponse_attachement_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE reponse_attachement_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reponse_attachement_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('reponse_attachement_id_seq', 100, false);


--
-- Name: reponse_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE reponse_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reponse_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('reponse_id_seq', 100, false);


--
-- Name: sujet; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE sujet (
    id bigint NOT NULL,
    titre text NOT NULL,
    version_sujet integer DEFAULT 1 NOT NULL,
    proprietaire_id bigint NOT NULL,
    matiere_id bigint,
    etablissement_id bigint,
    niveau_id bigint,
    duree_minutes integer,
    presentation text,
    note_max double precision,
    note_auto_max double precision,
    note_enseignant_max double precision,
    nb_questions integer,
    publication_id bigint,
    annotation_privee text,
    copyrights_type_id bigint NOT NULL,
    acces_public boolean NOT NULL,
    acces_sequentiel boolean NOT NULL,
    ordre_questions_aleatoire boolean NOT NULL,
    titre_normalise text,
    presentation_normalise text,
    publie boolean DEFAULT false NOT NULL,
    date_created timestamp with time zone,
    last_updated timestamp with time zone,
    sujet_type_id bigint,
    paternite text
);


--
-- Name: sujet_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE sujet_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sujet_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('sujet_id_seq', 100, false);


--
-- Name: sujet_sequence_questions; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE sujet_sequence_questions (
    id bigint NOT NULL,
    sujet_id bigint NOT NULL,
    question_id bigint NOT NULL,
    questions_sequences_idx integer NOT NULL,
    note_seuil_poursuite double precision,
    points double precision DEFAULT 1::double precision NOT NULL
);


--
-- Name: sujet_sequence_questions_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE sujet_sequence_questions_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sujet_sequence_questions_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('sujet_sequence_questions_id_seq', 100, false);


--
-- Name: sujet_type; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE sujet_type (
    id bigint NOT NULL,
    nom character varying(255) NOT NULL,
    nom_anglais character varying(255) NOT NULL
);


--
-- Name: sujet_type_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE sujet_type_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sujet_type_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('sujet_type_id_seq', 100, false);


SET search_path = tice, pg_catalog;

--
-- Name: attachement; Type: TABLE; Schema: tice; Owner: -; Tablespace: 
--

CREATE TABLE attachement (
    id bigint NOT NULL,
    chemin text NOT NULL,
    nom character varying(255) NOT NULL,
    taille bigint,
    type_mime character varying(255),
    nom_fichier_original character varying(255),
    a_supprimer boolean DEFAULT false,
    dimension_hauteur bigint,
    dimension_largeur bigint
);


--
-- Name: attachement_id_seq; Type: SEQUENCE; Schema: tice; Owner: -
--

CREATE SEQUENCE attachement_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachement_id_seq; Type: SEQUENCE SET; Schema: tice; Owner: -
--

SELECT pg_catalog.setval('attachement_id_seq', 100, false);


--
-- Name: compte_utilisateur; Type: TABLE; Schema: tice; Owner: -; Tablespace: 
--

CREATE TABLE compte_utilisateur (
    id bigint NOT NULL,
    personne_id bigint NOT NULL,
    version bigint NOT NULL,
    login character varying(255) NOT NULL,
    login_alias character varying(255),
    password character varying(255) NOT NULL,
    compte_expire boolean NOT NULL,
    compte_verrouille boolean NOT NULL,
    compte_active boolean NOT NULL,
    password_expire boolean NOT NULL,
    date_derniere_connexion timestamp with time zone
);


--
-- Name: compte_utilisateur_id_seq; Type: SEQUENCE; Schema: tice; Owner: -
--

CREATE SEQUENCE compte_utilisateur_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: compte_utilisateur_id_seq; Type: SEQUENCE SET; Schema: tice; Owner: -
--

SELECT pg_catalog.setval('compte_utilisateur_id_seq', 100, false);


--
-- Name: copyrights_type; Type: TABLE; Schema: tice; Owner: -; Tablespace: 
--

CREATE TABLE copyrights_type (
    id bigint NOT NULL,
    code character varying(255) NOT NULL,
    presentation text,
    lien text,
    logo text,
    option_cc_paternite boolean DEFAULT true,
    option_cc_pas_utilisation_commerciale boolean DEFAULT true,
    option_cc_pas_modification boolean DEFAULT true,
    option_cc_partage_viral boolean DEFAULT true,
    option_tous_droits_reserves boolean DEFAULT true
);


--
-- Name: copyrights_type_id_seq; Type: SEQUENCE; Schema: tice; Owner: -
--

CREATE SEQUENCE copyrights_type_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: copyrights_type_id_seq; Type: SEQUENCE SET; Schema: tice; Owner: -
--

SELECT pg_catalog.setval('copyrights_type_id_seq', 100, false);


--
-- TOC entry 547 (class 1259 OID 139155)
-- Dependencies: 21
-- Name: db_data_record; Type: TABLE; Schema: tice; Owner: -; Tablespace:
--

CREATE TABLE db_data_record (
    id bigint NOT NULL,
    identifier character varying(128) NOT NULL,
    last_updated timestamp with time zone NOT NULL,
    file_content bytea NOT NULL
);


--
-- TOC entry 546 (class 1259 OID 139153)
-- Dependencies: 21
-- Name: db_data_record_id_seq; Type: SEQUENCE; Schema: tice; Owner: -
--

CREATE SEQUENCE db_data_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5317 (class 0 OID 0)
-- Dependencies: 546
-- Name: db_data_record_id_seq; Type: SEQUENCE SET; Schema: tice; Owner: -
--

SELECT pg_catalog.setval('db_data_record_id_seq', 1, false);


--
-- TOC entry 516 (class 1259 OID 138565)
-- Dependencies: 21
-- Name: export_format; Type: TABLE; Schema: tice; Owner: -; Tablespace:
--

CREATE TABLE export_format (
    id bigint NOT NULL,
    nom character varying(255) NOT NULL,
    code character varying(255) NOT NULL
);


--
-- Name: export_format_id_seq; Type: SEQUENCE; Schema: tice; Owner: -
--

CREATE SEQUENCE export_format_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: export_format_id_seq; Type: SEQUENCE SET; Schema: tice; Owner: -
--

SELECT pg_catalog.setval('export_format_id_seq', 100, false);


--
-- Name: publication; Type: TABLE; Schema: tice; Owner: -; Tablespace: 
--

CREATE TABLE publication (
    id bigint NOT NULL,
    copyrights_type_id bigint NOT NULL,
    date_debut timestamp with time zone NOT NULL,
    date_fin timestamp with time zone
);


--
-- Name: publication_id_seq; Type: SEQUENCE; Schema: tice; Owner: -
--

CREATE SEQUENCE publication_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publication_id_seq; Type: SEQUENCE SET; Schema: tice; Owner: -
--

SELECT pg_catalog.setval('publication_id_seq', 100, false);


SET search_path = udt, pg_catalog;

--
-- Name: enseignement; Type: TABLE; Schema: udt; Owner: -; Tablespace: 
--

CREATE TABLE enseignement (
    id bigint NOT NULL,
    co_enseignement boolean NOT NULL,
    matiere_id bigint NOT NULL,
    professeur_id bigint NOT NULL,
    structure_enseignement_id bigint NOT NULL,
    udt_import_id bigint NOT NULL,
    cree_cdt boolean NOT NULL,
    etat character varying(20) DEFAULT 'EN_ATTENTE'::character varying NOT NULL,
    CONSTRAINT chk_etat CHECK (((etat)::text = ANY ((ARRAY['TRAITE'::character varying, 'EN_ATTENTE'::character varying, 'ERREUR'::character varying])::text[])))
);


--
-- Name: enseignement_id_seq; Type: SEQUENCE; Schema: udt; Owner: -
--

CREATE SEQUENCE enseignement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enseignement_id_seq; Type: SEQUENCE SET; Schema: udt; Owner: -
--

SELECT pg_catalog.setval('enseignement_id_seq', 1, false);


--
-- Name: evenement; Type: TABLE; Schema: udt; Owner: -; Tablespace: 
--

CREATE TABLE evenement (
    id bigint NOT NULL,
    date_debut timestamp with time zone NOT NULL,
    date_fin timestamp with time zone NOT NULL,
    salle character varying(50),
    etat character varying(50) DEFAULT 'EN_ATTENTE'::character varying,
    libelle character varying(100),
    co_enseignement boolean,
    matiere_id bigint,
    professeur_id bigint,
    structure_enseignement_id bigint,
    udt_import_id bigint NOT NULL,
    semaine_index smallint NOT NULL,
    jour_index smallint NOT NULL,
    sequence_index smallint NOT NULL,
    id_externe character varying(30) NOT NULL,
    annee smallint NOT NULL,
    CONSTRAINT chk_etat CHECK (((etat)::text = ANY ((ARRAY['TRAITE'::character varying, 'EN_ATTENTE'::character varying, 'ERREUR'::character varying])::text[])))
);


--
-- Name: evenement_id_seq; Type: SEQUENCE; Schema: udt; Owner: -
--

CREATE SEQUENCE evenement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: evenement_id_seq; Type: SEQUENCE SET; Schema: udt; Owner: -
--

SELECT pg_catalog.setval('evenement_id_seq', 1, false);


--
-- Name: import; Type: TABLE; Schema: udt; Owner: -; Tablespace: 
--

CREATE TABLE import (
    id bigint NOT NULL,
    semaines character varying(255) NOT NULL,
    etablissement_id bigint NOT NULL,
    date_debut_pre_traitement timestamp without time zone NOT NULL,
    date_fin_import timestamp without time zone,
    date_fin_pre_traitement timestamp without time zone
);


--
-- Name: import_id_seq; Type: SEQUENCE; Schema: udt; Owner: -
--

CREATE SEQUENCE import_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_id_seq; Type: SEQUENCE SET; Schema: udt; Owner: -
--

SELECT pg_catalog.setval('import_id_seq', 1, false);


SET search_path = ent, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: ent; Owner: -
--

ALTER TABLE ONLY service ALTER COLUMN id SET DEFAULT nextval('services_id_seq'::regclass);


SET search_path = forum, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: forum; Owner: -
--

ALTER TABLE ONLY commentaire ALTER COLUMN id SET DEFAULT nextval('commentaire_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forum; Owner: -
--

ALTER TABLE ONLY discussion ALTER COLUMN id SET DEFAULT nextval('discussion_id_seq'::regclass);


SET search_path = aaf, pg_catalog;

--
-- Data for Name: import; Type: TABLE DATA; Schema: aaf; Owner: -
--



--
-- Data for Name: import_verrou; Type: TABLE DATA; Schema: aaf; Owner: -
--



SET search_path = bascule_annee, pg_catalog;

--
-- Data for Name: etape; Type: TABLE DATA; Schema: bascule_annee; Owner: -
--



--
-- Data for Name: verrou; Type: TABLE DATA; Schema: bascule_annee; Owner: -
--



SET search_path = ent, pg_catalog;

--
-- Data for Name: annee_scolaire; Type: TABLE DATA; Schema: ent; Owner: -
--

INSERT INTO annee_scolaire (code, version, annee_en_cours, id) VALUES ('2011-2012', 0, true, 1);


--
-- Data for Name: appartenance_groupe_groupe; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: appartenance_personne_groupe; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: calendrier; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: civilite; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: enseignement; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: etablissement; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: fiche_eleve_commentaire; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: filiere; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: fonction; Type: TABLE DATA; Schema: ent; Owner: -
--

INSERT INTO fonction (id, code, libelle) VALUES (1, 'AC', 'ADMINISTRATEUR_CENTRAL');
INSERT INTO fonction (id, code, libelle) VALUES (2, 'AL', 'ADMINISTRATEUR_LOCAL');
INSERT INTO fonction (id, code, libelle) VALUES (3, 'CD', 'CORRESPONDANT_DEPLOIEMENT');
INSERT INTO fonction (id, code, libelle) VALUES (4, 'UI', 'INVITE');
INSERT INTO fonction (id, code, libelle) VALUES (5, 'ELEVE', 'ELEVE');
INSERT INTO fonction (id, code, libelle) VALUES (6, 'PERS_REL_ELEVE', 'PERSONNES EN RELATION ELEVE');
INSERT INTO fonction (id, code, libelle) VALUES (7, 'ENS', 'ENSEIGNEMENT');
INSERT INTO fonction (id, code, libelle) VALUES (8, 'DIR', 'DIRECTION');
INSERT INTO fonction (id, code, libelle) VALUES (9, 'EDU', 'EDUCATION');
INSERT INTO fonction (id, code, libelle) VALUES (10, 'DOC', 'DOCUMENTATION');
INSERT INTO fonction (id, code, libelle) VALUES (11, 'CFC', 'CONSEILLER EN
      FORMATION CONTINUE');
INSERT INTO fonction (id, code, libelle) VALUES (12, 'CTR', 'CHEF DE
      TRAVAUX');
INSERT INTO fonction (id, code, libelle) VALUES (13, 'ADF', 'PERSONNELS
      ADMINISTRATIFS');
INSERT INTO fonction (id, code, libelle) VALUES (14, 'ALB', 'LABORATOIRE');
INSERT INTO fonction (id, code, libelle) VALUES (15, 'ASE', 'ASSISTANT
      ETRANGER');
INSERT INTO fonction (id, code, libelle) VALUES (16, 'LAB', 'PERSONNELS DE
      LABORATOIRE');
INSERT INTO fonction (id, code, libelle) VALUES (17, 'MDS', 'PERSONNELS
      MEDICO-SOCIAUX');
INSERT INTO fonction (id, code, libelle) VALUES (18, 'OUV', 'PERSONNELS
      OUVRIERS ET DE SERVICES');
INSERT INTO fonction (id, code, libelle) VALUES (19, 'SUR', 'SURVEILLANCE');


--
-- Data for Name: groupe_personnes; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: matiere; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: mef; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: modalite_cours; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: modalite_matiere; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: niveau; Type: TABLE DATA; Schema: ent; Owner: -
--

INSERT INTO niveau (id, libelle_court, libelle_long, libelle_edition) VALUES (1, 'INDÉTERMINÉ', 'INDÉTERMINÉ', 'INDÉTERMINÉ');


--
-- Data for Name: periode; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: personne; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: personne_propriete_scolarite; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: porteur_ent; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: preference_etablissement; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: propriete_scolarite; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: regime; Type: TABLE DATA; Schema: ent; Owner: -
--

INSERT INTO regime (id, code) VALUES (1, 'EXTERNAT');
INSERT INTO regime (id, code) VALUES (2, 'DEMI-PENSION');
INSERT INTO regime (id, code) VALUES (3, 'INTERNAT');


--
-- Data for Name: rel_classe_filiere; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: rel_classe_groupe; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: rel_periode_service; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: responsable_eleve; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: responsable_propriete_scolarite; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: service; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: signature; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: source_import; Type: TABLE DATA; Schema: ent; Owner: -
--

INSERT INTO source_import (id, code, libelle) VALUES (1, 'STS', 'STSweb');
INSERT INTO source_import (id, code, libelle) VALUES (2, 'AAF', 'Annuaire Académique Fédérateur');
INSERT INTO source_import (id, code, libelle) VALUES (3, 'UDT', 'UnDeuxTEMPS');


--
-- Data for Name: sous_service; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: structure_enseignement; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- Data for Name: type_periode; Type: TABLE DATA; Schema: ent; Owner: -
--

INSERT INTO type_periode (id, libelle, version, intervalle, nature, etablissement_id) VALUES (1, NULL, 0, 'S1', 'NOTATION', NULL);
INSERT INTO type_periode (id, libelle, version, intervalle, nature, etablissement_id) VALUES (2, NULL, 0, 'S2', 'NOTATION', NULL);
INSERT INTO type_periode (id, libelle, version, intervalle, nature, etablissement_id) VALUES (3, NULL, 0, 'T1', 'NOTATION', NULL);
INSERT INTO type_periode (id, libelle, version, intervalle, nature, etablissement_id) VALUES (4, NULL, 0, 'T2', 'NOTATION', NULL);
INSERT INTO type_periode (id, libelle, version, intervalle, nature, etablissement_id) VALUES (5, NULL, 0, 'T3', 'NOTATION', NULL);
INSERT INTO type_periode (id, libelle, version, intervalle, nature, etablissement_id) VALUES (6, NULL, 0, 'ANNEE', 'NOTATION', NULL);


SET search_path = ent_2011_2012, pg_catalog;

--
-- Data for Name: calendrier; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: enseignement; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: matiere; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: modalite_matiere; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: periode; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: personne_propriete_scolarite; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: preference_etablissement; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: propriete_scolarite; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: rel_classe_filiere; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: rel_classe_groupe; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: rel_periode_service; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: responsable_propriete_scolarite; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: service; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: sous_service; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- Data for Name: structure_enseignement; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



SET search_path = entcdt, pg_catalog;

--
-- Data for Name: activite; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: cahier_de_textes; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: chapitre; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: contexte_activite; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: date_activite; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: dossier; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: fichier; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: rel_activite_acteur; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: rel_cahier_acteur; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: rel_cahier_groupe; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: rel_dossier_autorisation_cahier; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: ressource; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: textes_preferences_utilisateur; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- Data for Name: type_activite; Type: TABLE DATA; Schema: entcdt; Owner: -
--

INSERT INTO type_activite (id, code, nom, description, degre) VALUES (1, 'INTER', 'Activité interactive', 'Activité interactive', 2);


--
-- Data for Name: visa; Type: TABLE DATA; Schema: entcdt; Owner: -
--



SET search_path = entdemon, pg_catalog;

--
-- Data for Name: demande_traitement; Type: TABLE DATA; Schema: entdemon; Owner: -
--



SET search_path = entnotes, pg_catalog;

--
-- Data for Name: appreciation_classe_enseignement_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: appreciation_eleve_enseignement_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: appreciation_eleve_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: avis_conseil_de_classe; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: avis_orientation; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: brevet_epreuve; Type: TABLE DATA; Schema: entnotes; Owner: -
--

INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (1, 101, 'FRANÇAIS', 20, false, false, false, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (2, 102, 'MATHEMATIQUES', 20, false, false, false, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (3, 103, 'PREMIERE LANGUE VIVANTE', 20, false, false, true, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (4, 104, 'SCIENCES DE LA VIE ET DE LA TERRE', 20, false, false, false, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (5, 105, 'PHYSIQUE-CHIMIE', 20, false, false, false, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (6, 106, 'EDUCATION PHYSIQUE ET SPORTIVE', 20, false, false, false, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (7, 107, 'ARTS PLASTIQUES', 20, false, false, false, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (8, 108, 'EDUCATION MUSICALE', 20, false, false, false, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (9, 109, 'TECHNOLOGIE', 20, false, false, false, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (10, 110, 'DEUXIEME LANGUE VIVANTE', 20, false, false, true, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (11, 112, 'VIE SCOLAIRE', 20, false, false, false, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (12, 113, 'OPTION FACULTATIVE', 10, false, true, true, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (13, 121, 'HISTOIRE-GEOGRAPHIE', 20, true, false, false, true, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (14, 122, 'EDUCATION CIVIQUE', 20, true, false, false, true, NULL, 13, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (16, 101, 'FRANÇAIS', 20, false, false, false, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (17, 102, 'MATHEMATIQUES', 20, false, false, false, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (18, 103, 'PREMIERE LANGUE VIVANTE', 20, false, false, true, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (19, 104, 'SCIENCES DE LA VIE ET DE LA TERRE', 20, false, false, false, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (20, 105, 'PHYSIQUE-CHIMIE', 20, false, false, false, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (21, 106, 'EDUCATION PHYSIQUE ET SPORTIVE', 20, false, false, false, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (22, 107, 'ARTS PLASTIQUES', 20, false, false, false, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (23, 108, 'EDUCATION MUSICALE', 20, false, false, false, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (24, 109, 'TECHNOLOGIE', 20, false, false, false, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (25, 110, 'DECOUVERTE PROFESSIONNELLE MODULE 6 HEURES', 40, false, false, true, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (26, 112, 'VIE SCOLAIRE', 20, false, false, false, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (27, 113, 'OPTION FACULTATIVE', 10, false, true, true, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (28, 121, 'HISTOIRE-GEOGRAPHIE', 20, true, false, false, true, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (29, 122, 'EDUCATION CIVIQUE', 20, true, false, false, true, NULL, 13, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (31, 101, 'FRANÇAIS', 20, false, false, false, true, NULL, NULL, 3);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (32, 102, 'MATHEMATIQUES', 20, false, false, false, true, NULL, NULL, 3);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (34, 104, 'SCIENCES PHYSIQUES', 20, false, false, false, true, 33, NULL, 3);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (33, 103, 'PREMIERE LANGUE VIVANTE', 20, false, false, true, true, 34, NULL, 3);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (35, 105, 'PREVENTION SANTE ENVIRONNEMENT', 20, false, false, false, true, NULL, NULL, 3);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (36, 106, 'EDUCATION PHYSIQUE ET SPORTIVE', 20, false, false, false, true, NULL, NULL, 3);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (37, 107, 'EDUCATION ARTISTIQUE', 20, false, false, false, true, NULL, NULL, 3);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (38, 108, 'TECHNOLOGIE', 60, false, false, false, true, NULL, NULL, 3);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (39, 112, 'VIE SCOLAIRE', 20, false, false, false, true, NULL, NULL, 3);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (40, 121, 'HISTOIRE-GEOGRAPHIE EDUCATION CIVIQUE', 20, true, false, false, true, NULL, NULL, 3);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (42, 101, 'FRANÇAIS', 20, false, false, false, true, NULL, NULL, 4);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (43, 102, 'MATHEMATIQUES', 20, false, false, false, true, NULL, NULL, 4);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (45, 104, 'SCIENCES PHYSIQUES', 20, false, false, false, true, 44, NULL, 4);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (44, 103, 'PREMIERE LANGUE VIVANTE', 20, false, false, true, true, 45, NULL, 4);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (46, 105, 'PREVENTION SANTE ENVIRONNEMENT', 20, false, false, false, true, NULL, NULL, 4);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (47, 106, 'EDUCATION PHYSIQUE ET SPORTIVE', 20, false, false, false, true, NULL, NULL, 4);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (48, 107, 'EDUCATION ARTISTIQUE', 20, false, false, false, true, NULL, NULL, 4);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (49, 108, 'TECHNOLOGIE', 40, false, false, false, true, NULL, NULL, 4);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (50, 111, 'DECOUVERTE PROFESSIONNELLE MODULE 6 HEURES', 60, false, false, false, true, NULL, NULL, 4);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (51, 112, 'VIE SCOLAIRE', 20, false, false, false, true, NULL, NULL, 4);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (52, 121, 'HISTOIRE-GEOGRAPHIE EDUCATION CIVIQUE', 20, true, false, false, true, NULL, NULL, 4);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (54, 101, 'FRANÇAIS', 20, false, false, false, true, NULL, NULL, 5);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (55, 102, 'MATHEMATIQUES', 20, false, false, false, true, NULL, NULL, 5);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (56, 103, 'PREMIERE LANGUE VIVANTE', 20, false, false, true, true, NULL, NULL, 5);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (57, 105, 'ECONOMIE FAMILIALE ET SOCIALE', 20, false, false, true, true, NULL, NULL, 5);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (58, 106, 'EDUCATION PHYSIQUE ET SPORTIVE', 20, false, false, false, true, NULL, NULL, 5);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (59, 107, 'EDUCATION SOCIOCULTURELLE', 20, false, false, false, true, NULL, NULL, 5);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (60, 109, 'TECHNOLOGIE : SCIENCES BIOLOGIQUES ET SCIENCES PHYSIQUES', 60, false, false, false, true, NULL, NULL, 5);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (61, 112, 'VIE SCOLAIRE', 20, false, false, false, true, NULL, NULL, 5);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (62, 121, 'HISTOIRE-GEOGRAPHIE EDUCATION CIVIQUE', 20, true, false, false, true, NULL, NULL, 5);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (64, 101, 'FRANÇAIS', 20, false, false, false, true, NULL, NULL, 6);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (65, 102, 'MATHEMATIQUES', 20, false, false, false, true, NULL, NULL, 6);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (66, 103, 'PREMIERE LANGUE VIVANTE', 20, false, false, true, true, NULL, NULL, 6);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (67, 104, 'SCIENCES PHYSIQUES', 20, false, false, false, true, NULL, NULL, 6);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (68, 105, 'PREVENTION SANTE ENVIRONNEMENT', 20, false, false, false, true, NULL, NULL, 6);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (69, 106, 'EDUCATION PHYSIQUE ET SPORTIVE', 20, false, false, false, true, NULL, NULL, 6);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (70, 107, 'EDUCATION ARTISTIQUE', 20, false, false, false, true, NULL, NULL, 6);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (71, 108, 'TECHNOLOGIE', 40, false, false, false, true, NULL, NULL, 6);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (72, 112, 'VIE SCOLAIRE', 20, false, false, false, true, NULL, NULL, 6);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (73, 121, 'HISTOIRE-GEOGRAPHIE EDUCATION CIVIQUE', 20, true, false, false, true, NULL, NULL, 6);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (75, 101, 'FRANÇAIS', 20, false, false, false, true, NULL, NULL, 7);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (76, 102, 'MATHEMATIQUES', 20, false, false, false, true, NULL, NULL, 7);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (77, 103, 'PREMIERE LANGUE VIVANTE', 20, false, false, true, true, NULL, NULL, 7);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (78, 104, 'SCIENCES PHYSIQUES', 20, false, false, false, true, NULL, NULL, 7);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (79, 105, 'PREVENTION SANTE ENVIRONNEMENT', 20, false, false, false, true, NULL, NULL, 7);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (80, 106, 'EDUCATION PHYSIQUE ET SPORTIVE', 20, false, false, false, true, NULL, NULL, 7);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (81, 107, 'EDUCATION ARTISTIQUE', 20, false, false, false, true, NULL, NULL, 7);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (82, 108, 'TECHNOLOGIE', 20, false, false, false, true, NULL, NULL, 7);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (83, 110, 'DECOUVERTE PROFESSIONNELLE MODULE 6 HEURES', 40, false, false, false, true, NULL, NULL, 7);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (84, 112, 'VIE SCOLAIRE', 20, false, false, false, true, NULL, NULL, 7);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (85, 121, 'HISTOIRE-GEOGRAPHIE EDUCATION CIVIQUE', 20, true, false, false, true, NULL, NULL, 7);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (87, 101, 'FRANÇAIS', 20, false, false, false, true, NULL, NULL, 8);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (88, 102, 'MATHEMATIQUES', 20, false, false, false, true, NULL, NULL, 8);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (15, 130, 'NIVEAU A2 DE LANGUE REGIONALE', NULL, true, true, false, false, NULL, NULL, 1);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (30, 130, 'NIVEAU A2 DE LANGUE REGIONALE', NULL, true, true, false, false, NULL, NULL, 2);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (89, 103, 'PREMIERE LANGUE VIVANTE', 20, false, false, true, true, NULL, NULL, 8);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (90, 104, 'SCIENCES PHYSIQUES', 20, false, false, false, true, NULL, NULL, 8);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (91, 105, 'ECONOMIE FAMILIALE ET SOCIALE', 20, false, false, false, true, NULL, NULL, 8);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (92, 106, 'EDUCATION PHYSIQUE ET SPORTIVE', 20, false, false, false, true, NULL, NULL, 8);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (93, 107, 'EDUCATION SOCIOCULTURELLE', 20, false, false, false, true, NULL, NULL, 8);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (94, 109, 'TECHNOLOGIE : SECTEUR SCIENCES BIOLOGIQUES, TECHNIQUES AGRICOLES ET AGROALIMENTAIRES, ACTIVITES TERTIAIRES', 40, false, false, false, true, NULL, NULL, 8);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (95, 112, 'VIE SCOLAIRE', 20, false, false, false, true, NULL, NULL, 8);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (96, 121, 'HISTOIRE-GEOGRAPHIE EDUCATION CIVIQUE', 20, true, false, false, true, NULL, NULL, 8);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (41, 130, 'NIVEAU A2 DE LANGUE REGIONALE', NULL, true, true, false, false, NULL, NULL, 3);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (53, 130, 'NIVEAU A2 DE LANGUE REGIONALE', NULL, true, true, false, false, NULL, NULL, 4);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (63, 130, 'NIVEAU A2 DE LANGUE REGIONALE', NULL, true, true, false, false, NULL, NULL, 5);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (74, 130, 'NIVEAU A2 DE LANGUE REGIONALE', NULL, true, true, false, false, NULL, NULL, 6);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (86, 130, 'NIVEAU A2 DE LANGUE REGIONALE', NULL, true, true, false, false, NULL, NULL, 7);
INSERT INTO brevet_epreuve (id, code, libelle, note_max, indicative, optionnelle, personnalisable, notee, epreuve_exclusive_id, epreuve_matieres_a_heriter_id, serie_id) VALUES (97, 130, 'NIVEAU A2 DE LANGUE REGIONALE', NULL, true, true, false, false, NULL, NULL, 8);


--
-- Data for Name: brevet_fiche; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: brevet_note; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: brevet_note_valeur_textuelle; Type: TABLE DATA; Schema: entnotes; Owner: -
--

INSERT INTO brevet_note_valeur_textuelle (id, valeur) VALUES (1, 'AB');
INSERT INTO brevet_note_valeur_textuelle (id, valeur) VALUES (2, 'DI');
INSERT INTO brevet_note_valeur_textuelle (id, valeur) VALUES (3, 'VA');
INSERT INTO brevet_note_valeur_textuelle (id, valeur) VALUES (4, 'NV');


--
-- Data for Name: brevet_rel_epreuve_matiere; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: brevet_rel_epreuve_note_valeur_textuelle; Type: TABLE DATA; Schema: entnotes; Owner: -
--

INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (1, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (2, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (3, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (3, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (4, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (4, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (5, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (5, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (6, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (6, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (7, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (7, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (8, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (8, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (9, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (9, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (10, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (10, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (11, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (12, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (12, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (13, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (14, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (15, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (15, 3);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (15, 4);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (16, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (17, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (18, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (18, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (19, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (19, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (20, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (20, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (21, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (21, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (22, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (22, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (23, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (23, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (24, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (24, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (25, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (25, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (26, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (27, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (27, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (28, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (29, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (30, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (30, 3);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (30, 4);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (31, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (32, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (33, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (33, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (34, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (34, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (35, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (35, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (36, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (36, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (37, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (37, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (38, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (38, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (39, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (40, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (41, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (41, 3);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (41, 4);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (42, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (43, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (44, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (44, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (45, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (45, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (46, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (46, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (47, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (47, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (48, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (48, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (49, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (49, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (50, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (50, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (51, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (52, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (53, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (53, 3);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (53, 4);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (54, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (55, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (56, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (56, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (57, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (57, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (58, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (58, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (59, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (59, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (60, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (60, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (61, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (62, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (63, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (63, 3);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (63, 4);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (64, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (65, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (66, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (66, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (67, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (67, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (68, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (68, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (69, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (69, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (70, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (70, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (71, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (71, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (72, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (73, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (74, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (74, 3);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (74, 4);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (75, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (76, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (77, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (77, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (78, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (78, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (79, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (79, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (80, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (80, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (81, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (81, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (82, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (82, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (83, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (83, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (84, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (85, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (86, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (86, 3);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (86, 4);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (87, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (88, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (89, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (89, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (90, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (90, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (91, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (91, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (92, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (92, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (93, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (93, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (94, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (94, 2);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (95, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (96, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (97, 1);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (97, 3);
INSERT INTO brevet_rel_epreuve_note_valeur_textuelle (brevet_epreuve_id, valeur_textuelle_id) VALUES (97, 4);


--
-- Data for Name: brevet_serie; Type: TABLE DATA; Schema: entnotes; Owner: -
--

INSERT INTO brevet_serie (id, libelle_court, libelle_long, libelle_edition, annee_scolaire_id) VALUES (1, 'Collège (LV2)', 'COLLEGE, option de série LV2', 'Collège : option LV2', 1);
INSERT INTO brevet_serie (id, libelle_court, libelle_long, libelle_edition, annee_scolaire_id) VALUES (2, 'Collège (Dec)', 'COLLEGE, option de série Découverte Professionnelle', 'Collège : option Découverte Professionnelle', 1);
INSERT INTO brevet_serie (id, libelle_court, libelle_long, libelle_edition, annee_scolaire_id) VALUES (3, 'Professionnelle', 'PROFESSIONNELLE, sans Découverte Professionnelle', 'Professionnelle : sans option', 1);
INSERT INTO brevet_serie (id, libelle_court, libelle_long, libelle_edition, annee_scolaire_id) VALUES (4, 'Professionnelle (Dec)', 'PROFESSIONNELLE, avec Découverte Professionnelle', 'Professionnelle : avec Découverte Professionnelle', 1);
INSERT INTO brevet_serie (id, libelle_court, libelle_long, libelle_edition, annee_scolaire_id) VALUES (5, 'Professionnelle (Agricole)', 'PROFESSIONNELLE, option de série Agricole', 'Professionnelle : option Agricole', 1);
INSERT INTO brevet_serie (id, libelle_court, libelle_long, libelle_edition, annee_scolaire_id) VALUES (6, 'Technologique', 'TECHNOLOGIQUE, sans Découverte Professionnelle', 'Technologique : sans option', 1);
INSERT INTO brevet_serie (id, libelle_court, libelle_long, libelle_edition, annee_scolaire_id) VALUES (7, 'Technologique (Dec)', 'TECHNOLOGIQUE, avec Découverte Professionnelle', 'Technologique : avec Découverte Professionnelle', 1);
INSERT INTO brevet_serie (id, libelle_court, libelle_long, libelle_edition, annee_scolaire_id) VALUES (8, 'Technologique (Agricole)', 'TECHNOLOGIQUE, option de série Agricole', 'Technologique : option Agricole', 1);


--
-- Data for Name: dirty_moyenne; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: evaluation; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: info_calcul_moyennes_classe; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: modele_appreciation; Type: TABLE DATA; Schema: entnotes; Owner: -
--

INSERT INTO modele_appreciation (id, texte, type, version, ordre) VALUES (1, 'Félicitations', 'AVIS_CONSEIL_DE_CLASSE', 1, 1);
INSERT INTO modele_appreciation (id, texte, type, version, ordre) VALUES (2, 'Encouragements', 'AVIS_CONSEIL_DE_CLASSE', 1, 2);
INSERT INTO modele_appreciation (id, texte, type, version, ordre) VALUES (3, 'Doit progresser', 'AVIS_CONSEIL_DE_CLASSE', 1, 3);
INSERT INTO modele_appreciation (id, texte, type, version, ordre) VALUES (4, 'Manque de travail', 'AVIS_CONSEIL_DE_CLASSE', 1, 4);
INSERT INTO modele_appreciation (id, texte, type, version, ordre) VALUES (5, 'Avertissement', 'AVIS_CONSEIL_DE_CLASSE', 1, 5);
INSERT INTO modele_appreciation (id, texte, type, version, ordre) VALUES (6, 'Admis en classe supérieure', 'AVIS_ORIENTATION', 1, 1);
INSERT INTO modele_appreciation (id, texte, type, version, ordre) VALUES (7, 'Redoublement', 'AVIS_ORIENTATION', 1, 2);
INSERT INTO modele_appreciation (id, texte, type, version, ordre) VALUES (8, 'Réorientation', 'AVIS_ORIENTATION', 1, 3);


--
-- Data for Name: modele_appreciation_professeur; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: note; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: note_textuelle; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: rel_evaluation_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: resultat_classe_enseignement_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: resultat_classe_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: resultat_classe_service_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: resultat_classe_sous_service_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: resultat_eleve_enseignement_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: resultat_eleve_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: resultat_eleve_service_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- Data for Name: resultat_eleve_sous_service_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



SET search_path = entnotes_2011_2012, pg_catalog;

--
-- Data for Name: appreciation_classe_enseignement_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: appreciation_eleve_enseignement_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: appreciation_eleve_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: brevet_epreuve; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: brevet_fiche; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: brevet_note; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: brevet_rel_epreuve_matiere; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: brevet_rel_epreuve_note_valeur_textuelle; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: brevet_serie; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: evaluation; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: info_calcul_moyennes_classe; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: note; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: note_textuelle; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: rel_evaluation_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: resultat_classe_enseignement_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: resultat_classe_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: resultat_classe_service_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: resultat_classe_sous_service_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: resultat_eleve_enseignement_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: resultat_eleve_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: resultat_eleve_service_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- Data for Name: resultat_eleve_sous_service_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



SET search_path = enttemps, pg_catalog;

--
-- Data for Name: absence_journee; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: agenda; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: appel; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: appel_ligne; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: appel_plage_horaire; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: date_exclue; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: evenement; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: groupe_motif; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: incident; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: lieu_incident; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: motif; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: partenaire_a_prevenir; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: partenaire_a_prevenir_incident; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: plage_horaire; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: preference_etablissement_absences; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: preference_utilisateur_agenda; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: protagoniste_incident; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: punition; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: qualite_protagoniste; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: rel_agenda_evenement; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: repeter_jour_annee; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: repeter_jour_mois; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: repeter_jour_semaine; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: repeter_mois; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: repeter_semaine_annee; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: sanction; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: type_agenda; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: type_evenement; Type: TABLE DATA; Schema: enttemps; Owner: -
--

INSERT INTO type_evenement (id, type) VALUES (2, 'APPEL');
INSERT INTO type_evenement (id, type) VALUES (3, 'JOUR_FERIE');
INSERT INTO type_evenement (id, type) VALUES (4, 'FERMETURE_HEBDO');
INSERT INTO type_evenement (id, type) VALUES (5, 'COURS');
INSERT INTO type_evenement (id, type) VALUES (6, 'UTILISATEUR');
INSERT INTO type_evenement (id, type) VALUES (7, 'UDT');


--
-- Data for Name: type_incident; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: type_punition; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- Data for Name: type_sanction; Type: TABLE DATA; Schema: enttemps; Owner: -
--



SET search_path = enttemps_2011_2012, pg_catalog;

--
-- Data for Name: absence_journee; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: agenda; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: appel; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: appel_ligne; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: appel_plage_horaire; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: calendrier; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: evenement; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: groupe_motif; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: incident; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: lieu_incident; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: motif; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: partenaire_a_prevenir; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: partenaire_a_prevenir_incident; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: plage_horaire; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: preference_etablissement_absences; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: protagoniste_incident; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: punition; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: qualite_protagoniste; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: rel_agenda_evenement; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: sanction; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: type_incident; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: type_punition; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- Data for Name: type_sanction; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



SET search_path = forum, pg_catalog;

--
-- Data for Name: commentaire; Type: TABLE DATA; Schema: forum; Owner: -
--



--
-- Data for Name: commentaire_lu; Type: TABLE DATA; Schema: forum; Owner: -
--



--
-- Data for Name: discussion; Type: TABLE DATA; Schema: forum; Owner: -
--



--
-- Data for Name: etat_commentaire; Type: TABLE DATA; Schema: forum; Owner: -
--



--
-- Data for Name: etat_discussion; Type: TABLE DATA; Schema: forum; Owner: -
--



--
-- Data for Name: type_moderation; Type: TABLE DATA; Schema: forum; Owner: -
--



SET search_path = impression, pg_catalog;

--
-- Data for Name: publipostage_suivi; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- Data for Name: sms_fournisseur; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- Data for Name: sms_fournisseur_etablissement; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- Data for Name: template_champ_memo; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- Data for Name: template_document; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- Data for Name: template_document_sous_template_eliot; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- Data for Name: template_eliot; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- Data for Name: template_jasper; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- Data for Name: template_type_donnees; Type: TABLE DATA; Schema: impression; Owner: -
--

INSERT INTO template_type_donnees (id, libelle, code) VALUES (3, 'Données
      générales élèves', 'ELEVE_GENE');
INSERT INTO template_type_donnees (id, libelle, code) VALUES (4, 'Données
      de notes élèves', 'ELEVE_NOTES');
INSERT INTO template_type_donnees (id, libelle, code) VALUES (5, 'Données
      des absences élèves', 'ELEVE_ABSENCES');
INSERT INTO template_type_donnees (id, libelle, code) VALUES (6, 'Données
      des retards élèves', 'ELEVE_RETARDS');
INSERT INTO template_type_donnees (id, libelle, code) VALUES (7, 'Données
      de synthèse de notes de la classe', 'SYNTHESE_CLASSE_NOTES');
INSERT INTO template_type_donnees (id, libelle, code) VALUES (8, 'Données liées au
      brevet', 'ELEVE_BREVET');


--
-- Data for Name: template_type_fonctionnalite; Type: TABLE DATA; Schema: impression; Owner: -
--

INSERT INTO template_type_fonctionnalite (id, libelle, parent_id, code) VALUES (1, 'Général', NULL, 'GENERAL');
INSERT INTO template_type_fonctionnalite (id, libelle, parent_id, code) VALUES (2, 'Gestion des notes', NULL, 'NOTES');
INSERT INTO template_type_fonctionnalite (id, libelle, parent_id, code) VALUES (3, 'Gestion des absences', NULL, 'ABSENCES');
INSERT INTO template_type_fonctionnalite (id, libelle, parent_id, code) VALUES (4, 'Bulletin de notes', 2, 'BULLETIN_NOTES');
INSERT INTO template_type_fonctionnalite (id, libelle, parent_id, code) VALUES (5, 'Lettre', 1, 'LETTRE');
INSERT INTO template_type_fonctionnalite (id, libelle, parent_id, code) VALUES (6, 'Lettre d''absences', 3, 'LETTRE_ABSENCES');
INSERT INTO template_type_fonctionnalite (id, libelle, parent_id, code) VALUES (7, 'Lettre de retards', 3, 'LETTRE_RETARDS');
INSERT INTO template_type_fonctionnalite (id, libelle, parent_id, code) VALUES (8, 'Appréciations', 2, 'APPRECIATIONS');
INSERT INTO template_type_fonctionnalite (id, libelle, parent_id, code) VALUES (9, 'Relevé de notes', 2, 'RELEVE_NOTES');
INSERT INTO template_type_fonctionnalite (id, libelle, parent_id, code) VALUES (10, 'Synthèse de notes', NULL, 'SYNTHESE_NOTES');
INSERT INTO template_type_fonctionnalite (id, libelle, parent_id, code) VALUES (11, 'Brevet', NULL, 'BREVET');
INSERT INTO template_type_fonctionnalite (id, libelle, parent_id, code) VALUES (12, 'Sms', NULL, 'SMS');


SET search_path = public, pg_catalog;



--
-- Data for Name: eliot_version; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO eliot_version (id, date, code) VALUES (1, '2011-09-13 15:37:42.908592', '2.5.1-SNAPSHOT');
INSERT INTO eliot_version (id, date, code) VALUES (2, '2011-09-13 15:37:43.076475', '2.6.0-SNAPSHOT');
INSERT INTO eliot_version (id, date, code) VALUES (3, '2011-09-13 15:37:43.102585', '2.7.0-SNAPSHOT');
INSERT INTO eliot_version (id, date, code) VALUES (4, '2012-09-06 15:36:53.084247', '2.7.0-RC1');
INSERT INTO eliot_version (id, date, code) VALUES (5, '2012-09-06 15:36:53.089948', '2.7.1-SNAPSHOT');
INSERT INTO eliot_version (id, date, code) VALUES (6, '2012-09-06 15:36:53.21792', '2.7.1-A1');
INSERT INTO eliot_version (id, date, code) VALUES (7, '2012-09-06 15:36:53.222371', '2.7.1-RC1');
INSERT INTO eliot_version (id, date, code) VALUES (8, '2012-09-06 15:36:53.226384', '2.7.2-SNAPSHOT');
INSERT INTO eliot_version (id, date, code) VALUES (9, '2012-09-06 15:36:53.230458', '2.7.2');
INSERT INTO eliot_version (id, date, code) VALUES (10, '2012-09-06 15:36:53.235043', '2.8.0-A1');
INSERT INTO eliot_version (id, date, code) VALUES (11, '2012-09-06 15:36:53.240236', '2.8.0-RC1');
INSERT INTO eliot_version (id, date, code) VALUES (12, '2012-09-06 15:36:53.333649', '2.8.1-RC1');
INSERT INTO eliot_version (id, date, code) VALUES (13, '2012-09-06 15:36:53.338052', '2.8.2-A1');
INSERT INTO eliot_version (id, date, code) VALUES (14, '2012-09-06 15:36:53.342582', '2.8.2-RC1');


SET search_path = securite, pg_catalog;

--
-- Data for Name: autorisation; Type: TABLE DATA; Schema: securite; Owner: -
--



--
-- Data for Name: autorite; Type: TABLE DATA; Schema: securite; Owner: -
--



--
-- Data for Name: item; Type: TABLE DATA; Schema: securite; Owner: -
--



--
-- Data for Name: perimetre; Type: TABLE DATA; Schema: securite; Owner: -
--



--
-- Data for Name: perimetre_securite; Type: TABLE DATA; Schema: securite; Owner: -
--



--
-- Data for Name: permission; Type: TABLE DATA; Schema: securite; Owner: -
--

INSERT INTO permission (id, version, nom, valeur) VALUES (1, 1, 'PEUT_CONSULTER_LE_CONTENU', 1);
INSERT INTO permission (id, version, nom, valeur) VALUES (2, 1, 'PEUT_MODIFIER_LE_CONTENU', 2);
INSERT INTO permission (id, version, nom, valeur) VALUES (3, 1, 'PEUT_CONSULTER_LES_PERMISSIONS', 4);
INSERT INTO permission (id, version, nom, valeur) VALUES (4, 1, 'PEUT_MODIFIER_LES_PERMISSIONS', 8);
INSERT INTO permission (id, version, nom, valeur) VALUES (5, 1, 'PEUT_SUPPRIMER', 16);


SET search_path = td, pg_catalog;

--
-- Data for Name: copie; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- Data for Name: modalite_activite; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- Data for Name: question; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- Data for Name: question_attachement; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- Data for Name: question_export; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- Data for Name: question_type; Type: TABLE DATA; Schema: td; Owner: -
--

INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (1, 'Choix multiple', 'Multiple Choice', 'MultipleChoice', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (2, 'Ouverte', 'Open', 'Open', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (3, 'Décimale', 'Decimal', 'Decimal', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (4, 'Entière', 'Integer', 'Integer', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (6, 'Texte à trous', 'Fill Gap', 'FillGap', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (7, 'Evaluation booléenne', 'Boolean Match', 'BooleanMatch', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (8, 'Choix exclusif', 'Exclusive Choice', 'ExclusiveChoice', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (9, 'Graphique à compléter', 'Fill Graphics', 'FillGraphics', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (11, 'Ordre à rétablir', 'Order', 'Order', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (12, 'Association', 'Associate', 'Associate', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (13, 'Curseur à déplacer', 'Slider', 'Slider', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (15, 'Correspondance', 'Match', 'Match', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (51, 'Document', 'Document', 'Document', false);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (52, 'Énoncé', 'Statement', 'Statement', false);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (5, 'Exercice', 'Composite', 'Composite', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (10, 'Fichier à déposer', 'File Upload', 'FileUpload', true);
INSERT INTO question_type (id, nom, nom_anglais, code, interaction) VALUES (14, 'Association graphique', 'Graphic Match', 'GraphicMatch', true);


--
-- Data for Name: reponse; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- Data for Name: reponse_attachement; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- Data for Name: sujet; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- Data for Name: sujet_sequence_questions; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- Data for Name: sujet_type; Type: TABLE DATA; Schema: td; Owner: -
--

INSERT INTO sujet_type (id, nom, nom_anglais) VALUES (1, 'Sujet', 'Exercise set');
INSERT INTO sujet_type (id, nom, nom_anglais) VALUES (2, 'Exercice', 'Exercise');


SET search_path = tice, pg_catalog;

--
-- Data for Name: attachement; Type: TABLE DATA; Schema: tice; Owner: -
--



--
-- Data for Name: compte_utilisateur; Type: TABLE DATA; Schema: tice; Owner: -
--



--
-- Data for Name: copyrights_type; Type: TABLE DATA; Schema: tice; Owner: -
--

INSERT INTO copyrights_type (id, code, presentation, lien, logo, option_cc_paternite, option_cc_pas_utilisation_commerciale, option_cc_pas_modification, option_cc_partage_viral, option_tous_droits_reserves) VALUES (1, 'Tous droits réservés', 'Cette oeuvre est mise à disposition selon les termes du droit d''auteur émanant du code de la propriété intellectuelle.', 'http://www.legifrance.gouv.fr/affichCode.do?cidTexte=LEGITEXT000006069414', NULL, true, true, true, NULL, true);
INSERT INTO copyrights_type (id, code, presentation, lien, logo, option_cc_paternite, option_cc_pas_utilisation_commerciale, option_cc_pas_modification, option_cc_partage_viral, option_tous_droits_reserves) VALUES (2, '(CC) BY-NC-SA', 'Cette oeuvre est mise à disposition selon les termes de la Licence Creative Commons Paternité - Pas d''Utilisation Commerciale - Partage à l''Identique 2.0 France', 'http://creativecommons.org/licenses/by-nc-sa/2.0/fr/', 'CC-BY-NC-SA.png', true, true, false, true, false);
INSERT INTO copyrights_type (id, code, presentation, lien, logo, option_cc_paternite, option_cc_pas_utilisation_commerciale, option_cc_pas_modification, option_cc_partage_viral, option_tous_droits_reserves) VALUES (3, '(CC) BY-NC', 'Cette oeuvre est mise à disposition selon les termes de la Licence Creative Commons Paternité - Pas d''Utilisation Commerciale - France', 'http://creativecommons.org/licenses/by-nc/2.0/fr/', 'CC-BY-NC.png', true, true, false, false, false);


--
-- Data for Name: export_format; Type: TABLE DATA; Schema: tice; Owner: -
--

INSERT INTO export_format (id, nom, code) VALUES (1, 'IMS Question & Test Interoperability', 'QTI');


--
-- Data for Name: publication; Type: TABLE DATA; Schema: tice; Owner: -
--



SET search_path = udt, pg_catalog;

--
-- Data for Name: enseignement; Type: TABLE DATA; Schema: udt; Owner: -
--



--
-- Data for Name: evenement; Type: TABLE DATA; Schema: udt; Owner: -
--



--
-- Data for Name: import; Type: TABLE DATA; Schema: udt; Owner: -
--



SET search_path = aaf, pg_catalog;

--
-- Name: pk_import; Type: CONSTRAINT; Schema: aaf; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import
    ADD CONSTRAINT pk_import PRIMARY KEY (id);


--
-- Name: pk_import_verrou; Type: CONSTRAINT; Schema: aaf; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_verrou
    ADD CONSTRAINT pk_import_verrou PRIMARY KEY (id);


SET search_path = bascule_annee, pg_catalog;

--
-- Name: etape_index_key; Type: CONSTRAINT; Schema: bascule_annee; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etape
    ADD CONSTRAINT etape_index_key UNIQUE (index);


--
-- Name: etape_module_code_etape_code_key; Type: CONSTRAINT; Schema: bascule_annee; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etape
    ADD CONSTRAINT etape_module_code_etape_code_key UNIQUE (module_code, etape_code);


--
-- Name: pk_etape; Type: CONSTRAINT; Schema: bascule_annee; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etape
    ADD CONSTRAINT pk_etape PRIMARY KEY (id);


--
-- Name: pk_verrou; Type: CONSTRAINT; Schema: bascule_annee; Owner: -; Tablespace: 
--

ALTER TABLE ONLY verrou
    ADD CONSTRAINT pk_verrou PRIMARY KEY (id);


--
-- Name: uk_verrou_nom; Type: CONSTRAINT; Schema: bascule_annee; Owner: -; Tablespace: 
--

ALTER TABLE ONLY verrou
    ADD CONSTRAINT uk_verrou_nom UNIQUE (nom);


SET search_path = ent, pg_catalog;

--
-- Name: pk_annee_scolaire; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY annee_scolaire
    ADD CONSTRAINT pk_annee_scolaire PRIMARY KEY (id);


--
-- Name: pk_appartenance_groupe_groupe; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appartenance_groupe_groupe
    ADD CONSTRAINT pk_appartenance_groupe_groupe PRIMARY KEY (id);


--
-- Name: pk_appartenance_personne_groupe; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appartenance_personne_groupe
    ADD CONSTRAINT pk_appartenance_personne_groupe PRIMARY KEY (id);


--
-- Name: pk_calendrier; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT pk_calendrier PRIMARY KEY (id);


--
-- Name: pk_civilite; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY civilite
    ADD CONSTRAINT pk_civilite PRIMARY KEY (id);


--
-- Name: pk_enseignement; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT pk_enseignement PRIMARY KEY (id);


--
-- Name: pk_ent_service; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY service
    ADD CONSTRAINT pk_ent_service PRIMARY KEY (id);


--
-- Name: pk_etablissement; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT pk_etablissement PRIMARY KEY (id);


--
-- Name: pk_fiche_eleve_commentaire; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fiche_eleve_commentaire
    ADD CONSTRAINT pk_fiche_eleve_commentaire PRIMARY KEY (id);


--
-- Name: pk_filiere; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY filiere
    ADD CONSTRAINT pk_filiere PRIMARY KEY (id);


--
-- Name: pk_fonction; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fonction
    ADD CONSTRAINT pk_fonction PRIMARY KEY (id);


--
-- Name: pk_groupe_personnes; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT pk_groupe_personnes PRIMARY KEY (id);


--
-- Name: pk_matiere; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT pk_matiere PRIMARY KEY (id);


--
-- Name: pk_mef; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mef
    ADD CONSTRAINT pk_mef PRIMARY KEY (id);


--
-- Name: pk_modalite_cours; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_cours
    ADD CONSTRAINT pk_modalite_cours PRIMARY KEY (id);


--
-- Name: pk_modalite_matiere; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT pk_modalite_matiere PRIMARY KEY (id);


--
-- Name: pk_niveau; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY niveau
    ADD CONSTRAINT pk_niveau PRIMARY KEY (id);


--
-- Name: pk_periode; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT pk_periode PRIMARY KEY (id);


--
-- Name: pk_personne; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT pk_personne PRIMARY KEY (id);


--
-- Name: pk_personne_propriete_scolarite; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT pk_personne_propriete_scolarite PRIMARY KEY (id);


--
-- Name: pk_porteur_ent; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY porteur_ent
    ADD CONSTRAINT pk_porteur_ent PRIMARY KEY (id);


--
-- Name: pk_preference_etablissement; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT pk_preference_etablissement PRIMARY KEY (id);


--
-- Name: pk_propriete_scolarite; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT pk_propriete_scolarite PRIMARY KEY (id);


--
-- Name: pk_regime; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY regime
    ADD CONSTRAINT pk_regime PRIMARY KEY (id);


--
-- Name: pk_rel_classe_filiere; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT pk_rel_classe_filiere PRIMARY KEY (classe_id, filiere_id);


--
-- Name: pk_rel_classe_groupe; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT pk_rel_classe_groupe PRIMARY KEY (classe_id, groupe_id);


--
-- Name: pk_rel_periode_service; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT pk_rel_periode_service PRIMARY KEY (id);


--
-- Name: pk_responsable_eleve; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT pk_responsable_eleve PRIMARY KEY (id);


--
-- Name: pk_responsable_propriete_scolarite; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT pk_responsable_propriete_scolarite PRIMARY KEY (id);


--
-- Name: pk_signature; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY signature
    ADD CONSTRAINT pk_signature PRIMARY KEY (id);


--
-- Name: pk_source_import; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY source_import
    ADD CONSTRAINT pk_source_import PRIMARY KEY (id);


--
-- Name: pk_sous_service; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT pk_sous_service PRIMARY KEY (id);


--
-- Name: pk_structure_enseignement; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT pk_structure_enseignement PRIMARY KEY (id);


--
-- Name: pk_type_periode; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_periode
    ADD CONSTRAINT pk_type_periode PRIMARY KEY (id);


--
-- Name: uk_annee_scolaire_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY annee_scolaire
    ADD CONSTRAINT uk_annee_scolaire_code UNIQUE (code);


--
-- Name: uk_appartenance_groupe_groupe_groupe_personnes_parent_id_groupe; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appartenance_groupe_groupe
    ADD CONSTRAINT uk_appartenance_groupe_groupe_groupe_personnes_parent_id_groupe UNIQUE (groupe_personnes_parent_id, groupe_personnes_enfant_id);


--
-- Name: uk_appartenance_personne_groupe_personne_id_groupe_personnes_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appartenance_personne_groupe
    ADD CONSTRAINT uk_appartenance_personne_groupe_personne_id_groupe_personnes_id UNIQUE (personne_id, groupe_personnes_id);


--
-- Name: uk_calendrier_etablissement_id_annee_scolaire_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT uk_calendrier_etablissement_id_annee_scolaire_id UNIQUE (etablissement_id, annee_scolaire_id);


--
-- Name: uk_civilite_libelle; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY civilite
    ADD CONSTRAINT uk_civilite_libelle UNIQUE (libelle);


--
-- Name: uk_enseignement_enseignant_id_service_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT uk_enseignement_enseignant_id_service_id UNIQUE (enseignant_id, service_id);


--
-- Name: uk_etablissement_id_externe; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT uk_etablissement_id_externe UNIQUE (id_externe);


--
-- Name: uk_etablissement_uai; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT uk_etablissement_uai UNIQUE (uai);


--
-- Name: uk_fiche_eleve_commentaire_personne_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fiche_eleve_commentaire
    ADD CONSTRAINT uk_fiche_eleve_commentaire_personne_id UNIQUE (personne_id);


--
-- Name: uk_fonction_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fonction
    ADD CONSTRAINT uk_fonction_code UNIQUE (code);


--
-- Name: uk_groupe_personnes_autorite_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT uk_groupe_personnes_autorite_id UNIQUE (autorite_id);


--
-- Name: uk_groupe_personnes_item_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT uk_groupe_personnes_item_id UNIQUE (item_id);


--
-- Name: uk_matiere_etablissement_id_code_gestion_annee_scolaire_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT uk_matiere_etablissement_id_code_gestion_annee_scolaire_id UNIQUE (etablissement_id, code_gestion, annee_scolaire_id);


--
-- Name: uk_matiere_etablissement_id_code_sts_annee_scolaire_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT uk_matiere_etablissement_id_code_sts_annee_scolaire_id UNIQUE (etablissement_id, code_sts, annee_scolaire_id);


--
-- Name: uk_mef_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mef
    ADD CONSTRAINT uk_mef_code UNIQUE (code);


--
-- Name: uk_modalite_cours_code_sts; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_cours
    ADD CONSTRAINT uk_modalite_cours_code_sts UNIQUE (code_sts);


--
-- Name: uk_modalite_matiere_etablissement_id_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT uk_modalite_matiere_etablissement_id_code UNIQUE (etablissement_id, code);


--
-- Name: uk_niveau_libelle_court; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY niveau
    ADD CONSTRAINT uk_niveau_libelle_court UNIQUE (libelle_court);


--
-- Name: uk_periode_structure_enseignement_id_type_periode_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT uk_periode_structure_enseignement_id_type_periode_id UNIQUE (structure_enseignement_id, type_periode_id);


--
-- Name: uk_personne_autorite_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT uk_personne_autorite_id UNIQUE (autorite_id);


--
-- Name: uk_porteur_ent_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY porteur_ent
    ADD CONSTRAINT uk_porteur_ent_code UNIQUE (code);


--
-- Name: uk_porteur_perimetre_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY porteur_ent
    ADD CONSTRAINT uk_porteur_perimetre_id UNIQUE (perimetre_id);


--
-- Name: uk_preference_etablissement_etablissement_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT uk_preference_etablissement_etablissement_id UNIQUE (etablissement_id);


--
-- Name: uk_regime_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY regime
    ADD CONSTRAINT uk_regime_code UNIQUE (code);


--
-- Name: uk_rel_periode_service_periode_id_service_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT uk_rel_periode_service_periode_id_service_id UNIQUE (periode_id, service_id);


--
-- Name: uk_responsable_eleve_personne_id_eleve_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT uk_responsable_eleve_personne_id_eleve_id UNIQUE (personne_id, eleve_id);


--
-- Name: uk_source_import_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY source_import
    ADD CONSTRAINT uk_source_import_code UNIQUE (code);


--
-- Name: uk_sous_service_service_id_type_periode_id_modalite_matiere_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT uk_sous_service_service_id_type_periode_id_modalite_matiere_id UNIQUE (service_id, type_periode_id, modalite_matiere_id);


--
-- Name: uk_structure_enseignement_etablissement_id_annee_scolaire_id_ty; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT uk_structure_enseignement_etablissement_id_annee_scolaire_id_ty UNIQUE (etablissement_id, annee_scolaire_id, type, code);


--
-- Name: uk_type_periode_etablissement_id_libelle; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_periode
    ADD CONSTRAINT uk_type_periode_etablissement_id_libelle UNIQUE (etablissement_id, libelle);


--
-- Name: uk_type_periode_intervalle; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_periode
    ADD CONSTRAINT uk_type_periode_intervalle UNIQUE (intervalle);


SET search_path = ent_2011_2012, pg_catalog;

--
-- Name: pk_annee_scolaire; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT pk_annee_scolaire PRIMARY KEY (id);


--
-- Name: pk_enseignement; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT pk_enseignement PRIMARY KEY (id);


--
-- Name: pk_ent_service; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY service
    ADD CONSTRAINT pk_ent_service PRIMARY KEY (id);


--
-- Name: pk_matiere; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT pk_matiere PRIMARY KEY (id);


--
-- Name: pk_modalite_matiere; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT pk_modalite_matiere PRIMARY KEY (id);


--
-- Name: pk_periode; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT pk_periode PRIMARY KEY (id);


--
-- Name: pk_personne_propriete_scolarite; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT pk_personne_propriete_scolarite PRIMARY KEY (id);


--
-- Name: pk_preference_etablissement; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT pk_preference_etablissement PRIMARY KEY (id);


--
-- Name: pk_propriete_scolarite; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT pk_propriete_scolarite PRIMARY KEY (id);


--
-- Name: pk_rel_classe_filiere; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT pk_rel_classe_filiere PRIMARY KEY (classe_id, filiere_id);


--
-- Name: pk_rel_classe_groupe; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT pk_rel_classe_groupe PRIMARY KEY (classe_id, groupe_id);


--
-- Name: pk_rel_periode_service; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT pk_rel_periode_service PRIMARY KEY (id);


--
-- Name: pk_responsable_propriete_scolarite; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT pk_responsable_propriete_scolarite PRIMARY KEY (id);


--
-- Name: pk_sous_service; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT pk_sous_service PRIMARY KEY (id);


--
-- Name: pk_structure_enseignement; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT pk_structure_enseignement PRIMARY KEY (id);


--
-- Name: uk_calendrier_etablissement_id_annee_scolaire_id; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT uk_calendrier_etablissement_id_annee_scolaire_id UNIQUE (etablissement_id, annee_scolaire_id);


--
-- Name: uk_enseignement_enseignant_id_service_id; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT uk_enseignement_enseignant_id_service_id UNIQUE (enseignant_id, service_id);


--
-- Name: uk_matiere_etablissement_id_code_gestion; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT uk_matiere_etablissement_id_code_gestion UNIQUE (etablissement_id, code_gestion);


--
-- Name: uk_matiere_etablissement_id_code_sts; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT uk_matiere_etablissement_id_code_sts UNIQUE (etablissement_id, code_sts);


--
-- Name: uk_modalite_matiere_etablissement_id_code; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT uk_modalite_matiere_etablissement_id_code UNIQUE (etablissement_id, code);


--
-- Name: uk_periode_structure_enseignement_id_type_periode_id; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT uk_periode_structure_enseignement_id_type_periode_id UNIQUE (structure_enseignement_id, type_periode_id);


--
-- Name: uk_preference_etablissement_etablissement_id; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT uk_preference_etablissement_etablissement_id UNIQUE (etablissement_id);


--
-- Name: uk_rel_periode_service_periode_id_service_id; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT uk_rel_periode_service_periode_id_service_id UNIQUE (periode_id, service_id);


--
-- Name: uk_sous_service_service_id_type_periode_id_modalite_matiere_id; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT uk_sous_service_service_id_type_periode_id_modalite_matiere_id UNIQUE (service_id, type_periode_id, modalite_matiere_id);


--
-- Name: uk_structure_enseignement_etablissement_id_annee_scolaire_id_ty; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT uk_structure_enseignement_etablissement_id_annee_scolaire_id_ty UNIQUE (etablissement_id, annee_scolaire_id, type, code);


SET search_path = entcdt, pg_catalog;

--
-- Name: pk_activite; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT pk_activite PRIMARY KEY (id);


--
-- Name: pk_cahier_de_textes; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT pk_cahier_de_textes PRIMARY KEY (id);


--
-- Name: pk_chapitre; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY chapitre
    ADD CONSTRAINT pk_chapitre PRIMARY KEY (id);


--
-- Name: pk_contexte_activite; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contexte_activite
    ADD CONSTRAINT pk_contexte_activite PRIMARY KEY (id);


--
-- Name: pk_date_activite; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY date_activite
    ADD CONSTRAINT pk_date_activite PRIMARY KEY (id);


--
-- Name: pk_dossier; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dossier
    ADD CONSTRAINT pk_dossier PRIMARY KEY (id);


--
-- Name: pk_fichier; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fichier
    ADD CONSTRAINT pk_fichier PRIMARY KEY (id);


--
-- Name: pk_rel_activite_acteur; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_activite_acteur
    ADD CONSTRAINT pk_rel_activite_acteur PRIMARY KEY (id);


--
-- Name: pk_rel_cahier_acteur; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_cahier_acteur
    ADD CONSTRAINT pk_rel_cahier_acteur PRIMARY KEY (id);


--
-- Name: pk_rel_cahier_groupe; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_cahier_groupe
    ADD CONSTRAINT pk_rel_cahier_groupe PRIMARY KEY (id);


--
-- Name: pk_rel_dossier_autorisation_cahier; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_dossier_autorisation_cahier
    ADD CONSTRAINT pk_rel_dossier_autorisation_cahier PRIMARY KEY (id);


--
-- Name: pk_ressource; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ressource
    ADD CONSTRAINT pk_ressource PRIMARY KEY (id);


--
-- Name: pk_textes_preferences_utilisateur; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY textes_preferences_utilisateur
    ADD CONSTRAINT pk_textes_preferences_utilisateur PRIMARY KEY (id);


--
-- Name: pk_type_activite; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_activite
    ADD CONSTRAINT pk_type_activite PRIMARY KEY (id);


--
-- Name: pk_visa; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY visa
    ADD CONSTRAINT pk_visa PRIMARY KEY (id);


--
-- Name: uk_contexte_activite_code; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contexte_activite
    ADD CONSTRAINT uk_contexte_activite_code UNIQUE (code);


--
-- Name: uk_date_activite_evenement_id_activite_id; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY date_activite
    ADD CONSTRAINT uk_date_activite_evenement_id_activite_id UNIQUE (evenement_id, activite_id);


--
-- Name: uk_rel_activite_acteur_activite_id_acteur_id; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_activite_acteur
    ADD CONSTRAINT uk_rel_activite_acteur_activite_id_acteur_id UNIQUE (activite_id, acteur_id);


--
-- Name: uk_rel_cahier_acteur_acteur_id_cahier_de_textes_id; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_cahier_acteur
    ADD CONSTRAINT uk_rel_cahier_acteur_acteur_id_cahier_de_textes_id UNIQUE (acteur_id, cahier_de_textes_id);


--
-- Name: uk_rel_cahier_groupe_cahier_de_textes_id_groupe_id; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_cahier_groupe
    ADD CONSTRAINT uk_rel_cahier_groupe_cahier_de_textes_id_groupe_id UNIQUE (cahier_de_textes_id, groupe_id);


--
-- Name: uk_rel_dossier_autorisation_cahier_dossier_id_autorisation_id; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_dossier_autorisation_cahier
    ADD CONSTRAINT uk_rel_dossier_autorisation_cahier_dossier_id_autorisation_id UNIQUE (dossier_id, autorisation_id);


--
-- Name: uk_textes_preferences_utilisateur_utilisateur_id; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY textes_preferences_utilisateur
    ADD CONSTRAINT uk_textes_preferences_utilisateur_utilisateur_id UNIQUE (utilisateur_id);


--
-- Name: uk_type_activite_code; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_activite
    ADD CONSTRAINT uk_type_activite_code UNIQUE (code);


SET search_path = entdemon, pg_catalog;

--
-- Name: pk_demande_traitement; Type: CONSTRAINT; Schema: entdemon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY demande_traitement
    ADD CONSTRAINT pk_demande_traitement PRIMARY KEY (id);


SET search_path = entnotes, pg_catalog;

--
-- Name: brevet_epreuve_serie_id_code_key; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT brevet_epreuve_serie_id_code_key UNIQUE (serie_id, code);


--
-- Name: brevet_rel_epreuve_matiere_epreuve_id_matiere_id_key; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT brevet_rel_epreuve_matiere_epreuve_id_matiere_id_key UNIQUE (epreuve_id, matiere_id);


--
-- Name: brevet_rel_epreuve_note_valeu_brevet_epreuve_id_valeur_text_key; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT brevet_rel_epreuve_note_valeu_brevet_epreuve_id_valeur_text_key UNIQUE (brevet_epreuve_id, valeur_textuelle_id);


--
-- Name: pk_appreciation_classe_enseignement_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT pk_appreciation_classe_enseignement_periode PRIMARY KEY (id);


--
-- Name: pk_appreciation_eleve_enseignement_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT pk_appreciation_eleve_enseignement_periode PRIMARY KEY (id);


--
-- Name: pk_appreciation_eleve_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT pk_appreciation_eleve_periode PRIMARY KEY (id);


--
-- Name: pk_avis_conseil_de_classe; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY avis_conseil_de_classe
    ADD CONSTRAINT pk_avis_conseil_de_classe PRIMARY KEY (id);


--
-- Name: pk_avis_orientation; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY avis_orientation
    ADD CONSTRAINT pk_avis_orientation PRIMARY KEY (id);


--
-- Name: pk_brevet_epreuve; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT pk_brevet_epreuve PRIMARY KEY (id);


--
-- Name: pk_brevet_fiche; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT pk_brevet_fiche PRIMARY KEY (id);


--
-- Name: pk_brevet_note; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT pk_brevet_note PRIMARY KEY (id);


--
-- Name: pk_brevet_note_valeur_textuelle; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_note_valeur_textuelle
    ADD CONSTRAINT pk_brevet_note_valeur_textuelle PRIMARY KEY (id);


--
-- Name: pk_brevet_rel_epreuve_matiere; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT pk_brevet_rel_epreuve_matiere PRIMARY KEY (id);


--
-- Name: pk_brevet_rel_epreuve_note_valeur_textuelle; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT pk_brevet_rel_epreuve_note_valeur_textuelle PRIMARY KEY (brevet_epreuve_id, valeur_textuelle_id);


--
-- Name: pk_brevet_serie; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_serie
    ADD CONSTRAINT pk_brevet_serie PRIMARY KEY (id);


--
-- Name: pk_dirty_moyenne; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT pk_dirty_moyenne PRIMARY KEY (id);


--
-- Name: pk_evaluation; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT pk_evaluation PRIMARY KEY (id);


--
-- Name: pk_info_calcul_moyennes_classe; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT pk_info_calcul_moyennes_classe PRIMARY KEY (id);


--
-- Name: pk_info_supplementaire; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT pk_info_supplementaire PRIMARY KEY (id);


--
-- Name: pk_modele_appreciation_etablissement; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modele_appreciation
    ADD CONSTRAINT pk_modele_appreciation_etablissement PRIMARY KEY (id);


--
-- Name: pk_modele_appreciation_professeur; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modele_appreciation_professeur
    ADD CONSTRAINT pk_modele_appreciation_professeur PRIMARY KEY (id);


--
-- Name: pk_note; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note
    ADD CONSTRAINT pk_note PRIMARY KEY (id);


--
-- Name: pk_note_textuelle; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note_textuelle
    ADD CONSTRAINT pk_note_textuelle PRIMARY KEY (id);


--
-- Name: pk_rel_evaluation_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT pk_rel_evaluation_periode PRIMARY KEY (evaluation_id, periode_id);


--
-- Name: pk_resultat_classe_enseignement_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT pk_resultat_classe_enseignement_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_classe_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT pk_resultat_classe_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_classe_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT pk_resultat_classe_service_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_classe_sous_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT pk_resultat_classe_sous_service_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_eleve_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT pk_resultat_eleve_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_eleve_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT pk_resultat_eleve_service_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_eleve_sous_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT pk_resultat_eleve_sous_service_periode PRIMARY KEY (id);


--
-- Name: uk_appreciation_classe_enseignement_periode_classe_id_periode_i; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT uk_appreciation_classe_enseignement_periode_classe_id_periode_i UNIQUE (classe_id, periode_id, enseignement_id);


--
-- Name: uk_appreciation_eleve_enseignement_periode_eleve_id_periode_id_; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT uk_appreciation_eleve_enseignement_periode_eleve_id_periode_id_ UNIQUE (eleve_id, periode_id, enseignement_id);


--
-- Name: uk_appreciation_eleve_periode_eleve_id_periode_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT uk_appreciation_eleve_periode_eleve_id_periode_id UNIQUE (eleve_id, periode_id);


--
-- Name: uk_avis_conseil_de_classe_etablissement_id_texte; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY avis_conseil_de_classe
    ADD CONSTRAINT uk_avis_conseil_de_classe_etablissement_id_texte UNIQUE (etablissement_id, texte);


--
-- Name: uk_avis_orientation_etablissement_id_texte; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY avis_orientation
    ADD CONSTRAINT uk_avis_orientation_etablissement_id_texte UNIQUE (etablissement_id, texte);


--
-- Name: uk_brevet_fiche_eleve_id_annee_scolaire_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT uk_brevet_fiche_eleve_id_annee_scolaire_id UNIQUE (eleve_id, annee_scolaire_id);


--
-- Name: uk_brevet_note_fiche_id_epreuve_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT uk_brevet_note_fiche_id_epreuve_id UNIQUE (fiche_id, epreuve_id);


--
-- Name: uk_info_calcul_moyennes_classe_classe_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT uk_info_calcul_moyennes_classe_classe_id UNIQUE (classe_id);


--
-- Name: uk_modele_appreciation_professeur_autorite_id_texte; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modele_appreciation_professeur
    ADD CONSTRAINT uk_modele_appreciation_professeur_autorite_id_texte UNIQUE (autorite_id, texte);


--
-- Name: uk_modele_appreciation_texte_type; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modele_appreciation
    ADD CONSTRAINT uk_modele_appreciation_texte_type UNIQUE (texte, type);


--
-- Name: uk_note_evaluation_id_eleve_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note
    ADD CONSTRAINT uk_note_evaluation_id_eleve_id UNIQUE (evaluation_id, eleve_id);


--
-- Name: uk_rel_evaluation_periode_evaluation_id_periode_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT uk_rel_evaluation_periode_evaluation_id_periode_id UNIQUE (evaluation_id, periode_id);


--
-- Name: uk_resultat_classe_enseignement_periode_enseignement_id_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT uk_resultat_classe_enseignement_periode_enseignement_id_periode UNIQUE (enseignement_id, periode_id, structure_enseignement_id);


--
-- Name: uk_resultat_classe_periode_periode_id_structure_enseignement_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT uk_resultat_classe_periode_periode_id_structure_enseignement_id UNIQUE (periode_id, structure_enseignement_id);


--
-- Name: uk_resultat_classe_service_periode_service_id_periode_id_struct; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT uk_resultat_classe_service_periode_service_id_periode_id_struct UNIQUE (service_id, periode_id, structure_enseignement_id);


--
-- Name: uk_resultat_classe_sous_service_periode_resultat_classe_service; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT uk_resultat_classe_sous_service_periode_resultat_classe_service UNIQUE (resultat_classe_service_periode_id, sous_service_id);


--
-- Name: uk_resultat_eleve_enseignement_periode_enseignement_id_eleve_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT uk_resultat_eleve_enseignement_periode_enseignement_id_eleve_id UNIQUE (enseignement_id, eleve_id, periode_id);


--
-- Name: uk_resultat_eleve_periode_periode_id_autorite_eleve_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT uk_resultat_eleve_periode_periode_id_autorite_eleve_id UNIQUE (periode_id, autorite_eleve_id);


--
-- Name: uk_resultat_eleve_service_periode_service_id_periode_id_autorit; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT uk_resultat_eleve_service_periode_service_id_periode_id_autorit UNIQUE (service_id, periode_id, autorite_eleve_id);


--
-- Name: uk_resultat_eleve_sous_service_periode_resultat_eleve_service_p; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT uk_resultat_eleve_sous_service_periode_resultat_eleve_service_p UNIQUE (resultat_eleve_service_periode_id, sous_service_id);


SET search_path = entnotes_2011_2012, pg_catalog;

--
-- Name: brevet_epreuve_serie_id_code_key; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT brevet_epreuve_serie_id_code_key UNIQUE (serie_id, code);


--
-- Name: brevet_rel_epreuve_matiere_epreuve_id_matiere_id_key; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT brevet_rel_epreuve_matiere_epreuve_id_matiere_id_key UNIQUE (epreuve_id, matiere_id);


--
-- Name: pk_appreciation_classe_enseignement_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT pk_appreciation_classe_enseignement_periode PRIMARY KEY (id);


--
-- Name: pk_appreciation_eleve_enseignement_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT pk_appreciation_eleve_enseignement_periode PRIMARY KEY (id);


--
-- Name: pk_appreciation_eleve_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT pk_appreciation_eleve_periode PRIMARY KEY (id);


--
-- Name: pk_brevet_epreuve; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT pk_brevet_epreuve PRIMARY KEY (id);


--
-- Name: pk_brevet_fiche; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT pk_brevet_fiche PRIMARY KEY (id);


--
-- Name: pk_brevet_note; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT pk_brevet_note PRIMARY KEY (id);


--
-- Name: pk_brevet_rel_epreuve_matiere; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT pk_brevet_rel_epreuve_matiere PRIMARY KEY (id);


--
-- Name: pk_brevet_rel_epreuve_note_valeur_textuelle; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT pk_brevet_rel_epreuve_note_valeur_textuelle PRIMARY KEY (brevet_epreuve_id, valeur_textuelle_id);


--
-- Name: pk_brevet_serie; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_serie
    ADD CONSTRAINT pk_brevet_serie PRIMARY KEY (id);


--
-- Name: pk_evaluation; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT pk_evaluation PRIMARY KEY (id);


--
-- Name: pk_info_calcul_moyennes_classe; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT pk_info_calcul_moyennes_classe PRIMARY KEY (id);


--
-- Name: pk_info_supplementaire; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT pk_info_supplementaire PRIMARY KEY (id);


--
-- Name: pk_note; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note
    ADD CONSTRAINT pk_note PRIMARY KEY (id);


--
-- Name: pk_note_textuelle; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note_textuelle
    ADD CONSTRAINT pk_note_textuelle PRIMARY KEY (id);


--
-- Name: pk_rel_evaluation_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT pk_rel_evaluation_periode PRIMARY KEY (evaluation_id, periode_id);


--
-- Name: pk_resultat_classe_enseignement_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT pk_resultat_classe_enseignement_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_classe_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT pk_resultat_classe_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_classe_service_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT pk_resultat_classe_service_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_classe_sous_service_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT pk_resultat_classe_sous_service_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_eleve_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT pk_resultat_eleve_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_eleve_service_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT pk_resultat_eleve_service_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_eleve_sous_service_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT pk_resultat_eleve_sous_service_periode PRIMARY KEY (id);


--
-- Name: uk_appreciation_classe_enseignement_periode_classe_id_periode_i; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT uk_appreciation_classe_enseignement_periode_classe_id_periode_i UNIQUE (classe_id, periode_id, enseignement_id);


--
-- Name: uk_appreciation_eleve_enseignement_periode_eleve_id_periode_id_; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT uk_appreciation_eleve_enseignement_periode_eleve_id_periode_id_ UNIQUE (eleve_id, periode_id, enseignement_id);


--
-- Name: uk_appreciation_eleve_periode_eleve_id_periode_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT uk_appreciation_eleve_periode_eleve_id_periode_id UNIQUE (eleve_id, periode_id);


--
-- Name: uk_brevet_fiche_eleve_id_annee_scolaire_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT uk_brevet_fiche_eleve_id_annee_scolaire_id UNIQUE (eleve_id, annee_scolaire_id);


--
-- Name: uk_brevet_note_fiche_id_epreuve_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT uk_brevet_note_fiche_id_epreuve_id UNIQUE (fiche_id, epreuve_id);


--
-- Name: uk_info_calcul_moyennes_classe_classe_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT uk_info_calcul_moyennes_classe_classe_id UNIQUE (classe_id);


--
-- Name: uk_note_evaluation_id_eleve_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note
    ADD CONSTRAINT uk_note_evaluation_id_eleve_id UNIQUE (evaluation_id, eleve_id);


--
-- Name: uk_resultat_classe_enseignement_periode_enseignement_id_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT uk_resultat_classe_enseignement_periode_enseignement_id_periode UNIQUE (enseignement_id, periode_id, structure_enseignement_id);


--
-- Name: uk_resultat_classe_periode_periode_id_structure_enseignement_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT uk_resultat_classe_periode_periode_id_structure_enseignement_id UNIQUE (periode_id, structure_enseignement_id);


--
-- Name: uk_resultat_classe_service_periode_service_id_periode_id_struct; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT uk_resultat_classe_service_periode_service_id_periode_id_struct UNIQUE (service_id, periode_id, structure_enseignement_id);


--
-- Name: uk_resultat_classe_sous_service_periode_resultat_classe_service; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT uk_resultat_classe_sous_service_periode_resultat_classe_service UNIQUE (resultat_classe_service_periode_id, sous_service_id);


--
-- Name: uk_resultat_eleve_enseignement_periode_enseignement_id_eleve_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT uk_resultat_eleve_enseignement_periode_enseignement_id_eleve_id UNIQUE (enseignement_id, eleve_id, periode_id);


--
-- Name: uk_resultat_eleve_periode_periode_id_autorite_eleve_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT uk_resultat_eleve_periode_periode_id_autorite_eleve_id UNIQUE (periode_id, autorite_eleve_id);


--
-- Name: uk_resultat_eleve_service_periode_service_id_periode_id_autorit; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT uk_resultat_eleve_service_periode_service_id_periode_id_autorit UNIQUE (service_id, periode_id, autorite_eleve_id);


--
-- Name: uk_resultat_eleve_sous_service_periode_resultat_eleve_service_p; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT uk_resultat_eleve_sous_service_periode_resultat_eleve_service_p UNIQUE (resultat_eleve_service_periode_id, sous_service_id);


SET search_path = enttemps, pg_catalog;

--
-- Name: pk_absence_journee; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT pk_absence_journee PRIMARY KEY (id);


--
-- Name: pk_agenda; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT pk_agenda PRIMARY KEY (id);


--
-- Name: pk_appel; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT pk_appel PRIMARY KEY (id);


--
-- Name: pk_appel_ligne; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT pk_appel_ligne PRIMARY KEY (id);


--
-- Name: pk_appel_plage_horaire; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT pk_appel_plage_horaire PRIMARY KEY (appel_id, plage_horaire_id);


--
-- Name: pk_date_exclue; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY date_exclue
    ADD CONSTRAINT pk_date_exclue PRIMARY KEY (id);


--
-- Name: pk_evenement; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT pk_evenement PRIMARY KEY (id);


--
-- Name: pk_groupe_motif; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT pk_groupe_motif PRIMARY KEY (id);


--
-- Name: pk_incident; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT pk_incident PRIMARY KEY (id);


--
-- Name: pk_lieu_incident; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT pk_lieu_incident PRIMARY KEY (id);


--
-- Name: pk_motif; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT pk_motif PRIMARY KEY (id);


--
-- Name: pk_partenaire_a_prevenir; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT pk_partenaire_a_prevenir PRIMARY KEY (id);


--
-- Name: pk_partenaire_a_prevenir_incident; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT pk_partenaire_a_prevenir_incident PRIMARY KEY (id);


--
-- Name: pk_plage_horaire; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plage_horaire
    ADD CONSTRAINT pk_plage_horaire PRIMARY KEY (id);


--
-- Name: pk_preference_etablissement_absences; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT pk_preference_etablissement_absences PRIMARY KEY (id);


--
-- Name: pk_preference_utilisateur_agenda; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_utilisateur_agenda
    ADD CONSTRAINT pk_preference_utilisateur_agenda PRIMARY KEY (id);


--
-- Name: pk_protagoniste_incident; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT pk_protagoniste_incident PRIMARY KEY (id);


--
-- Name: pk_punition; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT pk_punition PRIMARY KEY (id);


--
-- Name: pk_qualite_protagoniste; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT pk_qualite_protagoniste PRIMARY KEY (id);


--
-- Name: pk_rel_agenda_evenement; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT pk_rel_agenda_evenement PRIMARY KEY (id);


--
-- Name: pk_repeter_jour_annee; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repeter_jour_annee
    ADD CONSTRAINT pk_repeter_jour_annee PRIMARY KEY (id);


--
-- Name: pk_repeter_jour_mois; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repeter_jour_mois
    ADD CONSTRAINT pk_repeter_jour_mois PRIMARY KEY (id);


--
-- Name: pk_repeter_jour_semaine; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repeter_jour_semaine
    ADD CONSTRAINT pk_repeter_jour_semaine PRIMARY KEY (id);


--
-- Name: pk_repeter_mois; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repeter_mois
    ADD CONSTRAINT pk_repeter_mois PRIMARY KEY (id);


--
-- Name: pk_repeter_semaine_annee; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repeter_semaine_annee
    ADD CONSTRAINT pk_repeter_semaine_annee PRIMARY KEY (id);


--
-- Name: pk_sanction; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT pk_sanction PRIMARY KEY (id);


--
-- Name: pk_type_agenda; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_agenda
    ADD CONSTRAINT pk_type_agenda PRIMARY KEY (id);


--
-- Name: pk_type_evenement; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_evenement
    ADD CONSTRAINT pk_type_evenement PRIMARY KEY (id);


--
-- Name: pk_type_incident; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT pk_type_incident PRIMARY KEY (id);


--
-- Name: pk_type_punition; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT pk_type_punition PRIMARY KEY (id);


--
-- Name: pk_type_sanction; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT pk_type_sanction PRIMARY KEY (id);


--
-- Name: uk_absence_journee_etablissement_id_date; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT uk_absence_journee_etablissement_id_date UNIQUE (etablissement_id, date);


--
-- Name: uk_appel_evenement_id; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT uk_appel_evenement_id UNIQUE (evenement_id);


--
-- Name: uk_appel_ligne_appel_id_autorite_id; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT uk_appel_ligne_appel_id_autorite_id UNIQUE (appel_id, autorite_id);


--
-- Name: uk_groupe_motif_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT uk_groupe_motif_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- Name: uk_lieu_incident_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT uk_lieu_incident_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- Name: uk_motif_groupe_motif_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT uk_motif_groupe_motif_id_libelle UNIQUE (groupe_motif_id, libelle);


--
-- Name: uk_partenaire_a_prevenir_incident_partenaire_a_prevenir_id_inci; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT uk_partenaire_a_prevenir_incident_partenaire_a_prevenir_id_inci UNIQUE (partenaire_a_prevenir_id, incident_id);


--
-- Name: uk_partenaire_a_prevenir_preference_etablissement_absences_id_l; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT uk_partenaire_a_prevenir_preference_etablissement_absences_id_l UNIQUE (preference_etablissement_absences_id, libelle);


--
-- Name: uk_preference_etablissement_absences_etablissement_id; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT uk_preference_etablissement_absences_etablissement_id UNIQUE (etablissement_id);


--
-- Name: uk_preference_utilisateur_agenda_utilisateur_id_agenda_id; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_utilisateur_agenda
    ADD CONSTRAINT uk_preference_utilisateur_agenda_utilisateur_id_agenda_id UNIQUE (utilisateur_id, agenda_id);


--
-- Name: uk_qualite_protagoniste_preference_etablissement_absences_id_li; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT uk_qualite_protagoniste_preference_etablissement_absences_id_li UNIQUE (preference_etablissement_absences_id, libelle);


--
-- Name: uk_rel_agenda_evenement_evenement_id_agenda_id; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT uk_rel_agenda_evenement_evenement_id_agenda_id UNIQUE (evenement_id, agenda_id);


--
-- Name: uk_type_agenda_code; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_agenda
    ADD CONSTRAINT uk_type_agenda_code UNIQUE (code);


--
-- Name: uk_type_evenement_type; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_evenement
    ADD CONSTRAINT uk_type_evenement_type UNIQUE (type);


--
-- Name: uk_type_incident_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT uk_type_incident_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- Name: uk_type_punition_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT uk_type_punition_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- Name: uk_type_sanction_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT uk_type_sanction_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


SET search_path = enttemps_2011_2012, pg_catalog;

--
-- Name: pk_absence_journee; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT pk_absence_journee PRIMARY KEY (id);


--
-- Name: pk_agenda; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT pk_agenda PRIMARY KEY (id);


--
-- Name: pk_appel; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT pk_appel PRIMARY KEY (id);


--
-- Name: pk_appel_ligne; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT pk_appel_ligne PRIMARY KEY (id);


--
-- Name: pk_appel_plage_horaire; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT pk_appel_plage_horaire PRIMARY KEY (appel_id, plage_horaire_id);


--
-- Name: pk_calendrier; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT pk_calendrier PRIMARY KEY (id);


--
-- Name: pk_evenement; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT pk_evenement PRIMARY KEY (id);


--
-- Name: pk_groupe_motif; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT pk_groupe_motif PRIMARY KEY (id);


--
-- Name: pk_incident; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT pk_incident PRIMARY KEY (id);


--
-- Name: pk_lieu_incident; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT pk_lieu_incident PRIMARY KEY (id);


--
-- Name: pk_motif; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT pk_motif PRIMARY KEY (id);


--
-- Name: pk_partenaire_a_prevenir; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT pk_partenaire_a_prevenir PRIMARY KEY (id);


--
-- Name: pk_partenaire_a_prevenir_incident; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT pk_partenaire_a_prevenir_incident PRIMARY KEY (id);


--
-- Name: pk_plage_horaire; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plage_horaire
    ADD CONSTRAINT pk_plage_horaire PRIMARY KEY (id);


--
-- Name: pk_preference_etablissement_absences; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT pk_preference_etablissement_absences PRIMARY KEY (id);


--
-- Name: pk_protagoniste_incident; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT pk_protagoniste_incident PRIMARY KEY (id);


--
-- Name: pk_punition; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT pk_punition PRIMARY KEY (id);


--
-- Name: pk_qualite_protagoniste; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT pk_qualite_protagoniste PRIMARY KEY (id);


--
-- Name: pk_rel_agenda_evenement; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT pk_rel_agenda_evenement PRIMARY KEY (id);


--
-- Name: pk_sanction; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT pk_sanction PRIMARY KEY (id);


--
-- Name: pk_type_incident; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT pk_type_incident PRIMARY KEY (id);


--
-- Name: pk_type_punition; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT pk_type_punition PRIMARY KEY (id);


--
-- Name: pk_type_sanction; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT pk_type_sanction PRIMARY KEY (id);


--
-- Name: uk_absence_journee_etablissement_id_date; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT uk_absence_journee_etablissement_id_date UNIQUE (etablissement_id, date);


--
-- Name: uk_appel_evenement_id; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT uk_appel_evenement_id UNIQUE (evenement_id);


--
-- Name: uk_appel_ligne_appel_id_autorite_id; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT uk_appel_ligne_appel_id_autorite_id UNIQUE (appel_id, autorite_id);


--
-- Name: uk_calendrier_etablissement_id_annee_scolaire_id; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT uk_calendrier_etablissement_id_annee_scolaire_id UNIQUE (etablissement_id, annee_scolaire_id);


--
-- Name: uk_groupe_motif_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT uk_groupe_motif_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- Name: uk_lieu_incident_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT uk_lieu_incident_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- Name: uk_motif_groupe_motif_id_libelle; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT uk_motif_groupe_motif_id_libelle UNIQUE (groupe_motif_id, libelle);


--
-- Name: uk_partenaire_a_prevenir_incident_partenaire_a_prevenir_id_inci; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT uk_partenaire_a_prevenir_incident_partenaire_a_prevenir_id_inci UNIQUE (partenaire_a_prevenir_id, incident_id);


--
-- Name: uk_partenaire_a_prevenir_preference_etablissement_absences_id_l; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT uk_partenaire_a_prevenir_preference_etablissement_absences_id_l UNIQUE (preference_etablissement_absences_id, libelle);


--
-- Name: uk_preference_etablissement_absences_etablissement_id; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT uk_preference_etablissement_absences_etablissement_id UNIQUE (etablissement_id);


--
-- Name: uk_qualite_protagoniste_preference_etablissement_absences_id_li; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT uk_qualite_protagoniste_preference_etablissement_absences_id_li UNIQUE (preference_etablissement_absences_id, libelle);


--
-- Name: uk_rel_agenda_evenement_evenement_id_agenda_id; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT uk_rel_agenda_evenement_evenement_id_agenda_id UNIQUE (evenement_id, agenda_id);


--
-- Name: uk_type_incident_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT uk_type_incident_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- Name: uk_type_punition_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT uk_type_punition_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- Name: uk_type_sanction_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT uk_type_sanction_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


SET search_path = forum, pg_catalog;

--
-- Name: pk_commentaire_lu; Type: CONSTRAINT; Schema: forum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY commentaire_lu
    ADD CONSTRAINT pk_commentaire_lu PRIMARY KEY (commentaire_id, autorite_id);


--
-- Name: pk_forum_commentaire; Type: CONSTRAINT; Schema: forum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY commentaire
    ADD CONSTRAINT pk_forum_commentaire PRIMARY KEY (id);


--
-- Name: pk_forum_discussion; Type: CONSTRAINT; Schema: forum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT pk_forum_discussion PRIMARY KEY (id);


--
-- Name: pk_forum_etat_commentaire; Type: CONSTRAINT; Schema: forum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etat_commentaire
    ADD CONSTRAINT pk_forum_etat_commentaire PRIMARY KEY (code);


--
-- Name: pk_forum_etat_discussion; Type: CONSTRAINT; Schema: forum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etat_discussion
    ADD CONSTRAINT pk_forum_etat_discussion PRIMARY KEY (code);


--
-- Name: pk_forum_type_moderation; Type: CONSTRAINT; Schema: forum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_moderation
    ADD CONSTRAINT pk_forum_type_moderation PRIMARY KEY (code);


SET search_path = impression, pg_catalog;

--
-- Name: pk_publipostage_suivi; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT pk_publipostage_suivi PRIMARY KEY (id);


--
-- Name: pk_sms_fournisseur; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sms_fournisseur
    ADD CONSTRAINT pk_sms_fournisseur PRIMARY KEY (id);


--
-- Name: pk_sms_fournisseur_etablissement; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sms_fournisseur_etablissement
    ADD CONSTRAINT pk_sms_fournisseur_etablissement PRIMARY KEY (id);


--
-- Name: pk_template_champ_memo; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_champ_memo
    ADD CONSTRAINT pk_template_champ_memo PRIMARY KEY (id);


--
-- Name: pk_template_eliot; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT pk_template_eliot PRIMARY KEY (id);


--
-- Name: pk_template_jasper; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_jasper
    ADD CONSTRAINT pk_template_jasper PRIMARY KEY (id);


--
-- Name: pk_template_type_donnees; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_type_donnees
    ADD CONSTRAINT pk_template_type_donnees PRIMARY KEY (id);


--
-- Name: pk_template_type_fonctionnalite; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_type_fonctionnalite
    ADD CONSTRAINT pk_template_type_fonctionnalite PRIMARY KEY (id);


--
-- Name: pk_template_utilisateur; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_document
    ADD CONSTRAINT pk_template_utilisateur PRIMARY KEY (id);


--
-- Name: pk_template_utilisateur_sous_template_eliot; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_document_sous_template_eliot
    ADD CONSTRAINT pk_template_utilisateur_sous_template_eliot PRIMARY KEY (id);


--
-- Name: uk_sms_fournisseur_etablissement_etablissement_actif; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sms_fournisseur_etablissement
    ADD CONSTRAINT uk_sms_fournisseur_etablissement_etablissement_actif UNIQUE (etablissement_id, actif);


--
-- Name: uk_sms_fournisseur_etablissement_sms_fournisseur; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sms_fournisseur_etablissement
    ADD CONSTRAINT uk_sms_fournisseur_etablissement_sms_fournisseur UNIQUE (etablissement_id, sms_fournisseur_id);


--
-- Name: uk_template_champ_memo_template_document_id_champ; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_champ_memo
    ADD CONSTRAINT uk_template_champ_memo_template_document_id_champ UNIQUE (template_document_id, champ);


--
-- Name: uk_template_document_nom_etablissement_id; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_document
    ADD CONSTRAINT uk_template_document_nom_etablissement_id UNIQUE (nom, etablissement_id);


--
-- Name: uk_template_document_sous_template_eliot_template_document_id_p; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_document_sous_template_eliot
    ADD CONSTRAINT uk_template_document_sous_template_eliot_template_document_id_p UNIQUE (template_document_id, param);


--
-- Name: uk_template_eliot_code; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT uk_template_eliot_code UNIQUE (code);


--
-- Name: uk_template_type_donnees_code; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_type_donnees
    ADD CONSTRAINT uk_template_type_donnees_code UNIQUE (code);


SET search_path = public, pg_catalog;


--
-- Name: pk_eliot_version; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eliot_version
    ADD CONSTRAINT pk_eliot_version PRIMARY KEY (id);


--
-- Name: uk_eliot_version_code; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eliot_version
    ADD CONSTRAINT uk_eliot_version_code UNIQUE (code);


SET search_path = securite, pg_catalog;

--
-- Name: pk_autorisation; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT pk_autorisation PRIMARY KEY (id);


--
-- Name: pk_autorite; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autorite
    ADD CONSTRAINT pk_autorite PRIMARY KEY (id);


--
-- Name: pk_item; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY item
    ADD CONSTRAINT pk_item PRIMARY KEY (id);


--
-- Name: pk_perimetre; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY perimetre
    ADD CONSTRAINT pk_perimetre PRIMARY KEY (id);


--
-- Name: pk_perimetre_securite; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY perimetre_securite
    ADD CONSTRAINT pk_perimetre_securite PRIMARY KEY (id);


--
-- Name: pk_permission; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY permission
    ADD CONSTRAINT pk_permission PRIMARY KEY (id);


--
-- Name: uk_autorisation_item_id_autorite_id; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT uk_autorisation_item_id_autorite_id UNIQUE (item_id, autorite_id);


--
-- Name: uk_autorite_enregistrement_cible_id_nom_entite_cible; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autorite
    ADD CONSTRAINT uk_autorite_enregistrement_cible_id_nom_entite_cible UNIQUE (enregistrement_cible_id, nom_entite_cible);


--
-- Name: uk_autorite_id_externe_type; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autorite
    ADD CONSTRAINT uk_autorite_id_externe_type UNIQUE (id_externe, type);


--
-- Name: uk_item_enregistrement_cible_id_nom_entite_cible; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY item
    ADD CONSTRAINT uk_item_enregistrement_cible_id_nom_entite_cible UNIQUE (enregistrement_cible_id, nom_entite_cible);


--
-- Name: uk_perimetre_enregistrement_cible_id_nom_entite_cible; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY perimetre
    ADD CONSTRAINT uk_perimetre_enregistrement_cible_id_nom_entite_cible UNIQUE (enregistrement_cible_id, nom_entite_cible);


--
-- Name: uk_perimetre_securite_item_id_perimetre_id; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY perimetre_securite
    ADD CONSTRAINT uk_perimetre_securite_item_id_perimetre_id UNIQUE (item_id, perimetre_id);


SET search_path = td, pg_catalog;

--
-- Name: pk_copie; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY copie
    ADD CONSTRAINT pk_copie PRIMARY KEY (id);


--
-- Name: pk_modalite_activite; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT pk_modalite_activite PRIMARY KEY (id);


--
-- Name: pk_question; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question
    ADD CONSTRAINT pk_question PRIMARY KEY (id);


--
-- Name: pk_question_attachement; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question_attachement
    ADD CONSTRAINT pk_question_attachement PRIMARY KEY (id);


--
-- Name: pk_question_export; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question_export
    ADD CONSTRAINT pk_question_export PRIMARY KEY (id);


--
-- Name: pk_question_type; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question_type
    ADD CONSTRAINT pk_question_type PRIMARY KEY (id);


--
-- Name: pk_reponse; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reponse
    ADD CONSTRAINT pk_reponse PRIMARY KEY (id);


--
-- Name: pk_reponse_attachement; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reponse_attachement
    ADD CONSTRAINT pk_reponse_attachement PRIMARY KEY (id);


--
-- Name: pk_sujet; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT pk_sujet PRIMARY KEY (id);


--
-- Name: pk_sujet_sequence_questions; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sujet_sequence_questions
    ADD CONSTRAINT pk_sujet_sequence_questions PRIMARY KEY (id);


--
-- Name: pk_sujet_type; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sujet_type
    ADD CONSTRAINT pk_sujet_type PRIMARY KEY (id);


--
-- Name: uk_copie_seance_eleve; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY copie
    ADD CONSTRAINT uk_copie_seance_eleve UNIQUE (modalite_activite_id, eleve_id);


--
-- Name: uk_reponse_copie_question; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reponse
    ADD CONSTRAINT uk_reponse_copie_question UNIQUE (sujet_question_id, copie_id);


SET search_path = tice, pg_catalog;

--
-- TOC entry 4455 (class 2606 OID 139164)
-- Dependencies: 547 547
-- Name: db_data_record_identifier_key; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace:
--

ALTER TABLE ONLY db_data_record
    ADD CONSTRAINT db_data_record_identifier_key UNIQUE (identifier);


--
-- TOC entry 4381 (class 2606 OID 138579)
-- Dependencies: 518 518
-- Name: pk_attachement; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace:
--

ALTER TABLE ONLY attachement
    ADD CONSTRAINT pk_attachement PRIMARY KEY (id);


--
-- Name: pk_compte_utilisateur; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace: 
--

ALTER TABLE ONLY compte_utilisateur
    ADD CONSTRAINT pk_compte_utilisateur PRIMARY KEY (id);


--
-- Name: pk_copyrigths_type; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace: 
--

ALTER TABLE ONLY copyrights_type
    ADD CONSTRAINT pk_copyrigths_type PRIMARY KEY (id);


--
-- TOC entry 4457 (class 2606 OID 139162)
-- Dependencies: 547 547
-- Name: pk_db_data_record; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace:
--

ALTER TABLE ONLY db_data_record
    ADD CONSTRAINT pk_db_data_record PRIMARY KEY (id);


--
-- TOC entry 4378 (class 2606 OID 138569)
-- Dependencies: 516 516
-- Name: pk_export_format; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace:
--

ALTER TABLE ONLY export_format
    ADD CONSTRAINT pk_export_format PRIMARY KEY (id);


--
-- Name: pk_publication; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace: 
--

ALTER TABLE ONLY publication
    ADD CONSTRAINT pk_publication PRIMARY KEY (id);


--
-- Name: uk_compte_utilisateur_login; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace: 
--

ALTER TABLE ONLY compte_utilisateur
    ADD CONSTRAINT uk_compte_utilisateur_login UNIQUE (login);


--
-- Name: uk_compte_utilisateur_login_alias; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace: 
--

ALTER TABLE ONLY compte_utilisateur
    ADD CONSTRAINT uk_compte_utilisateur_login_alias UNIQUE (login_alias);


SET search_path = udt, pg_catalog;

--
-- Name: pk_enseignement; Type: CONSTRAINT; Schema: udt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT pk_enseignement PRIMARY KEY (id);


--
-- Name: pk_evenement; Type: CONSTRAINT; Schema: udt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT pk_evenement PRIMARY KEY (id);


--
-- Name: pk_import; Type: CONSTRAINT; Schema: udt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import
    ADD CONSTRAINT pk_import PRIMARY KEY (id);


SET search_path = ent, pg_catalog;

--
-- Name: idx_appartenance_groupe_groupe_enfant_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_appartenance_groupe_groupe_enfant_id ON appartenance_groupe_groupe USING btree (groupe_personnes_enfant_id);


--
-- Name: idx_appartenance_personne_groupe_groupe_personnes_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_appartenance_personne_groupe_groupe_personnes_id ON appartenance_personne_groupe USING btree (groupe_personnes_id);


--
-- Name: idx_enseignement_service_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_enseignement_service_id ON enseignement USING btree (service_id);


--
-- Name: idx_etablissement_etab_ratt_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_etablissement_etab_ratt_id ON etablissement USING btree (etablissement_rattachement_id);


--
-- Name: idx_etablissement_perimetre_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_etablissement_perimetre_id ON etablissement USING btree (perimetre_id);


--
-- Name: idx_groupe_personnes_propriete_scolarite_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_groupe_personnes_propriete_scolarite_id ON groupe_personnes USING btree (propriete_scolarite_id);


--
-- Name: idx_personne_nom_prenom_normalise_date_naissance_etablissement_; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_personne_nom_prenom_normalise_date_naissance_etablissement_ ON personne USING btree (nom_normalise, prenom_normalise, date_naissance, etablissement_rattachement_id);


--
-- Name: idx_personne_propriete_scolarite_compteur_references; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_personne_propriete_scolarite_compteur_references ON personne_propriete_scolarite USING btree (compteur_references);


--
-- Name: idx_personne_propriete_scolarite_personne_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_personne_propriete_scolarite_personne_id ON personne_propriete_scolarite USING btree (personne_id);


--
-- Name: idx_personne_propriete_scolarite_personne_id_propriete_scolarit; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_personne_propriete_scolarite_personne_id_propriete_scolarit ON personne_propriete_scolarite USING btree (personne_id, propriete_scolarite_id, est_active) WHERE (est_active = true);


--
-- Name: idx_personne_propriete_scolarite_propriete_scolarite_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_personne_propriete_scolarite_propriete_scolarite_id ON personne_propriete_scolarite USING btree (propriete_scolarite_id);


--
-- Name: idx_preference_etablissement_etablissement_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_preference_etablissement_etablissement_id ON preference_etablissement USING btree (etablissement_id);


--
-- Name: idx_propriete_scolarite_etablissement_id_fonction_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_propriete_scolarite_etablissement_id_fonction_id ON propriete_scolarite USING btree (etablissement_id, fonction_id);


--
-- Name: idx_propriete_scolarite_structure_enseignement_id_fonction_id_m; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_propriete_scolarite_structure_enseignement_id_fonction_id_m ON propriete_scolarite USING btree (structure_enseignement_id, fonction_id, matiere_id);


--
-- Name: idx_rel_classe_filiere_id_filiere; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_classe_filiere_id_filiere ON rel_classe_filiere USING btree (filiere_id);


--
-- Name: idx_rel_classe_groupe_id_groupe; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_classe_groupe_id_groupe ON rel_classe_groupe USING btree (groupe_id);


--
-- Name: idx_rel_periode_service_service_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_periode_service_service_id ON rel_periode_service USING btree (service_id);


--
-- Name: idx_responsable_eleve_eleve_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_responsable_eleve_eleve_id ON responsable_eleve USING btree (eleve_id);


--
-- Name: idx_responsable_propriete_scolarite_propriete_scolarite_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_responsable_propriete_scolarite_propriete_scolarite_id ON responsable_propriete_scolarite USING btree (propriete_scolarite_id);


--
-- Name: idx_responsable_propriete_scolarite_responsable_eleve_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_responsable_propriete_scolarite_responsable_eleve_id ON responsable_propriete_scolarite USING btree (responsable_eleve_id);


--
-- Name: idx_service_id_matiere; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_service_id_matiere ON service USING btree (matiere_id);


--
-- Name: idx_service_structure_enseignement; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_service_structure_enseignement ON service USING btree (structure_enseignement_id);


--
-- Name: idx_sous_service_modalite_matiere_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_sous_service_modalite_matiere_id ON sous_service USING btree (modalite_matiere_id);


--
-- Name: ux_annee_en_cours; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX ux_annee_en_cours ON annee_scolaire USING btree (annee_en_cours) WHERE (annee_en_cours = true);


SET search_path = entcdt, pg_catalog;

--
-- Name: idx_activite_auteur_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_activite_auteur_id ON activite USING btree (auteur_id);


--
-- Name: idx_activite_cahier_de_textes_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_activite_cahier_de_textes_id ON activite USING btree (cahier_de_textes_id);


--
-- Name: idx_activite_chapitre_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_activite_chapitre_id ON activite USING btree (chapitre_id);


--
-- Name: idx_cahier_de_textes_parent_incorporation_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_cahier_de_textes_parent_incorporation_id ON cahier_de_textes USING btree (parent_incorporation_id);


--
-- Name: idx_cahier_de_textes_service_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_cahier_de_textes_service_id ON cahier_de_textes USING btree (service_id);


--
-- Name: idx_chapitre_cahier_de_textes_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_chapitre_cahier_de_textes_id ON chapitre USING btree (cahier_de_textes_id);


--
-- Name: idx_chapitre_chapitre_parent_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_chapitre_chapitre_parent_id ON chapitre USING btree (chapitre_parent_id);


--
-- Name: idx_date_activite_activite_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_date_activite_activite_id ON date_activite USING btree (activite_id);


--
-- Name: idx_dossier_acteur_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_dossier_acteur_id ON dossier USING btree (acteur_id);


--
-- Name: idx_dossier_acteur_id_est_defaut; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_dossier_acteur_id_est_defaut ON dossier USING btree (acteur_id) WHERE (est_defaut = true);


--
-- Name: idx_rel_activite_acteur_acteur_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_activite_acteur_acteur_id ON rel_activite_acteur USING btree (acteur_id);


--
-- Name: idx_rel_cahier_acteur_acteur_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_cahier_acteur_acteur_id ON rel_cahier_acteur USING btree (acteur_id);


--
-- Name: idx_rel_cahier_groupe_groupe_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_cahier_groupe_groupe_id ON rel_cahier_groupe USING btree (groupe_id);


--
-- Name: idx_rel_dossier_autorisation_cahier_autorisation_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_dossier_autorisation_cahier_autorisation_id ON rel_dossier_autorisation_cahier USING btree (autorisation_id);


--
-- Name: idx_ressource_activite_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_ressource_activite_id ON ressource USING btree (activite_id);


--
-- Name: idx_visa_auteur_personne_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_visa_auteur_personne_id ON visa USING btree (auteur_personne_id);


--
-- Name: idx_visa_cahier_vise_id_date_visee; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_visa_cahier_vise_id_date_visee ON visa USING btree (cahier_vise_id, date_visee);


SET search_path = entdemon, pg_catalog;

--
-- Name: idx_demande_traitement_date_demande; Type: INDEX; Schema: entdemon; Owner: -; Tablespace: 
--

CREATE INDEX idx_demande_traitement_date_demande ON demande_traitement USING btree (date_demande) WHERE ((statut)::text = 'EN_ATTENTE'::text);


SET search_path = entnotes, pg_catalog;

--
-- Name: idx_dirty_moyenne_classe_periode; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_classe_periode ON dirty_moyenne USING btree (classe_id, periode_id) WHERE ((type_moyenne)::text = 'CLASSE_PERIODE'::text);


--
-- Name: idx_dirty_moyenne_classe_periode_enseignement; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_classe_periode_enseignement ON dirty_moyenne USING btree (classe_id, periode_id, enseignement_id) WHERE ((type_moyenne)::text = 'CLASSE_ENSEIGNEMENT_PERIODE'::text);


--
-- Name: idx_dirty_moyenne_classe_periode_service; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_classe_periode_service ON dirty_moyenne USING btree (classe_id, periode_id, service_id) WHERE ((type_moyenne)::text = 'CLASSE_SERVICE_PERIODE'::text);


--
-- Name: idx_dirty_moyenne_classe_periode_sous_service; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_classe_periode_sous_service ON dirty_moyenne USING btree (classe_id, periode_id, sous_service_id) WHERE ((type_moyenne)::text = 'CLASSE_SOUS_SERVICE_PERIODE'::text);


--
-- Name: idx_dirty_moyenne_eleve_periode; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_eleve_periode ON dirty_moyenne USING btree (eleve_id, periode_id) WHERE ((type_moyenne)::text = 'ELEVE_PERIODE'::text);


--
-- Name: idx_dirty_moyenne_eleve_periode_enseignement; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_eleve_periode_enseignement ON dirty_moyenne USING btree (eleve_id, periode_id, enseignement_id) WHERE ((type_moyenne)::text = 'ELEVE_ENSEIGNEMENT_PERIODE'::text);


--
-- Name: idx_dirty_moyenne_eleve_periode_service; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_eleve_periode_service ON dirty_moyenne USING btree (eleve_id, periode_id, service_id) WHERE ((type_moyenne)::text = 'ELEVE_SERVICE_PERIODE'::text);


--
-- Name: idx_dirty_moyenne_eleve_periode_sous_service; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_eleve_periode_sous_service ON dirty_moyenne USING btree (eleve_id, periode_id, sous_service_id) WHERE ((type_moyenne)::text = 'ELEVE_SOUS_SERVICE_PERIODE'::text);


--
-- Name: idx_evaluation_enseignement; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_evaluation_enseignement ON evaluation USING btree (enseignement_id);


--
-- Name: idx_note_textuelle_etablissement_code; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_note_textuelle_etablissement_code ON note_textuelle USING btree (etablissement_id, upper((code)::text));


--
-- Name: idx_note_textuelle_etablissement_libelle; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_note_textuelle_etablissement_libelle ON note_textuelle USING btree (etablissement_id, upper((libelle)::text));


--
-- Name: idx_rel_evaluation_periode_periode_id; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_evaluation_periode_periode_id ON rel_evaluation_periode USING btree (periode_id);


--
-- Name: idx_resultat_classe_service_periode_classe; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_resultat_classe_service_periode_classe ON resultat_classe_service_periode USING btree (structure_enseignement_id);


--
-- Name: idx_resultat_classe_sous_service_periode_ssid; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_resultat_classe_sous_service_periode_ssid ON resultat_classe_sous_service_periode USING btree (sous_service_id);


--
-- Name: idx_resultat_eleve_sous_service_periode_ssid; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_resultat_eleve_sous_service_periode_ssid ON resultat_eleve_sous_service_periode USING btree (sous_service_id);


SET search_path = enttemps, pg_catalog;

--
-- Name: idx_agenda_enseignant_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_agenda_enseignant_id ON agenda USING btree (enseignant_id);


--
-- Name: idx_agenda_etablissement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_agenda_etablissement_id ON agenda USING btree (etablissement_id);


--
-- Name: idx_agenda_item_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_agenda_item_id ON agenda USING btree (item_id);


--
-- Name: idx_agenda_structure_enseignement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_agenda_structure_enseignement_id ON agenda USING btree (structure_enseignement_id);


--
-- Name: idx_appel_date_heure_debut; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_appel_date_heure_debut ON appel USING btree (date_heure_debut);


--
-- Name: idx_appel_date_heure_fin; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_appel_date_heure_fin ON appel USING btree (date_heure_fin);


--
-- Name: idx_appel_ligne_absence_journee_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_appel_ligne_absence_journee_id ON appel_ligne USING btree (absence_journee_id);


--
-- Name: idx_appel_ligne_autorite_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_appel_ligne_autorite_id ON appel_ligne USING btree (autorite_id);


--
-- Name: idx_date_exclue_evenement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_date_exclue_evenement_id ON date_exclue USING btree (evenement_id);


--
-- Name: idx_evenement_agenda_maitre_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_evenement_agenda_maitre_id ON evenement USING btree (agenda_maitre_id);


--
-- Name: idx_evenement_auteur; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_evenement_auteur ON evenement USING btree (auteur_id) WHERE (auteur_id > 0);


--
-- Name: idx_evenement_date_heure_debut; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_evenement_date_heure_debut ON evenement USING btree (date_heure_debut);


--
-- Name: idx_evenement_date_heure_fin; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_evenement_date_heure_fin ON evenement USING btree (date_heure_fin);


--
-- Name: idx_evenement_enseignement; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_evenement_enseignement ON evenement USING btree (enseignement_id);


--
-- Name: idx_partenaire_a_prevenir_incident_incident_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_partenaire_a_prevenir_incident_incident_id ON partenaire_a_prevenir_incident USING btree (incident_id);


--
-- Name: idx_plage_horaire_preference_etablissement_absences_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_plage_horaire_preference_etablissement_absences_id ON plage_horaire USING btree (preference_etablissement_absences_id);


--
-- Name: idx_preference_utilisateur_agenda_agenda_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_preference_utilisateur_agenda_agenda_id ON preference_utilisateur_agenda USING btree (agenda_id);


--
-- Name: idx_protagoniste_incident_autorite_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_protagoniste_incident_autorite_id ON protagoniste_incident USING btree (autorite_id);


--
-- Name: idx_protagoniste_incident_incident_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_protagoniste_incident_incident_id ON protagoniste_incident USING btree (incident_id);


--
-- Name: idx_punition_date; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_punition_date ON punition USING btree (date);


--
-- Name: idx_punition_eleve_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_punition_eleve_id ON punition USING btree (eleve_id);


--
-- Name: idx_punition_incident_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_punition_incident_id ON punition USING btree (incident_id);


--
-- Name: idx_punition_type_punition_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_punition_type_punition_id ON punition USING btree (type_punition_id);


--
-- Name: idx_rel_agenda_evenement_agenda_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_agenda_evenement_agenda_id ON rel_agenda_evenement USING btree (agenda_id);


--
-- Name: idx_repeter_jour_annee_evenement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_repeter_jour_annee_evenement_id ON repeter_jour_annee USING btree (evenement_id);


--
-- Name: idx_repeter_jour_mois_evenement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_repeter_jour_mois_evenement_id ON repeter_jour_mois USING btree (evenement_id);


--
-- Name: idx_repeter_jour_semaine_evenement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_repeter_jour_semaine_evenement_id ON repeter_jour_semaine USING btree (evenement_id);


--
-- Name: idx_repeter_mois_evenement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_repeter_mois_evenement_id ON repeter_mois USING btree (evenement_id);


--
-- Name: idx_repeter_semaine_annee_evenement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_repeter_semaine_annee_evenement_id ON repeter_semaine_annee USING btree (evenement_id);


--
-- Name: idx_sanction_eleve_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_sanction_eleve_id ON sanction USING btree (eleve_id);


--
-- Name: idx_sanction_type_sanction_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_sanction_type_sanction_id ON sanction USING btree (type_sanction_id);


--
-- Name: inx_lieu_incident_case_sensitive; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX inx_lieu_incident_case_sensitive ON lieu_incident USING btree (preference_etablissement_absences_id, lower((libelle)::text));


--
-- Name: inx_partenaire_a_prevenir_case_sensitive; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX inx_partenaire_a_prevenir_case_sensitive ON partenaire_a_prevenir USING btree (preference_etablissement_absences_id, lower((libelle)::text));


--
-- Name: inx_qualite_protagoniste_case_sensitive; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX inx_qualite_protagoniste_case_sensitive ON qualite_protagoniste USING btree (preference_etablissement_absences_id, lower((libelle)::text));


--
-- Name: inx_type_incident_case_sensitive; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX inx_type_incident_case_sensitive ON type_incident USING btree (preference_etablissement_absences_id, lower((libelle)::text));


--
-- Name: inx_type_punition_case_sensitive; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX inx_type_punition_case_sensitive ON type_punition USING btree (preference_etablissement_absences_id, lower((libelle)::text));


--
-- Name: inx_type_sanction_case_sensitive; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX inx_type_sanction_case_sensitive ON type_sanction USING btree (preference_etablissement_absences_id, lower((libelle)::text));


SET search_path = forum, pg_catalog;

--
-- Name: idx_commentaire_id_discussion; Type: INDEX; Schema: forum; Owner: -; Tablespace: 
--

CREATE INDEX idx_commentaire_id_discussion ON commentaire USING btree (discussion_id);


--
-- Name: idx_discussion_id_item_cible; Type: INDEX; Schema: forum; Owner: -; Tablespace: 
--

CREATE INDEX idx_discussion_id_item_cible ON discussion USING btree (item_cible_id);


SET search_path = impression, pg_catalog;

--
-- Name: idx_publipostage_suivi_classe_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_publipostage_suivi_classe_id ON publipostage_suivi USING btree (classe_id);


--
-- Name: idx_publipostage_suivi_personne_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_publipostage_suivi_personne_id ON publipostage_suivi USING btree (personne_id);


--
-- Name: idx_publipostage_suivi_template_doc_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_publipostage_suivi_template_doc_id ON publipostage_suivi USING btree (template_document_id);


--
-- Name: idx_template_doc_sous_template_eliot_template_eliot_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_doc_sous_template_eliot_template_eliot_id ON template_document_sous_template_eliot USING btree (template_eliot_id);


--
-- Name: idx_template_document_etablissement_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_document_etablissement_id ON template_document USING btree (etablissement_id);


--
-- Name: idx_template_document_template_eliot_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_document_template_eliot_id ON template_document USING btree (template_eliot_id);


--
-- Name: idx_template_eliot_template_jasper_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_eliot_template_jasper_id ON template_eliot USING btree (template_jasper_id);


--
-- Name: idx_template_eliot_type_donnees_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_eliot_type_donnees_id ON template_eliot USING btree (type_donnees_id);


--
-- Name: idx_template_eliot_type_fonctionnalite_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_eliot_type_fonctionnalite_id ON template_eliot USING btree (type_fonctionnalite_id);


--
-- Name: idx_template_jasper_sous_template_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_jasper_sous_template_id ON template_jasper USING btree (sous_template_id);


--
-- Name: idx_template_type_fonctionnalite_code; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_type_fonctionnalite_code ON template_type_fonctionnalite USING btree (code);


--
-- Name: idx_template_type_fonctionnalite_parent_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_type_fonctionnalite_parent_id ON template_type_fonctionnalite USING btree (parent_id);


SET search_path = securite, pg_catalog;

--
-- Name: idx_autorisation_autorite_id; Type: INDEX; Schema: securite; Owner: -; Tablespace: 
--

CREATE INDEX idx_autorisation_autorite_id ON autorisation USING btree (autorite_id);


--
-- Name: idx_autorisation_item_id; Type: INDEX; Schema: securite; Owner: -; Tablespace: 
--

CREATE INDEX idx_autorisation_item_id ON autorisation USING btree (item_id);


--
-- Name: idx_item_item_parent_id; Type: INDEX; Schema: securite; Owner: -; Tablespace: 
--

CREATE INDEX idx_item_item_parent_id ON item USING btree (item_parent_id);


--
-- Name: idx_perimetre_perimetre_parent_id; Type: INDEX; Schema: securite; Owner: -; Tablespace: 
--

CREATE INDEX idx_perimetre_perimetre_parent_id ON perimetre USING btree (perimetre_parent_id);


--
-- Name: idx_perimetre_securite_perimetre_id; Type: INDEX; Schema: securite; Owner: -; Tablespace: 
--

CREATE INDEX idx_perimetre_securite_perimetre_id ON perimetre_securite USING btree (perimetre_id);


SET search_path = td, pg_catalog;

--
-- Name: idx_copie_correcteur_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_copie_correcteur_id ON copie USING btree (correcteur_id);


--
-- Name: idx_copie_eleve_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_copie_eleve_id ON copie USING btree (eleve_id);


--
-- Name: idx_copie_modalite_activite_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_copie_modalite_activite_id ON copie USING btree (modalite_activite_id);


--
-- Name: idx_copie_sujet_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_copie_sujet_id ON copie USING btree (sujet_id);


--
-- Name: idx_modalite_activite_activite_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_activite_id ON modalite_activite USING btree (activite_id);


--
-- Name: idx_modalite_activite_enseignant_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_enseignant_id ON modalite_activite USING btree (enseignant_id);


--
-- Name: idx_modalite_activite_etablissement_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_etablissement_id ON modalite_activite USING btree (etablissement_id);


--
-- Name: idx_modalite_activite_evaluation_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_evaluation_id ON modalite_activite USING btree (evaluation_id);


--
-- Name: idx_modalite_activite_groupe_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_groupe_id ON modalite_activite USING btree (groupe_id);


--
-- Name: idx_modalite_activite_matiere_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_matiere_id ON modalite_activite USING btree (matiere_id);


--
-- Name: idx_modalite_activite_responsable_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_responsable_id ON modalite_activite USING btree (responsable_id);


--
-- Name: idx_modalite_activite_structure_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_structure_id ON modalite_activite USING btree (structure_enseignement_id);


--
-- Name: idx_modalite_activite_sujet_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_sujet_id ON modalite_activite USING btree (sujet_id);


--
-- Name: idx_question_attachement_attachement_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_attachement_attachement_id ON question_attachement USING btree (attachement_id);


--
-- Name: idx_question_attachement_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_attachement_id ON question USING btree (attachement_id);


--
-- Name: idx_question_attachement_question_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_attachement_question_id ON question_attachement USING btree (question_id);


--
-- Name: idx_question_copyrights_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_copyrights_id ON question USING btree (copyrights_type_id);


--
-- Name: idx_question_etablissement_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_etablissement_id ON question USING btree (etablissement_id);


--
-- Name: idx_question_exercice_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_exercice_id ON question USING btree (exercice_id);


--
-- Name: idx_question_export_format_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_export_format_id ON question_export USING btree (format_id);


--
-- Name: idx_question_export_question_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_export_question_id ON question_export USING btree (question_id);


--
-- Name: idx_question_matiere_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_matiere_id ON question USING btree (matiere_id);


--
-- Name: idx_question_niveau_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_niveau_id ON question USING btree (niveau_id);


--
-- Name: idx_question_proprietaire_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_proprietaire_id ON question USING btree (proprietaire_id);


--
-- Name: idx_question_publication_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_publication_id ON question USING btree (publication_id);


--
-- Name: idx_question_type_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_type_id ON question USING btree (type_id);


--
-- Name: idx_reponse_attachement_attachement_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_reponse_attachement_attachement_id ON reponse_attachement USING btree (attachement_id);


--
-- Name: idx_reponse_attachement_reponse_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_reponse_attachement_reponse_id ON reponse_attachement USING btree (reponse_id);


--
-- Name: idx_reponse_copie_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_reponse_copie_id ON reponse USING btree (copie_id);


--
-- Name: idx_reponse_correcteur_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_reponse_correcteur_id ON reponse USING btree (correcteur_id);


--
-- Name: idx_reponse_eleve_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_reponse_eleve_id ON reponse USING btree (eleve_id);


--
-- Name: idx_reponse_sujet_question_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_reponse_sujet_question_id ON reponse USING btree (sujet_question_id);


--
-- Name: idx_sujet_copyrights_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_copyrights_id ON sujet USING btree (copyrights_type_id);


--
-- Name: idx_sujet_etablissement_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_etablissement_id ON sujet USING btree (etablissement_id);


--
-- Name: idx_sujet_matiere_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_matiere_id ON sujet USING btree (matiere_id);


--
-- Name: idx_sujet_niveau_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_niveau_id ON sujet USING btree (niveau_id);


--
-- Name: idx_sujet_proprietaire_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_proprietaire_id ON sujet USING btree (proprietaire_id);


--
-- Name: idx_sujet_publication_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_publication_id ON sujet USING btree (publication_id);


--
-- Name: idx_sujet_sequence_questions_question_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_sequence_questions_question_id ON sujet_sequence_questions USING btree (question_id);


--
-- Name: idx_sujet_sequence_questions_sujet_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_sequence_questions_sujet_id ON sujet_sequence_questions USING btree (sujet_id);


--
-- Name: idx_sujet_sujet_type_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_sujet_type_id ON sujet USING btree (sujet_type_id);


SET search_path = tice, pg_catalog;

--
-- Name: idx_attachement_chemin; Type: INDEX; Schema: tice; Owner: -; Tablespace: 
--

CREATE INDEX idx_attachement_chemin ON attachement USING btree (chemin);


--
-- Name: idx_compte_utilisateur_login; Type: INDEX; Schema: tice; Owner: -; Tablespace: 
--

CREATE INDEX idx_compte_utilisateur_login ON compte_utilisateur USING btree (login);


--
-- Name: idx_compte_utilisateur_login_alias; Type: INDEX; Schema: tice; Owner: -; Tablespace: 
--

CREATE INDEX idx_compte_utilisateur_login_alias ON compte_utilisateur USING btree (login_alias);


--
-- Name: idx_compte_utilisateur_personne_id; Type: INDEX; Schema: tice; Owner: -; Tablespace: 
--

CREATE INDEX idx_compte_utilisateur_personne_id ON compte_utilisateur USING btree (personne_id);


--
-- Name: idx_publication_copyrights_type_id; Type: INDEX; Schema: tice; Owner: -; Tablespace: 
--

CREATE INDEX idx_publication_copyrights_type_id ON publication USING btree (copyrights_type_id);


SET search_path = udt, pg_catalog;

--
-- Name: idx_import_semaine_annee_structure_prof_matiere; Type: INDEX; Schema: udt; Owner: -; Tablespace: 
--

CREATE INDEX idx_import_semaine_annee_structure_prof_matiere ON evenement USING btree (udt_import_id, semaine_index, annee, structure_enseignement_id, professeur_id, matiere_id);


SET search_path = enttemps, pg_catalog;

--
-- Name: agenda_before_insert; Type: TRIGGER; Schema: enttemps; Owner: -
--

CREATE TRIGGER agenda_before_insert BEFORE INSERT ON agenda FOR EACH ROW EXECUTE PROCEDURE agenda_before_insert();


SET search_path = aaf, pg_catalog;

--
-- Name: fk_import_verrou_import; Type: FK CONSTRAINT; Schema: aaf; Owner: -
--

ALTER TABLE ONLY import_verrou
    ADD CONSTRAINT fk_import_verrou_import FOREIGN KEY (import_id) REFERENCES import(id);


SET search_path = ent, pg_catalog;

--
-- Name: fk_appartenance_groupe_groupe_groupe_personnes_enfant; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY appartenance_groupe_groupe
    ADD CONSTRAINT fk_appartenance_groupe_groupe_groupe_personnes_enfant FOREIGN KEY (groupe_personnes_enfant_id) REFERENCES groupe_personnes(id);


--
-- Name: fk_appartenance_groupe_groupe_groupe_personnes_parent; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY appartenance_groupe_groupe
    ADD CONSTRAINT fk_appartenance_groupe_groupe_groupe_personnes_parent FOREIGN KEY (groupe_personnes_parent_id) REFERENCES groupe_personnes(id);


--
-- Name: fk_appartenance_personne_groupe_groupe_personnes; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY appartenance_personne_groupe
    ADD CONSTRAINT fk_appartenance_personne_groupe_groupe_personnes FOREIGN KEY (groupe_personnes_id) REFERENCES groupe_personnes(id);


--
-- Name: fk_appartenance_personne_groupe_personne; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY appartenance_personne_groupe
    ADD CONSTRAINT fk_appartenance_personne_groupe_personne FOREIGN KEY (personne_id) REFERENCES personne(id);


--
-- Name: fk_calendrier_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT fk_calendrier_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id) ON DELETE CASCADE;


--
-- Name: fk_calendrier_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT fk_calendrier_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- Name: fk_enseignement_autorite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_autorite FOREIGN KEY (enseignant_id) REFERENCES securite.autorite(id);


--
-- Name: fk_enseignement_service; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_service FOREIGN KEY (service_id) REFERENCES service(id) ON DELETE CASCADE;


--
-- Name: fk_etablissement_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT fk_etablissement_etablissement FOREIGN KEY (etablissement_rattachement_id) REFERENCES etablissement(id);


--
-- Name: fk_etablissement_perimetre; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT fk_etablissement_perimetre FOREIGN KEY (perimetre_id) REFERENCES securite.perimetre(id);


--
-- Name: fk_etablissement_porteur_ent; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT fk_etablissement_porteur_ent FOREIGN KEY (porteur_ent_id) REFERENCES porteur_ent(id);


--
-- Name: fk_fiche_eleve_commentaire_personne; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY fiche_eleve_commentaire
    ADD CONSTRAINT fk_fiche_eleve_commentaire_personne FOREIGN KEY (personne_id) REFERENCES personne(id);


--
-- Name: fk_groupe_personnes_autorite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT fk_groupe_personnes_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_groupe_personnes_item; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT fk_groupe_personnes_item FOREIGN KEY (item_id) REFERENCES securite.item(id);


--
-- Name: fk_groupe_personnes_propriete_scolarite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT fk_groupe_personnes_propriete_scolarite FOREIGN KEY (propriete_scolarite_id) REFERENCES propriete_scolarite(id);


--
-- Name: fk_matiere_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT fk_matiere_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id);


--
-- Name: fk_matiere_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT fk_matiere_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- Name: fk_modalite_matiere_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT fk_modalite_matiere_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id);


--
-- Name: fk_modalite_matiere_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT fk_modalite_matiere_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- Name: fk_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT fk_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id);


--
-- Name: fk_periode_type_periode; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT fk_periode_type_periode FOREIGN KEY (type_periode_id) REFERENCES type_periode(id);


--
-- Name: fk_personne_autorite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT fk_personne_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_personne_civilite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT fk_personne_civilite FOREIGN KEY (civilite_id) REFERENCES civilite(id);


--
-- Name: fk_personne_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT fk_personne_etablissement FOREIGN KEY (etablissement_rattachement_id) REFERENCES etablissement(id);


--
-- Name: fk_personne_propriete_scolarite_import; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_import FOREIGN KEY (aaf_import_id) REFERENCES aaf.import(id);


--
-- Name: fk_personne_propriete_scolarite_personne; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_personne FOREIGN KEY (personne_id) REFERENCES personne(id);


--
-- Name: fk_personne_propriete_scolarite_propriete_scolarite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_propriete_scolarite FOREIGN KEY (propriete_scolarite_id) REFERENCES propriete_scolarite(id);


--
-- Name: fk_personne_propriete_scolarite_udt_import; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_udt_import FOREIGN KEY (udt_import_id) REFERENCES udt.import(id);


--
-- Name: fk_personne_regime; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT fk_personne_regime FOREIGN KEY (regime_id) REFERENCES regime(id);


--
-- Name: fk_porteur_ent_perimetre; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY porteur_ent
    ADD CONSTRAINT fk_porteur_ent_perimetre FOREIGN KEY (perimetre_id) REFERENCES securite.perimetre(id);


--
-- Name: fk_preference_etablissement_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT fk_preference_etablissement_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id);


--
-- Name: fk_preference_etablissement_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT fk_preference_etablissement_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- Name: fk_propriete_scolarite_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id);


--
-- Name: fk_propriete_scolarite_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- Name: fk_propriete_scolarite_fonction; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_fonction FOREIGN KEY (fonction_id) REFERENCES fonction(id);


--
-- Name: fk_propriete_scolarite_matiere; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_matiere FOREIGN KEY (matiere_id) REFERENCES matiere(id);


--
-- Name: fk_propriete_scolarite_mef; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_mef FOREIGN KEY (mef_id) REFERENCES mef(id);


--
-- Name: fk_propriete_scolarite_niveau; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_niveau FOREIGN KEY (niveau_id) REFERENCES niveau(id);


--
-- Name: fk_propriete_scolarite_porteur_ent; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_porteur_ent FOREIGN KEY (porteur_ent_id) REFERENCES porteur_ent(id);


--
-- Name: fk_propriete_scolarite_structure_enseignement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id);


--
-- Name: fk_rel_classe_filiere_filiere; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT fk_rel_classe_filiere_filiere FOREIGN KEY (filiere_id) REFERENCES filiere(id);


--
-- Name: fk_rel_classe_filiere_structure_enseignement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT fk_rel_classe_filiere_structure_enseignement FOREIGN KEY (classe_id) REFERENCES structure_enseignement(id);


--
-- Name: fk_rel_classe_groupe_structure_enseignement_classe; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT fk_rel_classe_groupe_structure_enseignement_classe FOREIGN KEY (classe_id) REFERENCES structure_enseignement(id);


--
-- Name: fk_rel_classe_groupe_structure_enseignement_groupe; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT fk_rel_classe_groupe_structure_enseignement_groupe FOREIGN KEY (groupe_id) REFERENCES structure_enseignement(id);


--
-- Name: fk_rel_periode_service_periode; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT fk_rel_periode_service_periode FOREIGN KEY (periode_id) REFERENCES periode(id);


--
-- Name: fk_rel_periode_service_service; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT fk_rel_periode_service_service FOREIGN KEY (service_id) REFERENCES service(id);


--
-- Name: fk_responsable_eleve_import; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT fk_responsable_eleve_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- Name: fk_responsable_eleve_personne_eleve; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT fk_responsable_eleve_personne_eleve FOREIGN KEY (eleve_id) REFERENCES personne(id);


--
-- Name: fk_responsable_eleve_personne_personne; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT fk_responsable_eleve_personne_personne FOREIGN KEY (personne_id) REFERENCES personne(id);


--
-- Name: fk_responsable_propriete_scolarite_import; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_responsable_propriete_scolarite_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- Name: fk_responsable_propriete_scolarite_propriete_scolarite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_responsable_propriete_scolarite_propriete_scolarite FOREIGN KEY (propriete_scolarite_id) REFERENCES propriete_scolarite(id);


--
-- Name: fk_responsable_propriete_scolarite_responsable_eleve; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_responsable_propriete_scolarite_responsable_eleve FOREIGN KEY (responsable_eleve_id) REFERENCES responsable_eleve(id);


--
-- Name: fk_service_matiere; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_matiere FOREIGN KEY (matiere_id) REFERENCES matiere(id);


--
-- Name: fk_service_modalite_cours; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_modalite_cours FOREIGN KEY (modalite_cours_id) REFERENCES modalite_cours(id);


--
-- Name: fk_service_structure_enseignement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id) ON DELETE CASCADE;


--
-- Name: fk_signature_autorite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY signature
    ADD CONSTRAINT fk_signature_autorite FOREIGN KEY (proprietaire_id) REFERENCES securite.autorite(id);


--
-- Name: fk_sous_service_modalite_matiere; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_modalite_matiere FOREIGN KEY (modalite_matiere_id) REFERENCES modalite_matiere(id);


--
-- Name: fk_sous_service_service; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_service FOREIGN KEY (service_id) REFERENCES service(id);


--
-- Name: fk_sous_service_type_periode; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_type_periode FOREIGN KEY (type_periode_id) REFERENCES type_periode(id);


--
-- Name: fk_structure_enseignement_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id);


--
-- Name: fk_structure_enseignement_brevet_serie; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_brevet_serie FOREIGN KEY (brevet_serie_id) REFERENCES entnotes.brevet_serie(id);


--
-- Name: fk_structure_enseignement_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- Name: fk_structure_enseignement_niveau; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_niveau FOREIGN KEY (niveau_id) REFERENCES niveau(id);


--
-- Name: fk_type_periode_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY type_periode
    ADD CONSTRAINT fk_type_periode_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


SET search_path = ent_2011_2012, pg_catalog;

--
-- Name: fk_calendrier_annee_scolaire; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT fk_calendrier_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id) ON DELETE CASCADE;


--
-- Name: fk_calendrier_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT fk_calendrier_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_enseignement_autorite; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_autorite FOREIGN KEY (enseignant_id) REFERENCES securite.autorite(id);


--
-- Name: fk_enseignement_service; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_service FOREIGN KEY (service_id) REFERENCES service(id) ON DELETE CASCADE;


--
-- Name: fk_matiere_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT fk_matiere_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_modalite_matiere_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT fk_modalite_matiere_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT fk_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id);


--
-- Name: fk_periode_type_periode; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT fk_periode_type_periode FOREIGN KEY (type_periode_id) REFERENCES ent.type_periode(id);


--
-- Name: fk_personne_propriete_scolarite_import; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_import FOREIGN KEY (aaf_import_id) REFERENCES aaf.import(id);


--
-- Name: fk_personne_propriete_scolarite_personne; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_personne FOREIGN KEY (personne_id) REFERENCES ent.personne(id);


--
-- Name: fk_personne_propriete_scolarite_propriete_scolarite; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_propriete_scolarite FOREIGN KEY (propriete_scolarite_id) REFERENCES propriete_scolarite(id);


--
-- Name: fk_personne_propriete_scolarite_udt_import; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_udt_import FOREIGN KEY (udt_import_id) REFERENCES udt.import(id);


--
-- Name: fk_preference_etablissement_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT fk_preference_etablissement_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_preference_etablissement_sms_fournisseur_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT fk_preference_etablissement_sms_fournisseur_etablissement FOREIGN KEY (sms_fournisseur_etablissement_id) REFERENCES impression.sms_fournisseur_etablissement(id);


--
-- Name: fk_propriete_scolarite_annee_scolaire; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_propriete_scolarite_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_propriete_scolarite_fonction; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_fonction FOREIGN KEY (fonction_id) REFERENCES ent.fonction(id);


--
-- Name: fk_propriete_scolarite_matiere; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_matiere FOREIGN KEY (matiere_id) REFERENCES matiere(id);


--
-- Name: fk_propriete_scolarite_mef; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_mef FOREIGN KEY (mef_id) REFERENCES ent.mef(id);


--
-- Name: fk_propriete_scolarite_niveau; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_niveau FOREIGN KEY (niveau_id) REFERENCES ent.niveau(id);


--
-- Name: fk_propriete_scolarite_porteur_ent; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_porteur_ent FOREIGN KEY (porteur_ent_id) REFERENCES ent.porteur_ent(id);


--
-- Name: fk_propriete_scolarite_structure_enseignement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id);


--
-- Name: fk_rel_classe_filiere_filiere; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT fk_rel_classe_filiere_filiere FOREIGN KEY (filiere_id) REFERENCES ent.filiere(id);


--
-- Name: fk_rel_classe_filiere_structure_enseignement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT fk_rel_classe_filiere_structure_enseignement FOREIGN KEY (classe_id) REFERENCES structure_enseignement(id);


--
-- Name: fk_rel_classe_groupe_structure_enseignement_classe; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT fk_rel_classe_groupe_structure_enseignement_classe FOREIGN KEY (classe_id) REFERENCES structure_enseignement(id);


--
-- Name: fk_rel_classe_groupe_structure_enseignement_groupe; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT fk_rel_classe_groupe_structure_enseignement_groupe FOREIGN KEY (groupe_id) REFERENCES structure_enseignement(id);


--
-- Name: fk_rel_periode_service_periode; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT fk_rel_periode_service_periode FOREIGN KEY (periode_id) REFERENCES periode(id);


--
-- Name: fk_rel_periode_service_service; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT fk_rel_periode_service_service FOREIGN KEY (service_id) REFERENCES service(id);


--
-- Name: fk_responsable_propriete_scolarite_import; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_responsable_propriete_scolarite_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- Name: fk_responsable_propriete_scolarite_propriete_scolarite; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_responsable_propriete_scolarite_propriete_scolarite FOREIGN KEY (propriete_scolarite_id) REFERENCES propriete_scolarite(id);


--
-- Name: fk_responsable_propriete_scolarite_responsable_eleve; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_responsable_propriete_scolarite_responsable_eleve FOREIGN KEY (responsable_eleve_id) REFERENCES ent.responsable_eleve(id);


--
-- Name: fk_service_matiere; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_matiere FOREIGN KEY (matiere_id) REFERENCES matiere(id);


--
-- Name: fk_service_modalite_cours; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_modalite_cours FOREIGN KEY (modalite_cours_id) REFERENCES ent.modalite_cours(id);


--
-- Name: fk_service_structure_enseignement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id) ON DELETE CASCADE;


--
-- Name: fk_sous_service_modalite_matiere; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_modalite_matiere FOREIGN KEY (modalite_matiere_id) REFERENCES modalite_matiere(id);


--
-- Name: fk_sous_service_service; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_service FOREIGN KEY (service_id) REFERENCES service(id);


--
-- Name: fk_sous_service_type_periode; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_type_periode FOREIGN KEY (type_periode_id) REFERENCES ent.type_periode(id);


--
-- Name: fk_structure_enseignement_annee_scolaire; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_structure_enseignement_brevet_serie; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_brevet_serie FOREIGN KEY (brevet_serie_id) REFERENCES entnotes_2011_2012.brevet_serie(id);


--
-- Name: fk_structure_enseignement_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_structure_enseignement_niveau; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_niveau FOREIGN KEY (niveau_id) REFERENCES ent.niveau(id);


SET search_path = entcdt, pg_catalog;

--
-- Name: fk_activite_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_autorite FOREIGN KEY (auteur_id) REFERENCES securite.autorite(id);


--
-- Name: fk_activite_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_cahier_de_textes FOREIGN KEY (cahier_de_textes_id) REFERENCES cahier_de_textes(id);


--
-- Name: fk_activite_chapitre; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_chapitre FOREIGN KEY (chapitre_id) REFERENCES chapitre(id);


--
-- Name: fk_activite_contexte_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_contexte_activite FOREIGN KEY (contexte_activite_id) REFERENCES contexte_activite(id);


--
-- Name: fk_activite_item; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_item FOREIGN KEY (item_id) REFERENCES securite.item(id);


--
-- Name: fk_activite_type_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_type_activite FOREIGN KEY (type_activite_id) REFERENCES type_activite(id);


--
-- Name: fk_cahier_de_textes_annee_scolaire; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_cahier_de_textes_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_cahier_de_textes FOREIGN KEY (parent_incorporation_id) REFERENCES cahier_de_textes(id);


--
-- Name: fk_cahier_de_textes_fichier; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_fichier FOREIGN KEY (fichier_id) REFERENCES fichier(id);


--
-- Name: fk_cahier_de_textes_item; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_item FOREIGN KEY (item_id) REFERENCES securite.item(id);


--
-- Name: fk_cahier_de_textes_service; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_service FOREIGN KEY (service_id) REFERENCES ent.service(id);


--
-- Name: fk_chapitre_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY chapitre
    ADD CONSTRAINT fk_chapitre_autorite FOREIGN KEY (auteur_id) REFERENCES securite.autorite(id);


--
-- Name: fk_chapitre_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY chapitre
    ADD CONSTRAINT fk_chapitre_cahier_de_textes FOREIGN KEY (cahier_de_textes_id) REFERENCES cahier_de_textes(id);


--
-- Name: fk_chapitre_chapitre; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY chapitre
    ADD CONSTRAINT fk_chapitre_chapitre FOREIGN KEY (chapitre_parent_id) REFERENCES chapitre(id);


--
-- Name: fk_date_activite_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY date_activite
    ADD CONSTRAINT fk_date_activite_activite FOREIGN KEY (activite_id) REFERENCES activite(id);


--
-- Name: fk_date_activite_evenement; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY date_activite
    ADD CONSTRAINT fk_date_activite_evenement FOREIGN KEY (evenement_id) REFERENCES enttemps.evenement(id) ON UPDATE SET NULL;


--
-- Name: fk_dossier_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY dossier
    ADD CONSTRAINT fk_dossier_autorite FOREIGN KEY (acteur_id) REFERENCES securite.autorite(id);


--
-- Name: fk_rel_activite_acteur_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_activite_acteur
    ADD CONSTRAINT fk_rel_activite_acteur_activite FOREIGN KEY (activite_id) REFERENCES activite(id);


--
-- Name: fk_rel_activite_acteur_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_activite_acteur
    ADD CONSTRAINT fk_rel_activite_acteur_autorite FOREIGN KEY (acteur_id) REFERENCES securite.autorite(id);


--
-- Name: fk_rel_cahier_acteur_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_cahier_acteur
    ADD CONSTRAINT fk_rel_cahier_acteur_autorite FOREIGN KEY (acteur_id) REFERENCES securite.autorite(id);


--
-- Name: fk_rel_cahier_acteur_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_cahier_acteur
    ADD CONSTRAINT fk_rel_cahier_acteur_cahier_de_textes FOREIGN KEY (cahier_de_textes_id) REFERENCES cahier_de_textes(id);


--
-- Name: fk_rel_cahier_groupe_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_cahier_groupe
    ADD CONSTRAINT fk_rel_cahier_groupe_autorite FOREIGN KEY (groupe_id) REFERENCES securite.autorite(id);


--
-- Name: fk_rel_cahier_groupe_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_cahier_groupe
    ADD CONSTRAINT fk_rel_cahier_groupe_cahier_de_textes FOREIGN KEY (cahier_de_textes_id) REFERENCES cahier_de_textes(id);


--
-- Name: fk_rel_dossier_autorisation_cahier_autorisation; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_dossier_autorisation_cahier
    ADD CONSTRAINT fk_rel_dossier_autorisation_cahier_autorisation FOREIGN KEY (autorisation_id) REFERENCES securite.autorisation(id) ON DELETE CASCADE;


--
-- Name: fk_rel_dossier_autorisation_cahier_dossier; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_dossier_autorisation_cahier
    ADD CONSTRAINT fk_rel_dossier_autorisation_cahier_dossier FOREIGN KEY (dossier_id) REFERENCES dossier(id);


--
-- Name: fk_ressource_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY ressource
    ADD CONSTRAINT fk_ressource_activite FOREIGN KEY (activite_id) REFERENCES activite(id);


--
-- Name: fk_ressource_fichier; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY ressource
    ADD CONSTRAINT fk_ressource_fichier FOREIGN KEY (fichier_id) REFERENCES fichier(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_textes_preferences_utilisateur_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY textes_preferences_utilisateur
    ADD CONSTRAINT fk_textes_preferences_utilisateur_autorite FOREIGN KEY (utilisateur_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_visa_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY visa
    ADD CONSTRAINT fk_visa_cahier_de_textes FOREIGN KEY (cahier_vise_id) REFERENCES cahier_de_textes(id);


--
-- Name: fk_visa_etablissement; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY visa
    ADD CONSTRAINT fk_visa_etablissement FOREIGN KEY (etablissement_uai) REFERENCES ent.etablissement(uai);


--
-- Name: fk_visa_personne; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY visa
    ADD CONSTRAINT fk_visa_personne FOREIGN KEY (auteur_personne_id) REFERENCES ent.personne(id);


SET search_path = entdemon, pg_catalog;

--
-- Name: fk_demande_traitement_annee_scolaire; Type: FK CONSTRAINT; Schema: entdemon; Owner: -
--

ALTER TABLE ONLY demande_traitement
    ADD CONSTRAINT fk_demande_traitement_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_demande_traitement_autorite; Type: FK CONSTRAINT; Schema: entdemon; Owner: -
--

ALTER TABLE ONLY demande_traitement
    ADD CONSTRAINT fk_demande_traitement_autorite FOREIGN KEY (demandeur_autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_demande_traitement_etablissement; Type: FK CONSTRAINT; Schema: entdemon; Owner: -
--

ALTER TABLE ONLY demande_traitement
    ADD CONSTRAINT fk_demande_traitement_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


SET search_path = entnotes, pg_catalog;

--
-- Name: fk_appreciation_classe_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- Name: fk_appreciation_classe_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id);


--
-- Name: fk_appreciation_classe_enseignement_periode_structure_enseignem; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_structure_enseignem FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_appreciation_eleve_enseignement_periode_eleve; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_eleve FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appreciation_eleve_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- Name: fk_appreciation_eleve_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id);


--
-- Name: fk_appreciation_eleve_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appreciation_eleve_periode_avis_conseil_de_classe; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_avis_conseil_de_classe FOREIGN KEY (avis_conseil_de_classe_id) REFERENCES avis_conseil_de_classe(id);


--
-- Name: fk_appreciation_eleve_periode_avis_orientation; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_avis_orientation FOREIGN KEY (avis_orientation_id) REFERENCES avis_orientation(id);


--
-- Name: fk_appreciation_eleve_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id);


--
-- Name: fk_avis_conseil_de_classe_etablissement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY avis_conseil_de_classe
    ADD CONSTRAINT fk_avis_conseil_de_classe_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_avis_orientation_etablissement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY avis_orientation
    ADD CONSTRAINT fk_avis_orientation_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_brevet_epreuve_brevet_serie; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT fk_brevet_epreuve_brevet_serie FOREIGN KEY (serie_id) REFERENCES brevet_serie(id);


--
-- Name: fk_brevet_epreuve_exclusive; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT fk_brevet_epreuve_exclusive FOREIGN KEY (epreuve_exclusive_id) REFERENCES brevet_epreuve(id);


--
-- Name: fk_brevet_fiche_annee_scolaire; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT fk_brevet_fiche_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_brevet_fiche_personne; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT fk_brevet_fiche_personne FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- Name: fk_brevet_note_brevet_epreuve; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_brevet_epreuve FOREIGN KEY (epreuve_id) REFERENCES brevet_epreuve(id);


--
-- Name: fk_brevet_note_brevet_fiche; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_brevet_fiche FOREIGN KEY (fiche_id) REFERENCES brevet_fiche(id);


--
-- Name: fk_brevet_note_brevet_note_valeur_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_brevet_note_valeur_textuelle FOREIGN KEY (valeur_textuelle_id) REFERENCES brevet_note_valeur_textuelle(id);


--
-- Name: fk_brevet_note_matiere; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_matiere FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- Name: fk_brevet_rel_epreuve_matiere_brevet_epreuve; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT fk_brevet_rel_epreuve_matiere_brevet_epreuve FOREIGN KEY (epreuve_id) REFERENCES brevet_epreuve(id);


--
-- Name: fk_brevet_rel_epreuve_matiere_matiere; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT fk_brevet_rel_epreuve_matiere_matiere FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- Name: fk_brevet_rel_epreuve_note_valeur_textuelle_epreuve; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT fk_brevet_rel_epreuve_note_valeur_textuelle_epreuve FOREIGN KEY (brevet_epreuve_id) REFERENCES brevet_epreuve(id);


--
-- Name: fk_brevet_rel_epreuve_note_valeur_textuelle_valeur_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT fk_brevet_rel_epreuve_note_valeur_textuelle_valeur_textuelle FOREIGN KEY (valeur_textuelle_id) REFERENCES brevet_note_valeur_textuelle(id);


--
-- Name: fk_brevet_serie_annee_scolaire_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_serie
    ADD CONSTRAINT fk_brevet_serie_annee_scolaire_id FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_dirty_moyenne_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id) ON DELETE CASCADE;


--
-- Name: fk_dirty_moyenne_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_dirty_moyenne_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_service FOREIGN KEY (service_id) REFERENCES ent.service(id) ON DELETE CASCADE;


--
-- Name: fk_dirty_moyenne_sous_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_sous_service FOREIGN KEY (sous_service_id) REFERENCES ent.sous_service(id) ON DELETE CASCADE;


--
-- Name: fk_dirty_moyenne_structure_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_structure_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_dirty_moyenne_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_structure_enseignement FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id) ON DELETE CASCADE;


--
-- Name: fk_epreuve_matieres_a_heriter; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT fk_epreuve_matieres_a_heriter FOREIGN KEY (epreuve_matieres_a_heriter_id) REFERENCES brevet_epreuve(id);


--
-- Name: fk_evaluation_activite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_activite FOREIGN KEY (activite_id) REFERENCES entcdt.activite(id);


--
-- Name: fk_evaluation_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- Name: fk_evaluation_modalite_matiere; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_modalite_matiere FOREIGN KEY (modalite_matiere_id) REFERENCES ent.modalite_matiere(id);


--
-- Name: fk_info_calcul_moyennes_classe_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT fk_info_calcul_moyennes_classe_structure_enseignement FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_modele_appreciation_professeur_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY modele_appreciation_professeur
    ADD CONSTRAINT fk_modele_appreciation_professeur_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_note_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_note_evaluation; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_evaluation FOREIGN KEY (evaluation_id) REFERENCES evaluation(id) ON DELETE CASCADE;


--
-- Name: fk_note_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- Name: fk_note_textuelle_annee_scolaire; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY note_textuelle
    ADD CONSTRAINT fk_note_textuelle_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_note_textuelle_etablissement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY note_textuelle
    ADD CONSTRAINT fk_note_textuelle_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_rel_evaluation_periode_evaluation; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT fk_rel_evaluation_periode_evaluation FOREIGN KEY (evaluation_id) REFERENCES evaluation(id) ON DELETE CASCADE;


--
-- Name: fk_rel_evaluation_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT fk_rel_evaluation_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- Name: fk_resultat_classe_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_enseignement_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_resultat_classe_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT fk_resultat_classe_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT fk_resultat_classe_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_resultat_classe_service_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_service_periode_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_service FOREIGN KEY (service_id) REFERENCES ent.service(id);


--
-- Name: fk_resultat_classe_service_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_resultat_classe_sous_service_periode_resultat_classe_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT fk_resultat_classe_sous_service_periode_resultat_classe_service FOREIGN KEY (resultat_classe_service_periode_id) REFERENCES resultat_classe_service_periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_sous_service_periode_sous_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT fk_resultat_classe_sous_service_periode_sous_service FOREIGN KEY (sous_service_id) REFERENCES ent.sous_service(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_enseignement_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_resultat_eleve_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- Name: fk_resultat_eleve_enseignement_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- Name: fk_resultat_eleve_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_autorite FOREIGN KEY (autorite_eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_resultat_eleve_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- Name: fk_resultat_eleve_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_service_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_autorite FOREIGN KEY (autorite_eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_resultat_eleve_service_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- Name: fk_resultat_eleve_service_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_service_periode_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_service FOREIGN KEY (service_id) REFERENCES ent.service(id);


--
-- Name: fk_resultat_eleve_sous_service_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- Name: fk_resultat_eleve_sous_service_periode_resultat_eleve_service_p; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_resultat_eleve_service_p FOREIGN KEY (resultat_eleve_service_periode_id) REFERENCES resultat_eleve_service_periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_sous_service_periode_sous_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_sous_service FOREIGN KEY (sous_service_id) REFERENCES ent.sous_service(id) ON DELETE CASCADE;


SET search_path = entnotes_2011_2012, pg_catalog;

--
-- Name: fk_appreciation_classe_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent_2011_2012.enseignement(id);


--
-- Name: fk_appreciation_classe_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id);


--
-- Name: fk_appreciation_classe_enseignement_periode_structure_enseignem; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_structure_enseignem FOREIGN KEY (classe_id) REFERENCES ent_2011_2012.structure_enseignement(id);


--
-- Name: fk_appreciation_eleve_enseignement_periode_eleve; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_eleve FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appreciation_eleve_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent_2011_2012.enseignement(id);


--
-- Name: fk_appreciation_eleve_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id);


--
-- Name: fk_appreciation_eleve_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appreciation_eleve_periode_avis_conseil_de_classe; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_avis_conseil_de_classe FOREIGN KEY (avis_conseil_de_classe_id) REFERENCES entnotes.avis_conseil_de_classe(id);


--
-- Name: fk_appreciation_eleve_periode_avis_orientation; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_avis_orientation FOREIGN KEY (avis_orientation_id) REFERENCES entnotes.avis_orientation(id);


--
-- Name: fk_appreciation_eleve_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id);


--
-- Name: fk_brevet_epreuve_brevet_serie; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT fk_brevet_epreuve_brevet_serie FOREIGN KEY (serie_id) REFERENCES brevet_serie(id);


--
-- Name: fk_brevet_epreuve_exclusive; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT fk_brevet_epreuve_exclusive FOREIGN KEY (epreuve_exclusive_id) REFERENCES brevet_epreuve(id);


--
-- Name: fk_brevet_fiche_annee_scolaire; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT fk_brevet_fiche_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_brevet_fiche_personne; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT fk_brevet_fiche_personne FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- Name: fk_brevet_note_brevet_epreuve; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_brevet_epreuve FOREIGN KEY (epreuve_id) REFERENCES brevet_epreuve(id);


--
-- Name: fk_brevet_note_brevet_fiche; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_brevet_fiche FOREIGN KEY (fiche_id) REFERENCES brevet_fiche(id);


--
-- Name: fk_brevet_note_brevet_note_valeur_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_brevet_note_valeur_textuelle FOREIGN KEY (valeur_textuelle_id) REFERENCES entnotes.brevet_note_valeur_textuelle(id);


--
-- Name: fk_brevet_note_matiere; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_matiere FOREIGN KEY (matiere_id) REFERENCES ent_2011_2012.matiere(id);


--
-- Name: fk_brevet_rel_epreuve_matiere_brevet_epreuve; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT fk_brevet_rel_epreuve_matiere_brevet_epreuve FOREIGN KEY (epreuve_id) REFERENCES brevet_epreuve(id);


--
-- Name: fk_brevet_rel_epreuve_matiere_matiere; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT fk_brevet_rel_epreuve_matiere_matiere FOREIGN KEY (matiere_id) REFERENCES ent_2011_2012.matiere(id);


--
-- Name: fk_brevet_rel_epreuve_note_valeur_textuelle_epreuve; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT fk_brevet_rel_epreuve_note_valeur_textuelle_epreuve FOREIGN KEY (brevet_epreuve_id) REFERENCES brevet_epreuve(id);


--
-- Name: fk_brevet_rel_epreuve_note_valeur_textuelle_valeur_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT fk_brevet_rel_epreuve_note_valeur_textuelle_valeur_textuelle FOREIGN KEY (valeur_textuelle_id) REFERENCES entnotes.brevet_note_valeur_textuelle(id);


--
-- Name: fk_brevet_serie_annee_scolaire_id; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_serie
    ADD CONSTRAINT fk_brevet_serie_annee_scolaire_id FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_epreuve_matieres_a_heriter; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT fk_epreuve_matieres_a_heriter FOREIGN KEY (epreuve_matieres_a_heriter_id) REFERENCES brevet_epreuve(id);


--
-- Name: fk_evaluation_activite; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_activite FOREIGN KEY (activite_id) REFERENCES entcdt.activite(id);


--
-- Name: fk_evaluation_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent_2011_2012.enseignement(id);


--
-- Name: fk_evaluation_modalite_matiere; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_modalite_matiere FOREIGN KEY (modalite_matiere_id) REFERENCES ent_2011_2012.modalite_matiere(id);


--
-- Name: fk_info_calcul_moyennes_classe_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT fk_info_calcul_moyennes_classe_structure_enseignement FOREIGN KEY (classe_id) REFERENCES ent_2011_2012.structure_enseignement(id);


--
-- Name: fk_note_autorite; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_note_evaluation; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_evaluation FOREIGN KEY (evaluation_id) REFERENCES evaluation(id) ON DELETE CASCADE;


--
-- Name: fk_note_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- Name: fk_note_textuelle_annee_scolaire; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY note_textuelle
    ADD CONSTRAINT fk_note_textuelle_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_note_textuelle_etablissement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY note_textuelle
    ADD CONSTRAINT fk_note_textuelle_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_rel_evaluation_periode_evaluation; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT fk_rel_evaluation_periode_evaluation FOREIGN KEY (evaluation_id) REFERENCES evaluation(id) ON DELETE CASCADE;


--
-- Name: fk_rel_evaluation_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT fk_rel_evaluation_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- Name: fk_resultat_classe_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_enseignement_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent_2011_2012.structure_enseignement(id);


--
-- Name: fk_resultat_classe_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT fk_resultat_classe_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT fk_resultat_classe_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent_2011_2012.structure_enseignement(id);


--
-- Name: fk_resultat_classe_service_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_service_periode_service; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_service FOREIGN KEY (service_id) REFERENCES ent_2011_2012.service(id);


--
-- Name: fk_resultat_classe_service_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent_2011_2012.structure_enseignement(id);


--
-- Name: fk_resultat_classe_sous_service_periode_resultat_classe_service; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT fk_resultat_classe_sous_service_periode_resultat_classe_service FOREIGN KEY (resultat_classe_service_periode_id) REFERENCES resultat_classe_service_periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_sous_service_periode_sous_service; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT fk_resultat_classe_sous_service_periode_sous_service FOREIGN KEY (sous_service_id) REFERENCES ent_2011_2012.sous_service(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_enseignement_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_resultat_eleve_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent_2011_2012.enseignement(id);


--
-- Name: fk_resultat_eleve_enseignement_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- Name: fk_resultat_eleve_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_autorite FOREIGN KEY (autorite_eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_resultat_eleve_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- Name: fk_resultat_eleve_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_service_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_autorite FOREIGN KEY (autorite_eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_resultat_eleve_service_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- Name: fk_resultat_eleve_service_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_service_periode_service; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_service FOREIGN KEY (service_id) REFERENCES ent_2011_2012.service(id);


--
-- Name: fk_resultat_eleve_sous_service_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- Name: fk_resultat_eleve_sous_service_periode_resultat_eleve_service_p; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_resultat_eleve_service_p FOREIGN KEY (resultat_eleve_service_periode_id) REFERENCES resultat_eleve_service_periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_sous_service_periode_sous_service; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_sous_service FOREIGN KEY (sous_service_id) REFERENCES ent_2011_2012.sous_service(id) ON DELETE CASCADE;


SET search_path = enttemps, pg_catalog;

--
-- Name: fk_absence_journee_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT fk_absence_journee_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_absence_journee_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT fk_absence_journee_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_agenda_autorite; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_autorite FOREIGN KEY (enseignant_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_agenda_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id) ON DELETE CASCADE;


--
-- Name: fk_agenda_item; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_item FOREIGN KEY (item_id) REFERENCES securite.item(id);


--
-- Name: fk_agenda_structure_enseignement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_agenda_type_agenda; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_type_agenda FOREIGN KEY (type_agenda_id) REFERENCES type_agenda(id);


--
-- Name: fk_appel_autorite_appelant; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_autorite_appelant FOREIGN KEY (appelant_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appel_autorite_operateur_saisie; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_autorite_operateur_saisie FOREIGN KEY (operateur_saisie_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appel_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id);


--
-- Name: fk_appel_ligne_absence_journee; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_absence_journee FOREIGN KEY (absence_journee_id) REFERENCES absence_journee(id) ON DELETE CASCADE;


--
-- Name: fk_appel_ligne_appel; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_appel FOREIGN KEY (appel_id) REFERENCES appel(id) ON DELETE CASCADE;


--
-- Name: fk_appel_ligne_autorite_eleve; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_autorite_eleve FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appel_ligne_autorite_operateur_saisie; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_autorite_operateur_saisie FOREIGN KEY (operateur_saisie_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appel_ligne_motif; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_motif FOREIGN KEY (motif_id) REFERENCES motif(id);


--
-- Name: fk_appel_ligne_sanction; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_sanction FOREIGN KEY (sanction_id) REFERENCES sanction(id);


--
-- Name: fk_appel_plage_horaire_appel; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT fk_appel_plage_horaire_appel FOREIGN KEY (appel_id) REFERENCES appel(id) ON DELETE CASCADE;


--
-- Name: fk_appel_plage_horaire_plage_horaire; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT fk_appel_plage_horaire_plage_horaire FOREIGN KEY (plage_horaire_id) REFERENCES plage_horaire(id) ON DELETE CASCADE;


--
-- Name: fk_appel_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_date_exclue_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY date_exclue
    ADD CONSTRAINT fk_date_exclue_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_evenement_agenda; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_agenda FOREIGN KEY (agenda_maitre_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- Name: fk_evenement_autorite; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_autorite FOREIGN KEY (auteur_id) REFERENCES securite.autorite(id);


--
-- Name: fk_evenement_enseignement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- Name: fk_evenement_type_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_type_evenement FOREIGN KEY (type_id) REFERENCES type_evenement(id);


--
-- Name: fk_groupe_motif_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT fk_groupe_motif_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_incident_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_incident_lieu_incident; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_lieu_incident FOREIGN KEY (lieu_id) REFERENCES lieu_incident(id);


--
-- Name: fk_incident_preference_etablissement_abscences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_preference_etablissement_abscences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_incident_type_incident; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_type_incident FOREIGN KEY (type_id) REFERENCES type_incident(id);


--
-- Name: fk_lieu_incident_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT fk_lieu_incident_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_motif_groupe_motif; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT fk_motif_groupe_motif FOREIGN KEY (groupe_motif_id) REFERENCES groupe_motif(id) ON DELETE CASCADE;


--
-- Name: fk_partenaire_a_prevenir_incident_incident; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT fk_partenaire_a_prevenir_incident_incident FOREIGN KEY (incident_id) REFERENCES incident(id) ON DELETE CASCADE;


--
-- Name: fk_partenaire_a_prevenir_incident_partenaire_a_prevenir; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT fk_partenaire_a_prevenir_incident_partenaire_a_prevenir FOREIGN KEY (partenaire_a_prevenir_id) REFERENCES partenaire_a_prevenir(id);


--
-- Name: fk_partenaire_a_prevenir_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT fk_partenaire_a_prevenir_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_plage_horaire_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY plage_horaire
    ADD CONSTRAINT fk_plage_horaire_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id) ON DELETE CASCADE;


--
-- Name: fk_preference_etablissement_absences_annee_scolaire; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_preference_etablissement_absences_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_preference_etablissement_absences_item; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_item FOREIGN KEY (param_item_id) REFERENCES securite.item(id);


--
-- Name: fk_preference_utilisateur_agenda_agenda; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY preference_utilisateur_agenda
    ADD CONSTRAINT fk_preference_utilisateur_agenda_agenda FOREIGN KEY (agenda_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- Name: fk_preference_utilisateur_agenda_autorite; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY preference_utilisateur_agenda
    ADD CONSTRAINT fk_preference_utilisateur_agenda_autorite FOREIGN KEY (utilisateur_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_protagoniste_incident_autorite; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_protagoniste_incident_incident; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_incident FOREIGN KEY (incident_id) REFERENCES incident(id) ON DELETE CASCADE;


--
-- Name: fk_protagoniste_incident_qualite_protagoniste; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_qualite_protagoniste FOREIGN KEY (qualite_id) REFERENCES qualite_protagoniste(id);


--
-- Name: fk_punition_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_punition_incident; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_incident FOREIGN KEY (incident_id) REFERENCES incident(id);


--
-- Name: fk_punition_personne_censeur; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_personne_censeur FOREIGN KEY (censeur_id) REFERENCES ent.personne(id);


--
-- Name: fk_punition_personne_eleve; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_personne_eleve FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- Name: fk_punition_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_punition_type_punition; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_type_punition FOREIGN KEY (type_punition_id) REFERENCES type_punition(id);


--
-- Name: fk_qualite_protagoniste_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT fk_qualite_protagoniste_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_rel_agenda_evenement_agenda; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT fk_rel_agenda_evenement_agenda FOREIGN KEY (agenda_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- Name: fk_rel_agenda_evenement_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT fk_rel_agenda_evenement_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_repeter_jour_annee_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY repeter_jour_annee
    ADD CONSTRAINT fk_repeter_jour_annee_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_repeter_jour_mois_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY repeter_jour_mois
    ADD CONSTRAINT fk_repeter_jour_mois_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_repeter_jour_semaine_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY repeter_jour_semaine
    ADD CONSTRAINT fk_repeter_jour_semaine_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_repeter_mois_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY repeter_mois
    ADD CONSTRAINT fk_repeter_mois_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_repeter_semaine_annee_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY repeter_semaine_annee
    ADD CONSTRAINT fk_repeter_semaine_annee_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_sanction_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_sanction_incident; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_incident FOREIGN KEY (incident_id) REFERENCES incident(id);


--
-- Name: fk_sanction_motif; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_motif FOREIGN KEY (motif_id) REFERENCES motif(id);


--
-- Name: fk_sanction_personne_censeur; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_personne_censeur FOREIGN KEY (censeur_id) REFERENCES ent.personne(id);


--
-- Name: fk_sanction_personne_eleve; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_personne_eleve FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- Name: fk_sanction_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_sanction_type_sanction; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_type_sanction FOREIGN KEY (type_sanction_id) REFERENCES type_sanction(id);


--
-- Name: fk_type_incident_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT fk_type_incident_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_type_punition_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT fk_type_punition_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_type_sanction_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT fk_type_sanction_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


SET search_path = enttemps_2011_2012, pg_catalog;

--
-- Name: fk_absence_journee_etablissement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT fk_absence_journee_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_absence_journee_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT fk_absence_journee_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_agenda_autorite; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_autorite FOREIGN KEY (enseignant_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_agenda_etablissement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id) ON DELETE CASCADE;


--
-- Name: fk_agenda_item; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_item FOREIGN KEY (item_id) REFERENCES securite.item(id);


--
-- Name: fk_agenda_structure_enseignement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent_2011_2012.structure_enseignement(id);


--
-- Name: fk_agenda_type_agenda; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_type_agenda FOREIGN KEY (type_agenda_id) REFERENCES enttemps.type_agenda(id);


--
-- Name: fk_appel_autorite_appelant; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_autorite_appelant FOREIGN KEY (appelant_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appel_autorite_operateur_saisie; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_autorite_operateur_saisie FOREIGN KEY (operateur_saisie_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appel_evenement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id);


--
-- Name: fk_appel_ligne_absence_journee; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_absence_journee FOREIGN KEY (absence_journee_id) REFERENCES absence_journee(id) ON DELETE CASCADE;


--
-- Name: fk_appel_ligne_appel; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_appel FOREIGN KEY (appel_id) REFERENCES appel(id) ON DELETE CASCADE;


--
-- Name: fk_appel_ligne_autorite_eleve; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_autorite_eleve FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appel_ligne_autorite_operateur_saisie; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_autorite_operateur_saisie FOREIGN KEY (operateur_saisie_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appel_ligne_motif; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_motif FOREIGN KEY (motif_id) REFERENCES motif(id);


--
-- Name: fk_appel_ligne_sanction; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_sanction FOREIGN KEY (sanction_id) REFERENCES sanction(id);


--
-- Name: fk_appel_plage_horaire_appel; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT fk_appel_plage_horaire_appel FOREIGN KEY (appel_id) REFERENCES appel(id) ON DELETE CASCADE;


--
-- Name: fk_appel_plage_horaire_plage_horaire; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT fk_appel_plage_horaire_plage_horaire FOREIGN KEY (plage_horaire_id) REFERENCES plage_horaire(id) ON DELETE CASCADE;


--
-- Name: fk_appel_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_evenement_agenda; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_agenda FOREIGN KEY (agenda_maitre_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- Name: fk_evenement_autorite; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_autorite FOREIGN KEY (auteur_id) REFERENCES securite.autorite(id);


--
-- Name: fk_evenement_enseignement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent_2011_2012.enseignement(id);


--
-- Name: fk_evenement_type_evenement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_type_evenement FOREIGN KEY (type_id) REFERENCES enttemps.type_evenement(id);


--
-- Name: fk_groupe_motif_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT fk_groupe_motif_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_incident_etablissement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_incident_lieu_incident; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_lieu_incident FOREIGN KEY (lieu_id) REFERENCES lieu_incident(id);


--
-- Name: fk_incident_preference_etablissement_abscences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_preference_etablissement_abscences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_incident_type_incident; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_type_incident FOREIGN KEY (type_id) REFERENCES type_incident(id);


--
-- Name: fk_lieu_incident_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT fk_lieu_incident_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_motif_groupe_motif; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT fk_motif_groupe_motif FOREIGN KEY (groupe_motif_id) REFERENCES groupe_motif(id) ON DELETE CASCADE;


--
-- Name: fk_partenaire_a_prevenir_incident_incident; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT fk_partenaire_a_prevenir_incident_incident FOREIGN KEY (incident_id) REFERENCES incident(id) ON DELETE CASCADE;


--
-- Name: fk_partenaire_a_prevenir_incident_partenaire_a_prevenir; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT fk_partenaire_a_prevenir_incident_partenaire_a_prevenir FOREIGN KEY (partenaire_a_prevenir_id) REFERENCES partenaire_a_prevenir(id);


--
-- Name: fk_partenaire_a_prevenir_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT fk_partenaire_a_prevenir_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_plage_horaire_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY plage_horaire
    ADD CONSTRAINT fk_plage_horaire_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id) ON DELETE CASCADE;


--
-- Name: fk_preference_etablissement_absences_annee_scolaire; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_preference_etablissement_absences_etablissement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_preference_etablissement_absences_item; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_item FOREIGN KEY (param_item_id) REFERENCES securite.item(id);


--
-- Name: fk_protagoniste_incident_autorite; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_protagoniste_incident_incident; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_incident FOREIGN KEY (incident_id) REFERENCES incident(id) ON DELETE CASCADE;


--
-- Name: fk_protagoniste_incident_qualite_protagoniste; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_qualite_protagoniste FOREIGN KEY (qualite_id) REFERENCES qualite_protagoniste(id);


--
-- Name: fk_punition_etablissement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_punition_incident; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_incident FOREIGN KEY (incident_id) REFERENCES incident(id);


--
-- Name: fk_punition_personne_censeur; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_personne_censeur FOREIGN KEY (censeur_id) REFERENCES ent.personne(id);


--
-- Name: fk_punition_personne_eleve; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_personne_eleve FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- Name: fk_punition_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_punition_type_punition; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_type_punition FOREIGN KEY (type_punition_id) REFERENCES type_punition(id);


--
-- Name: fk_qualite_protagoniste_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT fk_qualite_protagoniste_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_rel_agenda_evenement_agenda; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT fk_rel_agenda_evenement_agenda FOREIGN KEY (agenda_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- Name: fk_rel_agenda_evenement_evenement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT fk_rel_agenda_evenement_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_sanction_etablissement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_sanction_incident; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_incident FOREIGN KEY (incident_id) REFERENCES incident(id);


--
-- Name: fk_sanction_motif; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_motif FOREIGN KEY (motif_id) REFERENCES motif(id);


--
-- Name: fk_sanction_personne_censeur; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_personne_censeur FOREIGN KEY (censeur_id) REFERENCES ent.personne(id);


--
-- Name: fk_sanction_personne_eleve; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_personne_eleve FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- Name: fk_sanction_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_sanction_type_sanction; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_type_sanction FOREIGN KEY (type_sanction_id) REFERENCES type_sanction(id);


--
-- Name: fk_type_incident_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT fk_type_incident_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_type_punition_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT fk_type_punition_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- Name: fk_type_sanction_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT fk_type_sanction_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


SET search_path = forum, pg_catalog;

--
-- Name: fk_commentaire_autorite; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY commentaire
    ADD CONSTRAINT fk_commentaire_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_commentaire_discussion; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY commentaire
    ADD CONSTRAINT fk_commentaire_discussion FOREIGN KEY (discussion_id) REFERENCES discussion(id) ON DELETE CASCADE;


--
-- Name: fk_commentaire_etat_commentaire; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY commentaire
    ADD CONSTRAINT fk_commentaire_etat_commentaire FOREIGN KEY (code_etat_commentaire) REFERENCES etat_commentaire(code);


--
-- Name: fk_commentaire_lu_autorite; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY commentaire_lu
    ADD CONSTRAINT fk_commentaire_lu_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_commentaire_lu_commentaire; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY commentaire_lu
    ADD CONSTRAINT fk_commentaire_lu_commentaire FOREIGN KEY (commentaire_id) REFERENCES commentaire(id) ON DELETE CASCADE;


--
-- Name: fk_discussion_autorite; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT fk_discussion_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_discussion_etat_discussion; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT fk_discussion_etat_discussion FOREIGN KEY (code_etat_discussion) REFERENCES etat_discussion(code);


--
-- Name: fk_discussion_item; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT fk_discussion_item FOREIGN KEY (item_cible_id) REFERENCES securite.item(id) ON DELETE CASCADE;


--
-- Name: fk_discussion_type_moderation; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT fk_discussion_type_moderation FOREIGN KEY (code_type_moderation) REFERENCES type_moderation(code);


SET search_path = impression, pg_catalog;

--
-- Name: fk_publipostage_suivi_etablissement; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_publipostage_suivi_personne_operateur; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_personne_operateur FOREIGN KEY (operateur_id) REFERENCES ent.personne(id);


--
-- Name: fk_publipostage_suivi_personne_personne; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_personne_personne FOREIGN KEY (personne_id) REFERENCES ent.personne(id);


--
-- Name: fk_publipostage_suivi_responsable; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_responsable FOREIGN KEY (responsable_id) REFERENCES ent.personne(id);


--
-- Name: fk_publipostage_suivi_sms_fournisseur_etablissement; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_sms_fournisseur_etablissement FOREIGN KEY (sms_fournisseur_etablissement_id) REFERENCES sms_fournisseur_etablissement(id);


--
-- Name: fk_publipostage_suivi_structure_enseignement; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_structure_enseignement FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_publipostage_suivi_template_document; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_template_document FOREIGN KEY (template_document_id) REFERENCES template_document(id) ON DELETE SET NULL;


--
-- Name: fk_publipostage_suivi_template_type_fonctionnalite; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_template_type_fonctionnalite FOREIGN KEY (type_fonctionnalite_id) REFERENCES template_type_fonctionnalite(id);


--
-- Name: fk_sms_fournisseur_etablissement_etablissement; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY sms_fournisseur_etablissement
    ADD CONSTRAINT fk_sms_fournisseur_etablissement_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_sms_fournisseur_etablissement_sms_fournisseur; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY sms_fournisseur_etablissement
    ADD CONSTRAINT fk_sms_fournisseur_etablissement_sms_fournisseur FOREIGN KEY (sms_fournisseur_id) REFERENCES sms_fournisseur(id);


--
-- Name: fk_template_champ_memo_template_document; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_champ_memo
    ADD CONSTRAINT fk_template_champ_memo_template_document FOREIGN KEY (template_document_id) REFERENCES template_document(id);


--
-- Name: fk_template_document_etablissement; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_document
    ADD CONSTRAINT fk_template_document_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_template_document_sous_template_eliot_template_document; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_document_sous_template_eliot
    ADD CONSTRAINT fk_template_document_sous_template_eliot_template_document FOREIGN KEY (template_document_id) REFERENCES template_document(id);


--
-- Name: fk_template_document_sous_template_eliot_template_eliot; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_document_sous_template_eliot
    ADD CONSTRAINT fk_template_document_sous_template_eliot_template_eliot FOREIGN KEY (template_eliot_id) REFERENCES template_eliot(id);


--
-- Name: fk_template_document_template_eliot; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_document
    ADD CONSTRAINT fk_template_document_template_eliot FOREIGN KEY (template_eliot_id) REFERENCES template_eliot(id);


--
-- Name: fk_template_eliot_template_jasper; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT fk_template_eliot_template_jasper FOREIGN KEY (template_jasper_id) REFERENCES template_jasper(id);


--
-- Name: fk_template_eliot_template_type_donnees; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT fk_template_eliot_template_type_donnees FOREIGN KEY (type_donnees_id) REFERENCES template_type_donnees(id);


--
-- Name: fk_template_eliot_template_type_fonctionnalite; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT fk_template_eliot_template_type_fonctionnalite FOREIGN KEY (type_fonctionnalite_id) REFERENCES template_type_fonctionnalite(id);


--
-- Name: fk_template_jasper_template_jasper; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_jasper
    ADD CONSTRAINT fk_template_jasper_template_jasper FOREIGN KEY (sous_template_id) REFERENCES template_jasper(id);


--
-- Name: fk_template_type_fonctionnalite_template_type_fonctionnalite; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_type_fonctionnalite
    ADD CONSTRAINT fk_template_type_fonctionnalite_template_type_fonctionnalite FOREIGN KEY (parent_id) REFERENCES template_type_fonctionnalite(id);


SET search_path = securite, pg_catalog;

--
-- Name: fk_autorisation_autorisation; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT fk_autorisation_autorisation FOREIGN KEY (autorisation_heritee_id) REFERENCES autorisation(id) ON DELETE CASCADE;


--
-- Name: fk_autorisation_autorite; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT fk_autorisation_autorite FOREIGN KEY (autorite_id) REFERENCES autorite(id) ON DELETE CASCADE;


--
-- Name: fk_autorisation_item; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT fk_autorisation_item FOREIGN KEY (item_id) REFERENCES item(id);


--
-- Name: fk_autorite_import; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY autorite
    ADD CONSTRAINT fk_autorite_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- Name: fk_item_import; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY item
    ADD CONSTRAINT fk_item_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- Name: fk_item_item; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY item
    ADD CONSTRAINT fk_item_item FOREIGN KEY (item_parent_id) REFERENCES item(id);


--
-- Name: fk_perimetre_import; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY perimetre
    ADD CONSTRAINT fk_perimetre_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- Name: fk_perimetre_perimetre; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY perimetre
    ADD CONSTRAINT fk_perimetre_perimetre FOREIGN KEY (perimetre_parent_id) REFERENCES perimetre(id);


--
-- Name: fk_perimetre_securite_item; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY perimetre_securite
    ADD CONSTRAINT fk_perimetre_securite_item FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE;


--
-- Name: fk_perimetre_securite_perimetre; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY perimetre_securite
    ADD CONSTRAINT fk_perimetre_securite_perimetre FOREIGN KEY (perimetre_id) REFERENCES perimetre(id);


SET search_path = td, pg_catalog;

--
-- Name: fk_copie_correcteur_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY copie
    ADD CONSTRAINT fk_copie_correcteur_id FOREIGN KEY (correcteur_id) REFERENCES ent.personne(id);


--
-- Name: fk_copie_eleve_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY copie
    ADD CONSTRAINT fk_copie_eleve_id FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- Name: fk_copie_modalite_activite_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY copie
    ADD CONSTRAINT fk_copie_modalite_activite_id FOREIGN KEY (modalite_activite_id) REFERENCES modalite_activite(id);


--
-- Name: fk_copie_sujet_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY copie
    ADD CONSTRAINT fk_copie_sujet_id FOREIGN KEY (sujet_id) REFERENCES sujet(id);


--
-- Name: fk_modalite_activite_enseignant_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_enseignant_id FOREIGN KEY (enseignant_id) REFERENCES ent.personne(id);


--
-- Name: fk_modalite_activite_etablissement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_modalite_activite_groupe_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_groupe_id FOREIGN KEY (groupe_id) REFERENCES ent.groupe_personnes(id);


--
-- Name: fk_modalite_activite_matiere_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_matiere_id FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- Name: fk_modalite_activite_responsable_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_responsable_id FOREIGN KEY (responsable_id) REFERENCES ent.personne(id);


--
-- Name: fk_modalite_activite_structure_enseignement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_structure_enseignement_id FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_modalite_activite_sujet_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_sujet_id FOREIGN KEY (sujet_id) REFERENCES sujet(id);


--
-- Name: fk_question_attachement_attachement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question_attachement
    ADD CONSTRAINT fk_question_attachement_attachement_id FOREIGN KEY (attachement_id) REFERENCES tice.attachement(id);


--
-- Name: fk_question_attachement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_attachement_id FOREIGN KEY (attachement_id) REFERENCES tice.attachement(id);


--
-- Name: fk_question_attachement_question_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question_attachement
    ADD CONSTRAINT fk_question_attachement_question_id FOREIGN KEY (question_id) REFERENCES question(id);


--
-- Name: fk_question_copyrights_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_copyrights_id FOREIGN KEY (copyrights_type_id) REFERENCES tice.copyrights_type(id);


--
-- Name: fk_question_etablissement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_question_exercice_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_exercice_id FOREIGN KEY (exercice_id) REFERENCES sujet(id);


--
-- Name: fk_question_export_format_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question_export
    ADD CONSTRAINT fk_question_export_format_id FOREIGN KEY (format_id) REFERENCES tice.export_format(id);


--
-- Name: fk_question_export_question_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question_export
    ADD CONSTRAINT fk_question_export_question_id FOREIGN KEY (question_id) REFERENCES question(id);


--
-- Name: fk_question_matiere_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_matiere_id FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- Name: fk_question_niveau_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_niveau_id FOREIGN KEY (niveau_id) REFERENCES ent.niveau(id);


--
-- Name: fk_question_proprietaire_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_proprietaire_id FOREIGN KEY (proprietaire_id) REFERENCES ent.personne(id);


--
-- Name: fk_question_publication_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_publication_id FOREIGN KEY (publication_id) REFERENCES tice.publication(id);


--
-- Name: fk_question_type_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_type_id FOREIGN KEY (type_id) REFERENCES question_type(id);


--
-- Name: fk_reponse_attachement_attachement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY reponse_attachement
    ADD CONSTRAINT fk_reponse_attachement_attachement_id FOREIGN KEY (attachement_id) REFERENCES tice.attachement(id);


--
-- Name: fk_reponse_attachement_reponse_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY reponse_attachement
    ADD CONSTRAINT fk_reponse_attachement_reponse_id FOREIGN KEY (reponse_id) REFERENCES reponse(id);


--
-- Name: fk_reponse_copie_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY reponse
    ADD CONSTRAINT fk_reponse_copie_id FOREIGN KEY (copie_id) REFERENCES copie(id);


--
-- Name: fk_reponse_correcteur_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY reponse
    ADD CONSTRAINT fk_reponse_correcteur_id FOREIGN KEY (correcteur_id) REFERENCES ent.personne(id);


--
-- Name: fk_reponse_eleve_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY reponse
    ADD CONSTRAINT fk_reponse_eleve_id FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- Name: fk_reponse_sujet_question_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY reponse
    ADD CONSTRAINT fk_reponse_sujet_question_id FOREIGN KEY (sujet_question_id) REFERENCES sujet_sequence_questions(id);


--
-- Name: fk_sujet_copyrights_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_copyrights_id FOREIGN KEY (copyrights_type_id) REFERENCES tice.copyrights_type(id);


--
-- Name: fk_sujet_etablissement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_sujet_matiere_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_matiere_id FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- Name: fk_sujet_niveau_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_niveau_id FOREIGN KEY (niveau_id) REFERENCES ent.niveau(id);


--
-- Name: fk_sujet_proprietaire_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_proprietaire_id FOREIGN KEY (proprietaire_id) REFERENCES ent.personne(id);


--
-- Name: fk_sujet_publication_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_publication_id FOREIGN KEY (publication_id) REFERENCES tice.publication(id);


--
-- Name: fk_sujet_sequence_questions_question_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet_sequence_questions
    ADD CONSTRAINT fk_sujet_sequence_questions_question_id FOREIGN KEY (question_id) REFERENCES question(id);


--
-- Name: fk_sujet_sequence_questions_sujet_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet_sequence_questions
    ADD CONSTRAINT fk_sujet_sequence_questions_sujet_id FOREIGN KEY (sujet_id) REFERENCES sujet(id);


--
-- Name: fk_sujet_sujet_type_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_sujet_type_id FOREIGN KEY (sujet_type_id) REFERENCES sujet_type(id);


SET search_path = tice, pg_catalog;

--
-- Name: fk_compte_utilisateur_personne_id; Type: FK CONSTRAINT; Schema: tice; Owner: -
--

ALTER TABLE ONLY compte_utilisateur
    ADD CONSTRAINT fk_compte_utilisateur_personne_id FOREIGN KEY (personne_id) REFERENCES ent.personne(id);


--
-- Name: fk_publication_copyrights_type_id; Type: FK CONSTRAINT; Schema: tice; Owner: -
--

ALTER TABLE ONLY publication
    ADD CONSTRAINT fk_publication_copyrights_type_id FOREIGN KEY (copyrights_type_id) REFERENCES copyrights_type(id);


SET search_path = udt, pg_catalog;

--
-- Name: fk_enseignement_import; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_import FOREIGN KEY (udt_import_id) REFERENCES import(id);


--
-- Name: fk_enseignement_matiere; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_matiere FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- Name: fk_enseignement_personne; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_personne FOREIGN KEY (professeur_id) REFERENCES ent.personne(id);


--
-- Name: fk_enseignement_structure_enseignement; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_evenement_import; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_import FOREIGN KEY (udt_import_id) REFERENCES import(id);


--
-- Name: fk_evenement_matiere; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_matiere FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- Name: fk_evenement_personne; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_personne FOREIGN KEY (professeur_id) REFERENCES ent.personne(id);


--
-- Name: fk_evenement_structure_enseignement; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_import_etablissement; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY import
    ADD CONSTRAINT fk_import_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

-- CF- ne passe pas sur Cloudfoundry
--REVOKE ALL ON SCHEMA public FROM PUBLIC;
--REVOKE ALL ON SCHEMA public FROM postgres;
--GRANT ALL ON SCHEMA public TO postgres;
--GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

SET search_path = public ;


