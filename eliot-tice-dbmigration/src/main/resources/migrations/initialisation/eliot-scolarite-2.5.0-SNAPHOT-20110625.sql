--
-- PostgreSQL database dump
--

-- à faire  avant de lancer  liquibase
--  . supprimer toutes les instructions relatives à databasechangelog*
--  . ajouter la commande drop language if exists plpgsql
--  . mettre des '\' a la fin de chaque ligne d'une fonction terminant par ';'
--  . en dernière ligne ajouter 'SET search_path = public, pg_catalog;' (pour recup databasechangelog)

SET statement_timeout = 0;
-- SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

drop language if exists plpgsql;

--
-- Name: aaf; Type: SCHEMA; Schema: -; Owner: eliot
--

CREATE SCHEMA aaf;


ALTER SCHEMA aaf OWNER TO eliot;

--
-- Name: bascule_annee; Type: SCHEMA; Schema: -; Owner: eliot
--

CREATE SCHEMA bascule_annee;


ALTER SCHEMA bascule_annee OWNER TO eliot;

--
-- Name: ent; Type: SCHEMA; Schema: -; Owner: eliot
--

CREATE SCHEMA ent;


ALTER SCHEMA ent OWNER TO eliot;

--
-- Name: entcdt; Type: SCHEMA; Schema: -; Owner: eliot
--

CREATE SCHEMA entcdt;


ALTER SCHEMA entcdt OWNER TO eliot;

--
-- Name: entnotes; Type: SCHEMA; Schema: -; Owner: eliot
--

CREATE SCHEMA entnotes;


ALTER SCHEMA entnotes OWNER TO eliot;

--
-- Name: enttemps; Type: SCHEMA; Schema: -; Owner: eliot
--

CREATE SCHEMA enttemps;


ALTER SCHEMA enttemps OWNER TO eliot;

--
-- Name: forum; Type: SCHEMA; Schema: -; Owner: eliot
--

CREATE SCHEMA forum;


ALTER SCHEMA forum OWNER TO eliot;

--
-- Name: impression; Type: SCHEMA; Schema: -; Owner: eliot
--

CREATE SCHEMA impression;


ALTER SCHEMA impression OWNER TO eliot;

--
-- Name: securite; Type: SCHEMA; Schema: -; Owner: eliot
--

CREATE SCHEMA securite;


ALTER SCHEMA securite OWNER TO eliot;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = enttemps, pg_catalog;

--
-- Name: agenda_before_insert(); Type: FUNCTION; Schema: enttemps; Owner: eliot
--

CREATE FUNCTION agenda_before_insert() RETURNS "trigger"
    LANGUAGE plpgsql
    AS '
DECLARE
  code_type_agenda varchar(30);  \
  agenda_id bigint;  \

  BEGIN
    select code into code_type_agenda
  from enttemps.type_agenda as ta
  where  ta.id = NEW.type_agenda_id; \

  -- Agenda de type calendrier scolaire
  IF code_type_agenda =''CSE'' THEN
    select agenda_id into agenda_id
    from enttemps.agenda as a
    join enttemps.type_agenda as t on (a.type_agenda_id = t.id)
    where t.code = ''CSE''
    and NEW.etablissement_id = a.etablissement_id; \

    IF FOUND THEN
      RAISE EXCEPTION ''Le calendrier scolaire existe déjà pour cet établissement''; \
    END IF;  \

  ELSE
    --Agenda de type Structure d''enseignement
    IF code_type_agenda =''ETS'' THEN
      select agenda_id into agenda_id
      from enttemps.agenda as a
      join enttemps.type_agenda as t on (a.type_agenda_id = t.id)
      join ent.structure_enseignement as struct on (a.structure_enseignement_id = struct.id)
      where t.code = ''ETS''
      and NEW.structure_enseignement_id = a.structure_enseignement_id; \

    IF FOUND THEN
      RAISE EXCEPTION ''Agenda de structure existe déjà''; \
    END IF; \

    ELSE
      -- Agenda de type enseignant
      IF code_type_agenda =''ETE'' THEN
        select agenda_id into agenda_id
        from enttemps.agenda as a
        join enttemps.type_agenda as t on (a.type_agenda_id = t.id)
        join securite.autorite as aut on (a.enseignant_id = aut.id)
        where t.code = ''ETE''
        and NEW.etablissement_id = a.etablissement_id
        and NEW.enseignant_id = a.enseignant_id; \

        IF FOUND THEN
          RAISE EXCEPTION ''Agenda enseignant existe déjà'';  \
        END IF; \

      END IF;  \
    END IF;  \
  END IF;  \

  RETURN NEW; \
END; \
 ';


ALTER FUNCTION enttemps.agenda_before_insert() OWNER TO eliot;

SET search_path = aaf, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: import; Type: TABLE; Schema: aaf; Owner: eliot; Tablespace: 
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


ALTER TABLE aaf.import OWNER TO eliot;

--
-- Name: import_id_seq; Type: SEQUENCE; Schema: aaf; Owner: eliot
--

CREATE SEQUENCE import_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE aaf.import_id_seq OWNER TO eliot;

--
-- Name: import_id_seq; Type: SEQUENCE SET; Schema: aaf; Owner: eliot
--

SELECT pg_catalog.setval('import_id_seq', 1, false);


--
-- Name: import_verrou; Type: TABLE; Schema: aaf; Owner: eliot; Tablespace: 
--

CREATE TABLE import_verrou (
    id bigint NOT NULL,
    verrou boolean DEFAULT false,
    import_id bigint,
    date_pose_verrou timestamp without time zone
);


ALTER TABLE aaf.import_verrou OWNER TO eliot;

SET search_path = bascule_annee, pg_catalog;

--
-- Name: historique; Type: TABLE; Schema: bascule_annee; Owner: eliot; Tablespace: 
--

CREATE TABLE historique (
    id bigint NOT NULL,
    module character varying(30) NOT NULL,
    traitement character varying(60) NOT NULL,
    etat character varying(10) NOT NULL,
    operateur_id_externe character varying(128) NOT NULL,
    date_debut timestamp with time zone NOT NULL,
    date_fin timestamp with time zone,
    annee_scolaire_code character varying(30) NOT NULL
);


ALTER TABLE bascule_annee.historique OWNER TO eliot;

--
-- Name: historique_id_seq; Type: SEQUENCE; Schema: bascule_annee; Owner: eliot
--

CREATE SEQUENCE historique_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE bascule_annee.historique_id_seq OWNER TO eliot;

--
-- Name: historique_id_seq; Type: SEQUENCE SET; Schema: bascule_annee; Owner: eliot
--

SELECT pg_catalog.setval('historique_id_seq', 1, false);


--
-- Name: verrou; Type: TABLE; Schema: bascule_annee; Owner: eliot; Tablespace: 
--

CREATE TABLE verrou (
    id bigint NOT NULL,
    module character varying(30) NOT NULL,
    operateur_id_externe character varying(128) NOT NULL,
    date_creation timestamp with time zone NOT NULL,
    nom character varying(30) NOT NULL
);


ALTER TABLE bascule_annee.verrou OWNER TO eliot;

--
-- Name: verrou_id_seq; Type: SEQUENCE; Schema: bascule_annee; Owner: eliot
--

CREATE SEQUENCE verrou_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE bascule_annee.verrou_id_seq OWNER TO eliot;

--
-- Name: verrou_id_seq; Type: SEQUENCE SET; Schema: bascule_annee; Owner: eliot
--

SELECT pg_catalog.setval('verrou_id_seq', 1, false);


SET search_path = ent, pg_catalog;

--
-- Name: annee_scolaire; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE annee_scolaire (
    code character varying(30) NOT NULL,
    version integer NOT NULL,
    date_debut date,
    date_fin date,
    annee_en_cours boolean,
    id bigint NOT NULL
);


ALTER TABLE ent.annee_scolaire OWNER TO eliot;

--
-- Name: annee_scolaire_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE annee_scolaire_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.annee_scolaire_id_seq OWNER TO eliot;

--
-- Name: annee_scolaire_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('annee_scolaire_id_seq', 1, false);


--
-- Name: appartenance_groupe_groupe; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE appartenance_groupe_groupe (
    id bigint NOT NULL,
    groupe_personnes_parent_id bigint NOT NULL,
    groupe_personnes_enfant_id bigint NOT NULL
);


ALTER TABLE ent.appartenance_groupe_groupe OWNER TO eliot;

--
-- Name: appartenance_groupe_groupe_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE appartenance_groupe_groupe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.appartenance_groupe_groupe_id_seq OWNER TO eliot;

--
-- Name: appartenance_groupe_groupe_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('appartenance_groupe_groupe_id_seq', 1, false);


--
-- Name: appartenance_personne_groupe; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE appartenance_personne_groupe (
    id bigint NOT NULL,
    personne_id bigint NOT NULL,
    groupe_personnes_id bigint NOT NULL
);


ALTER TABLE ent.appartenance_personne_groupe OWNER TO eliot;

--
-- Name: appartenance_personne_groupe_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE appartenance_personne_groupe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.appartenance_personne_groupe_id_seq OWNER TO eliot;

--
-- Name: appartenance_personne_groupe_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('appartenance_personne_groupe_id_seq', 1, false);


--
-- Name: civilite; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE civilite (
    id bigint NOT NULL,
    libelle character varying(5) NOT NULL
);


ALTER TABLE ent.civilite OWNER TO eliot;

--
-- Name: civilite_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE civilite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.civilite_id_seq OWNER TO eliot;

--
-- Name: civilite_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('civilite_id_seq', 1, false);


--
-- Name: etablissement; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE etablissement (
    id bigint NOT NULL,
    id_externe character varying(128) NOT NULL,
    nom_affichage character varying(1024),
    version integer NOT NULL,
    uai character varying(10),
    version_import_sts integer DEFAULT 0,
    date_import_sts timestamp with time zone,
    code_porteur_ent character varying(10) DEFAULT 'CRIF'::character varying NOT NULL,
    perimetre_id bigint,
    porteur_ent_id bigint,
    etablissement_rattachement_id bigint,
    type_etablissement character varying(128),
    ministere_tutelle character varying(128)
);


ALTER TABLE ent.etablissement OWNER TO eliot;

--
-- Name: etablissement_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE etablissement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.etablissement_id_seq OWNER TO eliot;

--
-- Name: etablissement_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('etablissement_id_seq', 1, false);


--
-- Name: filiere; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE filiere (
    id bigint NOT NULL,
    id_externe character varying(30),
    libelle character varying(50),
    version integer DEFAULT 0 NOT NULL
);


ALTER TABLE ent.filiere OWNER TO eliot;

--
-- Name: filiere_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE filiere_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.filiere_id_seq OWNER TO eliot;

--
-- Name: filiere_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('filiere_id_seq', 1, false);


--
-- Name: fonction; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE fonction (
    id bigint NOT NULL,
    code character varying(32) NOT NULL,
    libelle character varying(255)
);


ALTER TABLE ent.fonction OWNER TO eliot;

--
-- Name: fonction_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE fonction_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.fonction_id_seq OWNER TO eliot;

--
-- Name: fonction_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('fonction_id_seq', 19, true);


--
-- Name: groupe_personnes; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE groupe_personnes (
    id bigint NOT NULL,
    nom character varying(512) NOT NULL,
    virtuel boolean DEFAULT false,
    autorite_id bigint NOT NULL,
    item_id bigint NOT NULL,
    proprietes_scolarite_id bigint
);


ALTER TABLE ent.groupe_personnes OWNER TO eliot;

--
-- Name: groupe_personnes_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE groupe_personnes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.groupe_personnes_id_seq OWNER TO eliot;

--
-- Name: groupe_personnes_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('groupe_personnes_id_seq', 1, false);


--
-- Name: inscription_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE inscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.inscription_id_seq OWNER TO eliot;

--
-- Name: inscription_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('inscription_id_seq', 1, false);


--
-- Name: matiere; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE matiere (
    version integer NOT NULL,
    id bigint NOT NULL,
    id_externe character varying(128),
    libelle_long character varying(255) NOT NULL,
    code_sts character varying(128),
    libelle_court character varying(255),
    code_gestion character varying(255) NOT NULL,
    libelle_edition character varying(255),
    etablissement_id bigint NOT NULL,
    origine character varying(10)
);


ALTER TABLE ent.matiere OWNER TO eliot;

--
-- Name: matiere_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE matiere_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.matiere_id_seq OWNER TO eliot;

--
-- Name: matiere_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('matiere_id_seq', 1, false);


--
-- Name: mef; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE mef (
    id bigint NOT NULL,
    code character varying(32) NOT NULL,
    formation character varying(255),
    specialite character varying(255),
    libelle_long character varying(255),
    libelle_edition character varying(255),
    mefstat11 character(11),
    mefstat4 character(4),
    niveau_id bigint
);


ALTER TABLE ent.mef OWNER TO eliot;

--
-- Name: mef_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE mef_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.mef_id_seq OWNER TO eliot;

--
-- Name: mef_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('mef_id_seq', 1, false);


--
-- Name: modalite_cours; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
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


ALTER TABLE ent.modalite_cours OWNER TO eliot;

--
-- Name: modalite_cours_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE modalite_cours_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.modalite_cours_id_seq OWNER TO eliot;

--
-- Name: modalite_cours_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('modalite_cours_id_seq', 1, false);


--
-- Name: modalite_matiere; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE modalite_matiere (
    id bigint NOT NULL,
    libelle character varying(1024) NOT NULL,
    code character varying(6) NOT NULL,
    etablissement_id bigint NOT NULL,
    version integer NOT NULL
);


ALTER TABLE ent.modalite_matiere OWNER TO eliot;

--
-- Name: modalite_matiere_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE modalite_matiere_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.modalite_matiere_id_seq OWNER TO eliot;

--
-- Name: modalite_matiere_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('modalite_matiere_id_seq', 1, false);


--
-- Name: niveau; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE niveau (
    id bigint NOT NULL,
    code_mefstat4 character(4) NOT NULL,
    libelle_court character varying(128),
    libelle_long character varying(255),
    libelle_edition character varying(255)
);


ALTER TABLE ent.niveau OWNER TO eliot;

--
-- Name: niveau_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE niveau_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.niveau_id_seq OWNER TO eliot;

--
-- Name: niveau_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('niveau_id_seq', 1, false);


--
-- Name: periode; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE periode (
    id bigint NOT NULL,
    type_periode_id integer NOT NULL,
    date_debut date,
    date_fin date,
    date_fin_saisie date,
    date_publication date,
    structure_enseignement_id bigint NOT NULL
);


ALTER TABLE ent.periode OWNER TO eliot;

--
-- Name: periode_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE periode_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.periode_id_seq OWNER TO eliot;

--
-- Name: periode_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('periode_id_seq', 6, true);


--
-- Name: personne; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE personne (
    id bigint NOT NULL,
    autorite_id integer NOT NULL,
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
    regime_id bigint
);


ALTER TABLE ent.personne OWNER TO eliot;

--
-- Name: personne_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE personne_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.personne_id_seq OWNER TO eliot;

--
-- Name: personne_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('personne_id_seq', 1, false);


--
-- Name: personne_proprietes_scolarite; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE personne_proprietes_scolarite (
    id bigint NOT NULL,
    personne_id bigint NOT NULL,
    proprietes_scolarite_id bigint NOT NULL,
    est_active boolean DEFAULT false NOT NULL,
    import_id bigint,
    date_desactivation timestamp without time zone,
    date_debut timestamp without time zone,
    date_fin timestamp without time zone,
    compteur_references integer
);


ALTER TABLE ent.personne_proprietes_scolarite OWNER TO eliot;

--
-- Name: personne_proprietes_scolarite_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE personne_proprietes_scolarite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.personne_proprietes_scolarite_id_seq OWNER TO eliot;

--
-- Name: personne_proprietes_scolarite_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('personne_proprietes_scolarite_id_seq', 1, false);


--
-- Name: porteur_ent; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
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


ALTER TABLE ent.porteur_ent OWNER TO eliot;

--
-- Name: porteur_ent_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE porteur_ent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.porteur_ent_id_seq OWNER TO eliot;

--
-- Name: porteur_ent_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('porteur_ent_id_seq', 1, false);


--
-- Name: preferences_etablissement; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE preferences_etablissement (
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
    logo_etablissement bytea
);


ALTER TABLE ent.preferences_etablissement OWNER TO eliot;

--
-- Name: preferences_etablissement_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE preferences_etablissement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.preferences_etablissement_id_seq OWNER TO eliot;

--
-- Name: preferences_etablissement_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('preferences_etablissement_id_seq', 1, false);


--
-- Name: preferences_utilisateur; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE preferences_utilisateur (
    id bigint NOT NULL,
    utilisateur_id bigint NOT NULL,
    dernier_etablissement_utilise_id bigint
);


ALTER TABLE ent.preferences_utilisateur OWNER TO eliot;

--
-- Name: preferences_utilisateur_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE preferences_utilisateur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.preferences_utilisateur_id_seq OWNER TO eliot;

--
-- Name: preferences_utilisateur_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('preferences_utilisateur_id_seq', 1, false);


--
-- Name: proprietes_scolarite; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE proprietes_scolarite (
    id bigint NOT NULL,
    etablissement_id bigint,
    structure_enseignement_id bigint,
    annee_scolaire_id bigint,
    niveau_id bigint,
    matiere_id bigint,
    mef_id bigint,
    fonction_id bigint,
    responsable_structure_enseignement boolean DEFAULT false,
    porteur_ent_id bigint,
    source_id bigint NOT NULL
);


ALTER TABLE ent.proprietes_scolarite OWNER TO eliot;

--
-- Name: proprietes_scolarite_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE proprietes_scolarite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.proprietes_scolarite_id_seq OWNER TO eliot;

--
-- Name: proprietes_scolarite_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('proprietes_scolarite_id_seq', 1, false);


--
-- Name: regime; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE regime (
    id bigint NOT NULL,
    code character varying(32) NOT NULL
);


ALTER TABLE ent.regime OWNER TO eliot;

--
-- Name: regime_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE regime_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.regime_id_seq OWNER TO eliot;

--
-- Name: regime_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('regime_id_seq', 3, true);


--
-- Name: rel_classe_filiere; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE rel_classe_filiere (
    id_classe bigint NOT NULL,
    id_filiere bigint NOT NULL
);


ALTER TABLE ent.rel_classe_filiere OWNER TO eliot;

--
-- Name: rel_classe_groupe; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE rel_classe_groupe (
    id_classe bigint NOT NULL,
    id_groupe bigint NOT NULL
);


ALTER TABLE ent.rel_classe_groupe OWNER TO eliot;

--
-- Name: rel_enseignant_service; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE rel_enseignant_service (
    id_enseignant integer NOT NULL,
    version integer NOT NULL,
    id_service integer NOT NULL,
    nb_heures double precision,
    version_import_sts integer DEFAULT -1,
    actif boolean DEFAULT true
);


ALTER TABLE ent.rel_enseignant_service OWNER TO eliot;

--
-- Name: rel_periode_service; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
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


ALTER TABLE ent.rel_periode_service OWNER TO eliot;

--
-- Name: rel_periode_service_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE rel_periode_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.rel_periode_service_id_seq OWNER TO eliot;

--
-- Name: rel_periode_service_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('rel_periode_service_id_seq', 1, false);


--
-- Name: responsable_eleve; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE responsable_eleve (
    id bigint NOT NULL,
    responsable_legal integer,
    parent boolean DEFAULT true,
    personne_id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    est_active boolean DEFAULT true,
    import_id bigint,
    date_desactivation timestamp without time zone
);


ALTER TABLE ent.responsable_eleve OWNER TO eliot;

--
-- Name: responsable_eleve_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE responsable_eleve_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.responsable_eleve_id_seq OWNER TO eliot;

--
-- Name: responsable_eleve_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('responsable_eleve_id_seq', 1, false);


--
-- Name: responsable_proprietes_scolarite; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE responsable_proprietes_scolarite (
    id bigint NOT NULL,
    responsable_eleve_id bigint NOT NULL,
    proprietes_scolarite_id bigint NOT NULL,
    est_active boolean DEFAULT true,
    import_id bigint,
    date_desactivation timestamp without time zone
);


ALTER TABLE ent.responsable_proprietes_scolarite OWNER TO eliot;

--
-- Name: responsable_proprietes_scolarite_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE responsable_proprietes_scolarite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.responsable_proprietes_scolarite_id_seq OWNER TO eliot;

--
-- Name: responsable_proprietes_scolarite_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('responsable_proprietes_scolarite_id_seq', 1, false);


--
-- Name: service; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE service (
    id integer NOT NULL,
    version integer NOT NULL,
    nb_heures double precision,
    co_ens boolean,
    libelle_matiere character varying(1024),
    id_modalite_cours bigint,
    id_matiere bigint NOT NULL,
    id_structure_enseignement bigint,
    version_import_sts integer DEFAULT -1,
    actif boolean DEFAULT true,
    origine character varying(10) DEFAULT 'AUTO'::character varying NOT NULL,
    service_principal boolean DEFAULT false NOT NULL
);


ALTER TABLE ent.service OWNER TO eliot;

--
-- Name: services_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.services_id_seq OWNER TO eliot;

--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: ent; Owner: eliot
--

ALTER SEQUENCE services_id_seq OWNED BY service.id;


--
-- Name: services_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('services_id_seq', 1, false);


--
-- Name: signature; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE signature (
    id bigint NOT NULL,
    proprietaire_id bigint NOT NULL,
    version integer NOT NULL,
    titre character varying(150),
    image_signature bytea
);


ALTER TABLE ent.signature OWNER TO eliot;

--
-- Name: signature_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE signature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.signature_id_seq OWNER TO eliot;

--
-- Name: signature_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('signature_id_seq', 1, false);


--
-- Name: source_import; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE source_import (
    id bigint NOT NULL,
    code character varying(30) NOT NULL,
    libelle character varying(30) NOT NULL
);


ALTER TABLE ent.source_import OWNER TO eliot;

--
-- Name: sous_service; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
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


ALTER TABLE ent.sous_service OWNER TO eliot;

--
-- Name: sous_service_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE sous_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.sous_service_id_seq OWNER TO eliot;

--
-- Name: sous_service_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('sous_service_id_seq', 1, false);


--
-- Name: structure_enseignement; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE structure_enseignement (
    id bigint NOT NULL,
    id_externe character varying(128) NOT NULL,
    type character varying(128) NOT NULL,
    version integer NOT NULL,
    etablissement_id bigint NOT NULL,
    id_annee_scolaire bigint NOT NULL,
    type_intervalle character varying(30),
    code character varying(50) NOT NULL,
    version_import_sts integer DEFAULT -1,
    actif boolean DEFAULT true
);


ALTER TABLE ent.structure_enseignement OWNER TO eliot;

--
-- Name: structure_enseignement_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE structure_enseignement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.structure_enseignement_id_seq OWNER TO eliot;

--
-- Name: structure_enseignement_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('structure_enseignement_id_seq', 1, false);


--
-- Name: trace; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE trace (
    id bigint NOT NULL,
    type_element character varying(30) NOT NULL,
    element_id bigint NOT NULL,
    operation character(1) NOT NULL,
    valeur character varying(255),
    auteur_id bigint NOT NULL,
    date_heure_action timestamp with time zone NOT NULL
);


ALTER TABLE ent.trace OWNER TO eliot;

--
-- Name: trace_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE trace_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.trace_id_seq OWNER TO eliot;

--
-- Name: trace_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('trace_id_seq', 1, false);


--
-- Name: type_periode; Type: TABLE; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE TABLE type_periode (
    id integer NOT NULL,
    libelle character varying(50),
    version integer NOT NULL,
    intervalle character varying(5),
    nature character varying(20) NOT NULL,
    etablissement_id bigint
);


ALTER TABLE ent.type_periode OWNER TO eliot;

--
-- Name: type_periode_id_seq; Type: SEQUENCE; Schema: ent; Owner: eliot
--

CREATE SEQUENCE type_periode_id_seq
    INCREMENT BY 7
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE ent.type_periode_id_seq OWNER TO eliot;

--
-- Name: type_periode_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: eliot
--

SELECT pg_catalog.setval('type_periode_id_seq', 5, true);


SET search_path = entcdt, pg_catalog;

--
-- Name: activite; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE activite (
    id integer NOT NULL,
    id_auteur integer NOT NULL,
    id_chapitre integer,
    id_contexte_activite integer,
    id_type_activite integer,
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
    id_cahier_de_textes integer NOT NULL,
    id_item bigint,
    CONSTRAINT check_activite_date_publication CHECK (((date_publication IS NULL) OR ((date_publication IS NOT NULL) AND est_publiee)))
);


ALTER TABLE entcdt.activite OWNER TO eliot;

--
-- Name: activite_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: eliot
--

CREATE SEQUENCE activite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entcdt.activite_id_seq OWNER TO eliot;

--
-- Name: activite_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: eliot
--

SELECT pg_catalog.setval('activite_id_seq', 1, false);


--
-- Name: cahier_de_textes; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE cahier_de_textes (
    id integer NOT NULL,
    id_fichier integer,
    id_service integer,
    nom character varying(255) NOT NULL,
    description text,
    date_creation timestamp without time zone NOT NULL,
    id_item bigint NOT NULL,
    est_vise boolean DEFAULT false,
    annee_scolaire_id bigint,
    droits_incomplets boolean DEFAULT false,
    id_parent_incorporation bigint
);


ALTER TABLE entcdt.cahier_de_textes OWNER TO eliot;

--
-- Name: cahier_de_textes_copie_info_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: eliot
--

CREATE SEQUENCE cahier_de_textes_copie_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entcdt.cahier_de_textes_copie_info_id_seq OWNER TO eliot;

--
-- Name: cahier_de_textes_copie_info_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: eliot
--

SELECT pg_catalog.setval('cahier_de_textes_copie_info_id_seq', 1, false);


--
-- Name: cahier_de_textes_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: eliot
--

CREATE SEQUENCE cahier_de_textes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entcdt.cahier_de_textes_id_seq OWNER TO eliot;

--
-- Name: cahier_de_textes_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: eliot
--

SELECT pg_catalog.setval('cahier_de_textes_id_seq', 1, false);


--
-- Name: chapitre; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE chapitre (
    id integer NOT NULL,
    id_chapitre_parent integer,
    id_auteur integer NOT NULL,
    nom character varying(255) NOT NULL,
    description text,
    ordre integer DEFAULT 0 NOT NULL,
    id_cahier_de_textes integer NOT NULL
);


ALTER TABLE entcdt.chapitre OWNER TO eliot;

--
-- Name: chapitre_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: eliot
--

CREATE SEQUENCE chapitre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entcdt.chapitre_id_seq OWNER TO eliot;

--
-- Name: chapitre_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: eliot
--

SELECT pg_catalog.setval('chapitre_id_seq', 1, false);


--
-- Name: contexte_activite; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE contexte_activite (
    id integer NOT NULL,
    id_proprietaire integer,
    code character varying(5) NOT NULL,
    nom character varying(255) NOT NULL,
    description text
);


ALTER TABLE entcdt.contexte_activite OWNER TO eliot;

--
-- Name: contexte_activite_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: eliot
--

CREATE SEQUENCE contexte_activite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entcdt.contexte_activite_id_seq OWNER TO eliot;

--
-- Name: contexte_activite_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: eliot
--

SELECT pg_catalog.setval('contexte_activite_id_seq', 1, false);


--
-- Name: date_activite; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE date_activite (
    id integer NOT NULL,
    id_activite integer,
    date_activite timestamp without time zone,
    date_echeance timestamp without time zone,
    duree integer,
    element_emploi_du_temps_id bigint
);


ALTER TABLE entcdt.date_activite OWNER TO eliot;

--
-- Name: date_activite_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: eliot
--

CREATE SEQUENCE date_activite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entcdt.date_activite_id_seq OWNER TO eliot;

--
-- Name: date_activite_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: eliot
--

SELECT pg_catalog.setval('date_activite_id_seq', 1, false);


--
-- Name: dossier; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE dossier (
    id integer NOT NULL,
    id_acteur integer NOT NULL,
    nom character varying(255) NOT NULL,
    description text,
    est_defaut boolean DEFAULT false NOT NULL,
    ordre integer
);


ALTER TABLE entcdt.dossier OWNER TO eliot;

--
-- Name: dossier_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: eliot
--

CREATE SEQUENCE dossier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entcdt.dossier_id_seq OWNER TO eliot;

--
-- Name: dossier_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: eliot
--

SELECT pg_catalog.setval('dossier_id_seq', 1, false);


--
-- Name: etat_chapitre; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE etat_chapitre (
    id_chapitre integer NOT NULL,
    id_acteur integer NOT NULL,
    est_ferme boolean DEFAULT false
);


ALTER TABLE entcdt.etat_chapitre OWNER TO eliot;

--
-- Name: etat_dossier; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE etat_dossier (
    id_dossier integer NOT NULL,
    id_acteur integer NOT NULL,
    est_ferme boolean DEFAULT false
);


ALTER TABLE entcdt.etat_dossier OWNER TO eliot;

--
-- Name: fichier; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE fichier (
    id integer NOT NULL,
    nom character varying,
    blob bytea NOT NULL
);


ALTER TABLE entcdt.fichier OWNER TO eliot;

--
-- Name: fichier_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: eliot
--

CREATE SEQUENCE fichier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entcdt.fichier_id_seq OWNER TO eliot;

--
-- Name: fichier_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: eliot
--

SELECT pg_catalog.setval('fichier_id_seq', 1, false);


--
-- Name: rel_activite_acteur; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE rel_activite_acteur (
    id_activite integer NOT NULL,
    id_acteur integer NOT NULL,
    annotation text,
    est_lu boolean DEFAULT false NOT NULL,
    est_termine boolean DEFAULT false NOT NULL,
    est_nouvelle boolean DEFAULT true NOT NULL
);


ALTER TABLE entcdt.rel_activite_acteur OWNER TO eliot;

--
-- Name: rel_cahier_acteur; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE rel_cahier_acteur (
    id_cahier_de_textes integer NOT NULL,
    id_acteur integer NOT NULL,
    sera_notifie boolean DEFAULT true NOT NULL,
    alias_nom character varying(255)
);


ALTER TABLE entcdt.rel_cahier_acteur OWNER TO eliot;

--
-- Name: rel_cahier_groupe; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE rel_cahier_groupe (
    id_cahier_de_textes integer NOT NULL,
    id_groupe integer NOT NULL,
    notification_obligatoire boolean DEFAULT false NOT NULL
);


ALTER TABLE entcdt.rel_cahier_groupe OWNER TO eliot;

--
-- Name: rel_dossier_autorisation_cahier; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE rel_dossier_autorisation_cahier (
    id_dossier integer NOT NULL,
    id_autorisation bigint NOT NULL,
    ordre bigint NOT NULL
);


ALTER TABLE entcdt.rel_dossier_autorisation_cahier OWNER TO eliot;

--
-- Name: ressource; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE ressource (
    id integer NOT NULL,
    id_activite integer NOT NULL,
    id_fichier integer,
    url text,
    ordre integer NOT NULL,
    description text,
    est_publiee boolean DEFAULT false NOT NULL,
    date_publication date,
    CONSTRAINT check_ressource CHECK (((id_fichier IS NOT NULL) OR (url IS NOT NULL)))
);


ALTER TABLE entcdt.ressource OWNER TO eliot;

--
-- Name: ressource_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: eliot
--

CREATE SEQUENCE ressource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entcdt.ressource_id_seq OWNER TO eliot;

--
-- Name: ressource_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: eliot
--

SELECT pg_catalog.setval('ressource_id_seq', 1, false);


--
-- Name: textes_preferences_utilisateur; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE textes_preferences_utilisateur (
    id bigint NOT NULL,
    utilisateur_id bigint NOT NULL,
    date_derniere_notification timestamp with time zone
);


ALTER TABLE entcdt.textes_preferences_utilisateur OWNER TO eliot;

--
-- Name: textes_preferences_utilisateur_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: eliot
--

CREATE SEQUENCE textes_preferences_utilisateur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entcdt.textes_preferences_utilisateur_id_seq OWNER TO eliot;

--
-- Name: textes_preferences_utilisateur_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: eliot
--

SELECT pg_catalog.setval('textes_preferences_utilisateur_id_seq', 1, false);


--
-- Name: type_activite; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE type_activite (
    id integer NOT NULL,
    id_proprietaire integer,
    code character varying(5),
    nom character varying(255) NOT NULL,
    description text,
    degre integer
);


ALTER TABLE entcdt.type_activite OWNER TO eliot;

--
-- Name: type_activite_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: eliot
--

CREATE SEQUENCE type_activite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entcdt.type_activite_id_seq OWNER TO eliot;

--
-- Name: type_activite_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: eliot
--

SELECT pg_catalog.setval('type_activite_id_seq', 1, false);


--
-- Name: visa; Type: TABLE; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE TABLE visa (
    id bigint NOT NULL,
    date_visee timestamp without time zone NOT NULL,
    auteur_personne_id bigint NOT NULL,
    cahier_vise_id bigint NOT NULL,
    commentaire text
);


ALTER TABLE entcdt.visa OWNER TO eliot;

--
-- Name: visa_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: eliot
--

CREATE SEQUENCE visa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entcdt.visa_id_seq OWNER TO eliot;

--
-- Name: visa_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: eliot
--

SELECT pg_catalog.setval('visa_id_seq', 1, false);


SET search_path = entnotes, pg_catalog;

--
-- Name: appreciation_classe_enseignement_periode; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE appreciation_classe_enseignement_periode (
    id bigint NOT NULL,
    classe_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    enseignement_enseignant_id bigint NOT NULL,
    enseignement_service_id bigint NOT NULL,
    appreciation character varying(1024),
    version integer NOT NULL
);


ALTER TABLE entnotes.appreciation_classe_enseignement_periode OWNER TO eliot;

--
-- Name: appreciation_classe_enseignement_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE appreciation_classe_enseignement_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.appreciation_classe_enseignement_periode_id_seq OWNER TO eliot;

--
-- Name: appreciation_classe_enseignement_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('appreciation_classe_enseignement_periode_id_seq', 1, false);


--
-- Name: appreciation_eleve_enseignement_periode; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE appreciation_eleve_enseignement_periode (
    id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    enseignement_enseignant_id bigint NOT NULL,
    enseignement_service_id bigint NOT NULL,
    appreciation character varying(1024),
    version integer NOT NULL
);


ALTER TABLE entnotes.appreciation_eleve_enseignement_periode OWNER TO eliot;

--
-- Name: appreciation_eleve_enseignement_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE appreciation_eleve_enseignement_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.appreciation_eleve_enseignement_periode_id_seq OWNER TO eliot;

--
-- Name: appreciation_eleve_enseignement_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('appreciation_eleve_enseignement_periode_id_seq', 1, false);


--
-- Name: appreciation_eleve_periode; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
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


ALTER TABLE entnotes.appreciation_eleve_periode OWNER TO eliot;

--
-- Name: appreciation_eleve_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE appreciation_eleve_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.appreciation_eleve_periode_id_seq OWNER TO eliot;

--
-- Name: appreciation_eleve_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('appreciation_eleve_periode_id_seq', 1, false);


--
-- Name: avis_conseil_de_classe; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE avis_conseil_de_classe (
    id bigint NOT NULL,
    version integer NOT NULL,
    texte character varying(1024) NOT NULL,
    etablissement_id bigint NOT NULL,
    ordre integer
);


ALTER TABLE entnotes.avis_conseil_de_classe OWNER TO eliot;

--
-- Name: avis_conseil_de_classe_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE avis_conseil_de_classe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.avis_conseil_de_classe_id_seq OWNER TO eliot;

--
-- Name: avis_conseil_de_classe_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('avis_conseil_de_classe_id_seq', 1, false);


--
-- Name: avis_orientation; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE avis_orientation (
    id bigint NOT NULL,
    version integer NOT NULL,
    texte character varying(1024) NOT NULL,
    etablissement_id bigint NOT NULL,
    ordre integer
);


ALTER TABLE entnotes.avis_orientation OWNER TO eliot;

--
-- Name: avis_orientation_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE avis_orientation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.avis_orientation_id_seq OWNER TO eliot;

--
-- Name: avis_orientation_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('avis_orientation_id_seq', 1, false);


--
-- Name: dernier_changement_dans_classe; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE dernier_changement_dans_classe (
    id bigint NOT NULL,
    date_changement timestamp without time zone,
    classe_id bigint NOT NULL
);


ALTER TABLE entnotes.dernier_changement_dans_classe OWNER TO eliot;

--
-- Name: dernier_changement_dans_classe_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE dernier_changement_dans_classe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.dernier_changement_dans_classe_id_seq OWNER TO eliot;

--
-- Name: dernier_changement_dans_classe_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('dernier_changement_dans_classe_id_seq', 1, false);


--
-- Name: dirty_moyenne; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE dirty_moyenne (
    id bigint NOT NULL,
    date_changement timestamp without time zone NOT NULL,
    eleve_id bigint,
    classe_id bigint,
    periode_id bigint NOT NULL,
    service_id bigint,
    enseignement_service_id bigint,
    enseignement_enseignant_id bigint,
    sous_service_id bigint,
    type_moyenne character varying(200) NOT NULL
);


ALTER TABLE entnotes.dirty_moyenne OWNER TO eliot;

--
-- Name: dirty_moyenne_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE dirty_moyenne_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.dirty_moyenne_id_seq OWNER TO eliot;

--
-- Name: dirty_moyenne_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('dirty_moyenne_id_seq', 1, false);


--
-- Name: evaluation; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE evaluation (
    id bigint NOT NULL,
    titre character varying(128) NOT NULL,
    date_evaluation timestamp with time zone NOT NULL,
    description character varying(1024),
    coefficient numeric NOT NULL,
    note_max_possible numeric,
    est_publiable boolean NOT NULL,
    activite_id bigint,
    enseignement_enseignant_id bigint NOT NULL,
    enseignement_service_id bigint NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    date_creation timestamp with time zone DEFAULT now() NOT NULL,
    ordre integer DEFAULT 0 NOT NULL,
    moyenne numeric,
    modalite_matiere_id bigint
);


ALTER TABLE entnotes.evaluation OWNER TO eliot;

--
-- Name: evaluation_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE evaluation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.evaluation_id_seq OWNER TO eliot;

--
-- Name: evaluation_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('evaluation_id_seq', 1, false);


--
-- Name: info_calcul_moyennes_classe; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE info_calcul_moyennes_classe (
    id bigint NOT NULL,
    classe_id bigint NOT NULL,
    calcul_en_cours boolean DEFAULT false NOT NULL,
    date_debut_calcul timestamp without time zone,
    date_fin_calcul timestamp without time zone,
    version integer NOT NULL
);


ALTER TABLE entnotes.info_calcul_moyennes_classe OWNER TO eliot;

--
-- Name: info_calcul_moyennes_classe_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE info_calcul_moyennes_classe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.info_calcul_moyennes_classe_id_seq OWNER TO eliot;

--
-- Name: info_calcul_moyennes_classe_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('info_calcul_moyennes_classe_id_seq', 1, false);


--
-- Name: modele_appreciation; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE modele_appreciation (
    id bigint NOT NULL,
    texte character varying(1024) NOT NULL,
    type character varying(1024) NOT NULL,
    version integer NOT NULL,
    ordre integer
);


ALTER TABLE entnotes.modele_appreciation OWNER TO eliot;

--
-- Name: modele_appreciation_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE modele_appreciation_id_seq
    START WITH 10
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.modele_appreciation_id_seq OWNER TO eliot;

--
-- Name: modele_appreciation_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('modele_appreciation_id_seq', 10, false);


--
-- Name: modele_appreciation_professeur; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE modele_appreciation_professeur (
    id bigint NOT NULL,
    autorite_id bigint NOT NULL,
    texte character varying(1024) NOT NULL,
    version integer NOT NULL
);


ALTER TABLE entnotes.modele_appreciation_professeur OWNER TO eliot;

--
-- Name: modele_appreciation_professeur_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE modele_appreciation_professeur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.modele_appreciation_professeur_id_seq OWNER TO eliot;

--
-- Name: modele_appreciation_professeur_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('modele_appreciation_professeur_id_seq', 1, false);


--
-- Name: note; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE note (
    id bigint NOT NULL,
    valeur_numerique numeric,
    valeur_non_numerique character varying(30),
    appreciation text,
    evaluation_id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    version integer DEFAULT 0 NOT NULL
);


ALTER TABLE entnotes.note OWNER TO eliot;

--
-- Name: note_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.note_id_seq OWNER TO eliot;

--
-- Name: note_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('note_id_seq', 1, false);


--
-- Name: rel_evaluation_periode; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE rel_evaluation_periode (
    evaluation_id bigint NOT NULL,
    periode_id bigint NOT NULL
);


ALTER TABLE entnotes.rel_evaluation_periode OWNER TO eliot;

--
-- Name: resultat_classe_enseignement_periode; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE resultat_classe_enseignement_periode (
    id bigint NOT NULL,
    enseignement_enseignant_id bigint NOT NULL,
    enseignement_service_id bigint NOT NULL,
    structure_enseignement_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    moyenne numeric,
    moyenne_max numeric,
    moyenne_min numeric,
    version integer NOT NULL
);


ALTER TABLE entnotes.resultat_classe_enseignement_periode OWNER TO eliot;

--
-- Name: resultat_classe_enseignement_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE resultat_classe_enseignement_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.resultat_classe_enseignement_periode_id_seq OWNER TO eliot;

--
-- Name: resultat_classe_enseignement_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('resultat_classe_enseignement_periode_id_seq', 1, false);


--
-- Name: resultat_classe_periode; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE resultat_classe_periode (
    id_structure_enseignement bigint NOT NULL,
    id_periode bigint NOT NULL,
    version integer NOT NULL,
    moyenne numeric,
    moyenne_max numeric,
    moyenne_min numeric,
    id bigint NOT NULL
);


ALTER TABLE entnotes.resultat_classe_periode OWNER TO eliot;

--
-- Name: resultat_classe_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE resultat_classe_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.resultat_classe_periode_id_seq OWNER TO eliot;

--
-- Name: resultat_classe_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('resultat_classe_periode_id_seq', 1, false);


--
-- Name: resultat_classe_service_periode; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE resultat_classe_service_periode (
    id_structure_enseignement bigint NOT NULL,
    id_service bigint NOT NULL,
    id_periode bigint NOT NULL,
    version integer NOT NULL,
    id_autorite_enseignant bigint,
    moyenne numeric,
    moyenne_max numeric,
    moyenne_min numeric,
    id bigint NOT NULL
);


ALTER TABLE entnotes.resultat_classe_service_periode OWNER TO eliot;

--
-- Name: resultat_classe_service_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE resultat_classe_service_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.resultat_classe_service_periode_id_seq OWNER TO eliot;

--
-- Name: resultat_classe_service_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('resultat_classe_service_periode_id_seq', 1, false);


--
-- Name: resultat_classe_sous_service_periode; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE resultat_classe_sous_service_periode (
    id bigint NOT NULL,
    moyenne numeric,
    resultat_classe_service_periode_id bigint NOT NULL,
    sous_service_id bigint NOT NULL,
    version bigint NOT NULL,
    moyenne_max numeric,
    moyenne_min numeric
);


ALTER TABLE entnotes.resultat_classe_sous_service_periode OWNER TO eliot;

--
-- Name: resultat_classe_sous_service_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE resultat_classe_sous_service_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.resultat_classe_sous_service_periode_id_seq OWNER TO eliot;

--
-- Name: resultat_classe_sous_service_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('resultat_classe_sous_service_periode_id_seq', 1, false);


--
-- Name: resultat_eleve_enseignement_periode; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE resultat_eleve_enseignement_periode (
    id bigint NOT NULL,
    enseignement_enseignant_id bigint NOT NULL,
    enseignement_service_id bigint NOT NULL,
    periode_id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    moyenne numeric,
    version integer NOT NULL
);


ALTER TABLE entnotes.resultat_eleve_enseignement_periode OWNER TO eliot;

--
-- Name: resultat_eleve_enseignement_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE resultat_eleve_enseignement_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.resultat_eleve_enseignement_periode_id_seq OWNER TO eliot;

--
-- Name: resultat_eleve_enseignement_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('resultat_eleve_enseignement_periode_id_seq', 1, false);


--
-- Name: resultat_eleve_periode; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE resultat_eleve_periode (
    id_autorite_eleve bigint NOT NULL,
    id_periode bigint NOT NULL,
    version integer NOT NULL,
    moyenne numeric,
    id bigint NOT NULL
);


ALTER TABLE entnotes.resultat_eleve_periode OWNER TO eliot;

--
-- Name: resultat_eleve_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE resultat_eleve_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.resultat_eleve_periode_id_seq OWNER TO eliot;

--
-- Name: resultat_eleve_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('resultat_eleve_periode_id_seq', 1, false);


--
-- Name: resultat_eleve_service_periode; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE resultat_eleve_service_periode (
    id_autorite_eleve bigint NOT NULL,
    id_service bigint NOT NULL,
    id_periode bigint NOT NULL,
    version integer NOT NULL,
    id_autorite_enseignant bigint,
    moyenne numeric,
    id bigint NOT NULL
);


ALTER TABLE entnotes.resultat_eleve_service_periode OWNER TO eliot;

--
-- Name: resultat_eleve_service_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE resultat_eleve_service_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.resultat_eleve_service_periode_id_seq OWNER TO eliot;

--
-- Name: resultat_eleve_service_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('resultat_eleve_service_periode_id_seq', 1, false);


--
-- Name: resultat_eleve_sous_service_periode; Type: TABLE; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE TABLE resultat_eleve_sous_service_periode (
    id bigint NOT NULL,
    moyenne numeric,
    resultat_eleve_service_periode_id bigint NOT NULL,
    sous_service_id bigint NOT NULL,
    version bigint NOT NULL
);


ALTER TABLE entnotes.resultat_eleve_sous_service_periode OWNER TO eliot;

--
-- Name: resultat_eleve_sous_service_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: eliot
--

CREATE SEQUENCE resultat_eleve_sous_service_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE entnotes.resultat_eleve_sous_service_periode_id_seq OWNER TO eliot;

--
-- Name: resultat_eleve_sous_service_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: eliot
--

SELECT pg_catalog.setval('resultat_eleve_sous_service_periode_id_seq', 1, false);


SET search_path = enttemps, pg_catalog;

--
-- Name: absence_journee; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE absence_journee (
    id bigint NOT NULL,
    etablissement_id bigint NOT NULL,
    date date NOT NULL
);


ALTER TABLE enttemps.absence_journee OWNER TO eliot;

--
-- Name: absence_journee_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE absence_journee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.absence_journee_id_seq OWNER TO eliot;

--
-- Name: absence_journee_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('absence_journee_id_seq', 1, false);


--
-- Name: agenda; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE agenda (
    id bigint NOT NULL,
    item_id bigint NOT NULL,
    type_agenda_id bigint NOT NULL,
    structure_enseignement_id bigint,
    nom character varying(256) NOT NULL,
    description text,
    date_creation timestamp with time zone NOT NULL,
    date_modification timestamp with time zone NOT NULL,
    etablissement_id bigint,
    enseignant_id bigint,
    droits_incomplets boolean DEFAULT false
);


ALTER TABLE enttemps.agenda OWNER TO eliot;

--
-- Name: agenda_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE agenda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.agenda_id_seq OWNER TO eliot;

--
-- Name: agenda_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('agenda_id_seq', 1, false);


--
-- Name: appel; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE appel (
    id bigint NOT NULL,
    evenement_id bigint NOT NULL,
    appelant_id bigint,
    operateur_saisie_id bigint NOT NULL,
    date_saisie timestamp with time zone NOT NULL,
    valide boolean DEFAULT false,
    date_heure_debut timestamp without time zone NOT NULL,
    date_heure_fin timestamp without time zone NOT NULL
);


ALTER TABLE enttemps.appel OWNER TO eliot;

--
-- Name: appel_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE appel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.appel_id_seq OWNER TO eliot;

--
-- Name: appel_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('appel_id_seq', 1, false);


--
-- Name: appel_ligne; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE appel_ligne (
    id bigint NOT NULL,
    appel_id bigint,
    personne_id bigint NOT NULL,
    motif_id bigint NOT NULL,
    retard boolean DEFAULT false,
    presence boolean DEFAULT true,
    absence_justifiee boolean,
    heure_arrivee timestamp with time zone,
    depart_anticipe boolean DEFAULT false,
    heure_depart timestamp with time zone,
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
    internat boolean DEFAULT false NOT NULL
);


ALTER TABLE enttemps.appel_ligne OWNER TO eliot;

--
-- Name: appel_ligne_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE appel_ligne_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.appel_ligne_id_seq OWNER TO eliot;

--
-- Name: appel_ligne_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('appel_ligne_id_seq', 1, false);


--
-- Name: appel_plage_horaire; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE appel_plage_horaire (
    appel_id bigint NOT NULL,
    plage_horaire_id bigint NOT NULL
);


ALTER TABLE enttemps.appel_plage_horaire OWNER TO eliot;

--
-- Name: calendier_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE calendier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.calendier_id_seq OWNER TO eliot;

--
-- Name: calendier_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('calendier_id_seq', 1, false);


--
-- Name: calendrier; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE calendrier (
    id bigint NOT NULL,
    preferences_etablissement_absences_id bigint NOT NULL,
    jour_semaine_ferie smallint NOT NULL,
    version integer NOT NULL,
    annee_scolaire_id bigint NOT NULL,
    premier_jour date NOT NULL,
    dernier_jour date NOT NULL
);


ALTER TABLE enttemps.calendrier OWNER TO eliot;

--
-- Name: date_exclue; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE date_exclue (
    id bigint NOT NULL,
    date_exclue timestamp with time zone NOT NULL,
    evenement_id bigint NOT NULL
);


ALTER TABLE enttemps.date_exclue OWNER TO eliot;

--
-- Name: date_exclue_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE date_exclue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.date_exclue_id_seq OWNER TO eliot;

--
-- Name: date_exclue_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('date_exclue_id_seq', 1, false);


--
-- Name: element_emploi_du_temps; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE element_emploi_du_temps (
    id bigint NOT NULL,
    evenement_id bigint NOT NULL,
    enseignant_id bigint NOT NULL,
    service_id bigint NOT NULL
);


ALTER TABLE enttemps.element_emploi_du_temps OWNER TO eliot;

--
-- Name: element_emploi_du_temps_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE element_emploi_du_temps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.element_emploi_du_temps_id_seq OWNER TO eliot;

--
-- Name: element_emploi_du_temps_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('element_emploi_du_temps_id_seq', 1, false);


--
-- Name: evenement; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
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
    date_heure_debut timestamp with time zone NOT NULL,
    date_heure_fin timestamp with time zone NOT NULL,
    date_creation timestamp with time zone NOT NULL,
    date_modification timestamp with time zone NOT NULL,
    recurrence boolean,
    frequence character varying,
    intervalle integer,
    date_debut_recurrence date,
    date_fin_recurrence date,
    occurence integer,
    agenda_maitre_id bigint NOT NULL,
    toute_la_journee boolean,
    critere character varying(10),
    enseignement_enseignant_id bigint,
    enseignement_service_id bigint,
    type_id bigint NOT NULL
);


ALTER TABLE enttemps.evenement OWNER TO eliot;

--
-- Name: evenement_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE evenement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.evenement_id_seq OWNER TO eliot;

--
-- Name: evenement_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('evenement_id_seq', 1, false);


--
-- Name: groupe_motif; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE groupe_motif (
    id bigint NOT NULL,
    preferences_etablissement_absences_id bigint NOT NULL,
    libelle character varying(512) NOT NULL,
    modifiable boolean DEFAULT true
);


ALTER TABLE enttemps.groupe_motif OWNER TO eliot;

--
-- Name: groupe_motif_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE groupe_motif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.groupe_motif_id_seq OWNER TO eliot;

--
-- Name: groupe_motif_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('groupe_motif_id_seq', 1, false);


--
-- Name: incident; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE incident (
    id bigint NOT NULL,
    date timestamp with time zone NOT NULL,
    type_id bigint NOT NULL,
    lieu_id bigint NOT NULL,
    description character varying(300),
    etablissement_id bigint NOT NULL,
    gravite smallint NOT NULL
);


ALTER TABLE enttemps.incident OWNER TO eliot;

--
-- Name: incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.incident_id_seq OWNER TO eliot;

--
-- Name: incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('incident_id_seq', 1, false);


--
-- Name: lieu_incident; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE lieu_incident (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preferences_etablissement_id bigint NOT NULL
);


ALTER TABLE enttemps.lieu_incident OWNER TO eliot;

--
-- Name: lieu_incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE lieu_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.lieu_incident_id_seq OWNER TO eliot;

--
-- Name: lieu_incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('lieu_incident_id_seq', 1, false);


--
-- Name: motif; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE motif (
    id bigint NOT NULL,
    libelle character varying(512) NOT NULL,
    couleur character varying(32),
    groupe_motif_id bigint NOT NULL,
    modifiable boolean DEFAULT true
);


ALTER TABLE enttemps.motif OWNER TO eliot;

--
-- Name: motif_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE motif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.motif_id_seq OWNER TO eliot;

--
-- Name: motif_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('motif_id_seq', 1, false);


--
-- Name: partenaire_a_prevenir; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE partenaire_a_prevenir (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preferences_etablissement_id bigint NOT NULL
);


ALTER TABLE enttemps.partenaire_a_prevenir OWNER TO eliot;

--
-- Name: partenaire_a_prevenir_incident; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE partenaire_a_prevenir_incident (
    id bigint NOT NULL,
    incident_id bigint NOT NULL,
    partenaire_a_prevenir_id bigint NOT NULL
);


ALTER TABLE enttemps.partenaire_a_prevenir_incident OWNER TO eliot;

--
-- Name: partenaire_a_prevenir_incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE partenaire_a_prevenir_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.partenaire_a_prevenir_incident_id_seq OWNER TO eliot;

--
-- Name: partenaire_a_prevenir_incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('partenaire_a_prevenir_incident_id_seq', 1, false);


--
-- Name: partenaire_prevenir_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE partenaire_prevenir_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.partenaire_prevenir_id_seq OWNER TO eliot;

--
-- Name: partenaire_prevenir_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('partenaire_prevenir_id_seq', 1, false);


--
-- Name: plage_horaire; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE plage_horaire (
    id bigint NOT NULL,
    preferences_etablissement_absences_id bigint NOT NULL,
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


ALTER TABLE enttemps.plage_horaire OWNER TO eliot;

--
-- Name: plage_horaire_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE plage_horaire_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.plage_horaire_id_seq OWNER TO eliot;

--
-- Name: plage_horaire_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('plage_horaire_id_seq', 1, false);


--
-- Name: preferences_etablissement_absences; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE preferences_etablissement_absences (
    id bigint NOT NULL,
    etablissement_id bigint,
    pas_decompte_absences_retards character varying(10),
    param_item_id bigint,
    version integer,
    autorise_saisie_hors_edt boolean NOT NULL,
    longueur_plage real
);


ALTER TABLE enttemps.preferences_etablissement_absences OWNER TO eliot;

--
-- Name: preferences_etablissement_absences_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE preferences_etablissement_absences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.preferences_etablissement_absences_id_seq OWNER TO eliot;

--
-- Name: preferences_etablissement_absences_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('preferences_etablissement_absences_id_seq', 1, false);


--
-- Name: preferences_utilisateur_agenda; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE preferences_utilisateur_agenda (
    id bigint NOT NULL,
    utilisateur_id bigint NOT NULL,
    agenda_id bigint NOT NULL,
    nom_personnalise character varying(128),
    couleur character varying(32),
    notification boolean NOT NULL
);


ALTER TABLE enttemps.preferences_utilisateur_agenda OWNER TO eliot;

--
-- Name: preferences_utilisateur_agenda_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE preferences_utilisateur_agenda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.preferences_utilisateur_agenda_id_seq OWNER TO eliot;

--
-- Name: preferences_utilisateur_agenda_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('preferences_utilisateur_agenda_id_seq', 1, false);


--
-- Name: protagoniste_incident; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE protagoniste_incident (
    id bigint NOT NULL,
    incident_id bigint NOT NULL,
    autorite_id bigint NOT NULL,
    qualite_id bigint NOT NULL,
    type character varying(10) NOT NULL
);


ALTER TABLE enttemps.protagoniste_incident OWNER TO eliot;

--
-- Name: protagoniste_incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE protagoniste_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.protagoniste_incident_id_seq OWNER TO eliot;

--
-- Name: protagoniste_incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('protagoniste_incident_id_seq', 1, false);


--
-- Name: punition; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
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
    censeur_id bigint
);


ALTER TABLE enttemps.punition OWNER TO eliot;

--
-- Name: punition_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE punition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.punition_id_seq OWNER TO eliot;

--
-- Name: punition_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('punition_id_seq', 1, false);


--
-- Name: qualite_protagoniste; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE qualite_protagoniste (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preferences_etablissement_id bigint NOT NULL
);


ALTER TABLE enttemps.qualite_protagoniste OWNER TO eliot;

--
-- Name: qualite_protagoniste_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE qualite_protagoniste_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.qualite_protagoniste_id_seq OWNER TO eliot;

--
-- Name: qualite_protagoniste_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('qualite_protagoniste_id_seq', 1, false);


--
-- Name: reaction_appel; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE reaction_appel (
    id bigint NOT NULL,
    type_reaction_id bigint NOT NULL,
    appel_ligne_id bigint NOT NULL,
    decisionnaire_id bigint NOT NULL,
    description text NOT NULL
);


ALTER TABLE enttemps.reaction_appel OWNER TO eliot;

--
-- Name: reaction_appel_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE reaction_appel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.reaction_appel_id_seq OWNER TO eliot;

--
-- Name: reaction_appel_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('reaction_appel_id_seq', 1, false);


--
-- Name: rel_agenda_evenement; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE rel_agenda_evenement (
    evenement_id bigint NOT NULL,
    agenda_id bigint NOT NULL,
    id bigint NOT NULL
);


ALTER TABLE enttemps.rel_agenda_evenement OWNER TO eliot;

--
-- Name: rel_agenda_evenement_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE rel_agenda_evenement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.rel_agenda_evenement_id_seq OWNER TO eliot;

--
-- Name: rel_agenda_evenement_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('rel_agenda_evenement_id_seq', 1, false);


--
-- Name: repeter_jour_annee; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE repeter_jour_annee (
    id bigint NOT NULL,
    jour_annee integer NOT NULL,
    evenement_id bigint NOT NULL
);


ALTER TABLE enttemps.repeter_jour_annee OWNER TO eliot;

--
-- Name: repeter_jour_annee_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE repeter_jour_annee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.repeter_jour_annee_id_seq OWNER TO eliot;

--
-- Name: repeter_jour_annee_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('repeter_jour_annee_id_seq', 1, false);


--
-- Name: repeter_jour_mois; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE repeter_jour_mois (
    id bigint NOT NULL,
    jour_mois integer NOT NULL,
    evenement_id bigint NOT NULL
);


ALTER TABLE enttemps.repeter_jour_mois OWNER TO eliot;

--
-- Name: repeter_jour_mois_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE repeter_jour_mois_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.repeter_jour_mois_id_seq OWNER TO eliot;

--
-- Name: repeter_jour_mois_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('repeter_jour_mois_id_seq', 1, false);


--
-- Name: repeter_jour_semaine; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE repeter_jour_semaine (
    id bigint NOT NULL,
    jour integer NOT NULL,
    evenement_id bigint NOT NULL
);


ALTER TABLE enttemps.repeter_jour_semaine OWNER TO eliot;

--
-- Name: repeter_jour_semaine_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE repeter_jour_semaine_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.repeter_jour_semaine_id_seq OWNER TO eliot;

--
-- Name: repeter_jour_semaine_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('repeter_jour_semaine_id_seq', 1, false);


--
-- Name: repeter_mois; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE repeter_mois (
    id bigint NOT NULL,
    mois integer NOT NULL,
    evenement_id bigint NOT NULL
);


ALTER TABLE enttemps.repeter_mois OWNER TO eliot;

--
-- Name: repeter_mois_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE repeter_mois_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.repeter_mois_id_seq OWNER TO eliot;

--
-- Name: repeter_mois_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('repeter_mois_id_seq', 1, false);


--
-- Name: repeter_semaine_annee; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE repeter_semaine_annee (
    id bigint NOT NULL,
    semaine_annee integer NOT NULL,
    evenement_id bigint NOT NULL
);


ALTER TABLE enttemps.repeter_semaine_annee OWNER TO eliot;

--
-- Name: repeter_semaine_annee_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE repeter_semaine_annee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.repeter_semaine_annee_id_seq OWNER TO eliot;

--
-- Name: repeter_semaine_annee_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('repeter_semaine_annee_id_seq', 1, false);


--
-- Name: reservation; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE reservation (
    id bigint NOT NULL,
    evenement_id bigint NOT NULL,
    ressource_reservable_id bigint NOT NULL,
    auteur_id bigint NOT NULL,
    "dateCreation" timestamp with time zone NOT NULL,
    "dateModification" timestamp with time zone NOT NULL
);


ALTER TABLE enttemps.reservation OWNER TO eliot;

--
-- Name: reservation_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE reservation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.reservation_id_seq OWNER TO eliot;

--
-- Name: reservation_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('reservation_id_seq', 1, false);


--
-- Name: ressource_reservable; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE ressource_reservable (
    id bigint NOT NULL,
    type_ressource_reservable_id bigint NOT NULL,
    nom character varying(256) NOT NULL,
    description text
);


ALTER TABLE enttemps.ressource_reservable OWNER TO eliot;

--
-- Name: ressource_reservable_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE ressource_reservable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.ressource_reservable_id_seq OWNER TO eliot;

--
-- Name: ressource_reservable_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('ressource_reservable_id_seq', 1, false);


--
-- Name: sanction; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
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
    etablissement_id bigint NOT NULL
);


ALTER TABLE enttemps.sanction OWNER TO eliot;

--
-- Name: sanction_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE sanction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.sanction_id_seq OWNER TO eliot;

--
-- Name: sanction_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('sanction_id_seq', 1, false);


--
-- Name: type_agenda; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE type_agenda (
    id bigint NOT NULL,
    code character varying(30) NOT NULL,
    libelle character varying(255)
);


ALTER TABLE enttemps.type_agenda OWNER TO eliot;

--
-- Name: type_agenda_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE type_agenda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.type_agenda_id_seq OWNER TO eliot;

--
-- Name: type_agenda_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('type_agenda_id_seq', 1, false);


--
-- Name: type_evenement; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE type_evenement (
    id bigint NOT NULL,
    type character varying(30) NOT NULL
);


ALTER TABLE enttemps.type_evenement OWNER TO eliot;

--
-- Name: type_evenement_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE type_evenement_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.type_evenement_id_seq OWNER TO eliot;

--
-- Name: type_evenement_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('type_evenement_id_seq', 4, true);


--
-- Name: type_incident; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE type_incident (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preferences_etablissement_id bigint NOT NULL
);


ALTER TABLE enttemps.type_incident OWNER TO eliot;

--
-- Name: type_incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE type_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.type_incident_id_seq OWNER TO eliot;

--
-- Name: type_incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('type_incident_id_seq', 1, false);


--
-- Name: type_punition; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE type_punition (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preferences_etablissement_id bigint NOT NULL
);


ALTER TABLE enttemps.type_punition OWNER TO eliot;

--
-- Name: type_punition_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE type_punition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.type_punition_id_seq OWNER TO eliot;

--
-- Name: type_punition_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('type_punition_id_seq', 1, false);


--
-- Name: type_reaction; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE type_reaction (
    id bigint NOT NULL,
    preferences_etablissement_id bigint NOT NULL,
    libelle character varying(512) NOT NULL,
    couleur character varying(32),
    sanction boolean DEFAULT true,
    punition boolean DEFAULT false
);


ALTER TABLE enttemps.type_reaction OWNER TO eliot;

--
-- Name: type_reaction_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE type_reaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.type_reaction_id_seq OWNER TO eliot;

--
-- Name: type_reaction_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('type_reaction_id_seq', 1, false);


--
-- Name: type_ressource_reservable; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE type_ressource_reservable (
    id bigint NOT NULL,
    code character varying(32) NOT NULL,
    libelle character varying(256)
);


ALTER TABLE enttemps.type_ressource_reservable OWNER TO eliot;

--
-- Name: type_ressource_reservable_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE type_ressource_reservable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.type_ressource_reservable_id_seq OWNER TO eliot;

--
-- Name: type_ressource_reservable_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('type_ressource_reservable_id_seq', 1, false);


--
-- Name: type_sanction; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE type_sanction (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preferences_etablissement_id bigint NOT NULL
);


ALTER TABLE enttemps.type_sanction OWNER TO eliot;

--
-- Name: type_sanction_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE type_sanction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.type_sanction_id_seq OWNER TO eliot;

--
-- Name: type_sanction_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('type_sanction_id_seq', 1, false);


--
-- Name: veille_presence; Type: TABLE; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE TABLE veille_presence (
    id bigint NOT NULL,
    preferences_etablissement_id bigint NOT NULL,
    auteur_id bigint NOT NULL,
    motif_id bigint,
    personne_id bigint,
    libelle character varying(512),
    "dateDebut" timestamp with time zone,
    "dateFin" timestamp with time zone
);


ALTER TABLE enttemps.veille_presence OWNER TO eliot;

--
-- Name: veille_presence_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: eliot
--

CREATE SEQUENCE veille_presence_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE enttemps.veille_presence_id_seq OWNER TO eliot;

--
-- Name: veille_presence_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: eliot
--

SELECT pg_catalog.setval('veille_presence_id_seq', 1, false);


SET search_path = forum, pg_catalog;

--
-- Name: commentaire; Type: TABLE; Schema: forum; Owner: eliot; Tablespace: 
--

CREATE TABLE commentaire (
    id integer NOT NULL,
    version integer NOT NULL,
    id_discussion integer NOT NULL,
    id_autorite integer NOT NULL,
    contenu text NOT NULL,
    date_creation timestamp without time zone NOT NULL,
    code_etat_commentaire character varying(10) NOT NULL,
    libelle_auteur character varying(512)
);


ALTER TABLE forum.commentaire OWNER TO eliot;

--
-- Name: commentaire_id_seq; Type: SEQUENCE; Schema: forum; Owner: eliot
--

CREATE SEQUENCE commentaire_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE forum.commentaire_id_seq OWNER TO eliot;

--
-- Name: commentaire_id_seq; Type: SEQUENCE OWNED BY; Schema: forum; Owner: eliot
--

ALTER SEQUENCE commentaire_id_seq OWNED BY commentaire.id;


--
-- Name: commentaire_id_seq; Type: SEQUENCE SET; Schema: forum; Owner: eliot
--

SELECT pg_catalog.setval('commentaire_id_seq', 1, false);


--
-- Name: commentaire_lu; Type: TABLE; Schema: forum; Owner: eliot; Tablespace: 
--

CREATE TABLE commentaire_lu (
    id_commentaire integer NOT NULL,
    version integer NOT NULL,
    id_autorite integer NOT NULL,
    date_lecture timestamp without time zone
);


ALTER TABLE forum.commentaire_lu OWNER TO eliot;

--
-- Name: discussion; Type: TABLE; Schema: forum; Owner: eliot; Tablespace: 
--

CREATE TABLE discussion (
    id integer NOT NULL,
    version integer NOT NULL,
    id_autorite integer NOT NULL,
    code_etat_discussion character varying(10) NOT NULL,
    code_type_moderation character varying(10) NOT NULL,
    libelle character varying(200) NOT NULL,
    date_creation timestamp without time zone NOT NULL,
    id_item_cible bigint NOT NULL
);


ALTER TABLE forum.discussion OWNER TO eliot;

--
-- Name: discussion_id_seq; Type: SEQUENCE; Schema: forum; Owner: eliot
--

CREATE SEQUENCE discussion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE forum.discussion_id_seq OWNER TO eliot;

--
-- Name: discussion_id_seq; Type: SEQUENCE OWNED BY; Schema: forum; Owner: eliot
--

ALTER SEQUENCE discussion_id_seq OWNED BY discussion.id;


--
-- Name: discussion_id_seq; Type: SEQUENCE SET; Schema: forum; Owner: eliot
--

SELECT pg_catalog.setval('discussion_id_seq', 1, false);


--
-- Name: etat_commentaire; Type: TABLE; Schema: forum; Owner: eliot; Tablespace: 
--

CREATE TABLE etat_commentaire (
    code character varying(10) NOT NULL,
    version integer NOT NULL,
    libelle character varying(60) NOT NULL
);


ALTER TABLE forum.etat_commentaire OWNER TO eliot;

--
-- Name: etat_discussion; Type: TABLE; Schema: forum; Owner: eliot; Tablespace: 
--

CREATE TABLE etat_discussion (
    code character varying(10) NOT NULL,
    version integer NOT NULL,
    libelle character varying(60) NOT NULL
);


ALTER TABLE forum.etat_discussion OWNER TO eliot;

--
-- Name: type_moderation; Type: TABLE; Schema: forum; Owner: eliot; Tablespace: 
--

CREATE TABLE type_moderation (
    code character varying(10) NOT NULL,
    version integer NOT NULL,
    libelle character varying(60) NOT NULL
);


ALTER TABLE forum.type_moderation OWNER TO eliot;

SET search_path = impression, pg_catalog;

--
-- Name: publipostage_suivi; Type: TABLE; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE TABLE publipostage_suivi (
    id bigint NOT NULL,
    media smallint,
    periode character varying(256),
    accuse_reception boolean,
    accuse_envoi boolean,
    nom_template character varying(256),
    classe_id bigint,
    personne_id bigint,
    operateur_id bigint,
    template_document_id bigint,
    date_envoi timestamp without time zone,
    version integer NOT NULL
);


ALTER TABLE impression.publipostage_suivi OWNER TO eliot;

--
-- Name: publipostage_suivi_id_seq; Type: SEQUENCE; Schema: impression; Owner: eliot
--

CREATE SEQUENCE publipostage_suivi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE impression.publipostage_suivi_id_seq OWNER TO eliot;

--
-- Name: publipostage_suivi_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: eliot
--

SELECT pg_catalog.setval('publipostage_suivi_id_seq', 1, false);


--
-- Name: template_champ_memo; Type: TABLE; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE TABLE template_champ_memo (
    id bigint NOT NULL,
    champ character varying(256) NOT NULL,
    template text,
    template_document_id bigint
);


ALTER TABLE impression.template_champ_memo OWNER TO eliot;

--
-- Name: template_champ_memo_id_seq; Type: SEQUENCE; Schema: impression; Owner: eliot
--

CREATE SEQUENCE template_champ_memo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE impression.template_champ_memo_id_seq OWNER TO eliot;

--
-- Name: template_champ_memo_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: eliot
--

SELECT pg_catalog.setval('template_champ_memo_id_seq', 1, false);


--
-- Name: template_document; Type: TABLE; Schema: impression; Owner: eliot; Tablespace: 
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
    numero_version integer DEFAULT 0 NOT NULL
);


ALTER TABLE impression.template_document OWNER TO eliot;

--
-- Name: template_document_id_seq; Type: SEQUENCE; Schema: impression; Owner: eliot
--

CREATE SEQUENCE template_document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE impression.template_document_id_seq OWNER TO eliot;

--
-- Name: template_document_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: eliot
--

SELECT pg_catalog.setval('template_document_id_seq', 1, false);


--
-- Name: template_document_sous_template_eliot; Type: TABLE; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE TABLE template_document_sous_template_eliot (
    id bigint NOT NULL,
    param character varying(256),
    template_document_id bigint,
    template_eliot_id bigint
);


ALTER TABLE impression.template_document_sous_template_eliot OWNER TO eliot;

--
-- Name: template_document_sous_template_eliot_id_seq; Type: SEQUENCE; Schema: impression; Owner: eliot
--

CREATE SEQUENCE template_document_sous_template_eliot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE impression.template_document_sous_template_eliot_id_seq OWNER TO eliot;

--
-- Name: template_document_sous_template_eliot_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: eliot
--

SELECT pg_catalog.setval('template_document_sous_template_eliot_id_seq', 1, false);


--
-- Name: template_eliot; Type: TABLE; Schema: impression; Owner: eliot; Tablespace: 
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
    numero_version integer NOT NULL
);


ALTER TABLE impression.template_eliot OWNER TO eliot;

--
-- Name: template_eliot_id_seq; Type: SEQUENCE; Schema: impression; Owner: eliot
--

CREATE SEQUENCE template_eliot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE impression.template_eliot_id_seq OWNER TO eliot;

--
-- Name: template_eliot_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: eliot
--

SELECT pg_catalog.setval('template_eliot_id_seq', 1, false);


--
-- Name: template_jasper; Type: TABLE; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE TABLE template_jasper (
    id bigint NOT NULL,
    jrxml text NOT NULL,
    sous_template_id bigint,
    jasper bytea,
    param character varying(256) NOT NULL,
    template_dynamique_factory_classe character varying(255)
);


ALTER TABLE impression.template_jasper OWNER TO eliot;

--
-- Name: template_jasper_id_seq; Type: SEQUENCE; Schema: impression; Owner: eliot
--

CREATE SEQUENCE template_jasper_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE impression.template_jasper_id_seq OWNER TO eliot;

--
-- Name: template_jasper_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: eliot
--

SELECT pg_catalog.setval('template_jasper_id_seq', 1, false);


--
-- Name: template_type_donnees; Type: TABLE; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE TABLE template_type_donnees (
    id bigint NOT NULL,
    libelle character varying(256) NOT NULL,
    code character varying(32) NOT NULL
);


ALTER TABLE impression.template_type_donnees OWNER TO eliot;

--
-- Name: template_type_donnees_id_seq; Type: SEQUENCE; Schema: impression; Owner: eliot
--

CREATE SEQUENCE template_type_donnees_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE impression.template_type_donnees_id_seq OWNER TO eliot;

--
-- Name: template_type_donnees_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: eliot
--

SELECT pg_catalog.setval('template_type_donnees_id_seq', 7, true);


--
-- Name: template_type_fonctionnalite; Type: TABLE; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE TABLE template_type_fonctionnalite (
    id bigint NOT NULL,
    libelle character varying(256) NOT NULL,
    parent_id bigint,
    code character varying(32) NOT NULL
);


ALTER TABLE impression.template_type_fonctionnalite OWNER TO eliot;

--
-- Name: template_type_fonctionnalite_id_seq; Type: SEQUENCE; Schema: impression; Owner: eliot
--

CREATE SEQUENCE template_type_fonctionnalite_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE impression.template_type_fonctionnalite_id_seq OWNER TO eliot;

--
-- Name: template_type_fonctionnalite_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: eliot
--

SELECT pg_catalog.setval('template_type_fonctionnalite_id_seq', 10, true);




SET search_path = securite, pg_catalog;

--
-- Name: autorisation; Type: TABLE; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE TABLE autorisation (
    id bigint NOT NULL,
    version integer NOT NULL,
    id_item integer,
    id_autorite integer NOT NULL,
    valeur_permissions_explicite integer NOT NULL,
    proprietaire boolean DEFAULT false NOT NULL,
    id_autorisation_heritee bigint
);


ALTER TABLE securite.autorisation OWNER TO eliot;

--
-- Name: autorite; Type: TABLE; Schema: securite; Owner: eliot; Tablespace: 
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
    id_enregistrement_cible bigint,
    academie character varying(128),
    id_sts character varying(128)
);


ALTER TABLE securite.autorite OWNER TO eliot;

--
-- Name: item; Type: TABLE; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE TABLE item (
    id bigint NOT NULL,
    version integer NOT NULL,
    type character varying(128) NOT NULL,
    item_parent_id bigint,
    nom_entite_cible character varying(128),
    id_enregistrement_cible bigint,
    est_active boolean DEFAULT true,
    import_id bigint,
    date_desactivation timestamp without time zone
);


ALTER TABLE securite.item OWNER TO eliot;

--
-- Name: perimetre; Type: TABLE; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE TABLE perimetre (
    id bigint NOT NULL,
    nom_entite_cible character varying(128),
    id_enregistrement_cible bigint,
    est_active boolean DEFAULT true,
    import_id bigint,
    date_desactivation timestamp without time zone,
    perimetre_parent_id bigint
);


ALTER TABLE securite.perimetre OWNER TO eliot;

--
-- Name: perimetre_securite; Type: TABLE; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE TABLE perimetre_securite (
    id bigint NOT NULL,
    item_id bigint NOT NULL,
    perimetre_id bigint NOT NULL
);


ALTER TABLE securite.perimetre_securite OWNER TO eliot;

--
-- Name: permission; Type: TABLE; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE TABLE permission (
    id bigint NOT NULL,
    version integer NOT NULL,
    nom character varying(128) NOT NULL,
    valeur integer NOT NULL
);


ALTER TABLE securite.permission OWNER TO eliot;

--
-- Name: seq_autorisation; Type: SEQUENCE; Schema: securite; Owner: eliot
--

CREATE SEQUENCE seq_autorisation
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE securite.seq_autorisation OWNER TO eliot;

--
-- Name: seq_autorisation; Type: SEQUENCE SET; Schema: securite; Owner: eliot
--

SELECT pg_catalog.setval('seq_autorisation', 1, false);


--
-- Name: seq_autorite; Type: SEQUENCE; Schema: securite; Owner: eliot
--

CREATE SEQUENCE seq_autorite
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE securite.seq_autorite OWNER TO eliot;

--
-- Name: seq_autorite; Type: SEQUENCE SET; Schema: securite; Owner: eliot
--

SELECT pg_catalog.setval('seq_autorite', 1, false);


--
-- Name: seq_item; Type: SEQUENCE; Schema: securite; Owner: eliot
--

CREATE SEQUENCE seq_item
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE securite.seq_item OWNER TO eliot;

--
-- Name: seq_item; Type: SEQUENCE SET; Schema: securite; Owner: eliot
--

SELECT pg_catalog.setval('seq_item', 1, false);


--
-- Name: seq_perimetre; Type: SEQUENCE; Schema: securite; Owner: eliot
--

CREATE SEQUENCE seq_perimetre
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE securite.seq_perimetre OWNER TO eliot;

--
-- Name: seq_perimetre; Type: SEQUENCE SET; Schema: securite; Owner: eliot
--

SELECT pg_catalog.setval('seq_perimetre', 1, false);


--
-- Name: seq_perimetre_securite; Type: SEQUENCE; Schema: securite; Owner: eliot
--

CREATE SEQUENCE seq_perimetre_securite
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE securite.seq_perimetre_securite OWNER TO eliot;

--
-- Name: seq_perimetre_securite; Type: SEQUENCE SET; Schema: securite; Owner: eliot
--

SELECT pg_catalog.setval('seq_perimetre_securite', 1, false);


--
-- Name: seq_permission; Type: SEQUENCE; Schema: securite; Owner: eliot
--

CREATE SEQUENCE seq_permission
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE securite.seq_permission OWNER TO eliot;

--
-- Name: seq_permission; Type: SEQUENCE SET; Schema: securite; Owner: eliot
--

SELECT pg_catalog.setval('seq_permission', 5, true);


SET search_path = ent, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: ent; Owner: eliot
--

ALTER TABLE service ALTER COLUMN id SET DEFAULT nextval('services_id_seq'::regclass);


SET search_path = forum, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: forum; Owner: eliot
--

ALTER TABLE commentaire ALTER COLUMN id SET DEFAULT nextval('commentaire_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: forum; Owner: eliot
--

ALTER TABLE discussion ALTER COLUMN id SET DEFAULT nextval('discussion_id_seq'::regclass);


SET search_path = aaf, pg_catalog;

--
-- Data for Name: import; Type: TABLE DATA; Schema: aaf; Owner: eliot
--



--
-- Data for Name: import_verrou; Type: TABLE DATA; Schema: aaf; Owner: eliot
--



SET search_path = bascule_annee, pg_catalog;

--
-- Data for Name: historique; Type: TABLE DATA; Schema: bascule_annee; Owner: eliot
--



--
-- Data for Name: verrou; Type: TABLE DATA; Schema: bascule_annee; Owner: eliot
--



SET search_path = ent, pg_catalog;

--
-- Data for Name: annee_scolaire; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: appartenance_groupe_groupe; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: appartenance_personne_groupe; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: civilite; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: etablissement; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: filiere; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: fonction; Type: TABLE DATA; Schema: ent; Owner: eliot
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
INSERT INTO fonction (id, code, libelle) VALUES (11, 'CFC', 'CONSEILLER EN FORMATION CONTINUE');
INSERT INTO fonction (id, code, libelle) VALUES (12, 'CTR', 'CHEF DE TRAVAUX');
INSERT INTO fonction (id, code, libelle) VALUES (13, 'ADF', 'PERSONNELS ADMINISTRATIFS');
INSERT INTO fonction (id, code, libelle) VALUES (14, 'ALB', 'LABORATOIRE');
INSERT INTO fonction (id, code, libelle) VALUES (15, 'ASE', 'ASSISTANT ETRANGER');
INSERT INTO fonction (id, code, libelle) VALUES (16, 'LAB', 'PERSONNELS DE LABORATOIRE');
INSERT INTO fonction (id, code, libelle) VALUES (17, 'MDS', 'PERSONNELS MEDICO-SOCIAUX');
INSERT INTO fonction (id, code, libelle) VALUES (18, 'OUV', 'PERSONNELS OUVRIERS ET DE SERVICES');
INSERT INTO fonction (id, code, libelle) VALUES (19, 'SUR', 'SURVEILLANCE');


--
-- Data for Name: groupe_personnes; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: matiere; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: mef; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: modalite_cours; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: modalite_matiere; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: niveau; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: periode; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: personne; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: personne_proprietes_scolarite; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: porteur_ent; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: preferences_etablissement; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: preferences_utilisateur; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: proprietes_scolarite; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: regime; Type: TABLE DATA; Schema: ent; Owner: eliot
--

INSERT INTO regime (id, code) VALUES (1, 'EXTERNAT');
INSERT INTO regime (id, code) VALUES (2, 'DEMI-PENSION');
INSERT INTO regime (id, code) VALUES (3, 'INTERNAT');


--
-- Data for Name: rel_classe_filiere; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: rel_classe_groupe; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: rel_enseignant_service; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: rel_periode_service; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: responsable_eleve; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: responsable_proprietes_scolarite; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: service; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: signature; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: source_import; Type: TABLE DATA; Schema: ent; Owner: eliot
--

INSERT INTO source_import (id, code, libelle) VALUES (1, 'STS', 'STSweb');
INSERT INTO source_import (id, code, libelle) VALUES (2, 'AAF', 'Annuaire Académique Fédérateur');


--
-- Data for Name: sous_service; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: structure_enseignement; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: trace; Type: TABLE DATA; Schema: ent; Owner: eliot
--



--
-- Data for Name: type_periode; Type: TABLE DATA; Schema: ent; Owner: eliot
--

INSERT INTO type_periode (id, libelle, version, intervalle, nature, etablissement_id) VALUES (1, NULL, 0, 'S1', 'NOTATION', NULL);
INSERT INTO type_periode (id, libelle, version, intervalle, nature, etablissement_id) VALUES (2, NULL, 0, 'S2', 'NOTATION', NULL);
INSERT INTO type_periode (id, libelle, version, intervalle, nature, etablissement_id) VALUES (3, NULL, 0, 'T1', 'NOTATION', NULL);
INSERT INTO type_periode (id, libelle, version, intervalle, nature, etablissement_id) VALUES (4, NULL, 0, 'T2', 'NOTATION', NULL);
INSERT INTO type_periode (id, libelle, version, intervalle, nature, etablissement_id) VALUES (5, NULL, 0, 'T3', 'NOTATION', NULL);
INSERT INTO type_periode (id, libelle, version, intervalle, nature, etablissement_id) VALUES (6, NULL, 0, 'ANNEE', 'NOTATION', NULL);


SET search_path = entcdt, pg_catalog;

--
-- Data for Name: activite; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: cahier_de_textes; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: chapitre; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: contexte_activite; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: date_activite; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: dossier; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: etat_chapitre; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: etat_dossier; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: fichier; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: rel_activite_acteur; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: rel_cahier_acteur; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: rel_cahier_groupe; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: rel_dossier_autorisation_cahier; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: ressource; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: textes_preferences_utilisateur; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: type_activite; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



--
-- Data for Name: visa; Type: TABLE DATA; Schema: entcdt; Owner: eliot
--



SET search_path = entnotes, pg_catalog;

--
-- Data for Name: appreciation_classe_enseignement_periode; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: appreciation_eleve_enseignement_periode; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: appreciation_eleve_periode; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: avis_conseil_de_classe; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: avis_orientation; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: dernier_changement_dans_classe; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: dirty_moyenne; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: evaluation; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: info_calcul_moyennes_classe; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: modele_appreciation; Type: TABLE DATA; Schema: entnotes; Owner: eliot
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
-- Data for Name: modele_appreciation_professeur; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: note; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: rel_evaluation_periode; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: resultat_classe_enseignement_periode; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: resultat_classe_periode; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: resultat_classe_service_periode; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: resultat_classe_sous_service_periode; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: resultat_eleve_enseignement_periode; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: resultat_eleve_periode; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: resultat_eleve_service_periode; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



--
-- Data for Name: resultat_eleve_sous_service_periode; Type: TABLE DATA; Schema: entnotes; Owner: eliot
--



SET search_path = enttemps, pg_catalog;

--
-- Data for Name: absence_journee; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: agenda; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: appel; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: appel_ligne; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: appel_plage_horaire; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: calendrier; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: date_exclue; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: element_emploi_du_temps; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: evenement; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: groupe_motif; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: incident; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: lieu_incident; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: motif; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: partenaire_a_prevenir; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: partenaire_a_prevenir_incident; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: plage_horaire; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: preferences_etablissement_absences; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: preferences_utilisateur_agenda; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: protagoniste_incident; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: punition; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: qualite_protagoniste; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: reaction_appel; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: rel_agenda_evenement; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: repeter_jour_annee; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: repeter_jour_mois; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: repeter_jour_semaine; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: repeter_mois; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: repeter_semaine_annee; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: reservation; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: ressource_reservable; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: sanction; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: type_agenda; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: type_evenement; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--

INSERT INTO type_evenement (id, type) VALUES (1, 'SIMPLE');
INSERT INTO type_evenement (id, type) VALUES (2, 'APPEL');
INSERT INTO type_evenement (id, type) VALUES (3, 'JOUR_FERIE');
INSERT INTO type_evenement (id, type) VALUES (4, 'FERMETURE_HEBDO');


--
-- Data for Name: type_incident; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: type_punition; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: type_reaction; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: type_ressource_reservable; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: type_sanction; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



--
-- Data for Name: veille_presence; Type: TABLE DATA; Schema: enttemps; Owner: eliot
--



SET search_path = forum, pg_catalog;

--
-- Data for Name: commentaire; Type: TABLE DATA; Schema: forum; Owner: eliot
--



--
-- Data for Name: commentaire_lu; Type: TABLE DATA; Schema: forum; Owner: eliot
--



--
-- Data for Name: discussion; Type: TABLE DATA; Schema: forum; Owner: eliot
--



--
-- Data for Name: etat_commentaire; Type: TABLE DATA; Schema: forum; Owner: eliot
--



--
-- Data for Name: etat_discussion; Type: TABLE DATA; Schema: forum; Owner: eliot
--



--
-- Data for Name: type_moderation; Type: TABLE DATA; Schema: forum; Owner: eliot
--



SET search_path = impression, pg_catalog;

--
-- Data for Name: publipostage_suivi; Type: TABLE DATA; Schema: impression; Owner: eliot
--



--
-- Data for Name: template_champ_memo; Type: TABLE DATA; Schema: impression; Owner: eliot
--



--
-- Data for Name: template_document; Type: TABLE DATA; Schema: impression; Owner: eliot
--



--
-- Data for Name: template_document_sous_template_eliot; Type: TABLE DATA; Schema: impression; Owner: eliot
--



--
-- Data for Name: template_eliot; Type: TABLE DATA; Schema: impression; Owner: eliot
--



--
-- Data for Name: template_jasper; Type: TABLE DATA; Schema: impression; Owner: eliot
--



--
-- Data for Name: template_type_donnees; Type: TABLE DATA; Schema: impression; Owner: eliot
--

INSERT INTO template_type_donnees (id, libelle, code) VALUES (3, 'Données générales élèves', 'ELEVE_GENE');
INSERT INTO template_type_donnees (id, libelle, code) VALUES (4, 'Données de notes élèves', 'ELEVE_NOTES');
INSERT INTO template_type_donnees (id, libelle, code) VALUES (5, 'Données des absences élèves', 'ELEVE_ABSENCES');
INSERT INTO template_type_donnees (id, libelle, code) VALUES (6, 'Données des retards élèves', 'ELEVE_RETARDS');
INSERT INTO template_type_donnees (id, libelle, code) VALUES (7, 'Données de synthèse de notes de la classe', 'SYNTHESE_CLASSE_NOTES');


--
-- Data for Name: template_type_fonctionnalite; Type: TABLE DATA; Schema: impression; Owner: eliot
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





SET search_path = securite, pg_catalog;

--
-- Data for Name: autorisation; Type: TABLE DATA; Schema: securite; Owner: eliot
--



--
-- Data for Name: autorite; Type: TABLE DATA; Schema: securite; Owner: eliot
--



--
-- Data for Name: item; Type: TABLE DATA; Schema: securite; Owner: eliot
--



--
-- Data for Name: perimetre; Type: TABLE DATA; Schema: securite; Owner: eliot
--



--
-- Data for Name: perimetre_securite; Type: TABLE DATA; Schema: securite; Owner: eliot
--



--
-- Data for Name: permission; Type: TABLE DATA; Schema: securite; Owner: eliot
--

INSERT INTO permission (id, version, nom, valeur) VALUES (1, 1, 'PEUT_CONSULTER_LE_CONTENU', 1);
INSERT INTO permission (id, version, nom, valeur) VALUES (2, 1, 'PEUT_MODIFIER_LE_CONTENU', 2);
INSERT INTO permission (id, version, nom, valeur) VALUES (3, 1, 'PEUT_CONSULTER_LES_PERMISSIONS', 4);
INSERT INTO permission (id, version, nom, valeur) VALUES (4, 1, 'PEUT_MODIFIER_LES_PERMISSIONS', 8);
INSERT INTO permission (id, version, nom, valeur) VALUES (5, 1, 'PEUT_SUPPRIMER', 16);


SET search_path = aaf, pg_catalog;

--
-- Name: pk_import; Type: CONSTRAINT; Schema: aaf; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY import
    ADD CONSTRAINT pk_import PRIMARY KEY (id);


--
-- Name: pk_import_verrou; Type: CONSTRAINT; Schema: aaf; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY import_verrou
    ADD CONSTRAINT pk_import_verrou PRIMARY KEY (id);


SET search_path = bascule_annee, pg_catalog;

--
-- Name: pk_historique; Type: CONSTRAINT; Schema: bascule_annee; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY historique
    ADD CONSTRAINT pk_historique PRIMARY KEY (id);


--
-- Name: pk_verrou; Type: CONSTRAINT; Schema: bascule_annee; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY verrou
    ADD CONSTRAINT pk_verrou PRIMARY KEY (id);


--
-- Name: uk_verrou_nom; Type: CONSTRAINT; Schema: bascule_annee; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY verrou
    ADD CONSTRAINT uk_verrou_nom UNIQUE (nom);


SET search_path = ent, pg_catalog;

--
-- Name: annee_scolaire_pkey; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY annee_scolaire
    ADD CONSTRAINT annee_scolaire_pkey PRIMARY KEY (id);


--
-- Name: fonction_code_key; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY fonction
    ADD CONSTRAINT fonction_code_key UNIQUE (code);


--
-- Name: groupe_personnes_autorite_id_key; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT groupe_personnes_autorite_id_key UNIQUE (autorite_id);


--
-- Name: groupe_personnes_item_id_key; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT groupe_personnes_item_id_key UNIQUE (item_id);


--
-- Name: matiere_pkey; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT matiere_pkey PRIMARY KEY (id);


--
-- Name: mef_code_key; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY mef
    ADD CONSTRAINT mef_code_key UNIQUE (code);


--
-- Name: modalite_cours_pkey; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY modalite_cours
    ADD CONSTRAINT modalite_cours_pkey PRIMARY KEY (id);


--
-- Name: niveau_code_mefstat4_key; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY niveau
    ADD CONSTRAINT niveau_code_mefstat4_key UNIQUE (code_mefstat4);


--
-- Name: pk_appartenance_groupe_groupe; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY appartenance_groupe_groupe
    ADD CONSTRAINT pk_appartenance_groupe_groupe PRIMARY KEY (id);


--
-- Name: pk_appartenance_personne_groupe; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY appartenance_personne_groupe
    ADD CONSTRAINT pk_appartenance_personne_groupe PRIMARY KEY (id);


--
-- Name: pk_civilite; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY civilite
    ADD CONSTRAINT pk_civilite PRIMARY KEY (id);


--
-- Name: pk_ent_service; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY service
    ADD CONSTRAINT pk_ent_service PRIMARY KEY (id);


--
-- Name: pk_etablissement; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT pk_etablissement PRIMARY KEY (id);


--
-- Name: pk_filiere; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY filiere
    ADD CONSTRAINT pk_filiere PRIMARY KEY (id);


--
-- Name: pk_fonction; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY fonction
    ADD CONSTRAINT pk_fonction PRIMARY KEY (id);


--
-- Name: pk_groupe_personnes; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT pk_groupe_personnes PRIMARY KEY (id);


--
-- Name: pk_mef; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY mef
    ADD CONSTRAINT pk_mef PRIMARY KEY (id);


--
-- Name: pk_modalite_matiere; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT pk_modalite_matiere PRIMARY KEY (id);


--
-- Name: pk_niveau; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY niveau
    ADD CONSTRAINT pk_niveau PRIMARY KEY (id);


--
-- Name: pk_periode; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT pk_periode PRIMARY KEY (id);


--
-- Name: pk_personne; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT pk_personne PRIMARY KEY (id);


--
-- Name: pk_personne_proprietes_scolarite; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY personne_proprietes_scolarite
    ADD CONSTRAINT pk_personne_proprietes_scolarite PRIMARY KEY (id);


--
-- Name: pk_porteur_ent; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY porteur_ent
    ADD CONSTRAINT pk_porteur_ent PRIMARY KEY (id);


--
-- Name: pk_preferences_etablissement; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY preferences_etablissement
    ADD CONSTRAINT pk_preferences_etablissement PRIMARY KEY (id);


--
-- Name: pk_preferences_utilisateur; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY preferences_utilisateur
    ADD CONSTRAINT pk_preferences_utilisateur PRIMARY KEY (id);


--
-- Name: pk_proprietes_scolarite; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY proprietes_scolarite
    ADD CONSTRAINT pk_proprietes_scolarite PRIMARY KEY (id);


--
-- Name: pk_regime; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY regime
    ADD CONSTRAINT pk_regime PRIMARY KEY (id);


--
-- Name: pk_rel_classe_filiere; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT pk_rel_classe_filiere PRIMARY KEY (id_classe, id_filiere);


--
-- Name: pk_rel_classe_groupe; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT pk_rel_classe_groupe PRIMARY KEY (id_classe, id_groupe);


--
-- Name: pk_rel_enseignant_service; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY rel_enseignant_service
    ADD CONSTRAINT pk_rel_enseignant_service PRIMARY KEY (id_enseignant, id_service);


--
-- Name: pk_rel_periode_service; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT pk_rel_periode_service PRIMARY KEY (id);


--
-- Name: pk_responsable_eleve; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT pk_responsable_eleve PRIMARY KEY (id);


--
-- Name: pk_responsable_proprietes_scolarite; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY responsable_proprietes_scolarite
    ADD CONSTRAINT pk_responsable_proprietes_scolarite PRIMARY KEY (id);


--
-- Name: pk_signature; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY signature
    ADD CONSTRAINT pk_signature PRIMARY KEY (id);


--
-- Name: pk_source_import; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY source_import
    ADD CONSTRAINT pk_source_import PRIMARY KEY (id);


--
-- Name: pk_sous_service; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT pk_sous_service PRIMARY KEY (id);


--
-- Name: pk_structure_enseignement; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT pk_structure_enseignement PRIMARY KEY (id);


--
-- Name: pk_trace; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY trace
    ADD CONSTRAINT pk_trace PRIMARY KEY (id);


--
-- Name: pk_type_periode; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_periode
    ADD CONSTRAINT pk_type_periode PRIMARY KEY (id);


--
-- Name: porteur_ent_code_key; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY porteur_ent
    ADD CONSTRAINT porteur_ent_code_key UNIQUE (code);


--
-- Name: porteur_ent_perimetre_id_key; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY porteur_ent
    ADD CONSTRAINT porteur_ent_perimetre_id_key UNIQUE (perimetre_id);


--
-- Name: uk_appartenance_groupe_groupe; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY appartenance_groupe_groupe
    ADD CONSTRAINT uk_appartenance_groupe_groupe UNIQUE (groupe_personnes_parent_id, groupe_personnes_enfant_id);


--
-- Name: uk_appartenance_personne_groupe; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY appartenance_personne_groupe
    ADD CONSTRAINT uk_appartenance_personne_groupe UNIQUE (personne_id, groupe_personnes_id);


--
-- Name: uk_civilite_libelle; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY civilite
    ADD CONSTRAINT uk_civilite_libelle UNIQUE (libelle);


--
-- Name: uk_etablissement_code_gestion; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT uk_etablissement_code_gestion UNIQUE (etablissement_id, code_gestion);


--
-- Name: uk_etablissement_id_externe; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT uk_etablissement_id_externe UNIQUE (id_externe);


--
-- Name: uk_personne_autorite_id; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT uk_personne_autorite_id UNIQUE (autorite_id);


--
-- Name: uk_preferences_utilisateur_utilisateur_id; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY preferences_utilisateur
    ADD CONSTRAINT uk_preferences_utilisateur_utilisateur_id UNIQUE (utilisateur_id);


--
-- Name: uk_rel_periode_service; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT uk_rel_periode_service UNIQUE (periode_id, service_id);


--
-- Name: uk_responsable_eleve; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT uk_responsable_eleve UNIQUE (personne_id, eleve_id);


--
-- Name: uk_structure_enseignement_type_periode; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT uk_structure_enseignement_type_periode UNIQUE (structure_enseignement_id, type_periode_id);


--
-- Name: uk_structure_type_etablissement_annee_code; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT uk_structure_type_etablissement_annee_code UNIQUE (type, etablissement_id, id_annee_scolaire, code);


--
-- Name: uk_type_periode_intervalle; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_periode
    ADD CONSTRAINT uk_type_periode_intervalle UNIQUE (intervalle);


--
-- Name: uk_type_periode_libelle_etablissement; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_periode
    ADD CONSTRAINT uk_type_periode_libelle_etablissement UNIQUE (libelle, etablissement_id);


--
-- Name: uq_modalite_matiere_code_etablissement; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT uq_modalite_matiere_code_etablissement UNIQUE (code, etablissement_id);


--
-- Name: uq_sous_service; Type: CONSTRAINT; Schema: ent; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT uq_sous_service UNIQUE (service_id, modalite_matiere_id, type_periode_id);


SET search_path = entcdt, pg_catalog;

--
-- Name: pk_activite; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT pk_activite PRIMARY KEY (id);


--
-- Name: pk_cahier_de_textes; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT pk_cahier_de_textes PRIMARY KEY (id);


--
-- Name: pk_chapitre; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY chapitre
    ADD CONSTRAINT pk_chapitre PRIMARY KEY (id);


--
-- Name: pk_contexte_activite; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY contexte_activite
    ADD CONSTRAINT pk_contexte_activite PRIMARY KEY (id);


--
-- Name: pk_date_activite; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY date_activite
    ADD CONSTRAINT pk_date_activite PRIMARY KEY (id);


--
-- Name: pk_dossier; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY dossier
    ADD CONSTRAINT pk_dossier PRIMARY KEY (id);


--
-- Name: pk_etat_chapitre; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY etat_chapitre
    ADD CONSTRAINT pk_etat_chapitre PRIMARY KEY (id_chapitre, id_acteur);


--
-- Name: pk_etat_dossier; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY etat_dossier
    ADD CONSTRAINT pk_etat_dossier PRIMARY KEY (id_dossier, id_acteur);


--
-- Name: pk_fichier; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY fichier
    ADD CONSTRAINT pk_fichier PRIMARY KEY (id);


--
-- Name: pk_rel_activite_acteur; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY rel_activite_acteur
    ADD CONSTRAINT pk_rel_activite_acteur PRIMARY KEY (id_activite, id_acteur);


--
-- Name: pk_rel_cahier_acteur; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY rel_cahier_acteur
    ADD CONSTRAINT pk_rel_cahier_acteur PRIMARY KEY (id_cahier_de_textes, id_acteur);


--
-- Name: pk_rel_cahier_groupe; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY rel_cahier_groupe
    ADD CONSTRAINT pk_rel_cahier_groupe PRIMARY KEY (id_cahier_de_textes, id_groupe);


--
-- Name: pk_rel_dossier_autorisation_cahier; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY rel_dossier_autorisation_cahier
    ADD CONSTRAINT pk_rel_dossier_autorisation_cahier PRIMARY KEY (id_dossier, id_autorisation);


--
-- Name: pk_ressource; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY ressource
    ADD CONSTRAINT pk_ressource PRIMARY KEY (id);


--
-- Name: pk_textes_preferences_utilisateur; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY textes_preferences_utilisateur
    ADD CONSTRAINT pk_textes_preferences_utilisateur PRIMARY KEY (id);


--
-- Name: pk_type_activite; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_activite
    ADD CONSTRAINT pk_type_activite PRIMARY KEY (id);


--
-- Name: pk_visa; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY visa
    ADD CONSTRAINT pk_visa PRIMARY KEY (id);


--
-- Name: uk_textes_preferences_utilisateur_utilisateur_id; Type: CONSTRAINT; Schema: entcdt; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY textes_preferences_utilisateur
    ADD CONSTRAINT uk_textes_preferences_utilisateur_utilisateur_id UNIQUE (utilisateur_id);


SET search_path = entnotes, pg_catalog;

--
-- Name: pk_appreciation_classe_enseignement_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT pk_appreciation_classe_enseignement_periode PRIMARY KEY (id);


--
-- Name: pk_appreciation_eleve_enseignement_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT pk_appreciation_eleve_enseignement_periode PRIMARY KEY (id);


--
-- Name: pk_appreciation_eleve_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT pk_appreciation_eleve_periode PRIMARY KEY (id);


--
-- Name: pk_avis_conseil_de_classe; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY avis_conseil_de_classe
    ADD CONSTRAINT pk_avis_conseil_de_classe PRIMARY KEY (id);


--
-- Name: pk_avis_orientation; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY avis_orientation
    ADD CONSTRAINT pk_avis_orientation PRIMARY KEY (id);


--
-- Name: pk_dernier_changement_dans_classe; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY dernier_changement_dans_classe
    ADD CONSTRAINT pk_dernier_changement_dans_classe PRIMARY KEY (id);


--
-- Name: pk_dirty_moyenne; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT pk_dirty_moyenne PRIMARY KEY (id);


--
-- Name: pk_evaluation; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT pk_evaluation PRIMARY KEY (id);


--
-- Name: pk_info_calcul_moyennes_classe; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT pk_info_calcul_moyennes_classe PRIMARY KEY (id);


--
-- Name: pk_info_supplementaire; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT pk_info_supplementaire PRIMARY KEY (id);


--
-- Name: pk_modele_appreciation_etablissement; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY modele_appreciation
    ADD CONSTRAINT pk_modele_appreciation_etablissement PRIMARY KEY (id);


--
-- Name: pk_modele_appreciation_professeur; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY modele_appreciation_professeur
    ADD CONSTRAINT pk_modele_appreciation_professeur PRIMARY KEY (id);


--
-- Name: pk_note; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY note
    ADD CONSTRAINT pk_note PRIMARY KEY (id);


--
-- Name: pk_rel_evaluation_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT pk_rel_evaluation_periode PRIMARY KEY (evaluation_id, periode_id);


--
-- Name: pk_resultat_classe_enseignement_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT pk_resultat_classe_enseignement_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_classe_sous_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT pk_resultat_classe_sous_service_periode PRIMARY KEY (id);


--
-- Name: pk_resultat_eleve_sous_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT pk_resultat_eleve_sous_service_periode PRIMARY KEY (id);


--
-- Name: resultat_classe_pkey; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT resultat_classe_pkey PRIMARY KEY (id);


--
-- Name: resultat_classe_service_pkey; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT resultat_classe_service_pkey PRIMARY KEY (id);


--
-- Name: resultat_eleve_pkey; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT resultat_eleve_pkey PRIMARY KEY (id);


--
-- Name: resultat_eleve_service_pkey; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT resultat_eleve_service_pkey PRIMARY KEY (id);


--
-- Name: uk_avis_conseil_de_classe_texte_etablissement; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY avis_conseil_de_classe
    ADD CONSTRAINT uk_avis_conseil_de_classe_texte_etablissement UNIQUE (texte, etablissement_id);


--
-- Name: uk_avis_orientation_texte_etablissement; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY avis_orientation
    ADD CONSTRAINT uk_avis_orientation_texte_etablissement UNIQUE (texte, etablissement_id);


--
-- Name: uk_modele_appreciation_texte_type; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY modele_appreciation
    ADD CONSTRAINT uk_modele_appreciation_texte_type UNIQUE (texte, type);


--
-- Name: uk_note_eleve_evaluation; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY note
    ADD CONSTRAINT uk_note_eleve_evaluation UNIQUE (evaluation_id, eleve_id);


--
-- Name: uk_resultat_classe_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT uk_resultat_classe_periode UNIQUE (id_structure_enseignement, id_periode);


--
-- Name: uk_resultat_classe_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT uk_resultat_classe_service_periode UNIQUE (id_structure_enseignement, id_service, id_periode);


--
-- Name: uk_resultat_eleve_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT uk_resultat_eleve_periode UNIQUE (id_autorite_eleve, id_periode);


--
-- Name: uk_resultat_eleve_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT uk_resultat_eleve_service_periode UNIQUE (id_autorite_eleve, id_service, id_periode);


--
-- Name: uk_resultat_enseignant_classe_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT uk_resultat_enseignant_classe_service_periode UNIQUE (enseignement_enseignant_id, enseignement_service_id, structure_enseignement_id, periode_id);


--
-- Name: uk_resultat_enseignant_eleve_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT uk_resultat_enseignant_eleve_service_periode UNIQUE (enseignement_enseignant_id, enseignement_service_id, eleve_id, periode_id);


--
-- Name: uq_modele_appreciation_professeur_autorite_id_texte; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY modele_appreciation_professeur
    ADD CONSTRAINT uq_modele_appreciation_professeur_autorite_id_texte UNIQUE (autorite_id, texte);


--
-- Name: uq_resultat_classe_sous_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT uq_resultat_classe_sous_service_periode UNIQUE (resultat_classe_service_periode_id, sous_service_id);


--
-- Name: uq_resultat_eleve_sous_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT uq_resultat_eleve_sous_service_periode UNIQUE (resultat_eleve_service_periode_id, sous_service_id);


SET search_path = enttemps, pg_catalog;

--
-- Name: pk_absence_journee; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT pk_absence_journee PRIMARY KEY (id);


--
-- Name: pk_agenda; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT pk_agenda PRIMARY KEY (id);


--
-- Name: pk_appel; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT pk_appel PRIMARY KEY (id);


--
-- Name: pk_appel_ligne; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT pk_appel_ligne PRIMARY KEY (id);


--
-- Name: pk_appel_plage_horaire; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT pk_appel_plage_horaire PRIMARY KEY (appel_id, plage_horaire_id);


--
-- Name: pk_calendrier; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT pk_calendrier PRIMARY KEY (id);


--
-- Name: pk_date_exclue; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY date_exclue
    ADD CONSTRAINT pk_date_exclue PRIMARY KEY (id);


--
-- Name: pk_element_emploi_du_temps; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY element_emploi_du_temps
    ADD CONSTRAINT pk_element_emploi_du_temps PRIMARY KEY (id);


--
-- Name: pk_evenement; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT pk_evenement PRIMARY KEY (id);


--
-- Name: pk_groupe_motif; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT pk_groupe_motif PRIMARY KEY (id);


--
-- Name: pk_incident; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT pk_incident PRIMARY KEY (id);


--
-- Name: pk_lieu_incident; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT pk_lieu_incident PRIMARY KEY (id);


--
-- Name: pk_motif; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT pk_motif PRIMARY KEY (id);


--
-- Name: pk_partenaire_a_prevenir_incident; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT pk_partenaire_a_prevenir_incident PRIMARY KEY (id);


--
-- Name: pk_partenaire_prevenir; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT pk_partenaire_prevenir PRIMARY KEY (id);


--
-- Name: pk_plage_horaire; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY plage_horaire
    ADD CONSTRAINT pk_plage_horaire PRIMARY KEY (id);


--
-- Name: pk_preferences_etablissement_absences; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY preferences_etablissement_absences
    ADD CONSTRAINT pk_preferences_etablissement_absences PRIMARY KEY (id);


--
-- Name: pk_preferences_utilisateur_agenda; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY preferences_utilisateur_agenda
    ADD CONSTRAINT pk_preferences_utilisateur_agenda PRIMARY KEY (id);


--
-- Name: pk_protagoniste_incident; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT pk_protagoniste_incident PRIMARY KEY (id);


--
-- Name: pk_punition; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT pk_punition PRIMARY KEY (id);


--
-- Name: pk_qualite_protagoniste; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT pk_qualite_protagoniste PRIMARY KEY (id);


--
-- Name: pk_reaction_appel; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY reaction_appel
    ADD CONSTRAINT pk_reaction_appel PRIMARY KEY (id);


--
-- Name: pk_rel_agenda_evenement; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT pk_rel_agenda_evenement PRIMARY KEY (id);


--
-- Name: pk_repeter_jour_annee; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY repeter_jour_annee
    ADD CONSTRAINT pk_repeter_jour_annee PRIMARY KEY (id);


--
-- Name: pk_repeter_jour_mois; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY repeter_jour_mois
    ADD CONSTRAINT pk_repeter_jour_mois PRIMARY KEY (id);


--
-- Name: pk_repeter_jour_semaine; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY repeter_jour_semaine
    ADD CONSTRAINT pk_repeter_jour_semaine PRIMARY KEY (id);


--
-- Name: pk_repeter_mois; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY repeter_mois
    ADD CONSTRAINT pk_repeter_mois PRIMARY KEY (id);


--
-- Name: pk_repeter_semaine_annee; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY repeter_semaine_annee
    ADD CONSTRAINT pk_repeter_semaine_annee PRIMARY KEY (id);


--
-- Name: pk_reservation; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY reservation
    ADD CONSTRAINT pk_reservation PRIMARY KEY (id);


--
-- Name: pk_ressource_reservable; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY ressource_reservable
    ADD CONSTRAINT pk_ressource_reservable PRIMARY KEY (id);


--
-- Name: pk_sanction; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT pk_sanction PRIMARY KEY (id);


--
-- Name: pk_type_agenda; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_agenda
    ADD CONSTRAINT pk_type_agenda PRIMARY KEY (id);


--
-- Name: pk_type_evenement; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_evenement
    ADD CONSTRAINT pk_type_evenement PRIMARY KEY (id);


--
-- Name: pk_type_incident; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT pk_type_incident PRIMARY KEY (id);


--
-- Name: pk_type_punition; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT pk_type_punition PRIMARY KEY (id);


--
-- Name: pk_type_reaction; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_reaction
    ADD CONSTRAINT pk_type_reaction PRIMARY KEY (id);


--
-- Name: pk_type_ressource_reservable; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_ressource_reservable
    ADD CONSTRAINT pk_type_ressource_reservable PRIMARY KEY (id);


--
-- Name: pk_type_sanction; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT pk_type_sanction PRIMARY KEY (id);


--
-- Name: pk_veille_presence; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY veille_presence
    ADD CONSTRAINT pk_veille_presence PRIMARY KEY (id);


--
-- Name: uk_absence_journee_etablissement_id_date; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT uk_absence_journee_etablissement_id_date UNIQUE (etablissement_id, date);


--
-- Name: uk_agenda_id_evenement_id; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT uk_agenda_id_evenement_id UNIQUE (evenement_id, agenda_id);


--
-- Name: uk_appel_evenement_id; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT uk_appel_evenement_id UNIQUE (evenement_id);


--
-- Name: uk_appel_ligne_appel_personne; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT uk_appel_ligne_appel_personne UNIQUE (appel_id, personne_id);


--
-- Name: uk_etablissement_id; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY preferences_etablissement_absences
    ADD CONSTRAINT uk_etablissement_id UNIQUE (etablissement_id);


--
-- Name: uk_groupe_motif_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT uk_groupe_motif_id_libelle UNIQUE (groupe_motif_id, libelle);


--
-- Name: uk_lieu_incident_libelle_preferences_etablissement_id; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT uk_lieu_incident_libelle_preferences_etablissement_id UNIQUE (libelle, preferences_etablissement_id);


--
-- Name: uk_partenaire_prevenir_libelle_preferences_etablissement_id; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT uk_partenaire_prevenir_libelle_preferences_etablissement_id UNIQUE (libelle, preferences_etablissement_id);


--
-- Name: uk_preferences_etablissement_absences_annee_scolaire; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT uk_preferences_etablissement_absences_annee_scolaire UNIQUE (preferences_etablissement_absences_id, annee_scolaire_id);


--
-- Name: uk_preferences_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT uk_preferences_etablissement_absences_id_libelle UNIQUE (preferences_etablissement_absences_id, libelle);


--
-- Name: uk_qualite_protagoniste_libelle_preferences_etablissement_id; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT uk_qualite_protagoniste_libelle_preferences_etablissement_id UNIQUE (libelle, preferences_etablissement_id);


--
-- Name: uk_type_incident_libelle_preferences_etablissement_id; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT uk_type_incident_libelle_preferences_etablissement_id UNIQUE (libelle, preferences_etablissement_id);


--
-- Name: uk_type_punition_libelle_preferences_etablissement_id; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT uk_type_punition_libelle_preferences_etablissement_id UNIQUE (libelle, preferences_etablissement_id);


--
-- Name: uk_type_sanction_libelle_preferences_etablissement_id; Type: CONSTRAINT; Schema: enttemps; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT uk_type_sanction_libelle_preferences_etablissement_id UNIQUE (libelle, preferences_etablissement_id);


SET search_path = forum, pg_catalog;

--
-- Name: pk_commentaire_lu; Type: CONSTRAINT; Schema: forum; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY commentaire_lu
    ADD CONSTRAINT pk_commentaire_lu PRIMARY KEY (id_commentaire, id_autorite);


--
-- Name: pk_forum_commentaire; Type: CONSTRAINT; Schema: forum; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY commentaire
    ADD CONSTRAINT pk_forum_commentaire PRIMARY KEY (id);


--
-- Name: pk_forum_discussion; Type: CONSTRAINT; Schema: forum; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT pk_forum_discussion PRIMARY KEY (id);


--
-- Name: pk_forum_etat_commentaire; Type: CONSTRAINT; Schema: forum; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY etat_commentaire
    ADD CONSTRAINT pk_forum_etat_commentaire PRIMARY KEY (code);


--
-- Name: pk_forum_etat_discussion; Type: CONSTRAINT; Schema: forum; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY etat_discussion
    ADD CONSTRAINT pk_forum_etat_discussion PRIMARY KEY (code);


--
-- Name: pk_forum_type_moderation; Type: CONSTRAINT; Schema: forum; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY type_moderation
    ADD CONSTRAINT pk_forum_type_moderation PRIMARY KEY (code);


SET search_path = impression, pg_catalog;

--
-- Name: pk_publipostage_suivi; Type: CONSTRAINT; Schema: impression; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT pk_publipostage_suivi PRIMARY KEY (id);


--
-- Name: pk_template_champ_memo; Type: CONSTRAINT; Schema: impression; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY template_champ_memo
    ADD CONSTRAINT pk_template_champ_memo PRIMARY KEY (id);


--
-- Name: pk_template_eliot; Type: CONSTRAINT; Schema: impression; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT pk_template_eliot PRIMARY KEY (id);


--
-- Name: pk_template_jasper; Type: CONSTRAINT; Schema: impression; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY template_jasper
    ADD CONSTRAINT pk_template_jasper PRIMARY KEY (id);


--
-- Name: pk_template_type_donnees; Type: CONSTRAINT; Schema: impression; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY template_type_donnees
    ADD CONSTRAINT pk_template_type_donnees PRIMARY KEY (id);


--
-- Name: pk_template_type_fonctionnalite; Type: CONSTRAINT; Schema: impression; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY template_type_fonctionnalite
    ADD CONSTRAINT pk_template_type_fonctionnalite PRIMARY KEY (id);


--
-- Name: pk_template_utilisateur; Type: CONSTRAINT; Schema: impression; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY template_document
    ADD CONSTRAINT pk_template_utilisateur PRIMARY KEY (id);


--
-- Name: pk_template_utilisateur_sous_template_eliot; Type: CONSTRAINT; Schema: impression; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY template_document_sous_template_eliot
    ADD CONSTRAINT pk_template_utilisateur_sous_template_eliot PRIMARY KEY (id);


--
-- Name: uk_template_champ_memo_champ_template_doc_id; Type: CONSTRAINT; Schema: impression; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY template_champ_memo
    ADD CONSTRAINT uk_template_champ_memo_champ_template_doc_id UNIQUE (template_document_id, champ);


--
-- Name: uk_template_doc_sous_template_eliot_param_template_doc_id; Type: CONSTRAINT; Schema: impression; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY template_document_sous_template_eliot
    ADD CONSTRAINT uk_template_doc_sous_template_eliot_param_template_doc_id UNIQUE (template_document_id, param);


--
-- Name: ux_template_eliot_code; Type: CONSTRAINT; Schema: impression; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT ux_template_eliot_code UNIQUE (code);





SET search_path = securite, pg_catalog;

--
-- Name: pk_autorisation; Type: CONSTRAINT; Schema: securite; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT pk_autorisation PRIMARY KEY (id);


--
-- Name: pk_autorite; Type: CONSTRAINT; Schema: securite; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY autorite
    ADD CONSTRAINT pk_autorite PRIMARY KEY (id);


--
-- Name: pk_item; Type: CONSTRAINT; Schema: securite; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY item
    ADD CONSTRAINT pk_item PRIMARY KEY (id);


--
-- Name: pk_perimetre; Type: CONSTRAINT; Schema: securite; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY perimetre
    ADD CONSTRAINT pk_perimetre PRIMARY KEY (id);


--
-- Name: pk_perimetre_securite; Type: CONSTRAINT; Schema: securite; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY perimetre_securite
    ADD CONSTRAINT pk_perimetre_securite PRIMARY KEY (id);


--
-- Name: pk_permission; Type: CONSTRAINT; Schema: securite; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY permission
    ADD CONSTRAINT pk_permission PRIMARY KEY (id);


--
-- Name: uk_perimetre_securite; Type: CONSTRAINT; Schema: securite; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY perimetre_securite
    ADD CONSTRAINT uk_perimetre_securite UNIQUE (item_id, perimetre_id);


--
-- Name: unique_id_externe; Type: CONSTRAINT; Schema: securite; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY autorite
    ADD CONSTRAINT unique_id_externe UNIQUE (id_externe, type);


--
-- Name: uq_autorisation_item_autorite; Type: CONSTRAINT; Schema: securite; Owner: eliot; Tablespace: 
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT uq_autorisation_item_autorite UNIQUE (id_item, id_autorite);


SET search_path = ent, pg_catalog;

--
-- Name: idx_appartenance_groupe_groupe_enfant_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_appartenance_groupe_groupe_enfant_id ON appartenance_groupe_groupe USING btree (groupe_personnes_enfant_id);


--
-- Name: idx_appartenance_groupe_groupe_parent_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_appartenance_groupe_groupe_parent_id ON appartenance_groupe_groupe USING btree (groupe_personnes_parent_id);


--
-- Name: idx_appartenance_personne_groupe_groupe_personnes_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_appartenance_personne_groupe_groupe_personnes_id ON appartenance_personne_groupe USING btree (groupe_personnes_id);


--
-- Name: idx_appartenance_personne_groupe_personne_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_appartenance_personne_groupe_personne_id ON appartenance_personne_groupe USING btree (personne_id);


--
-- Name: idx_etablissement_etab_ratt_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_etablissement_etab_ratt_id ON etablissement USING btree (etablissement_rattachement_id);


--
-- Name: idx_etablissement_perimetre_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_etablissement_perimetre_id ON etablissement USING btree (perimetre_id);


--
-- Name: idx_etablissement_porteur_ent_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_etablissement_porteur_ent_id ON etablissement USING btree (porteur_ent_id);


--
-- Name: idx_groupe_personnes_autorite_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_groupe_personnes_autorite_id ON groupe_personnes USING btree (autorite_id);


--
-- Name: idx_groupe_personnes_item_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_groupe_personnes_item_id ON groupe_personnes USING btree (item_id);


--
-- Name: idx_groupe_personnes_proprietes_scolarite_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_groupe_personnes_proprietes_scolarite_id ON groupe_personnes USING btree (proprietes_scolarite_id);


--
-- Name: idx_matiere_code_gestion_etablissement; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_matiere_code_gestion_etablissement ON matiere USING btree (code_gestion, etablissement_id);


--
-- Name: idx_modalite_matiere_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_modalite_matiere_id ON modalite_matiere USING btree (id);


--
-- Name: idx_niveau_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_niveau_id ON mef USING btree (niveau_id);


--
-- Name: idx_personne_autorite_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_personne_autorite_id ON personne USING btree (autorite_id);


--
-- Name: idx_personne_etab_ratt_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_personne_etab_ratt_id ON personne USING btree (etablissement_rattachement_id);


--
-- Name: idx_personne_nom_prenom_normalise; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_personne_nom_prenom_normalise ON personne USING btree (nom_normalise, prenom_normalise);


--
-- Name: idx_personne_props_scolarite_compteur_references; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_personne_props_scolarite_compteur_references ON personne_proprietes_scolarite USING btree (compteur_references);


--
-- Name: idx_personne_props_scolarite_import_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_personne_props_scolarite_import_id ON personne_proprietes_scolarite USING btree (import_id);


--
-- Name: idx_personne_props_scolarite_personne_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_personne_props_scolarite_personne_id ON personne_proprietes_scolarite USING btree (personne_id);


--
-- Name: idx_personne_props_scolarite_props_scolarite_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_personne_props_scolarite_props_scolarite_id ON personne_proprietes_scolarite USING btree (proprietes_scolarite_id);


--
-- Name: idx_personne_regime_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_personne_regime_id ON personne USING btree (regime_id);


--
-- Name: idx_porteur_ent_perimetre_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_porteur_ent_perimetre_id ON porteur_ent USING btree (perimetre_id);


--
-- Name: idx_preferences_etablissement_etablissement_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_preferences_etablissement_etablissement_id ON preferences_etablissement USING btree (etablissement_id);


--
-- Name: idx_proprietes_scolarite_annee_scolaire_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_proprietes_scolarite_annee_scolaire_id ON proprietes_scolarite USING btree (annee_scolaire_id);


--
-- Name: idx_proprietes_scolarite_etablissement_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_proprietes_scolarite_etablissement_id ON proprietes_scolarite USING btree (etablissement_id);


--
-- Name: idx_proprietes_scolarite_fonction_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_proprietes_scolarite_fonction_id ON proprietes_scolarite USING btree (fonction_id);


--
-- Name: idx_proprietes_scolarite_matiere_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_proprietes_scolarite_matiere_id ON proprietes_scolarite USING btree (matiere_id);


--
-- Name: idx_proprietes_scolarite_mef_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_proprietes_scolarite_mef_id ON proprietes_scolarite USING btree (mef_id);


--
-- Name: idx_proprietes_scolarite_niveau_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_proprietes_scolarite_niveau_id ON proprietes_scolarite USING btree (niveau_id);


--
-- Name: idx_proprietes_scolarite_structure_enseignement_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_proprietes_scolarite_structure_enseignement_id ON proprietes_scolarite USING btree (structure_enseignement_id);


--
-- Name: idx_props_scolarite_porteur_ent_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_props_scolarite_porteur_ent_id ON proprietes_scolarite USING btree (porteur_ent_id);


--
-- Name: idx_resp_eleve_import_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_resp_eleve_import_id ON responsable_eleve USING btree (import_id);


--
-- Name: idx_responsable_eleve_eleve_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_responsable_eleve_eleve_id ON responsable_eleve USING btree (eleve_id);


--
-- Name: idx_responsable_eleve_personne_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_responsable_eleve_personne_id ON responsable_eleve USING btree (personne_id);


--
-- Name: idx_responsable_props_scolarite_import_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_responsable_props_scolarite_import_id ON responsable_proprietes_scolarite USING btree (import_id);


--
-- Name: idx_responsable_props_scolarite_props_scolarite_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_responsable_props_scolarite_props_scolarite_id ON responsable_proprietes_scolarite USING btree (proprietes_scolarite_id);


--
-- Name: idx_responsable_props_scolarite_resp_eleve_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_responsable_props_scolarite_resp_eleve_id ON responsable_proprietes_scolarite USING btree (responsable_eleve_id);


--
-- Name: idx_service_structure_enseignement; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_service_structure_enseignement ON service USING btree (id_structure_enseignement);


--
-- Name: idx_sous_service_id; Type: INDEX; Schema: ent; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_sous_service_id ON sous_service USING btree (id);


SET search_path = entcdt, pg_catalog;

--
-- Name: idx_activite_id_cahier_de_textes; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_activite_id_cahier_de_textes ON activite USING btree (id_cahier_de_textes);


--
-- Name: idx_activite_id_chapitre; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_activite_id_chapitre ON activite USING btree (id_chapitre);


--
-- Name: idx_cahier_de_textes_id_item; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_cahier_de_textes_id_item ON cahier_de_textes USING btree (id_item);


--
-- Name: idx_cahier_de_textes_parent_incorporation; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_cahier_de_textes_parent_incorporation ON cahier_de_textes USING btree (id_parent_incorporation);


--
-- Name: idx_date_activite_id_activite; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_date_activite_id_activite ON date_activite USING btree (id_activite);


--
-- Name: idx_dossier_id_acteur; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_dossier_id_acteur ON dossier USING btree (id_acteur);


--
-- Name: idx_rel_activite_acteur_id_acteur; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_rel_activite_acteur_id_acteur ON rel_activite_acteur USING btree (id_acteur);


--
-- Name: idx_rel_activite_acteur_id_activite; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_rel_activite_acteur_id_activite ON rel_activite_acteur USING btree (id_activite);


--
-- Name: idx_rel_cahier_acteur_id_acteur; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_rel_cahier_acteur_id_acteur ON rel_cahier_acteur USING btree (id_acteur);


--
-- Name: idx_rel_cahier_acteur_id_cahier_de_textes; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_rel_cahier_acteur_id_cahier_de_textes ON rel_cahier_acteur USING btree (id_cahier_de_textes);


--
-- Name: idx_ressource_id_activite; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_ressource_id_activite ON ressource USING btree (id_activite);


--
-- Name: idx_visa_auteur_personne_id; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_visa_auteur_personne_id ON visa USING btree (auteur_personne_id);


--
-- Name: idx_visa_cahier_vise_id; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_visa_cahier_vise_id ON visa USING btree (cahier_vise_id);


--
-- Name: ux_activity_book_group; Type: INDEX; Schema: entcdt; Owner: eliot; Tablespace: 
--

CREATE UNIQUE INDEX ux_activity_book_group ON dossier USING btree (id_acteur) WHERE (est_defaut = true);


SET search_path = entnotes, pg_catalog;

--
-- Name: idx_appreciation_classe_enseignement_periode; Type: INDEX; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_appreciation_classe_enseignement_periode ON appreciation_classe_enseignement_periode USING btree (classe_id, periode_id, enseignement_enseignant_id, enseignement_service_id);


--
-- Name: idx_appreciation_eleve_enseignement_periode; Type: INDEX; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_appreciation_eleve_enseignement_periode ON appreciation_eleve_enseignement_periode USING btree (eleve_id, periode_id, enseignement_enseignant_id, enseignement_service_id);


--
-- Name: idx_appreciation_eleve_periode; Type: INDEX; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_appreciation_eleve_periode ON appreciation_eleve_periode USING btree (eleve_id, periode_id);


--
-- Name: idx_dernier_changement_dans_classe; Type: INDEX; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_dernier_changement_dans_classe ON dernier_changement_dans_classe USING btree (classe_id);


--
-- Name: idx_info_calcul_moyennes_classe; Type: INDEX; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_info_calcul_moyennes_classe ON info_calcul_moyennes_classe USING btree (classe_id);


--
-- Name: idx_modele_appreciation_etablissement_id; Type: INDEX; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_modele_appreciation_etablissement_id ON modele_appreciation USING btree (id);


--
-- Name: idx_modele_appreciation_professeur_id; Type: INDEX; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_modele_appreciation_professeur_id ON modele_appreciation_professeur USING btree (id);


--
-- Name: idx_resultat_classe_sous_service_periode_rcspid; Type: INDEX; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_resultat_classe_sous_service_periode_rcspid ON resultat_classe_sous_service_periode USING btree (resultat_classe_service_periode_id);


--
-- Name: idx_resultat_classe_sous_service_periode_ssid; Type: INDEX; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_resultat_classe_sous_service_periode_ssid ON resultat_classe_sous_service_periode USING btree (sous_service_id);


--
-- Name: idx_resultat_eleve_sous_service_periode_respid; Type: INDEX; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_resultat_eleve_sous_service_periode_respid ON resultat_eleve_sous_service_periode USING btree (resultat_eleve_service_periode_id);


--
-- Name: idx_resultat_eleve_sous_service_periode_ssid; Type: INDEX; Schema: entnotes; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_resultat_eleve_sous_service_periode_ssid ON resultat_eleve_sous_service_periode USING btree (sous_service_id);


SET search_path = enttemps, pg_catalog;

--
-- Name: idx_agenda_etablissement_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_agenda_etablissement_id ON agenda USING btree (etablissement_id);


--
-- Name: idx_agenda_item_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_agenda_item_id ON agenda USING btree (item_id);


--
-- Name: idx_agenda_structure_enseignement_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_agenda_structure_enseignement_id ON agenda USING btree (structure_enseignement_id);


--
-- Name: idx_appel_evenement_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_appel_evenement_id ON appel USING btree (evenement_id);


--
-- Name: idx_appel_ligne_appel_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_appel_ligne_appel_id ON appel_ligne USING btree (appel_id);


--
-- Name: idx_calendrier_preferences_etablissement_absences_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_calendrier_preferences_etablissement_absences_id ON calendrier USING btree (preferences_etablissement_absences_id);


--
-- Name: idx_date_exclue_evenement_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_date_exclue_evenement_id ON date_exclue USING btree (evenement_id);


--
-- Name: idx_element_emploi_du_temps_enseignant_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_element_emploi_du_temps_enseignant_id ON element_emploi_du_temps USING btree (enseignant_id);


--
-- Name: idx_element_emploi_du_temps_evenement_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_element_emploi_du_temps_evenement_id ON element_emploi_du_temps USING btree (evenement_id);


--
-- Name: idx_groupe_motif_preferences_etablissement_absences_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_groupe_motif_preferences_etablissement_absences_id ON groupe_motif USING btree (preferences_etablissement_absences_id);


--
-- Name: idx_incident_etablissement_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_incident_etablissement_id ON incident USING btree (etablissement_id);


--
-- Name: idx_motif_groupe_motif_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_motif_groupe_motif_id ON motif USING btree (groupe_motif_id);


--
-- Name: idx_partenaire_a_prevenir_incident_incident_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_partenaire_a_prevenir_incident_incident_id ON partenaire_a_prevenir_incident USING btree (incident_id);


--
-- Name: idx_plage_horaire_preferences_etablissement_absences_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_plage_horaire_preferences_etablissement_absences_id ON plage_horaire USING btree (preferences_etablissement_absences_id);


--
-- Name: idx_preferences_utilisateur_agenda_agenda_id_utilisateur_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_preferences_utilisateur_agenda_agenda_id_utilisateur_id ON preferences_utilisateur_agenda USING btree (agenda_id, utilisateur_id);


--
-- Name: idx_protagoniste_incident_incident_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_protagoniste_incident_incident_id ON protagoniste_incident USING btree (incident_id);


--
-- Name: idx_reaction_appel_appel_ligne_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_reaction_appel_appel_ligne_id ON reaction_appel USING btree (appel_ligne_id);


--
-- Name: idx_rel_agenda_evenement_agenda_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_rel_agenda_evenement_agenda_id ON rel_agenda_evenement USING btree (agenda_id);


--
-- Name: idx_repeter_jour_annee_evenement_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_repeter_jour_annee_evenement_id ON repeter_jour_annee USING btree (evenement_id);


--
-- Name: idx_repeter_jour_mois_evenement_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_repeter_jour_mois_evenement_id ON repeter_jour_mois USING btree (evenement_id);


--
-- Name: idx_repeter_jour_semaine_evenement_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_repeter_jour_semaine_evenement_id ON repeter_jour_semaine USING btree (evenement_id);


--
-- Name: idx_repeter_mois_evenement_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_repeter_mois_evenement_id ON repeter_mois USING btree (evenement_id);


--
-- Name: idx_repeter_semaine_annee_evenement_id; Type: INDEX; Schema: enttemps; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_repeter_semaine_annee_evenement_id ON repeter_semaine_annee USING btree (evenement_id);


SET search_path = forum, pg_catalog;

--
-- Name: idx_commentaire_id_discussion; Type: INDEX; Schema: forum; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_commentaire_id_discussion ON commentaire USING btree (id_discussion);


--
-- Name: idx_discussion_id_item_cible; Type: INDEX; Schema: forum; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_discussion_id_item_cible ON discussion USING btree (id_item_cible);


SET search_path = impression, pg_catalog;

--
-- Name: idx_publipostage_suivi_classe_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_publipostage_suivi_classe_id ON publipostage_suivi USING btree (classe_id);


--
-- Name: idx_publipostage_suivi_operateur_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_publipostage_suivi_operateur_id ON publipostage_suivi USING btree (operateur_id);


--
-- Name: idx_publipostage_suivi_personne_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_publipostage_suivi_personne_id ON publipostage_suivi USING btree (personne_id);


--
-- Name: idx_publipostage_suivi_template_doc_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_publipostage_suivi_template_doc_id ON publipostage_suivi USING btree (template_document_id);


--
-- Name: idx_template_champ_memo_template_doc_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_template_champ_memo_template_doc_id ON template_champ_memo USING btree (template_document_id);


--
-- Name: idx_template_doc_sous_template_eliot_template_doc_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_template_doc_sous_template_eliot_template_doc_id ON template_document_sous_template_eliot USING btree (template_document_id);


--
-- Name: idx_template_doc_sous_template_eliot_template_eliot_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_template_doc_sous_template_eliot_template_eliot_id ON template_document_sous_template_eliot USING btree (template_eliot_id);


--
-- Name: idx_template_document_etablissement_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_template_document_etablissement_id ON template_document USING btree (etablissement_id);


--
-- Name: idx_template_document_template_eliot_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_template_document_template_eliot_id ON template_document USING btree (template_eliot_id);


--
-- Name: idx_template_eliot_template_jasper_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_template_eliot_template_jasper_id ON template_eliot USING btree (template_jasper_id);


--
-- Name: idx_template_eliot_type_donnees_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_template_eliot_type_donnees_id ON template_eliot USING btree (type_donnees_id);


--
-- Name: idx_template_eliot_type_fonctionnalite_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_template_eliot_type_fonctionnalite_id ON template_eliot USING btree (type_fonctionnalite_id);


--
-- Name: idx_template_jasper_sous_template_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_template_jasper_sous_template_id ON template_jasper USING btree (sous_template_id);


--
-- Name: idx_template_type_donnees_code; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_template_type_donnees_code ON template_type_donnees USING btree (code);


--
-- Name: idx_template_type_fonctionnalite_code; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_template_type_fonctionnalite_code ON template_type_fonctionnalite USING btree (code);


--
-- Name: idx_template_type_fonctionnalite_parent_id; Type: INDEX; Schema: impression; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_template_type_fonctionnalite_parent_id ON template_type_fonctionnalite USING btree (parent_id);


SET search_path = securite, pg_catalog;

--
-- Name: idx_autorisation_id_autorite; Type: INDEX; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_autorisation_id_autorite ON autorisation USING btree (id_autorite);


--
-- Name: idx_autorisation_id_item; Type: INDEX; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_autorisation_id_item ON autorisation USING btree (id_item);


--
-- Name: idx_autorite_import_id; Type: INDEX; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_autorite_import_id ON autorite USING btree (import_id);


--
-- Name: idx_item_import_id; Type: INDEX; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_item_import_id ON item USING btree (import_id);


--
-- Name: idx_perimetre_import_id; Type: INDEX; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_perimetre_import_id ON perimetre USING btree (import_id);


--
-- Name: idx_perimetre_parent_id; Type: INDEX; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_perimetre_parent_id ON perimetre USING btree (perimetre_parent_id);


--
-- Name: idx_perimetre_securite_item_id; Type: INDEX; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_perimetre_securite_item_id ON perimetre_securite USING btree (item_id);


--
-- Name: idx_perimetre_securite_perimetre_id; Type: INDEX; Schema: securite; Owner: eliot; Tablespace: 
--

CREATE INDEX idx_perimetre_securite_perimetre_id ON perimetre_securite USING btree (perimetre_id);


SET search_path = enttemps, pg_catalog;

--
-- Name: agenda_before_insert; Type: TRIGGER; Schema: enttemps; Owner: eliot
--

CREATE TRIGGER agenda_before_insert
    BEFORE INSERT ON agenda
    FOR EACH ROW
    EXECUTE PROCEDURE agenda_before_insert();


SET search_path = aaf, pg_catalog;

--
-- Name: fk_import_verrou_import; Type: FK CONSTRAINT; Schema: aaf; Owner: eliot
--

ALTER TABLE ONLY import_verrou
    ADD CONSTRAINT fk_import_verrou_import FOREIGN KEY (import_id) REFERENCES import(id);


SET search_path = ent, pg_catalog;

--
-- Name: fk_appartenance_groupe_groupe_groupe_enfant; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY appartenance_groupe_groupe
    ADD CONSTRAINT fk_appartenance_groupe_groupe_groupe_enfant FOREIGN KEY (groupe_personnes_enfant_id) REFERENCES groupe_personnes(id);


--
-- Name: fk_appartenance_groupe_groupe_groupe_parent; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY appartenance_groupe_groupe
    ADD CONSTRAINT fk_appartenance_groupe_groupe_groupe_parent FOREIGN KEY (groupe_personnes_parent_id) REFERENCES groupe_personnes(id);


--
-- Name: fk_appartenance_personne_groupe_groupe; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY appartenance_personne_groupe
    ADD CONSTRAINT fk_appartenance_personne_groupe_groupe FOREIGN KEY (groupe_personnes_id) REFERENCES groupe_personnes(id);


--
-- Name: fk_appartenance_personne_groupe_personne; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY appartenance_personne_groupe
    ADD CONSTRAINT fk_appartenance_personne_groupe_personne FOREIGN KEY (personne_id) REFERENCES personne(id);


--
-- Name: fk_etablissement_etab_ratt_id; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT fk_etablissement_etab_ratt_id FOREIGN KEY (etablissement_rattachement_id) REFERENCES etablissement(id);


--
-- Name: fk_etablissement_perimetre; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT fk_etablissement_perimetre FOREIGN KEY (perimetre_id) REFERENCES securite.perimetre(id);


--
-- Name: fk_etablissement_porteur_ent; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT fk_etablissement_porteur_ent FOREIGN KEY (porteur_ent_id) REFERENCES porteur_ent(id);


--
-- Name: fk_groupe_personnes_autorite; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT fk_groupe_personnes_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_groupe_personnes_item; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT fk_groupe_personnes_item FOREIGN KEY (item_id) REFERENCES securite.item(id);


--
-- Name: fk_groupe_personnes_proprietes_scolarite; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT fk_groupe_personnes_proprietes_scolarite FOREIGN KEY (proprietes_scolarite_id) REFERENCES proprietes_scolarite(id);


--
-- Name: fk_matiere_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT fk_matiere_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- Name: fk_mef_niveau; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY mef
    ADD CONSTRAINT fk_mef_niveau FOREIGN KEY (niveau_id) REFERENCES niveau(id);


--
-- Name: fk_modalite_matiere_etablissement_id; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT fk_modalite_matiere_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- Name: fk_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT fk_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id);


--
-- Name: fk_periode_type_periode; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT fk_periode_type_periode FOREIGN KEY (type_periode_id) REFERENCES type_periode(id);


--
-- Name: fk_personne_autorite; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT fk_personne_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_personne_civilite; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT fk_personne_civilite FOREIGN KEY (civilite_id) REFERENCES civilite(id);


--
-- Name: fk_personne_etab_ratt_id; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT fk_personne_etab_ratt_id FOREIGN KEY (etablissement_rattachement_id) REFERENCES etablissement(id);


--
-- Name: fk_personne_props_scolarite_import; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY personne_proprietes_scolarite
    ADD CONSTRAINT fk_personne_props_scolarite_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- Name: fk_personne_props_scolarite_personne; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY personne_proprietes_scolarite
    ADD CONSTRAINT fk_personne_props_scolarite_personne FOREIGN KEY (personne_id) REFERENCES personne(id);


--
-- Name: fk_personne_props_scolarite_props_scolarite; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY personne_proprietes_scolarite
    ADD CONSTRAINT fk_personne_props_scolarite_props_scolarite FOREIGN KEY (proprietes_scolarite_id) REFERENCES proprietes_scolarite(id);


--
-- Name: fk_personne_regime_id; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT fk_personne_regime_id FOREIGN KEY (regime_id) REFERENCES regime(id);


--
-- Name: fk_porteur_ent_perimetre; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY porteur_ent
    ADD CONSTRAINT fk_porteur_ent_perimetre FOREIGN KEY (perimetre_id) REFERENCES securite.perimetre(id);


--
-- Name: fk_preferences_etablissement_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY preferences_etablissement
    ADD CONSTRAINT fk_preferences_etablissement_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- Name: fk_preferences_utilisateur_dernier_etablissement_utilise_id; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY preferences_utilisateur
    ADD CONSTRAINT fk_preferences_utilisateur_dernier_etablissement_utilise_id FOREIGN KEY (dernier_etablissement_utilise_id) REFERENCES etablissement(id) ON DELETE SET NULL;


--
-- Name: fk_preferences_utilisateur_utilisateur_id; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY preferences_utilisateur
    ADD CONSTRAINT fk_preferences_utilisateur_utilisateur_id FOREIGN KEY (utilisateur_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_proprietes_scolarite_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY proprietes_scolarite
    ADD CONSTRAINT fk_proprietes_scolarite_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id);


--
-- Name: fk_proprietes_scolarite_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY proprietes_scolarite
    ADD CONSTRAINT fk_proprietes_scolarite_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- Name: fk_proprietes_scolarite_fonction; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY proprietes_scolarite
    ADD CONSTRAINT fk_proprietes_scolarite_fonction FOREIGN KEY (fonction_id) REFERENCES fonction(id);


--
-- Name: fk_proprietes_scolarite_matiere; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY proprietes_scolarite
    ADD CONSTRAINT fk_proprietes_scolarite_matiere FOREIGN KEY (matiere_id) REFERENCES matiere(id);


--
-- Name: fk_proprietes_scolarite_mef; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY proprietes_scolarite
    ADD CONSTRAINT fk_proprietes_scolarite_mef FOREIGN KEY (mef_id) REFERENCES mef(id);


--
-- Name: fk_proprietes_scolarite_niveau; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY proprietes_scolarite
    ADD CONSTRAINT fk_proprietes_scolarite_niveau FOREIGN KEY (niveau_id) REFERENCES niveau(id);


--
-- Name: fk_proprietes_scolarite_source_import_id; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY proprietes_scolarite
    ADD CONSTRAINT fk_proprietes_scolarite_source_import_id FOREIGN KEY (source_id) REFERENCES source_import(id);


--
-- Name: fk_proprietes_scolarite_structure; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY proprietes_scolarite
    ADD CONSTRAINT fk_proprietes_scolarite_structure FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id);


--
-- Name: fk_props_scolarite_porteur_ent; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY proprietes_scolarite
    ADD CONSTRAINT fk_props_scolarite_porteur_ent FOREIGN KEY (porteur_ent_id) REFERENCES porteur_ent(id);


--
-- Name: fk_rel_classe_filiere_to_filiere; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT fk_rel_classe_filiere_to_filiere FOREIGN KEY (id_filiere) REFERENCES filiere(id);


--
-- Name: fk_rel_classe_filiere_to_structure_enseignement_classe; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT fk_rel_classe_filiere_to_structure_enseignement_classe FOREIGN KEY (id_classe) REFERENCES structure_enseignement(id);


--
-- Name: fk_rel_classe_groupe_to_structure_enseignement_classe; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT fk_rel_classe_groupe_to_structure_enseignement_classe FOREIGN KEY (id_classe) REFERENCES structure_enseignement(id);


--
-- Name: fk_rel_classe_groupe_to_structure_enseignement_groupe; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT fk_rel_classe_groupe_to_structure_enseignement_groupe FOREIGN KEY (id_groupe) REFERENCES structure_enseignement(id);


--
-- Name: fk_rel_ens_service_autorite; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY rel_enseignant_service
    ADD CONSTRAINT fk_rel_ens_service_autorite FOREIGN KEY (id_enseignant) REFERENCES securite.autorite(id);


--
-- Name: fk_rel_enseignant_service_srv; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY rel_enseignant_service
    ADD CONSTRAINT fk_rel_enseignant_service_srv FOREIGN KEY (id_service) REFERENCES service(id) ON DELETE CASCADE;


--
-- Name: fk_rel_periode_service_periode; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT fk_rel_periode_service_periode FOREIGN KEY (periode_id) REFERENCES periode(id);


--
-- Name: fk_rel_periode_service_service; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT fk_rel_periode_service_service FOREIGN KEY (service_id) REFERENCES service(id);


--
-- Name: fk_resp_eleve_import; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT fk_resp_eleve_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- Name: fk_responsable_eleve_eleve; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT fk_responsable_eleve_eleve FOREIGN KEY (eleve_id) REFERENCES personne(id);


--
-- Name: fk_responsable_eleve_personne; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT fk_responsable_eleve_personne FOREIGN KEY (personne_id) REFERENCES personne(id);


--
-- Name: fk_responsable_props_scolarite_import; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY responsable_proprietes_scolarite
    ADD CONSTRAINT fk_responsable_props_scolarite_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- Name: fk_responsable_props_scolarite_props_scolarite; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY responsable_proprietes_scolarite
    ADD CONSTRAINT fk_responsable_props_scolarite_props_scolarite FOREIGN KEY (proprietes_scolarite_id) REFERENCES proprietes_scolarite(id);


--
-- Name: fk_responsable_props_scolarite_responsable; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY responsable_proprietes_scolarite
    ADD CONSTRAINT fk_responsable_props_scolarite_responsable FOREIGN KEY (responsable_eleve_id) REFERENCES responsable_eleve(id);


--
-- Name: fk_service_matiere; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_matiere FOREIGN KEY (id_matiere) REFERENCES matiere(id);


--
-- Name: fk_service_modalite_cours; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_modalite_cours FOREIGN KEY (id_modalite_cours) REFERENCES modalite_cours(id);


--
-- Name: fk_service_structure_ens; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_structure_ens FOREIGN KEY (id_structure_enseignement) REFERENCES structure_enseignement(id) ON DELETE CASCADE;


--
-- Name: fk_signature_to_autorite; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY signature
    ADD CONSTRAINT fk_signature_to_autorite FOREIGN KEY (proprietaire_id) REFERENCES securite.autorite(id);


--
-- Name: fk_sous_service_modalite_matiere_id; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_modalite_matiere_id FOREIGN KEY (modalite_matiere_id) REFERENCES modalite_matiere(id);


--
-- Name: fk_sous_service_service_id; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_service_id FOREIGN KEY (service_id) REFERENCES service(id);


--
-- Name: fk_sous_service_type_periode; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_type_periode FOREIGN KEY (type_periode_id) REFERENCES type_periode(id);


--
-- Name: fk_structure_enseignement_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_annee_scolaire FOREIGN KEY (id_annee_scolaire) REFERENCES annee_scolaire(id);


--
-- Name: fk_structure_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- Name: fk_trace_auteur; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY trace
    ADD CONSTRAINT fk_trace_auteur FOREIGN KEY (auteur_id) REFERENCES securite.autorite(id);


--
-- Name: fk_type_periode_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: eliot
--

ALTER TABLE ONLY type_periode
    ADD CONSTRAINT fk_type_periode_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


SET search_path = entcdt, pg_catalog;

--
-- Name: fk_activite_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_autorite FOREIGN KEY (id_auteur) REFERENCES securite.autorite(id);


--
-- Name: fk_activite_chapitre; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_chapitre FOREIGN KEY (id_chapitre) REFERENCES chapitre(id);


--
-- Name: fk_activite_contexte; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_contexte FOREIGN KEY (id_contexte_activite) REFERENCES contexte_activite(id);


--
-- Name: fk_activite_item; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_item FOREIGN KEY (id_item) REFERENCES securite.item(id);


--
-- Name: fk_activite_type; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_type FOREIGN KEY (id_type_activite) REFERENCES type_activite(id);


--
-- Name: fk_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY chapitre
    ADD CONSTRAINT fk_cahier_de_textes FOREIGN KEY (id_cahier_de_textes) REFERENCES cahier_de_textes(id);


--
-- Name: fk_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_cahier_de_textes FOREIGN KEY (id_cahier_de_textes) REFERENCES cahier_de_textes(id);


--
-- Name: fk_cahier_de_textes_annee_scolaire; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- Name: fk_cahier_de_textes_item; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_item FOREIGN KEY (id_item) REFERENCES securite.item(id);


--
-- Name: fk_cahier_de_textes_parent_incorporation; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_parent_incorporation FOREIGN KEY (id_parent_incorporation) REFERENCES cahier_de_textes(id);


--
-- Name: fk_cahier_de_textes_service; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_service FOREIGN KEY (id_service) REFERENCES ent.service(id);


--
-- Name: fk_chapitre_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY chapitre
    ADD CONSTRAINT fk_chapitre_autorite FOREIGN KEY (id_auteur) REFERENCES securite.autorite(id);


--
-- Name: fk_chapitre_chapitre_parent; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY chapitre
    ADD CONSTRAINT fk_chapitre_chapitre_parent FOREIGN KEY (id_chapitre_parent) REFERENCES chapitre(id);


--
-- Name: fk_contexte_activite_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY contexte_activite
    ADD CONSTRAINT fk_contexte_activite_autorite FOREIGN KEY (id_proprietaire) REFERENCES securite.autorite(id);


--
-- Name: fk_date_activite_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY date_activite
    ADD CONSTRAINT fk_date_activite_activite FOREIGN KEY (id_activite) REFERENCES activite(id);


--
-- Name: fk_date_activite_element_emploi_du_temps; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY date_activite
    ADD CONSTRAINT fk_date_activite_element_emploi_du_temps FOREIGN KEY (element_emploi_du_temps_id) REFERENCES enttemps.element_emploi_du_temps(id);


--
-- Name: fk_dossier_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY dossier
    ADD CONSTRAINT fk_dossier_autorite FOREIGN KEY (id_acteur) REFERENCES securite.autorite(id);


--
-- Name: fk_etat_chapitre_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY etat_chapitre
    ADD CONSTRAINT fk_etat_chapitre_autorite FOREIGN KEY (id_acteur) REFERENCES securite.autorite(id);


--
-- Name: fk_etat_chapitre_chapitre; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY etat_chapitre
    ADD CONSTRAINT fk_etat_chapitre_chapitre FOREIGN KEY (id_chapitre) REFERENCES chapitre(id);


--
-- Name: fk_etat_dossier_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY etat_dossier
    ADD CONSTRAINT fk_etat_dossier_autorite FOREIGN KEY (id_acteur) REFERENCES securite.autorite(id);


--
-- Name: fk_etat_dossier_dossier; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY etat_dossier
    ADD CONSTRAINT fk_etat_dossier_dossier FOREIGN KEY (id_dossier) REFERENCES dossier(id);


--
-- Name: fk_rel_activite_acteur_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY rel_activite_acteur
    ADD CONSTRAINT fk_rel_activite_acteur_activite FOREIGN KEY (id_activite) REFERENCES activite(id);


--
-- Name: fk_rel_activite_acteur_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY rel_activite_acteur
    ADD CONSTRAINT fk_rel_activite_acteur_autorite FOREIGN KEY (id_acteur) REFERENCES securite.autorite(id);


--
-- Name: fk_rel_cahier_acteur_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY rel_cahier_acteur
    ADD CONSTRAINT fk_rel_cahier_acteur_autorite FOREIGN KEY (id_acteur) REFERENCES securite.autorite(id);


--
-- Name: fk_rel_cahier_acteur_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY rel_cahier_acteur
    ADD CONSTRAINT fk_rel_cahier_acteur_cahier_de_textes FOREIGN KEY (id_cahier_de_textes) REFERENCES cahier_de_textes(id);


--
-- Name: fk_rel_cahier_groupe_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY rel_cahier_groupe
    ADD CONSTRAINT fk_rel_cahier_groupe_autorite FOREIGN KEY (id_groupe) REFERENCES securite.autorite(id);


--
-- Name: fk_rel_cahier_groupe_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY rel_cahier_groupe
    ADD CONSTRAINT fk_rel_cahier_groupe_cahier_de_textes FOREIGN KEY (id_cahier_de_textes) REFERENCES cahier_de_textes(id);


--
-- Name: fk_rel_dossier_autorisation_cahier_autorisation; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY rel_dossier_autorisation_cahier
    ADD CONSTRAINT fk_rel_dossier_autorisation_cahier_autorisation FOREIGN KEY (id_autorisation) REFERENCES securite.autorisation(id) ON DELETE CASCADE;


--
-- Name: fk_rel_dossier_autorisation_cahier_dossier; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY rel_dossier_autorisation_cahier
    ADD CONSTRAINT fk_rel_dossier_autorisation_cahier_dossier FOREIGN KEY (id_dossier) REFERENCES dossier(id);


--
-- Name: fk_ressource_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY ressource
    ADD CONSTRAINT fk_ressource_activite FOREIGN KEY (id_activite) REFERENCES activite(id);


--
-- Name: fk_ressource_fichier; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY ressource
    ADD CONSTRAINT fk_ressource_fichier FOREIGN KEY (id_fichier) REFERENCES fichier(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_textes_preferences_utilisateur_utilisateur_id; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY textes_preferences_utilisateur
    ADD CONSTRAINT fk_textes_preferences_utilisateur_utilisateur_id FOREIGN KEY (utilisateur_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_type_activite_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY type_activite
    ADD CONSTRAINT fk_type_activite_autorite FOREIGN KEY (id_proprietaire) REFERENCES securite.autorite(id);


--
-- Name: fk_visa_auteur_personne_id; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY visa
    ADD CONSTRAINT fk_visa_auteur_personne_id FOREIGN KEY (auteur_personne_id) REFERENCES ent.personne(id);


--
-- Name: fk_visa_cahier_vise_id; Type: FK CONSTRAINT; Schema: entcdt; Owner: eliot
--

ALTER TABLE ONLY visa
    ADD CONSTRAINT fk_visa_cahier_vise_id FOREIGN KEY (cahier_vise_id) REFERENCES cahier_de_textes(id);


SET search_path = entnotes, pg_catalog;

--
-- Name: fk_appreciation_classe_enseignement_periode_eleve_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_eleve_id FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_appreciation_classe_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_enseignement FOREIGN KEY (enseignement_service_id, enseignement_enseignant_id) REFERENCES ent.rel_enseignant_service(id_service, id_enseignant);


--
-- Name: fk_appreciation_classe_enseignement_periode_periode_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_periode_id FOREIGN KEY (periode_id) REFERENCES ent.periode(id);


--
-- Name: fk_appreciation_eleve_enseignement_periode_eleve_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_eleve_id FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appreciation_eleve_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_enseignement FOREIGN KEY (enseignement_service_id, enseignement_enseignant_id) REFERENCES ent.rel_enseignant_service(id_service, id_enseignant);


--
-- Name: fk_appreciation_eleve_enseignement_periode_periode_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_periode_id FOREIGN KEY (periode_id) REFERENCES ent.periode(id);


--
-- Name: fk_appreciation_eleve_periode_avis_conseil_de_classe_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_avis_conseil_de_classe_id FOREIGN KEY (avis_conseil_de_classe_id) REFERENCES avis_conseil_de_classe(id);


--
-- Name: fk_appreciation_eleve_periode_avis_orientation_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_avis_orientation_id FOREIGN KEY (avis_orientation_id) REFERENCES avis_orientation(id);


--
-- Name: fk_appreciation_eleve_periode_eleve_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_eleve_id FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appreciation_eleve_periode_periode_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_periode_id FOREIGN KEY (periode_id) REFERENCES ent.periode(id);


--
-- Name: fk_avis_conseil_de_classe_etablissement_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY avis_conseil_de_classe
    ADD CONSTRAINT fk_avis_conseil_de_classe_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_avis_orientation_etablissement_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY avis_orientation
    ADD CONSTRAINT fk_avis_orientation_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_dernier_changement_dans_classe_classe_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY dernier_changement_dans_classe
    ADD CONSTRAINT fk_dernier_changement_dans_classe_classe_id FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_dirty_moyenne_classe_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_classe_id FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_dirty_moyenne_eleve_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_eleve_id FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_dirty_moyenne_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_enseignement FOREIGN KEY (enseignement_service_id, enseignement_enseignant_id) REFERENCES ent.rel_enseignant_service(id_service, id_enseignant);


--
-- Name: fk_dirty_moyenne_periode_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_periode_id FOREIGN KEY (periode_id) REFERENCES ent.periode(id);


--
-- Name: fk_dirty_moyenne_service_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_service_id FOREIGN KEY (service_id) REFERENCES ent.service(id);


--
-- Name: fk_dirty_moyenne_sous_service_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_sous_service_id FOREIGN KEY (sous_service_id) REFERENCES ent.sous_service(id);


--
-- Name: fk_evaluation_activite; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_activite FOREIGN KEY (activite_id) REFERENCES entcdt.activite(id);


--
-- Name: fk_evaluation_modalite_matiere_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_modalite_matiere_id FOREIGN KEY (modalite_matiere_id) REFERENCES ent.modalite_matiere(id);


--
-- Name: fk_evaluation_rel_enseignant_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_rel_enseignant_service FOREIGN KEY (enseignement_enseignant_id, enseignement_service_id) REFERENCES ent.rel_enseignant_service(id_enseignant, id_service);


--
-- Name: fk_info_calcul_moyennes_classe_classe_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT fk_info_calcul_moyennes_classe_classe_id FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_info_supplementaire_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_info_supplementaire_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- Name: fk_info_supplementaire_enseignement_enseignant; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_info_supplementaire_enseignement_enseignant FOREIGN KEY (enseignement_enseignant_id, enseignement_service_id) REFERENCES ent.rel_enseignant_service(id_enseignant, id_service);


--
-- Name: fk_modele_appreciation_professeur_autorite_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY modele_appreciation_professeur
    ADD CONSTRAINT fk_modele_appreciation_professeur_autorite_id FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_note_eleve; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_eleve FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_note_evaluation; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_evaluation FOREIGN KEY (evaluation_id) REFERENCES evaluation(id) ON DELETE CASCADE;


--
-- Name: fk_rel_evaluation_periode_evaluation_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT fk_rel_evaluation_periode_evaluation_id FOREIGN KEY (evaluation_id) REFERENCES evaluation(id) ON DELETE CASCADE;


--
-- Name: fk_rel_evaluation_periode_periode_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT fk_rel_evaluation_periode_periode_id FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_enseignement FOREIGN KEY (enseignement_enseignant_id, enseignement_service_id) REFERENCES ent.rel_enseignant_service(id_enseignant, id_service);


--
-- Name: fk_resultat_classe_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_enseignement_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_resultat_classe_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT fk_resultat_classe_periode_periode FOREIGN KEY (id_periode) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_service_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_periode FOREIGN KEY (id_periode) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_service_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_service FOREIGN KEY (id_service) REFERENCES ent.service(id);


--
-- Name: fk_resultat_classe_service_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_structure_enseignement FOREIGN KEY (id_structure_enseignement) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_resultat_classe_sous_service_periode_rcspid; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT fk_resultat_classe_sous_service_periode_rcspid FOREIGN KEY (resultat_classe_service_periode_id) REFERENCES resultat_classe_service_periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_sous_service_periode_ssid; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT fk_resultat_classe_sous_service_periode_ssid FOREIGN KEY (sous_service_id) REFERENCES ent.sous_service(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_classe_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT fk_resultat_classe_structure_enseignement FOREIGN KEY (id_structure_enseignement) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_resultat_eleve_autorite_eleve; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_autorite_eleve FOREIGN KEY (id_autorite_eleve) REFERENCES securite.autorite(id);


--
-- Name: fk_resultat_eleve_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_periode FOREIGN KEY (id_periode) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_service_autorite_eleve; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_autorite_eleve FOREIGN KEY (id_autorite_eleve) REFERENCES securite.autorite(id);


--
-- Name: fk_resultat_eleve_service_autorite_enseignant; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_autorite_enseignant FOREIGN KEY (id_autorite_enseignant) REFERENCES securite.autorite(id);


--
-- Name: fk_resultat_eleve_service_autorite_enseignant; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_autorite_enseignant FOREIGN KEY (id_autorite_enseignant) REFERENCES securite.autorite(id);


--
-- Name: fk_resultat_eleve_service_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode FOREIGN KEY (id_periode) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_service_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_service FOREIGN KEY (id_service) REFERENCES ent.service(id);


--
-- Name: fk_resultat_eleve_sous_service_periode_respid; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_respid FOREIGN KEY (resultat_eleve_service_periode_id) REFERENCES resultat_eleve_service_periode(id) ON DELETE CASCADE;


--
-- Name: fk_resultat_eleve_sous_service_periode_ssid; Type: FK CONSTRAINT; Schema: entnotes; Owner: eliot
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_ssid FOREIGN KEY (sous_service_id) REFERENCES ent.sous_service(id) ON DELETE CASCADE;


SET search_path = enttemps, pg_catalog;

--
-- Name: appel_ligne_absence_journee_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT appel_ligne_absence_journee_id FOREIGN KEY (absence_journee_id) REFERENCES absence_journee(id) ON DELETE CASCADE;


--
-- Name: appel_ligne_operateur_saisie_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT appel_ligne_operateur_saisie_id FOREIGN KEY (operateur_saisie_id) REFERENCES securite.autorite(id);


--
-- Name: appel_plage_horaire_plage_horaire_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT appel_plage_horaire_plage_horaire_id FOREIGN KEY (plage_horaire_id) REFERENCES plage_horaire(id) ON DELETE CASCADE;


--
-- Name: fk_absence_journee_etablissement_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT fk_absence_journee_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_agenda_enseignant_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_enseignant_id FOREIGN KEY (enseignant_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_agenda_etablissement_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id) ON DELETE CASCADE;


--
-- Name: fk_agenda_item; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_item FOREIGN KEY (item_id) REFERENCES securite.item(id);


--
-- Name: fk_agenda_structure_enseignement; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_agenda_type_agenda; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_type_agenda FOREIGN KEY (type_agenda_id) REFERENCES type_agenda(id);


--
-- Name: fk_appel_appelant; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_appelant FOREIGN KEY (appelant_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appel_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id);


--
-- Name: fk_appel_ligne_appel; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_appel FOREIGN KEY (appel_id) REFERENCES appel(id) ON DELETE CASCADE;


--
-- Name: fk_appel_ligne_motif; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_motif FOREIGN KEY (motif_id) REFERENCES motif(id);


--
-- Name: fk_appel_ligne_personne; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_personne FOREIGN KEY (personne_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appel_ligne_sanction_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_sanction_id FOREIGN KEY (sanction_id) REFERENCES sanction(id);


--
-- Name: fk_appel_operateur_saisie; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_operateur_saisie FOREIGN KEY (operateur_saisie_id) REFERENCES securite.autorite(id);


--
-- Name: fk_appel_plage_horaire_appel_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT fk_appel_plage_horaire_appel_id FOREIGN KEY (appel_id) REFERENCES appel(id) ON DELETE CASCADE;


--
-- Name: fk_calendrier_annee_scolaire; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT fk_calendrier_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id) ON DELETE CASCADE;


--
-- Name: fk_calendrier_preferences_etablissement_absences_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT fk_calendrier_preferences_etablissement_absences_id FOREIGN KEY (preferences_etablissement_absences_id) REFERENCES preferences_etablissement_absences(id) ON DELETE CASCADE;


--
-- Name: fk_element_emploi_du_temps_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY element_emploi_du_temps
    ADD CONSTRAINT fk_element_emploi_du_temps_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id);


--
-- Name: fk_element_emploi_du_temps_rel_enseignant_service; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY element_emploi_du_temps
    ADD CONSTRAINT fk_element_emploi_du_temps_rel_enseignant_service FOREIGN KEY (enseignant_id, service_id) REFERENCES ent.rel_enseignant_service(id_enseignant, id_service);


--
-- Name: fk_evenement_agenda_maitre; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_agenda_maitre FOREIGN KEY (agenda_maitre_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- Name: fk_evenement_auteur; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_auteur FOREIGN KEY (auteur_id) REFERENCES securite.autorite(id);


--
-- Name: fk_evenement_date_exclue; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY date_exclue
    ADD CONSTRAINT fk_evenement_date_exclue FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_evenement_repeter_jour_annee; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY repeter_jour_annee
    ADD CONSTRAINT fk_evenement_repeter_jour_annee FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_evenement_repeter_jour_mois; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY repeter_jour_mois
    ADD CONSTRAINT fk_evenement_repeter_jour_mois FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_evenement_repeter_jour_semaine; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY repeter_jour_semaine
    ADD CONSTRAINT fk_evenement_repeter_jour_semaine FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_evenement_repeter_mois; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY repeter_mois
    ADD CONSTRAINT fk_evenement_repeter_mois FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_evenement_repeter_semaine_annee; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY repeter_semaine_annee
    ADD CONSTRAINT fk_evenement_repeter_semaine_annee FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_evenement_type_evenement_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_type_evenement_id FOREIGN KEY (type_id) REFERENCES type_evenement(id);


--
-- Name: fk_groupe_motif_preferences_etablissement_absences_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT fk_groupe_motif_preferences_etablissement_absences_id FOREIGN KEY (preferences_etablissement_absences_id) REFERENCES preferences_etablissement_absences(id);


--
-- Name: fk_incident_etablissement_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_incident_lieu_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_lieu_id FOREIGN KEY (lieu_id) REFERENCES lieu_incident(id);


--
-- Name: fk_incident_type_incident_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_type_incident_id FOREIGN KEY (type_id) REFERENCES type_incident(id);


--
-- Name: fk_lieu_incident_preferences_etablissement_absences_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT fk_lieu_incident_preferences_etablissement_absences_id FOREIGN KEY (preferences_etablissement_id) REFERENCES preferences_etablissement_absences(id);


--
-- Name: fk_motif_groupe_motif_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT fk_motif_groupe_motif_id FOREIGN KEY (groupe_motif_id) REFERENCES groupe_motif(id) ON DELETE CASCADE;


--
-- Name: fk_partenaire_a_prevenir_incident_incident_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT fk_partenaire_a_prevenir_incident_incident_id FOREIGN KEY (incident_id) REFERENCES incident(id) ON DELETE CASCADE;


--
-- Name: fk_partenaire_a_prevenir_incident_partenaire_a_prevenir_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT fk_partenaire_a_prevenir_incident_partenaire_a_prevenir_id FOREIGN KEY (partenaire_a_prevenir_id) REFERENCES partenaire_a_prevenir(id);


--
-- Name: fk_partenaire_a_prevenirr_preferences_etablissement_absences_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT fk_partenaire_a_prevenirr_preferences_etablissement_absences_id FOREIGN KEY (preferences_etablissement_id) REFERENCES preferences_etablissement_absences(id);


--
-- Name: fk_plage_horaire_preferences_etablissement_absences_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY plage_horaire
    ADD CONSTRAINT fk_plage_horaire_preferences_etablissement_absences_id FOREIGN KEY (preferences_etablissement_absences_id) REFERENCES preferences_etablissement_absences(id) ON DELETE CASCADE;


--
-- Name: fk_preference_etablissement_absences_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY preferences_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_preferences_etablissement_absences_item_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY preferences_etablissement_absences
    ADD CONSTRAINT fk_preferences_etablissement_absences_item_id FOREIGN KEY (param_item_id) REFERENCES securite.item(id);


--
-- Name: fk_preferences_utilisateur_agenda_agenda; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY preferences_utilisateur_agenda
    ADD CONSTRAINT fk_preferences_utilisateur_agenda_agenda FOREIGN KEY (agenda_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- Name: fk_preferences_utilisateur_agenda_utilisateur; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY preferences_utilisateur_agenda
    ADD CONSTRAINT fk_preferences_utilisateur_agenda_utilisateur FOREIGN KEY (utilisateur_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- Name: fk_protagoniste_incident_autorite_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_autorite_id FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- Name: fk_protagoniste_incident_incident_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_incident_id FOREIGN KEY (incident_id) REFERENCES incident(id) ON DELETE CASCADE;


--
-- Name: fk_protagoniste_incident_qualite_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_qualite_id FOREIGN KEY (qualite_id) REFERENCES qualite_protagoniste(id);


--
-- Name: fk_punition_censeur_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_censeur_id FOREIGN KEY (censeur_id) REFERENCES ent.personne(id);


--
-- Name: fk_punition_eleve_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_eleve_id FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- Name: fk_punition_etablissement_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_punition_incident_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_incident_id FOREIGN KEY (incident_id) REFERENCES incident(id);


--
-- Name: fk_punition_type_punition_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_type_punition_id FOREIGN KEY (type_punition_id) REFERENCES type_punition(id);


--
-- Name: fk_qualite_protagoniste_preferences_etablissement_absences_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT fk_qualite_protagoniste_preferences_etablissement_absences_id FOREIGN KEY (preferences_etablissement_id) REFERENCES preferences_etablissement_absences(id);


--
-- Name: fk_reaction_appel_ligne; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY reaction_appel
    ADD CONSTRAINT fk_reaction_appel_ligne FOREIGN KEY (appel_ligne_id) REFERENCES appel_ligne(id);


--
-- Name: fk_reaction_appel_type_reaction; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY reaction_appel
    ADD CONSTRAINT fk_reaction_appel_type_reaction FOREIGN KEY (type_reaction_id) REFERENCES type_reaction(id);


--
-- Name: fk_rel_agenda_evenement_agenda; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT fk_rel_agenda_evenement_agenda FOREIGN KEY (agenda_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- Name: fk_rel_agenda_evenement_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT fk_rel_agenda_evenement_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- Name: fk_rel_evenement_enseignant; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_rel_evenement_enseignant FOREIGN KEY (enseignement_enseignant_id, enseignement_service_id) REFERENCES ent.rel_enseignant_service(id_enseignant, id_service);


--
-- Name: fk_reservation_auteur; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY reservation
    ADD CONSTRAINT fk_reservation_auteur FOREIGN KEY (auteur_id) REFERENCES securite.autorite(id);


--
-- Name: fk_reservation_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY reservation
    ADD CONSTRAINT fk_reservation_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id);


--
-- Name: fk_reservation_ressource_reservable; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY reservation
    ADD CONSTRAINT fk_reservation_ressource_reservable FOREIGN KEY (ressource_reservable_id) REFERENCES ressource_reservable(id);


--
-- Name: fk_ressource_reservable_type_ressource_reservable; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY ressource_reservable
    ADD CONSTRAINT fk_ressource_reservable_type_ressource_reservable FOREIGN KEY (type_ressource_reservable_id) REFERENCES type_ressource_reservable(id);


--
-- Name: fk_sanction_censeur_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_censeur_id FOREIGN KEY (censeur_id) REFERENCES ent.personne(id);


--
-- Name: fk_sanction_eleve_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_eleve_id FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- Name: fk_sanction_etablissement_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_sanction_incident_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_incident_id FOREIGN KEY (incident_id) REFERENCES incident(id);


--
-- Name: fk_sanction_type_sanction_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_type_sanction_id FOREIGN KEY (type_sanction_id) REFERENCES type_sanction(id);


--
-- Name: fk_type_incident_preferences_etablissement_absences_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT fk_type_incident_preferences_etablissement_absences_id FOREIGN KEY (preferences_etablissement_id) REFERENCES preferences_etablissement_absences(id);


--
-- Name: fk_type_punition_preferences_etablissement_absences_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT fk_type_punition_preferences_etablissement_absences_id FOREIGN KEY (preferences_etablissement_id) REFERENCES preferences_etablissement_absences(id);


--
-- Name: fk_type_reaction_preferences_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY type_reaction
    ADD CONSTRAINT fk_type_reaction_preferences_etablissement FOREIGN KEY (preferences_etablissement_id) REFERENCES ent.preferences_etablissement(id);


--
-- Name: fk_type_sanction_preferences_etablissement_absences_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT fk_type_sanction_preferences_etablissement_absences_id FOREIGN KEY (preferences_etablissement_id) REFERENCES preferences_etablissement_absences(id);


--
-- Name: fk_veille_presence_auteur; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY veille_presence
    ADD CONSTRAINT fk_veille_presence_auteur FOREIGN KEY (auteur_id) REFERENCES securite.autorite(id);


--
-- Name: fk_veille_presence_motif; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY veille_presence
    ADD CONSTRAINT fk_veille_presence_motif FOREIGN KEY (motif_id) REFERENCES motif(id);


--
-- Name: fk_veille_presence_personne; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY veille_presence
    ADD CONSTRAINT fk_veille_presence_personne FOREIGN KEY (personne_id) REFERENCES securite.autorite(id);


--
-- Name: fk_veille_presence_preferences_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY veille_presence
    ADD CONSTRAINT fk_veille_presence_preferences_etablissement FOREIGN KEY (preferences_etablissement_id) REFERENCES ent.preferences_etablissement(id);


--
-- Name: sanction_motif_id; Type: FK CONSTRAINT; Schema: enttemps; Owner: eliot
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT sanction_motif_id FOREIGN KEY (motif_id) REFERENCES motif(id);


SET search_path = forum, pg_catalog;

--
-- Name: fk_discussion_item_cible; Type: FK CONSTRAINT; Schema: forum; Owner: eliot
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT fk_discussion_item_cible FOREIGN KEY (id_item_cible) REFERENCES securite.item(id);


--
-- Name: fk_fm_cmlu_autorite; Type: FK CONSTRAINT; Schema: forum; Owner: eliot
--

ALTER TABLE ONLY commentaire_lu
    ADD CONSTRAINT fk_fm_cmlu_autorite FOREIGN KEY (id_autorite) REFERENCES securite.autorite(id);


--
-- Name: fk_fm_cmlu_commentaire; Type: FK CONSTRAINT; Schema: forum; Owner: eliot
--

ALTER TABLE ONLY commentaire_lu
    ADD CONSTRAINT fk_fm_cmlu_commentaire FOREIGN KEY (id_commentaire) REFERENCES commentaire(id) ON DELETE CASCADE;


--
-- Name: fk_fm_commentaire_autorite; Type: FK CONSTRAINT; Schema: forum; Owner: eliot
--

ALTER TABLE ONLY commentaire
    ADD CONSTRAINT fk_fm_commentaire_autorite FOREIGN KEY (id_autorite) REFERENCES securite.autorite(id);


--
-- Name: fk_fm_commentaire_discussion; Type: FK CONSTRAINT; Schema: forum; Owner: eliot
--

ALTER TABLE ONLY commentaire
    ADD CONSTRAINT fk_fm_commentaire_discussion FOREIGN KEY (id_discussion) REFERENCES discussion(id) ON DELETE CASCADE;


--
-- Name: fk_fm_commentaire_etat_commentaire; Type: FK CONSTRAINT; Schema: forum; Owner: eliot
--

ALTER TABLE ONLY commentaire
    ADD CONSTRAINT fk_fm_commentaire_etat_commentaire FOREIGN KEY (code_etat_commentaire) REFERENCES etat_commentaire(code);


--
-- Name: fk_fm_discussion_autorite; Type: FK CONSTRAINT; Schema: forum; Owner: eliot
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT fk_fm_discussion_autorite FOREIGN KEY (id_autorite) REFERENCES securite.autorite(id);


--
-- Name: fk_fm_discussion_etat_discussion; Type: FK CONSTRAINT; Schema: forum; Owner: eliot
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT fk_fm_discussion_etat_discussion FOREIGN KEY (code_etat_discussion) REFERENCES etat_discussion(code);


--
-- Name: fk_fm_discussion_type_moderation; Type: FK CONSTRAINT; Schema: forum; Owner: eliot
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT fk_fm_discussion_type_moderation FOREIGN KEY (code_type_moderation) REFERENCES type_moderation(code);


SET search_path = impression, pg_catalog;

--
-- Name: fk_publipostage_suivi_classe_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_classe_id FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id);


--
-- Name: fk_publipostage_suivi_operateur_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_operateur_id FOREIGN KEY (operateur_id) REFERENCES ent.personne(id);


--
-- Name: fk_publipostage_suivi_personne_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_personne_id FOREIGN KEY (personne_id) REFERENCES ent.personne(id);


--
-- Name: fk_template_champ_memo_template_doc_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY template_champ_memo
    ADD CONSTRAINT fk_template_champ_memo_template_doc_id FOREIGN KEY (template_document_id) REFERENCES template_document(id);


--
-- Name: fk_template_doc_sous_template_eliot_template_doc_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY template_document_sous_template_eliot
    ADD CONSTRAINT fk_template_doc_sous_template_eliot_template_doc_id FOREIGN KEY (template_document_id) REFERENCES template_document(id);


--
-- Name: fk_template_doc_sous_template_eliot_template_eliot_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY template_document_sous_template_eliot
    ADD CONSTRAINT fk_template_doc_sous_template_eliot_template_eliot_id FOREIGN KEY (template_eliot_id) REFERENCES template_eliot(id);


--
-- Name: fk_template_document_etablissement_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY template_document
    ADD CONSTRAINT fk_template_document_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- Name: fk_template_document_template_eliot_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY template_document
    ADD CONSTRAINT fk_template_document_template_eliot_id FOREIGN KEY (template_eliot_id) REFERENCES template_eliot(id);


--
-- Name: fk_template_eliot_template_jasper_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT fk_template_eliot_template_jasper_id FOREIGN KEY (template_jasper_id) REFERENCES template_jasper(id);


--
-- Name: fk_template_eliot_type_donnees_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT fk_template_eliot_type_donnees_id FOREIGN KEY (type_donnees_id) REFERENCES template_type_donnees(id);


--
-- Name: fk_template_eliot_type_fonctionnalite_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT fk_template_eliot_type_fonctionnalite_id FOREIGN KEY (type_fonctionnalite_id) REFERENCES template_type_fonctionnalite(id);


--
-- Name: fk_template_jasper_sous_template_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY template_jasper
    ADD CONSTRAINT fk_template_jasper_sous_template_id FOREIGN KEY (sous_template_id) REFERENCES template_jasper(id);


--
-- Name: fk_template_type_fonctionnalite_parent_id; Type: FK CONSTRAINT; Schema: impression; Owner: eliot
--

ALTER TABLE ONLY template_type_fonctionnalite
    ADD CONSTRAINT fk_template_type_fonctionnalite_parent_id FOREIGN KEY (parent_id) REFERENCES template_type_fonctionnalite(id);


SET search_path = securite, pg_catalog;

--
-- Name: fk_autorisation_autorite; Type: FK CONSTRAINT; Schema: securite; Owner: eliot
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT fk_autorisation_autorite FOREIGN KEY (id_autorite) REFERENCES autorite(id) ON DELETE CASCADE;


--
-- Name: fk_autorisation_heritee_autorisation; Type: FK CONSTRAINT; Schema: securite; Owner: eliot
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT fk_autorisation_heritee_autorisation FOREIGN KEY (id_autorisation_heritee) REFERENCES autorisation(id);


--
-- Name: fk_autorisation_item; Type: FK CONSTRAINT; Schema: securite; Owner: eliot
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT fk_autorisation_item FOREIGN KEY (id_item) REFERENCES item(id);


--
-- Name: fk_autorite_import; Type: FK CONSTRAINT; Schema: securite; Owner: eliot
--

ALTER TABLE ONLY autorite
    ADD CONSTRAINT fk_autorite_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- Name: fk_item_import; Type: FK CONSTRAINT; Schema: securite; Owner: eliot
--

ALTER TABLE ONLY item
    ADD CONSTRAINT fk_item_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- Name: fk_item_item_parent; Type: FK CONSTRAINT; Schema: securite; Owner: eliot
--

ALTER TABLE ONLY item
    ADD CONSTRAINT fk_item_item_parent FOREIGN KEY (item_parent_id) REFERENCES item(id);


--
-- Name: fk_perimetre_import; Type: FK CONSTRAINT; Schema: securite; Owner: eliot
--

ALTER TABLE ONLY perimetre
    ADD CONSTRAINT fk_perimetre_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- Name: fk_perimetre_perimetre_parent; Type: FK CONSTRAINT; Schema: securite; Owner: eliot
--

ALTER TABLE ONLY perimetre
    ADD CONSTRAINT fk_perimetre_perimetre_parent FOREIGN KEY (perimetre_parent_id) REFERENCES perimetre(id);


--
-- Name: fk_perimetre_securite_item; Type: FK CONSTRAINT; Schema: securite; Owner: eliot
--

ALTER TABLE ONLY perimetre_securite
    ADD CONSTRAINT fk_perimetre_securite_item FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE;


--
-- Name: fk_perimetre_securite_perimetre; Type: FK CONSTRAINT; Schema: securite; Owner: eliot
--

ALTER TABLE ONLY perimetre_securite
    ADD CONSTRAINT fk_perimetre_securite_perimetre FOREIGN KEY (perimetre_id) REFERENCES perimetre(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


SET search_path = public, pg_catalog;

--
-- PostgreSQL database dump complete
--

