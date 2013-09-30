package org.lilie.services.eliot.competence

import grails.plugin.spock.UnitSpec

/**
 * @author John
 */
class DomaineSpec extends UnitSpec {

  def setup() {
    mockDomain(Domaine)
  }

  def "testIsAncestorOf"() {
    given:
    Domaine domaineParent = new Domaine(id: 1)
    Domaine domaine = new Domaine(id: 2)
    domaineParent.addToAllSousDomaine(domaine)
    Competence competence = new Competence(id: 1)

    expect:
    !domaine.isAncestorOf(competence)
    !domaineParent.isAncestorOf(competence)

    when:
    domaine.addToAllCompetence(competence)

    then:
    domaine.isAncestorOf(competence)
    domaineParent.isAncestorOf(competence)

    when:
    domaine.removeFromAllCompetence(competence)
    domaineParent.addToAllCompetence(competence)

    then:
    !domaine.isAncestorOf(competence)
    domaineParent.isAncestorOf(competence)
  }

  def "testIsAncestorOfAnyOf"() {
    given:
    Domaine domaineGrandParent = new Domaine(id: 0)
    Domaine domaineParent = new Domaine(id: 1)
    domaineGrandParent.addToAllSousDomaine(domaineParent)
    Domaine domaine = new Domaine(id: 2)
    domaineParent.addToAllSousDomaine(domaine)
    Competence competence1 = new Competence(id: 1)
    Competence competence2 = new Competence(id: 2)

    expect:
    !domaine.isAncestorOfAnyOf([])
    !domaineParent.isAncestorOfAnyOf([])
    !domaineGrandParent.isAncestorOfAnyOf([])
    !domaine.isAncestorOfAnyOf([competence1, competence2])
    !domaineParent.isAncestorOfAnyOf([competence1, competence2])
    !domaineGrandParent.isAncestorOfAnyOf([competence1, competence2])

    when:
    domaineParent.addToAllCompetence(competence1)
    domaine.addToAllCompetence(competence2)

    then:
    domaineGrandParent.isAncestorOfAnyOf([competence1, competence2])
    domaineGrandParent.isAncestorOfAnyOf([competence1])
    domaineGrandParent.isAncestorOfAnyOf([competence2])
    domaineParent.isAncestorOfAnyOf([competence1, competence2])
    domaineParent.isAncestorOfAnyOf([competence1])
    domaineParent.isAncestorOfAnyOf([competence2])
    domaine.isAncestorOfAnyOf([competence1, competence2])
    domaine.isAncestorOfAnyOf([competence2])
    !domaine.isAncestorOfAnyOf([competence1])
  }
}
