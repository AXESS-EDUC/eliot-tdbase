/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tdbase.xml.transformation

import org.springframework.context.ApplicationContext
import org.springframework.context.support.ClassPathXmlApplicationContext

/**
 *
 * @author franck Silvestre
 */
class MoodleQuizTransformationHelperTests extends GroovyTestCase {

  static final INPUT = 'org/lilie/services/eliot/tdbase/xml/exemples/quiz-exemple-20120229-0812.xml'
  static final XSLT_JSON = 'org/lilie/services/eliot/tdbase/xml/transformation/moodleXmlToEliotTdbaseJson.xsl'

  MoodleQuizTransformationHelper transformationHelper
  ApplicationContext ctx

  void setUp() {

    ctx = new ClassPathXmlApplicationContext('TestContext.xml')
    transformationHelper = ctx.getBean('transformationHelper')
  }

  void testTransformInputWithStyleSheetJson() {
    def inputStream = ctx.getResource("classpath:$INPUT").getInputStream()
    def xsltSream = ctx.getResource("classpath:$XSLT_JSON").getInputStream()
    assertNotNull(xsltSream)
    assertNotNull(inputStream)
    ByteArrayOutputStream baos = new ByteArrayOutputStream()
    transformationHelper.transformInputWithXslt(inputStream, xsltSream, baos)
    ByteArrayInputStream bais = new ByteArrayInputStream(baos.toByteArray())
    Reader reader = new InputStreamReader(bais)
    println reader.text
    assertNotNull reader
  }

  void testProcessInputWithBase64Handler() {
    def inputStream = ctx.getResource("classpath:$INPUT").getInputStream()
    def imageIds = transformationHelper.processInputWithBase64Handler(inputStream)
    assertTrue(imageIds.size() > 0)
    imageIds.each {
      println it
    }
  }


}
