package org.lilie.services.eliot.tdbase.impl.fillgap

/**
 * Created by IntelliJ IDEA.
 * User: bert
 * Date: 13/02/12
 * Time: 15:46
 * To change this template use File | Settings | File Templates.
 */
class ReponseFillGapSpecificationTest extends GroovyTestCase {

  void testEvaluate() {

    def texteATrous = "The color of blood is {=red}. Major blood vessels are {~feet=arteries=veins} and {=veins=arteries~hair~\\~moo\\}\\=\\{}."
    def specification = new FillGapSpecification([texteATrous: texteATrous])
    def reponsesPossibles = specification.texteATrousStructure.findAll {!it.textElement}
    def reponseSpec = new ReponseFillGapSpecification(valeursDeReponse: ["red", "arteries", "veins"], reponsesPossibles: reponsesPossibles);

    assertEquals(1f, reponseSpec.evaluate(1f), 0f);
  }
}
