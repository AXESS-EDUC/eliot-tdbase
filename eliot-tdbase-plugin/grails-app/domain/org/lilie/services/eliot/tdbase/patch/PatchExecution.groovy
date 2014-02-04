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

  boolean equals(o) {
    if (this.is(o)) return true
    if (getClass() != o.class) return false

    PatchExecution that = (PatchExecution) o

    if (code != that.code) return false

    return true
  }

  int hashCode() {
    return code.hashCode()
  }


  @Override
  public String toString() {
    return "PatchExecution{" +
        "code='" + code + '\'' +
        '}';
  }
}
