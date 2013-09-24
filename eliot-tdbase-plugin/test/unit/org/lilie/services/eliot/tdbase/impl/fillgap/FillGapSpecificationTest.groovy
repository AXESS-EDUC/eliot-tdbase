/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 * Lilie is free software. You can redistribute it and/or modify since
 * you respect the terms of either (at least one of the both license) :
 * - under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * - the CeCILL-C as published by CeCILL-C; either version 1 of the
 * License, or any later version
 *
 * There are special exceptions to the terms and conditions of the
 * licenses as they are applied to this software. View the full text of
 * the exception in file LICENSE.txt in the directory of this software
 * distribution.
 *
 * Lilie is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Licenses for more details.
 *
 * You should have received a copy of the GNU General Public License
 * and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tdbase.impl.fillgap

/**
 * Created by IntelliJ IDEA.
 * User: bert
 * Date: 18/11/11
 * Time: 17:53
 * To change this template use File | Settings | File Templates.
 */
class FillGapSpecificationTest extends GroovyTestCase {

  void testGetTextATrousStructure() {

    def texteATrous = "The color of blood is {=red}. Major blood vessels are {~feet=arteries=veins} and {=veins=arteries~hair~\\~moo\\}\\=\\{}."

    def structure = new FillGapSpecification([texteATrous: texteATrous]).texteATrousStructure

    assertEquals(7, structure.size())
    assertTrue(structure[0].isTextElement())
    assertFalse(structure[1].isTextElement())
    assertTrue(structure[2].isTextElement())
    assertFalse(structure[3].isTextElement())
    assertTrue(structure[4].isTextElement())
    assertFalse(structure[5].isTextElement())
    assertTrue(structure[6].isTextElement())

    //---
    TextATrouElement trouElement = structure[1]
    assertEquals(1, trouElement.valeur.size())

    assertEquals("red", trouElement.valeur[0].text)
    assertEquals(true, trouElement.valeur[0].correct)

    //---
    trouElement = structure[3]
    assertEquals(3, trouElement.valeur.size())

    assertEquals("feet", trouElement.valeur[0].text)
    assertEquals(false, trouElement.valeur[0].correct)

    assertEquals("arteries", trouElement.valeur[1].text)
    assertEquals(true, trouElement.valeur[1].correct)

    assertEquals("veins", trouElement.valeur[2].text)
    assertEquals(true, trouElement.valeur[2].correct)

    //---
    trouElement = structure[5]
    assertEquals(4, trouElement.valeur.size())

    assertEquals("veins", trouElement.valeur[0].text)
    assertEquals(true, trouElement.valeur[0].correct)

    assertEquals("arteries", trouElement.valeur[1].text)
    assertEquals(true, trouElement.valeur[1].correct)

    assertEquals("hair", trouElement.valeur[2].text)
    assertEquals(false, trouElement.valeur[2].correct)

    assertEquals("\\~moo\\}\\=\\{", trouElement.valeur[3].text)
    assertEquals(false, trouElement.valeur[3].correct)
  }

  void testTrouElementValeurAsText() {
    def trouElement = new TrouElement()
    trouElement.valeur << new TrouText(text: 'toto', correct: false)
    trouElement.valeur << new TrouText(text: 'titi', correct: true)
    trouElement.valeur << new TrouText(text: 'tata', correct: false)

    assertEquals('{~toto=titi~tata}', trouElement.valeurAsText())
  }

  void testPeekedElementIsText() {
    assertTrue new FillGapSpecification().peekedElementIsText('fdfdfg{=toto}')
    assertTrue(new FillGapSpecification().peekedElementIsText('fdfdfg\\{bla\\}{=toto}'))
    assertFalse(new FillGapSpecification().peekedElementIsText('{=toto}blalala'))
    assertTrue(new FillGapSpecification().peekedElementIsText('blalalal'))
    assertTrue(new FillGapSpecification().peekedElementIsText('blalalal}'))
  }

  void testExtractText() {
    def fillGapSpecification = new FillGapSpecification()

    shouldFail { fillGapSpecification.extractTextElement("{=toto}") }
    assertEquals("toto", fillGapSpecification.extractTextElement("toto{=titi}").valeur)
    assertEquals("toto{as", fillGapSpecification.extractTextElement("toto\\{as{=titi}").valeur)
    assertEquals("{", fillGapSpecification.extractTextElement("\\{").valeur)
  }

  void testEatText() {
    def fillGapSpecification = new FillGapSpecification()
    // should fail because the text begins with a gap element instead of a text element
    shouldFail { fillGapSpecification.eatText("{=toto}") }
    assertEquals("{=titi}", fillGapSpecification.eatText("toto{=titi}"))
    assertEquals("{=titi}", fillGapSpecification.eatText("t\\{oto{=titi}"))
    assertEquals("", fillGapSpecification.eatText("DFSFDFFFSFSFSFS"))
  }

  void testEatGap() {
    def fillGapSpecification = new FillGapSpecification()
    // should fail because the text begins with a text element instead of a gap element
    shouldFail { fillGapSpecification.eatGap("rzerzer{=toto}") }
    assertEquals("sdfsfsfs{~tata}", fillGapSpecification.eatGap("{=titi}sdfsfsfs{~tata}"))
    assertEquals("sdfrrf", fillGapSpecification.eatGap("{=ti\\~ti}sdfrrf"))
  }

  void testExtractGap() {
    def fillGapSpecification = new FillGapSpecification()
    // should fail because does not start with '{'
    shouldFail {fillGapSpecification.extractGap('toto{=titi}')}
    // should fail because does not end with '}'
    shouldFail {fillGapSpecification.extractGap('{=titi')}

    TrouElement trouElement = fillGapSpecification.extractGap('{=titi~toto\\~no=ti\\~bla}sdfsdfdfsdf')

    assertEquals(3, trouElement.valeur.size())

    assertEquals("titi", trouElement.valeur[0].text)
    assertTrue(trouElement.valeur[0].correct)

    assertEquals("toto\\~no", trouElement.valeur[1].text)
    assertFalse(trouElement.valeur[1].correct)


    assertEquals("ti\\~bla", trouElement.valeur[2].text)
    assertTrue(trouElement.valeur[2].correct)

    assertEquals('{=titi~toto\\~no=ti\\~bla}', fillGapSpecification.extractGap('{=titi~toto\\~no=ti\\~bla}sdfsdfdfsdf').valeurAsText())
  }

  void testGetMotsSugeres() {
    def texteATrous = "The color of blood is {=red}. Major blood vessels are {~feet=arteries=veins} and {=veins=arteries~hair~\\~moo\\}\\=\\{}."
    def specification = new FillGapSpecification(texteATrous: texteATrous)
    def motsSugeres = specification.motsSugeres

    assertEquals(8, motsSugeres.size())
    assertTrue(motsSugeres.contains('red'))
    assertTrue(motsSugeres.contains('arteries'))
    assertTrue(motsSugeres.contains('veins'))
    assertTrue(motsSugeres.contains('feet'))
    assertTrue(motsSugeres.contains('hair'))
  }
}
