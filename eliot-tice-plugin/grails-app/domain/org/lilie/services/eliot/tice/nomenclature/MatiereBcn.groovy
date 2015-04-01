package org.lilie.services.eliot.tice.nomenclature

class MatiereBcn {

  Long id
  String libelleCourt
  String libelleLong
  String libelleEdition
  Long bcnId

  static mapping = {
    table 'nomenclature.matiere'
    id column: 'id', generator: 'sequence', params: [sequence: 'nomenclature.matiere_id_seq']
    cache usage: 'read-write'
  }

  static constraints = {
    libelleCourt(maxSize: 50)
    libelleLong(maxSize: 255)
    libelleEdition(maxSize: 255)
  }
}
