package org.lilie.services.eliot.tice.scolarite

import org.springframework.security.core.GrantedAuthority

/**
 * Table fonction
 * @author othe
 */
class Fonction implements GrantedAuthority {
  Long id
  String code
  String libelle

  static constraints = {
    code(nullable: false)
    libelle(nullable: true)
  }

  /**
   *
   * @return le libelle de la fonction
   */
  String getAuthority() {
    return "ROLE_${code}"
  }

  static transients = ['authority']

  static mapping = {
    table('ent.fonction')
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.fonction_id_seq']
    version false
    cache('read-only')
  }

}

/**
 * Enumeration des fonctions
 * <ul>
 *  <li>AC - adminsitrateur central</li>
 *  <li>AL - adminsitrateur local</li>
 *  <li>CD - correspondant déploiement</li>
 *  <li>UI - invité</li>
 *  <li>ELEVE - élève</li>
 *  <li>PERS_REL_ELEVE - responsable élève</li>
 *  <li>ENS - enseignant</li>
 *  <li>DIR - direction</li>
 *  <li>EDU - CPE</li>
 *  <li>DOC - Documentation</li>
 *  <li>CFC - Conseiller Formation continue</li>
 *  <li>CTR - Chef de travaux</li>
 *  <li>ADF - Personnel administratif</li>
 *  <li>ALB - Laboratoire</li>
 *  <li>ASE - Assistant étranger</li>
 *  <li>LAB - Personnel de laboratoire</li>
 *  <li>MDS - Personnel medico-social</li>
 *  <li>OUV - Personnel ouviriers et de service</li>
 *  <li>SUR - Surveillance</li>
 * </ul>
 */
enum FonctionEnum {
  AC(1),
  AL(2),
  CD(3),
  UI(4),
  ELEVE(5),
  PERS_REL_ELEVE(6),
  ENS(7),
  DIR(8),
  EDU(9),
  DOC(10),
  CFC(11),
  CTR(12),
  ADF(13),
  ALB(14),
  ASE(15),
  LAB(16),
  MDS(17),
  OUV(18),
  SUR(19)
  //ORI(20),
  //AED(21),
  //AVS(22),
  //APP(23)


  private Long id

  private FonctionEnum(Long id) {
    this.id = id
  }

  Long getId() {
    return id
  }

  Fonction getFonction() {
    Fonction.get(id)
  }

  String toRole() {
    "ROLE_${this.toString()}"
  }

}