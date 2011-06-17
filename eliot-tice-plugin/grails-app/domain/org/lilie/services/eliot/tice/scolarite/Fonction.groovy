package org.lilie.services.eliot.tice.scolarite

/**
 * Table fonction
 * @author othe
 */
class Fonction {
  Long id
  String code
  String libelle

  static constraints = {
    code(nullable: false)
    libelle(nullable: true)    
  }

  static mapping = {
    table('ent.fonction')
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.fonction_id_seq']
    version false
  }

}
