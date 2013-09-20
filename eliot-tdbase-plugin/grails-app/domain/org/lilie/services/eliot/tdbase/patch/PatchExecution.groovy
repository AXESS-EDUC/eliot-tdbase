package org.lilie.services.eliot.tdbase.patch

class PatchExecution {

  String code
  Date dateCreated

  static constraints = {
    code blank: false
  }

  static mapping = {
    table "td.patch_execution"
    version false
    id(column: 'id', generator: 'sequence', params: [sequence: 'td.patch_execution_id_seq'])
  }
}
