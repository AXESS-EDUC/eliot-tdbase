package org.lilie.services.eliot.tice.scolarite

class Regime {
  Long id
  String code

  static mapping = {
    table('ent.regime')
    id column: 'id', generator: 'sequence', params: [sequence: 'ent.regime_id_seq']
    version false
  }
}
