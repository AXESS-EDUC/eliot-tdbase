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
class MoodleQuizTransformerTests extends GroovyTestCase {

  static final INPUT = 'org/lilie/services/eliot/tdbase/xml/exemples/quiz-exemple-20120229-0812.xml'

  MoodleQuizTransformer moodleQuizTransformer
  ApplicationContext ctx

  void setUp() {
    ctx = new ClassPathXmlApplicationContext('TestContext.xml')
    moodleQuizTransformer = ctx.getBean('moodleQuizTransformer')
  }

  void testTransformInputWithStyleSheetGroovy() {
    def inputStream = ctx.getResource("classpath:$INPUT").getInputStream()
    assertNotNull(inputStream)
    def res = moodleQuizTransformer.moodleQuizTransform(inputStream)
    assertNotNull res
    def quiz = res.quiz
    println quiz
    assert quiz[0].nombreItems == 11
  }

}
