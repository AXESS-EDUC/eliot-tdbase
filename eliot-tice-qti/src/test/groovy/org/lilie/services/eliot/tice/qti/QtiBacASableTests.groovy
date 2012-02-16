package org.lilie.services.eliot.tice.qti

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

/**
 *
 * @author franck Silvestre
 */
class QtiBacASableTests extends GroovyTestCase {

  void testParseQtiFile() {
    String qtiXml = '''
    <assessmentItem xmlns="http://www.imsglobal.org/xsd/imsqti_v2p0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.imsglobal.org/xsd/imsqti_v2p0 imsqti_v2p0.xsd"
        identifier="choiceMultiple" title="Composition of Water" adaptive="false" timeDependent="false">
        <responseDeclaration identifier="MR01" cardinality="multiple" baseType="identifier">
            <correctResponse>
                <value>H</value>
                <value>O</value>
            </correctResponse>
            <mapping lowerBound="0" upperBound="2" defaultValue="-2">
                <mapEntry mapKey="H" mappedValue="1"/>
                <mapEntry mapKey="O" mappedValue="1"/>
                <mapEntry mapKey="Cl" mappedValue="-1"/>
            </mapping>
        </responseDeclaration>
        <outcomeDeclaration identifier="SCORE" cardinality="single" baseType="integer"/>
        <itemBody>
            <choiceInteraction responseIdentifier="MR01" shuffle="true" maxChoices="0">
                <prompt>Which of the <strong>following</strong> elements are used to form water?</prompt>
                <simpleChoice identifier="H" fixed="false">Hydrogen</simpleChoice>
                <simpleChoice identifier="He" fixed="false">Helium</simpleChoice>
                <simpleChoice identifier="C" fixed="false">Carbon</simpleChoice>
                <simpleChoice identifier="O" fixed="false">Oxygen</simpleChoice>
                <simpleChoice identifier="N" fixed="false">Nitrogen</simpleChoice>
                <simpleChoice identifier="Cl" fixed="false">Chlorine</simpleChoice>
            </choiceInteraction>
        </itemBody>
        <responseProcessing template="http://www.imsglobal.org/question/qti_v2p0/rptemplates/map_response"/>
    </assessmentItem>
  '''

    QtiBacASable qtiBacASable = new QtiBacASable()
    def mcSpec = qtiBacASable.parseQtiChoiceInteractionWithXmlParser(qtiXml)

    println ">>>> with xml parser ${mcSpec.libelle}"
    assertNotNull(mcSpec.libelle)


    mcSpec = qtiBacASable.parseQtiChoiceInteraction(qtiXml)
    println ">>>> with xom ${mcSpec.libelle}"
    assertNotNull(mcSpec.libelle)


  }

}
