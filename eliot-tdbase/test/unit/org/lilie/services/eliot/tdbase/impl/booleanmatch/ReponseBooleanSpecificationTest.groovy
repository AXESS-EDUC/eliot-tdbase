package org.lilie.services.eliot.tdbase.impl.booleanmatch

/**
 * Created by IntelliJ IDEA.
 * User: bert
 * Date: 16/02/12
 * Time: 17:16
 * To change this template use File | Settings | File Templates.
 */
class ReponseBooleanSpecificationTest extends GroovyTestCase {


  void testEvaluate() {

    def reponsesPossibles = ['I', 'am', 'happy']
    ReponseBooleanMatchSpecification reponseBooleanSpecification

    reponseBooleanSpecification = new ReponseBooleanMatchSpecification(
            valeurDeReponse: 'I am very happy',
            reponsesPossibles: reponsesPossibles,
            toutOuRien: false
    )
    assertEquals(3F, reponseBooleanSpecification.evaluate(3F), 0F)

    reponseBooleanSpecification = new ReponseBooleanMatchSpecification(
            valeurDeReponse: 'I am very happy',
            reponsesPossibles: reponsesPossibles,
            toutOuRien: true
    )
    assertEquals(3F, reponseBooleanSpecification.evaluate(3F), 0F)

    reponseBooleanSpecification = new ReponseBooleanMatchSpecification(
            valeurDeReponse: 'I am unhappy',
            reponsesPossibles: reponsesPossibles,
            toutOuRien: false
    )
    assertEquals(2F, reponseBooleanSpecification.evaluate(3F), 0F)

    reponseBooleanSpecification = new ReponseBooleanMatchSpecification(
            valeurDeReponse: 'I am unhappy',
            reponsesPossibles: reponsesPossibles,
            toutOuRien: true
    )
    assertEquals(0F, reponseBooleanSpecification.evaluate(3F), 0F)
  }
}
