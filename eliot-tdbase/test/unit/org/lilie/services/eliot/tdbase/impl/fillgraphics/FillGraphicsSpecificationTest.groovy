package org.lilie.services.eliot.tdbase.impl.fillgraphics

/**
 * Created by IntelliJ IDEA.
 * User: bert
 * Date: 15/02/12
 * Time: 10:22
 * To change this template use File | Settings | File Templates.
 */
class FillGraphicsSpecificationTest extends GroovyTestCase {

  void testGetMotsSugeres() {
    def textZones = []
    textZones << new TextZone(text: "Tata").toMap()
    textZones << new TextZone(text: "Titi").toMap()
    textZones << new TextZone(text: "Tutu").toMap()
    def specification = new FillGraphicsSpecification(textZones: textZones)

    def motsSugeres = specification.motsSugeres

    assertEquals(3, motsSugeres.size())
    assertTrue(motsSugeres.contains("Tata"))
    assertTrue(motsSugeres.contains("Titi"))
    assertTrue(motsSugeres.contains("Tutu"))
  }
}
