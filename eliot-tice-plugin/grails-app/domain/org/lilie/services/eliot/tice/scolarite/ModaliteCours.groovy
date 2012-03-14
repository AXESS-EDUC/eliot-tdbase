package org.lilie.services.eliot.tice.scolarite

class ModaliteCours {

  String codeSts
  String libelleCourt
  String libelleLong
  Boolean coEns
  int noOrdre

  public static final CODE_AIDE_INDIV = 'AI'
  public static final CODE_ATELIER_PRATIQUE = 'ATP'
  public static final CODE_ATELIER = 'AT'
  public static final CODE_COURS = 'CG'
  public static final CODE_MODULE = 'MO'
  public static final CODE_PLURIDISC = 'PL'
  public static final CODE_TD = 'TD'
  public static final CODE_TP = 'TP'

  static constraints = {
    codeSts(nullable: true, maxSize: 30, unique: true)
    libelleCourt(nullable: true, maxSize: 255)
    libelleLong(nullable: true, maxSize: 1024)
    coEns(nullable: true)
  }

  static mapping = {
    table('ent.modalite_cours')
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.modalite_cours_id_seq']
  }
}

