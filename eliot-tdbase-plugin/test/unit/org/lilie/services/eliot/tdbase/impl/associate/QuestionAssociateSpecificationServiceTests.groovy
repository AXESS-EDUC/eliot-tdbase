package org.lilie.services.eliot.tdbase.impl.associate

class QuestionAssociateSpecificationServiceTests extends GroovyTestCase {

  void testSomething() {


    def p11 = null
    def p12 = "DEF"
    def p21 = "DEF"
    def p22 = null

    def association1 = [p11, p12]
    def association2 = [p21, p22]

    assertTrue((association1 - association2).isEmpty())
  }
}
