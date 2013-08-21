package org.lilie.services.eliot.tdbase

/**
 * @author John Tranier
 */
class ReferentielSujetSequenceQuestions {
  Integer rang
  Float noteSeuilPoursuite
  Float points

  boolean equals(o) {
    if (this.is(o)) return true
    if (getClass() != o.class) return false

    ReferentielSujetSequenceQuestions that = (ReferentielSujetSequenceQuestions) o

    if (noteSeuilPoursuite != that.noteSeuilPoursuite) return false
    if (points != that.points) return false
    if (rang != that.rang) return false

    return true
  }

  int hashCode() {
    int result
    result = (rang != null ? rang.hashCode() : 0)
    result = 31 * result + (noteSeuilPoursuite != null ? noteSeuilPoursuite.hashCode() : 0)
    result = 31 * result + (points != null ? points.hashCode() : 0)
    return result
  }
}
