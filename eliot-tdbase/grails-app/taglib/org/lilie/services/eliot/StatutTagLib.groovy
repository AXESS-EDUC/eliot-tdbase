package org.lilie.services.eliot

/**
 * @author John Tranier
 */
class StatutTagLib {

  def renderStatut = { attrs ->
    Boolean value = attrs.value

    if(value == null) {
      out << "-"
    }
    else if(value) {
      out << '<span class="success">OK</span>'
    }
    else {
      out << '<span class="error">KO</span>'
    }
  }
}
