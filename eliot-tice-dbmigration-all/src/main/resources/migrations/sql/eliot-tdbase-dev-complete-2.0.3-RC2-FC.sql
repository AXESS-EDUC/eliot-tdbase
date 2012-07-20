--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.4
-- Dumped by pg_dump version 9.1.4
-- Started on 2012-07-19 17:57:31 CEST

SET statement_timeout = 0;
-- SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 6 (class 2615 OID 131740)
-- Name: aaf; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA aaf;


--
-- TOC entry 7 (class 2615 OID 131741)
-- Name: bascule_annee; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA bascule_annee;


--
-- TOC entry 8 (class 2615 OID 131742)
-- Name: ent; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ent;


--
-- TOC entry 20 (class 2615 OID 137566)
-- Name: ent_2011_2012; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ent_2011_2012;


--
-- TOC entry 9 (class 2615 OID 131743)
-- Name: entcdt; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA entcdt;


--
-- TOC entry 10 (class 2615 OID 131744)
-- Name: entdemon; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA entdemon;


--
-- TOC entry 11 (class 2615 OID 131745)
-- Name: entnotes; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA entnotes;


--
-- TOC entry 19 (class 2615 OID 137365)
-- Name: entnotes_2011_2012; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA entnotes_2011_2012;


--
-- TOC entry 12 (class 2615 OID 131746)
-- Name: enttemps; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA enttemps;


--
-- TOC entry 18 (class 2615 OID 137181)
-- Name: enttemps_2011_2012; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA enttemps_2011_2012;


--
-- TOC entry 13 (class 2615 OID 131747)
-- Name: forum; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA forum;


--
-- TOC entry 14 (class 2615 OID 131748)
-- Name: impression; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA impression;


--
-- TOC entry 15 (class 2615 OID 131749)
-- Name: securite; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA securite;


--
-- TOC entry 22 (class 2615 OID 138582)
-- Name: td; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA td;


--
-- TOC entry 21 (class 2615 OID 138542)
-- Name: tice; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tice;


--
-- TOC entry 17 (class 2615 OID 137108)
-- Name: udt; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA udt;


--
-- TOC entry 548 (class 3079 OID 11907)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

-- NE PASSE PAS SUR CLOUDFOUNDRY
-- CREATE OR REPLACE LANGUAGE  plpgsql ;

--
-- TOC entry 5167 (class 0 OID 0)
-- Dependencies: 548
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

-- COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = enttemps, pg_catalog;

--
-- TOC entry 560 (class 1255 OID 131750)
-- Dependencies: 1777 12
-- Name: agenda_before_insert(); Type: FUNCTION; Schema: enttemps; Owner: -
--

CREATE FUNCTION agenda_before_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $BODY$
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
      $BODY$;


SET search_path = aaf, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 179 (class 1259 OID 131751)
-- Dependencies: 6
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
-- TOC entry 180 (class 1259 OID 131757)
-- Dependencies: 6
-- Name: import_id_seq; Type: SEQUENCE; Schema: aaf; Owner: -
--

CREATE SEQUENCE import_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5168 (class 0 OID 0)
-- Dependencies: 180
-- Name: import_id_seq; Type: SEQUENCE SET; Schema: aaf; Owner: -
--

SELECT pg_catalog.setval('import_id_seq', 1, false);


--
-- TOC entry 181 (class 1259 OID 131759)
-- Dependencies: 3404 6
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
-- TOC entry 418 (class 1259 OID 134466)
-- Dependencies: 7
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
-- TOC entry 419 (class 1259 OID 134473)
-- Dependencies: 7
-- Name: etape_id_seq; Type: SEQUENCE; Schema: bascule_annee; Owner: -
--

CREATE SEQUENCE etape_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5169 (class 0 OID 0)
-- Dependencies: 419
-- Name: etape_id_seq; Type: SEQUENCE SET; Schema: bascule_annee; Owner: -
--

SELECT pg_catalog.setval('etape_id_seq', 1, false);


--
-- TOC entry 182 (class 1259 OID 131766)
-- Dependencies: 7
-- Name: historique_id_seq; Type: SEQUENCE; Schema: bascule_annee; Owner: -
--

CREATE SEQUENCE historique_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5170 (class 0 OID 0)
-- Dependencies: 182
-- Name: historique_id_seq; Type: SEQUENCE SET; Schema: bascule_annee; Owner: -
--

SELECT pg_catalog.setval('historique_id_seq', 1, false);


--
-- TOC entry 183 (class 1259 OID 131768)
-- Dependencies: 7
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
-- TOC entry 184 (class 1259 OID 131771)
-- Dependencies: 7
-- Name: verrou_id_seq; Type: SEQUENCE; Schema: bascule_annee; Owner: -
--

CREATE SEQUENCE verrou_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 184
-- Name: verrou_id_seq; Type: SEQUENCE SET; Schema: bascule_annee; Owner: -
--

SELECT pg_catalog.setval('verrou_id_seq', 1, false);


SET search_path = ent, pg_catalog;

--
-- TOC entry 185 (class 1259 OID 131773)
-- Dependencies: 8
-- Name: annee_scolaire; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE annee_scolaire (
    code character varying(30) NOT NULL,
    version integer NOT NULL,
    annee_en_cours boolean,
    id bigint NOT NULL
);


--
-- TOC entry 186 (class 1259 OID 131776)
-- Dependencies: 8
-- Name: annee_scolaire_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE annee_scolaire_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5172 (class 0 OID 0)
-- Dependencies: 186
-- Name: annee_scolaire_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('annee_scolaire_id_seq', 1, true);


--
-- TOC entry 187 (class 1259 OID 131778)
-- Dependencies: 8
-- Name: appartenance_groupe_groupe; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE appartenance_groupe_groupe (
    id bigint NOT NULL,
    groupe_personnes_parent_id bigint NOT NULL,
    groupe_personnes_enfant_id bigint NOT NULL
);


--
-- TOC entry 188 (class 1259 OID 131781)
-- Dependencies: 8
-- Name: appartenance_groupe_groupe_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE appartenance_groupe_groupe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 188
-- Name: appartenance_groupe_groupe_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('appartenance_groupe_groupe_id_seq', 1, false);


--
-- TOC entry 189 (class 1259 OID 131783)
-- Dependencies: 8
-- Name: appartenance_personne_groupe; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE appartenance_personne_groupe (
    id bigint NOT NULL,
    personne_id bigint NOT NULL,
    groupe_personnes_id bigint NOT NULL
);


--
-- TOC entry 190 (class 1259 OID 131786)
-- Dependencies: 8
-- Name: appartenance_personne_groupe_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE appartenance_personne_groupe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 190
-- Name: appartenance_personne_groupe_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('appartenance_personne_groupe_id_seq', 1, false);


--
-- TOC entry 326 (class 1259 OID 132335)
-- Dependencies: 8
-- Name: calendier_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE calendier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 326
-- Name: calendier_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('calendier_id_seq', 1, false);


--
-- TOC entry 327 (class 1259 OID 132337)
-- Dependencies: 8
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
-- TOC entry 191 (class 1259 OID 131788)
-- Dependencies: 8
-- Name: civilite; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE civilite (
    id bigint NOT NULL,
    libelle character varying(5) NOT NULL
);


--
-- TOC entry 192 (class 1259 OID 131791)
-- Dependencies: 8
-- Name: civilite_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE civilite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 192
-- Name: civilite_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('civilite_id_seq', 1, false);


--
-- TOC entry 229 (class 1259 OID 131925)
-- Dependencies: 3417 3418 8
-- Name: enseignement; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE enseignement (
    enseignant_id bigint NOT NULL,
    version integer NOT NULL,
    service_id integer NOT NULL,
    nb_heures double precision,
    version_import_sts integer DEFAULT (-1),
    actif boolean DEFAULT true,
    id bigint NOT NULL
);


--
-- TOC entry 422 (class 1259 OID 134522)
-- Dependencies: 8
-- Name: enseignement_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE enseignement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5177 (class 0 OID 0)
-- Dependencies: 422
-- Name: enseignement_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('enseignement_id_seq', 1, false);


--
-- TOC entry 193 (class 1259 OID 131793)
-- Dependencies: 3405 3406 3407 8
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
-- TOC entry 194 (class 1259 OID 131801)
-- Dependencies: 8
-- Name: etablissement_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE etablissement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5178 (class 0 OID 0)
-- Dependencies: 194
-- Name: etablissement_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('etablissement_id_seq', 1, false);


--
-- TOC entry 420 (class 1259 OID 134482)
-- Dependencies: 8
-- Name: fiche_eleve_commentaire; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE fiche_eleve_commentaire (
    id bigint NOT NULL,
    personne_id bigint NOT NULL,
    commentaire text
);


--
-- TOC entry 421 (class 1259 OID 134490)
-- Dependencies: 8
-- Name: fiche_eleve_commentaire_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE fiche_eleve_commentaire_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 421
-- Name: fiche_eleve_commentaire_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('fiche_eleve_commentaire_id_seq', 1, false);


--
-- TOC entry 195 (class 1259 OID 131803)
-- Dependencies: 3408 8
-- Name: filiere; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE filiere (
    id bigint NOT NULL,
    id_externe character varying(30),
    libelle character varying(50),
    version integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 196 (class 1259 OID 131807)
-- Dependencies: 8
-- Name: filiere_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE filiere_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 196
-- Name: filiere_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('filiere_id_seq', 1, false);


--
-- TOC entry 197 (class 1259 OID 131809)
-- Dependencies: 8
-- Name: fonction; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE fonction (
    id bigint NOT NULL,
    code character varying(32) NOT NULL,
    libelle character varying(255)
);


--
-- TOC entry 198 (class 1259 OID 131812)
-- Dependencies: 8
-- Name: fonction_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE fonction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 198
-- Name: fonction_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('fonction_id_seq', 19, true);


--
-- TOC entry 199 (class 1259 OID 131814)
-- Dependencies: 3409 8
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
-- TOC entry 200 (class 1259 OID 131821)
-- Dependencies: 8
-- Name: groupe_personnes_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE groupe_personnes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 200
-- Name: groupe_personnes_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('groupe_personnes_id_seq', 1, false);


--
-- TOC entry 201 (class 1259 OID 131823)
-- Dependencies: 8
-- Name: inscription_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE inscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 201
-- Name: inscription_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('inscription_id_seq', 1, false);


--
-- TOC entry 202 (class 1259 OID 131825)
-- Dependencies: 3410 8
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
-- TOC entry 203 (class 1259 OID 131831)
-- Dependencies: 8
-- Name: matiere_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE matiere_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 203
-- Name: matiere_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('matiere_id_seq', 1, false);


--
-- TOC entry 204 (class 1259 OID 131833)
-- Dependencies: 8
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
-- TOC entry 205 (class 1259 OID 131839)
-- Dependencies: 8
-- Name: mef_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE mef_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 205
-- Name: mef_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('mef_id_seq', 1, false);


--
-- TOC entry 206 (class 1259 OID 131841)
-- Dependencies: 8
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
-- TOC entry 207 (class 1259 OID 131847)
-- Dependencies: 8
-- Name: modalite_cours_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE modalite_cours_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 207
-- Name: modalite_cours_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('modalite_cours_id_seq', 1, false);


--
-- TOC entry 208 (class 1259 OID 131849)
-- Dependencies: 8
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
-- TOC entry 209 (class 1259 OID 131855)
-- Dependencies: 8
-- Name: modalite_matiere_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE modalite_matiere_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 209
-- Name: modalite_matiere_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('modalite_matiere_id_seq', 1, false);


--
-- TOC entry 210 (class 1259 OID 131857)
-- Dependencies: 8
-- Name: niveau; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE niveau (
    id bigint NOT NULL,
    libelle_court character varying(128),
    libelle_long character varying(255),
    libelle_edition character varying(255)
);


--
-- TOC entry 211 (class 1259 OID 131863)
-- Dependencies: 8
-- Name: niveau_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE niveau_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 211
-- Name: niveau_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('niveau_id_seq', 1, true);


--
-- TOC entry 212 (class 1259 OID 131865)
-- Dependencies: 8
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
-- TOC entry 213 (class 1259 OID 131868)
-- Dependencies: 8
-- Name: periode_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 213
-- Name: periode_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('periode_id_seq', 6, true);


--
-- TOC entry 214 (class 1259 OID 131870)
-- Dependencies: 8
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
-- TOC entry 215 (class 1259 OID 131876)
-- Dependencies: 8
-- Name: personne_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE personne_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 215
-- Name: personne_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('personne_id_seq', 1, false);


--
-- TOC entry 216 (class 1259 OID 131878)
-- Dependencies: 3411 8
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
    udt_import_id bigint
);


--
-- TOC entry 217 (class 1259 OID 131882)
-- Dependencies: 8
-- Name: personne_propriete_scolarite_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE personne_propriete_scolarite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 217
-- Name: personne_propriete_scolarite_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('personne_propriete_scolarite_id_seq', 1, false);


--
-- TOC entry 218 (class 1259 OID 131884)
-- Dependencies: 8
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
-- TOC entry 219 (class 1259 OID 131890)
-- Dependencies: 8
-- Name: porteur_ent_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE porteur_ent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 219
-- Name: porteur_ent_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('porteur_ent_id_seq', 1, false);


--
-- TOC entry 220 (class 1259 OID 131892)
-- Dependencies: 3412 3413 3414 3415 8
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
    sms_fournisseur_etablissement_id bigint,
    annee_scolaire_id bigint NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 131901)
-- Dependencies: 8
-- Name: preference_etablissement_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE preference_etablissement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 221
-- Name: preference_etablissement_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('preference_etablissement_id_seq', 1, false);


--
-- TOC entry 222 (class 1259 OID 131906)
-- Dependencies: 8
-- Name: preference_utilisateur_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE preference_utilisateur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 222
-- Name: preference_utilisateur_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('preference_utilisateur_id_seq', 1, false);


--
-- TOC entry 223 (class 1259 OID 131908)
-- Dependencies: 3416 8
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
    porteur_ent_id bigint,
    source_id bigint NOT NULL
);


--
-- TOC entry 224 (class 1259 OID 131912)
-- Dependencies: 8
-- Name: propriete_scolarite_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE propriete_scolarite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 224
-- Name: propriete_scolarite_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('propriete_scolarite_id_seq', 1, false);


--
-- TOC entry 225 (class 1259 OID 131914)
-- Dependencies: 8
-- Name: regime; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE regime (
    id bigint NOT NULL,
    code character varying(32) NOT NULL
);


--
-- TOC entry 226 (class 1259 OID 131917)
-- Dependencies: 8
-- Name: regime_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE regime_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 226
-- Name: regime_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('regime_id_seq', 3, true);


--
-- TOC entry 227 (class 1259 OID 131919)
-- Dependencies: 8
-- Name: rel_classe_filiere; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE rel_classe_filiere (
    classe_id bigint NOT NULL,
    filiere_id bigint NOT NULL
);


--
-- TOC entry 228 (class 1259 OID 131922)
-- Dependencies: 8
-- Name: rel_classe_groupe; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE rel_classe_groupe (
    classe_id bigint NOT NULL,
    groupe_id bigint NOT NULL
);


--
-- TOC entry 230 (class 1259 OID 131930)
-- Dependencies: 3419 3420 8
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
-- TOC entry 231 (class 1259 OID 131938)
-- Dependencies: 8
-- Name: rel_periode_service_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE rel_periode_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 231
-- Name: rel_periode_service_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('rel_periode_service_id_seq', 1, false);


--
-- TOC entry 232 (class 1259 OID 131940)
-- Dependencies: 3421 3422 3423 8
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
    est_validee boolean DEFAULT false
);


--
-- TOC entry 233 (class 1259 OID 131946)
-- Dependencies: 8
-- Name: responsable_eleve_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE responsable_eleve_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 233
-- Name: responsable_eleve_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('responsable_eleve_id_seq', 1, false);


--
-- TOC entry 234 (class 1259 OID 131948)
-- Dependencies: 3424 8
-- Name: responsable_propriete_scolarite; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
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
-- TOC entry 235 (class 1259 OID 131952)
-- Dependencies: 8
-- Name: responsable_propriete_scolarite_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE responsable_propriete_scolarite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 235
-- Name: responsable_propriete_scolarite_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('responsable_propriete_scolarite_id_seq', 1, false);


--
-- TOC entry 236 (class 1259 OID 131954)
-- Dependencies: 3425 3426 3427 3428 8
-- Name: service; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE service (
    id integer NOT NULL,
    version integer NOT NULL,
    nb_heures double precision,
    co_ens boolean,
    libelle_matiere character varying(1024),
    modalite_cours_id bigint,
    matiere_id bigint NOT NULL,
    structure_enseignement_id bigint,
    version_import_sts integer DEFAULT (-1),
    actif boolean DEFAULT true,
    origine character varying(10) DEFAULT 'AUTO'::character varying NOT NULL,
    service_principal boolean DEFAULT false NOT NULL
);


--
-- TOC entry 237 (class 1259 OID 131964)
-- Dependencies: 236 8
-- Name: services_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 237
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: ent; Owner: -
--

ALTER SEQUENCE services_id_seq OWNED BY service.id;


--
-- TOC entry 5201 (class 0 OID 0)
-- Dependencies: 237
-- Name: services_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('services_id_seq', 1, false);


--
-- TOC entry 238 (class 1259 OID 131966)
-- Dependencies: 8
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
-- TOC entry 239 (class 1259 OID 131972)
-- Dependencies: 8
-- Name: signature_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE signature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5202 (class 0 OID 0)
-- Dependencies: 239
-- Name: signature_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('signature_id_seq', 1, false);


--
-- TOC entry 240 (class 1259 OID 131974)
-- Dependencies: 8
-- Name: source_import; Type: TABLE; Schema: ent; Owner: -; Tablespace: 
--

CREATE TABLE source_import (
    id bigint NOT NULL,
    code character varying(30) NOT NULL,
    libelle character varying(30) NOT NULL
);


--
-- TOC entry 241 (class 1259 OID 131977)
-- Dependencies: 3430 8
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
-- TOC entry 242 (class 1259 OID 131984)
-- Dependencies: 8
-- Name: sous_service_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE sous_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5203 (class 0 OID 0)
-- Dependencies: 242
-- Name: sous_service_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('sous_service_id_seq', 1, false);


--
-- TOC entry 243 (class 1259 OID 131986)
-- Dependencies: 3431 3432 3433 8
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
    version_import_sts integer DEFAULT (-1),
    actif boolean DEFAULT true,
    niveau_id bigint,
    brevet_serie_id bigint,
    date_publication_brevet timestamp with time zone,
    CONSTRAINT chk_structure_enseignement_validite_niveau CHECK ((((niveau_id IS NULL) AND ((type)::text = 'GROUPE'::text)) OR ((niveau_id IS NOT NULL) AND ((type)::text = 'CLASSE'::text))))
);


--
-- TOC entry 244 (class 1259 OID 131991)
-- Dependencies: 8
-- Name: structure_enseignement_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE structure_enseignement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5204 (class 0 OID 0)
-- Dependencies: 244
-- Name: structure_enseignement_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('structure_enseignement_id_seq', 1, false);


--
-- TOC entry 245 (class 1259 OID 131993)
-- Dependencies: 8
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
-- TOC entry 246 (class 1259 OID 131996)
-- Dependencies: 8
-- Name: type_periode_id_seq; Type: SEQUENCE; Schema: ent; Owner: -
--

CREATE SEQUENCE type_periode_id_seq
    START WITH 1
    INCREMENT BY 7
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5205 (class 0 OID 0)
-- Dependencies: 246
-- Name: type_periode_id_seq; Type: SEQUENCE SET; Schema: ent; Owner: -
--

SELECT pg_catalog.setval('type_periode_id_seq', 5, true);


SET search_path = securite, pg_catalog;

--
-- TOC entry 247 (class 1259 OID 131998)
-- Dependencies: 3434 15
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
    id_sts character varying(128)
);


SET search_path = ent, pg_catalog;

--
-- TOC entry 423 (class 1259 OID 134625)
-- Dependencies: 3403 8
-- Name: vue_annuaire; Type: VIEW; Schema: ent; Owner: -
--

CREATE VIEW vue_annuaire AS
    SELECT p.nom, p.prenom, e.nom_affichage AS nom_etab, se.code AS structure_code, se.type AS structure_type, se.actif AS structure_actif, f.code AS fonction_code, ps.responsable_structure_enseignement AS resp_structure, an.code AS annee_code, niv.libelle_court AS niveau_lib, mat.libelle_court AS matiere_lib, mef.code AS mef_code, p.id AS personne_id, p.autorite_id, pps.id AS pps_id, e.id AS etablissement_id, se.id AS structure_id, f.id AS fonction_id, an.id AS annee_id, niv.id AS niveau_id, mat.id AS matiere_id, mef.id AS mef_id, aut.id_externe FROM ((((((((((personne p JOIN personne_propriete_scolarite pps ON (((pps.personne_id = p.id) AND (pps.est_active = true)))) JOIN propriete_scolarite ps ON ((ps.id = pps.propriete_scolarite_id))) LEFT JOIN etablissement e ON ((e.id = ps.etablissement_id))) LEFT JOIN structure_enseignement se ON ((se.id = ps.structure_enseignement_id))) LEFT JOIN fonction f ON ((f.id = ps.fonction_id))) LEFT JOIN annee_scolaire an ON ((an.id = ps.annee_scolaire_id))) LEFT JOIN niveau niv ON ((niv.id = ps.niveau_id))) LEFT JOIN matiere mat ON ((mat.id = ps.matiere_id))) LEFT JOIN mef mef ON ((mef.id = ps.mef_id))) LEFT JOIN securite.autorite aut ON ((p.autorite_id = aut.id))) ORDER BY p.nom, p.prenom;


SET search_path = ent_2011_2012, pg_catalog;

--
-- TOC entry 498 (class 1259 OID 137567)
-- Dependencies: 20
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
-- TOC entry 499 (class 1259 OID 137574)
-- Dependencies: 3540 3541 20
-- Name: enseignement; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE enseignement (
    enseignant_id bigint NOT NULL,
    version integer NOT NULL,
    service_id integer NOT NULL,
    nb_heures double precision,
    version_import_sts integer DEFAULT (-1),
    actif boolean DEFAULT true,
    id bigint NOT NULL
);


--
-- TOC entry 500 (class 1259 OID 137583)
-- Dependencies: 3542 20
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
-- TOC entry 501 (class 1259 OID 137596)
-- Dependencies: 20
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
-- TOC entry 502 (class 1259 OID 137606)
-- Dependencies: 20
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
-- TOC entry 503 (class 1259 OID 137613)
-- Dependencies: 3543 20
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
    udt_import_id bigint
);


--
-- TOC entry 504 (class 1259 OID 137619)
-- Dependencies: 3544 3545 3546 3547 20
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
-- TOC entry 505 (class 1259 OID 137633)
-- Dependencies: 3548 20
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
    porteur_ent_id bigint,
    source_id bigint NOT NULL
);


--
-- TOC entry 506 (class 1259 OID 137639)
-- Dependencies: 20
-- Name: rel_classe_filiere; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE rel_classe_filiere (
    classe_id bigint NOT NULL,
    filiere_id bigint NOT NULL
);


--
-- TOC entry 507 (class 1259 OID 137644)
-- Dependencies: 20
-- Name: rel_classe_groupe; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE rel_classe_groupe (
    classe_id bigint NOT NULL,
    groupe_id bigint NOT NULL
);


--
-- TOC entry 508 (class 1259 OID 137649)
-- Dependencies: 3549 3550 20
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
-- TOC entry 509 (class 1259 OID 137661)
-- Dependencies: 3551 20
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
-- TOC entry 510 (class 1259 OID 137667)
-- Dependencies: 3552 3553 3554 3555 3556 20
-- Name: service; Type: TABLE; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE service (
    id integer DEFAULT nextval('ent.services_id_seq'::regclass) NOT NULL,
    version integer NOT NULL,
    nb_heures double precision,
    co_ens boolean,
    libelle_matiere character varying(1024),
    modalite_cours_id bigint,
    matiere_id bigint NOT NULL,
    structure_enseignement_id bigint,
    version_import_sts integer DEFAULT (-1),
    actif boolean DEFAULT true,
    origine character varying(10) DEFAULT 'AUTO'::character varying NOT NULL,
    service_principal boolean DEFAULT false NOT NULL
);


--
-- TOC entry 511 (class 1259 OID 137680)
-- Dependencies: 3557 20
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
-- TOC entry 512 (class 1259 OID 137691)
-- Dependencies: 3558 3559 3560 20
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
-- TOC entry 248 (class 1259 OID 132010)
-- Dependencies: 3435 3436 3437 9
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
-- TOC entry 249 (class 1259 OID 132019)
-- Dependencies: 9
-- Name: activite_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE activite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5206 (class 0 OID 0)
-- Dependencies: 249
-- Name: activite_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('activite_id_seq', 1, false);


--
-- TOC entry 250 (class 1259 OID 132021)
-- Dependencies: 3438 3439 9
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
-- TOC entry 251 (class 1259 OID 132029)
-- Dependencies: 9
-- Name: cahier_de_textes_copie_info_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE cahier_de_textes_copie_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5207 (class 0 OID 0)
-- Dependencies: 251
-- Name: cahier_de_textes_copie_info_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('cahier_de_textes_copie_info_id_seq', 1, false);


--
-- TOC entry 252 (class 1259 OID 132031)
-- Dependencies: 9
-- Name: cahier_de_textes_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE cahier_de_textes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5208 (class 0 OID 0)
-- Dependencies: 252
-- Name: cahier_de_textes_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('cahier_de_textes_id_seq', 1, false);


--
-- TOC entry 253 (class 1259 OID 132033)
-- Dependencies: 3440 9
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
-- TOC entry 254 (class 1259 OID 132040)
-- Dependencies: 9
-- Name: chapitre_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE chapitre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5209 (class 0 OID 0)
-- Dependencies: 254
-- Name: chapitre_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('chapitre_id_seq', 1, false);


--
-- TOC entry 255 (class 1259 OID 132042)
-- Dependencies: 9
-- Name: contexte_activite; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE contexte_activite (
    id bigint NOT NULL,
    code character varying(5) NOT NULL,
    nom character varying(255) NOT NULL,
    description text
);


--
-- TOC entry 256 (class 1259 OID 132048)
-- Dependencies: 9
-- Name: contexte_activite_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE contexte_activite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5210 (class 0 OID 0)
-- Dependencies: 256
-- Name: contexte_activite_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('contexte_activite_id_seq', 1, false);


--
-- TOC entry 257 (class 1259 OID 132050)
-- Dependencies: 9
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
-- TOC entry 258 (class 1259 OID 132053)
-- Dependencies: 9
-- Name: date_activite_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE date_activite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5211 (class 0 OID 0)
-- Dependencies: 258
-- Name: date_activite_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('date_activite_id_seq', 1, false);


--
-- TOC entry 259 (class 1259 OID 132055)
-- Dependencies: 3441 9
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
-- TOC entry 260 (class 1259 OID 132062)
-- Dependencies: 9
-- Name: dossier_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE dossier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5212 (class 0 OID 0)
-- Dependencies: 260
-- Name: dossier_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('dossier_id_seq', 1, false);


--
-- TOC entry 261 (class 1259 OID 132072)
-- Dependencies: 3442 9
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
-- TOC entry 262 (class 1259 OID 132078)
-- Dependencies: 9
-- Name: fichier_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE fichier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5213 (class 0 OID 0)
-- Dependencies: 262
-- Name: fichier_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('fichier_id_seq', 1, false);


--
-- TOC entry 263 (class 1259 OID 132080)
-- Dependencies: 3443 3444 3445 9
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
-- TOC entry 424 (class 1259 OID 135472)
-- Dependencies: 9
-- Name: rel_activite_acteur_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE rel_activite_acteur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5214 (class 0 OID 0)
-- Dependencies: 424
-- Name: rel_activite_acteur_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('rel_activite_acteur_id_seq', 1, false);


--
-- TOC entry 264 (class 1259 OID 132089)
-- Dependencies: 3446 9
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
-- TOC entry 425 (class 1259 OID 135478)
-- Dependencies: 9
-- Name: rel_cahier_acteur_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE rel_cahier_acteur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5215 (class 0 OID 0)
-- Dependencies: 425
-- Name: rel_cahier_acteur_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('rel_cahier_acteur_id_seq', 1, false);


--
-- TOC entry 265 (class 1259 OID 132093)
-- Dependencies: 3447 9
-- Name: rel_cahier_groupe; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE rel_cahier_groupe (
    cahier_de_textes_id bigint NOT NULL,
    groupe_id bigint NOT NULL,
    notification_obligatoire boolean DEFAULT false NOT NULL,
    id bigint NOT NULL
);


--
-- TOC entry 426 (class 1259 OID 135484)
-- Dependencies: 9
-- Name: rel_cahier_groupe_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE rel_cahier_groupe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5216 (class 0 OID 0)
-- Dependencies: 426
-- Name: rel_cahier_groupe_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('rel_cahier_groupe_id_seq', 1, false);


--
-- TOC entry 266 (class 1259 OID 132097)
-- Dependencies: 9
-- Name: rel_dossier_autorisation_cahier; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE rel_dossier_autorisation_cahier (
    dossier_id bigint NOT NULL,
    autorisation_id bigint NOT NULL,
    id bigint NOT NULL
);


--
-- TOC entry 427 (class 1259 OID 135490)
-- Dependencies: 9
-- Name: rel_dossier_autorisation_cahier_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE rel_dossier_autorisation_cahier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5217 (class 0 OID 0)
-- Dependencies: 427
-- Name: rel_dossier_autorisation_cahier_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('rel_dossier_autorisation_cahier_id_seq', 1, false);


--
-- TOC entry 267 (class 1259 OID 132100)
-- Dependencies: 3448 3449 3450 9
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
-- TOC entry 268 (class 1259 OID 132108)
-- Dependencies: 9
-- Name: ressource_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE ressource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5218 (class 0 OID 0)
-- Dependencies: 268
-- Name: ressource_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('ressource_id_seq', 1, false);


--
-- TOC entry 269 (class 1259 OID 132110)
-- Dependencies: 9
-- Name: textes_preferences_utilisateur; Type: TABLE; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE TABLE textes_preferences_utilisateur (
    id bigint NOT NULL,
    utilisateur_id bigint NOT NULL,
    date_derniere_notification timestamp without time zone
);


--
-- TOC entry 270 (class 1259 OID 132113)
-- Dependencies: 9
-- Name: textes_preferences_utilisateur_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE textes_preferences_utilisateur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5219 (class 0 OID 0)
-- Dependencies: 270
-- Name: textes_preferences_utilisateur_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('textes_preferences_utilisateur_id_seq', 1, false);


--
-- TOC entry 271 (class 1259 OID 132115)
-- Dependencies: 9
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
-- TOC entry 272 (class 1259 OID 132121)
-- Dependencies: 9
-- Name: type_activite_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE type_activite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5220 (class 0 OID 0)
-- Dependencies: 272
-- Name: type_activite_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('type_activite_id_seq', 1, true);


--
-- TOC entry 273 (class 1259 OID 132123)
-- Dependencies: 9
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
-- TOC entry 274 (class 1259 OID 132129)
-- Dependencies: 9
-- Name: visa_id_seq; Type: SEQUENCE; Schema: entcdt; Owner: -
--

CREATE SEQUENCE visa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5221 (class 0 OID 0)
-- Dependencies: 274
-- Name: visa_id_seq; Type: SEQUENCE SET; Schema: entcdt; Owner: -
--

SELECT pg_catalog.setval('visa_id_seq', 1, false);


SET search_path = entdemon, pg_catalog;

--
-- TOC entry 275 (class 1259 OID 132131)
-- Dependencies: 10
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
-- TOC entry 276 (class 1259 OID 132137)
-- Dependencies: 10
-- Name: demande_traitement_id_seq; Type: SEQUENCE; Schema: entdemon; Owner: -
--

CREATE SEQUENCE demande_traitement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5222 (class 0 OID 0)
-- Dependencies: 276
-- Name: demande_traitement_id_seq; Type: SEQUENCE SET; Schema: entdemon; Owner: -
--

SELECT pg_catalog.setval('demande_traitement_id_seq', 1, false);


SET search_path = entnotes, pg_catalog;

--
-- TOC entry 277 (class 1259 OID 132139)
-- Dependencies: 11
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
-- TOC entry 278 (class 1259 OID 132145)
-- Dependencies: 11
-- Name: appreciation_classe_enseignement_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE appreciation_classe_enseignement_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5223 (class 0 OID 0)
-- Dependencies: 278
-- Name: appreciation_classe_enseignement_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('appreciation_classe_enseignement_periode_id_seq', 1, false);


--
-- TOC entry 279 (class 1259 OID 132147)
-- Dependencies: 11
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
-- TOC entry 280 (class 1259 OID 132153)
-- Dependencies: 11
-- Name: appreciation_eleve_enseignement_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE appreciation_eleve_enseignement_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5224 (class 0 OID 0)
-- Dependencies: 280
-- Name: appreciation_eleve_enseignement_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('appreciation_eleve_enseignement_periode_id_seq', 1, false);


--
-- TOC entry 281 (class 1259 OID 132155)
-- Dependencies: 11
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
-- TOC entry 282 (class 1259 OID 132161)
-- Dependencies: 11
-- Name: appreciation_eleve_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE appreciation_eleve_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5225 (class 0 OID 0)
-- Dependencies: 282
-- Name: appreciation_eleve_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('appreciation_eleve_periode_id_seq', 1, false);


--
-- TOC entry 283 (class 1259 OID 132163)
-- Dependencies: 11
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
-- TOC entry 284 (class 1259 OID 132169)
-- Dependencies: 11
-- Name: avis_conseil_de_classe_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE avis_conseil_de_classe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5226 (class 0 OID 0)
-- Dependencies: 284
-- Name: avis_conseil_de_classe_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('avis_conseil_de_classe_id_seq', 1, false);


--
-- TOC entry 285 (class 1259 OID 132171)
-- Dependencies: 11
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
-- TOC entry 286 (class 1259 OID 132177)
-- Dependencies: 11
-- Name: avis_orientation_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE avis_orientation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5227 (class 0 OID 0)
-- Dependencies: 286
-- Name: avis_orientation_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('avis_orientation_id_seq', 1, false);


--
-- TOC entry 430 (class 1259 OID 136723)
-- Dependencies: 11
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
-- TOC entry 446 (class 1259 OID 137099)
-- Dependencies: 11
-- Name: brevet_epreuve_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE brevet_epreuve_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5228 (class 0 OID 0)
-- Dependencies: 446
-- Name: brevet_epreuve_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('brevet_epreuve_id_seq', 97, true);


--
-- TOC entry 443 (class 1259 OID 137071)
-- Dependencies: 11
-- Name: brevet_fiche; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE brevet_fiche (
    id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    annee_scolaire_id bigint NOT NULL,
    avis character varying(256)
);


--
-- TOC entry 444 (class 1259 OID 137076)
-- Dependencies: 11
-- Name: brevet_fiche_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE brevet_fiche_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5229 (class 0 OID 0)
-- Dependencies: 444
-- Name: brevet_fiche_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('brevet_fiche_id_seq', 1, false);


--
-- TOC entry 433 (class 1259 OID 136767)
-- Dependencies: 11
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
-- TOC entry 434 (class 1259 OID 136790)
-- Dependencies: 11
-- Name: brevet_note_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE brevet_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5230 (class 0 OID 0)
-- Dependencies: 434
-- Name: brevet_note_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('brevet_note_id_seq', 1, false);


--
-- TOC entry 431 (class 1259 OID 136745)
-- Dependencies: 11
-- Name: brevet_note_valeur_textuelle; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE brevet_note_valeur_textuelle (
    id bigint NOT NULL,
    valeur character varying(2) NOT NULL
);


--
-- TOC entry 435 (class 1259 OID 136792)
-- Dependencies: 11
-- Name: brevet_rel_epreuve_matiere; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE brevet_rel_epreuve_matiere (
    id bigint NOT NULL,
    epreuve_id bigint NOT NULL,
    matiere_id bigint NOT NULL
);


--
-- TOC entry 436 (class 1259 OID 136809)
-- Dependencies: 11
-- Name: brevet_rel_epreuve_matiere_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE brevet_rel_epreuve_matiere_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5231 (class 0 OID 0)
-- Dependencies: 436
-- Name: brevet_rel_epreuve_matiere_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('brevet_rel_epreuve_matiere_id_seq', 1, false);


--
-- TOC entry 432 (class 1259 OID 136750)
-- Dependencies: 11
-- Name: brevet_rel_epreuve_note_valeur_textuelle; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE brevet_rel_epreuve_note_valeur_textuelle (
    brevet_epreuve_id bigint NOT NULL,
    valeur_textuelle_id bigint NOT NULL
);


--
-- TOC entry 447 (class 1259 OID 137101)
-- Dependencies: 11
-- Name: brevet_rel_epreuve_note_valeur_textuelle_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE brevet_rel_epreuve_note_valeur_textuelle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5232 (class 0 OID 0)
-- Dependencies: 447
-- Name: brevet_rel_epreuve_note_valeur_textuelle_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('brevet_rel_epreuve_note_valeur_textuelle_id_seq', 1, false);


--
-- TOC entry 429 (class 1259 OID 136718)
-- Dependencies: 11
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
-- TOC entry 445 (class 1259 OID 137097)
-- Dependencies: 11
-- Name: brevet_serie_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE brevet_serie_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5233 (class 0 OID 0)
-- Dependencies: 445
-- Name: brevet_serie_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('brevet_serie_id_seq', 8, true);


--
-- TOC entry 287 (class 1259 OID 132182)
-- Dependencies: 11
-- Name: dernier_changement_dans_classe_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE dernier_changement_dans_classe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5234 (class 0 OID 0)
-- Dependencies: 287
-- Name: dernier_changement_dans_classe_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('dernier_changement_dans_classe_id_seq', 1, false);


--
-- TOC entry 288 (class 1259 OID 132184)
-- Dependencies: 11
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
-- TOC entry 289 (class 1259 OID 132187)
-- Dependencies: 11
-- Name: dirty_moyenne_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE dirty_moyenne_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5235 (class 0 OID 0)
-- Dependencies: 289
-- Name: dirty_moyenne_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('dirty_moyenne_id_seq', 1, false);


--
-- TOC entry 290 (class 1259 OID 132189)
-- Dependencies: 3451 3452 3453 3454 11
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
-- TOC entry 291 (class 1259 OID 132198)
-- Dependencies: 11
-- Name: evaluation_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE evaluation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5236 (class 0 OID 0)
-- Dependencies: 291
-- Name: evaluation_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('evaluation_id_seq', 1, false);


--
-- TOC entry 292 (class 1259 OID 132200)
-- Dependencies: 3455 11
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
-- TOC entry 293 (class 1259 OID 132204)
-- Dependencies: 11
-- Name: info_calcul_moyennes_classe_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE info_calcul_moyennes_classe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5237 (class 0 OID 0)
-- Dependencies: 293
-- Name: info_calcul_moyennes_classe_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('info_calcul_moyennes_classe_id_seq', 1, false);


--
-- TOC entry 294 (class 1259 OID 132206)
-- Dependencies: 11
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
-- TOC entry 295 (class 1259 OID 132212)
-- Dependencies: 11
-- Name: modele_appreciation_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE modele_appreciation_id_seq
    START WITH 10
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5238 (class 0 OID 0)
-- Dependencies: 295
-- Name: modele_appreciation_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('modele_appreciation_id_seq', 10, false);


--
-- TOC entry 296 (class 1259 OID 132214)
-- Dependencies: 11
-- Name: modele_appreciation_professeur; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE modele_appreciation_professeur (
    id bigint NOT NULL,
    autorite_id bigint NOT NULL,
    texte character varying(1024) NOT NULL,
    version integer NOT NULL
);


--
-- TOC entry 297 (class 1259 OID 132220)
-- Dependencies: 11
-- Name: modele_appreciation_professeur_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE modele_appreciation_professeur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5239 (class 0 OID 0)
-- Dependencies: 297
-- Name: modele_appreciation_professeur_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('modele_appreciation_professeur_id_seq', 1, false);


--
-- TOC entry 298 (class 1259 OID 132222)
-- Dependencies: 3456 3457 11
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
-- TOC entry 299 (class 1259 OID 132229)
-- Dependencies: 11
-- Name: note_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 299
-- Name: note_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('note_id_seq', 1, false);


--
-- TOC entry 441 (class 1259 OID 136947)
-- Dependencies: 11
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
-- TOC entry 442 (class 1259 OID 136952)
-- Dependencies: 11
-- Name: note_textuelle_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE note_textuelle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 442
-- Name: note_textuelle_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('note_textuelle_id_seq', 1, false);


--
-- TOC entry 300 (class 1259 OID 132231)
-- Dependencies: 11
-- Name: rel_evaluation_periode; Type: TABLE; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE TABLE rel_evaluation_periode (
    evaluation_id bigint NOT NULL,
    periode_id bigint NOT NULL
);


--
-- TOC entry 301 (class 1259 OID 132234)
-- Dependencies: 11
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
-- TOC entry 302 (class 1259 OID 132240)
-- Dependencies: 11
-- Name: resultat_classe_enseignement_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_classe_enseignement_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 302
-- Name: resultat_classe_enseignement_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_classe_enseignement_periode_id_seq', 1, false);


--
-- TOC entry 303 (class 1259 OID 132242)
-- Dependencies: 11
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
-- TOC entry 304 (class 1259 OID 132248)
-- Dependencies: 11
-- Name: resultat_classe_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_classe_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 304
-- Name: resultat_classe_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_classe_periode_id_seq', 1, false);


--
-- TOC entry 305 (class 1259 OID 132250)
-- Dependencies: 11
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
-- TOC entry 306 (class 1259 OID 132256)
-- Dependencies: 11
-- Name: resultat_classe_service_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_classe_service_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 306
-- Name: resultat_classe_service_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_classe_service_periode_id_seq', 1, false);


--
-- TOC entry 307 (class 1259 OID 132258)
-- Dependencies: 11
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
-- TOC entry 308 (class 1259 OID 132264)
-- Dependencies: 11
-- Name: resultat_classe_sous_service_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_classe_sous_service_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 308
-- Name: resultat_classe_sous_service_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_classe_sous_service_periode_id_seq', 1, false);


--
-- TOC entry 309 (class 1259 OID 132266)
-- Dependencies: 3458 11
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
-- TOC entry 310 (class 1259 OID 132272)
-- Dependencies: 11
-- Name: resultat_eleve_enseignement_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_eleve_enseignement_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 310
-- Name: resultat_eleve_enseignement_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_eleve_enseignement_periode_id_seq', 1, false);


--
-- TOC entry 311 (class 1259 OID 132274)
-- Dependencies: 3459 11
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
-- TOC entry 312 (class 1259 OID 132280)
-- Dependencies: 11
-- Name: resultat_eleve_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_eleve_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 312
-- Name: resultat_eleve_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_eleve_periode_id_seq', 1, false);


--
-- TOC entry 313 (class 1259 OID 132282)
-- Dependencies: 3460 11
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
-- TOC entry 314 (class 1259 OID 132288)
-- Dependencies: 11
-- Name: resultat_eleve_service_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_eleve_service_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 314
-- Name: resultat_eleve_service_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_eleve_service_periode_id_seq', 1, false);


--
-- TOC entry 315 (class 1259 OID 132290)
-- Dependencies: 3461 11
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
-- TOC entry 316 (class 1259 OID 132296)
-- Dependencies: 11
-- Name: resultat_eleve_sous_service_periode_id_seq; Type: SEQUENCE; Schema: entnotes; Owner: -
--

CREATE SEQUENCE resultat_eleve_sous_service_periode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 316
-- Name: resultat_eleve_sous_service_periode_id_seq; Type: SEQUENCE SET; Schema: entnotes; Owner: -
--

SELECT pg_catalog.setval('resultat_eleve_sous_service_periode_id_seq', 1, false);


SET search_path = entnotes_2011_2012, pg_catalog;

--
-- TOC entry 477 (class 1259 OID 137376)
-- Dependencies: 19
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
-- TOC entry 478 (class 1259 OID 137386)
-- Dependencies: 19
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
-- TOC entry 476 (class 1259 OID 137366)
-- Dependencies: 19
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
-- TOC entry 492 (class 1259 OID 137519)
-- Dependencies: 19
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
-- TOC entry 496 (class 1259 OID 137551)
-- Dependencies: 19
-- Name: brevet_fiche; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE brevet_fiche (
    id bigint NOT NULL,
    eleve_id bigint NOT NULL,
    annee_scolaire_id bigint NOT NULL,
    avis character varying(256)
);


--
-- TOC entry 489 (class 1259 OID 137497)
-- Dependencies: 19
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
-- TOC entry 490 (class 1259 OID 137507)
-- Dependencies: 19
-- Name: brevet_rel_epreuve_matiere; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE brevet_rel_epreuve_matiere (
    id bigint NOT NULL,
    epreuve_id bigint NOT NULL,
    matiere_id bigint NOT NULL
);


--
-- TOC entry 491 (class 1259 OID 137514)
-- Dependencies: 19
-- Name: brevet_rel_epreuve_note_valeur_textuelle; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE brevet_rel_epreuve_note_valeur_textuelle (
    brevet_epreuve_id bigint NOT NULL,
    valeur_textuelle_id bigint NOT NULL
);


--
-- TOC entry 493 (class 1259 OID 137526)
-- Dependencies: 19
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
-- TOC entry 495 (class 1259 OID 137539)
-- Dependencies: 3535 3536 3537 3538 19
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
-- TOC entry 497 (class 1259 OID 137558)
-- Dependencies: 3539 19
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
-- TOC entry 480 (class 1259 OID 137401)
-- Dependencies: 3529 3530 19
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
-- TOC entry 479 (class 1259 OID 137396)
-- Dependencies: 19
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
-- TOC entry 494 (class 1259 OID 137534)
-- Dependencies: 19
-- Name: rel_evaluation_periode; Type: TABLE; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE rel_evaluation_periode (
    evaluation_id bigint NOT NULL,
    periode_id bigint NOT NULL
);


--
-- TOC entry 481 (class 1259 OID 137413)
-- Dependencies: 19
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
-- TOC entry 482 (class 1259 OID 137423)
-- Dependencies: 19
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
-- TOC entry 484 (class 1259 OID 137443)
-- Dependencies: 19
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
-- TOC entry 483 (class 1259 OID 137433)
-- Dependencies: 19
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
-- TOC entry 485 (class 1259 OID 137453)
-- Dependencies: 3531 19
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
-- TOC entry 486 (class 1259 OID 137464)
-- Dependencies: 3532 19
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
-- TOC entry 488 (class 1259 OID 137486)
-- Dependencies: 3534 19
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
-- TOC entry 487 (class 1259 OID 137475)
-- Dependencies: 3533 19
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
-- TOC entry 317 (class 1259 OID 132298)
-- Dependencies: 12
-- Name: absence_journee; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE absence_journee (
    id bigint NOT NULL,
    etablissement_id bigint NOT NULL,
    date date NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 318 (class 1259 OID 132301)
-- Dependencies: 12
-- Name: absence_journee_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE absence_journee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 318
-- Name: absence_journee_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('absence_journee_id_seq', 1, false);


--
-- TOC entry 319 (class 1259 OID 132303)
-- Dependencies: 3462 12
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
-- TOC entry 320 (class 1259 OID 132310)
-- Dependencies: 12
-- Name: agenda_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE agenda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 320
-- Name: agenda_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('agenda_id_seq', 1, false);


--
-- TOC entry 321 (class 1259 OID 132312)
-- Dependencies: 3463 12
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
-- TOC entry 428 (class 1259 OID 136674)
-- Dependencies: 12
-- Name: appel_en_cours_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE appel_en_cours_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 428
-- Name: appel_en_cours_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('appel_en_cours_id_seq', 1, false);


--
-- TOC entry 322 (class 1259 OID 132316)
-- Dependencies: 12
-- Name: appel_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE appel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 322
-- Name: appel_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('appel_id_seq', 1, false);


--
-- TOC entry 323 (class 1259 OID 132318)
-- Dependencies: 3464 3465 3466 3467 3468 3469 3470 3471 3472 3473 3474 3475 12
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
-- TOC entry 324 (class 1259 OID 132330)
-- Dependencies: 12
-- Name: appel_ligne_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE appel_ligne_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 324
-- Name: appel_ligne_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('appel_ligne_id_seq', 1, false);


--
-- TOC entry 325 (class 1259 OID 132332)
-- Dependencies: 12
-- Name: appel_plage_horaire; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE appel_plage_horaire (
    appel_id bigint NOT NULL,
    plage_horaire_id bigint NOT NULL
);


--
-- TOC entry 328 (class 1259 OID 132340)
-- Dependencies: 12
-- Name: date_exclue; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE date_exclue (
    id bigint NOT NULL,
    date_exclue date NOT NULL,
    evenement_id bigint NOT NULL
);


--
-- TOC entry 329 (class 1259 OID 132343)
-- Dependencies: 12
-- Name: date_exclue_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE date_exclue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 329
-- Name: date_exclue_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('date_exclue_id_seq', 1, false);


--
-- TOC entry 330 (class 1259 OID 132345)
-- Dependencies: 12
-- Name: element_emploi_du_temps_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE element_emploi_du_temps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 330
-- Name: element_emploi_du_temps_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('element_emploi_du_temps_id_seq', 1, false);


--
-- TOC entry 331 (class 1259 OID 132347)
-- Dependencies: 12
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
-- TOC entry 332 (class 1259 OID 132353)
-- Dependencies: 12
-- Name: evenement_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE evenement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 332
-- Name: evenement_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('evenement_id_seq', 1, false);


--
-- TOC entry 333 (class 1259 OID 132355)
-- Dependencies: 3476 12
-- Name: groupe_motif; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE groupe_motif (
    id bigint NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL,
    libelle character varying(512) NOT NULL,
    modifiable boolean DEFAULT true
);


--
-- TOC entry 334 (class 1259 OID 132362)
-- Dependencies: 12
-- Name: groupe_motif_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE groupe_motif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 334
-- Name: groupe_motif_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('groupe_motif_id_seq', 1, false);


--
-- TOC entry 335 (class 1259 OID 132364)
-- Dependencies: 12
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
-- TOC entry 336 (class 1259 OID 132367)
-- Dependencies: 12
-- Name: incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5259 (class 0 OID 0)
-- Dependencies: 336
-- Name: incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('incident_id_seq', 1, false);


--
-- TOC entry 337 (class 1259 OID 132369)
-- Dependencies: 12
-- Name: lieu_incident; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE lieu_incident (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 338 (class 1259 OID 132372)
-- Dependencies: 12
-- Name: lieu_incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE lieu_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 338
-- Name: lieu_incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('lieu_incident_id_seq', 1, false);


--
-- TOC entry 339 (class 1259 OID 132374)
-- Dependencies: 3477 12
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
-- TOC entry 340 (class 1259 OID 132381)
-- Dependencies: 12
-- Name: motif_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE motif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 340
-- Name: motif_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('motif_id_seq', 1, false);


--
-- TOC entry 341 (class 1259 OID 132383)
-- Dependencies: 12
-- Name: partenaire_a_prevenir; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE partenaire_a_prevenir (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 342 (class 1259 OID 132386)
-- Dependencies: 12
-- Name: partenaire_a_prevenir_incident; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE partenaire_a_prevenir_incident (
    id bigint NOT NULL,
    incident_id bigint NOT NULL,
    partenaire_a_prevenir_id bigint NOT NULL
);


--
-- TOC entry 343 (class 1259 OID 132389)
-- Dependencies: 12
-- Name: partenaire_a_prevenir_incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE partenaire_a_prevenir_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 343
-- Name: partenaire_a_prevenir_incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('partenaire_a_prevenir_incident_id_seq', 1, false);


--
-- TOC entry 344 (class 1259 OID 132391)
-- Dependencies: 12
-- Name: partenaire_prevenir_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE partenaire_prevenir_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 344
-- Name: partenaire_prevenir_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('partenaire_prevenir_id_seq', 1, false);


--
-- TOC entry 345 (class 1259 OID 132393)
-- Dependencies: 3478 3479 3480 3481 3482 3483 3484 12
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
-- TOC entry 346 (class 1259 OID 132403)
-- Dependencies: 12
-- Name: plage_horaire_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE plage_horaire_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 346
-- Name: plage_horaire_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('plage_horaire_id_seq', 1, false);


--
-- TOC entry 347 (class 1259 OID 132405)
-- Dependencies: 12
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
-- TOC entry 348 (class 1259 OID 132408)
-- Dependencies: 12
-- Name: preference_etablissement_absences_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE preference_etablissement_absences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 348
-- Name: preference_etablissement_absences_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('preference_etablissement_absences_id_seq', 1, false);


--
-- TOC entry 349 (class 1259 OID 132410)
-- Dependencies: 12
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
-- TOC entry 350 (class 1259 OID 132413)
-- Dependencies: 12
-- Name: preference_utilisateur_agenda_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE preference_utilisateur_agenda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 350
-- Name: preference_utilisateur_agenda_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('preference_utilisateur_agenda_id_seq', 1, false);


--
-- TOC entry 351 (class 1259 OID 132415)
-- Dependencies: 12
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
-- TOC entry 352 (class 1259 OID 132418)
-- Dependencies: 12
-- Name: protagoniste_incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE protagoniste_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 352
-- Name: protagoniste_incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('protagoniste_incident_id_seq', 1, false);


--
-- TOC entry 353 (class 1259 OID 132420)
-- Dependencies: 12
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
-- TOC entry 354 (class 1259 OID 132423)
-- Dependencies: 12
-- Name: punition_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE punition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5268 (class 0 OID 0)
-- Dependencies: 354
-- Name: punition_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('punition_id_seq', 1, false);


--
-- TOC entry 355 (class 1259 OID 132425)
-- Dependencies: 12
-- Name: qualite_protagoniste; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE qualite_protagoniste (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 356 (class 1259 OID 132428)
-- Dependencies: 12
-- Name: qualite_protagoniste_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE qualite_protagoniste_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5269 (class 0 OID 0)
-- Dependencies: 356
-- Name: qualite_protagoniste_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('qualite_protagoniste_id_seq', 1, false);


--
-- TOC entry 357 (class 1259 OID 132430)
-- Dependencies: 12
-- Name: rel_agenda_evenement; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE rel_agenda_evenement (
    evenement_id bigint NOT NULL,
    agenda_id bigint NOT NULL,
    id bigint NOT NULL
);


--
-- TOC entry 358 (class 1259 OID 132433)
-- Dependencies: 12
-- Name: rel_agenda_evenement_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE rel_agenda_evenement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5270 (class 0 OID 0)
-- Dependencies: 358
-- Name: rel_agenda_evenement_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('rel_agenda_evenement_id_seq', 1, false);


--
-- TOC entry 359 (class 1259 OID 132435)
-- Dependencies: 12
-- Name: repeter_jour_annee; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE repeter_jour_annee (
    id bigint NOT NULL,
    jour_annee integer NOT NULL,
    evenement_id bigint NOT NULL
);


--
-- TOC entry 360 (class 1259 OID 132438)
-- Dependencies: 12
-- Name: repeter_jour_annee_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE repeter_jour_annee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5271 (class 0 OID 0)
-- Dependencies: 360
-- Name: repeter_jour_annee_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('repeter_jour_annee_id_seq', 1, false);


--
-- TOC entry 361 (class 1259 OID 132440)
-- Dependencies: 12
-- Name: repeter_jour_mois; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE repeter_jour_mois (
    id bigint NOT NULL,
    jour_mois integer NOT NULL,
    evenement_id bigint NOT NULL
);


--
-- TOC entry 362 (class 1259 OID 132443)
-- Dependencies: 12
-- Name: repeter_jour_mois_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE repeter_jour_mois_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5272 (class 0 OID 0)
-- Dependencies: 362
-- Name: repeter_jour_mois_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('repeter_jour_mois_id_seq', 1, false);


--
-- TOC entry 363 (class 1259 OID 132445)
-- Dependencies: 12
-- Name: repeter_jour_semaine; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE repeter_jour_semaine (
    id bigint NOT NULL,
    jour integer NOT NULL,
    evenement_id bigint NOT NULL
);


--
-- TOC entry 364 (class 1259 OID 132448)
-- Dependencies: 12
-- Name: repeter_jour_semaine_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE repeter_jour_semaine_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 364
-- Name: repeter_jour_semaine_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('repeter_jour_semaine_id_seq', 1, false);


--
-- TOC entry 365 (class 1259 OID 132450)
-- Dependencies: 12
-- Name: repeter_mois; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE repeter_mois (
    id bigint NOT NULL,
    mois integer NOT NULL,
    evenement_id bigint NOT NULL
);


--
-- TOC entry 366 (class 1259 OID 132453)
-- Dependencies: 12
-- Name: repeter_mois_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE repeter_mois_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 366
-- Name: repeter_mois_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('repeter_mois_id_seq', 1, false);


--
-- TOC entry 367 (class 1259 OID 132455)
-- Dependencies: 12
-- Name: repeter_semaine_annee; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE repeter_semaine_annee (
    id bigint NOT NULL,
    semaine_annee integer NOT NULL,
    evenement_id bigint NOT NULL
);


--
-- TOC entry 368 (class 1259 OID 132458)
-- Dependencies: 12
-- Name: repeter_semaine_annee_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE repeter_semaine_annee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 368
-- Name: repeter_semaine_annee_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('repeter_semaine_annee_id_seq', 1, false);


--
-- TOC entry 369 (class 1259 OID 132460)
-- Dependencies: 12
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
-- TOC entry 370 (class 1259 OID 132463)
-- Dependencies: 12
-- Name: sanction_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE sanction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 370
-- Name: sanction_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('sanction_id_seq', 1, false);


--
-- TOC entry 371 (class 1259 OID 132465)
-- Dependencies: 12
-- Name: type_agenda; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE type_agenda (
    id bigint NOT NULL,
    code character varying(30) NOT NULL,
    libelle character varying(255)
);


--
-- TOC entry 372 (class 1259 OID 132468)
-- Dependencies: 12
-- Name: type_agenda_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE type_agenda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 372
-- Name: type_agenda_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('type_agenda_id_seq', 1, false);


--
-- TOC entry 373 (class 1259 OID 132470)
-- Dependencies: 12
-- Name: type_evenement; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE type_evenement (
    id bigint NOT NULL,
    type character varying(30) NOT NULL
);


--
-- TOC entry 374 (class 1259 OID 132473)
-- Dependencies: 12
-- Name: type_evenement_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE type_evenement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 374
-- Name: type_evenement_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('type_evenement_id_seq', 7, true);


--
-- TOC entry 375 (class 1259 OID 132475)
-- Dependencies: 12
-- Name: type_incident; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE type_incident (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 376 (class 1259 OID 132478)
-- Dependencies: 12
-- Name: type_incident_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE type_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 376
-- Name: type_incident_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('type_incident_id_seq', 1, false);


--
-- TOC entry 377 (class 1259 OID 132480)
-- Dependencies: 12
-- Name: type_punition; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE type_punition (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 378 (class 1259 OID 132483)
-- Dependencies: 12
-- Name: type_punition_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE type_punition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 378
-- Name: type_punition_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('type_punition_id_seq', 1, false);


--
-- TOC entry 379 (class 1259 OID 132485)
-- Dependencies: 12
-- Name: type_sanction; Type: TABLE; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE TABLE type_sanction (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 380 (class 1259 OID 132488)
-- Dependencies: 12
-- Name: type_sanction_id_seq; Type: SEQUENCE; Schema: enttemps; Owner: -
--

CREATE SEQUENCE type_sanction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 380
-- Name: type_sanction_id_seq; Type: SEQUENCE SET; Schema: enttemps; Owner: -
--

SELECT pg_catalog.setval('type_sanction_id_seq', 1, false);


SET search_path = enttemps_2011_2012, pg_catalog;

--
-- TOC entry 465 (class 1259 OID 137278)
-- Dependencies: 18
-- Name: absence_journee; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE absence_journee (
    id bigint NOT NULL,
    etablissement_id bigint NOT NULL,
    date date NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 473 (class 1259 OID 137341)
-- Dependencies: 3528 18
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
-- TOC entry 464 (class 1259 OID 137270)
-- Dependencies: 3515 18
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
-- TOC entry 471 (class 1259 OID 137312)
-- Dependencies: 3516 3517 3518 3519 3520 3521 3522 3523 3524 3525 3526 3527 18
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
-- TOC entry 470 (class 1259 OID 137307)
-- Dependencies: 18
-- Name: appel_plage_horaire; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE appel_plage_horaire (
    appel_id bigint NOT NULL,
    plage_horaire_id bigint NOT NULL
);


--
-- TOC entry 472 (class 1259 OID 137334)
-- Dependencies: 18
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
-- TOC entry 474 (class 1259 OID 137350)
-- Dependencies: 18
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
-- TOC entry 455 (class 1259 OID 137201)
-- Dependencies: 3513 18
-- Name: groupe_motif; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE groupe_motif (
    id bigint NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL,
    libelle character varying(512) NOT NULL,
    modifiable boolean DEFAULT true
);


--
-- TOC entry 461 (class 1259 OID 137251)
-- Dependencies: 18
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
-- TOC entry 457 (class 1259 OID 137219)
-- Dependencies: 18
-- Name: lieu_incident; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE lieu_incident (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 459 (class 1259 OID 137233)
-- Dependencies: 3514 18
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
-- TOC entry 462 (class 1259 OID 137256)
-- Dependencies: 18
-- Name: partenaire_a_prevenir; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE partenaire_a_prevenir (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 468 (class 1259 OID 137295)
-- Dependencies: 18
-- Name: partenaire_a_prevenir_incident; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE partenaire_a_prevenir_incident (
    id bigint NOT NULL,
    incident_id bigint NOT NULL,
    partenaire_a_prevenir_id bigint NOT NULL
);


--
-- TOC entry 454 (class 1259 OID 137189)
-- Dependencies: 3506 3507 3508 3509 3510 3511 3512 18
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
-- TOC entry 453 (class 1259 OID 137182)
-- Dependencies: 18
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
-- TOC entry 467 (class 1259 OID 137290)
-- Dependencies: 18
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
-- TOC entry 469 (class 1259 OID 137302)
-- Dependencies: 18
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
-- TOC entry 458 (class 1259 OID 137226)
-- Dependencies: 18
-- Name: qualite_protagoniste; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE qualite_protagoniste (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 475 (class 1259 OID 137358)
-- Dependencies: 18
-- Name: rel_agenda_evenement; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE rel_agenda_evenement (
    evenement_id bigint NOT NULL,
    agenda_id bigint NOT NULL,
    id bigint NOT NULL
);


--
-- TOC entry 466 (class 1259 OID 137285)
-- Dependencies: 18
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
-- TOC entry 456 (class 1259 OID 137212)
-- Dependencies: 18
-- Name: type_incident; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE type_incident (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 463 (class 1259 OID 137263)
-- Dependencies: 18
-- Name: type_punition; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE type_punition (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


--
-- TOC entry 460 (class 1259 OID 137244)
-- Dependencies: 18
-- Name: type_sanction; Type: TABLE; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

CREATE TABLE type_sanction (
    id bigint NOT NULL,
    libelle character varying(30) NOT NULL,
    preference_etablissement_absences_id bigint NOT NULL
);


SET search_path = forum, pg_catalog;

--
-- TOC entry 381 (class 1259 OID 132490)
-- Dependencies: 13
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
-- TOC entry 382 (class 1259 OID 132496)
-- Dependencies: 381 13
-- Name: commentaire_id_seq; Type: SEQUENCE; Schema: forum; Owner: -
--

CREATE SEQUENCE commentaire_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 382
-- Name: commentaire_id_seq; Type: SEQUENCE OWNED BY; Schema: forum; Owner: -
--

ALTER SEQUENCE commentaire_id_seq OWNED BY commentaire.id;


--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 382
-- Name: commentaire_id_seq; Type: SEQUENCE SET; Schema: forum; Owner: -
--

SELECT pg_catalog.setval('commentaire_id_seq', 1, false);


--
-- TOC entry 383 (class 1259 OID 132498)
-- Dependencies: 13
-- Name: commentaire_lu; Type: TABLE; Schema: forum; Owner: -; Tablespace: 
--

CREATE TABLE commentaire_lu (
    commentaire_id bigint NOT NULL,
    version integer NOT NULL,
    autorite_id bigint NOT NULL,
    date_lecture timestamp without time zone
);


--
-- TOC entry 384 (class 1259 OID 132501)
-- Dependencies: 13
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
-- TOC entry 385 (class 1259 OID 132504)
-- Dependencies: 384 13
-- Name: discussion_id_seq; Type: SEQUENCE; Schema: forum; Owner: -
--

CREATE SEQUENCE discussion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 385
-- Name: discussion_id_seq; Type: SEQUENCE OWNED BY; Schema: forum; Owner: -
--

ALTER SEQUENCE discussion_id_seq OWNED BY discussion.id;


--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 385
-- Name: discussion_id_seq; Type: SEQUENCE SET; Schema: forum; Owner: -
--

SELECT pg_catalog.setval('discussion_id_seq', 1, false);


--
-- TOC entry 386 (class 1259 OID 132506)
-- Dependencies: 13
-- Name: etat_commentaire; Type: TABLE; Schema: forum; Owner: -; Tablespace: 
--

CREATE TABLE etat_commentaire (
    code character varying(10) NOT NULL,
    version integer NOT NULL,
    libelle character varying(60) NOT NULL
);


--
-- TOC entry 387 (class 1259 OID 132509)
-- Dependencies: 13
-- Name: etat_discussion; Type: TABLE; Schema: forum; Owner: -; Tablespace: 
--

CREATE TABLE etat_discussion (
    code character varying(10) NOT NULL,
    version integer NOT NULL,
    libelle character varying(60) NOT NULL
);


--
-- TOC entry 388 (class 1259 OID 132512)
-- Dependencies: 13
-- Name: type_moderation; Type: TABLE; Schema: forum; Owner: -; Tablespace: 
--

CREATE TABLE type_moderation (
    code character varying(10) NOT NULL,
    version integer NOT NULL,
    libelle character varying(60) NOT NULL
);


SET search_path = impression, pg_catalog;

--
-- TOC entry 389 (class 1259 OID 132515)
-- Dependencies: 14
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
-- TOC entry 390 (class 1259 OID 132521)
-- Dependencies: 14
-- Name: publipostage_suivi_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE publipostage_suivi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5286 (class 0 OID 0)
-- Dependencies: 390
-- Name: publipostage_suivi_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('publipostage_suivi_id_seq', 1, false);


--
-- TOC entry 437 (class 1259 OID 136868)
-- Dependencies: 14
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
-- TOC entry 439 (class 1259 OID 136925)
-- Dependencies: 14
-- Name: sms_fournisseur_etablissement; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE sms_fournisseur_etablissement (
    id bigint NOT NULL,
    sms_fournisseur_id bigint,
    sms_login character varying(50),
    sms_mot_de_passe character varying(50),
    sms_identifiants_codes boolean,
    sms_https_envoi boolean
);


--
-- TOC entry 440 (class 1259 OID 136930)
-- Dependencies: 14
-- Name: sms_fournisseur_etablissement_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE sms_fournisseur_etablissement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5287 (class 0 OID 0)
-- Dependencies: 440
-- Name: sms_fournisseur_etablissement_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('sms_fournisseur_etablissement_id_seq', 1, false);


--
-- TOC entry 438 (class 1259 OID 136876)
-- Dependencies: 14
-- Name: sms_fournisseur_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE sms_fournisseur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5288 (class 0 OID 0)
-- Dependencies: 438
-- Name: sms_fournisseur_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('sms_fournisseur_id_seq', 1, false);


--
-- TOC entry 391 (class 1259 OID 132523)
-- Dependencies: 14
-- Name: template_champ_memo; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE template_champ_memo (
    id bigint NOT NULL,
    champ character varying(256) NOT NULL,
    template text,
    template_document_id bigint
);


--
-- TOC entry 392 (class 1259 OID 132529)
-- Dependencies: 14
-- Name: template_champ_memo_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_champ_memo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5289 (class 0 OID 0)
-- Dependencies: 392
-- Name: template_champ_memo_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_champ_memo_id_seq', 1, false);


--
-- TOC entry 393 (class 1259 OID 132531)
-- Dependencies: 3487 3488 3489 14
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
-- TOC entry 394 (class 1259 OID 132539)
-- Dependencies: 14
-- Name: template_document_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5290 (class 0 OID 0)
-- Dependencies: 394
-- Name: template_document_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_document_id_seq', 1, false);


--
-- TOC entry 395 (class 1259 OID 132541)
-- Dependencies: 14
-- Name: template_document_sous_template_eliot; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE template_document_sous_template_eliot (
    id bigint NOT NULL,
    param character varying(256),
    template_document_id bigint,
    template_eliot_id bigint
);


--
-- TOC entry 396 (class 1259 OID 132544)
-- Dependencies: 14
-- Name: template_document_sous_template_eliot_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_document_sous_template_eliot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5291 (class 0 OID 0)
-- Dependencies: 396
-- Name: template_document_sous_template_eliot_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_document_sous_template_eliot_id_seq', 1, false);


--
-- TOC entry 397 (class 1259 OID 132546)
-- Dependencies: 3490 3491 3492 3493 3494 3495 14
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
-- TOC entry 398 (class 1259 OID 132558)
-- Dependencies: 14
-- Name: template_eliot_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_eliot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5292 (class 0 OID 0)
-- Dependencies: 398
-- Name: template_eliot_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_eliot_id_seq', 1, false);


--
-- TOC entry 399 (class 1259 OID 132560)
-- Dependencies: 14
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
-- TOC entry 400 (class 1259 OID 132566)
-- Dependencies: 14
-- Name: template_jasper_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_jasper_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5293 (class 0 OID 0)
-- Dependencies: 400
-- Name: template_jasper_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_jasper_id_seq', 1, false);


--
-- TOC entry 401 (class 1259 OID 132568)
-- Dependencies: 14
-- Name: template_type_donnees; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE template_type_donnees (
    id bigint NOT NULL,
    libelle character varying(256) NOT NULL,
    code character varying(32) NOT NULL
);


--
-- TOC entry 402 (class 1259 OID 132571)
-- Dependencies: 14
-- Name: template_type_donnees_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_type_donnees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5294 (class 0 OID 0)
-- Dependencies: 402
-- Name: template_type_donnees_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_type_donnees_id_seq', 8, true);


--
-- TOC entry 403 (class 1259 OID 132573)
-- Dependencies: 14
-- Name: template_type_fonctionnalite; Type: TABLE; Schema: impression; Owner: -; Tablespace: 
--

CREATE TABLE template_type_fonctionnalite (
    id bigint NOT NULL,
    libelle character varying(256) NOT NULL,
    parent_id bigint,
    code character varying(32) NOT NULL
);


--
-- TOC entry 404 (class 1259 OID 132576)
-- Dependencies: 14
-- Name: template_type_fonctionnalite_id_seq; Type: SEQUENCE; Schema: impression; Owner: -
--

CREATE SEQUENCE template_type_fonctionnalite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5295 (class 0 OID 0)
-- Dependencies: 404
-- Name: template_type_fonctionnalite_id_seq; Type: SEQUENCE SET; Schema: impression; Owner: -
--

SELECT pg_catalog.setval('template_type_fonctionnalite_id_seq', 12, true);


SET search_path = public, pg_catalog;



--
-- TOC entry 405 (class 1259 OID 132578)
-- Dependencies: 16
-- Name: eliot_version_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE eliot_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5296 (class 0 OID 0)
-- Dependencies: 405
-- Name: eliot_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('eliot_version_id_seq', 13, true);


--
-- TOC entry 406 (class 1259 OID 132580)
-- Dependencies: 3496 3497 16
-- Name: eliot_version; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eliot_version (
    id bigint DEFAULT nextval('eliot_version_id_seq'::regclass) NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    code character varying(128) NOT NULL
);


SET search_path = securite, pg_catalog;

--
-- TOC entry 407 (class 1259 OID 132585)
-- Dependencies: 3498 3499 15
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
-- TOC entry 412 (class 1259 OID 132603)
-- Dependencies: 15
-- Name: autorisation_id_seq; Type: SEQUENCE; Schema: securite; Owner: -
--

CREATE SEQUENCE autorisation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5297 (class 0 OID 0)
-- Dependencies: 412
-- Name: autorisation_id_seq; Type: SEQUENCE SET; Schema: securite; Owner: -
--

SELECT pg_catalog.setval('autorisation_id_seq', 1, false);


--
-- TOC entry 413 (class 1259 OID 132605)
-- Dependencies: 15
-- Name: autorite_id_seq; Type: SEQUENCE; Schema: securite; Owner: -
--

CREATE SEQUENCE autorite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5298 (class 0 OID 0)
-- Dependencies: 413
-- Name: autorite_id_seq; Type: SEQUENCE SET; Schema: securite; Owner: -
--

SELECT pg_catalog.setval('autorite_id_seq', 1, false);


--
-- TOC entry 408 (class 1259 OID 132589)
-- Dependencies: 3500 15
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
-- TOC entry 414 (class 1259 OID 132607)
-- Dependencies: 15
-- Name: item_id_seq; Type: SEQUENCE; Schema: securite; Owner: -
--

CREATE SEQUENCE item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5299 (class 0 OID 0)
-- Dependencies: 414
-- Name: item_id_seq; Type: SEQUENCE SET; Schema: securite; Owner: -
--

SELECT pg_catalog.setval('item_id_seq', 1, false);


--
-- TOC entry 409 (class 1259 OID 132593)
-- Dependencies: 3501 15
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
-- TOC entry 415 (class 1259 OID 132609)
-- Dependencies: 15
-- Name: perimetre_id_seq; Type: SEQUENCE; Schema: securite; Owner: -
--

CREATE SEQUENCE perimetre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5300 (class 0 OID 0)
-- Dependencies: 415
-- Name: perimetre_id_seq; Type: SEQUENCE SET; Schema: securite; Owner: -
--

SELECT pg_catalog.setval('perimetre_id_seq', 1, false);


--
-- TOC entry 410 (class 1259 OID 132597)
-- Dependencies: 15
-- Name: perimetre_securite; Type: TABLE; Schema: securite; Owner: -; Tablespace: 
--

CREATE TABLE perimetre_securite (
    id bigint NOT NULL,
    item_id bigint NOT NULL,
    perimetre_id bigint NOT NULL
);


--
-- TOC entry 416 (class 1259 OID 132611)
-- Dependencies: 15
-- Name: perimetre_securite_id_seq; Type: SEQUENCE; Schema: securite; Owner: -
--

CREATE SEQUENCE perimetre_securite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5301 (class 0 OID 0)
-- Dependencies: 416
-- Name: perimetre_securite_id_seq; Type: SEQUENCE SET; Schema: securite; Owner: -
--

SELECT pg_catalog.setval('perimetre_securite_id_seq', 1, false);


--
-- TOC entry 411 (class 1259 OID 132600)
-- Dependencies: 15
-- Name: permission; Type: TABLE; Schema: securite; Owner: -; Tablespace: 
--

CREATE TABLE permission (
    id bigint NOT NULL,
    version integer NOT NULL,
    nom character varying(128) NOT NULL,
    valeur integer NOT NULL
);


--
-- TOC entry 417 (class 1259 OID 132613)
-- Dependencies: 15
-- Name: permission_id_seq; Type: SEQUENCE; Schema: securite; Owner: -
--

CREATE SEQUENCE permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5302 (class 0 OID 0)
-- Dependencies: 417
-- Name: permission_id_seq; Type: SEQUENCE SET; Schema: securite; Owner: -
--

SELECT pg_catalog.setval('permission_id_seq', 5, true);


SET search_path = td, pg_catalog;

--
-- TOC entry 536 (class 1259 OID 138798)
-- Dependencies: 3577 3578 22
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
-- TOC entry 535 (class 1259 OID 138796)
-- Dependencies: 22
-- Name: copie_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE copie_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5303 (class 0 OID 0)
-- Dependencies: 535
-- Name: copie_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('copie_id_seq', 100, false);


--
-- TOC entry 539 (class 1259 OID 138854)
-- Dependencies: 3579 22
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
-- TOC entry 543 (class 1259 OID 139037)
-- Dependencies: 22
-- Name: modalite_activite_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE modalite_activite_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5304 (class 0 OID 0)
-- Dependencies: 543
-- Name: modalite_activite_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('modalite_activite_id_seq', 100, false);


--
-- TOC entry 522 (class 1259 OID 138593)
-- Dependencies: 3564 3565 3566 22
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
-- TOC entry 526 (class 1259 OID 138657)
-- Dependencies: 3567 3568 22
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
-- TOC entry 527 (class 1259 OID 138663)
-- Dependencies: 22
-- Name: question_attachement_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE question_attachement_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5305 (class 0 OID 0)
-- Dependencies: 527
-- Name: question_attachement_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('question_attachement_id_seq', 100, false);


--
-- TOC entry 524 (class 1259 OID 138635)
-- Dependencies: 22
-- Name: question_export; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE question_export (
    id bigint NOT NULL,
    format_id bigint NOT NULL,
    export text NOT NULL,
    question_id bigint NOT NULL
);


--
-- TOC entry 525 (class 1259 OID 138643)
-- Dependencies: 22
-- Name: question_export_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE question_export_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5306 (class 0 OID 0)
-- Dependencies: 525
-- Name: question_export_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('question_export_id_seq', 100, false);


--
-- TOC entry 523 (class 1259 OID 138603)
-- Dependencies: 22
-- Name: question_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE question_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5307 (class 0 OID 0)
-- Dependencies: 523
-- Name: question_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('question_id_seq', 100, false);


--
-- TOC entry 520 (class 1259 OID 138583)
-- Dependencies: 3562 3563 22
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
-- TOC entry 521 (class 1259 OID 138591)
-- Dependencies: 22
-- Name: question_type_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE question_type_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5308 (class 0 OID 0)
-- Dependencies: 521
-- Name: question_type_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('question_type_id_seq', 100, false);


--
-- TOC entry 538 (class 1259 OID 138826)
-- Dependencies: 22
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
-- TOC entry 544 (class 1259 OID 139113)
-- Dependencies: 3580 22
-- Name: reponse_attachement; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE reponse_attachement (
    id bigint NOT NULL,
    reponse_id bigint NOT NULL,
    attachement_id bigint NOT NULL,
    rang integer DEFAULT 1
);


--
-- TOC entry 545 (class 1259 OID 139119)
-- Dependencies: 22
-- Name: reponse_attachement_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE reponse_attachement_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5309 (class 0 OID 0)
-- Dependencies: 545
-- Name: reponse_attachement_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('reponse_attachement_id_seq', 100, false);


--
-- TOC entry 537 (class 1259 OID 138824)
-- Dependencies: 22
-- Name: reponse_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE reponse_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5310 (class 0 OID 0)
-- Dependencies: 537
-- Name: reponse_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('reponse_id_seq', 100, false);


--
-- TOC entry 528 (class 1259 OID 138696)
-- Dependencies: 3569 3570 22
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
-- TOC entry 529 (class 1259 OID 138705)
-- Dependencies: 22
-- Name: sujet_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE sujet_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5311 (class 0 OID 0)
-- Dependencies: 529
-- Name: sujet_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('sujet_id_seq', 100, false);


--
-- TOC entry 530 (class 1259 OID 138731)
-- Dependencies: 3571 22
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
-- TOC entry 531 (class 1259 OID 138736)
-- Dependencies: 22
-- Name: sujet_sequence_questions_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE sujet_sequence_questions_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5312 (class 0 OID 0)
-- Dependencies: 531
-- Name: sujet_sequence_questions_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('sujet_sequence_questions_id_seq', 100, false);


--
-- TOC entry 541 (class 1259 OID 138977)
-- Dependencies: 22
-- Name: sujet_type; Type: TABLE; Schema: td; Owner: -; Tablespace: 
--

CREATE TABLE sujet_type (
    id bigint NOT NULL,
    nom character varying(255) NOT NULL,
    nom_anglais character varying(255) NOT NULL
);


--
-- TOC entry 542 (class 1259 OID 138985)
-- Dependencies: 22
-- Name: sujet_type_id_seq; Type: SEQUENCE; Schema: td; Owner: -
--

CREATE SEQUENCE sujet_type_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5313 (class 0 OID 0)
-- Dependencies: 542
-- Name: sujet_type_id_seq; Type: SEQUENCE SET; Schema: td; Owner: -
--

SELECT pg_catalog.setval('sujet_type_id_seq', 100, false);


SET search_path = tice, pg_catalog;

--
-- TOC entry 518 (class 1259 OID 138572)
-- Dependencies: 3561 21
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
-- TOC entry 519 (class 1259 OID 138580)
-- Dependencies: 21
-- Name: attachement_id_seq; Type: SEQUENCE; Schema: tice; Owner: -
--

CREATE SEQUENCE attachement_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5314 (class 0 OID 0)
-- Dependencies: 519
-- Name: attachement_id_seq; Type: SEQUENCE SET; Schema: tice; Owner: -
--

SELECT pg_catalog.setval('attachement_id_seq', 100, false);


--
-- TOC entry 514 (class 1259 OID 138543)
-- Dependencies: 21
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
-- TOC entry 515 (class 1259 OID 138562)
-- Dependencies: 21
-- Name: compte_utilisateur_id_seq; Type: SEQUENCE; Schema: tice; Owner: -
--

CREATE SEQUENCE compte_utilisateur_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5315 (class 0 OID 0)
-- Dependencies: 515
-- Name: compte_utilisateur_id_seq; Type: SEQUENCE SET; Schema: tice; Owner: -
--

SELECT pg_catalog.setval('compte_utilisateur_id_seq', 100, false);


--
-- TOC entry 532 (class 1259 OID 138750)
-- Dependencies: 3572 3573 3574 3575 3576 21
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
-- TOC entry 540 (class 1259 OID 138925)
-- Dependencies: 21
-- Name: copyrights_type_id_seq; Type: SEQUENCE; Schema: tice; Owner: -
--

CREATE SEQUENCE copyrights_type_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5316 (class 0 OID 0)
-- Dependencies: 540
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
-- TOC entry 517 (class 1259 OID 138570)
-- Dependencies: 21
-- Name: export_format_id_seq; Type: SEQUENCE; Schema: tice; Owner: -
--

CREATE SEQUENCE export_format_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5318 (class 0 OID 0)
-- Dependencies: 517
-- Name: export_format_id_seq; Type: SEQUENCE SET; Schema: tice; Owner: -
--

SELECT pg_catalog.setval('export_format_id_seq', 100, false);


--
-- TOC entry 533 (class 1259 OID 138765)
-- Dependencies: 21
-- Name: publication; Type: TABLE; Schema: tice; Owner: -; Tablespace: 
--

CREATE TABLE publication (
    id bigint NOT NULL,
    copyrights_type_id bigint NOT NULL,
    date_debut timestamp with time zone NOT NULL,
    date_fin timestamp with time zone
);


--
-- TOC entry 534 (class 1259 OID 138770)
-- Dependencies: 21
-- Name: publication_id_seq; Type: SEQUENCE; Schema: tice; Owner: -
--

CREATE SEQUENCE publication_id_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5319 (class 0 OID 0)
-- Dependencies: 534
-- Name: publication_id_seq; Type: SEQUENCE SET; Schema: tice; Owner: -
--

SELECT pg_catalog.setval('publication_id_seq', 100, false);


SET search_path = udt, pg_catalog;

--
-- TOC entry 450 (class 1259 OID 137121)
-- Dependencies: 3502 3503 17
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
-- TOC entry 451 (class 1259 OID 137126)
-- Dependencies: 17
-- Name: enseignement_id_seq; Type: SEQUENCE; Schema: udt; Owner: -
--

CREATE SEQUENCE enseignement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5320 (class 0 OID 0)
-- Dependencies: 451
-- Name: enseignement_id_seq; Type: SEQUENCE SET; Schema: udt; Owner: -
--

SELECT pg_catalog.setval('enseignement_id_seq', 1, false);


--
-- TOC entry 452 (class 1259 OID 137148)
-- Dependencies: 3504 3505 17
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
    type_evenement_id bigint NOT NULL,
    semaine_index smallint NOT NULL,
    jour_index smallint NOT NULL,
    sequence_index smallint NOT NULL,
    id_externe character varying(30) NOT NULL,
    annee smallint NOT NULL,
    CONSTRAINT chk_etat CHECK (((etat)::text = ANY ((ARRAY['TRAITE'::character varying, 'EN_ATTENTE'::character varying, 'ERREUR'::character varying])::text[])))
);


--
-- TOC entry 513 (class 1259 OID 138496)
-- Dependencies: 17
-- Name: evenement_id_seq; Type: SEQUENCE; Schema: udt; Owner: -
--

CREATE SEQUENCE evenement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5321 (class 0 OID 0)
-- Dependencies: 513
-- Name: evenement_id_seq; Type: SEQUENCE SET; Schema: udt; Owner: -
--

SELECT pg_catalog.setval('evenement_id_seq', 1, false);


--
-- TOC entry 448 (class 1259 OID 137109)
-- Dependencies: 17
-- Name: import; Type: TABLE; Schema: udt; Owner: -; Tablespace: 
--

CREATE TABLE import (
    id bigint NOT NULL,
    date timestamp with time zone NOT NULL,
    semaines character varying(255) NOT NULL,
    etablissement_id bigint NOT NULL,
    date_fin_import timestamp with time zone
);


--
-- TOC entry 449 (class 1259 OID 137114)
-- Dependencies: 17
-- Name: import_id_seq; Type: SEQUENCE; Schema: udt; Owner: -
--

CREATE SEQUENCE import_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5322 (class 0 OID 0)
-- Dependencies: 449
-- Name: import_id_seq; Type: SEQUENCE SET; Schema: udt; Owner: -
--

SELECT pg_catalog.setval('import_id_seq', 1, false);


SET search_path = ent, pg_catalog;

--
-- TOC entry 3429 (class 2604 OID 132615)
-- Dependencies: 237 236
-- Name: id; Type: DEFAULT; Schema: ent; Owner: -
--

ALTER TABLE ONLY service ALTER COLUMN id SET DEFAULT nextval('services_id_seq'::regclass);


SET search_path = forum, pg_catalog;

--
-- TOC entry 3485 (class 2604 OID 134791)
-- Dependencies: 382 381
-- Name: id; Type: DEFAULT; Schema: forum; Owner: -
--

ALTER TABLE ONLY commentaire ALTER COLUMN id SET DEFAULT nextval('commentaire_id_seq'::regclass);


--
-- TOC entry 3486 (class 2604 OID 134778)
-- Dependencies: 385 384
-- Name: id; Type: DEFAULT; Schema: forum; Owner: -
--

ALTER TABLE ONLY discussion ALTER COLUMN id SET DEFAULT nextval('discussion_id_seq'::regclass);


SET search_path = aaf, pg_catalog;

--
-- TOC entry 4946 (class 0 OID 131751)
-- Dependencies: 179
-- Data for Name: import; Type: TABLE DATA; Schema: aaf; Owner: -
--



--
-- TOC entry 4947 (class 0 OID 131759)
-- Dependencies: 181
-- Data for Name: import_verrou; Type: TABLE DATA; Schema: aaf; Owner: -
--



SET search_path = bascule_annee, pg_catalog;

--
-- TOC entry 5070 (class 0 OID 134466)
-- Dependencies: 418
-- Data for Name: etape; Type: TABLE DATA; Schema: bascule_annee; Owner: -
--



--
-- TOC entry 4948 (class 0 OID 131768)
-- Dependencies: 183
-- Data for Name: verrou; Type: TABLE DATA; Schema: bascule_annee; Owner: -
--



SET search_path = ent, pg_catalog;

--
-- TOC entry 4949 (class 0 OID 131773)
-- Dependencies: 185
-- Data for Name: annee_scolaire; Type: TABLE DATA; Schema: ent; Owner: -
--

INSERT INTO annee_scolaire (code, version, annee_en_cours, id) VALUES ('2011-2012', 0, true, 1);


--
-- TOC entry 4950 (class 0 OID 131778)
-- Dependencies: 187
-- Data for Name: appartenance_groupe_groupe; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4951 (class 0 OID 131783)
-- Dependencies: 189
-- Data for Name: appartenance_personne_groupe; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 5023 (class 0 OID 132337)
-- Dependencies: 327
-- Data for Name: calendrier; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4952 (class 0 OID 131788)
-- Dependencies: 191
-- Data for Name: civilite; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4971 (class 0 OID 131925)
-- Dependencies: 229
-- Data for Name: enseignement; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4953 (class 0 OID 131793)
-- Dependencies: 193
-- Data for Name: etablissement; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 5071 (class 0 OID 134482)
-- Dependencies: 420
-- Data for Name: fiche_eleve_commentaire; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4954 (class 0 OID 131803)
-- Dependencies: 195
-- Data for Name: filiere; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4955 (class 0 OID 131809)
-- Dependencies: 197
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
-- TOC entry 4956 (class 0 OID 131814)
-- Dependencies: 199
-- Data for Name: groupe_personnes; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4957 (class 0 OID 131825)
-- Dependencies: 202
-- Data for Name: matiere; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4958 (class 0 OID 131833)
-- Dependencies: 204
-- Data for Name: mef; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4959 (class 0 OID 131841)
-- Dependencies: 206
-- Data for Name: modalite_cours; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4960 (class 0 OID 131849)
-- Dependencies: 208
-- Data for Name: modalite_matiere; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4961 (class 0 OID 131857)
-- Dependencies: 210
-- Data for Name: niveau; Type: TABLE DATA; Schema: ent; Owner: -
--

INSERT INTO niveau (id, libelle_court, libelle_long, libelle_edition) VALUES (1, 'INDÉTERMINÉ', 'INDÉTERMINÉ', 'INDÉTERMINÉ');


--
-- TOC entry 4962 (class 0 OID 131865)
-- Dependencies: 212
-- Data for Name: periode; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4963 (class 0 OID 131870)
-- Dependencies: 214
-- Data for Name: personne; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4964 (class 0 OID 131878)
-- Dependencies: 216
-- Data for Name: personne_propriete_scolarite; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4965 (class 0 OID 131884)
-- Dependencies: 218
-- Data for Name: porteur_ent; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4966 (class 0 OID 131892)
-- Dependencies: 220
-- Data for Name: preference_etablissement; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4967 (class 0 OID 131908)
-- Dependencies: 223
-- Data for Name: propriete_scolarite; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4968 (class 0 OID 131914)
-- Dependencies: 225
-- Data for Name: regime; Type: TABLE DATA; Schema: ent; Owner: -
--

INSERT INTO regime (id, code) VALUES (1, 'EXTERNAT');
INSERT INTO regime (id, code) VALUES (2, 'DEMI-PENSION');
INSERT INTO regime (id, code) VALUES (3, 'INTERNAT');


--
-- TOC entry 4969 (class 0 OID 131919)
-- Dependencies: 227
-- Data for Name: rel_classe_filiere; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4970 (class 0 OID 131922)
-- Dependencies: 228
-- Data for Name: rel_classe_groupe; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4972 (class 0 OID 131930)
-- Dependencies: 230
-- Data for Name: rel_periode_service; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4973 (class 0 OID 131940)
-- Dependencies: 232
-- Data for Name: responsable_eleve; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4974 (class 0 OID 131948)
-- Dependencies: 234
-- Data for Name: responsable_propriete_scolarite; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4975 (class 0 OID 131954)
-- Dependencies: 236
-- Data for Name: service; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4976 (class 0 OID 131966)
-- Dependencies: 238
-- Data for Name: signature; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4977 (class 0 OID 131974)
-- Dependencies: 240
-- Data for Name: source_import; Type: TABLE DATA; Schema: ent; Owner: -
--

INSERT INTO source_import (id, code, libelle) VALUES (1, 'STS', 'STSweb');
INSERT INTO source_import (id, code, libelle) VALUES (2, 'AAF', 'Annuaire Académique Fédérateur');
INSERT INTO source_import (id, code, libelle) VALUES (3, 'UDT', 'UnDeuxTEMPS');


--
-- TOC entry 4978 (class 0 OID 131977)
-- Dependencies: 241
-- Data for Name: sous_service; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4979 (class 0 OID 131986)
-- Dependencies: 243
-- Data for Name: structure_enseignement; Type: TABLE DATA; Schema: ent; Owner: -
--



--
-- TOC entry 4980 (class 0 OID 131993)
-- Dependencies: 245
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
-- TOC entry 5130 (class 0 OID 137567)
-- Dependencies: 498
-- Data for Name: calendrier; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5131 (class 0 OID 137574)
-- Dependencies: 499
-- Data for Name: enseignement; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5132 (class 0 OID 137583)
-- Dependencies: 500
-- Data for Name: matiere; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5133 (class 0 OID 137596)
-- Dependencies: 501
-- Data for Name: modalite_matiere; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5134 (class 0 OID 137606)
-- Dependencies: 502
-- Data for Name: periode; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5135 (class 0 OID 137613)
-- Dependencies: 503
-- Data for Name: personne_propriete_scolarite; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5136 (class 0 OID 137619)
-- Dependencies: 504
-- Data for Name: preference_etablissement; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5137 (class 0 OID 137633)
-- Dependencies: 505
-- Data for Name: propriete_scolarite; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5138 (class 0 OID 137639)
-- Dependencies: 506
-- Data for Name: rel_classe_filiere; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5139 (class 0 OID 137644)
-- Dependencies: 507
-- Data for Name: rel_classe_groupe; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5140 (class 0 OID 137649)
-- Dependencies: 508
-- Data for Name: rel_periode_service; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5141 (class 0 OID 137661)
-- Dependencies: 509
-- Data for Name: responsable_propriete_scolarite; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5142 (class 0 OID 137667)
-- Dependencies: 510
-- Data for Name: service; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5143 (class 0 OID 137680)
-- Dependencies: 511
-- Data for Name: sous_service; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



--
-- TOC entry 5144 (class 0 OID 137691)
-- Dependencies: 512
-- Data for Name: structure_enseignement; Type: TABLE DATA; Schema: ent_2011_2012; Owner: -
--



SET search_path = entcdt, pg_catalog;

--
-- TOC entry 4982 (class 0 OID 132010)
-- Dependencies: 248
-- Data for Name: activite; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4983 (class 0 OID 132021)
-- Dependencies: 250
-- Data for Name: cahier_de_textes; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4984 (class 0 OID 132033)
-- Dependencies: 253
-- Data for Name: chapitre; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4985 (class 0 OID 132042)
-- Dependencies: 255
-- Data for Name: contexte_activite; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4986 (class 0 OID 132050)
-- Dependencies: 257
-- Data for Name: date_activite; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4987 (class 0 OID 132055)
-- Dependencies: 259
-- Data for Name: dossier; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4988 (class 0 OID 132072)
-- Dependencies: 261
-- Data for Name: fichier; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4989 (class 0 OID 132080)
-- Dependencies: 263
-- Data for Name: rel_activite_acteur; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4990 (class 0 OID 132089)
-- Dependencies: 264
-- Data for Name: rel_cahier_acteur; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4991 (class 0 OID 132093)
-- Dependencies: 265
-- Data for Name: rel_cahier_groupe; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4992 (class 0 OID 132097)
-- Dependencies: 266
-- Data for Name: rel_dossier_autorisation_cahier; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4993 (class 0 OID 132100)
-- Dependencies: 267
-- Data for Name: ressource; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4994 (class 0 OID 132110)
-- Dependencies: 269
-- Data for Name: textes_preferences_utilisateur; Type: TABLE DATA; Schema: entcdt; Owner: -
--



--
-- TOC entry 4995 (class 0 OID 132115)
-- Dependencies: 271
-- Data for Name: type_activite; Type: TABLE DATA; Schema: entcdt; Owner: -
--

INSERT INTO type_activite (id, code, nom, description, degre) VALUES (1, 'INTER', 'Activité interactive', 'Activité interactive', 2);


--
-- TOC entry 4996 (class 0 OID 132123)
-- Dependencies: 273
-- Data for Name: visa; Type: TABLE DATA; Schema: entcdt; Owner: -
--



SET search_path = entdemon, pg_catalog;

--
-- TOC entry 4997 (class 0 OID 132131)
-- Dependencies: 275
-- Data for Name: demande_traitement; Type: TABLE DATA; Schema: entdemon; Owner: -
--



SET search_path = entnotes, pg_catalog;

--
-- TOC entry 4998 (class 0 OID 132139)
-- Dependencies: 277
-- Data for Name: appreciation_classe_enseignement_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 4999 (class 0 OID 132147)
-- Dependencies: 279
-- Data for Name: appreciation_eleve_enseignement_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5000 (class 0 OID 132155)
-- Dependencies: 281
-- Data for Name: appreciation_eleve_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5001 (class 0 OID 132163)
-- Dependencies: 283
-- Data for Name: avis_conseil_de_classe; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5002 (class 0 OID 132171)
-- Dependencies: 285
-- Data for Name: avis_orientation; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5073 (class 0 OID 136723)
-- Dependencies: 430
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
-- TOC entry 5081 (class 0 OID 137071)
-- Dependencies: 443
-- Data for Name: brevet_fiche; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5076 (class 0 OID 136767)
-- Dependencies: 433
-- Data for Name: brevet_note; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5074 (class 0 OID 136745)
-- Dependencies: 431
-- Data for Name: brevet_note_valeur_textuelle; Type: TABLE DATA; Schema: entnotes; Owner: -
--

INSERT INTO brevet_note_valeur_textuelle (id, valeur) VALUES (1, 'AB');
INSERT INTO brevet_note_valeur_textuelle (id, valeur) VALUES (2, 'DI');
INSERT INTO brevet_note_valeur_textuelle (id, valeur) VALUES (3, 'VA');
INSERT INTO brevet_note_valeur_textuelle (id, valeur) VALUES (4, 'NV');


--
-- TOC entry 5077 (class 0 OID 136792)
-- Dependencies: 435
-- Data for Name: brevet_rel_epreuve_matiere; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5075 (class 0 OID 136750)
-- Dependencies: 432
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
-- TOC entry 5072 (class 0 OID 136718)
-- Dependencies: 429
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
-- TOC entry 5003 (class 0 OID 132184)
-- Dependencies: 288
-- Data for Name: dirty_moyenne; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5004 (class 0 OID 132189)
-- Dependencies: 290
-- Data for Name: evaluation; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5005 (class 0 OID 132200)
-- Dependencies: 292
-- Data for Name: info_calcul_moyennes_classe; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5006 (class 0 OID 132206)
-- Dependencies: 294
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
-- TOC entry 5007 (class 0 OID 132214)
-- Dependencies: 296
-- Data for Name: modele_appreciation_professeur; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5008 (class 0 OID 132222)
-- Dependencies: 298
-- Data for Name: note; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5080 (class 0 OID 136947)
-- Dependencies: 441
-- Data for Name: note_textuelle; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5009 (class 0 OID 132231)
-- Dependencies: 300
-- Data for Name: rel_evaluation_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5010 (class 0 OID 132234)
-- Dependencies: 301
-- Data for Name: resultat_classe_enseignement_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5011 (class 0 OID 132242)
-- Dependencies: 303
-- Data for Name: resultat_classe_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5012 (class 0 OID 132250)
-- Dependencies: 305
-- Data for Name: resultat_classe_service_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5013 (class 0 OID 132258)
-- Dependencies: 307
-- Data for Name: resultat_classe_sous_service_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5014 (class 0 OID 132266)
-- Dependencies: 309
-- Data for Name: resultat_eleve_enseignement_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5015 (class 0 OID 132274)
-- Dependencies: 311
-- Data for Name: resultat_eleve_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5016 (class 0 OID 132282)
-- Dependencies: 313
-- Data for Name: resultat_eleve_service_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



--
-- TOC entry 5017 (class 0 OID 132290)
-- Dependencies: 315
-- Data for Name: resultat_eleve_sous_service_periode; Type: TABLE DATA; Schema: entnotes; Owner: -
--



SET search_path = entnotes_2011_2012, pg_catalog;

--
-- TOC entry 5109 (class 0 OID 137376)
-- Dependencies: 477
-- Data for Name: appreciation_classe_enseignement_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5110 (class 0 OID 137386)
-- Dependencies: 478
-- Data for Name: appreciation_eleve_enseignement_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5108 (class 0 OID 137366)
-- Dependencies: 476
-- Data for Name: appreciation_eleve_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5124 (class 0 OID 137519)
-- Dependencies: 492
-- Data for Name: brevet_epreuve; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5128 (class 0 OID 137551)
-- Dependencies: 496
-- Data for Name: brevet_fiche; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5121 (class 0 OID 137497)
-- Dependencies: 489
-- Data for Name: brevet_note; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5122 (class 0 OID 137507)
-- Dependencies: 490
-- Data for Name: brevet_rel_epreuve_matiere; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5123 (class 0 OID 137514)
-- Dependencies: 491
-- Data for Name: brevet_rel_epreuve_note_valeur_textuelle; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5125 (class 0 OID 137526)
-- Dependencies: 493
-- Data for Name: brevet_serie; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5127 (class 0 OID 137539)
-- Dependencies: 495
-- Data for Name: evaluation; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5129 (class 0 OID 137558)
-- Dependencies: 497
-- Data for Name: info_calcul_moyennes_classe; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5112 (class 0 OID 137401)
-- Dependencies: 480
-- Data for Name: note; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5111 (class 0 OID 137396)
-- Dependencies: 479
-- Data for Name: note_textuelle; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5126 (class 0 OID 137534)
-- Dependencies: 494
-- Data for Name: rel_evaluation_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5113 (class 0 OID 137413)
-- Dependencies: 481
-- Data for Name: resultat_classe_enseignement_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5114 (class 0 OID 137423)
-- Dependencies: 482
-- Data for Name: resultat_classe_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5116 (class 0 OID 137443)
-- Dependencies: 484
-- Data for Name: resultat_classe_service_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5115 (class 0 OID 137433)
-- Dependencies: 483
-- Data for Name: resultat_classe_sous_service_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5117 (class 0 OID 137453)
-- Dependencies: 485
-- Data for Name: resultat_eleve_enseignement_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5118 (class 0 OID 137464)
-- Dependencies: 486
-- Data for Name: resultat_eleve_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5120 (class 0 OID 137486)
-- Dependencies: 488
-- Data for Name: resultat_eleve_service_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



--
-- TOC entry 5119 (class 0 OID 137475)
-- Dependencies: 487
-- Data for Name: resultat_eleve_sous_service_periode; Type: TABLE DATA; Schema: entnotes_2011_2012; Owner: -
--



SET search_path = enttemps, pg_catalog;

--
-- TOC entry 5018 (class 0 OID 132298)
-- Dependencies: 317
-- Data for Name: absence_journee; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5019 (class 0 OID 132303)
-- Dependencies: 319
-- Data for Name: agenda; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5020 (class 0 OID 132312)
-- Dependencies: 321
-- Data for Name: appel; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5021 (class 0 OID 132318)
-- Dependencies: 323
-- Data for Name: appel_ligne; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5022 (class 0 OID 132332)
-- Dependencies: 325
-- Data for Name: appel_plage_horaire; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5024 (class 0 OID 132340)
-- Dependencies: 328
-- Data for Name: date_exclue; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5025 (class 0 OID 132347)
-- Dependencies: 331
-- Data for Name: evenement; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5026 (class 0 OID 132355)
-- Dependencies: 333
-- Data for Name: groupe_motif; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5027 (class 0 OID 132364)
-- Dependencies: 335
-- Data for Name: incident; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5028 (class 0 OID 132369)
-- Dependencies: 337
-- Data for Name: lieu_incident; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5029 (class 0 OID 132374)
-- Dependencies: 339
-- Data for Name: motif; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5030 (class 0 OID 132383)
-- Dependencies: 341
-- Data for Name: partenaire_a_prevenir; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5031 (class 0 OID 132386)
-- Dependencies: 342
-- Data for Name: partenaire_a_prevenir_incident; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5032 (class 0 OID 132393)
-- Dependencies: 345
-- Data for Name: plage_horaire; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5033 (class 0 OID 132405)
-- Dependencies: 347
-- Data for Name: preference_etablissement_absences; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5034 (class 0 OID 132410)
-- Dependencies: 349
-- Data for Name: preference_utilisateur_agenda; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5035 (class 0 OID 132415)
-- Dependencies: 351
-- Data for Name: protagoniste_incident; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5036 (class 0 OID 132420)
-- Dependencies: 353
-- Data for Name: punition; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5037 (class 0 OID 132425)
-- Dependencies: 355
-- Data for Name: qualite_protagoniste; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5038 (class 0 OID 132430)
-- Dependencies: 357
-- Data for Name: rel_agenda_evenement; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5039 (class 0 OID 132435)
-- Dependencies: 359
-- Data for Name: repeter_jour_annee; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5040 (class 0 OID 132440)
-- Dependencies: 361
-- Data for Name: repeter_jour_mois; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5041 (class 0 OID 132445)
-- Dependencies: 363
-- Data for Name: repeter_jour_semaine; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5042 (class 0 OID 132450)
-- Dependencies: 365
-- Data for Name: repeter_mois; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5043 (class 0 OID 132455)
-- Dependencies: 367
-- Data for Name: repeter_semaine_annee; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5044 (class 0 OID 132460)
-- Dependencies: 369
-- Data for Name: sanction; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5045 (class 0 OID 132465)
-- Dependencies: 371
-- Data for Name: type_agenda; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5046 (class 0 OID 132470)
-- Dependencies: 373
-- Data for Name: type_evenement; Type: TABLE DATA; Schema: enttemps; Owner: -
--

INSERT INTO type_evenement (id, type) VALUES (2, 'APPEL');
INSERT INTO type_evenement (id, type) VALUES (3, 'JOUR_FERIE');
INSERT INTO type_evenement (id, type) VALUES (4, 'FERMETURE_HEBDO');
INSERT INTO type_evenement (id, type) VALUES (5, 'COURS');
INSERT INTO type_evenement (id, type) VALUES (6, 'UTILISATEUR');
INSERT INTO type_evenement (id, type) VALUES (7, 'UDT');


--
-- TOC entry 5047 (class 0 OID 132475)
-- Dependencies: 375
-- Data for Name: type_incident; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5048 (class 0 OID 132480)
-- Dependencies: 377
-- Data for Name: type_punition; Type: TABLE DATA; Schema: enttemps; Owner: -
--



--
-- TOC entry 5049 (class 0 OID 132485)
-- Dependencies: 379
-- Data for Name: type_sanction; Type: TABLE DATA; Schema: enttemps; Owner: -
--



SET search_path = enttemps_2011_2012, pg_catalog;

--
-- TOC entry 5097 (class 0 OID 137278)
-- Dependencies: 465
-- Data for Name: absence_journee; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5105 (class 0 OID 137341)
-- Dependencies: 473
-- Data for Name: agenda; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5096 (class 0 OID 137270)
-- Dependencies: 464
-- Data for Name: appel; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5103 (class 0 OID 137312)
-- Dependencies: 471
-- Data for Name: appel_ligne; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5102 (class 0 OID 137307)
-- Dependencies: 470
-- Data for Name: appel_plage_horaire; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5104 (class 0 OID 137334)
-- Dependencies: 472
-- Data for Name: calendrier; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5106 (class 0 OID 137350)
-- Dependencies: 474
-- Data for Name: evenement; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5087 (class 0 OID 137201)
-- Dependencies: 455
-- Data for Name: groupe_motif; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5093 (class 0 OID 137251)
-- Dependencies: 461
-- Data for Name: incident; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5089 (class 0 OID 137219)
-- Dependencies: 457
-- Data for Name: lieu_incident; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5091 (class 0 OID 137233)
-- Dependencies: 459
-- Data for Name: motif; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5094 (class 0 OID 137256)
-- Dependencies: 462
-- Data for Name: partenaire_a_prevenir; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5100 (class 0 OID 137295)
-- Dependencies: 468
-- Data for Name: partenaire_a_prevenir_incident; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5086 (class 0 OID 137189)
-- Dependencies: 454
-- Data for Name: plage_horaire; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5085 (class 0 OID 137182)
-- Dependencies: 453
-- Data for Name: preference_etablissement_absences; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5099 (class 0 OID 137290)
-- Dependencies: 467
-- Data for Name: protagoniste_incident; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5101 (class 0 OID 137302)
-- Dependencies: 469
-- Data for Name: punition; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5090 (class 0 OID 137226)
-- Dependencies: 458
-- Data for Name: qualite_protagoniste; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5107 (class 0 OID 137358)
-- Dependencies: 475
-- Data for Name: rel_agenda_evenement; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5098 (class 0 OID 137285)
-- Dependencies: 466
-- Data for Name: sanction; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5088 (class 0 OID 137212)
-- Dependencies: 456
-- Data for Name: type_incident; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5095 (class 0 OID 137263)
-- Dependencies: 463
-- Data for Name: type_punition; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



--
-- TOC entry 5092 (class 0 OID 137244)
-- Dependencies: 460
-- Data for Name: type_sanction; Type: TABLE DATA; Schema: enttemps_2011_2012; Owner: -
--



SET search_path = forum, pg_catalog;

--
-- TOC entry 5050 (class 0 OID 132490)
-- Dependencies: 381
-- Data for Name: commentaire; Type: TABLE DATA; Schema: forum; Owner: -
--



--
-- TOC entry 5051 (class 0 OID 132498)
-- Dependencies: 383
-- Data for Name: commentaire_lu; Type: TABLE DATA; Schema: forum; Owner: -
--



--
-- TOC entry 5052 (class 0 OID 132501)
-- Dependencies: 384
-- Data for Name: discussion; Type: TABLE DATA; Schema: forum; Owner: -
--



--
-- TOC entry 5053 (class 0 OID 132506)
-- Dependencies: 386
-- Data for Name: etat_commentaire; Type: TABLE DATA; Schema: forum; Owner: -
--



--
-- TOC entry 5054 (class 0 OID 132509)
-- Dependencies: 387
-- Data for Name: etat_discussion; Type: TABLE DATA; Schema: forum; Owner: -
--



--
-- TOC entry 5055 (class 0 OID 132512)
-- Dependencies: 388
-- Data for Name: type_moderation; Type: TABLE DATA; Schema: forum; Owner: -
--



SET search_path = impression, pg_catalog;

--
-- TOC entry 5056 (class 0 OID 132515)
-- Dependencies: 389
-- Data for Name: publipostage_suivi; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- TOC entry 5078 (class 0 OID 136868)
-- Dependencies: 437
-- Data for Name: sms_fournisseur; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- TOC entry 5079 (class 0 OID 136925)
-- Dependencies: 439
-- Data for Name: sms_fournisseur_etablissement; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- TOC entry 5057 (class 0 OID 132523)
-- Dependencies: 391
-- Data for Name: template_champ_memo; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- TOC entry 5058 (class 0 OID 132531)
-- Dependencies: 393
-- Data for Name: template_document; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- TOC entry 5059 (class 0 OID 132541)
-- Dependencies: 395
-- Data for Name: template_document_sous_template_eliot; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- TOC entry 5060 (class 0 OID 132546)
-- Dependencies: 397
-- Data for Name: template_eliot; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- TOC entry 5061 (class 0 OID 132560)
-- Dependencies: 399
-- Data for Name: template_jasper; Type: TABLE DATA; Schema: impression; Owner: -
--



--
-- TOC entry 5062 (class 0 OID 132568)
-- Dependencies: 401
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
-- TOC entry 5063 (class 0 OID 132573)
-- Dependencies: 403
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
-- TOC entry 5064 (class 0 OID 132580)
-- Dependencies: 406
-- Data for Name: eliot_version; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO eliot_version (id, date, code) VALUES (1, '2011-09-13 15:37:42.908592', '2.5.1-SNAPSHOT');
INSERT INTO eliot_version (id, date, code) VALUES (2, '2011-09-13 15:37:43.076475', '2.6.0-SNAPSHOT');
INSERT INTO eliot_version (id, date, code) VALUES (3, '2011-09-13 15:37:43.102585', '2.7.0-SNAPSHOT');
INSERT INTO eliot_version (id, date, code) VALUES (4, '2012-07-19 17:51:24.218526', '2.7.0-RC1');
INSERT INTO eliot_version (id, date, code) VALUES (5, '2012-07-19 17:51:24.223648', '2.7.1-SNAPSHOT');
INSERT INTO eliot_version (id, date, code) VALUES (6, '2012-07-19 17:51:24.348556', '2.7.1-A1');
INSERT INTO eliot_version (id, date, code) VALUES (7, '2012-07-19 17:51:24.352979', '2.7.1-RC1');
INSERT INTO eliot_version (id, date, code) VALUES (8, '2012-07-19 17:51:24.357916', '2.7.2-SNAPSHOT');
INSERT INTO eliot_version (id, date, code) VALUES (9, '2012-07-19 17:51:24.362452', '2.7.2');
INSERT INTO eliot_version (id, date, code) VALUES (10, '2012-07-19 17:51:24.367263', '2.8.0-A1');
INSERT INTO eliot_version (id, date, code) VALUES (11, '2012-07-19 17:51:24.371519', '2.8.0-RC1');
INSERT INTO eliot_version (id, date, code) VALUES (12, '2012-07-19 17:51:24.460235', '2.8.1-RC1');
INSERT INTO eliot_version (id, date, code) VALUES (13, '2012-07-19 17:51:24.464948', '2.8.2-A1');


SET search_path = securite, pg_catalog;

--
-- TOC entry 5065 (class 0 OID 132585)
-- Dependencies: 407
-- Data for Name: autorisation; Type: TABLE DATA; Schema: securite; Owner: -
--



--
-- TOC entry 4981 (class 0 OID 131998)
-- Dependencies: 247
-- Data for Name: autorite; Type: TABLE DATA; Schema: securite; Owner: -
--



--
-- TOC entry 5066 (class 0 OID 132589)
-- Dependencies: 408
-- Data for Name: item; Type: TABLE DATA; Schema: securite; Owner: -
--



--
-- TOC entry 5067 (class 0 OID 132593)
-- Dependencies: 409
-- Data for Name: perimetre; Type: TABLE DATA; Schema: securite; Owner: -
--



--
-- TOC entry 5068 (class 0 OID 132597)
-- Dependencies: 410
-- Data for Name: perimetre_securite; Type: TABLE DATA; Schema: securite; Owner: -
--



--
-- TOC entry 5069 (class 0 OID 132600)
-- Dependencies: 411
-- Data for Name: permission; Type: TABLE DATA; Schema: securite; Owner: -
--

INSERT INTO permission (id, version, nom, valeur) VALUES (1, 1, 'PEUT_CONSULTER_LE_CONTENU', 1);
INSERT INTO permission (id, version, nom, valeur) VALUES (2, 1, 'PEUT_MODIFIER_LE_CONTENU', 2);
INSERT INTO permission (id, version, nom, valeur) VALUES (3, 1, 'PEUT_CONSULTER_LES_PERMISSIONS', 4);
INSERT INTO permission (id, version, nom, valeur) VALUES (4, 1, 'PEUT_MODIFIER_LES_PERMISSIONS', 8);
INSERT INTO permission (id, version, nom, valeur) VALUES (5, 1, 'PEUT_SUPPRIMER', 16);


SET search_path = td, pg_catalog;

--
-- TOC entry 5156 (class 0 OID 138798)
-- Dependencies: 536
-- Data for Name: copie; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- TOC entry 5158 (class 0 OID 138854)
-- Dependencies: 539
-- Data for Name: modalite_activite; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- TOC entry 5149 (class 0 OID 138593)
-- Dependencies: 522
-- Data for Name: question; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- TOC entry 5151 (class 0 OID 138657)
-- Dependencies: 526
-- Data for Name: question_attachement; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- TOC entry 5150 (class 0 OID 138635)
-- Dependencies: 524
-- Data for Name: question_export; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- TOC entry 5148 (class 0 OID 138583)
-- Dependencies: 520
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
-- TOC entry 5157 (class 0 OID 138826)
-- Dependencies: 538
-- Data for Name: reponse; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- TOC entry 5160 (class 0 OID 139113)
-- Dependencies: 544
-- Data for Name: reponse_attachement; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- TOC entry 5152 (class 0 OID 138696)
-- Dependencies: 528
-- Data for Name: sujet; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- TOC entry 5153 (class 0 OID 138731)
-- Dependencies: 530
-- Data for Name: sujet_sequence_questions; Type: TABLE DATA; Schema: td; Owner: -
--



--
-- TOC entry 5159 (class 0 OID 138977)
-- Dependencies: 541
-- Data for Name: sujet_type; Type: TABLE DATA; Schema: td; Owner: -
--

INSERT INTO sujet_type (id, nom, nom_anglais) VALUES (1, 'Sujet', 'Exercise set');
INSERT INTO sujet_type (id, nom, nom_anglais) VALUES (2, 'Exercice', 'Exercise');


SET search_path = tice, pg_catalog;

--
-- TOC entry 5147 (class 0 OID 138572)
-- Dependencies: 518
-- Data for Name: attachement; Type: TABLE DATA; Schema: tice; Owner: -
--



--
-- TOC entry 5145 (class 0 OID 138543)
-- Dependencies: 514
-- Data for Name: compte_utilisateur; Type: TABLE DATA; Schema: tice; Owner: -
--



--
-- TOC entry 5154 (class 0 OID 138750)
-- Dependencies: 532
-- Data for Name: copyrights_type; Type: TABLE DATA; Schema: tice; Owner: -
--

INSERT INTO copyrights_type (id, code, presentation, lien, logo, option_cc_paternite, option_cc_pas_utilisation_commerciale, option_cc_pas_modification, option_cc_partage_viral, option_tous_droits_reserves) VALUES (1, 'Tous droits réservés', 'Cette oeuvre est mise à disposition selon les termes du droit d''auteur émanant du code de la propriété intellectuelle.', 'http://www.legifrance.gouv.fr/affichCode.do?cidTexte=LEGITEXT000006069414', NULL, true, true, true, NULL, true);
INSERT INTO copyrights_type (id, code, presentation, lien, logo, option_cc_paternite, option_cc_pas_utilisation_commerciale, option_cc_pas_modification, option_cc_partage_viral, option_tous_droits_reserves) VALUES (2, '(CC) BY-NC-SA', 'Cette oeuvre est mise à disposition selon les termes de la Licence Creative Commons Paternité - Pas d''Utilisation Commerciale - Partage à l''Identique 2.0 France', 'http://creativecommons.org/licenses/by-nc-sa/2.0/fr/', 'CC-BY-NC-SA.png', true, true, false, true, false);
INSERT INTO copyrights_type (id, code, presentation, lien, logo, option_cc_paternite, option_cc_pas_utilisation_commerciale, option_cc_pas_modification, option_cc_partage_viral, option_tous_droits_reserves) VALUES (3, '(CC) BY-NC', 'Cette oeuvre est mise à disposition selon les termes de la Licence Creative Commons Paternité - Pas d''Utilisation Commerciale - France', 'http://creativecommons.org/licenses/by-nc/2.0/fr/', 'CC-BY-NC.png', true, true, false, false, false);


--
-- TOC entry 5161 (class 0 OID 139155)
-- Dependencies: 547
-- Data for Name: db_data_record; Type: TABLE DATA; Schema: tice; Owner: -
--



--
-- TOC entry 5146 (class 0 OID 138565)
-- Dependencies: 516
-- Data for Name: export_format; Type: TABLE DATA; Schema: tice; Owner: -
--

INSERT INTO export_format (id, nom, code) VALUES (1, 'IMS Question & Test Interoperability', 'QTI');


--
-- TOC entry 5155 (class 0 OID 138765)
-- Dependencies: 533
-- Data for Name: publication; Type: TABLE DATA; Schema: tice; Owner: -
--



SET search_path = udt, pg_catalog;

--
-- TOC entry 5083 (class 0 OID 137121)
-- Dependencies: 450
-- Data for Name: enseignement; Type: TABLE DATA; Schema: udt; Owner: -
--



--
-- TOC entry 5084 (class 0 OID 137148)
-- Dependencies: 452
-- Data for Name: evenement; Type: TABLE DATA; Schema: udt; Owner: -
--



--
-- TOC entry 5082 (class 0 OID 137109)
-- Dependencies: 448
-- Data for Name: import; Type: TABLE DATA; Schema: udt; Owner: -
--



SET search_path = aaf, pg_catalog;

--
-- TOC entry 3586 (class 2606 OID 132619)
-- Dependencies: 179 179
-- Name: pk_import; Type: CONSTRAINT; Schema: aaf; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import
    ADD CONSTRAINT pk_import PRIMARY KEY (id);


--
-- TOC entry 3588 (class 2606 OID 132621)
-- Dependencies: 181 181
-- Name: pk_import_verrou; Type: CONSTRAINT; Schema: aaf; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_verrou
    ADD CONSTRAINT pk_import_verrou PRIMARY KEY (id);


SET search_path = bascule_annee, pg_catalog;

--
-- TOC entry 4117 (class 2606 OID 134472)
-- Dependencies: 418 418
-- Name: etape_index_key; Type: CONSTRAINT; Schema: bascule_annee; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etape
    ADD CONSTRAINT etape_index_key UNIQUE (index);


--
-- TOC entry 4119 (class 2606 OID 134481)
-- Dependencies: 418 418 418
-- Name: etape_module_code_etape_code_key; Type: CONSTRAINT; Schema: bascule_annee; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etape
    ADD CONSTRAINT etape_module_code_etape_code_key UNIQUE (module_code, etape_code);


--
-- TOC entry 4121 (class 2606 OID 134470)
-- Dependencies: 418 418
-- Name: pk_etape; Type: CONSTRAINT; Schema: bascule_annee; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etape
    ADD CONSTRAINT pk_etape PRIMARY KEY (id);


--
-- TOC entry 3590 (class 2606 OID 132625)
-- Dependencies: 183 183
-- Name: pk_verrou; Type: CONSTRAINT; Schema: bascule_annee; Owner: -; Tablespace: 
--

ALTER TABLE ONLY verrou
    ADD CONSTRAINT pk_verrou PRIMARY KEY (id);


--
-- TOC entry 3592 (class 2606 OID 132627)
-- Dependencies: 183 183
-- Name: uk_verrou_nom; Type: CONSTRAINT; Schema: bascule_annee; Owner: -; Tablespace: 
--

ALTER TABLE ONLY verrou
    ADD CONSTRAINT uk_verrou_nom UNIQUE (nom);


SET search_path = ent, pg_catalog;

--
-- TOC entry 3594 (class 2606 OID 135836)
-- Dependencies: 185 185
-- Name: pk_annee_scolaire; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY annee_scolaire
    ADD CONSTRAINT pk_annee_scolaire PRIMARY KEY (id);


--
-- TOC entry 3600 (class 2606 OID 132645)
-- Dependencies: 187 187
-- Name: pk_appartenance_groupe_groupe; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appartenance_groupe_groupe
    ADD CONSTRAINT pk_appartenance_groupe_groupe PRIMARY KEY (id);


--
-- TOC entry 3605 (class 2606 OID 132647)
-- Dependencies: 189 189
-- Name: pk_appartenance_personne_groupe; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appartenance_personne_groupe
    ADD CONSTRAINT pk_appartenance_personne_groupe PRIMARY KEY (id);


--
-- TOC entry 3925 (class 2606 OID 132885)
-- Dependencies: 327 327
-- Name: pk_calendrier; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT pk_calendrier PRIMARY KEY (id);


--
-- TOC entry 3609 (class 2606 OID 132649)
-- Dependencies: 191 191
-- Name: pk_civilite; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY civilite
    ADD CONSTRAINT pk_civilite PRIMARY KEY (id);


--
-- TOC entry 3697 (class 2606 OID 135877)
-- Dependencies: 229 229
-- Name: pk_enseignement; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT pk_enseignement PRIMARY KEY (id);


--
-- TOC entry 3717 (class 2606 OID 132651)
-- Dependencies: 236 236
-- Name: pk_ent_service; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY service
    ADD CONSTRAINT pk_ent_service PRIMARY KEY (id);


--
-- TOC entry 3615 (class 2606 OID 132653)
-- Dependencies: 193 193
-- Name: pk_etablissement; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT pk_etablissement PRIMARY KEY (id);


--
-- TOC entry 4123 (class 2606 OID 134489)
-- Dependencies: 420 420
-- Name: pk_fiche_eleve_commentaire; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fiche_eleve_commentaire
    ADD CONSTRAINT pk_fiche_eleve_commentaire PRIMARY KEY (id);


--
-- TOC entry 3621 (class 2606 OID 132655)
-- Dependencies: 195 195
-- Name: pk_filiere; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY filiere
    ADD CONSTRAINT pk_filiere PRIMARY KEY (id);


--
-- TOC entry 3623 (class 2606 OID 132657)
-- Dependencies: 197 197
-- Name: pk_fonction; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fonction
    ADD CONSTRAINT pk_fonction PRIMARY KEY (id);


--
-- TOC entry 3628 (class 2606 OID 132659)
-- Dependencies: 199 199
-- Name: pk_groupe_personnes; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT pk_groupe_personnes PRIMARY KEY (id);


--
-- TOC entry 3634 (class 2606 OID 135863)
-- Dependencies: 202 202
-- Name: pk_matiere; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT pk_matiere PRIMARY KEY (id);


--
-- TOC entry 3640 (class 2606 OID 132661)
-- Dependencies: 204 204
-- Name: pk_mef; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mef
    ADD CONSTRAINT pk_mef PRIMARY KEY (id);


--
-- TOC entry 3644 (class 2606 OID 135865)
-- Dependencies: 206 206
-- Name: pk_modalite_cours; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_cours
    ADD CONSTRAINT pk_modalite_cours PRIMARY KEY (id);


--
-- TOC entry 3648 (class 2606 OID 132663)
-- Dependencies: 208 208
-- Name: pk_modalite_matiere; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT pk_modalite_matiere PRIMARY KEY (id);


--
-- TOC entry 3652 (class 2606 OID 132665)
-- Dependencies: 210 210
-- Name: pk_niveau; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY niveau
    ADD CONSTRAINT pk_niveau PRIMARY KEY (id);


--
-- TOC entry 3656 (class 2606 OID 132667)
-- Dependencies: 212 212
-- Name: pk_periode; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT pk_periode PRIMARY KEY (id);


--
-- TOC entry 3661 (class 2606 OID 132669)
-- Dependencies: 214 214
-- Name: pk_personne; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT pk_personne PRIMARY KEY (id);


--
-- TOC entry 3669 (class 2606 OID 135608)
-- Dependencies: 216 216
-- Name: pk_personne_propriete_scolarite; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT pk_personne_propriete_scolarite PRIMARY KEY (id);


--
-- TOC entry 3671 (class 2606 OID 132673)
-- Dependencies: 218 218
-- Name: pk_porteur_ent; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY porteur_ent
    ADD CONSTRAINT pk_porteur_ent PRIMARY KEY (id);


--
-- TOC entry 3678 (class 2606 OID 135624)
-- Dependencies: 220 220
-- Name: pk_preference_etablissement; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT pk_preference_etablissement PRIMARY KEY (id);


--
-- TOC entry 3684 (class 2606 OID 135528)
-- Dependencies: 223 223
-- Name: pk_propriete_scolarite; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT pk_propriete_scolarite PRIMARY KEY (id);


--
-- TOC entry 3686 (class 2606 OID 132681)
-- Dependencies: 225 225
-- Name: pk_regime; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY regime
    ADD CONSTRAINT pk_regime PRIMARY KEY (id);


--
-- TOC entry 3691 (class 2606 OID 135496)
-- Dependencies: 227 227 227
-- Name: pk_rel_classe_filiere; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT pk_rel_classe_filiere PRIMARY KEY (classe_id, filiere_id);


--
-- TOC entry 3694 (class 2606 OID 135498)
-- Dependencies: 228 228 228
-- Name: pk_rel_classe_groupe; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT pk_rel_classe_groupe PRIMARY KEY (classe_id, groupe_id);


--
-- TOC entry 3702 (class 2606 OID 132689)
-- Dependencies: 230 230
-- Name: pk_rel_periode_service; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT pk_rel_periode_service PRIMARY KEY (id);


--
-- TOC entry 3707 (class 2606 OID 132691)
-- Dependencies: 232 232
-- Name: pk_responsable_eleve; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT pk_responsable_eleve PRIMARY KEY (id);


--
-- TOC entry 3713 (class 2606 OID 135610)
-- Dependencies: 234 234
-- Name: pk_responsable_propriete_scolarite; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT pk_responsable_propriete_scolarite PRIMARY KEY (id);


--
-- TOC entry 3719 (class 2606 OID 132695)
-- Dependencies: 238 238
-- Name: pk_signature; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY signature
    ADD CONSTRAINT pk_signature PRIMARY KEY (id);


--
-- TOC entry 3721 (class 2606 OID 132697)
-- Dependencies: 240 240
-- Name: pk_source_import; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY source_import
    ADD CONSTRAINT pk_source_import PRIMARY KEY (id);


--
-- TOC entry 3726 (class 2606 OID 132699)
-- Dependencies: 241 241
-- Name: pk_sous_service; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT pk_sous_service PRIMARY KEY (id);


--
-- TOC entry 3730 (class 2606 OID 132701)
-- Dependencies: 243 243
-- Name: pk_structure_enseignement; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT pk_structure_enseignement PRIMARY KEY (id);


--
-- TOC entry 3734 (class 2606 OID 132703)
-- Dependencies: 245 245
-- Name: pk_type_periode; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_periode
    ADD CONSTRAINT pk_type_periode PRIMARY KEY (id);


--
-- TOC entry 3596 (class 2606 OID 137045)
-- Dependencies: 185 185
-- Name: uk_annee_scolaire_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY annee_scolaire
    ADD CONSTRAINT uk_annee_scolaire_code UNIQUE (code);


--
-- TOC entry 3602 (class 2606 OID 135770)
-- Dependencies: 187 187 187
-- Name: uk_appartenance_groupe_groupe_groupe_personnes_parent_id_groupe; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appartenance_groupe_groupe
    ADD CONSTRAINT uk_appartenance_groupe_groupe_groupe_personnes_parent_id_groupe UNIQUE (groupe_personnes_parent_id, groupe_personnes_enfant_id);


--
-- TOC entry 3607 (class 2606 OID 135772)
-- Dependencies: 189 189 189
-- Name: uk_appartenance_personne_groupe_personne_id_groupe_personnes_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appartenance_personne_groupe
    ADD CONSTRAINT uk_appartenance_personne_groupe_personne_id_groupe_personnes_id UNIQUE (personne_id, groupe_personnes_id);


--
-- TOC entry 3927 (class 2606 OID 136628)
-- Dependencies: 327 327 327
-- Name: uk_calendrier_etablissement_id_annee_scolaire_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT uk_calendrier_etablissement_id_annee_scolaire_id UNIQUE (etablissement_id, annee_scolaire_id);


--
-- TOC entry 3611 (class 2606 OID 132713)
-- Dependencies: 191 191
-- Name: uk_civilite_libelle; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY civilite
    ADD CONSTRAINT uk_civilite_libelle UNIQUE (libelle);


--
-- TOC entry 3699 (class 2606 OID 135506)
-- Dependencies: 229 229 229
-- Name: uk_enseignement_enseignant_id_service_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT uk_enseignement_enseignant_id_service_id UNIQUE (enseignant_id, service_id);


--
-- TOC entry 3617 (class 2606 OID 132719)
-- Dependencies: 193 193
-- Name: uk_etablissement_id_externe; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT uk_etablissement_id_externe UNIQUE (id_externe);


--
-- TOC entry 3619 (class 2606 OID 132721)
-- Dependencies: 193 193
-- Name: uk_etablissement_uai; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT uk_etablissement_uai UNIQUE (uai);


--
-- TOC entry 4125 (class 2606 OID 134499)
-- Dependencies: 420 420
-- Name: uk_fiche_eleve_commentaire_personne_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fiche_eleve_commentaire
    ADD CONSTRAINT uk_fiche_eleve_commentaire_personne_id UNIQUE (personne_id);


--
-- TOC entry 3625 (class 2606 OID 135758)
-- Dependencies: 197 197
-- Name: uk_fonction_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fonction
    ADD CONSTRAINT uk_fonction_code UNIQUE (code);


--
-- TOC entry 3630 (class 2606 OID 135760)
-- Dependencies: 199 199
-- Name: uk_groupe_personnes_autorite_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT uk_groupe_personnes_autorite_id UNIQUE (autorite_id);


--
-- TOC entry 3632 (class 2606 OID 135762)
-- Dependencies: 199 199
-- Name: uk_groupe_personnes_item_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT uk_groupe_personnes_item_id UNIQUE (item_id);


--
-- TOC entry 3636 (class 2606 OID 135774)
-- Dependencies: 202 202 202
-- Name: uk_matiere_etablissement_id_code_gestion; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT uk_matiere_etablissement_id_code_gestion UNIQUE (etablissement_id, code_gestion);


--
-- TOC entry 3638 (class 2606 OID 135776)
-- Dependencies: 202 202 202
-- Name: uk_matiere_etablissement_id_code_sts; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT uk_matiere_etablissement_id_code_sts UNIQUE (etablissement_id, code_sts);


--
-- TOC entry 3642 (class 2606 OID 135764)
-- Dependencies: 204 204
-- Name: uk_mef_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mef
    ADD CONSTRAINT uk_mef_code UNIQUE (code);


--
-- TOC entry 3646 (class 2606 OID 132723)
-- Dependencies: 206 206
-- Name: uk_modalite_cours_code_sts; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_cours
    ADD CONSTRAINT uk_modalite_cours_code_sts UNIQUE (code_sts);


--
-- TOC entry 3650 (class 2606 OID 135778)
-- Dependencies: 208 208 208
-- Name: uk_modalite_matiere_etablissement_id_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT uk_modalite_matiere_etablissement_id_code UNIQUE (etablissement_id, code);


--
-- TOC entry 3654 (class 2606 OID 136616)
-- Dependencies: 210 210
-- Name: uk_niveau_libelle_court; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY niveau
    ADD CONSTRAINT uk_niveau_libelle_court UNIQUE (libelle_court);


--
-- TOC entry 3658 (class 2606 OID 135786)
-- Dependencies: 212 212 212
-- Name: uk_periode_structure_enseignement_id_type_periode_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT uk_periode_structure_enseignement_id_type_periode_id UNIQUE (structure_enseignement_id, type_periode_id);


--
-- TOC entry 3663 (class 2606 OID 134610)
-- Dependencies: 214 214
-- Name: uk_personne_autorite_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT uk_personne_autorite_id UNIQUE (autorite_id);


--
-- TOC entry 3673 (class 2606 OID 132729)
-- Dependencies: 218 218
-- Name: uk_porteur_ent_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY porteur_ent
    ADD CONSTRAINT uk_porteur_ent_code UNIQUE (code);


--
-- TOC entry 3675 (class 2606 OID 135768)
-- Dependencies: 218 218
-- Name: uk_porteur_perimetre_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY porteur_ent
    ADD CONSTRAINT uk_porteur_perimetre_id UNIQUE (perimetre_id);


--
-- TOC entry 3680 (class 2606 OID 135631)
-- Dependencies: 220 220
-- Name: uk_preference_etablissement_etablissement_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT uk_preference_etablissement_etablissement_id UNIQUE (etablissement_id);


--
-- TOC entry 3688 (class 2606 OID 132735)
-- Dependencies: 225 225
-- Name: uk_regime_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY regime
    ADD CONSTRAINT uk_regime_code UNIQUE (code);


--
-- TOC entry 3704 (class 2606 OID 135780)
-- Dependencies: 230 230 230
-- Name: uk_rel_periode_service_periode_id_service_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT uk_rel_periode_service_periode_id_service_id UNIQUE (periode_id, service_id);


--
-- TOC entry 3709 (class 2606 OID 135782)
-- Dependencies: 232 232 232
-- Name: uk_responsable_eleve_personne_id_eleve_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT uk_responsable_eleve_personne_id_eleve_id UNIQUE (personne_id, eleve_id);


--
-- TOC entry 3723 (class 2606 OID 132741)
-- Dependencies: 240 240
-- Name: uk_source_import_code; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY source_import
    ADD CONSTRAINT uk_source_import_code UNIQUE (code);


--
-- TOC entry 3728 (class 2606 OID 135784)
-- Dependencies: 241 241 241 241
-- Name: uk_sous_service_service_id_type_periode_id_modalite_matiere_id; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT uk_sous_service_service_id_type_periode_id_modalite_matiere_id UNIQUE (service_id, type_periode_id, modalite_matiere_id);


--
-- TOC entry 3732 (class 2606 OID 135508)
-- Dependencies: 243 243 243 243 243
-- Name: uk_structure_enseignement_etablissement_id_annee_scolaire_id_ty; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT uk_structure_enseignement_etablissement_id_annee_scolaire_id_ty UNIQUE (etablissement_id, annee_scolaire_id, type, code);


--
-- TOC entry 3736 (class 2606 OID 135788)
-- Dependencies: 245 245 245
-- Name: uk_type_periode_etablissement_id_libelle; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_periode
    ADD CONSTRAINT uk_type_periode_etablissement_id_libelle UNIQUE (etablissement_id, libelle);


--
-- TOC entry 3738 (class 2606 OID 132751)
-- Dependencies: 245 245
-- Name: uk_type_periode_intervalle; Type: CONSTRAINT; Schema: ent; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_periode
    ADD CONSTRAINT uk_type_periode_intervalle UNIQUE (intervalle);


SET search_path = ent_2011_2012, pg_catalog;

--
-- TOC entry 4319 (class 2606 OID 137571)
-- Dependencies: 498 498
-- Name: pk_annee_scolaire; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT pk_annee_scolaire PRIMARY KEY (id);


--
-- TOC entry 4323 (class 2606 OID 137580)
-- Dependencies: 499 499
-- Name: pk_enseignement; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT pk_enseignement PRIMARY KEY (id);


--
-- TOC entry 4359 (class 2606 OID 137679)
-- Dependencies: 510 510
-- Name: pk_ent_service; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY service
    ADD CONSTRAINT pk_ent_service PRIMARY KEY (id);


--
-- TOC entry 4327 (class 2606 OID 137591)
-- Dependencies: 500 500
-- Name: pk_matiere; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT pk_matiere PRIMARY KEY (id);


--
-- TOC entry 4333 (class 2606 OID 137603)
-- Dependencies: 501 501
-- Name: pk_modalite_matiere; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT pk_modalite_matiere PRIMARY KEY (id);


--
-- TOC entry 4337 (class 2606 OID 137610)
-- Dependencies: 502 502
-- Name: pk_periode; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT pk_periode PRIMARY KEY (id);


--
-- TOC entry 4341 (class 2606 OID 137618)
-- Dependencies: 503 503
-- Name: pk_personne_propriete_scolarite; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT pk_personne_propriete_scolarite PRIMARY KEY (id);


--
-- TOC entry 4343 (class 2606 OID 137630)
-- Dependencies: 504 504
-- Name: pk_preference_etablissement; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT pk_preference_etablissement PRIMARY KEY (id);


--
-- TOC entry 4347 (class 2606 OID 137638)
-- Dependencies: 505 505
-- Name: pk_propriete_scolarite; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT pk_propriete_scolarite PRIMARY KEY (id);


--
-- TOC entry 4349 (class 2606 OID 137643)
-- Dependencies: 506 506 506
-- Name: pk_rel_classe_filiere; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT pk_rel_classe_filiere PRIMARY KEY (classe_id, filiere_id);


--
-- TOC entry 4351 (class 2606 OID 137648)
-- Dependencies: 507 507 507
-- Name: pk_rel_classe_groupe; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT pk_rel_classe_groupe PRIMARY KEY (classe_id, groupe_id);


--
-- TOC entry 4353 (class 2606 OID 137658)
-- Dependencies: 508 508
-- Name: pk_rel_periode_service; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT pk_rel_periode_service PRIMARY KEY (id);


--
-- TOC entry 4357 (class 2606 OID 137666)
-- Dependencies: 509 509
-- Name: pk_responsable_propriete_scolarite; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT pk_responsable_propriete_scolarite PRIMARY KEY (id);


--
-- TOC entry 4361 (class 2606 OID 137688)
-- Dependencies: 511 511
-- Name: pk_sous_service; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT pk_sous_service PRIMARY KEY (id);


--
-- TOC entry 4365 (class 2606 OID 137697)
-- Dependencies: 512 512
-- Name: pk_structure_enseignement; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT pk_structure_enseignement PRIMARY KEY (id);


--
-- TOC entry 4321 (class 2606 OID 137573)
-- Dependencies: 498 498 498
-- Name: uk_calendrier_etablissement_id_annee_scolaire_id; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT uk_calendrier_etablissement_id_annee_scolaire_id UNIQUE (etablissement_id, annee_scolaire_id);


--
-- TOC entry 4325 (class 2606 OID 137582)
-- Dependencies: 499 499 499
-- Name: uk_enseignement_enseignant_id_service_id; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT uk_enseignement_enseignant_id_service_id UNIQUE (enseignant_id, service_id);


--
-- TOC entry 4329 (class 2606 OID 137593)
-- Dependencies: 500 500 500
-- Name: uk_matiere_etablissement_id_code_gestion; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT uk_matiere_etablissement_id_code_gestion UNIQUE (etablissement_id, code_gestion);


--
-- TOC entry 4331 (class 2606 OID 137595)
-- Dependencies: 500 500 500
-- Name: uk_matiere_etablissement_id_code_sts; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT uk_matiere_etablissement_id_code_sts UNIQUE (etablissement_id, code_sts);


--
-- TOC entry 4335 (class 2606 OID 137605)
-- Dependencies: 501 501 501
-- Name: uk_modalite_matiere_etablissement_id_code; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT uk_modalite_matiere_etablissement_id_code UNIQUE (etablissement_id, code);


--
-- TOC entry 4339 (class 2606 OID 137612)
-- Dependencies: 502 502 502
-- Name: uk_periode_structure_enseignement_id_type_periode_id; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT uk_periode_structure_enseignement_id_type_periode_id UNIQUE (structure_enseignement_id, type_periode_id);


--
-- TOC entry 4345 (class 2606 OID 137632)
-- Dependencies: 504 504
-- Name: uk_preference_etablissement_etablissement_id; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT uk_preference_etablissement_etablissement_id UNIQUE (etablissement_id);


--
-- TOC entry 4355 (class 2606 OID 137660)
-- Dependencies: 508 508 508
-- Name: uk_rel_periode_service_periode_id_service_id; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT uk_rel_periode_service_periode_id_service_id UNIQUE (periode_id, service_id);


--
-- TOC entry 4363 (class 2606 OID 137690)
-- Dependencies: 511 511 511 511
-- Name: uk_sous_service_service_id_type_periode_id_modalite_matiere_id; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT uk_sous_service_service_id_type_periode_id_modalite_matiere_id UNIQUE (service_id, type_periode_id, modalite_matiere_id);


--
-- TOC entry 4367 (class 2606 OID 137699)
-- Dependencies: 512 512 512 512 512
-- Name: uk_structure_enseignement_etablissement_id_annee_scolaire_id_ty; Type: CONSTRAINT; Schema: ent_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT uk_structure_enseignement_etablissement_id_annee_scolaire_id_ty UNIQUE (etablissement_id, annee_scolaire_id, type, code);


SET search_path = entcdt, pg_catalog;

--
-- TOC entry 3749 (class 2606 OID 135252)
-- Dependencies: 248 248
-- Name: pk_activite; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT pk_activite PRIMARY KEY (id);


--
-- TOC entry 3753 (class 2606 OID 134895)
-- Dependencies: 250 250
-- Name: pk_cahier_de_textes; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT pk_cahier_de_textes PRIMARY KEY (id);


--
-- TOC entry 3757 (class 2606 OID 134965)
-- Dependencies: 253 253
-- Name: pk_chapitre; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY chapitre
    ADD CONSTRAINT pk_chapitre PRIMARY KEY (id);


--
-- TOC entry 3759 (class 2606 OID 135021)
-- Dependencies: 255 255
-- Name: pk_contexte_activite; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contexte_activite
    ADD CONSTRAINT pk_contexte_activite PRIMARY KEY (id);


--
-- TOC entry 3764 (class 2606 OID 135049)
-- Dependencies: 257 257
-- Name: pk_date_activite; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY date_activite
    ADD CONSTRAINT pk_date_activite PRIMARY KEY (id);


--
-- TOC entry 3770 (class 2606 OID 135071)
-- Dependencies: 259 259
-- Name: pk_dossier; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dossier
    ADD CONSTRAINT pk_dossier PRIMARY KEY (id);


--
-- TOC entry 3772 (class 2606 OID 135116)
-- Dependencies: 261 261
-- Name: pk_fichier; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fichier
    ADD CONSTRAINT pk_fichier PRIMARY KEY (id);


--
-- TOC entry 3775 (class 2606 OID 135475)
-- Dependencies: 263 263
-- Name: pk_rel_activite_acteur; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_activite_acteur
    ADD CONSTRAINT pk_rel_activite_acteur PRIMARY KEY (id);


--
-- TOC entry 3780 (class 2606 OID 135481)
-- Dependencies: 264 264
-- Name: pk_rel_cahier_acteur; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_cahier_acteur
    ADD CONSTRAINT pk_rel_cahier_acteur PRIMARY KEY (id);


--
-- TOC entry 3785 (class 2606 OID 135487)
-- Dependencies: 265 265
-- Name: pk_rel_cahier_groupe; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_cahier_groupe
    ADD CONSTRAINT pk_rel_cahier_groupe PRIMARY KEY (id);


--
-- TOC entry 3790 (class 2606 OID 135493)
-- Dependencies: 266 266
-- Name: pk_rel_dossier_autorisation_cahier; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_dossier_autorisation_cahier
    ADD CONSTRAINT pk_rel_dossier_autorisation_cahier PRIMARY KEY (id);


--
-- TOC entry 3795 (class 2606 OID 135199)
-- Dependencies: 267 267
-- Name: pk_ressource; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ressource
    ADD CONSTRAINT pk_ressource PRIMARY KEY (id);


--
-- TOC entry 3797 (class 2606 OID 132781)
-- Dependencies: 269 269
-- Name: pk_textes_preferences_utilisateur; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY textes_preferences_utilisateur
    ADD CONSTRAINT pk_textes_preferences_utilisateur PRIMARY KEY (id);


--
-- TOC entry 3801 (class 2606 OID 135237)
-- Dependencies: 271 271
-- Name: pk_type_activite; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_activite
    ADD CONSTRAINT pk_type_activite PRIMARY KEY (id);


--
-- TOC entry 3807 (class 2606 OID 132785)
-- Dependencies: 273 273
-- Name: pk_visa; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY visa
    ADD CONSTRAINT pk_visa PRIMARY KEY (id);


--
-- TOC entry 3761 (class 2606 OID 132787)
-- Dependencies: 255 255
-- Name: uk_contexte_activite_code; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contexte_activite
    ADD CONSTRAINT uk_contexte_activite_code UNIQUE (code);


--
-- TOC entry 3766 (class 2606 OID 135510)
-- Dependencies: 257 257 257
-- Name: uk_date_activite_evenement_id_activite_id; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY date_activite
    ADD CONSTRAINT uk_date_activite_evenement_id_activite_id UNIQUE (evenement_id, activite_id);


--
-- TOC entry 3777 (class 2606 OID 135512)
-- Dependencies: 263 263 263
-- Name: uk_rel_activite_acteur_activite_id_acteur_id; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_activite_acteur
    ADD CONSTRAINT uk_rel_activite_acteur_activite_id_acteur_id UNIQUE (activite_id, acteur_id);


--
-- TOC entry 3782 (class 2606 OID 135514)
-- Dependencies: 264 264 264
-- Name: uk_rel_cahier_acteur_acteur_id_cahier_de_textes_id; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_cahier_acteur
    ADD CONSTRAINT uk_rel_cahier_acteur_acteur_id_cahier_de_textes_id UNIQUE (acteur_id, cahier_de_textes_id);


--
-- TOC entry 3787 (class 2606 OID 135516)
-- Dependencies: 265 265 265
-- Name: uk_rel_cahier_groupe_cahier_de_textes_id_groupe_id; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_cahier_groupe
    ADD CONSTRAINT uk_rel_cahier_groupe_cahier_de_textes_id_groupe_id UNIQUE (cahier_de_textes_id, groupe_id);


--
-- TOC entry 3792 (class 2606 OID 135518)
-- Dependencies: 266 266 266
-- Name: uk_rel_dossier_autorisation_cahier_dossier_id_autorisation_id; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_dossier_autorisation_cahier
    ADD CONSTRAINT uk_rel_dossier_autorisation_cahier_dossier_id_autorisation_id UNIQUE (dossier_id, autorisation_id);


--
-- TOC entry 3799 (class 2606 OID 132791)
-- Dependencies: 269 269
-- Name: uk_textes_preferences_utilisateur_utilisateur_id; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY textes_preferences_utilisateur
    ADD CONSTRAINT uk_textes_preferences_utilisateur_utilisateur_id UNIQUE (utilisateur_id);


--
-- TOC entry 3803 (class 2606 OID 132793)
-- Dependencies: 271 271
-- Name: uk_type_activite_code; Type: CONSTRAINT; Schema: entcdt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_activite
    ADD CONSTRAINT uk_type_activite_code UNIQUE (code);


SET search_path = entdemon, pg_catalog;

--
-- TOC entry 3810 (class 2606 OID 132795)
-- Dependencies: 275 275
-- Name: pk_demande_traitement; Type: CONSTRAINT; Schema: entdemon; Owner: -; Tablespace: 
--

ALTER TABLE ONLY demande_traitement
    ADD CONSTRAINT pk_demande_traitement PRIMARY KEY (id);


SET search_path = entnotes, pg_catalog;

--
-- TOC entry 4129 (class 2606 OID 136744)
-- Dependencies: 430 430 430
-- Name: brevet_epreuve_serie_id_code_key; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT brevet_epreuve_serie_id_code_key UNIQUE (serie_id, code);


--
-- TOC entry 4143 (class 2606 OID 136798)
-- Dependencies: 435 435 435
-- Name: brevet_rel_epreuve_matiere_epreuve_id_matiere_id_key; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT brevet_rel_epreuve_matiere_epreuve_id_matiere_id_key UNIQUE (epreuve_id, matiere_id);


--
-- TOC entry 4135 (class 2606 OID 136756)
-- Dependencies: 432 432 432
-- Name: brevet_rel_epreuve_note_valeu_brevet_epreuve_id_valeur_text_key; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT brevet_rel_epreuve_note_valeu_brevet_epreuve_id_valeur_text_key UNIQUE (brevet_epreuve_id, valeur_textuelle_id);


--
-- TOC entry 3812 (class 2606 OID 132797)
-- Dependencies: 277 277
-- Name: pk_appreciation_classe_enseignement_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT pk_appreciation_classe_enseignement_periode PRIMARY KEY (id);


--
-- TOC entry 3816 (class 2606 OID 132799)
-- Dependencies: 279 279
-- Name: pk_appreciation_eleve_enseignement_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT pk_appreciation_eleve_enseignement_periode PRIMARY KEY (id);


--
-- TOC entry 3820 (class 2606 OID 132801)
-- Dependencies: 281 281
-- Name: pk_appreciation_eleve_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT pk_appreciation_eleve_periode PRIMARY KEY (id);


--
-- TOC entry 3824 (class 2606 OID 132803)
-- Dependencies: 283 283
-- Name: pk_avis_conseil_de_classe; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY avis_conseil_de_classe
    ADD CONSTRAINT pk_avis_conseil_de_classe PRIMARY KEY (id);


--
-- TOC entry 3828 (class 2606 OID 132805)
-- Dependencies: 285 285
-- Name: pk_avis_orientation; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY avis_orientation
    ADD CONSTRAINT pk_avis_orientation PRIMARY KEY (id);


--
-- TOC entry 4131 (class 2606 OID 136727)
-- Dependencies: 430 430
-- Name: pk_brevet_epreuve; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT pk_brevet_epreuve PRIMARY KEY (id);


--
-- TOC entry 4155 (class 2606 OID 137075)
-- Dependencies: 443 443
-- Name: pk_brevet_fiche; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT pk_brevet_fiche PRIMARY KEY (id);


--
-- TOC entry 4139 (class 2606 OID 136774)
-- Dependencies: 433 433
-- Name: pk_brevet_note; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT pk_brevet_note PRIMARY KEY (id);


--
-- TOC entry 4133 (class 2606 OID 136749)
-- Dependencies: 431 431
-- Name: pk_brevet_note_valeur_textuelle; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_note_valeur_textuelle
    ADD CONSTRAINT pk_brevet_note_valeur_textuelle PRIMARY KEY (id);


--
-- TOC entry 4145 (class 2606 OID 136796)
-- Dependencies: 435 435
-- Name: pk_brevet_rel_epreuve_matiere; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT pk_brevet_rel_epreuve_matiere PRIMARY KEY (id);


--
-- TOC entry 4137 (class 2606 OID 136754)
-- Dependencies: 432 432 432
-- Name: pk_brevet_rel_epreuve_note_valeur_textuelle; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT pk_brevet_rel_epreuve_note_valeur_textuelle PRIMARY KEY (brevet_epreuve_id, valeur_textuelle_id);


--
-- TOC entry 4127 (class 2606 OID 136722)
-- Dependencies: 429 429
-- Name: pk_brevet_serie; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_serie
    ADD CONSTRAINT pk_brevet_serie PRIMARY KEY (id);


--
-- TOC entry 3840 (class 2606 OID 132809)
-- Dependencies: 288 288
-- Name: pk_dirty_moyenne; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT pk_dirty_moyenne PRIMARY KEY (id);


--
-- TOC entry 3843 (class 2606 OID 132811)
-- Dependencies: 290 290
-- Name: pk_evaluation; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT pk_evaluation PRIMARY KEY (id);


--
-- TOC entry 3845 (class 2606 OID 132813)
-- Dependencies: 292 292
-- Name: pk_info_calcul_moyennes_classe; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT pk_info_calcul_moyennes_classe PRIMARY KEY (id);


--
-- TOC entry 3884 (class 2606 OID 132815)
-- Dependencies: 309 309
-- Name: pk_info_supplementaire; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT pk_info_supplementaire PRIMARY KEY (id);


--
-- TOC entry 3849 (class 2606 OID 132817)
-- Dependencies: 294 294
-- Name: pk_modele_appreciation_etablissement; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modele_appreciation
    ADD CONSTRAINT pk_modele_appreciation_etablissement PRIMARY KEY (id);


--
-- TOC entry 3853 (class 2606 OID 132819)
-- Dependencies: 296 296
-- Name: pk_modele_appreciation_professeur; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modele_appreciation_professeur
    ADD CONSTRAINT pk_modele_appreciation_professeur PRIMARY KEY (id);


--
-- TOC entry 3857 (class 2606 OID 132821)
-- Dependencies: 298 298
-- Name: pk_note; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note
    ADD CONSTRAINT pk_note PRIMARY KEY (id);


--
-- TOC entry 4153 (class 2606 OID 136951)
-- Dependencies: 441 441
-- Name: pk_note_textuelle; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note_textuelle
    ADD CONSTRAINT pk_note_textuelle PRIMARY KEY (id);


--
-- TOC entry 3862 (class 2606 OID 132823)
-- Dependencies: 300 300 300
-- Name: pk_rel_evaluation_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT pk_rel_evaluation_periode PRIMARY KEY (evaluation_id, periode_id);


--
-- TOC entry 3866 (class 2606 OID 132825)
-- Dependencies: 301 301
-- Name: pk_resultat_classe_enseignement_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT pk_resultat_classe_enseignement_periode PRIMARY KEY (id);


--
-- TOC entry 3870 (class 2606 OID 135867)
-- Dependencies: 303 303
-- Name: pk_resultat_classe_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT pk_resultat_classe_periode PRIMARY KEY (id);


--
-- TOC entry 3875 (class 2606 OID 135869)
-- Dependencies: 305 305
-- Name: pk_resultat_classe_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT pk_resultat_classe_service_periode PRIMARY KEY (id);


--
-- TOC entry 3880 (class 2606 OID 132827)
-- Dependencies: 307 307
-- Name: pk_resultat_classe_sous_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT pk_resultat_classe_sous_service_periode PRIMARY KEY (id);


--
-- TOC entry 3888 (class 2606 OID 135871)
-- Dependencies: 311 311
-- Name: pk_resultat_eleve_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT pk_resultat_eleve_periode PRIMARY KEY (id);


--
-- TOC entry 3892 (class 2606 OID 135873)
-- Dependencies: 313 313
-- Name: pk_resultat_eleve_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT pk_resultat_eleve_service_periode PRIMARY KEY (id);


--
-- TOC entry 3897 (class 2606 OID 132829)
-- Dependencies: 315 315
-- Name: pk_resultat_eleve_sous_service_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT pk_resultat_eleve_sous_service_periode PRIMARY KEY (id);


--
-- TOC entry 3814 (class 2606 OID 135790)
-- Dependencies: 277 277 277 277
-- Name: uk_appreciation_classe_enseignement_periode_classe_id_periode_i; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT uk_appreciation_classe_enseignement_periode_classe_id_periode_i UNIQUE (classe_id, periode_id, enseignement_id);


--
-- TOC entry 3818 (class 2606 OID 135792)
-- Dependencies: 279 279 279 279
-- Name: uk_appreciation_eleve_enseignement_periode_eleve_id_periode_id_; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT uk_appreciation_eleve_enseignement_periode_eleve_id_periode_id_ UNIQUE (eleve_id, periode_id, enseignement_id);


--
-- TOC entry 3822 (class 2606 OID 135794)
-- Dependencies: 281 281 281
-- Name: uk_appreciation_eleve_periode_eleve_id_periode_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT uk_appreciation_eleve_periode_eleve_id_periode_id UNIQUE (eleve_id, periode_id);


--
-- TOC entry 3826 (class 2606 OID 135796)
-- Dependencies: 283 283 283
-- Name: uk_avis_conseil_de_classe_etablissement_id_texte; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY avis_conseil_de_classe
    ADD CONSTRAINT uk_avis_conseil_de_classe_etablissement_id_texte UNIQUE (etablissement_id, texte);


--
-- TOC entry 3830 (class 2606 OID 135798)
-- Dependencies: 285 285 285
-- Name: uk_avis_orientation_etablissement_id_texte; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY avis_orientation
    ADD CONSTRAINT uk_avis_orientation_etablissement_id_texte UNIQUE (etablissement_id, texte);


--
-- TOC entry 4157 (class 2606 OID 137094)
-- Dependencies: 443 443 443
-- Name: uk_brevet_fiche_eleve_id_annee_scolaire_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT uk_brevet_fiche_eleve_id_annee_scolaire_id UNIQUE (eleve_id, annee_scolaire_id);


--
-- TOC entry 4141 (class 2606 OID 137096)
-- Dependencies: 433 433 433
-- Name: uk_brevet_note_fiche_id_epreuve_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT uk_brevet_note_fiche_id_epreuve_id UNIQUE (fiche_id, epreuve_id);


--
-- TOC entry 3847 (class 2606 OID 132849)
-- Dependencies: 292 292
-- Name: uk_info_calcul_moyennes_classe_classe_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT uk_info_calcul_moyennes_classe_classe_id UNIQUE (classe_id);


--
-- TOC entry 3855 (class 2606 OID 135808)
-- Dependencies: 296 296 296
-- Name: uk_modele_appreciation_professeur_autorite_id_texte; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modele_appreciation_professeur
    ADD CONSTRAINT uk_modele_appreciation_professeur_autorite_id_texte UNIQUE (autorite_id, texte);


--
-- TOC entry 3851 (class 2606 OID 132851)
-- Dependencies: 294 294 294
-- Name: uk_modele_appreciation_texte_type; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modele_appreciation
    ADD CONSTRAINT uk_modele_appreciation_texte_type UNIQUE (texte, type);


--
-- TOC entry 3859 (class 2606 OID 135800)
-- Dependencies: 298 298 298
-- Name: uk_note_evaluation_id_eleve_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note
    ADD CONSTRAINT uk_note_evaluation_id_eleve_id UNIQUE (evaluation_id, eleve_id);


--
-- TOC entry 3864 (class 2606 OID 135802)
-- Dependencies: 300 300 300
-- Name: uk_rel_evaluation_periode_evaluation_id_periode_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT uk_rel_evaluation_periode_evaluation_id_periode_id UNIQUE (evaluation_id, periode_id);


--
-- TOC entry 3868 (class 2606 OID 135804)
-- Dependencies: 301 301 301 301
-- Name: uk_resultat_classe_enseignement_periode_enseignement_id_periode; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT uk_resultat_classe_enseignement_periode_enseignement_id_periode UNIQUE (enseignement_id, periode_id, structure_enseignement_id);


--
-- TOC entry 3872 (class 2606 OID 135520)
-- Dependencies: 303 303 303
-- Name: uk_resultat_classe_periode_periode_id_structure_enseignement_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT uk_resultat_classe_periode_periode_id_structure_enseignement_id UNIQUE (periode_id, structure_enseignement_id);


--
-- TOC entry 3877 (class 2606 OID 135522)
-- Dependencies: 305 305 305 305
-- Name: uk_resultat_classe_service_periode_service_id_periode_id_struct; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT uk_resultat_classe_service_periode_service_id_periode_id_struct UNIQUE (service_id, periode_id, structure_enseignement_id);


--
-- TOC entry 3882 (class 2606 OID 135810)
-- Dependencies: 307 307 307
-- Name: uk_resultat_classe_sous_service_periode_resultat_classe_service; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT uk_resultat_classe_sous_service_periode_resultat_classe_service UNIQUE (resultat_classe_service_periode_id, sous_service_id);


--
-- TOC entry 3886 (class 2606 OID 135806)
-- Dependencies: 309 309 309 309
-- Name: uk_resultat_eleve_enseignement_periode_enseignement_id_eleve_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT uk_resultat_eleve_enseignement_periode_enseignement_id_eleve_id UNIQUE (enseignement_id, eleve_id, periode_id);


--
-- TOC entry 3890 (class 2606 OID 135524)
-- Dependencies: 311 311 311
-- Name: uk_resultat_eleve_periode_periode_id_autorite_eleve_id; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT uk_resultat_eleve_periode_periode_id_autorite_eleve_id UNIQUE (periode_id, autorite_eleve_id);


--
-- TOC entry 3894 (class 2606 OID 135526)
-- Dependencies: 313 313 313 313
-- Name: uk_resultat_eleve_service_periode_service_id_periode_id_autorit; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT uk_resultat_eleve_service_periode_service_id_periode_id_autorit UNIQUE (service_id, periode_id, autorite_eleve_id);


--
-- TOC entry 3899 (class 2606 OID 135812)
-- Dependencies: 315 315 315
-- Name: uk_resultat_eleve_sous_service_periode_resultat_eleve_service_p; Type: CONSTRAINT; Schema: entnotes; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT uk_resultat_eleve_sous_service_periode_resultat_eleve_service_p UNIQUE (resultat_eleve_service_periode_id, sous_service_id);


SET search_path = entnotes_2011_2012, pg_catalog;

--
-- TOC entry 4301 (class 2606 OID 137525)
-- Dependencies: 492 492 492
-- Name: brevet_epreuve_serie_id_code_key; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT brevet_epreuve_serie_id_code_key UNIQUE (serie_id, code);


--
-- TOC entry 4295 (class 2606 OID 137513)
-- Dependencies: 490 490 490
-- Name: brevet_rel_epreuve_matiere_epreuve_id_matiere_id_key; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT brevet_rel_epreuve_matiere_epreuve_id_matiere_id_key UNIQUE (epreuve_id, matiere_id);


--
-- TOC entry 4245 (class 2606 OID 137383)
-- Dependencies: 477 477
-- Name: pk_appreciation_classe_enseignement_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT pk_appreciation_classe_enseignement_periode PRIMARY KEY (id);


--
-- TOC entry 4249 (class 2606 OID 137393)
-- Dependencies: 478 478
-- Name: pk_appreciation_eleve_enseignement_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT pk_appreciation_eleve_enseignement_periode PRIMARY KEY (id);


--
-- TOC entry 4241 (class 2606 OID 137373)
-- Dependencies: 476 476
-- Name: pk_appreciation_eleve_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT pk_appreciation_eleve_periode PRIMARY KEY (id);


--
-- TOC entry 4303 (class 2606 OID 137523)
-- Dependencies: 492 492
-- Name: pk_brevet_epreuve; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT pk_brevet_epreuve PRIMARY KEY (id);


--
-- TOC entry 4311 (class 2606 OID 137555)
-- Dependencies: 496 496
-- Name: pk_brevet_fiche; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT pk_brevet_fiche PRIMARY KEY (id);


--
-- TOC entry 4291 (class 2606 OID 137504)
-- Dependencies: 489 489
-- Name: pk_brevet_note; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT pk_brevet_note PRIMARY KEY (id);


--
-- TOC entry 4297 (class 2606 OID 137511)
-- Dependencies: 490 490
-- Name: pk_brevet_rel_epreuve_matiere; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT pk_brevet_rel_epreuve_matiere PRIMARY KEY (id);


--
-- TOC entry 4299 (class 2606 OID 137518)
-- Dependencies: 491 491 491
-- Name: pk_brevet_rel_epreuve_note_valeur_textuelle; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT pk_brevet_rel_epreuve_note_valeur_textuelle PRIMARY KEY (brevet_epreuve_id, valeur_textuelle_id);


--
-- TOC entry 4305 (class 2606 OID 137533)
-- Dependencies: 493 493
-- Name: pk_brevet_serie; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_serie
    ADD CONSTRAINT pk_brevet_serie PRIMARY KEY (id);


--
-- TOC entry 4309 (class 2606 OID 137550)
-- Dependencies: 495 495
-- Name: pk_evaluation; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT pk_evaluation PRIMARY KEY (id);


--
-- TOC entry 4315 (class 2606 OID 137563)
-- Dependencies: 497 497
-- Name: pk_info_calcul_moyennes_classe; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT pk_info_calcul_moyennes_classe PRIMARY KEY (id);


--
-- TOC entry 4275 (class 2606 OID 137460)
-- Dependencies: 485 485
-- Name: pk_info_supplementaire; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT pk_info_supplementaire PRIMARY KEY (id);


--
-- TOC entry 4255 (class 2606 OID 137409)
-- Dependencies: 480 480
-- Name: pk_note; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note
    ADD CONSTRAINT pk_note PRIMARY KEY (id);


--
-- TOC entry 4253 (class 2606 OID 137400)
-- Dependencies: 479 479
-- Name: pk_note_textuelle; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note_textuelle
    ADD CONSTRAINT pk_note_textuelle PRIMARY KEY (id);


--
-- TOC entry 4307 (class 2606 OID 137538)
-- Dependencies: 494 494 494
-- Name: pk_rel_evaluation_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT pk_rel_evaluation_periode PRIMARY KEY (evaluation_id, periode_id);


--
-- TOC entry 4259 (class 2606 OID 137420)
-- Dependencies: 481 481
-- Name: pk_resultat_classe_enseignement_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT pk_resultat_classe_enseignement_periode PRIMARY KEY (id);


--
-- TOC entry 4263 (class 2606 OID 137430)
-- Dependencies: 482 482
-- Name: pk_resultat_classe_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT pk_resultat_classe_periode PRIMARY KEY (id);


--
-- TOC entry 4271 (class 2606 OID 137450)
-- Dependencies: 484 484
-- Name: pk_resultat_classe_service_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT pk_resultat_classe_service_periode PRIMARY KEY (id);


--
-- TOC entry 4267 (class 2606 OID 137440)
-- Dependencies: 483 483
-- Name: pk_resultat_classe_sous_service_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT pk_resultat_classe_sous_service_periode PRIMARY KEY (id);


--
-- TOC entry 4279 (class 2606 OID 137471)
-- Dependencies: 486 486
-- Name: pk_resultat_eleve_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT pk_resultat_eleve_periode PRIMARY KEY (id);


--
-- TOC entry 4287 (class 2606 OID 137493)
-- Dependencies: 488 488
-- Name: pk_resultat_eleve_service_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT pk_resultat_eleve_service_periode PRIMARY KEY (id);


--
-- TOC entry 4283 (class 2606 OID 137482)
-- Dependencies: 487 487
-- Name: pk_resultat_eleve_sous_service_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT pk_resultat_eleve_sous_service_periode PRIMARY KEY (id);


--
-- TOC entry 4247 (class 2606 OID 137385)
-- Dependencies: 477 477 477 477
-- Name: uk_appreciation_classe_enseignement_periode_classe_id_periode_i; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT uk_appreciation_classe_enseignement_periode_classe_id_periode_i UNIQUE (classe_id, periode_id, enseignement_id);


--
-- TOC entry 4251 (class 2606 OID 137395)
-- Dependencies: 478 478 478 478
-- Name: uk_appreciation_eleve_enseignement_periode_eleve_id_periode_id_; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT uk_appreciation_eleve_enseignement_periode_eleve_id_periode_id_ UNIQUE (eleve_id, periode_id, enseignement_id);


--
-- TOC entry 4243 (class 2606 OID 137375)
-- Dependencies: 476 476 476
-- Name: uk_appreciation_eleve_periode_eleve_id_periode_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT uk_appreciation_eleve_periode_eleve_id_periode_id UNIQUE (eleve_id, periode_id);


--
-- TOC entry 4313 (class 2606 OID 137557)
-- Dependencies: 496 496 496
-- Name: uk_brevet_fiche_eleve_id_annee_scolaire_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT uk_brevet_fiche_eleve_id_annee_scolaire_id UNIQUE (eleve_id, annee_scolaire_id);


--
-- TOC entry 4293 (class 2606 OID 137506)
-- Dependencies: 489 489 489
-- Name: uk_brevet_note_fiche_id_epreuve_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT uk_brevet_note_fiche_id_epreuve_id UNIQUE (fiche_id, epreuve_id);


--
-- TOC entry 4317 (class 2606 OID 137565)
-- Dependencies: 497 497
-- Name: uk_info_calcul_moyennes_classe_classe_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT uk_info_calcul_moyennes_classe_classe_id UNIQUE (classe_id);


--
-- TOC entry 4257 (class 2606 OID 137411)
-- Dependencies: 480 480 480
-- Name: uk_note_evaluation_id_eleve_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY note
    ADD CONSTRAINT uk_note_evaluation_id_eleve_id UNIQUE (evaluation_id, eleve_id);


--
-- TOC entry 4261 (class 2606 OID 137422)
-- Dependencies: 481 481 481 481
-- Name: uk_resultat_classe_enseignement_periode_enseignement_id_periode; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT uk_resultat_classe_enseignement_periode_enseignement_id_periode UNIQUE (enseignement_id, periode_id, structure_enseignement_id);


--
-- TOC entry 4265 (class 2606 OID 137432)
-- Dependencies: 482 482 482
-- Name: uk_resultat_classe_periode_periode_id_structure_enseignement_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT uk_resultat_classe_periode_periode_id_structure_enseignement_id UNIQUE (periode_id, structure_enseignement_id);


--
-- TOC entry 4273 (class 2606 OID 137452)
-- Dependencies: 484 484 484 484
-- Name: uk_resultat_classe_service_periode_service_id_periode_id_struct; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT uk_resultat_classe_service_periode_service_id_periode_id_struct UNIQUE (service_id, periode_id, structure_enseignement_id);


--
-- TOC entry 4269 (class 2606 OID 137442)
-- Dependencies: 483 483 483
-- Name: uk_resultat_classe_sous_service_periode_resultat_classe_service; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT uk_resultat_classe_sous_service_periode_resultat_classe_service UNIQUE (resultat_classe_service_periode_id, sous_service_id);


--
-- TOC entry 4277 (class 2606 OID 137462)
-- Dependencies: 485 485 485 485
-- Name: uk_resultat_eleve_enseignement_periode_enseignement_id_eleve_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT uk_resultat_eleve_enseignement_periode_enseignement_id_eleve_id UNIQUE (enseignement_id, eleve_id, periode_id);


--
-- TOC entry 4281 (class 2606 OID 137473)
-- Dependencies: 486 486 486
-- Name: uk_resultat_eleve_periode_periode_id_autorite_eleve_id; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT uk_resultat_eleve_periode_periode_id_autorite_eleve_id UNIQUE (periode_id, autorite_eleve_id);


--
-- TOC entry 4289 (class 2606 OID 137495)
-- Dependencies: 488 488 488 488
-- Name: uk_resultat_eleve_service_periode_service_id_periode_id_autorit; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT uk_resultat_eleve_service_periode_service_id_periode_id_autorit UNIQUE (service_id, periode_id, autorite_eleve_id);


--
-- TOC entry 4285 (class 2606 OID 137484)
-- Dependencies: 487 487 487
-- Name: uk_resultat_eleve_sous_service_periode_resultat_eleve_service_p; Type: CONSTRAINT; Schema: entnotes_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT uk_resultat_eleve_sous_service_periode_resultat_eleve_service_p UNIQUE (resultat_eleve_service_periode_id, sous_service_id);


SET search_path = enttemps, pg_catalog;

--
-- TOC entry 3901 (class 2606 OID 132875)
-- Dependencies: 317 317
-- Name: pk_absence_journee; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT pk_absence_journee PRIMARY KEY (id);


--
-- TOC entry 3909 (class 2606 OID 132877)
-- Dependencies: 319 319
-- Name: pk_agenda; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT pk_agenda PRIMARY KEY (id);


--
-- TOC entry 3913 (class 2606 OID 132879)
-- Dependencies: 321 321
-- Name: pk_appel; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT pk_appel PRIMARY KEY (id);


--
-- TOC entry 3919 (class 2606 OID 132881)
-- Dependencies: 323 323
-- Name: pk_appel_ligne; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT pk_appel_ligne PRIMARY KEY (id);


--
-- TOC entry 3923 (class 2606 OID 132883)
-- Dependencies: 325 325 325
-- Name: pk_appel_plage_horaire; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT pk_appel_plage_horaire PRIMARY KEY (appel_id, plage_horaire_id);


--
-- TOC entry 3930 (class 2606 OID 132887)
-- Dependencies: 328 328
-- Name: pk_date_exclue; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY date_exclue
    ADD CONSTRAINT pk_date_exclue PRIMARY KEY (id);


--
-- TOC entry 3937 (class 2606 OID 132889)
-- Dependencies: 331 331
-- Name: pk_evenement; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT pk_evenement PRIMARY KEY (id);


--
-- TOC entry 3939 (class 2606 OID 132891)
-- Dependencies: 333 333
-- Name: pk_groupe_motif; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT pk_groupe_motif PRIMARY KEY (id);


--
-- TOC entry 3943 (class 2606 OID 132893)
-- Dependencies: 335 335
-- Name: pk_incident; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT pk_incident PRIMARY KEY (id);


--
-- TOC entry 3946 (class 2606 OID 132895)
-- Dependencies: 337 337
-- Name: pk_lieu_incident; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT pk_lieu_incident PRIMARY KEY (id);


--
-- TOC entry 3950 (class 2606 OID 132897)
-- Dependencies: 339 339
-- Name: pk_motif; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT pk_motif PRIMARY KEY (id);


--
-- TOC entry 3955 (class 2606 OID 135875)
-- Dependencies: 341 341
-- Name: pk_partenaire_a_prevenir; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT pk_partenaire_a_prevenir PRIMARY KEY (id);


--
-- TOC entry 3960 (class 2606 OID 132899)
-- Dependencies: 342 342
-- Name: pk_partenaire_a_prevenir_incident; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT pk_partenaire_a_prevenir_incident PRIMARY KEY (id);


--
-- TOC entry 3965 (class 2606 OID 132903)
-- Dependencies: 345 345
-- Name: pk_plage_horaire; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plage_horaire
    ADD CONSTRAINT pk_plage_horaire PRIMARY KEY (id);


--
-- TOC entry 3967 (class 2606 OID 135648)
-- Dependencies: 347 347
-- Name: pk_preference_etablissement_absences; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT pk_preference_etablissement_absences PRIMARY KEY (id);


--
-- TOC entry 3972 (class 2606 OID 135702)
-- Dependencies: 349 349
-- Name: pk_preference_utilisateur_agenda; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_utilisateur_agenda
    ADD CONSTRAINT pk_preference_utilisateur_agenda PRIMARY KEY (id);


--
-- TOC entry 3978 (class 2606 OID 132909)
-- Dependencies: 351 351
-- Name: pk_protagoniste_incident; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT pk_protagoniste_incident PRIMARY KEY (id);


--
-- TOC entry 3984 (class 2606 OID 132911)
-- Dependencies: 353 353
-- Name: pk_punition; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT pk_punition PRIMARY KEY (id);


--
-- TOC entry 3987 (class 2606 OID 132913)
-- Dependencies: 355 355
-- Name: pk_qualite_protagoniste; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT pk_qualite_protagoniste PRIMARY KEY (id);


--
-- TOC entry 3992 (class 2606 OID 132915)
-- Dependencies: 357 357
-- Name: pk_rel_agenda_evenement; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT pk_rel_agenda_evenement PRIMARY KEY (id);


--
-- TOC entry 3997 (class 2606 OID 132917)
-- Dependencies: 359 359
-- Name: pk_repeter_jour_annee; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repeter_jour_annee
    ADD CONSTRAINT pk_repeter_jour_annee PRIMARY KEY (id);


--
-- TOC entry 4000 (class 2606 OID 132919)
-- Dependencies: 361 361
-- Name: pk_repeter_jour_mois; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repeter_jour_mois
    ADD CONSTRAINT pk_repeter_jour_mois PRIMARY KEY (id);


--
-- TOC entry 4003 (class 2606 OID 132921)
-- Dependencies: 363 363
-- Name: pk_repeter_jour_semaine; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repeter_jour_semaine
    ADD CONSTRAINT pk_repeter_jour_semaine PRIMARY KEY (id);


--
-- TOC entry 4006 (class 2606 OID 132923)
-- Dependencies: 365 365
-- Name: pk_repeter_mois; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repeter_mois
    ADD CONSTRAINT pk_repeter_mois PRIMARY KEY (id);


--
-- TOC entry 4009 (class 2606 OID 132925)
-- Dependencies: 367 367
-- Name: pk_repeter_semaine_annee; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repeter_semaine_annee
    ADD CONSTRAINT pk_repeter_semaine_annee PRIMARY KEY (id);


--
-- TOC entry 4013 (class 2606 OID 132927)
-- Dependencies: 369 369
-- Name: pk_sanction; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT pk_sanction PRIMARY KEY (id);


--
-- TOC entry 4015 (class 2606 OID 132929)
-- Dependencies: 371 371
-- Name: pk_type_agenda; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_agenda
    ADD CONSTRAINT pk_type_agenda PRIMARY KEY (id);


--
-- TOC entry 4019 (class 2606 OID 132931)
-- Dependencies: 373 373
-- Name: pk_type_evenement; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_evenement
    ADD CONSTRAINT pk_type_evenement PRIMARY KEY (id);


--
-- TOC entry 4024 (class 2606 OID 132933)
-- Dependencies: 375 375
-- Name: pk_type_incident; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT pk_type_incident PRIMARY KEY (id);


--
-- TOC entry 4029 (class 2606 OID 132935)
-- Dependencies: 377 377
-- Name: pk_type_punition; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT pk_type_punition PRIMARY KEY (id);


--
-- TOC entry 4034 (class 2606 OID 132937)
-- Dependencies: 379 379
-- Name: pk_type_sanction; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT pk_type_sanction PRIMARY KEY (id);


--
-- TOC entry 3903 (class 2606 OID 132939)
-- Dependencies: 317 317 317
-- Name: uk_absence_journee_etablissement_id_date; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT uk_absence_journee_etablissement_id_date UNIQUE (etablissement_id, date);


--
-- TOC entry 3915 (class 2606 OID 132943)
-- Dependencies: 321 321
-- Name: uk_appel_evenement_id; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT uk_appel_evenement_id UNIQUE (evenement_id);


--
-- TOC entry 3921 (class 2606 OID 136608)
-- Dependencies: 323 323 323
-- Name: uk_appel_ligne_appel_id_autorite_id; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT uk_appel_ligne_appel_id_autorite_id UNIQUE (appel_id, autorite_id);


--
-- TOC entry 3941 (class 2606 OID 135729)
-- Dependencies: 333 333 333
-- Name: uk_groupe_motif_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT uk_groupe_motif_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- TOC entry 3948 (class 2606 OID 135723)
-- Dependencies: 337 337 337
-- Name: uk_lieu_incident_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT uk_lieu_incident_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- TOC entry 3952 (class 2606 OID 135818)
-- Dependencies: 339 339 339
-- Name: uk_motif_groupe_motif_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT uk_motif_groupe_motif_id_libelle UNIQUE (groupe_motif_id, libelle);


--
-- TOC entry 3962 (class 2606 OID 135820)
-- Dependencies: 342 342 342
-- Name: uk_partenaire_a_prevenir_incident_partenaire_a_prevenir_id_inci; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT uk_partenaire_a_prevenir_incident_partenaire_a_prevenir_id_inci UNIQUE (partenaire_a_prevenir_id, incident_id);


--
-- TOC entry 3957 (class 2606 OID 135725)
-- Dependencies: 341 341 341
-- Name: uk_partenaire_a_prevenir_preference_etablissement_absences_id_l; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT uk_partenaire_a_prevenir_preference_etablissement_absences_id_l UNIQUE (preference_etablissement_absences_id, libelle);


--
-- TOC entry 3969 (class 2606 OID 135700)
-- Dependencies: 347 347
-- Name: uk_preference_etablissement_absences_etablissement_id; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT uk_preference_etablissement_absences_etablissement_id UNIQUE (etablissement_id);


--
-- TOC entry 3974 (class 2606 OID 135714)
-- Dependencies: 349 349 349
-- Name: uk_preference_utilisateur_agenda_utilisateur_id_agenda_id; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_utilisateur_agenda
    ADD CONSTRAINT uk_preference_utilisateur_agenda_utilisateur_id_agenda_id UNIQUE (utilisateur_id, agenda_id);


--
-- TOC entry 3989 (class 2606 OID 135731)
-- Dependencies: 355 355 355
-- Name: uk_qualite_protagoniste_preference_etablissement_absences_id_li; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT uk_qualite_protagoniste_preference_etablissement_absences_id_li UNIQUE (preference_etablissement_absences_id, libelle);


--
-- TOC entry 3994 (class 2606 OID 135814)
-- Dependencies: 357 357 357
-- Name: uk_rel_agenda_evenement_evenement_id_agenda_id; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT uk_rel_agenda_evenement_evenement_id_agenda_id UNIQUE (evenement_id, agenda_id);


--
-- TOC entry 4017 (class 2606 OID 132965)
-- Dependencies: 371 371
-- Name: uk_type_agenda_code; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_agenda
    ADD CONSTRAINT uk_type_agenda_code UNIQUE (code);


--
-- TOC entry 4021 (class 2606 OID 132967)
-- Dependencies: 373 373
-- Name: uk_type_evenement_type; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_evenement
    ADD CONSTRAINT uk_type_evenement_type UNIQUE (type);


--
-- TOC entry 4026 (class 2606 OID 135733)
-- Dependencies: 375 375 375
-- Name: uk_type_incident_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT uk_type_incident_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- TOC entry 4031 (class 2606 OID 135735)
-- Dependencies: 377 377 377
-- Name: uk_type_punition_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT uk_type_punition_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- TOC entry 4036 (class 2606 OID 135737)
-- Dependencies: 379 379 379
-- Name: uk_type_sanction_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT uk_type_sanction_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


SET search_path = enttemps_2011_2012, pg_catalog;

--
-- TOC entry 4209 (class 2606 OID 137282)
-- Dependencies: 465 465
-- Name: pk_absence_journee; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT pk_absence_journee PRIMARY KEY (id);


--
-- TOC entry 4233 (class 2606 OID 137349)
-- Dependencies: 473 473
-- Name: pk_agenda; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT pk_agenda PRIMARY KEY (id);


--
-- TOC entry 4205 (class 2606 OID 137275)
-- Dependencies: 464 464
-- Name: pk_appel; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT pk_appel PRIMARY KEY (id);


--
-- TOC entry 4225 (class 2606 OID 137331)
-- Dependencies: 471 471
-- Name: pk_appel_ligne; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT pk_appel_ligne PRIMARY KEY (id);


--
-- TOC entry 4223 (class 2606 OID 137311)
-- Dependencies: 470 470 470
-- Name: pk_appel_plage_horaire; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT pk_appel_plage_horaire PRIMARY KEY (appel_id, plage_horaire_id);


--
-- TOC entry 4229 (class 2606 OID 137338)
-- Dependencies: 472 472
-- Name: pk_calendrier; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT pk_calendrier PRIMARY KEY (id);


--
-- TOC entry 4235 (class 2606 OID 137357)
-- Dependencies: 474 474
-- Name: pk_evenement; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT pk_evenement PRIMARY KEY (id);


--
-- TOC entry 4171 (class 2606 OID 137209)
-- Dependencies: 455 455
-- Name: pk_groupe_motif; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT pk_groupe_motif PRIMARY KEY (id);


--
-- TOC entry 4195 (class 2606 OID 137255)
-- Dependencies: 461 461
-- Name: pk_incident; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT pk_incident PRIMARY KEY (id);


--
-- TOC entry 4179 (class 2606 OID 137223)
-- Dependencies: 457 457
-- Name: pk_lieu_incident; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT pk_lieu_incident PRIMARY KEY (id);


--
-- TOC entry 4187 (class 2606 OID 137241)
-- Dependencies: 459 459
-- Name: pk_motif; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT pk_motif PRIMARY KEY (id);


--
-- TOC entry 4197 (class 2606 OID 137260)
-- Dependencies: 462 462
-- Name: pk_partenaire_a_prevenir; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT pk_partenaire_a_prevenir PRIMARY KEY (id);


--
-- TOC entry 4217 (class 2606 OID 137299)
-- Dependencies: 468 468
-- Name: pk_partenaire_a_prevenir_incident; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT pk_partenaire_a_prevenir_incident PRIMARY KEY (id);


--
-- TOC entry 4169 (class 2606 OID 137200)
-- Dependencies: 454 454
-- Name: pk_plage_horaire; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plage_horaire
    ADD CONSTRAINT pk_plage_horaire PRIMARY KEY (id);


--
-- TOC entry 4165 (class 2606 OID 137186)
-- Dependencies: 453 453
-- Name: pk_preference_etablissement_absences; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT pk_preference_etablissement_absences PRIMARY KEY (id);


--
-- TOC entry 4215 (class 2606 OID 137294)
-- Dependencies: 467 467
-- Name: pk_protagoniste_incident; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT pk_protagoniste_incident PRIMARY KEY (id);


--
-- TOC entry 4221 (class 2606 OID 137306)
-- Dependencies: 469 469
-- Name: pk_punition; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT pk_punition PRIMARY KEY (id);


--
-- TOC entry 4183 (class 2606 OID 137230)
-- Dependencies: 458 458
-- Name: pk_qualite_protagoniste; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT pk_qualite_protagoniste PRIMARY KEY (id);


--
-- TOC entry 4237 (class 2606 OID 137362)
-- Dependencies: 475 475
-- Name: pk_rel_agenda_evenement; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT pk_rel_agenda_evenement PRIMARY KEY (id);


--
-- TOC entry 4213 (class 2606 OID 137289)
-- Dependencies: 466 466
-- Name: pk_sanction; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT pk_sanction PRIMARY KEY (id);


--
-- TOC entry 4175 (class 2606 OID 137216)
-- Dependencies: 456 456
-- Name: pk_type_incident; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT pk_type_incident PRIMARY KEY (id);


--
-- TOC entry 4201 (class 2606 OID 137267)
-- Dependencies: 463 463
-- Name: pk_type_punition; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT pk_type_punition PRIMARY KEY (id);


--
-- TOC entry 4191 (class 2606 OID 137248)
-- Dependencies: 460 460
-- Name: pk_type_sanction; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT pk_type_sanction PRIMARY KEY (id);


--
-- TOC entry 4211 (class 2606 OID 137284)
-- Dependencies: 465 465 465
-- Name: uk_absence_journee_etablissement_id_date; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT uk_absence_journee_etablissement_id_date UNIQUE (etablissement_id, date);


--
-- TOC entry 4207 (class 2606 OID 137277)
-- Dependencies: 464 464
-- Name: uk_appel_evenement_id; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT uk_appel_evenement_id UNIQUE (evenement_id);


--
-- TOC entry 4227 (class 2606 OID 137333)
-- Dependencies: 471 471 471
-- Name: uk_appel_ligne_appel_id_autorite_id; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT uk_appel_ligne_appel_id_autorite_id UNIQUE (appel_id, autorite_id);


--
-- TOC entry 4231 (class 2606 OID 137340)
-- Dependencies: 472 472 472
-- Name: uk_calendrier_etablissement_id_annee_scolaire_id; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT uk_calendrier_etablissement_id_annee_scolaire_id UNIQUE (etablissement_id, annee_scolaire_id);


--
-- TOC entry 4173 (class 2606 OID 137211)
-- Dependencies: 455 455 455
-- Name: uk_groupe_motif_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT uk_groupe_motif_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- TOC entry 4181 (class 2606 OID 137225)
-- Dependencies: 457 457 457
-- Name: uk_lieu_incident_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT uk_lieu_incident_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- TOC entry 4189 (class 2606 OID 137243)
-- Dependencies: 459 459 459
-- Name: uk_motif_groupe_motif_id_libelle; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT uk_motif_groupe_motif_id_libelle UNIQUE (groupe_motif_id, libelle);


--
-- TOC entry 4219 (class 2606 OID 137301)
-- Dependencies: 468 468 468
-- Name: uk_partenaire_a_prevenir_incident_partenaire_a_prevenir_id_inci; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT uk_partenaire_a_prevenir_incident_partenaire_a_prevenir_id_inci UNIQUE (partenaire_a_prevenir_id, incident_id);


--
-- TOC entry 4199 (class 2606 OID 137262)
-- Dependencies: 462 462 462
-- Name: uk_partenaire_a_prevenir_preference_etablissement_absences_id_l; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT uk_partenaire_a_prevenir_preference_etablissement_absences_id_l UNIQUE (preference_etablissement_absences_id, libelle);


--
-- TOC entry 4167 (class 2606 OID 137188)
-- Dependencies: 453 453
-- Name: uk_preference_etablissement_absences_etablissement_id; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT uk_preference_etablissement_absences_etablissement_id UNIQUE (etablissement_id);


--
-- TOC entry 4185 (class 2606 OID 137232)
-- Dependencies: 458 458 458
-- Name: uk_qualite_protagoniste_preference_etablissement_absences_id_li; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT uk_qualite_protagoniste_preference_etablissement_absences_id_li UNIQUE (preference_etablissement_absences_id, libelle);


--
-- TOC entry 4239 (class 2606 OID 137364)
-- Dependencies: 475 475 475
-- Name: uk_rel_agenda_evenement_evenement_id_agenda_id; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT uk_rel_agenda_evenement_evenement_id_agenda_id UNIQUE (evenement_id, agenda_id);


--
-- TOC entry 4177 (class 2606 OID 137218)
-- Dependencies: 456 456 456
-- Name: uk_type_incident_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT uk_type_incident_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- TOC entry 4203 (class 2606 OID 137269)
-- Dependencies: 463 463 463
-- Name: uk_type_punition_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT uk_type_punition_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


--
-- TOC entry 4193 (class 2606 OID 137250)
-- Dependencies: 460 460 460
-- Name: uk_type_sanction_preference_etablissement_absences_id_libelle; Type: CONSTRAINT; Schema: enttemps_2011_2012; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT uk_type_sanction_preference_etablissement_absences_id_libelle UNIQUE (preference_etablissement_absences_id, libelle);


SET search_path = forum, pg_catalog;

--
-- TOC entry 4041 (class 2606 OID 135504)
-- Dependencies: 383 383 383
-- Name: pk_commentaire_lu; Type: CONSTRAINT; Schema: forum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY commentaire_lu
    ADD CONSTRAINT pk_commentaire_lu PRIMARY KEY (commentaire_id, autorite_id);


--
-- TOC entry 4039 (class 2606 OID 134793)
-- Dependencies: 381 381
-- Name: pk_forum_commentaire; Type: CONSTRAINT; Schema: forum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY commentaire
    ADD CONSTRAINT pk_forum_commentaire PRIMARY KEY (id);


--
-- TOC entry 4044 (class 2606 OID 134780)
-- Dependencies: 384 384
-- Name: pk_forum_discussion; Type: CONSTRAINT; Schema: forum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT pk_forum_discussion PRIMARY KEY (id);


--
-- TOC entry 4046 (class 2606 OID 132981)
-- Dependencies: 386 386
-- Name: pk_forum_etat_commentaire; Type: CONSTRAINT; Schema: forum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etat_commentaire
    ADD CONSTRAINT pk_forum_etat_commentaire PRIMARY KEY (code);


--
-- TOC entry 4048 (class 2606 OID 132983)
-- Dependencies: 387 387
-- Name: pk_forum_etat_discussion; Type: CONSTRAINT; Schema: forum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY etat_discussion
    ADD CONSTRAINT pk_forum_etat_discussion PRIMARY KEY (code);


--
-- TOC entry 4050 (class 2606 OID 132985)
-- Dependencies: 388 388
-- Name: pk_forum_type_moderation; Type: CONSTRAINT; Schema: forum; Owner: -; Tablespace: 
--

ALTER TABLE ONLY type_moderation
    ADD CONSTRAINT pk_forum_type_moderation PRIMARY KEY (code);


SET search_path = impression, pg_catalog;

--
-- TOC entry 4055 (class 2606 OID 132987)
-- Dependencies: 389 389
-- Name: pk_publipostage_suivi; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT pk_publipostage_suivi PRIMARY KEY (id);


--
-- TOC entry 4147 (class 2606 OID 136875)
-- Dependencies: 437 437
-- Name: pk_sms_fournisseur; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sms_fournisseur
    ADD CONSTRAINT pk_sms_fournisseur PRIMARY KEY (id);


--
-- TOC entry 4149 (class 2606 OID 136929)
-- Dependencies: 439 439
-- Name: pk_sms_fournisseur_etablissement; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sms_fournisseur_etablissement
    ADD CONSTRAINT pk_sms_fournisseur_etablissement PRIMARY KEY (id);


--
-- TOC entry 4057 (class 2606 OID 132989)
-- Dependencies: 391 391
-- Name: pk_template_champ_memo; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_champ_memo
    ADD CONSTRAINT pk_template_champ_memo PRIMARY KEY (id);


--
-- TOC entry 4075 (class 2606 OID 132991)
-- Dependencies: 397 397
-- Name: pk_template_eliot; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT pk_template_eliot PRIMARY KEY (id);


--
-- TOC entry 4080 (class 2606 OID 132993)
-- Dependencies: 399 399
-- Name: pk_template_jasper; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_jasper
    ADD CONSTRAINT pk_template_jasper PRIMARY KEY (id);


--
-- TOC entry 4082 (class 2606 OID 132995)
-- Dependencies: 401 401
-- Name: pk_template_type_donnees; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_type_donnees
    ADD CONSTRAINT pk_template_type_donnees PRIMARY KEY (id);


--
-- TOC entry 4088 (class 2606 OID 132997)
-- Dependencies: 403 403
-- Name: pk_template_type_fonctionnalite; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_type_fonctionnalite
    ADD CONSTRAINT pk_template_type_fonctionnalite PRIMARY KEY (id);


--
-- TOC entry 4063 (class 2606 OID 132999)
-- Dependencies: 393 393
-- Name: pk_template_utilisateur; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_document
    ADD CONSTRAINT pk_template_utilisateur PRIMARY KEY (id);


--
-- TOC entry 4068 (class 2606 OID 133001)
-- Dependencies: 395 395
-- Name: pk_template_utilisateur_sous_template_eliot; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_document_sous_template_eliot
    ADD CONSTRAINT pk_template_utilisateur_sous_template_eliot PRIMARY KEY (id);


--
-- TOC entry 4059 (class 2606 OID 135822)
-- Dependencies: 391 391 391
-- Name: uk_template_champ_memo_template_document_id_champ; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_champ_memo
    ADD CONSTRAINT uk_template_champ_memo_template_document_id_champ UNIQUE (template_document_id, champ);


--
-- TOC entry 4065 (class 2606 OID 135826)
-- Dependencies: 393 393 393
-- Name: uk_template_document_nom_etablissement_id; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_document
    ADD CONSTRAINT uk_template_document_nom_etablissement_id UNIQUE (nom, etablissement_id);


--
-- TOC entry 4070 (class 2606 OID 135824)
-- Dependencies: 395 395 395
-- Name: uk_template_document_sous_template_eliot_template_document_id_p; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_document_sous_template_eliot
    ADD CONSTRAINT uk_template_document_sous_template_eliot_template_document_id_p UNIQUE (template_document_id, param);


--
-- TOC entry 4077 (class 2606 OID 135828)
-- Dependencies: 397 397
-- Name: uk_template_eliot_code; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT uk_template_eliot_code UNIQUE (code);


--
-- TOC entry 4084 (class 2606 OID 133009)
-- Dependencies: 401 401
-- Name: uk_template_type_donnees_code; Type: CONSTRAINT; Schema: impression; Owner: -; Tablespace: 
--

ALTER TABLE ONLY template_type_donnees
    ADD CONSTRAINT uk_template_type_donnees_code UNIQUE (code);


SET search_path = public, pg_catalog;



--
-- TOC entry 4090 (class 2606 OID 133013)
-- Dependencies: 406 406
-- Name: pk_eliot_version; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eliot_version
    ADD CONSTRAINT pk_eliot_version PRIMARY KEY (id);


--
-- TOC entry 4092 (class 2606 OID 133015)
-- Dependencies: 406 406
-- Name: uk_eliot_version_code; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eliot_version
    ADD CONSTRAINT uk_eliot_version_code UNIQUE (code);


SET search_path = securite, pg_catalog;

--
-- TOC entry 4096 (class 2606 OID 133017)
-- Dependencies: 407 407
-- Name: pk_autorisation; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT pk_autorisation PRIMARY KEY (id);


--
-- TOC entry 3740 (class 2606 OID 133019)
-- Dependencies: 247 247
-- Name: pk_autorite; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autorite
    ADD CONSTRAINT pk_autorite PRIMARY KEY (id);


--
-- TOC entry 4101 (class 2606 OID 133021)
-- Dependencies: 408 408
-- Name: pk_item; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY item
    ADD CONSTRAINT pk_item PRIMARY KEY (id);


--
-- TOC entry 4106 (class 2606 OID 133023)
-- Dependencies: 409 409
-- Name: pk_perimetre; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY perimetre
    ADD CONSTRAINT pk_perimetre PRIMARY KEY (id);


--
-- TOC entry 4111 (class 2606 OID 133025)
-- Dependencies: 410 410
-- Name: pk_perimetre_securite; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY perimetre_securite
    ADD CONSTRAINT pk_perimetre_securite PRIMARY KEY (id);


--
-- TOC entry 4115 (class 2606 OID 133027)
-- Dependencies: 411 411
-- Name: pk_permission; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY permission
    ADD CONSTRAINT pk_permission PRIMARY KEY (id);


--
-- TOC entry 4098 (class 2606 OID 134422)
-- Dependencies: 407 407 407
-- Name: uk_autorisation_item_id_autorite_id; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT uk_autorisation_item_id_autorite_id UNIQUE (item_id, autorite_id);


--
-- TOC entry 3742 (class 2606 OID 135830)
-- Dependencies: 247 247 247
-- Name: uk_autorite_enregistrement_cible_id_nom_entite_cible; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autorite
    ADD CONSTRAINT uk_autorite_enregistrement_cible_id_nom_entite_cible UNIQUE (enregistrement_cible_id, nom_entite_cible);


--
-- TOC entry 3744 (class 2606 OID 134420)
-- Dependencies: 247 247 247
-- Name: uk_autorite_id_externe_type; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autorite
    ADD CONSTRAINT uk_autorite_id_externe_type UNIQUE (id_externe, type);


--
-- TOC entry 4103 (class 2606 OID 135832)
-- Dependencies: 408 408 408
-- Name: uk_item_enregistrement_cible_id_nom_entite_cible; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY item
    ADD CONSTRAINT uk_item_enregistrement_cible_id_nom_entite_cible UNIQUE (enregistrement_cible_id, nom_entite_cible);


--
-- TOC entry 4108 (class 2606 OID 135834)
-- Dependencies: 409 409 409
-- Name: uk_perimetre_enregistrement_cible_id_nom_entite_cible; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY perimetre
    ADD CONSTRAINT uk_perimetre_enregistrement_cible_id_nom_entite_cible UNIQUE (enregistrement_cible_id, nom_entite_cible);


--
-- TOC entry 4113 (class 2606 OID 134418)
-- Dependencies: 410 410 410
-- Name: uk_perimetre_securite_item_id_perimetre_id; Type: CONSTRAINT; Schema: securite; Owner: -; Tablespace: 
--

ALTER TABLE ONLY perimetre_securite
    ADD CONSTRAINT uk_perimetre_securite_item_id_perimetre_id UNIQUE (item_id, perimetre_id);


SET search_path = td, pg_catalog;

--
-- TOC entry 4426 (class 2606 OID 138805)
-- Dependencies: 536 536
-- Name: pk_copie; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY copie
    ADD CONSTRAINT pk_copie PRIMARY KEY (id);


--
-- TOC entry 4447 (class 2606 OID 138858)
-- Dependencies: 539 539
-- Name: pk_modalite_activite; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT pk_modalite_activite PRIMARY KEY (id);


--
-- TOC entry 4394 (class 2606 OID 138602)
-- Dependencies: 522 522
-- Name: pk_question; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question
    ADD CONSTRAINT pk_question PRIMARY KEY (id);


--
-- TOC entry 4402 (class 2606 OID 138662)
-- Dependencies: 526 526
-- Name: pk_question_attachement; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question_attachement
    ADD CONSTRAINT pk_question_attachement PRIMARY KEY (id);


--
-- TOC entry 4398 (class 2606 OID 138642)
-- Dependencies: 524 524
-- Name: pk_question_export; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question_export
    ADD CONSTRAINT pk_question_export PRIMARY KEY (id);


--
-- TOC entry 4383 (class 2606 OID 138590)
-- Dependencies: 520 520
-- Name: pk_question_type; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question_type
    ADD CONSTRAINT pk_question_type PRIMARY KEY (id);


--
-- TOC entry 4434 (class 2606 OID 138833)
-- Dependencies: 538 538
-- Name: pk_reponse; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reponse
    ADD CONSTRAINT pk_reponse PRIMARY KEY (id);


--
-- TOC entry 4453 (class 2606 OID 139118)
-- Dependencies: 544 544
-- Name: pk_reponse_attachement; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reponse_attachement
    ADD CONSTRAINT pk_reponse_attachement PRIMARY KEY (id);


--
-- TOC entry 4411 (class 2606 OID 138704)
-- Dependencies: 528 528
-- Name: pk_sujet; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT pk_sujet PRIMARY KEY (id);


--
-- TOC entry 4415 (class 2606 OID 138735)
-- Dependencies: 530 530
-- Name: pk_sujet_sequence_questions; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sujet_sequence_questions
    ADD CONSTRAINT pk_sujet_sequence_questions PRIMARY KEY (id);


--
-- TOC entry 4449 (class 2606 OID 138984)
-- Dependencies: 541 541
-- Name: pk_sujet_type; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sujet_type
    ADD CONSTRAINT pk_sujet_type PRIMARY KEY (id);


--
-- TOC entry 4428 (class 2606 OID 139084)
-- Dependencies: 536 536 536
-- Name: uk_copie_seance_eleve; Type: CONSTRAINT; Schema: td; Owner: -; Tablespace: 
--

ALTER TABLE ONLY copie
    ADD CONSTRAINT uk_copie_seance_eleve UNIQUE (modalite_activite_id, eleve_id);


--
-- TOC entry 4436 (class 2606 OID 139086)
-- Dependencies: 538 538 538
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
-- TOC entry 4372 (class 2606 OID 138550)
-- Dependencies: 514 514
-- Name: pk_compte_utilisateur; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace: 
--

ALTER TABLE ONLY compte_utilisateur
    ADD CONSTRAINT pk_compte_utilisateur PRIMARY KEY (id);


--
-- TOC entry 4417 (class 2606 OID 138762)
-- Dependencies: 532 532
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
-- TOC entry 4420 (class 2606 OID 138769)
-- Dependencies: 533 533
-- Name: pk_publication; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace: 
--

ALTER TABLE ONLY publication
    ADD CONSTRAINT pk_publication PRIMARY KEY (id);


--
-- TOC entry 4374 (class 2606 OID 138554)
-- Dependencies: 514 514
-- Name: uk_compte_utilisateur_login; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace: 
--

ALTER TABLE ONLY compte_utilisateur
    ADD CONSTRAINT uk_compte_utilisateur_login UNIQUE (login);


--
-- TOC entry 4376 (class 2606 OID 138552)
-- Dependencies: 514 514
-- Name: uk_compte_utilisateur_login_alias; Type: CONSTRAINT; Schema: tice; Owner: -; Tablespace: 
--

ALTER TABLE ONLY compte_utilisateur
    ADD CONSTRAINT uk_compte_utilisateur_login_alias UNIQUE (login_alias);


SET search_path = udt, pg_catalog;

--
-- TOC entry 4161 (class 2606 OID 137125)
-- Dependencies: 450 450
-- Name: pk_enseignement; Type: CONSTRAINT; Schema: udt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT pk_enseignement PRIMARY KEY (id);


--
-- TOC entry 4163 (class 2606 OID 138511)
-- Dependencies: 452 452
-- Name: pk_evenement; Type: CONSTRAINT; Schema: udt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT pk_evenement PRIMARY KEY (id);


--
-- TOC entry 4159 (class 2606 OID 137113)
-- Dependencies: 448 448
-- Name: pk_import; Type: CONSTRAINT; Schema: udt; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import
    ADD CONSTRAINT pk_import PRIMARY KEY (id);


SET search_path = ent, pg_catalog;

--
-- TOC entry 3598 (class 1259 OID 133040)
-- Dependencies: 187
-- Name: idx_appartenance_groupe_groupe_enfant_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_appartenance_groupe_groupe_enfant_id ON appartenance_groupe_groupe USING btree (groupe_personnes_enfant_id);


--
-- TOC entry 3603 (class 1259 OID 133041)
-- Dependencies: 189
-- Name: idx_appartenance_personne_groupe_groupe_personnes_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_appartenance_personne_groupe_groupe_personnes_id ON appartenance_personne_groupe USING btree (groupe_personnes_id);


--
-- TOC entry 3695 (class 1259 OID 135943)
-- Dependencies: 229
-- Name: idx_enseignement_service_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_enseignement_service_id ON enseignement USING btree (service_id);


--
-- TOC entry 3612 (class 1259 OID 133042)
-- Dependencies: 193
-- Name: idx_etablissement_etab_ratt_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_etablissement_etab_ratt_id ON etablissement USING btree (etablissement_rattachement_id);


--
-- TOC entry 3613 (class 1259 OID 133043)
-- Dependencies: 193
-- Name: idx_etablissement_perimetre_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_etablissement_perimetre_id ON etablissement USING btree (perimetre_id);


--
-- TOC entry 3626 (class 1259 OID 135721)
-- Dependencies: 199
-- Name: idx_groupe_personnes_propriete_scolarite_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_groupe_personnes_propriete_scolarite_id ON groupe_personnes USING btree (propriete_scolarite_id);


--
-- TOC entry 3659 (class 1259 OID 133046)
-- Dependencies: 214 214 214 214
-- Name: idx_personne_nom_prenom_normalise_date_naissance_etablissement_; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_personne_nom_prenom_normalise_date_naissance_etablissement_ ON personne USING btree (nom_normalise, prenom_normalise, date_naissance, etablissement_rattachement_id);


--
-- TOC entry 3664 (class 1259 OID 135603)
-- Dependencies: 216
-- Name: idx_personne_propriete_scolarite_compteur_references; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_personne_propriete_scolarite_compteur_references ON personne_propriete_scolarite USING btree (compteur_references);


--
-- TOC entry 3665 (class 1259 OID 135604)
-- Dependencies: 216
-- Name: idx_personne_propriete_scolarite_personne_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_personne_propriete_scolarite_personne_id ON personne_propriete_scolarite USING btree (personne_id);


--
-- TOC entry 3666 (class 1259 OID 135606)
-- Dependencies: 216 216 216 216
-- Name: idx_personne_propriete_scolarite_personne_id_propriete_scolarit; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_personne_propriete_scolarite_personne_id_propriete_scolarit ON personne_propriete_scolarite USING btree (personne_id, propriete_scolarite_id, est_active) WHERE (est_active = true);


--
-- TOC entry 3667 (class 1259 OID 135605)
-- Dependencies: 216
-- Name: idx_personne_propriete_scolarite_propriete_scolarite_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_personne_propriete_scolarite_propriete_scolarite_id ON personne_propriete_scolarite USING btree (propriete_scolarite_id);


--
-- TOC entry 3676 (class 1259 OID 135632)
-- Dependencies: 220
-- Name: idx_preference_etablissement_etablissement_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_preference_etablissement_etablissement_id ON preference_etablissement USING btree (etablissement_id);


--
-- TOC entry 3681 (class 1259 OID 135589)
-- Dependencies: 223 223
-- Name: idx_propriete_scolarite_etablissement_id_fonction_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_propriete_scolarite_etablissement_id_fonction_id ON propriete_scolarite USING btree (etablissement_id, fonction_id);


--
-- TOC entry 3682 (class 1259 OID 135590)
-- Dependencies: 223 223 223
-- Name: idx_propriete_scolarite_structure_enseignement_id_fonction_id_m; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_propriete_scolarite_structure_enseignement_id_fonction_id_m ON propriete_scolarite USING btree (structure_enseignement_id, fonction_id, matiere_id);


--
-- TOC entry 3689 (class 1259 OID 133054)
-- Dependencies: 227
-- Name: idx_rel_classe_filiere_id_filiere; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_classe_filiere_id_filiere ON rel_classe_filiere USING btree (filiere_id);


--
-- TOC entry 3692 (class 1259 OID 133055)
-- Dependencies: 228
-- Name: idx_rel_classe_groupe_id_groupe; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_classe_groupe_id_groupe ON rel_classe_groupe USING btree (groupe_id);


--
-- TOC entry 3700 (class 1259 OID 133057)
-- Dependencies: 230
-- Name: idx_rel_periode_service_service_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_periode_service_service_id ON rel_periode_service USING btree (service_id);


--
-- TOC entry 3705 (class 1259 OID 133058)
-- Dependencies: 232
-- Name: idx_responsable_eleve_eleve_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_responsable_eleve_eleve_id ON responsable_eleve USING btree (eleve_id);


--
-- TOC entry 3710 (class 1259 OID 135621)
-- Dependencies: 234
-- Name: idx_responsable_propriete_scolarite_propriete_scolarite_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_responsable_propriete_scolarite_propriete_scolarite_id ON responsable_propriete_scolarite USING btree (propriete_scolarite_id);


--
-- TOC entry 3711 (class 1259 OID 135622)
-- Dependencies: 234
-- Name: idx_responsable_propriete_scolarite_responsable_eleve_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_responsable_propriete_scolarite_responsable_eleve_id ON responsable_propriete_scolarite USING btree (responsable_eleve_id);


--
-- TOC entry 3714 (class 1259 OID 133061)
-- Dependencies: 236
-- Name: idx_service_id_matiere; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_service_id_matiere ON service USING btree (matiere_id);


--
-- TOC entry 3715 (class 1259 OID 133062)
-- Dependencies: 236
-- Name: idx_service_structure_enseignement; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_service_structure_enseignement ON service USING btree (structure_enseignement_id);


--
-- TOC entry 3724 (class 1259 OID 133063)
-- Dependencies: 241
-- Name: idx_sous_service_modalite_matiere_id; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE INDEX idx_sous_service_modalite_matiere_id ON sous_service USING btree (modalite_matiere_id);


--
-- TOC entry 3597 (class 1259 OID 137043)
-- Dependencies: 185 185
-- Name: ux_annee_en_cours; Type: INDEX; Schema: ent; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX ux_annee_en_cours ON annee_scolaire USING btree (annee_en_cours) WHERE (annee_en_cours = true);


SET search_path = entcdt, pg_catalog;

--
-- TOC entry 3745 (class 1259 OID 135739)
-- Dependencies: 248
-- Name: idx_activite_auteur_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_activite_auteur_id ON activite USING btree (auteur_id);


--
-- TOC entry 3746 (class 1259 OID 135740)
-- Dependencies: 248
-- Name: idx_activite_cahier_de_textes_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_activite_cahier_de_textes_id ON activite USING btree (cahier_de_textes_id);


--
-- TOC entry 3747 (class 1259 OID 135741)
-- Dependencies: 248
-- Name: idx_activite_chapitre_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_activite_chapitre_id ON activite USING btree (chapitre_id);


--
-- TOC entry 3750 (class 1259 OID 135743)
-- Dependencies: 250
-- Name: idx_cahier_de_textes_parent_incorporation_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_cahier_de_textes_parent_incorporation_id ON cahier_de_textes USING btree (parent_incorporation_id);


--
-- TOC entry 3751 (class 1259 OID 135742)
-- Dependencies: 250
-- Name: idx_cahier_de_textes_service_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_cahier_de_textes_service_id ON cahier_de_textes USING btree (service_id);


--
-- TOC entry 3754 (class 1259 OID 135744)
-- Dependencies: 253
-- Name: idx_chapitre_cahier_de_textes_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_chapitre_cahier_de_textes_id ON chapitre USING btree (cahier_de_textes_id);


--
-- TOC entry 3755 (class 1259 OID 135745)
-- Dependencies: 253
-- Name: idx_chapitre_chapitre_parent_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_chapitre_chapitre_parent_id ON chapitre USING btree (chapitre_parent_id);


--
-- TOC entry 3762 (class 1259 OID 135746)
-- Dependencies: 257
-- Name: idx_date_activite_activite_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_date_activite_activite_id ON date_activite USING btree (activite_id);


--
-- TOC entry 3767 (class 1259 OID 135747)
-- Dependencies: 259
-- Name: idx_dossier_acteur_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_dossier_acteur_id ON dossier USING btree (acteur_id);


--
-- TOC entry 3768 (class 1259 OID 135756)
-- Dependencies: 259 259
-- Name: idx_dossier_acteur_id_est_defaut; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_dossier_acteur_id_est_defaut ON dossier USING btree (acteur_id) WHERE (est_defaut = true);


--
-- TOC entry 3773 (class 1259 OID 135748)
-- Dependencies: 263
-- Name: idx_rel_activite_acteur_acteur_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_activite_acteur_acteur_id ON rel_activite_acteur USING btree (acteur_id);


--
-- TOC entry 3778 (class 1259 OID 135749)
-- Dependencies: 264
-- Name: idx_rel_cahier_acteur_acteur_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_cahier_acteur_acteur_id ON rel_cahier_acteur USING btree (acteur_id);


--
-- TOC entry 3783 (class 1259 OID 135750)
-- Dependencies: 265
-- Name: idx_rel_cahier_groupe_groupe_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_cahier_groupe_groupe_id ON rel_cahier_groupe USING btree (groupe_id);


--
-- TOC entry 3788 (class 1259 OID 135751)
-- Dependencies: 266
-- Name: idx_rel_dossier_autorisation_cahier_autorisation_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_dossier_autorisation_cahier_autorisation_id ON rel_dossier_autorisation_cahier USING btree (autorisation_id);


--
-- TOC entry 3793 (class 1259 OID 135752)
-- Dependencies: 267
-- Name: idx_ressource_activite_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_ressource_activite_id ON ressource USING btree (activite_id);


--
-- TOC entry 3804 (class 1259 OID 133080)
-- Dependencies: 273
-- Name: idx_visa_auteur_personne_id; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_visa_auteur_personne_id ON visa USING btree (auteur_personne_id);


--
-- TOC entry 3805 (class 1259 OID 133081)
-- Dependencies: 273 273
-- Name: idx_visa_cahier_vise_id_date_visee; Type: INDEX; Schema: entcdt; Owner: -; Tablespace: 
--

CREATE INDEX idx_visa_cahier_vise_id_date_visee ON visa USING btree (cahier_vise_id, date_visee);


SET search_path = entdemon, pg_catalog;

--
-- TOC entry 3808 (class 1259 OID 135299)
-- Dependencies: 275 275
-- Name: idx_demande_traitement_date_demande; Type: INDEX; Schema: entdemon; Owner: -; Tablespace: 
--

CREATE INDEX idx_demande_traitement_date_demande ON demande_traitement USING btree (date_demande) WHERE ((statut)::text = 'EN_ATTENTE'::text);


SET search_path = entnotes, pg_catalog;

--
-- TOC entry 3831 (class 1259 OID 133085)
-- Dependencies: 288 288 288
-- Name: idx_dirty_moyenne_classe_periode; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_classe_periode ON dirty_moyenne USING btree (classe_id, periode_id) WHERE ((type_moyenne)::text = 'CLASSE_PERIODE'::text);


--
-- TOC entry 3832 (class 1259 OID 134557)
-- Dependencies: 288 288 288 288
-- Name: idx_dirty_moyenne_classe_periode_enseignement; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_classe_periode_enseignement ON dirty_moyenne USING btree (classe_id, periode_id, enseignement_id) WHERE ((type_moyenne)::text = 'CLASSE_ENSEIGNEMENT_PERIODE'::text);


--
-- TOC entry 3833 (class 1259 OID 133087)
-- Dependencies: 288 288 288 288
-- Name: idx_dirty_moyenne_classe_periode_service; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_classe_periode_service ON dirty_moyenne USING btree (classe_id, periode_id, service_id) WHERE ((type_moyenne)::text = 'CLASSE_SERVICE_PERIODE'::text);


--
-- TOC entry 3834 (class 1259 OID 133088)
-- Dependencies: 288 288 288 288
-- Name: idx_dirty_moyenne_classe_periode_sous_service; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_classe_periode_sous_service ON dirty_moyenne USING btree (classe_id, periode_id, sous_service_id) WHERE ((type_moyenne)::text = 'CLASSE_SOUS_SERVICE_PERIODE'::text);


--
-- TOC entry 3835 (class 1259 OID 133089)
-- Dependencies: 288 288 288
-- Name: idx_dirty_moyenne_eleve_periode; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_eleve_periode ON dirty_moyenne USING btree (eleve_id, periode_id) WHERE ((type_moyenne)::text = 'ELEVE_PERIODE'::text);


--
-- TOC entry 3836 (class 1259 OID 134558)
-- Dependencies: 288 288 288 288
-- Name: idx_dirty_moyenne_eleve_periode_enseignement; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_eleve_periode_enseignement ON dirty_moyenne USING btree (eleve_id, periode_id, enseignement_id) WHERE ((type_moyenne)::text = 'ELEVE_ENSEIGNEMENT_PERIODE'::text);


--
-- TOC entry 3837 (class 1259 OID 133091)
-- Dependencies: 288 288 288 288
-- Name: idx_dirty_moyenne_eleve_periode_service; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_eleve_periode_service ON dirty_moyenne USING btree (eleve_id, periode_id, service_id) WHERE ((type_moyenne)::text = 'ELEVE_SERVICE_PERIODE'::text);


--
-- TOC entry 3838 (class 1259 OID 133092)
-- Dependencies: 288 288 288 288
-- Name: idx_dirty_moyenne_eleve_periode_sous_service; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_dirty_moyenne_eleve_periode_sous_service ON dirty_moyenne USING btree (eleve_id, periode_id, sous_service_id) WHERE ((type_moyenne)::text = 'ELEVE_SOUS_SERVICE_PERIODE'::text);


--
-- TOC entry 3841 (class 1259 OID 134551)
-- Dependencies: 290
-- Name: idx_evaluation_enseignement; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_evaluation_enseignement ON evaluation USING btree (enseignement_id);


--
-- TOC entry 4150 (class 1259 OID 136959)
-- Dependencies: 441 441
-- Name: idx_note_textuelle_etablissement_code; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_note_textuelle_etablissement_code ON note_textuelle USING btree (etablissement_id, upper((code)::text));


--
-- TOC entry 4151 (class 1259 OID 136960)
-- Dependencies: 441 441
-- Name: idx_note_textuelle_etablissement_libelle; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_note_textuelle_etablissement_libelle ON note_textuelle USING btree (etablissement_id, upper((libelle)::text));


--
-- TOC entry 3860 (class 1259 OID 133094)
-- Dependencies: 300
-- Name: idx_rel_evaluation_periode_periode_id; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_evaluation_periode_periode_id ON rel_evaluation_periode USING btree (periode_id);


--
-- TOC entry 3873 (class 1259 OID 133095)
-- Dependencies: 305
-- Name: idx_resultat_classe_service_periode_classe; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_resultat_classe_service_periode_classe ON resultat_classe_service_periode USING btree (structure_enseignement_id);


--
-- TOC entry 3878 (class 1259 OID 133096)
-- Dependencies: 307
-- Name: idx_resultat_classe_sous_service_periode_ssid; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_resultat_classe_sous_service_periode_ssid ON resultat_classe_sous_service_periode USING btree (sous_service_id);


--
-- TOC entry 3895 (class 1259 OID 133097)
-- Dependencies: 315
-- Name: idx_resultat_eleve_sous_service_periode_ssid; Type: INDEX; Schema: entnotes; Owner: -; Tablespace: 
--

CREATE INDEX idx_resultat_eleve_sous_service_periode_ssid ON resultat_eleve_sous_service_periode USING btree (sous_service_id);


SET search_path = enttemps, pg_catalog;

--
-- TOC entry 3904 (class 1259 OID 133098)
-- Dependencies: 319
-- Name: idx_agenda_enseignant_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_agenda_enseignant_id ON agenda USING btree (enseignant_id);


--
-- TOC entry 3905 (class 1259 OID 133099)
-- Dependencies: 319
-- Name: idx_agenda_etablissement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_agenda_etablissement_id ON agenda USING btree (etablissement_id);


--
-- TOC entry 3906 (class 1259 OID 133100)
-- Dependencies: 319
-- Name: idx_agenda_item_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_agenda_item_id ON agenda USING btree (item_id);


--
-- TOC entry 3907 (class 1259 OID 133101)
-- Dependencies: 319
-- Name: idx_agenda_structure_enseignement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_agenda_structure_enseignement_id ON agenda USING btree (structure_enseignement_id);


--
-- TOC entry 3910 (class 1259 OID 133102)
-- Dependencies: 321
-- Name: idx_appel_date_heure_debut; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_appel_date_heure_debut ON appel USING btree (date_heure_debut);


--
-- TOC entry 3911 (class 1259 OID 133103)
-- Dependencies: 321
-- Name: idx_appel_date_heure_fin; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_appel_date_heure_fin ON appel USING btree (date_heure_fin);


--
-- TOC entry 3916 (class 1259 OID 133104)
-- Dependencies: 323
-- Name: idx_appel_ligne_absence_journee_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_appel_ligne_absence_journee_id ON appel_ligne USING btree (absence_journee_id);


--
-- TOC entry 3917 (class 1259 OID 136609)
-- Dependencies: 323
-- Name: idx_appel_ligne_autorite_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_appel_ligne_autorite_id ON appel_ligne USING btree (autorite_id);


--
-- TOC entry 3928 (class 1259 OID 133106)
-- Dependencies: 328
-- Name: idx_date_exclue_evenement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_date_exclue_evenement_id ON date_exclue USING btree (evenement_id);


--
-- TOC entry 3931 (class 1259 OID 133107)
-- Dependencies: 331
-- Name: idx_evenement_agenda_maitre_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_evenement_agenda_maitre_id ON evenement USING btree (agenda_maitre_id);


--
-- TOC entry 3932 (class 1259 OID 133108)
-- Dependencies: 331 331
-- Name: idx_evenement_auteur; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_evenement_auteur ON evenement USING btree (auteur_id) WHERE (auteur_id > 0);


--
-- TOC entry 3933 (class 1259 OID 135403)
-- Dependencies: 331
-- Name: idx_evenement_date_heure_debut; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_evenement_date_heure_debut ON evenement USING btree (date_heure_debut);


--
-- TOC entry 3934 (class 1259 OID 135416)
-- Dependencies: 331
-- Name: idx_evenement_date_heure_fin; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_evenement_date_heure_fin ON evenement USING btree (date_heure_fin);


--
-- TOC entry 3935 (class 1259 OID 134531)
-- Dependencies: 331
-- Name: idx_evenement_enseignement; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_evenement_enseignement ON evenement USING btree (enseignement_id);


--
-- TOC entry 3958 (class 1259 OID 133112)
-- Dependencies: 342
-- Name: idx_partenaire_a_prevenir_incident_incident_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_partenaire_a_prevenir_incident_incident_id ON partenaire_a_prevenir_incident USING btree (incident_id);


--
-- TOC entry 3963 (class 1259 OID 135738)
-- Dependencies: 345
-- Name: idx_plage_horaire_preference_etablissement_absences_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_plage_horaire_preference_etablissement_absences_id ON plage_horaire USING btree (preference_etablissement_absences_id);


--
-- TOC entry 3970 (class 1259 OID 135715)
-- Dependencies: 349
-- Name: idx_preference_utilisateur_agenda_agenda_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_preference_utilisateur_agenda_agenda_id ON preference_utilisateur_agenda USING btree (agenda_id);


--
-- TOC entry 3975 (class 1259 OID 133115)
-- Dependencies: 351
-- Name: idx_protagoniste_incident_autorite_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_protagoniste_incident_autorite_id ON protagoniste_incident USING btree (autorite_id);


--
-- TOC entry 3976 (class 1259 OID 133116)
-- Dependencies: 351
-- Name: idx_protagoniste_incident_incident_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_protagoniste_incident_incident_id ON protagoniste_incident USING btree (incident_id);


--
-- TOC entry 3979 (class 1259 OID 133117)
-- Dependencies: 353
-- Name: idx_punition_date; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_punition_date ON punition USING btree (date);


--
-- TOC entry 3980 (class 1259 OID 133118)
-- Dependencies: 353
-- Name: idx_punition_eleve_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_punition_eleve_id ON punition USING btree (eleve_id);


--
-- TOC entry 3981 (class 1259 OID 133119)
-- Dependencies: 353
-- Name: idx_punition_incident_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_punition_incident_id ON punition USING btree (incident_id);


--
-- TOC entry 3982 (class 1259 OID 133120)
-- Dependencies: 353
-- Name: idx_punition_type_punition_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_punition_type_punition_id ON punition USING btree (type_punition_id);


--
-- TOC entry 3990 (class 1259 OID 133121)
-- Dependencies: 357
-- Name: idx_rel_agenda_evenement_agenda_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_rel_agenda_evenement_agenda_id ON rel_agenda_evenement USING btree (agenda_id);


--
-- TOC entry 3995 (class 1259 OID 133122)
-- Dependencies: 359
-- Name: idx_repeter_jour_annee_evenement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_repeter_jour_annee_evenement_id ON repeter_jour_annee USING btree (evenement_id);


--
-- TOC entry 3998 (class 1259 OID 133123)
-- Dependencies: 361
-- Name: idx_repeter_jour_mois_evenement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_repeter_jour_mois_evenement_id ON repeter_jour_mois USING btree (evenement_id);


--
-- TOC entry 4001 (class 1259 OID 133124)
-- Dependencies: 363
-- Name: idx_repeter_jour_semaine_evenement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_repeter_jour_semaine_evenement_id ON repeter_jour_semaine USING btree (evenement_id);


--
-- TOC entry 4004 (class 1259 OID 133125)
-- Dependencies: 365
-- Name: idx_repeter_mois_evenement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_repeter_mois_evenement_id ON repeter_mois USING btree (evenement_id);


--
-- TOC entry 4007 (class 1259 OID 133126)
-- Dependencies: 367
-- Name: idx_repeter_semaine_annee_evenement_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_repeter_semaine_annee_evenement_id ON repeter_semaine_annee USING btree (evenement_id);


--
-- TOC entry 4010 (class 1259 OID 133127)
-- Dependencies: 369
-- Name: idx_sanction_eleve_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_sanction_eleve_id ON sanction USING btree (eleve_id);


--
-- TOC entry 4011 (class 1259 OID 133128)
-- Dependencies: 369
-- Name: idx_sanction_type_sanction_id; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE INDEX idx_sanction_type_sanction_id ON sanction USING btree (type_sanction_id);


--
-- TOC entry 3944 (class 1259 OID 136642)
-- Dependencies: 337 337
-- Name: inx_lieu_incident_case_sensitive; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX inx_lieu_incident_case_sensitive ON lieu_incident USING btree (preference_etablissement_absences_id, lower((libelle)::text));


--
-- TOC entry 3953 (class 1259 OID 136640)
-- Dependencies: 341 341
-- Name: inx_partenaire_a_prevenir_case_sensitive; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX inx_partenaire_a_prevenir_case_sensitive ON partenaire_a_prevenir USING btree (preference_etablissement_absences_id, lower((libelle)::text));


--
-- TOC entry 3985 (class 1259 OID 136638)
-- Dependencies: 355 355
-- Name: inx_qualite_protagoniste_case_sensitive; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX inx_qualite_protagoniste_case_sensitive ON qualite_protagoniste USING btree (preference_etablissement_absences_id, lower((libelle)::text));


--
-- TOC entry 4022 (class 1259 OID 136632)
-- Dependencies: 375 375
-- Name: inx_type_incident_case_sensitive; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX inx_type_incident_case_sensitive ON type_incident USING btree (preference_etablissement_absences_id, lower((libelle)::text));


--
-- TOC entry 4027 (class 1259 OID 136634)
-- Dependencies: 377 377
-- Name: inx_type_punition_case_sensitive; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX inx_type_punition_case_sensitive ON type_punition USING btree (preference_etablissement_absences_id, lower((libelle)::text));


--
-- TOC entry 4032 (class 1259 OID 136636)
-- Dependencies: 379 379
-- Name: inx_type_sanction_case_sensitive; Type: INDEX; Schema: enttemps; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX inx_type_sanction_case_sensitive ON type_sanction USING btree (preference_etablissement_absences_id, lower((libelle)::text));


SET search_path = forum, pg_catalog;

--
-- TOC entry 4037 (class 1259 OID 134807)
-- Dependencies: 381
-- Name: idx_commentaire_id_discussion; Type: INDEX; Schema: forum; Owner: -; Tablespace: 
--

CREATE INDEX idx_commentaire_id_discussion ON commentaire USING btree (discussion_id);


--
-- TOC entry 4042 (class 1259 OID 133130)
-- Dependencies: 384
-- Name: idx_discussion_id_item_cible; Type: INDEX; Schema: forum; Owner: -; Tablespace: 
--

CREATE INDEX idx_discussion_id_item_cible ON discussion USING btree (item_cible_id);


SET search_path = impression, pg_catalog;

--
-- TOC entry 4051 (class 1259 OID 133131)
-- Dependencies: 389
-- Name: idx_publipostage_suivi_classe_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_publipostage_suivi_classe_id ON publipostage_suivi USING btree (classe_id);


--
-- TOC entry 4052 (class 1259 OID 133133)
-- Dependencies: 389
-- Name: idx_publipostage_suivi_personne_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_publipostage_suivi_personne_id ON publipostage_suivi USING btree (personne_id);


--
-- TOC entry 4053 (class 1259 OID 133134)
-- Dependencies: 389
-- Name: idx_publipostage_suivi_template_doc_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_publipostage_suivi_template_doc_id ON publipostage_suivi USING btree (template_document_id);


--
-- TOC entry 4066 (class 1259 OID 133135)
-- Dependencies: 395
-- Name: idx_template_doc_sous_template_eliot_template_eliot_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_doc_sous_template_eliot_template_eliot_id ON template_document_sous_template_eliot USING btree (template_eliot_id);


--
-- TOC entry 4060 (class 1259 OID 133136)
-- Dependencies: 393
-- Name: idx_template_document_etablissement_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_document_etablissement_id ON template_document USING btree (etablissement_id);


--
-- TOC entry 4061 (class 1259 OID 133137)
-- Dependencies: 393
-- Name: idx_template_document_template_eliot_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_document_template_eliot_id ON template_document USING btree (template_eliot_id);


--
-- TOC entry 4071 (class 1259 OID 133138)
-- Dependencies: 397
-- Name: idx_template_eliot_template_jasper_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_eliot_template_jasper_id ON template_eliot USING btree (template_jasper_id);


--
-- TOC entry 4072 (class 1259 OID 133139)
-- Dependencies: 397
-- Name: idx_template_eliot_type_donnees_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_eliot_type_donnees_id ON template_eliot USING btree (type_donnees_id);


--
-- TOC entry 4073 (class 1259 OID 133140)
-- Dependencies: 397
-- Name: idx_template_eliot_type_fonctionnalite_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_eliot_type_fonctionnalite_id ON template_eliot USING btree (type_fonctionnalite_id);


--
-- TOC entry 4078 (class 1259 OID 133141)
-- Dependencies: 399
-- Name: idx_template_jasper_sous_template_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_jasper_sous_template_id ON template_jasper USING btree (sous_template_id);


--
-- TOC entry 4085 (class 1259 OID 133142)
-- Dependencies: 403
-- Name: idx_template_type_fonctionnalite_code; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_type_fonctionnalite_code ON template_type_fonctionnalite USING btree (code);


--
-- TOC entry 4086 (class 1259 OID 133143)
-- Dependencies: 403
-- Name: idx_template_type_fonctionnalite_parent_id; Type: INDEX; Schema: impression; Owner: -; Tablespace: 
--

CREATE INDEX idx_template_type_fonctionnalite_parent_id ON template_type_fonctionnalite USING btree (parent_id);


SET search_path = securite, pg_catalog;

--
-- TOC entry 4093 (class 1259 OID 134415)
-- Dependencies: 407
-- Name: idx_autorisation_autorite_id; Type: INDEX; Schema: securite; Owner: -; Tablespace: 
--

CREATE INDEX idx_autorisation_autorite_id ON autorisation USING btree (autorite_id);


--
-- TOC entry 4094 (class 1259 OID 135494)
-- Dependencies: 407
-- Name: idx_autorisation_item_id; Type: INDEX; Schema: securite; Owner: -; Tablespace: 
--

CREATE INDEX idx_autorisation_item_id ON autorisation USING btree (item_id);


--
-- TOC entry 4099 (class 1259 OID 133145)
-- Dependencies: 408
-- Name: idx_item_item_parent_id; Type: INDEX; Schema: securite; Owner: -; Tablespace: 
--

CREATE INDEX idx_item_item_parent_id ON item USING btree (item_parent_id);


--
-- TOC entry 4104 (class 1259 OID 134416)
-- Dependencies: 409
-- Name: idx_perimetre_perimetre_parent_id; Type: INDEX; Schema: securite; Owner: -; Tablespace: 
--

CREATE INDEX idx_perimetre_perimetre_parent_id ON perimetre USING btree (perimetre_parent_id);


--
-- TOC entry 4109 (class 1259 OID 133147)
-- Dependencies: 410
-- Name: idx_perimetre_securite_perimetre_id; Type: INDEX; Schema: securite; Owner: -; Tablespace: 
--

CREATE INDEX idx_perimetre_securite_perimetre_id ON perimetre_securite USING btree (perimetre_id);


SET search_path = td, pg_catalog;

--
-- TOC entry 4421 (class 1259 OID 138823)
-- Dependencies: 536
-- Name: idx_copie_correcteur_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_copie_correcteur_id ON copie USING btree (correcteur_id);


--
-- TOC entry 4422 (class 1259 OID 138817)
-- Dependencies: 536
-- Name: idx_copie_eleve_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_copie_eleve_id ON copie USING btree (eleve_id);


--
-- TOC entry 4423 (class 1259 OID 138906)
-- Dependencies: 536
-- Name: idx_copie_modalite_activite_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_copie_modalite_activite_id ON copie USING btree (modalite_activite_id);


--
-- TOC entry 4424 (class 1259 OID 138811)
-- Dependencies: 536
-- Name: idx_copie_sujet_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_copie_sujet_id ON copie USING btree (sujet_id);


--
-- TOC entry 4437 (class 1259 OID 138870)
-- Dependencies: 539
-- Name: idx_modalite_activite_activite_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_activite_id ON modalite_activite USING btree (activite_id);


--
-- TOC entry 4438 (class 1259 OID 138882)
-- Dependencies: 539
-- Name: idx_modalite_activite_enseignant_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_enseignant_id ON modalite_activite USING btree (enseignant_id);


--
-- TOC entry 4439 (class 1259 OID 138888)
-- Dependencies: 539
-- Name: idx_modalite_activite_etablissement_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_etablissement_id ON modalite_activite USING btree (etablissement_id);


--
-- TOC entry 4440 (class 1259 OID 138864)
-- Dependencies: 539
-- Name: idx_modalite_activite_evaluation_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_evaluation_id ON modalite_activite USING btree (evaluation_id);


--
-- TOC entry 4441 (class 1259 OID 138900)
-- Dependencies: 539
-- Name: idx_modalite_activite_groupe_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_groupe_id ON modalite_activite USING btree (groupe_id);


--
-- TOC entry 4442 (class 1259 OID 139059)
-- Dependencies: 539
-- Name: idx_modalite_activite_matiere_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_matiere_id ON modalite_activite USING btree (matiere_id);


--
-- TOC entry 4443 (class 1259 OID 138894)
-- Dependencies: 539
-- Name: idx_modalite_activite_responsable_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_responsable_id ON modalite_activite USING btree (responsable_id);


--
-- TOC entry 4444 (class 1259 OID 139058)
-- Dependencies: 539
-- Name: idx_modalite_activite_structure_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_structure_id ON modalite_activite USING btree (structure_enseignement_id);


--
-- TOC entry 4445 (class 1259 OID 139039)
-- Dependencies: 539
-- Name: idx_modalite_activite_sujet_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_modalite_activite_sujet_id ON modalite_activite USING btree (sujet_id);


--
-- TOC entry 4399 (class 1259 OID 138670)
-- Dependencies: 526
-- Name: idx_question_attachement_attachement_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_attachement_attachement_id ON question_attachement USING btree (attachement_id);


--
-- TOC entry 4384 (class 1259 OID 139146)
-- Dependencies: 522
-- Name: idx_question_attachement_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_attachement_id ON question USING btree (attachement_id);


--
-- TOC entry 4400 (class 1259 OID 138676)
-- Dependencies: 526
-- Name: idx_question_attachement_question_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_attachement_question_id ON question_attachement USING btree (question_id);


--
-- TOC entry 4385 (class 1259 OID 139009)
-- Dependencies: 522
-- Name: idx_question_copyrights_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_copyrights_id ON question USING btree (copyrights_type_id);


--
-- TOC entry 4386 (class 1259 OID 138616)
-- Dependencies: 522
-- Name: idx_question_etablissement_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_etablissement_id ON question USING btree (etablissement_id);


--
-- TOC entry 4387 (class 1259 OID 139133)
-- Dependencies: 522
-- Name: idx_question_exercice_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_exercice_id ON question USING btree (exercice_id);


--
-- TOC entry 4395 (class 1259 OID 138650)
-- Dependencies: 524
-- Name: idx_question_export_format_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_export_format_id ON question_export USING btree (format_id);


--
-- TOC entry 4396 (class 1259 OID 138656)
-- Dependencies: 524
-- Name: idx_question_export_question_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_export_question_id ON question_export USING btree (question_id);


--
-- TOC entry 4388 (class 1259 OID 138622)
-- Dependencies: 522
-- Name: idx_question_matiere_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_matiere_id ON question USING btree (matiere_id);


--
-- TOC entry 4389 (class 1259 OID 138610)
-- Dependencies: 522
-- Name: idx_question_niveau_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_niveau_id ON question USING btree (niveau_id);


--
-- TOC entry 4390 (class 1259 OID 138634)
-- Dependencies: 522
-- Name: idx_question_proprietaire_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_proprietaire_id ON question USING btree (proprietaire_id);


--
-- TOC entry 4391 (class 1259 OID 138783)
-- Dependencies: 522
-- Name: idx_question_publication_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_publication_id ON question USING btree (publication_id);


--
-- TOC entry 4392 (class 1259 OID 138628)
-- Dependencies: 522
-- Name: idx_question_type_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_question_type_id ON question USING btree (type_id);


--
-- TOC entry 4450 (class 1259 OID 139126)
-- Dependencies: 544
-- Name: idx_reponse_attachement_attachement_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_reponse_attachement_attachement_id ON reponse_attachement USING btree (attachement_id);


--
-- TOC entry 4451 (class 1259 OID 139132)
-- Dependencies: 544
-- Name: idx_reponse_attachement_reponse_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_reponse_attachement_reponse_id ON reponse_attachement USING btree (reponse_id);


--
-- TOC entry 4429 (class 1259 OID 138839)
-- Dependencies: 538
-- Name: idx_reponse_copie_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_reponse_copie_id ON reponse USING btree (copie_id);


--
-- TOC entry 4430 (class 1259 OID 138851)
-- Dependencies: 538
-- Name: idx_reponse_correcteur_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_reponse_correcteur_id ON reponse USING btree (correcteur_id);


--
-- TOC entry 4431 (class 1259 OID 138922)
-- Dependencies: 538
-- Name: idx_reponse_eleve_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_reponse_eleve_id ON reponse USING btree (eleve_id);


--
-- TOC entry 4432 (class 1259 OID 139077)
-- Dependencies: 538
-- Name: idx_reponse_sujet_question_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_reponse_sujet_question_id ON reponse USING btree (sujet_question_id);


--
-- TOC entry 4403 (class 1259 OID 138927)
-- Dependencies: 528
-- Name: idx_sujet_copyrights_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_copyrights_id ON sujet USING btree (copyrights_type_id);


--
-- TOC entry 4404 (class 1259 OID 138718)
-- Dependencies: 528
-- Name: idx_sujet_etablissement_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_etablissement_id ON sujet USING btree (etablissement_id);


--
-- TOC entry 4405 (class 1259 OID 138724)
-- Dependencies: 528
-- Name: idx_sujet_matiere_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_matiere_id ON sujet USING btree (matiere_id);


--
-- TOC entry 4406 (class 1259 OID 138712)
-- Dependencies: 528
-- Name: idx_sujet_niveau_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_niveau_id ON sujet USING btree (niveau_id);


--
-- TOC entry 4407 (class 1259 OID 138730)
-- Dependencies: 528
-- Name: idx_sujet_proprietaire_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_proprietaire_id ON sujet USING btree (proprietaire_id);


--
-- TOC entry 4408 (class 1259 OID 138789)
-- Dependencies: 528
-- Name: idx_sujet_publication_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_publication_id ON sujet USING btree (publication_id);


--
-- TOC entry 4412 (class 1259 OID 138749)
-- Dependencies: 530
-- Name: idx_sujet_sequence_questions_question_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_sequence_questions_question_id ON sujet_sequence_questions USING btree (question_id);


--
-- TOC entry 4413 (class 1259 OID 138743)
-- Dependencies: 530
-- Name: idx_sujet_sequence_questions_sujet_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_sequence_questions_sujet_id ON sujet_sequence_questions USING btree (sujet_id);


--
-- TOC entry 4409 (class 1259 OID 138992)
-- Dependencies: 528
-- Name: idx_sujet_sujet_type_id; Type: INDEX; Schema: td; Owner: -; Tablespace: 
--

CREATE INDEX idx_sujet_sujet_type_id ON sujet USING btree (sujet_type_id);


SET search_path = tice, pg_catalog;

--
-- TOC entry 4379 (class 1259 OID 139152)
-- Dependencies: 518
-- Name: idx_attachement_chemin; Type: INDEX; Schema: tice; Owner: -; Tablespace: 
--

CREATE INDEX idx_attachement_chemin ON attachement USING btree (chemin);


--
-- TOC entry 4368 (class 1259 OID 138560)
-- Dependencies: 514
-- Name: idx_compte_utilisateur_login; Type: INDEX; Schema: tice; Owner: -; Tablespace: 
--

CREATE INDEX idx_compte_utilisateur_login ON compte_utilisateur USING btree (login);


--
-- TOC entry 4369 (class 1259 OID 138561)
-- Dependencies: 514
-- Name: idx_compte_utilisateur_login_alias; Type: INDEX; Schema: tice; Owner: -; Tablespace: 
--

CREATE INDEX idx_compte_utilisateur_login_alias ON compte_utilisateur USING btree (login_alias);


--
-- TOC entry 4370 (class 1259 OID 138564)
-- Dependencies: 514
-- Name: idx_compte_utilisateur_personne_id; Type: INDEX; Schema: tice; Owner: -; Tablespace: 
--

CREATE INDEX idx_compte_utilisateur_personne_id ON compte_utilisateur USING btree (personne_id);


--
-- TOC entry 4418 (class 1259 OID 138777)
-- Dependencies: 533
-- Name: idx_publication_copyrights_type_id; Type: INDEX; Schema: tice; Owner: -; Tablespace: 
--

CREATE INDEX idx_publication_copyrights_type_id ON publication USING btree (copyrights_type_id);


SET search_path = enttemps, pg_catalog;

--
-- TOC entry 4943 (class 2620 OID 133148)
-- Dependencies: 560 319
-- Name: agenda_before_insert; Type: TRIGGER; Schema: enttemps; Owner: -
--

CREATE TRIGGER agenda_before_insert BEFORE INSERT ON agenda FOR EACH ROW EXECUTE PROCEDURE agenda_before_insert();


SET search_path = aaf, pg_catalog;

--
-- TOC entry 4458 (class 2606 OID 133149)
-- Dependencies: 179 3585 181
-- Name: fk_import_verrou_import; Type: FK CONSTRAINT; Schema: aaf; Owner: -
--

ALTER TABLE ONLY import_verrou
    ADD CONSTRAINT fk_import_verrou_import FOREIGN KEY (import_id) REFERENCES import(id);


SET search_path = ent, pg_catalog;

--
-- TOC entry 4460 (class 2606 OID 135954)
-- Dependencies: 199 187 3627
-- Name: fk_appartenance_groupe_groupe_groupe_personnes_enfant; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY appartenance_groupe_groupe
    ADD CONSTRAINT fk_appartenance_groupe_groupe_groupe_personnes_enfant FOREIGN KEY (groupe_personnes_enfant_id) REFERENCES groupe_personnes(id);


--
-- TOC entry 4459 (class 2606 OID 135959)
-- Dependencies: 199 187 3627
-- Name: fk_appartenance_groupe_groupe_groupe_personnes_parent; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY appartenance_groupe_groupe
    ADD CONSTRAINT fk_appartenance_groupe_groupe_groupe_personnes_parent FOREIGN KEY (groupe_personnes_parent_id) REFERENCES groupe_personnes(id);


--
-- TOC entry 4461 (class 2606 OID 135964)
-- Dependencies: 199 189 3627
-- Name: fk_appartenance_personne_groupe_groupe_personnes; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY appartenance_personne_groupe
    ADD CONSTRAINT fk_appartenance_personne_groupe_groupe_personnes FOREIGN KEY (groupe_personnes_id) REFERENCES groupe_personnes(id);


--
-- TOC entry 4462 (class 2606 OID 133169)
-- Dependencies: 214 189 3660
-- Name: fk_appartenance_personne_groupe_personne; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY appartenance_personne_groupe
    ADD CONSTRAINT fk_appartenance_personne_groupe_personne FOREIGN KEY (personne_id) REFERENCES personne(id);


--
-- TOC entry 4628 (class 2606 OID 135857)
-- Dependencies: 185 3593 327
-- Name: fk_calendrier_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT fk_calendrier_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id) ON DELETE CASCADE;


--
-- TOC entry 4629 (class 2606 OID 136622)
-- Dependencies: 327 193 3614
-- Name: fk_calendrier_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT fk_calendrier_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- TOC entry 4500 (class 2606 OID 135949)
-- Dependencies: 247 229 3739
-- Name: fk_enseignement_autorite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_autorite FOREIGN KEY (enseignant_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4501 (class 2606 OID 135944)
-- Dependencies: 236 229 3716
-- Name: fk_enseignement_service; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_service FOREIGN KEY (service_id) REFERENCES service(id) ON DELETE CASCADE;


--
-- TOC entry 4463 (class 2606 OID 135969)
-- Dependencies: 193 193 3614
-- Name: fk_etablissement_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT fk_etablissement_etablissement FOREIGN KEY (etablissement_rattachement_id) REFERENCES etablissement(id);


--
-- TOC entry 4465 (class 2606 OID 133179)
-- Dependencies: 193 409 4105
-- Name: fk_etablissement_perimetre; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT fk_etablissement_perimetre FOREIGN KEY (perimetre_id) REFERENCES securite.perimetre(id);


--
-- TOC entry 4464 (class 2606 OID 133184)
-- Dependencies: 218 193 3670
-- Name: fk_etablissement_porteur_ent; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY etablissement
    ADD CONSTRAINT fk_etablissement_porteur_ent FOREIGN KEY (porteur_ent_id) REFERENCES porteur_ent(id);


--
-- TOC entry 4714 (class 2606 OID 135974)
-- Dependencies: 214 420 3660
-- Name: fk_fiche_eleve_commentaire_personne; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY fiche_eleve_commentaire
    ADD CONSTRAINT fk_fiche_eleve_commentaire_personne FOREIGN KEY (personne_id) REFERENCES personne(id);


--
-- TOC entry 4468 (class 2606 OID 133189)
-- Dependencies: 3739 247 199
-- Name: fk_groupe_personnes_autorite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT fk_groupe_personnes_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4467 (class 2606 OID 133194)
-- Dependencies: 4100 199 408
-- Name: fk_groupe_personnes_item; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT fk_groupe_personnes_item FOREIGN KEY (item_id) REFERENCES securite.item(id);


--
-- TOC entry 4466 (class 2606 OID 135539)
-- Dependencies: 3683 199 223
-- Name: fk_groupe_personnes_propriete_scolarite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY groupe_personnes
    ADD CONSTRAINT fk_groupe_personnes_propriete_scolarite FOREIGN KEY (propriete_scolarite_id) REFERENCES propriete_scolarite(id);


--
-- TOC entry 4469 (class 2606 OID 137051)
-- Dependencies: 185 202 3593
-- Name: fk_matiere_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT fk_matiere_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id);


--
-- TOC entry 4470 (class 2606 OID 133204)
-- Dependencies: 193 202 3614
-- Name: fk_matiere_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT fk_matiere_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- TOC entry 4471 (class 2606 OID 137056)
-- Dependencies: 3593 185 208
-- Name: fk_modalite_matiere_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT fk_modalite_matiere_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id);


--
-- TOC entry 4472 (class 2606 OID 135979)
-- Dependencies: 3614 208 193
-- Name: fk_modalite_matiere_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT fk_modalite_matiere_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- TOC entry 4474 (class 2606 OID 133219)
-- Dependencies: 243 3729 212
-- Name: fk_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT fk_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id);


--
-- TOC entry 4473 (class 2606 OID 133224)
-- Dependencies: 3733 212 245
-- Name: fk_periode_type_periode; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT fk_periode_type_periode FOREIGN KEY (type_periode_id) REFERENCES type_periode(id);


--
-- TOC entry 4477 (class 2606 OID 134611)
-- Dependencies: 247 3739 214
-- Name: fk_personne_autorite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT fk_personne_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- TOC entry 4478 (class 2606 OID 133234)
-- Dependencies: 3608 191 214
-- Name: fk_personne_civilite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT fk_personne_civilite FOREIGN KEY (civilite_id) REFERENCES civilite(id);


--
-- TOC entry 4476 (class 2606 OID 135984)
-- Dependencies: 214 193 3614
-- Name: fk_personne_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT fk_personne_etablissement FOREIGN KEY (etablissement_rattachement_id) REFERENCES etablissement(id);


--
-- TOC entry 4482 (class 2606 OID 135593)
-- Dependencies: 179 216 3585
-- Name: fk_personne_propriete_scolarite_import; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_import FOREIGN KEY (aaf_import_id) REFERENCES aaf.import(id);


--
-- TOC entry 4481 (class 2606 OID 135598)
-- Dependencies: 216 3660 214
-- Name: fk_personne_propriete_scolarite_personne; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_personne FOREIGN KEY (personne_id) REFERENCES personne(id);


--
-- TOC entry 4480 (class 2606 OID 137103)
-- Dependencies: 223 3683 216
-- Name: fk_personne_propriete_scolarite_propriete_scolarite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_propriete_scolarite FOREIGN KEY (propriete_scolarite_id) REFERENCES propriete_scolarite(id);


--
-- TOC entry 4479 (class 2606 OID 138498)
-- Dependencies: 4158 448 216
-- Name: fk_personne_propriete_scolarite_udt_import; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_udt_import FOREIGN KEY (udt_import_id) REFERENCES udt.import(id);


--
-- TOC entry 4475 (class 2606 OID 135989)
-- Dependencies: 3685 214 225
-- Name: fk_personne_regime; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT fk_personne_regime FOREIGN KEY (regime_id) REFERENCES regime(id);


--
-- TOC entry 4483 (class 2606 OID 133264)
-- Dependencies: 4105 218 409
-- Name: fk_porteur_ent_perimetre; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY porteur_ent
    ADD CONSTRAINT fk_porteur_ent_perimetre FOREIGN KEY (perimetre_id) REFERENCES securite.perimetre(id);


--
-- TOC entry 4484 (class 2606 OID 137061)
-- Dependencies: 3593 220 185
-- Name: fk_preference_etablissement_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT fk_preference_etablissement_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id);


--
-- TOC entry 4486 (class 2606 OID 135625)
-- Dependencies: 220 193 3614
-- Name: fk_preference_etablissement_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT fk_preference_etablissement_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- TOC entry 4485 (class 2606 OID 136937)
-- Dependencies: 439 220 4148
-- Name: fk_preference_etablissement_sms_fournisseur_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT fk_preference_etablissement_sms_fournisseur_etablissement FOREIGN KEY (sms_fournisseur_etablissement_id) REFERENCES impression.sms_fournisseur_etablissement(id);


--
-- TOC entry 4488 (class 2606 OID 135837)
-- Dependencies: 3593 185 223
-- Name: fk_propriete_scolarite_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id);


--
-- TOC entry 4495 (class 2606 OID 135549)
-- Dependencies: 223 3614 193
-- Name: fk_propriete_scolarite_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- TOC entry 4494 (class 2606 OID 135554)
-- Dependencies: 197 223 3622
-- Name: fk_propriete_scolarite_fonction; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_fonction FOREIGN KEY (fonction_id) REFERENCES fonction(id);


--
-- TOC entry 4487 (class 2606 OID 135878)
-- Dependencies: 3633 202 223
-- Name: fk_propriete_scolarite_matiere; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_matiere FOREIGN KEY (matiere_id) REFERENCES matiere(id);


--
-- TOC entry 4493 (class 2606 OID 135564)
-- Dependencies: 204 3639 223
-- Name: fk_propriete_scolarite_mef; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_mef FOREIGN KEY (mef_id) REFERENCES mef(id);


--
-- TOC entry 4489 (class 2606 OID 135716)
-- Dependencies: 223 3651 210
-- Name: fk_propriete_scolarite_niveau; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_niveau FOREIGN KEY (niveau_id) REFERENCES niveau(id);


--
-- TOC entry 4490 (class 2606 OID 135584)
-- Dependencies: 3670 218 223
-- Name: fk_propriete_scolarite_porteur_ent; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_porteur_ent FOREIGN KEY (porteur_ent_id) REFERENCES porteur_ent(id);


--
-- TOC entry 4492 (class 2606 OID 135574)
-- Dependencies: 223 240 3720
-- Name: fk_propriete_scolarite_source_import; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_source_import FOREIGN KEY (source_id) REFERENCES source_import(id);


--
-- TOC entry 4491 (class 2606 OID 135579)
-- Dependencies: 3729 223 243
-- Name: fk_propriete_scolarite_structure_enseignement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id);


--
-- TOC entry 4497 (class 2606 OID 135994)
-- Dependencies: 195 227 3620
-- Name: fk_rel_classe_filiere_filiere; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT fk_rel_classe_filiere_filiere FOREIGN KEY (filiere_id) REFERENCES filiere(id);


--
-- TOC entry 4496 (class 2606 OID 135999)
-- Dependencies: 243 227 3729
-- Name: fk_rel_classe_filiere_structure_enseignement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT fk_rel_classe_filiere_structure_enseignement FOREIGN KEY (classe_id) REFERENCES structure_enseignement(id);


--
-- TOC entry 4499 (class 2606 OID 136004)
-- Dependencies: 243 228 3729
-- Name: fk_rel_classe_groupe_structure_enseignement_classe; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT fk_rel_classe_groupe_structure_enseignement_classe FOREIGN KEY (classe_id) REFERENCES structure_enseignement(id);


--
-- TOC entry 4498 (class 2606 OID 136009)
-- Dependencies: 243 228 3729
-- Name: fk_rel_classe_groupe_structure_enseignement_groupe; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT fk_rel_classe_groupe_structure_enseignement_groupe FOREIGN KEY (groupe_id) REFERENCES structure_enseignement(id);


--
-- TOC entry 4503 (class 2606 OID 133359)
-- Dependencies: 230 3655 212
-- Name: fk_rel_periode_service_periode; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT fk_rel_periode_service_periode FOREIGN KEY (periode_id) REFERENCES periode(id);


--
-- TOC entry 4502 (class 2606 OID 133364)
-- Dependencies: 236 3716 230
-- Name: fk_rel_periode_service_service; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT fk_rel_periode_service_service FOREIGN KEY (service_id) REFERENCES service(id);


--
-- TOC entry 4506 (class 2606 OID 136014)
-- Dependencies: 179 232 3585
-- Name: fk_responsable_eleve_import; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT fk_responsable_eleve_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- TOC entry 4505 (class 2606 OID 136019)
-- Dependencies: 214 232 3660
-- Name: fk_responsable_eleve_personne_eleve; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT fk_responsable_eleve_personne_eleve FOREIGN KEY (eleve_id) REFERENCES personne(id);


--
-- TOC entry 4504 (class 2606 OID 136024)
-- Dependencies: 214 232 3660
-- Name: fk_responsable_eleve_personne_personne; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY responsable_eleve
    ADD CONSTRAINT fk_responsable_eleve_personne_personne FOREIGN KEY (personne_id) REFERENCES personne(id);


--
-- TOC entry 4508 (class 2606 OID 135611)
-- Dependencies: 179 3585 234
-- Name: fk_responsable_propriete_scolarite_import; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_responsable_propriete_scolarite_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- TOC entry 4509 (class 2606 OID 135529)
-- Dependencies: 234 3683 223
-- Name: fk_responsable_propriete_scolarite_propriete_scolarite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_responsable_propriete_scolarite_propriete_scolarite FOREIGN KEY (propriete_scolarite_id) REFERENCES propriete_scolarite(id);


--
-- TOC entry 4507 (class 2606 OID 135616)
-- Dependencies: 232 3706 234
-- Name: fk_responsable_propriete_scolarite_responsable_eleve; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_responsable_propriete_scolarite_responsable_eleve FOREIGN KEY (responsable_eleve_id) REFERENCES responsable_eleve(id);


--
-- TOC entry 4512 (class 2606 OID 135883)
-- Dependencies: 202 236 3633
-- Name: fk_service_matiere; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_matiere FOREIGN KEY (matiere_id) REFERENCES matiere(id);


--
-- TOC entry 4511 (class 2606 OID 135888)
-- Dependencies: 236 3643 206
-- Name: fk_service_modalite_cours; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_modalite_cours FOREIGN KEY (modalite_cours_id) REFERENCES modalite_cours(id);


--
-- TOC entry 4510 (class 2606 OID 136029)
-- Dependencies: 243 236 3729
-- Name: fk_service_structure_enseignement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id) ON DELETE CASCADE;


--
-- TOC entry 4513 (class 2606 OID 136034)
-- Dependencies: 247 238 3739
-- Name: fk_signature_autorite; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY signature
    ADD CONSTRAINT fk_signature_autorite FOREIGN KEY (proprietaire_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4515 (class 2606 OID 136039)
-- Dependencies: 208 241 3647
-- Name: fk_sous_service_modalite_matiere; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_modalite_matiere FOREIGN KEY (modalite_matiere_id) REFERENCES modalite_matiere(id);


--
-- TOC entry 4514 (class 2606 OID 136044)
-- Dependencies: 236 241 3716
-- Name: fk_sous_service_service; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_service FOREIGN KEY (service_id) REFERENCES service(id);


--
-- TOC entry 4516 (class 2606 OID 133429)
-- Dependencies: 245 241 3733
-- Name: fk_sous_service_type_periode; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_type_periode FOREIGN KEY (type_periode_id) REFERENCES type_periode(id);


--
-- TOC entry 4520 (class 2606 OID 135842)
-- Dependencies: 243 3593 185
-- Name: fk_structure_enseignement_annee_scolaire; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES annee_scolaire(id);


--
-- TOC entry 4517 (class 2606 OID 136835)
-- Dependencies: 243 4126 429
-- Name: fk_structure_enseignement_brevet_serie; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_brevet_serie FOREIGN KEY (brevet_serie_id) REFERENCES entnotes.brevet_serie(id);


--
-- TOC entry 4519 (class 2606 OID 136049)
-- Dependencies: 193 3614 243
-- Name: fk_structure_enseignement_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


--
-- TOC entry 4518 (class 2606 OID 136610)
-- Dependencies: 243 3651 210
-- Name: fk_structure_enseignement_niveau; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_niveau FOREIGN KEY (niveau_id) REFERENCES niveau(id);


--
-- TOC entry 4521 (class 2606 OID 133444)
-- Dependencies: 3614 245 193
-- Name: fk_type_periode_etablissement; Type: FK CONSTRAINT; Schema: ent; Owner: -
--

ALTER TABLE ONLY type_periode
    ADD CONSTRAINT fk_type_periode_etablissement FOREIGN KEY (etablissement_id) REFERENCES etablissement(id);


SET search_path = ent_2011_2012, pg_catalog;

--
-- TOC entry 4861 (class 2606 OID 138291)
-- Dependencies: 498 185 3593
-- Name: fk_calendrier_annee_scolaire; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT fk_calendrier_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id) ON DELETE CASCADE;


--
-- TOC entry 4860 (class 2606 OID 138296)
-- Dependencies: 498 193 3614
-- Name: fk_calendrier_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY calendrier
    ADD CONSTRAINT fk_calendrier_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4863 (class 2606 OID 138301)
-- Dependencies: 499 247 3739
-- Name: fk_enseignement_autorite; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_autorite FOREIGN KEY (enseignant_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4862 (class 2606 OID 138306)
-- Dependencies: 499 510 4358
-- Name: fk_enseignement_service; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_service FOREIGN KEY (service_id) REFERENCES service(id) ON DELETE CASCADE;


--
-- TOC entry 4864 (class 2606 OID 138311)
-- Dependencies: 500 193 3614
-- Name: fk_matiere_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY matiere
    ADD CONSTRAINT fk_matiere_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4865 (class 2606 OID 138316)
-- Dependencies: 501 193 3614
-- Name: fk_modalite_matiere_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY modalite_matiere
    ADD CONSTRAINT fk_modalite_matiere_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4867 (class 2606 OID 138321)
-- Dependencies: 502 512 4364
-- Name: fk_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT fk_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id);


--
-- TOC entry 4866 (class 2606 OID 138326)
-- Dependencies: 502 245 3733
-- Name: fk_periode_type_periode; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY periode
    ADD CONSTRAINT fk_periode_type_periode FOREIGN KEY (type_periode_id) REFERENCES ent.type_periode(id);


--
-- TOC entry 4870 (class 2606 OID 138331)
-- Dependencies: 503 179 3585
-- Name: fk_personne_propriete_scolarite_import; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_import FOREIGN KEY (aaf_import_id) REFERENCES aaf.import(id);


--
-- TOC entry 4869 (class 2606 OID 138336)
-- Dependencies: 503 214 3660
-- Name: fk_personne_propriete_scolarite_personne; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_personne FOREIGN KEY (personne_id) REFERENCES ent.personne(id);


--
-- TOC entry 4891 (class 2606 OID 138426)
-- Dependencies: 505 4346 509
-- Name: fk_personne_propriete_scolarite_propriete_scolarite; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_propriete_scolarite FOREIGN KEY (propriete_scolarite_id) REFERENCES propriete_scolarite(id);


--
-- TOC entry 4868 (class 2606 OID 138537)
-- Dependencies: 4158 503 448
-- Name: fk_personne_propriete_scolarite_udt_import; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY personne_propriete_scolarite
    ADD CONSTRAINT fk_personne_propriete_scolarite_udt_import FOREIGN KEY (udt_import_id) REFERENCES udt.import(id);


--
-- TOC entry 4872 (class 2606 OID 138341)
-- Dependencies: 504 193 3614
-- Name: fk_preference_etablissement_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT fk_preference_etablissement_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4871 (class 2606 OID 138346)
-- Dependencies: 504 439 4148
-- Name: fk_preference_etablissement_sms_fournisseur_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY preference_etablissement
    ADD CONSTRAINT fk_preference_etablissement_sms_fournisseur_etablissement FOREIGN KEY (sms_fournisseur_etablissement_id) REFERENCES impression.sms_fournisseur_etablissement(id);


--
-- TOC entry 4881 (class 2606 OID 138351)
-- Dependencies: 505 185 3593
-- Name: fk_propriete_scolarite_annee_scolaire; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- TOC entry 4880 (class 2606 OID 138356)
-- Dependencies: 193 505 3614
-- Name: fk_propriete_scolarite_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4879 (class 2606 OID 138361)
-- Dependencies: 505 197 3622
-- Name: fk_propriete_scolarite_fonction; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_fonction FOREIGN KEY (fonction_id) REFERENCES ent.fonction(id);


--
-- TOC entry 4878 (class 2606 OID 138366)
-- Dependencies: 505 500 4326
-- Name: fk_propriete_scolarite_matiere; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_matiere FOREIGN KEY (matiere_id) REFERENCES matiere(id);


--
-- TOC entry 4877 (class 2606 OID 138371)
-- Dependencies: 505 204 3639
-- Name: fk_propriete_scolarite_mef; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_mef FOREIGN KEY (mef_id) REFERENCES ent.mef(id);


--
-- TOC entry 4876 (class 2606 OID 138376)
-- Dependencies: 505 210 3651
-- Name: fk_propriete_scolarite_niveau; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_niveau FOREIGN KEY (niveau_id) REFERENCES ent.niveau(id);


--
-- TOC entry 4875 (class 2606 OID 138381)
-- Dependencies: 505 218 3670
-- Name: fk_propriete_scolarite_porteur_ent; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_porteur_ent FOREIGN KEY (porteur_ent_id) REFERENCES ent.porteur_ent(id);


--
-- TOC entry 4874 (class 2606 OID 138386)
-- Dependencies: 505 240 3720
-- Name: fk_propriete_scolarite_source_import; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_source_import FOREIGN KEY (source_id) REFERENCES ent.source_import(id);


--
-- TOC entry 4873 (class 2606 OID 138391)
-- Dependencies: 505 512 4364
-- Name: fk_propriete_scolarite_structure_enseignement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY propriete_scolarite
    ADD CONSTRAINT fk_propriete_scolarite_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id);


--
-- TOC entry 4883 (class 2606 OID 138396)
-- Dependencies: 506 195 3620
-- Name: fk_rel_classe_filiere_filiere; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT fk_rel_classe_filiere_filiere FOREIGN KEY (filiere_id) REFERENCES ent.filiere(id);


--
-- TOC entry 4882 (class 2606 OID 138401)
-- Dependencies: 512 506 4364
-- Name: fk_rel_classe_filiere_structure_enseignement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_classe_filiere
    ADD CONSTRAINT fk_rel_classe_filiere_structure_enseignement FOREIGN KEY (classe_id) REFERENCES structure_enseignement(id);


--
-- TOC entry 4885 (class 2606 OID 138406)
-- Dependencies: 512 507 4364
-- Name: fk_rel_classe_groupe_structure_enseignement_classe; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT fk_rel_classe_groupe_structure_enseignement_classe FOREIGN KEY (classe_id) REFERENCES structure_enseignement(id);


--
-- TOC entry 4884 (class 2606 OID 138411)
-- Dependencies: 4364 507 512
-- Name: fk_rel_classe_groupe_structure_enseignement_groupe; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_classe_groupe
    ADD CONSTRAINT fk_rel_classe_groupe_structure_enseignement_groupe FOREIGN KEY (groupe_id) REFERENCES structure_enseignement(id);


--
-- TOC entry 4887 (class 2606 OID 138416)
-- Dependencies: 502 508 4336
-- Name: fk_rel_periode_service_periode; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT fk_rel_periode_service_periode FOREIGN KEY (periode_id) REFERENCES periode(id);


--
-- TOC entry 4886 (class 2606 OID 138421)
-- Dependencies: 510 508 4358
-- Name: fk_rel_periode_service_service; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_periode_service
    ADD CONSTRAINT fk_rel_periode_service_service FOREIGN KEY (service_id) REFERENCES service(id);


--
-- TOC entry 4890 (class 2606 OID 138431)
-- Dependencies: 3585 179 509
-- Name: fk_responsable_propriete_scolarite_import; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_responsable_propriete_scolarite_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- TOC entry 4889 (class 2606 OID 138436)
-- Dependencies: 505 4346 509
-- Name: fk_responsable_propriete_scolarite_propriete_scolarite; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_responsable_propriete_scolarite_propriete_scolarite FOREIGN KEY (propriete_scolarite_id) REFERENCES propriete_scolarite(id);


--
-- TOC entry 4888 (class 2606 OID 138441)
-- Dependencies: 509 232 3706
-- Name: fk_responsable_propriete_scolarite_responsable_eleve; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY responsable_propriete_scolarite
    ADD CONSTRAINT fk_responsable_propriete_scolarite_responsable_eleve FOREIGN KEY (responsable_eleve_id) REFERENCES ent.responsable_eleve(id);


--
-- TOC entry 4894 (class 2606 OID 138446)
-- Dependencies: 500 4326 510
-- Name: fk_service_matiere; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_matiere FOREIGN KEY (matiere_id) REFERENCES matiere(id);


--
-- TOC entry 4893 (class 2606 OID 138451)
-- Dependencies: 206 510 3643
-- Name: fk_service_modalite_cours; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_modalite_cours FOREIGN KEY (modalite_cours_id) REFERENCES ent.modalite_cours(id);


--
-- TOC entry 4892 (class 2606 OID 138456)
-- Dependencies: 512 4364 510
-- Name: fk_service_structure_enseignement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES structure_enseignement(id) ON DELETE CASCADE;


--
-- TOC entry 4897 (class 2606 OID 138461)
-- Dependencies: 511 4332 501
-- Name: fk_sous_service_modalite_matiere; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_modalite_matiere FOREIGN KEY (modalite_matiere_id) REFERENCES modalite_matiere(id);


--
-- TOC entry 4896 (class 2606 OID 138466)
-- Dependencies: 4358 510 511
-- Name: fk_sous_service_service; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_service FOREIGN KEY (service_id) REFERENCES service(id);


--
-- TOC entry 4895 (class 2606 OID 138471)
-- Dependencies: 511 245 3733
-- Name: fk_sous_service_type_periode; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY sous_service
    ADD CONSTRAINT fk_sous_service_type_periode FOREIGN KEY (type_periode_id) REFERENCES ent.type_periode(id);


--
-- TOC entry 4901 (class 2606 OID 138476)
-- Dependencies: 512 185 3593
-- Name: fk_structure_enseignement_annee_scolaire; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- TOC entry 4900 (class 2606 OID 138481)
-- Dependencies: 512 493 4304
-- Name: fk_structure_enseignement_brevet_serie; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_brevet_serie FOREIGN KEY (brevet_serie_id) REFERENCES entnotes_2011_2012.brevet_serie(id);


--
-- TOC entry 4899 (class 2606 OID 138486)
-- Dependencies: 512 193 3614
-- Name: fk_structure_enseignement_etablissement; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4898 (class 2606 OID 138491)
-- Dependencies: 512 3651 210
-- Name: fk_structure_enseignement_niveau; Type: FK CONSTRAINT; Schema: ent_2011_2012; Owner: -
--

ALTER TABLE ONLY structure_enseignement
    ADD CONSTRAINT fk_structure_enseignement_niveau FOREIGN KEY (niveau_id) REFERENCES ent.niveau(id);


SET search_path = entcdt, pg_catalog;

--
-- TOC entry 4527 (class 2606 OID 134644)
-- Dependencies: 248 3739 247
-- Name: fk_activite_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_autorite FOREIGN KEY (auteur_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4523 (class 2606 OID 136064)
-- Dependencies: 3752 248 250
-- Name: fk_activite_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_cahier_de_textes FOREIGN KEY (cahier_de_textes_id) REFERENCES cahier_de_textes(id);


--
-- TOC entry 4526 (class 2606 OID 134976)
-- Dependencies: 248 253 3756
-- Name: fk_activite_chapitre; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_chapitre FOREIGN KEY (chapitre_id) REFERENCES chapitre(id);


--
-- TOC entry 4525 (class 2606 OID 136054)
-- Dependencies: 3758 255 248
-- Name: fk_activite_contexte_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_contexte_activite FOREIGN KEY (contexte_activite_id) REFERENCES contexte_activite(id);


--
-- TOC entry 4528 (class 2606 OID 133464)
-- Dependencies: 4100 408 248
-- Name: fk_activite_item; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_item FOREIGN KEY (item_id) REFERENCES securite.item(id);


--
-- TOC entry 4524 (class 2606 OID 136059)
-- Dependencies: 3800 271 248
-- Name: fk_activite_type_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY activite
    ADD CONSTRAINT fk_activite_type_activite FOREIGN KEY (type_activite_id) REFERENCES type_activite(id);


--
-- TOC entry 4531 (class 2606 OID 135847)
-- Dependencies: 250 3593 185
-- Name: fk_cahier_de_textes_annee_scolaire; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- TOC entry 4529 (class 2606 OID 136079)
-- Dependencies: 250 250 3752
-- Name: fk_cahier_de_textes_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_cahier_de_textes FOREIGN KEY (parent_incorporation_id) REFERENCES cahier_de_textes(id);


--
-- TOC entry 4530 (class 2606 OID 136074)
-- Dependencies: 250 261 3771
-- Name: fk_cahier_de_textes_fichier; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_fichier FOREIGN KEY (fichier_id) REFERENCES fichier(id);


--
-- TOC entry 4533 (class 2606 OID 133494)
-- Dependencies: 408 4100 250
-- Name: fk_cahier_de_textes_item; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_item FOREIGN KEY (item_id) REFERENCES securite.item(id);


--
-- TOC entry 4532 (class 2606 OID 134950)
-- Dependencies: 3716 236 250
-- Name: fk_cahier_de_textes_service; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY cahier_de_textes
    ADD CONSTRAINT fk_cahier_de_textes_service FOREIGN KEY (service_id) REFERENCES ent.service(id);


--
-- TOC entry 4536 (class 2606 OID 134659)
-- Dependencies: 3739 253 247
-- Name: fk_chapitre_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY chapitre
    ADD CONSTRAINT fk_chapitre_autorite FOREIGN KEY (auteur_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4535 (class 2606 OID 136069)
-- Dependencies: 3752 253 250
-- Name: fk_chapitre_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY chapitre
    ADD CONSTRAINT fk_chapitre_cahier_de_textes FOREIGN KEY (cahier_de_textes_id) REFERENCES cahier_de_textes(id);


--
-- TOC entry 4534 (class 2606 OID 136084)
-- Dependencies: 3756 253 253
-- Name: fk_chapitre_chapitre; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY chapitre
    ADD CONSTRAINT fk_chapitre_chapitre FOREIGN KEY (chapitre_parent_id) REFERENCES chapitre(id);


--
-- TOC entry 4538 (class 2606 OID 135258)
-- Dependencies: 257 248 3748
-- Name: fk_date_activite_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY date_activite
    ADD CONSTRAINT fk_date_activite_activite FOREIGN KEY (activite_id) REFERENCES activite(id);


--
-- TOC entry 4537 (class 2606 OID 136089)
-- Dependencies: 331 257 3936
-- Name: fk_date_activite_evenement; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY date_activite
    ADD CONSTRAINT fk_date_activite_evenement FOREIGN KEY (evenement_id) REFERENCES enttemps.evenement(id) ON UPDATE SET NULL;


--
-- TOC entry 4539 (class 2606 OID 134675)
-- Dependencies: 259 3739 247
-- Name: fk_dossier_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY dossier
    ADD CONSTRAINT fk_dossier_autorite FOREIGN KEY (acteur_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4540 (class 2606 OID 135263)
-- Dependencies: 248 3748 263
-- Name: fk_rel_activite_acteur_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_activite_acteur
    ADD CONSTRAINT fk_rel_activite_acteur_activite FOREIGN KEY (activite_id) REFERENCES activite(id);


--
-- TOC entry 4541 (class 2606 OID 134718)
-- Dependencies: 263 3739 247
-- Name: fk_rel_activite_acteur_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_activite_acteur
    ADD CONSTRAINT fk_rel_activite_acteur_autorite FOREIGN KEY (acteur_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4543 (class 2606 OID 134734)
-- Dependencies: 3739 264 247
-- Name: fk_rel_cahier_acteur_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_cahier_acteur
    ADD CONSTRAINT fk_rel_cahier_acteur_autorite FOREIGN KEY (acteur_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4542 (class 2606 OID 135151)
-- Dependencies: 264 250 3752
-- Name: fk_rel_cahier_acteur_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_cahier_acteur
    ADD CONSTRAINT fk_rel_cahier_acteur_cahier_de_textes FOREIGN KEY (cahier_de_textes_id) REFERENCES cahier_de_textes(id);


--
-- TOC entry 4544 (class 2606 OID 135176)
-- Dependencies: 247 3739 265
-- Name: fk_rel_cahier_groupe_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_cahier_groupe
    ADD CONSTRAINT fk_rel_cahier_groupe_autorite FOREIGN KEY (groupe_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4545 (class 2606 OID 135163)
-- Dependencies: 265 3752 250
-- Name: fk_rel_cahier_groupe_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_cahier_groupe
    ADD CONSTRAINT fk_rel_cahier_groupe_cahier_de_textes FOREIGN KEY (cahier_de_textes_id) REFERENCES cahier_de_textes(id);


--
-- TOC entry 4547 (class 2606 OID 133589)
-- Dependencies: 266 407 4095
-- Name: fk_rel_dossier_autorisation_cahier_autorisation; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_dossier_autorisation_cahier
    ADD CONSTRAINT fk_rel_dossier_autorisation_cahier_autorisation FOREIGN KEY (autorisation_id) REFERENCES securite.autorisation(id) ON DELETE CASCADE;


--
-- TOC entry 4546 (class 2606 OID 135188)
-- Dependencies: 3769 266 259
-- Name: fk_rel_dossier_autorisation_cahier_dossier; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY rel_dossier_autorisation_cahier
    ADD CONSTRAINT fk_rel_dossier_autorisation_cahier_dossier FOREIGN KEY (dossier_id) REFERENCES dossier(id);


--
-- TOC entry 4548 (class 2606 OID 135268)
-- Dependencies: 3748 267 248
-- Name: fk_ressource_activite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY ressource
    ADD CONSTRAINT fk_ressource_activite FOREIGN KEY (activite_id) REFERENCES activite(id);


--
-- TOC entry 4549 (class 2606 OID 135223)
-- Dependencies: 3771 261 267
-- Name: fk_ressource_fichier; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY ressource
    ADD CONSTRAINT fk_ressource_fichier FOREIGN KEY (fichier_id) REFERENCES fichier(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4550 (class 2606 OID 136094)
-- Dependencies: 3739 247 269
-- Name: fk_textes_preferences_utilisateur_autorite; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY textes_preferences_utilisateur
    ADD CONSTRAINT fk_textes_preferences_utilisateur_autorite FOREIGN KEY (utilisateur_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- TOC entry 4552 (class 2606 OID 136104)
-- Dependencies: 250 273 3752
-- Name: fk_visa_cahier_de_textes; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY visa
    ADD CONSTRAINT fk_visa_cahier_de_textes FOREIGN KEY (cahier_vise_id) REFERENCES cahier_de_textes(id);


--
-- TOC entry 4551 (class 2606 OID 137036)
-- Dependencies: 3618 273 193
-- Name: fk_visa_etablissement; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY visa
    ADD CONSTRAINT fk_visa_etablissement FOREIGN KEY (etablissement_uai) REFERENCES ent.etablissement(uai);


--
-- TOC entry 4553 (class 2606 OID 136099)
-- Dependencies: 273 3660 214
-- Name: fk_visa_personne; Type: FK CONSTRAINT; Schema: entcdt; Owner: -
--

ALTER TABLE ONLY visa
    ADD CONSTRAINT fk_visa_personne FOREIGN KEY (auteur_personne_id) REFERENCES ent.personne(id);


SET search_path = entdemon, pg_catalog;

--
-- TOC entry 4556 (class 2606 OID 135852)
-- Dependencies: 185 3593 275
-- Name: fk_demande_traitement_annee_scolaire; Type: FK CONSTRAINT; Schema: entdemon; Owner: -
--

ALTER TABLE ONLY demande_traitement
    ADD CONSTRAINT fk_demande_traitement_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- TOC entry 4554 (class 2606 OID 136114)
-- Dependencies: 3739 275 247
-- Name: fk_demande_traitement_autorite; Type: FK CONSTRAINT; Schema: entdemon; Owner: -
--

ALTER TABLE ONLY demande_traitement
    ADD CONSTRAINT fk_demande_traitement_autorite FOREIGN KEY (demandeur_autorite_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4555 (class 2606 OID 136109)
-- Dependencies: 3614 193 275
-- Name: fk_demande_traitement_etablissement; Type: FK CONSTRAINT; Schema: entdemon; Owner: -
--

ALTER TABLE ONLY demande_traitement
    ADD CONSTRAINT fk_demande_traitement_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


SET search_path = entnotes, pg_catalog;

--
-- TOC entry 4559 (class 2606 OID 135908)
-- Dependencies: 229 277 3696
-- Name: fk_appreciation_classe_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- TOC entry 4557 (class 2606 OID 136124)
-- Dependencies: 3655 277 212
-- Name: fk_appreciation_classe_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id);


--
-- TOC entry 4558 (class 2606 OID 136119)
-- Dependencies: 277 243 3729
-- Name: fk_appreciation_classe_enseignement_periode_structure_enseignem; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_structure_enseignem FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id);


--
-- TOC entry 4561 (class 2606 OID 136129)
-- Dependencies: 3739 247 279
-- Name: fk_appreciation_eleve_enseignement_periode_eleve; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_eleve FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4562 (class 2606 OID 135913)
-- Dependencies: 279 229 3696
-- Name: fk_appreciation_eleve_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- TOC entry 4560 (class 2606 OID 136134)
-- Dependencies: 3655 279 212
-- Name: fk_appreciation_eleve_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id);


--
-- TOC entry 4564 (class 2606 OID 136149)
-- Dependencies: 281 247 3739
-- Name: fk_appreciation_eleve_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4566 (class 2606 OID 136139)
-- Dependencies: 283 3823 281
-- Name: fk_appreciation_eleve_periode_avis_conseil_de_classe; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_avis_conseil_de_classe FOREIGN KEY (avis_conseil_de_classe_id) REFERENCES avis_conseil_de_classe(id);


--
-- TOC entry 4565 (class 2606 OID 136144)
-- Dependencies: 285 281 3827
-- Name: fk_appreciation_eleve_periode_avis_orientation; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_avis_orientation FOREIGN KEY (avis_orientation_id) REFERENCES avis_orientation(id);


--
-- TOC entry 4563 (class 2606 OID 136154)
-- Dependencies: 3655 281 212
-- Name: fk_appreciation_eleve_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id);


--
-- TOC entry 4567 (class 2606 OID 136159)
-- Dependencies: 283 193 3614
-- Name: fk_avis_conseil_de_classe_etablissement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY avis_conseil_de_classe
    ADD CONSTRAINT fk_avis_conseil_de_classe_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4568 (class 2606 OID 136164)
-- Dependencies: 285 193 3614
-- Name: fk_avis_orientation_etablissement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY avis_orientation
    ADD CONSTRAINT fk_avis_orientation_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4716 (class 2606 OID 136738)
-- Dependencies: 430 429 4126
-- Name: fk_brevet_epreuve_brevet_serie; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT fk_brevet_epreuve_brevet_serie FOREIGN KEY (serie_id) REFERENCES brevet_serie(id);


--
-- TOC entry 4718 (class 2606 OID 136728)
-- Dependencies: 430 430 4130
-- Name: fk_brevet_epreuve_exclusive; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT fk_brevet_epreuve_exclusive FOREIGN KEY (epreuve_exclusive_id) REFERENCES brevet_epreuve(id);


--
-- TOC entry 4731 (class 2606 OID 137078)
-- Dependencies: 443 185 3593
-- Name: fk_brevet_fiche_annee_scolaire; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT fk_brevet_fiche_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- TOC entry 4730 (class 2606 OID 137083)
-- Dependencies: 443 214 3660
-- Name: fk_brevet_fiche_personne; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT fk_brevet_fiche_personne FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- TOC entry 4723 (class 2606 OID 136785)
-- Dependencies: 433 430 4130
-- Name: fk_brevet_note_brevet_epreuve; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_brevet_epreuve FOREIGN KEY (epreuve_id) REFERENCES brevet_epreuve(id);


--
-- TOC entry 4721 (class 2606 OID 137088)
-- Dependencies: 443 433 4154
-- Name: fk_brevet_note_brevet_fiche; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_brevet_fiche FOREIGN KEY (fiche_id) REFERENCES brevet_fiche(id);


--
-- TOC entry 4724 (class 2606 OID 136775)
-- Dependencies: 433 431 4132
-- Name: fk_brevet_note_brevet_note_valeur_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_brevet_note_valeur_textuelle FOREIGN KEY (valeur_textuelle_id) REFERENCES brevet_note_valeur_textuelle(id);


--
-- TOC entry 4722 (class 2606 OID 136858)
-- Dependencies: 433 3633 202
-- Name: fk_brevet_note_matiere; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_matiere FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- TOC entry 4726 (class 2606 OID 136799)
-- Dependencies: 435 430 4130
-- Name: fk_brevet_rel_epreuve_matiere_brevet_epreuve; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT fk_brevet_rel_epreuve_matiere_brevet_epreuve FOREIGN KEY (epreuve_id) REFERENCES brevet_epreuve(id);


--
-- TOC entry 4725 (class 2606 OID 136804)
-- Dependencies: 435 202 3633
-- Name: fk_brevet_rel_epreuve_matiere_matiere; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT fk_brevet_rel_epreuve_matiere_matiere FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- TOC entry 4720 (class 2606 OID 136757)
-- Dependencies: 432 430 4130
-- Name: fk_brevet_rel_epreuve_note_valeur_textuelle_epreuve; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT fk_brevet_rel_epreuve_note_valeur_textuelle_epreuve FOREIGN KEY (brevet_epreuve_id) REFERENCES brevet_epreuve(id);


--
-- TOC entry 4719 (class 2606 OID 136762)
-- Dependencies: 432 431 4132
-- Name: fk_brevet_rel_epreuve_note_valeur_textuelle_valeur_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT fk_brevet_rel_epreuve_note_valeur_textuelle_valeur_textuelle FOREIGN KEY (valeur_textuelle_id) REFERENCES brevet_note_valeur_textuelle(id);


--
-- TOC entry 4715 (class 2606 OID 137066)
-- Dependencies: 3593 429 185
-- Name: fk_brevet_serie_annee_scolaire_id; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_serie
    ADD CONSTRAINT fk_brevet_serie_annee_scolaire_id FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- TOC entry 4574 (class 2606 OID 135918)
-- Dependencies: 288 229 3696
-- Name: fk_dirty_moyenne_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id) ON DELETE CASCADE;


--
-- TOC entry 4571 (class 2606 OID 136184)
-- Dependencies: 288 212 3655
-- Name: fk_dirty_moyenne_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4570 (class 2606 OID 136189)
-- Dependencies: 288 3716 236
-- Name: fk_dirty_moyenne_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_service FOREIGN KEY (service_id) REFERENCES ent.service(id) ON DELETE CASCADE;


--
-- TOC entry 4569 (class 2606 OID 136194)
-- Dependencies: 241 288 3725
-- Name: fk_dirty_moyenne_sous_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_sous_service FOREIGN KEY (sous_service_id) REFERENCES ent.sous_service(id) ON DELETE CASCADE;


--
-- TOC entry 4572 (class 2606 OID 136179)
-- Dependencies: 3739 247 288
-- Name: fk_dirty_moyenne_structure_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_structure_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- TOC entry 4573 (class 2606 OID 136174)
-- Dependencies: 243 3729 288
-- Name: fk_dirty_moyenne_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY dirty_moyenne
    ADD CONSTRAINT fk_dirty_moyenne_structure_enseignement FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id) ON DELETE CASCADE;


--
-- TOC entry 4717 (class 2606 OID 136733)
-- Dependencies: 430 430 4130
-- Name: fk_epreuve_matieres_a_heriter; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT fk_epreuve_matieres_a_heriter FOREIGN KEY (epreuve_matieres_a_heriter_id) REFERENCES brevet_epreuve(id);


--
-- TOC entry 4577 (class 2606 OID 135253)
-- Dependencies: 290 3748 248
-- Name: fk_evaluation_activite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_activite FOREIGN KEY (activite_id) REFERENCES entcdt.activite(id);


--
-- TOC entry 4576 (class 2606 OID 135923)
-- Dependencies: 3696 290 229
-- Name: fk_evaluation_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- TOC entry 4575 (class 2606 OID 136199)
-- Dependencies: 208 290 3647
-- Name: fk_evaluation_modalite_matiere; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_modalite_matiere FOREIGN KEY (modalite_matiere_id) REFERENCES ent.modalite_matiere(id);


--
-- TOC entry 4578 (class 2606 OID 136204)
-- Dependencies: 292 3729 243
-- Name: fk_info_calcul_moyennes_classe_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT fk_info_calcul_moyennes_classe_structure_enseignement FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id);


--
-- TOC entry 4579 (class 2606 OID 136214)
-- Dependencies: 3739 296 247
-- Name: fk_modele_appreciation_professeur_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY modele_appreciation_professeur
    ADD CONSTRAINT fk_modele_appreciation_professeur_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4581 (class 2606 OID 136219)
-- Dependencies: 298 3739 247
-- Name: fk_note_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- TOC entry 4582 (class 2606 OID 133774)
-- Dependencies: 298 290 3842
-- Name: fk_note_evaluation; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_evaluation FOREIGN KEY (evaluation_id) REFERENCES evaluation(id) ON DELETE CASCADE;


--
-- TOC entry 4580 (class 2606 OID 136961)
-- Dependencies: 4152 298 441
-- Name: fk_note_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- TOC entry 4728 (class 2606 OID 137046)
-- Dependencies: 3593 441 185
-- Name: fk_note_textuelle_annee_scolaire; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY note_textuelle
    ADD CONSTRAINT fk_note_textuelle_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- TOC entry 4729 (class 2606 OID 136954)
-- Dependencies: 193 441 3614
-- Name: fk_note_textuelle_etablissement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY note_textuelle
    ADD CONSTRAINT fk_note_textuelle_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4584 (class 2606 OID 136224)
-- Dependencies: 300 290 3842
-- Name: fk_rel_evaluation_periode_evaluation; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT fk_rel_evaluation_periode_evaluation FOREIGN KEY (evaluation_id) REFERENCES evaluation(id) ON DELETE CASCADE;


--
-- TOC entry 4583 (class 2606 OID 136229)
-- Dependencies: 212 3655 300
-- Name: fk_rel_evaluation_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT fk_rel_evaluation_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4585 (class 2606 OID 135928)
-- Dependencies: 229 301 3696
-- Name: fk_resultat_classe_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- TOC entry 4587 (class 2606 OID 133794)
-- Dependencies: 3655 301 212
-- Name: fk_resultat_classe_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4586 (class 2606 OID 133799)
-- Dependencies: 243 301 3729
-- Name: fk_resultat_classe_enseignement_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- TOC entry 4589 (class 2606 OID 133804)
-- Dependencies: 212 303 3655
-- Name: fk_resultat_classe_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT fk_resultat_classe_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4588 (class 2606 OID 136249)
-- Dependencies: 3729 303 243
-- Name: fk_resultat_classe_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT fk_resultat_classe_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- TOC entry 4592 (class 2606 OID 133809)
-- Dependencies: 212 305 3655
-- Name: fk_resultat_classe_service_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4591 (class 2606 OID 136234)
-- Dependencies: 305 236 3716
-- Name: fk_resultat_classe_service_periode_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_service FOREIGN KEY (service_id) REFERENCES ent.service(id);


--
-- TOC entry 4590 (class 2606 OID 136239)
-- Dependencies: 243 3729 305
-- Name: fk_resultat_classe_service_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- TOC entry 4594 (class 2606 OID 135893)
-- Dependencies: 305 3874 307
-- Name: fk_resultat_classe_sous_service_periode_resultat_classe_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT fk_resultat_classe_sous_service_periode_resultat_classe_service FOREIGN KEY (resultat_classe_service_periode_id) REFERENCES resultat_classe_service_periode(id) ON DELETE CASCADE;


--
-- TOC entry 4593 (class 2606 OID 136244)
-- Dependencies: 3725 307 241
-- Name: fk_resultat_classe_sous_service_periode_sous_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT fk_resultat_classe_sous_service_periode_sous_service FOREIGN KEY (sous_service_id) REFERENCES ent.sous_service(id) ON DELETE CASCADE;


--
-- TOC entry 4596 (class 2606 OID 136209)
-- Dependencies: 3739 309 247
-- Name: fk_resultat_eleve_enseignement_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4597 (class 2606 OID 135933)
-- Dependencies: 229 309 3696
-- Name: fk_resultat_eleve_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- TOC entry 4595 (class 2606 OID 136966)
-- Dependencies: 4152 309 441
-- Name: fk_resultat_eleve_enseignement_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- TOC entry 4598 (class 2606 OID 133844)
-- Dependencies: 212 309 3655
-- Name: fk_resultat_eleve_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4600 (class 2606 OID 136254)
-- Dependencies: 3739 247 311
-- Name: fk_resultat_eleve_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_autorite FOREIGN KEY (autorite_eleve_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4599 (class 2606 OID 136972)
-- Dependencies: 441 311 4152
-- Name: fk_resultat_eleve_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- TOC entry 4601 (class 2606 OID 133849)
-- Dependencies: 212 311 3655
-- Name: fk_resultat_eleve_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4605 (class 2606 OID 136259)
-- Dependencies: 3739 247 313
-- Name: fk_resultat_eleve_service_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_autorite FOREIGN KEY (autorite_eleve_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4602 (class 2606 OID 136978)
-- Dependencies: 313 441 4152
-- Name: fk_resultat_eleve_service_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- TOC entry 4604 (class 2606 OID 136264)
-- Dependencies: 3655 313 212
-- Name: fk_resultat_eleve_service_periode_periode; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_periode FOREIGN KEY (periode_id) REFERENCES ent.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4603 (class 2606 OID 136269)
-- Dependencies: 236 313 3716
-- Name: fk_resultat_eleve_service_periode_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_service FOREIGN KEY (service_id) REFERENCES ent.service(id);


--
-- TOC entry 4606 (class 2606 OID 136984)
-- Dependencies: 441 4152 315
-- Name: fk_resultat_eleve_sous_service_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- TOC entry 4608 (class 2606 OID 135898)
-- Dependencies: 3891 313 315
-- Name: fk_resultat_eleve_sous_service_periode_resultat_eleve_service_p; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_resultat_eleve_service_p FOREIGN KEY (resultat_eleve_service_periode_id) REFERENCES resultat_eleve_service_periode(id) ON DELETE CASCADE;


--
-- TOC entry 4607 (class 2606 OID 136274)
-- Dependencies: 241 315 3725
-- Name: fk_resultat_eleve_sous_service_periode_sous_service; Type: FK CONSTRAINT; Schema: entnotes; Owner: -
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_sous_service FOREIGN KEY (sous_service_id) REFERENCES ent.sous_service(id) ON DELETE CASCADE;


SET search_path = entnotes_2011_2012, pg_catalog;

--
-- TOC entry 4807 (class 2606 OID 138016)
-- Dependencies: 477 499 4322
-- Name: fk_appreciation_classe_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent_2011_2012.enseignement(id);


--
-- TOC entry 4806 (class 2606 OID 138021)
-- Dependencies: 477 502 4336
-- Name: fk_appreciation_classe_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id);


--
-- TOC entry 4805 (class 2606 OID 138026)
-- Dependencies: 477 512 4364
-- Name: fk_appreciation_classe_enseignement_periode_structure_enseignem; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_classe_enseignement_periode
    ADD CONSTRAINT fk_appreciation_classe_enseignement_periode_structure_enseignem FOREIGN KEY (classe_id) REFERENCES ent_2011_2012.structure_enseignement(id);


--
-- TOC entry 4810 (class 2606 OID 138031)
-- Dependencies: 478 247 3739
-- Name: fk_appreciation_eleve_enseignement_periode_eleve; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_eleve FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4809 (class 2606 OID 138036)
-- Dependencies: 478 499 4322
-- Name: fk_appreciation_eleve_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent_2011_2012.enseignement(id);


--
-- TOC entry 4808 (class 2606 OID 138041)
-- Dependencies: 478 502 4336
-- Name: fk_appreciation_eleve_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_enseignement_periode
    ADD CONSTRAINT fk_appreciation_eleve_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id);


--
-- TOC entry 4804 (class 2606 OID 137996)
-- Dependencies: 476 247 3739
-- Name: fk_appreciation_eleve_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4803 (class 2606 OID 138001)
-- Dependencies: 476 283 3823
-- Name: fk_appreciation_eleve_periode_avis_conseil_de_classe; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_avis_conseil_de_classe FOREIGN KEY (avis_conseil_de_classe_id) REFERENCES entnotes.avis_conseil_de_classe(id);


--
-- TOC entry 4802 (class 2606 OID 138006)
-- Dependencies: 476 285 3827
-- Name: fk_appreciation_eleve_periode_avis_orientation; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_avis_orientation FOREIGN KEY (avis_orientation_id) REFERENCES entnotes.avis_orientation(id);


--
-- TOC entry 4801 (class 2606 OID 138011)
-- Dependencies: 476 502 4336
-- Name: fk_appreciation_eleve_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY appreciation_eleve_periode
    ADD CONSTRAINT fk_appreciation_eleve_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id);


--
-- TOC entry 4850 (class 2606 OID 138206)
-- Dependencies: 492 493 4304
-- Name: fk_brevet_epreuve_brevet_serie; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT fk_brevet_epreuve_brevet_serie FOREIGN KEY (serie_id) REFERENCES brevet_serie(id);


--
-- TOC entry 4849 (class 2606 OID 138211)
-- Dependencies: 492 492 4302
-- Name: fk_brevet_epreuve_exclusive; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT fk_brevet_epreuve_exclusive FOREIGN KEY (epreuve_exclusive_id) REFERENCES brevet_epreuve(id);


--
-- TOC entry 4858 (class 2606 OID 138271)
-- Dependencies: 496 185 3593
-- Name: fk_brevet_fiche_annee_scolaire; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT fk_brevet_fiche_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- TOC entry 4857 (class 2606 OID 138276)
-- Dependencies: 496 214 3660
-- Name: fk_brevet_fiche_personne; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_fiche
    ADD CONSTRAINT fk_brevet_fiche_personne FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- TOC entry 4843 (class 2606 OID 138221)
-- Dependencies: 489 492 4302
-- Name: fk_brevet_note_brevet_epreuve; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_brevet_epreuve FOREIGN KEY (epreuve_id) REFERENCES brevet_epreuve(id);


--
-- TOC entry 4842 (class 2606 OID 138226)
-- Dependencies: 489 496 4310
-- Name: fk_brevet_note_brevet_fiche; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_brevet_fiche FOREIGN KEY (fiche_id) REFERENCES brevet_fiche(id);


--
-- TOC entry 4841 (class 2606 OID 138231)
-- Dependencies: 431 489 4132
-- Name: fk_brevet_note_brevet_note_valeur_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_brevet_note_valeur_textuelle FOREIGN KEY (valeur_textuelle_id) REFERENCES entnotes.brevet_note_valeur_textuelle(id);


--
-- TOC entry 4840 (class 2606 OID 138236)
-- Dependencies: 489 500 4326
-- Name: fk_brevet_note_matiere; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_note
    ADD CONSTRAINT fk_brevet_note_matiere FOREIGN KEY (matiere_id) REFERENCES ent_2011_2012.matiere(id);


--
-- TOC entry 4845 (class 2606 OID 138241)
-- Dependencies: 490 492 4302
-- Name: fk_brevet_rel_epreuve_matiere_brevet_epreuve; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT fk_brevet_rel_epreuve_matiere_brevet_epreuve FOREIGN KEY (epreuve_id) REFERENCES brevet_epreuve(id);


--
-- TOC entry 4844 (class 2606 OID 138246)
-- Dependencies: 490 500 4326
-- Name: fk_brevet_rel_epreuve_matiere_matiere; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_matiere
    ADD CONSTRAINT fk_brevet_rel_epreuve_matiere_matiere FOREIGN KEY (matiere_id) REFERENCES ent_2011_2012.matiere(id);


--
-- TOC entry 4847 (class 2606 OID 138251)
-- Dependencies: 491 492 4302
-- Name: fk_brevet_rel_epreuve_note_valeur_textuelle_epreuve; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT fk_brevet_rel_epreuve_note_valeur_textuelle_epreuve FOREIGN KEY (brevet_epreuve_id) REFERENCES brevet_epreuve(id);


--
-- TOC entry 4846 (class 2606 OID 138256)
-- Dependencies: 491 431 4132
-- Name: fk_brevet_rel_epreuve_note_valeur_textuelle_valeur_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_rel_epreuve_note_valeur_textuelle
    ADD CONSTRAINT fk_brevet_rel_epreuve_note_valeur_textuelle_valeur_textuelle FOREIGN KEY (valeur_textuelle_id) REFERENCES entnotes.brevet_note_valeur_textuelle(id);


--
-- TOC entry 4851 (class 2606 OID 138281)
-- Dependencies: 493 185 3593
-- Name: fk_brevet_serie_annee_scolaire_id; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_serie
    ADD CONSTRAINT fk_brevet_serie_annee_scolaire_id FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- TOC entry 4848 (class 2606 OID 138216)
-- Dependencies: 492 492 4302
-- Name: fk_epreuve_matieres_a_heriter; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY brevet_epreuve
    ADD CONSTRAINT fk_epreuve_matieres_a_heriter FOREIGN KEY (epreuve_matieres_a_heriter_id) REFERENCES brevet_epreuve(id);


--
-- TOC entry 4856 (class 2606 OID 138056)
-- Dependencies: 495 248 3748
-- Name: fk_evaluation_activite; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_activite FOREIGN KEY (activite_id) REFERENCES entcdt.activite(id);


--
-- TOC entry 4855 (class 2606 OID 138061)
-- Dependencies: 495 499 4322
-- Name: fk_evaluation_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent_2011_2012.enseignement(id);


--
-- TOC entry 4854 (class 2606 OID 138066)
-- Dependencies: 495 501 4332
-- Name: fk_evaluation_modalite_matiere; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY evaluation
    ADD CONSTRAINT fk_evaluation_modalite_matiere FOREIGN KEY (modalite_matiere_id) REFERENCES ent_2011_2012.modalite_matiere(id);


--
-- TOC entry 4859 (class 2606 OID 138286)
-- Dependencies: 497 512 4364
-- Name: fk_info_calcul_moyennes_classe_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY info_calcul_moyennes_classe
    ADD CONSTRAINT fk_info_calcul_moyennes_classe_structure_enseignement FOREIGN KEY (classe_id) REFERENCES ent_2011_2012.structure_enseignement(id);


--
-- TOC entry 4815 (class 2606 OID 138071)
-- Dependencies: 480 247 3739
-- Name: fk_note_autorite; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- TOC entry 4814 (class 2606 OID 138076)
-- Dependencies: 480 495 4308
-- Name: fk_note_evaluation; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_evaluation FOREIGN KEY (evaluation_id) REFERENCES evaluation(id) ON DELETE CASCADE;


--
-- TOC entry 4813 (class 2606 OID 138081)
-- Dependencies: 480 479 4252
-- Name: fk_note_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY note
    ADD CONSTRAINT fk_note_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- TOC entry 4812 (class 2606 OID 138046)
-- Dependencies: 479 185 3593
-- Name: fk_note_textuelle_annee_scolaire; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY note_textuelle
    ADD CONSTRAINT fk_note_textuelle_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- TOC entry 4811 (class 2606 OID 138051)
-- Dependencies: 479 193 3614
-- Name: fk_note_textuelle_etablissement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY note_textuelle
    ADD CONSTRAINT fk_note_textuelle_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4853 (class 2606 OID 138261)
-- Dependencies: 494 495 4308
-- Name: fk_rel_evaluation_periode_evaluation; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT fk_rel_evaluation_periode_evaluation FOREIGN KEY (evaluation_id) REFERENCES evaluation(id) ON DELETE CASCADE;


--
-- TOC entry 4852 (class 2606 OID 138266)
-- Dependencies: 494 502 4336
-- Name: fk_rel_evaluation_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_evaluation_periode
    ADD CONSTRAINT fk_rel_evaluation_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4818 (class 2606 OID 138086)
-- Dependencies: 481 229 3696
-- Name: fk_resultat_classe_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- TOC entry 4817 (class 2606 OID 138091)
-- Dependencies: 481 502 4336
-- Name: fk_resultat_classe_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4816 (class 2606 OID 138096)
-- Dependencies: 481 512 4364
-- Name: fk_resultat_classe_enseignement_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_enseignement_periode
    ADD CONSTRAINT fk_resultat_classe_enseignement_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent_2011_2012.structure_enseignement(id);


--
-- TOC entry 4820 (class 2606 OID 138101)
-- Dependencies: 482 502 4336
-- Name: fk_resultat_classe_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT fk_resultat_classe_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4819 (class 2606 OID 138106)
-- Dependencies: 482 512 4364
-- Name: fk_resultat_classe_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_periode
    ADD CONSTRAINT fk_resultat_classe_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent_2011_2012.structure_enseignement(id);


--
-- TOC entry 4825 (class 2606 OID 138111)
-- Dependencies: 484 502 4336
-- Name: fk_resultat_classe_service_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4824 (class 2606 OID 138116)
-- Dependencies: 484 510 4358
-- Name: fk_resultat_classe_service_periode_service; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_service FOREIGN KEY (service_id) REFERENCES ent_2011_2012.service(id);


--
-- TOC entry 4823 (class 2606 OID 138121)
-- Dependencies: 484 512 4364
-- Name: fk_resultat_classe_service_periode_structure_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_service_periode
    ADD CONSTRAINT fk_resultat_classe_service_periode_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent_2011_2012.structure_enseignement(id);


--
-- TOC entry 4822 (class 2606 OID 138126)
-- Dependencies: 483 484 4270
-- Name: fk_resultat_classe_sous_service_periode_resultat_classe_service; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT fk_resultat_classe_sous_service_periode_resultat_classe_service FOREIGN KEY (resultat_classe_service_periode_id) REFERENCES resultat_classe_service_periode(id) ON DELETE CASCADE;


--
-- TOC entry 4821 (class 2606 OID 138131)
-- Dependencies: 483 511 4360
-- Name: fk_resultat_classe_sous_service_periode_sous_service; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_classe_sous_service_periode
    ADD CONSTRAINT fk_resultat_classe_sous_service_periode_sous_service FOREIGN KEY (sous_service_id) REFERENCES ent_2011_2012.sous_service(id) ON DELETE CASCADE;


--
-- TOC entry 4829 (class 2606 OID 138136)
-- Dependencies: 485 247 3739
-- Name: fk_resultat_eleve_enseignement_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_autorite FOREIGN KEY (eleve_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4828 (class 2606 OID 138141)
-- Dependencies: 485 499 4322
-- Name: fk_resultat_eleve_enseignement_periode_enseignement; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent_2011_2012.enseignement(id);


--
-- TOC entry 4827 (class 2606 OID 138146)
-- Dependencies: 485 479 4252
-- Name: fk_resultat_eleve_enseignement_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- TOC entry 4826 (class 2606 OID 138151)
-- Dependencies: 485 502 4336
-- Name: fk_resultat_eleve_enseignement_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_enseignement_periode
    ADD CONSTRAINT fk_resultat_eleve_enseignement_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4832 (class 2606 OID 138156)
-- Dependencies: 486 247 3739
-- Name: fk_resultat_eleve_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_autorite FOREIGN KEY (autorite_eleve_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4831 (class 2606 OID 138161)
-- Dependencies: 486 479 4252
-- Name: fk_resultat_eleve_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- TOC entry 4830 (class 2606 OID 138166)
-- Dependencies: 486 502 4336
-- Name: fk_resultat_eleve_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_periode
    ADD CONSTRAINT fk_resultat_eleve_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4839 (class 2606 OID 138171)
-- Dependencies: 488 247 3739
-- Name: fk_resultat_eleve_service_periode_autorite; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_autorite FOREIGN KEY (autorite_eleve_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4838 (class 2606 OID 138176)
-- Dependencies: 488 479 4252
-- Name: fk_resultat_eleve_service_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- TOC entry 4837 (class 2606 OID 138181)
-- Dependencies: 488 502 4336
-- Name: fk_resultat_eleve_service_periode_periode; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_periode FOREIGN KEY (periode_id) REFERENCES ent_2011_2012.periode(id) ON DELETE CASCADE;


--
-- TOC entry 4836 (class 2606 OID 138186)
-- Dependencies: 488 510 4358
-- Name: fk_resultat_eleve_service_periode_service; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_service_periode
    ADD CONSTRAINT fk_resultat_eleve_service_periode_service FOREIGN KEY (service_id) REFERENCES ent_2011_2012.service(id);


--
-- TOC entry 4835 (class 2606 OID 138191)
-- Dependencies: 487 479 4252
-- Name: fk_resultat_eleve_sous_service_periode_note_textuelle; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_note_textuelle FOREIGN KEY (note_textuelle_id) REFERENCES note_textuelle(id);


--
-- TOC entry 4834 (class 2606 OID 138196)
-- Dependencies: 487 488 4286
-- Name: fk_resultat_eleve_sous_service_periode_resultat_eleve_service_p; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_resultat_eleve_service_p FOREIGN KEY (resultat_eleve_service_periode_id) REFERENCES resultat_eleve_service_periode(id) ON DELETE CASCADE;


--
-- TOC entry 4833 (class 2606 OID 138201)
-- Dependencies: 487 511 4360
-- Name: fk_resultat_eleve_sous_service_periode_sous_service; Type: FK CONSTRAINT; Schema: entnotes_2011_2012; Owner: -
--

ALTER TABLE ONLY resultat_eleve_sous_service_periode
    ADD CONSTRAINT fk_resultat_eleve_sous_service_periode_sous_service FOREIGN KEY (sous_service_id) REFERENCES ent_2011_2012.sous_service(id) ON DELETE CASCADE;


SET search_path = enttemps, pg_catalog;

--
-- TOC entry 4610 (class 2606 OID 136299)
-- Dependencies: 3614 317 193
-- Name: fk_absence_journee_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT fk_absence_journee_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4609 (class 2606 OID 137006)
-- Dependencies: 317 347 3966
-- Name: fk_absence_journee_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT fk_absence_journee_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4612 (class 2606 OID 136304)
-- Dependencies: 319 3739 247
-- Name: fk_agenda_autorite; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_autorite FOREIGN KEY (enseignant_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- TOC entry 4611 (class 2606 OID 136309)
-- Dependencies: 3614 319 193
-- Name: fk_agenda_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id) ON DELETE CASCADE;


--
-- TOC entry 4615 (class 2606 OID 133909)
-- Dependencies: 408 319 4100
-- Name: fk_agenda_item; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_item FOREIGN KEY (item_id) REFERENCES securite.item(id);


--
-- TOC entry 4614 (class 2606 OID 133914)
-- Dependencies: 3729 243 319
-- Name: fk_agenda_structure_enseignement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- TOC entry 4613 (class 2606 OID 133919)
-- Dependencies: 319 371 4014
-- Name: fk_agenda_type_agenda; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_type_agenda FOREIGN KEY (type_agenda_id) REFERENCES type_agenda(id);


--
-- TOC entry 4618 (class 2606 OID 136314)
-- Dependencies: 3739 247 321
-- Name: fk_appel_autorite_appelant; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_autorite_appelant FOREIGN KEY (appelant_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4617 (class 2606 OID 136319)
-- Dependencies: 3739 321 247
-- Name: fk_appel_autorite_operateur_saisie; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_autorite_operateur_saisie FOREIGN KEY (operateur_saisie_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4619 (class 2606 OID 133929)
-- Dependencies: 3936 321 331
-- Name: fk_appel_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id);


--
-- TOC entry 4623 (class 2606 OID 136279)
-- Dependencies: 317 323 3900
-- Name: fk_appel_ligne_absence_journee; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_absence_journee FOREIGN KEY (absence_journee_id) REFERENCES absence_journee(id) ON DELETE CASCADE;


--
-- TOC entry 4625 (class 2606 OID 133934)
-- Dependencies: 321 323 3912
-- Name: fk_appel_ligne_appel; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_appel FOREIGN KEY (appel_id) REFERENCES appel(id) ON DELETE CASCADE;


--
-- TOC entry 4620 (class 2606 OID 136602)
-- Dependencies: 247 3739 323
-- Name: fk_appel_ligne_autorite_eleve; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_autorite_eleve FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4622 (class 2606 OID 136284)
-- Dependencies: 3739 247 323
-- Name: fk_appel_ligne_autorite_operateur_saisie; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_autorite_operateur_saisie FOREIGN KEY (operateur_saisie_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4624 (class 2606 OID 133939)
-- Dependencies: 339 323 3949
-- Name: fk_appel_ligne_motif; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_motif FOREIGN KEY (motif_id) REFERENCES motif(id);


--
-- TOC entry 4621 (class 2606 OID 136324)
-- Dependencies: 4012 369 323
-- Name: fk_appel_ligne_sanction; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_sanction FOREIGN KEY (sanction_id) REFERENCES sanction(id);


--
-- TOC entry 4626 (class 2606 OID 136329)
-- Dependencies: 325 321 3912
-- Name: fk_appel_plage_horaire_appel; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT fk_appel_plage_horaire_appel FOREIGN KEY (appel_id) REFERENCES appel(id) ON DELETE CASCADE;


--
-- TOC entry 4627 (class 2606 OID 136294)
-- Dependencies: 345 3964 325
-- Name: fk_appel_plage_horaire_plage_horaire; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT fk_appel_plage_horaire_plage_horaire FOREIGN KEY (plage_horaire_id) REFERENCES plage_horaire(id) ON DELETE CASCADE;


--
-- TOC entry 4616 (class 2606 OID 137031)
-- Dependencies: 321 347 3966
-- Name: fk_appel_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4630 (class 2606 OID 136349)
-- Dependencies: 3936 331 328
-- Name: fk_date_exclue_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY date_exclue
    ADD CONSTRAINT fk_date_exclue_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- TOC entry 4633 (class 2606 OID 136334)
-- Dependencies: 3908 319 331
-- Name: fk_evenement_agenda; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_agenda FOREIGN KEY (agenda_maitre_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- TOC entry 4632 (class 2606 OID 136339)
-- Dependencies: 247 331 3739
-- Name: fk_evenement_autorite; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_autorite FOREIGN KEY (auteur_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4634 (class 2606 OID 135938)
-- Dependencies: 229 331 3696
-- Name: fk_evenement_enseignement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent.enseignement(id);


--
-- TOC entry 4631 (class 2606 OID 136344)
-- Dependencies: 4018 331 373
-- Name: fk_evenement_type_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_type_evenement FOREIGN KEY (type_id) REFERENCES type_evenement(id);


--
-- TOC entry 4635 (class 2606 OID 135654)
-- Dependencies: 347 333 3966
-- Name: fk_groupe_motif_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT fk_groupe_motif_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4639 (class 2606 OID 136379)
-- Dependencies: 335 3614 193
-- Name: fk_incident_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4638 (class 2606 OID 136384)
-- Dependencies: 337 335 3945
-- Name: fk_incident_lieu_incident; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_lieu_incident FOREIGN KEY (lieu_id) REFERENCES lieu_incident(id);


--
-- TOC entry 4636 (class 2606 OID 137016)
-- Dependencies: 335 347 3966
-- Name: fk_incident_preference_etablissement_abscences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_preference_etablissement_abscences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4637 (class 2606 OID 136389)
-- Dependencies: 4023 375 335
-- Name: fk_incident_type_incident; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_type_incident FOREIGN KEY (type_id) REFERENCES type_incident(id);


--
-- TOC entry 4640 (class 2606 OID 135659)
-- Dependencies: 3966 347 337
-- Name: fk_lieu_incident_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT fk_lieu_incident_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4641 (class 2606 OID 136394)
-- Dependencies: 339 333 3938
-- Name: fk_motif_groupe_motif; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT fk_motif_groupe_motif FOREIGN KEY (groupe_motif_id) REFERENCES groupe_motif(id) ON DELETE CASCADE;


--
-- TOC entry 4643 (class 2606 OID 136399)
-- Dependencies: 3942 335 342
-- Name: fk_partenaire_a_prevenir_incident_incident; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT fk_partenaire_a_prevenir_incident_incident FOREIGN KEY (incident_id) REFERENCES incident(id) ON DELETE CASCADE;


--
-- TOC entry 4644 (class 2606 OID 135903)
-- Dependencies: 341 342 3954
-- Name: fk_partenaire_a_prevenir_incident_partenaire_a_prevenir; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT fk_partenaire_a_prevenir_incident_partenaire_a_prevenir FOREIGN KEY (partenaire_a_prevenir_id) REFERENCES partenaire_a_prevenir(id);


--
-- TOC entry 4642 (class 2606 OID 135664)
-- Dependencies: 3966 347 341
-- Name: fk_partenaire_a_prevenir_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT fk_partenaire_a_prevenir_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4645 (class 2606 OID 135669)
-- Dependencies: 347 3966 345
-- Name: fk_plage_horaire_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY plage_horaire
    ADD CONSTRAINT fk_plage_horaire_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id) ON DELETE CASCADE;


--
-- TOC entry 4646 (class 2606 OID 137001)
-- Dependencies: 3593 347 185
-- Name: fk_preference_etablissement_absences_annee_scolaire; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- TOC entry 4648 (class 2606 OID 134069)
-- Dependencies: 347 193 3614
-- Name: fk_preference_etablissement_absences_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4647 (class 2606 OID 135694)
-- Dependencies: 347 4100 408
-- Name: fk_preference_etablissement_absences_item; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_item FOREIGN KEY (param_item_id) REFERENCES securite.item(id);


--
-- TOC entry 4650 (class 2606 OID 135703)
-- Dependencies: 349 319 3908
-- Name: fk_preference_utilisateur_agenda_agenda; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY preference_utilisateur_agenda
    ADD CONSTRAINT fk_preference_utilisateur_agenda_agenda FOREIGN KEY (agenda_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- TOC entry 4649 (class 2606 OID 135708)
-- Dependencies: 3739 349 247
-- Name: fk_preference_utilisateur_agenda_autorite; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY preference_utilisateur_agenda
    ADD CONSTRAINT fk_preference_utilisateur_agenda_autorite FOREIGN KEY (utilisateur_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- TOC entry 4653 (class 2606 OID 136404)
-- Dependencies: 247 351 3739
-- Name: fk_protagoniste_incident_autorite; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4652 (class 2606 OID 136409)
-- Dependencies: 335 351 3942
-- Name: fk_protagoniste_incident_incident; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_incident FOREIGN KEY (incident_id) REFERENCES incident(id) ON DELETE CASCADE;


--
-- TOC entry 4651 (class 2606 OID 136414)
-- Dependencies: 351 3986 355
-- Name: fk_protagoniste_incident_qualite_protagoniste; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_qualite_protagoniste FOREIGN KEY (qualite_id) REFERENCES qualite_protagoniste(id);


--
-- TOC entry 4657 (class 2606 OID 136429)
-- Dependencies: 353 3614 193
-- Name: fk_punition_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4656 (class 2606 OID 136434)
-- Dependencies: 335 3942 353
-- Name: fk_punition_incident; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_incident FOREIGN KEY (incident_id) REFERENCES incident(id);


--
-- TOC entry 4659 (class 2606 OID 136419)
-- Dependencies: 3660 214 353
-- Name: fk_punition_personne_censeur; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_personne_censeur FOREIGN KEY (censeur_id) REFERENCES ent.personne(id);


--
-- TOC entry 4658 (class 2606 OID 136424)
-- Dependencies: 3660 353 214
-- Name: fk_punition_personne_eleve; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_personne_eleve FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- TOC entry 4654 (class 2606 OID 137021)
-- Dependencies: 347 3966 353
-- Name: fk_punition_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4655 (class 2606 OID 136439)
-- Dependencies: 4028 353 377
-- Name: fk_punition_type_punition; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_type_punition FOREIGN KEY (type_punition_id) REFERENCES type_punition(id);


--
-- TOC entry 4660 (class 2606 OID 135674)
-- Dependencies: 347 3966 355
-- Name: fk_qualite_protagoniste_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT fk_qualite_protagoniste_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4662 (class 2606 OID 134134)
-- Dependencies: 357 319 3908
-- Name: fk_rel_agenda_evenement_agenda; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT fk_rel_agenda_evenement_agenda FOREIGN KEY (agenda_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- TOC entry 4661 (class 2606 OID 134139)
-- Dependencies: 3936 357 331
-- Name: fk_rel_agenda_evenement_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT fk_rel_agenda_evenement_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- TOC entry 4663 (class 2606 OID 136354)
-- Dependencies: 359 3936 331
-- Name: fk_repeter_jour_annee_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY repeter_jour_annee
    ADD CONSTRAINT fk_repeter_jour_annee_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- TOC entry 4664 (class 2606 OID 136359)
-- Dependencies: 3936 331 361
-- Name: fk_repeter_jour_mois_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY repeter_jour_mois
    ADD CONSTRAINT fk_repeter_jour_mois_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- TOC entry 4665 (class 2606 OID 136364)
-- Dependencies: 363 3936 331
-- Name: fk_repeter_jour_semaine_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY repeter_jour_semaine
    ADD CONSTRAINT fk_repeter_jour_semaine_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- TOC entry 4666 (class 2606 OID 136369)
-- Dependencies: 3936 331 365
-- Name: fk_repeter_mois_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY repeter_mois
    ADD CONSTRAINT fk_repeter_mois_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- TOC entry 4667 (class 2606 OID 136374)
-- Dependencies: 331 3936 367
-- Name: fk_repeter_semaine_annee_evenement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY repeter_semaine_annee
    ADD CONSTRAINT fk_repeter_semaine_annee_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- TOC entry 4672 (class 2606 OID 136454)
-- Dependencies: 369 3614 193
-- Name: fk_sanction_etablissement; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4671 (class 2606 OID 136459)
-- Dependencies: 335 3942 369
-- Name: fk_sanction_incident; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_incident FOREIGN KEY (incident_id) REFERENCES incident(id);


--
-- TOC entry 4669 (class 2606 OID 136469)
-- Dependencies: 339 369 3949
-- Name: fk_sanction_motif; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_motif FOREIGN KEY (motif_id) REFERENCES motif(id);


--
-- TOC entry 4674 (class 2606 OID 136444)
-- Dependencies: 369 3660 214
-- Name: fk_sanction_personne_censeur; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_personne_censeur FOREIGN KEY (censeur_id) REFERENCES ent.personne(id);


--
-- TOC entry 4673 (class 2606 OID 136449)
-- Dependencies: 369 3660 214
-- Name: fk_sanction_personne_eleve; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_personne_eleve FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- TOC entry 4668 (class 2606 OID 137026)
-- Dependencies: 3966 369 347
-- Name: fk_sanction_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4670 (class 2606 OID 136464)
-- Dependencies: 379 4033 369
-- Name: fk_sanction_type_sanction; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_type_sanction FOREIGN KEY (type_sanction_id) REFERENCES type_sanction(id);


--
-- TOC entry 4675 (class 2606 OID 135679)
-- Dependencies: 347 375 3966
-- Name: fk_type_incident_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT fk_type_incident_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4676 (class 2606 OID 135684)
-- Dependencies: 377 3966 347
-- Name: fk_type_punition_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT fk_type_punition_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4677 (class 2606 OID 135689)
-- Dependencies: 347 379 3966
-- Name: fk_type_sanction_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps; Owner: -
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT fk_type_sanction_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


SET search_path = enttemps_2011_2012, pg_catalog;

--
-- TOC entry 4763 (class 2606 OID 137756)
-- Dependencies: 465 3614 193
-- Name: fk_absence_journee_etablissement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT fk_absence_journee_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4762 (class 2606 OID 137761)
-- Dependencies: 453 465 4164
-- Name: fk_absence_journee_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY absence_journee
    ADD CONSTRAINT fk_absence_journee_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4794 (class 2606 OID 137936)
-- Dependencies: 247 473 3739
-- Name: fk_agenda_autorite; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_autorite FOREIGN KEY (enseignant_id) REFERENCES securite.autorite(id) ON DELETE CASCADE;


--
-- TOC entry 4793 (class 2606 OID 137941)
-- Dependencies: 473 193 3614
-- Name: fk_agenda_etablissement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id) ON DELETE CASCADE;


--
-- TOC entry 4792 (class 2606 OID 137946)
-- Dependencies: 408 473 4100
-- Name: fk_agenda_item; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_item FOREIGN KEY (item_id) REFERENCES securite.item(id);


--
-- TOC entry 4791 (class 2606 OID 137951)
-- Dependencies: 4364 512 473
-- Name: fk_agenda_structure_enseignement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent_2011_2012.structure_enseignement(id);


--
-- TOC entry 4790 (class 2606 OID 137956)
-- Dependencies: 371 4014 473
-- Name: fk_agenda_type_agenda; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT fk_agenda_type_agenda FOREIGN KEY (type_agenda_id) REFERENCES enttemps.type_agenda(id);


--
-- TOC entry 4760 (class 2606 OID 137746)
-- Dependencies: 464 3739 247
-- Name: fk_appel_autorite_appelant; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_autorite_appelant FOREIGN KEY (appelant_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4759 (class 2606 OID 137751)
-- Dependencies: 247 3739 464
-- Name: fk_appel_autorite_operateur_saisie; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_autorite_operateur_saisie FOREIGN KEY (operateur_saisie_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4758 (class 2606 OID 137991)
-- Dependencies: 464 474 4234
-- Name: fk_appel_evenement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id);


--
-- TOC entry 4789 (class 2606 OID 137711)
-- Dependencies: 471 465 4208
-- Name: fk_appel_ligne_absence_journee; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_absence_journee FOREIGN KEY (absence_journee_id) REFERENCES absence_journee(id) ON DELETE CASCADE;


--
-- TOC entry 4788 (class 2606 OID 137716)
-- Dependencies: 4204 471 464
-- Name: fk_appel_ligne_appel; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_appel FOREIGN KEY (appel_id) REFERENCES appel(id) ON DELETE CASCADE;


--
-- TOC entry 4787 (class 2606 OID 137721)
-- Dependencies: 247 3739 471
-- Name: fk_appel_ligne_autorite_eleve; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_autorite_eleve FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4786 (class 2606 OID 137726)
-- Dependencies: 3739 471 247
-- Name: fk_appel_ligne_autorite_operateur_saisie; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_autorite_operateur_saisie FOREIGN KEY (operateur_saisie_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4785 (class 2606 OID 137731)
-- Dependencies: 4186 459 471
-- Name: fk_appel_ligne_motif; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_motif FOREIGN KEY (motif_id) REFERENCES motif(id);


--
-- TOC entry 4784 (class 2606 OID 137736)
-- Dependencies: 466 471 4212
-- Name: fk_appel_ligne_sanction; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_ligne
    ADD CONSTRAINT fk_appel_ligne_sanction FOREIGN KEY (sanction_id) REFERENCES sanction(id);


--
-- TOC entry 4783 (class 2606 OID 137701)
-- Dependencies: 470 4204 464
-- Name: fk_appel_plage_horaire_appel; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT fk_appel_plage_horaire_appel FOREIGN KEY (appel_id) REFERENCES appel(id) ON DELETE CASCADE;


--
-- TOC entry 4782 (class 2606 OID 137706)
-- Dependencies: 4168 470 454
-- Name: fk_appel_plage_horaire_plage_horaire; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel_plage_horaire
    ADD CONSTRAINT fk_appel_plage_horaire_plage_horaire FOREIGN KEY (plage_horaire_id) REFERENCES plage_horaire(id) ON DELETE CASCADE;


--
-- TOC entry 4761 (class 2606 OID 137741)
-- Dependencies: 453 4164 464
-- Name: fk_appel_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY appel
    ADD CONSTRAINT fk_appel_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4798 (class 2606 OID 137961)
-- Dependencies: 474 4232 473
-- Name: fk_evenement_agenda; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_agenda FOREIGN KEY (agenda_maitre_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- TOC entry 4797 (class 2606 OID 137966)
-- Dependencies: 474 247 3739
-- Name: fk_evenement_autorite; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_autorite FOREIGN KEY (auteur_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4796 (class 2606 OID 137971)
-- Dependencies: 474 499 4322
-- Name: fk_evenement_enseignement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_enseignement FOREIGN KEY (enseignement_id) REFERENCES ent_2011_2012.enseignement(id);


--
-- TOC entry 4795 (class 2606 OID 137976)
-- Dependencies: 474 373 4018
-- Name: fk_evenement_type_evenement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_type_evenement FOREIGN KEY (type_id) REFERENCES enttemps.type_evenement(id);


--
-- TOC entry 4746 (class 2606 OID 137901)
-- Dependencies: 455 453 4164
-- Name: fk_groupe_motif_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY groupe_motif
    ADD CONSTRAINT fk_groupe_motif_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4755 (class 2606 OID 137866)
-- Dependencies: 461 3614 193
-- Name: fk_incident_etablissement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4754 (class 2606 OID 137871)
-- Dependencies: 457 461 4178
-- Name: fk_incident_lieu_incident; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_lieu_incident FOREIGN KEY (lieu_id) REFERENCES lieu_incident(id);


--
-- TOC entry 4753 (class 2606 OID 137876)
-- Dependencies: 461 4164 453
-- Name: fk_incident_preference_etablissement_abscences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_preference_etablissement_abscences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4752 (class 2606 OID 137881)
-- Dependencies: 4174 461 456
-- Name: fk_incident_type_incident; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY incident
    ADD CONSTRAINT fk_incident_type_incident FOREIGN KEY (type_id) REFERENCES type_incident(id);


--
-- TOC entry 4748 (class 2606 OID 137911)
-- Dependencies: 453 457 4164
-- Name: fk_lieu_incident_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY lieu_incident
    ADD CONSTRAINT fk_lieu_incident_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4750 (class 2606 OID 137856)
-- Dependencies: 459 4170 455
-- Name: fk_motif_groupe_motif; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY motif
    ADD CONSTRAINT fk_motif_groupe_motif FOREIGN KEY (groupe_motif_id) REFERENCES groupe_motif(id) ON DELETE CASCADE;


--
-- TOC entry 4775 (class 2606 OID 137816)
-- Dependencies: 468 4194 461
-- Name: fk_partenaire_a_prevenir_incident_incident; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT fk_partenaire_a_prevenir_incident_incident FOREIGN KEY (incident_id) REFERENCES incident(id) ON DELETE CASCADE;


--
-- TOC entry 4774 (class 2606 OID 137821)
-- Dependencies: 468 4196 462
-- Name: fk_partenaire_a_prevenir_incident_partenaire_a_prevenir; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY partenaire_a_prevenir_incident
    ADD CONSTRAINT fk_partenaire_a_prevenir_incident_partenaire_a_prevenir FOREIGN KEY (partenaire_a_prevenir_id) REFERENCES partenaire_a_prevenir(id);


--
-- TOC entry 4756 (class 2606 OID 137886)
-- Dependencies: 462 453 4164
-- Name: fk_partenaire_a_prevenir_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY partenaire_a_prevenir
    ADD CONSTRAINT fk_partenaire_a_prevenir_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4745 (class 2606 OID 137896)
-- Dependencies: 4164 453 454
-- Name: fk_plage_horaire_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY plage_horaire
    ADD CONSTRAINT fk_plage_horaire_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id) ON DELETE CASCADE;


--
-- TOC entry 4744 (class 2606 OID 137921)
-- Dependencies: 185 453 3593
-- Name: fk_preference_etablissement_absences_annee_scolaire; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_annee_scolaire FOREIGN KEY (annee_scolaire_id) REFERENCES ent.annee_scolaire(id);


--
-- TOC entry 4743 (class 2606 OID 137926)
-- Dependencies: 3614 453 193
-- Name: fk_preference_etablissement_absences_etablissement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4742 (class 2606 OID 137931)
-- Dependencies: 408 4100 453
-- Name: fk_preference_etablissement_absences_item; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY preference_etablissement_absences
    ADD CONSTRAINT fk_preference_etablissement_absences_item FOREIGN KEY (param_item_id) REFERENCES securite.item(id);


--
-- TOC entry 4773 (class 2606 OID 137801)
-- Dependencies: 467 3739 247
-- Name: fk_protagoniste_incident_autorite; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4772 (class 2606 OID 137806)
-- Dependencies: 4194 461 467
-- Name: fk_protagoniste_incident_incident; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_incident FOREIGN KEY (incident_id) REFERENCES incident(id) ON DELETE CASCADE;


--
-- TOC entry 4771 (class 2606 OID 137811)
-- Dependencies: 4182 458 467
-- Name: fk_protagoniste_incident_qualite_protagoniste; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY protagoniste_incident
    ADD CONSTRAINT fk_protagoniste_incident_qualite_protagoniste FOREIGN KEY (qualite_id) REFERENCES qualite_protagoniste(id);


--
-- TOC entry 4781 (class 2606 OID 137826)
-- Dependencies: 3614 469 193
-- Name: fk_punition_etablissement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4780 (class 2606 OID 137831)
-- Dependencies: 461 469 4194
-- Name: fk_punition_incident; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_incident FOREIGN KEY (incident_id) REFERENCES incident(id);


--
-- TOC entry 4779 (class 2606 OID 137836)
-- Dependencies: 3660 214 469
-- Name: fk_punition_personne_censeur; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_personne_censeur FOREIGN KEY (censeur_id) REFERENCES ent.personne(id);


--
-- TOC entry 4778 (class 2606 OID 137841)
-- Dependencies: 469 214 3660
-- Name: fk_punition_personne_eleve; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_personne_eleve FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- TOC entry 4777 (class 2606 OID 137846)
-- Dependencies: 4164 453 469
-- Name: fk_punition_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4776 (class 2606 OID 137851)
-- Dependencies: 469 4200 463
-- Name: fk_punition_type_punition; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY punition
    ADD CONSTRAINT fk_punition_type_punition FOREIGN KEY (type_punition_id) REFERENCES type_punition(id);


--
-- TOC entry 4749 (class 2606 OID 137916)
-- Dependencies: 453 4164 458
-- Name: fk_qualite_protagoniste_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY qualite_protagoniste
    ADD CONSTRAINT fk_qualite_protagoniste_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4800 (class 2606 OID 137981)
-- Dependencies: 475 473 4232
-- Name: fk_rel_agenda_evenement_agenda; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT fk_rel_agenda_evenement_agenda FOREIGN KEY (agenda_id) REFERENCES agenda(id) ON DELETE CASCADE;


--
-- TOC entry 4799 (class 2606 OID 137986)
-- Dependencies: 475 474 4234
-- Name: fk_rel_agenda_evenement_evenement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY rel_agenda_evenement
    ADD CONSTRAINT fk_rel_agenda_evenement_evenement FOREIGN KEY (evenement_id) REFERENCES evenement(id) ON DELETE CASCADE;


--
-- TOC entry 4770 (class 2606 OID 137766)
-- Dependencies: 466 193 3614
-- Name: fk_sanction_etablissement; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4769 (class 2606 OID 137771)
-- Dependencies: 461 466 4194
-- Name: fk_sanction_incident; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_incident FOREIGN KEY (incident_id) REFERENCES incident(id);


--
-- TOC entry 4768 (class 2606 OID 137776)
-- Dependencies: 4186 459 466
-- Name: fk_sanction_motif; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_motif FOREIGN KEY (motif_id) REFERENCES motif(id);


--
-- TOC entry 4767 (class 2606 OID 137781)
-- Dependencies: 466 3660 214
-- Name: fk_sanction_personne_censeur; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_personne_censeur FOREIGN KEY (censeur_id) REFERENCES ent.personne(id);


--
-- TOC entry 4766 (class 2606 OID 137786)
-- Dependencies: 3660 466 214
-- Name: fk_sanction_personne_eleve; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_personne_eleve FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- TOC entry 4765 (class 2606 OID 137791)
-- Dependencies: 4164 466 453
-- Name: fk_sanction_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4764 (class 2606 OID 137796)
-- Dependencies: 4190 460 466
-- Name: fk_sanction_type_sanction; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY sanction
    ADD CONSTRAINT fk_sanction_type_sanction FOREIGN KEY (type_sanction_id) REFERENCES type_sanction(id);


--
-- TOC entry 4747 (class 2606 OID 137906)
-- Dependencies: 453 456 4164
-- Name: fk_type_incident_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY type_incident
    ADD CONSTRAINT fk_type_incident_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4757 (class 2606 OID 137891)
-- Dependencies: 463 4164 453
-- Name: fk_type_punition_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY type_punition
    ADD CONSTRAINT fk_type_punition_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


--
-- TOC entry 4751 (class 2606 OID 137861)
-- Dependencies: 4164 453 460
-- Name: fk_type_sanction_preference_etablissement_absences; Type: FK CONSTRAINT; Schema: enttemps_2011_2012; Owner: -
--

ALTER TABLE ONLY type_sanction
    ADD CONSTRAINT fk_type_sanction_preference_etablissement_absences FOREIGN KEY (preference_etablissement_absences_id) REFERENCES preference_etablissement_absences(id);


SET search_path = forum, pg_catalog;

--
-- TOC entry 4680 (class 2606 OID 136489)
-- Dependencies: 247 3739 381
-- Name: fk_commentaire_autorite; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY commentaire
    ADD CONSTRAINT fk_commentaire_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4679 (class 2606 OID 136494)
-- Dependencies: 384 381 4043
-- Name: fk_commentaire_discussion; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY commentaire
    ADD CONSTRAINT fk_commentaire_discussion FOREIGN KEY (discussion_id) REFERENCES discussion(id) ON DELETE CASCADE;


--
-- TOC entry 4678 (class 2606 OID 136499)
-- Dependencies: 4045 381 386
-- Name: fk_commentaire_etat_commentaire; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY commentaire
    ADD CONSTRAINT fk_commentaire_etat_commentaire FOREIGN KEY (code_etat_commentaire) REFERENCES etat_commentaire(code);


--
-- TOC entry 4682 (class 2606 OID 136479)
-- Dependencies: 247 3739 383
-- Name: fk_commentaire_lu_autorite; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY commentaire_lu
    ADD CONSTRAINT fk_commentaire_lu_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4681 (class 2606 OID 136484)
-- Dependencies: 381 383 4038
-- Name: fk_commentaire_lu_commentaire; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY commentaire_lu
    ADD CONSTRAINT fk_commentaire_lu_commentaire FOREIGN KEY (commentaire_id) REFERENCES commentaire(id) ON DELETE CASCADE;


--
-- TOC entry 4685 (class 2606 OID 136504)
-- Dependencies: 3739 384 247
-- Name: fk_discussion_autorite; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT fk_discussion_autorite FOREIGN KEY (autorite_id) REFERENCES securite.autorite(id);


--
-- TOC entry 4684 (class 2606 OID 136509)
-- Dependencies: 4047 384 387
-- Name: fk_discussion_etat_discussion; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT fk_discussion_etat_discussion FOREIGN KEY (code_etat_discussion) REFERENCES etat_discussion(code);


--
-- TOC entry 4686 (class 2606 OID 136474)
-- Dependencies: 408 4100 384
-- Name: fk_discussion_item; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT fk_discussion_item FOREIGN KEY (item_cible_id) REFERENCES securite.item(id) ON DELETE CASCADE;


--
-- TOC entry 4683 (class 2606 OID 136514)
-- Dependencies: 388 4049 384
-- Name: fk_discussion_type_moderation; Type: FK CONSTRAINT; Schema: forum; Owner: -
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT fk_discussion_type_moderation FOREIGN KEY (code_type_moderation) REFERENCES type_moderation(code);


SET search_path = impression, pg_catalog;

--
-- TOC entry 4693 (class 2606 OID 136524)
-- Dependencies: 3614 389 193
-- Name: fk_publipostage_suivi_etablissement; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4692 (class 2606 OID 136529)
-- Dependencies: 3660 214 389
-- Name: fk_publipostage_suivi_personne_operateur; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_personne_operateur FOREIGN KEY (operateur_id) REFERENCES ent.personne(id);


--
-- TOC entry 4691 (class 2606 OID 136534)
-- Dependencies: 3660 389 214
-- Name: fk_publipostage_suivi_personne_personne; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_personne_personne FOREIGN KEY (personne_id) REFERENCES ent.personne(id);


--
-- TOC entry 4688 (class 2606 OID 136908)
-- Dependencies: 389 3660 214
-- Name: fk_publipostage_suivi_responsable; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_responsable FOREIGN KEY (responsable_id) REFERENCES ent.personne(id);


--
-- TOC entry 4687 (class 2606 OID 136942)
-- Dependencies: 4148 389 439
-- Name: fk_publipostage_suivi_sms_fournisseur_etablissement; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_sms_fournisseur_etablissement FOREIGN KEY (sms_fournisseur_etablissement_id) REFERENCES sms_fournisseur_etablissement(id);


--
-- TOC entry 4694 (class 2606 OID 136519)
-- Dependencies: 3729 389 243
-- Name: fk_publipostage_suivi_structure_enseignement; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_structure_enseignement FOREIGN KEY (classe_id) REFERENCES ent.structure_enseignement(id);


--
-- TOC entry 4690 (class 2606 OID 136539)
-- Dependencies: 393 4062 389
-- Name: fk_publipostage_suivi_template_document; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_template_document FOREIGN KEY (template_document_id) REFERENCES template_document(id) ON DELETE SET NULL;


--
-- TOC entry 4689 (class 2606 OID 136544)
-- Dependencies: 403 4087 389
-- Name: fk_publipostage_suivi_template_type_fonctionnalite; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY publipostage_suivi
    ADD CONSTRAINT fk_publipostage_suivi_template_type_fonctionnalite FOREIGN KEY (type_fonctionnalite_id) REFERENCES template_type_fonctionnalite(id);


--
-- TOC entry 4727 (class 2606 OID 136932)
-- Dependencies: 437 439 4146
-- Name: fk_sms_fournisseur_etablissement_sms_fournisseur; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY sms_fournisseur_etablissement
    ADD CONSTRAINT fk_sms_fournisseur_etablissement_sms_fournisseur FOREIGN KEY (sms_fournisseur_id) REFERENCES sms_fournisseur(id);


--
-- TOC entry 4695 (class 2606 OID 136549)
-- Dependencies: 391 4062 393
-- Name: fk_template_champ_memo_template_document; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_champ_memo
    ADD CONSTRAINT fk_template_champ_memo_template_document FOREIGN KEY (template_document_id) REFERENCES template_document(id);


--
-- TOC entry 4697 (class 2606 OID 136564)
-- Dependencies: 3614 393 193
-- Name: fk_template_document_etablissement; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_document
    ADD CONSTRAINT fk_template_document_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4699 (class 2606 OID 136554)
-- Dependencies: 393 395 4062
-- Name: fk_template_document_sous_template_eliot_template_document; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_document_sous_template_eliot
    ADD CONSTRAINT fk_template_document_sous_template_eliot_template_document FOREIGN KEY (template_document_id) REFERENCES template_document(id);


--
-- TOC entry 4698 (class 2606 OID 136559)
-- Dependencies: 397 4074 395
-- Name: fk_template_document_sous_template_eliot_template_eliot; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_document_sous_template_eliot
    ADD CONSTRAINT fk_template_document_sous_template_eliot_template_eliot FOREIGN KEY (template_eliot_id) REFERENCES template_eliot(id);


--
-- TOC entry 4696 (class 2606 OID 136569)
-- Dependencies: 397 4074 393
-- Name: fk_template_document_template_eliot; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_document
    ADD CONSTRAINT fk_template_document_template_eliot FOREIGN KEY (template_eliot_id) REFERENCES template_eliot(id);


--
-- TOC entry 4702 (class 2606 OID 136574)
-- Dependencies: 397 399 4079
-- Name: fk_template_eliot_template_jasper; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT fk_template_eliot_template_jasper FOREIGN KEY (template_jasper_id) REFERENCES template_jasper(id);


--
-- TOC entry 4701 (class 2606 OID 136579)
-- Dependencies: 397 401 4081
-- Name: fk_template_eliot_template_type_donnees; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT fk_template_eliot_template_type_donnees FOREIGN KEY (type_donnees_id) REFERENCES template_type_donnees(id);


--
-- TOC entry 4700 (class 2606 OID 136584)
-- Dependencies: 4087 397 403
-- Name: fk_template_eliot_template_type_fonctionnalite; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_eliot
    ADD CONSTRAINT fk_template_eliot_template_type_fonctionnalite FOREIGN KEY (type_fonctionnalite_id) REFERENCES template_type_fonctionnalite(id);


--
-- TOC entry 4703 (class 2606 OID 136589)
-- Dependencies: 4079 399 399
-- Name: fk_template_jasper_template_jasper; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_jasper
    ADD CONSTRAINT fk_template_jasper_template_jasper FOREIGN KEY (sous_template_id) REFERENCES template_jasper(id);


--
-- TOC entry 4704 (class 2606 OID 136594)
-- Dependencies: 4087 403 403
-- Name: fk_template_type_fonctionnalite_template_type_fonctionnalite; Type: FK CONSTRAINT; Schema: impression; Owner: -
--

ALTER TABLE ONLY template_type_fonctionnalite
    ADD CONSTRAINT fk_template_type_fonctionnalite_template_type_fonctionnalite FOREIGN KEY (parent_id) REFERENCES template_type_fonctionnalite(id);


SET search_path = securite, pg_catalog;

--
-- TOC entry 4705 (class 2606 OID 134423)
-- Dependencies: 407 4095 407
-- Name: fk_autorisation_autorisation; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT fk_autorisation_autorisation FOREIGN KEY (autorisation_heritee_id) REFERENCES autorisation(id) ON DELETE CASCADE;


--
-- TOC entry 4706 (class 2606 OID 134385)
-- Dependencies: 407 3739 247
-- Name: fk_autorisation_autorite; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT fk_autorisation_autorite FOREIGN KEY (autorite_id) REFERENCES autorite(id) ON DELETE CASCADE;


--
-- TOC entry 4707 (class 2606 OID 134371)
-- Dependencies: 407 4100 408
-- Name: fk_autorisation_item; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY autorisation
    ADD CONSTRAINT fk_autorisation_item FOREIGN KEY (item_id) REFERENCES item(id);


--
-- TOC entry 4522 (class 2606 OID 134334)
-- Dependencies: 179 247 3585
-- Name: fk_autorite_import; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY autorite
    ADD CONSTRAINT fk_autorite_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- TOC entry 4709 (class 2606 OID 134339)
-- Dependencies: 179 3585 408
-- Name: fk_item_import; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY item
    ADD CONSTRAINT fk_item_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- TOC entry 4708 (class 2606 OID 134428)
-- Dependencies: 408 4100 408
-- Name: fk_item_item; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY item
    ADD CONSTRAINT fk_item_item FOREIGN KEY (item_parent_id) REFERENCES item(id);


--
-- TOC entry 4711 (class 2606 OID 134349)
-- Dependencies: 179 409 3585
-- Name: fk_perimetre_import; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY perimetre
    ADD CONSTRAINT fk_perimetre_import FOREIGN KEY (import_id) REFERENCES aaf.import(id);


--
-- TOC entry 4710 (class 2606 OID 134433)
-- Dependencies: 4105 409 409
-- Name: fk_perimetre_perimetre; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY perimetre
    ADD CONSTRAINT fk_perimetre_perimetre FOREIGN KEY (perimetre_parent_id) REFERENCES perimetre(id);


--
-- TOC entry 4713 (class 2606 OID 134359)
-- Dependencies: 4100 410 408
-- Name: fk_perimetre_securite_item; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY perimetre_securite
    ADD CONSTRAINT fk_perimetre_securite_item FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE;


--
-- TOC entry 4712 (class 2606 OID 134364)
-- Dependencies: 410 4105 409
-- Name: fk_perimetre_securite_perimetre; Type: FK CONSTRAINT; Schema: securite; Owner: -
--

ALTER TABLE ONLY perimetre_securite
    ADD CONSTRAINT fk_perimetre_securite_perimetre FOREIGN KEY (perimetre_id) REFERENCES perimetre(id);


SET search_path = td, pg_catalog;

--
-- TOC entry 4927 (class 2606 OID 138818)
-- Dependencies: 3660 536 214
-- Name: fk_copie_correcteur_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY copie
    ADD CONSTRAINT fk_copie_correcteur_id FOREIGN KEY (correcteur_id) REFERENCES ent.personne(id);


--
-- TOC entry 4928 (class 2606 OID 138812)
-- Dependencies: 536 3660 214
-- Name: fk_copie_eleve_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY copie
    ADD CONSTRAINT fk_copie_eleve_id FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- TOC entry 4926 (class 2606 OID 138901)
-- Dependencies: 536 4446 539
-- Name: fk_copie_modalite_activite_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY copie
    ADD CONSTRAINT fk_copie_modalite_activite_id FOREIGN KEY (modalite_activite_id) REFERENCES modalite_activite(id);


--
-- TOC entry 4929 (class 2606 OID 138806)
-- Dependencies: 528 536 4410
-- Name: fk_copie_sujet_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY copie
    ADD CONSTRAINT fk_copie_sujet_id FOREIGN KEY (sujet_id) REFERENCES sujet(id);


--
-- TOC entry 4940 (class 2606 OID 138877)
-- Dependencies: 3660 214 539
-- Name: fk_modalite_activite_enseignant_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_enseignant_id FOREIGN KEY (enseignant_id) REFERENCES ent.personne(id);


--
-- TOC entry 4939 (class 2606 OID 138883)
-- Dependencies: 539 3614 193
-- Name: fk_modalite_activite_etablissement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4937 (class 2606 OID 138895)
-- Dependencies: 3627 199 539
-- Name: fk_modalite_activite_groupe_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_groupe_id FOREIGN KEY (groupe_id) REFERENCES ent.groupe_personnes(id);


--
-- TOC entry 4934 (class 2606 OID 139065)
-- Dependencies: 202 539 3633
-- Name: fk_modalite_activite_matiere_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_matiere_id FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- TOC entry 4938 (class 2606 OID 138889)
-- Dependencies: 3660 539 214
-- Name: fk_modalite_activite_responsable_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_responsable_id FOREIGN KEY (responsable_id) REFERENCES ent.personne(id);


--
-- TOC entry 4935 (class 2606 OID 139060)
-- Dependencies: 3729 539 243
-- Name: fk_modalite_activite_structure_enseignement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_structure_enseignement_id FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- TOC entry 4936 (class 2606 OID 139040)
-- Dependencies: 528 539 4410
-- Name: fk_modalite_activite_sujet_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY modalite_activite
    ADD CONSTRAINT fk_modalite_activite_sujet_id FOREIGN KEY (sujet_id) REFERENCES sujet(id);


--
-- TOC entry 4915 (class 2606 OID 138665)
-- Dependencies: 518 526 4380
-- Name: fk_question_attachement_attachement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question_attachement
    ADD CONSTRAINT fk_question_attachement_attachement_id FOREIGN KEY (attachement_id) REFERENCES tice.attachement(id);


--
-- TOC entry 4903 (class 2606 OID 139147)
-- Dependencies: 518 522 4380
-- Name: fk_question_attachement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_attachement_id FOREIGN KEY (attachement_id) REFERENCES tice.attachement(id);


--
-- TOC entry 4914 (class 2606 OID 138671)
-- Dependencies: 522 526 4393
-- Name: fk_question_attachement_question_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question_attachement
    ADD CONSTRAINT fk_question_attachement_question_id FOREIGN KEY (question_id) REFERENCES question(id);


--
-- TOC entry 4905 (class 2606 OID 139010)
-- Dependencies: 532 522 4416
-- Name: fk_question_copyrights_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_copyrights_id FOREIGN KEY (copyrights_type_id) REFERENCES tice.copyrights_type(id);


--
-- TOC entry 4910 (class 2606 OID 138611)
-- Dependencies: 3614 193 522
-- Name: fk_question_etablissement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4904 (class 2606 OID 139134)
-- Dependencies: 528 522 4410
-- Name: fk_question_exercice_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_exercice_id FOREIGN KEY (exercice_id) REFERENCES sujet(id);


--
-- TOC entry 4913 (class 2606 OID 138645)
-- Dependencies: 4377 516 524
-- Name: fk_question_export_format_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question_export
    ADD CONSTRAINT fk_question_export_format_id FOREIGN KEY (format_id) REFERENCES tice.export_format(id);


--
-- TOC entry 4912 (class 2606 OID 138651)
-- Dependencies: 4393 524 522
-- Name: fk_question_export_question_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question_export
    ADD CONSTRAINT fk_question_export_question_id FOREIGN KEY (question_id) REFERENCES question(id);


--
-- TOC entry 4909 (class 2606 OID 138617)
-- Dependencies: 3633 522 202
-- Name: fk_question_matiere_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_matiere_id FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- TOC entry 4911 (class 2606 OID 138605)
-- Dependencies: 522 3651 210
-- Name: fk_question_niveau_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_niveau_id FOREIGN KEY (niveau_id) REFERENCES ent.niveau(id);


--
-- TOC entry 4907 (class 2606 OID 138629)
-- Dependencies: 214 522 3660
-- Name: fk_question_proprietaire_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_proprietaire_id FOREIGN KEY (proprietaire_id) REFERENCES ent.personne(id);


--
-- TOC entry 4906 (class 2606 OID 138778)
-- Dependencies: 533 522 4419
-- Name: fk_question_publication_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_publication_id FOREIGN KEY (publication_id) REFERENCES tice.publication(id);


--
-- TOC entry 4908 (class 2606 OID 138623)
-- Dependencies: 520 522 4382
-- Name: fk_question_type_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_type_id FOREIGN KEY (type_id) REFERENCES question_type(id);


--
-- TOC entry 4942 (class 2606 OID 139121)
-- Dependencies: 4380 544 518
-- Name: fk_reponse_attachement_attachement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY reponse_attachement
    ADD CONSTRAINT fk_reponse_attachement_attachement_id FOREIGN KEY (attachement_id) REFERENCES tice.attachement(id);


--
-- TOC entry 4941 (class 2606 OID 139127)
-- Dependencies: 544 4433 538
-- Name: fk_reponse_attachement_reponse_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY reponse_attachement
    ADD CONSTRAINT fk_reponse_attachement_reponse_id FOREIGN KEY (reponse_id) REFERENCES reponse(id);


--
-- TOC entry 4933 (class 2606 OID 138834)
-- Dependencies: 4425 538 536
-- Name: fk_reponse_copie_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY reponse
    ADD CONSTRAINT fk_reponse_copie_id FOREIGN KEY (copie_id) REFERENCES copie(id);


--
-- TOC entry 4932 (class 2606 OID 138846)
-- Dependencies: 214 538 3660
-- Name: fk_reponse_correcteur_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY reponse
    ADD CONSTRAINT fk_reponse_correcteur_id FOREIGN KEY (correcteur_id) REFERENCES ent.personne(id);


--
-- TOC entry 4931 (class 2606 OID 138917)
-- Dependencies: 538 3660 214
-- Name: fk_reponse_eleve_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY reponse
    ADD CONSTRAINT fk_reponse_eleve_id FOREIGN KEY (eleve_id) REFERENCES ent.personne(id);


--
-- TOC entry 4930 (class 2606 OID 139078)
-- Dependencies: 530 538 4414
-- Name: fk_reponse_sujet_question_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY reponse
    ADD CONSTRAINT fk_reponse_sujet_question_id FOREIGN KEY (sujet_question_id) REFERENCES sujet_sequence_questions(id);


--
-- TOC entry 4917 (class 2606 OID 138928)
-- Dependencies: 4416 528 532
-- Name: fk_sujet_copyrights_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_copyrights_id FOREIGN KEY (copyrights_type_id) REFERENCES tice.copyrights_type(id);


--
-- TOC entry 4921 (class 2606 OID 138713)
-- Dependencies: 528 193 3614
-- Name: fk_sujet_etablissement_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_etablissement_id FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 4920 (class 2606 OID 138719)
-- Dependencies: 3633 202 528
-- Name: fk_sujet_matiere_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_matiere_id FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- TOC entry 4922 (class 2606 OID 138707)
-- Dependencies: 3651 210 528
-- Name: fk_sujet_niveau_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_niveau_id FOREIGN KEY (niveau_id) REFERENCES ent.niveau(id);


--
-- TOC entry 4919 (class 2606 OID 138725)
-- Dependencies: 3660 214 528
-- Name: fk_sujet_proprietaire_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_proprietaire_id FOREIGN KEY (proprietaire_id) REFERENCES ent.personne(id);


--
-- TOC entry 4918 (class 2606 OID 138784)
-- Dependencies: 528 4419 533
-- Name: fk_sujet_publication_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_publication_id FOREIGN KEY (publication_id) REFERENCES tice.publication(id);


--
-- TOC entry 4923 (class 2606 OID 138744)
-- Dependencies: 4393 522 530
-- Name: fk_sujet_sequence_questions_question_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet_sequence_questions
    ADD CONSTRAINT fk_sujet_sequence_questions_question_id FOREIGN KEY (question_id) REFERENCES question(id);


--
-- TOC entry 4924 (class 2606 OID 138738)
-- Dependencies: 528 4410 530
-- Name: fk_sujet_sequence_questions_sujet_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet_sequence_questions
    ADD CONSTRAINT fk_sujet_sequence_questions_sujet_id FOREIGN KEY (sujet_id) REFERENCES sujet(id);


--
-- TOC entry 4916 (class 2606 OID 138987)
-- Dependencies: 541 528 4448
-- Name: fk_sujet_sujet_type_id; Type: FK CONSTRAINT; Schema: td; Owner: -
--

ALTER TABLE ONLY sujet
    ADD CONSTRAINT fk_sujet_sujet_type_id FOREIGN KEY (sujet_type_id) REFERENCES sujet_type(id);


SET search_path = tice, pg_catalog;

--
-- TOC entry 4902 (class 2606 OID 138555)
-- Dependencies: 3660 214 514
-- Name: fk_compte_utilisateur_personne_id; Type: FK CONSTRAINT; Schema: tice; Owner: -
--

ALTER TABLE ONLY compte_utilisateur
    ADD CONSTRAINT fk_compte_utilisateur_personne_id FOREIGN KEY (personne_id) REFERENCES ent.personne(id);


--
-- TOC entry 4925 (class 2606 OID 138772)
-- Dependencies: 4416 532 533
-- Name: fk_publication_copyrights_type_id; Type: FK CONSTRAINT; Schema: tice; Owner: -
--

ALTER TABLE ONLY publication
    ADD CONSTRAINT fk_publication_copyrights_type_id FOREIGN KEY (copyrights_type_id) REFERENCES copyrights_type(id);


SET search_path = udt, pg_catalog;

--
-- TOC entry 4733 (class 2606 OID 137143)
-- Dependencies: 448 4158 450
-- Name: fk_enseignement_import; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_import FOREIGN KEY (udt_import_id) REFERENCES import(id);


--
-- TOC entry 4736 (class 2606 OID 137128)
-- Dependencies: 450 3633 202
-- Name: fk_enseignement_matiere; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_matiere FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- TOC entry 4735 (class 2606 OID 137133)
-- Dependencies: 214 450 3660
-- Name: fk_enseignement_personne; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_personne FOREIGN KEY (professeur_id) REFERENCES ent.personne(id);


--
-- TOC entry 4734 (class 2606 OID 137138)
-- Dependencies: 243 450 3729
-- Name: fk_enseignement_structure_enseignement; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY enseignement
    ADD CONSTRAINT fk_enseignement_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- TOC entry 4738 (class 2606 OID 138527)
-- Dependencies: 4158 452 448
-- Name: fk_evenement_import; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_import FOREIGN KEY (udt_import_id) REFERENCES import(id);


--
-- TOC entry 4741 (class 2606 OID 138512)
-- Dependencies: 202 3633 452
-- Name: fk_evenement_matiere; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_matiere FOREIGN KEY (matiere_id) REFERENCES ent.matiere(id);


--
-- TOC entry 4740 (class 2606 OID 138517)
-- Dependencies: 452 3660 214
-- Name: fk_evenement_personne; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_personne FOREIGN KEY (professeur_id) REFERENCES ent.personne(id);


--
-- TOC entry 4739 (class 2606 OID 138522)
-- Dependencies: 3729 243 452
-- Name: fk_evenement_structure_enseignement; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_structure_enseignement FOREIGN KEY (structure_enseignement_id) REFERENCES ent.structure_enseignement(id);


--
-- TOC entry 4737 (class 2606 OID 138532)
-- Dependencies: 4018 452 373
-- Name: fk_evenement_type_evenement; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY evenement
    ADD CONSTRAINT fk_evenement_type_evenement FOREIGN KEY (type_evenement_id) REFERENCES enttemps.type_evenement(id);


--
-- TOC entry 4732 (class 2606 OID 137116)
-- Dependencies: 3614 448 193
-- Name: fk_import_etablissement; Type: FK CONSTRAINT; Schema: udt; Owner: -
--

ALTER TABLE ONLY import
    ADD CONSTRAINT fk_import_etablissement FOREIGN KEY (etablissement_id) REFERENCES ent.etablissement(id);


--
-- TOC entry 5166 (class 0 OID 0)
-- Dependencies: 16
-- Name: public; Type: ACL; Schema: -; Owner: -
--

--REVOKE ALL ON SCHEMA public FROM PUBLIC;
--REVOKE ALL ON SCHEMA public FROM postgres;
--GRANT ALL ON SCHEMA public TO postgres;
--GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2012-07-19 17:57:33 CEST

--
-- PostgreSQL database dump complete
--

SET search_path = public ;


