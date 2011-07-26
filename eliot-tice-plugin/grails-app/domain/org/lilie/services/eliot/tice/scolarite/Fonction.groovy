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
