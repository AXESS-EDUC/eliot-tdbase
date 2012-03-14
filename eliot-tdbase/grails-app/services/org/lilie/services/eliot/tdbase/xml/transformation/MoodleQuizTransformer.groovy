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
import org.springframework.context.ApplicationContextAware
import org.lilie.services.eliot.tice.ImageIds

/**
 * Classe responsable de la transformation d'un quiz moodle au format moodle XML
 * en structure Groovy
 * @author franck Silvestre
 */
class MoodleQuizTransformer implements ApplicationContextAware {

  private static final XSLT_GROOVY = 'org/lilie/services/eliot/tdbase/xml/transformation/moodleXmlToEliotTdbaseGroovy.xsl'

  MoodleQuizTransformationHelper xmlTransformationHelper
  ApplicationContext applicationContext

  /**
   * Transforme un fichier quiz moodle xml en une map contenant les items à
   * importer
   * @param moodleQuiz l'inpustream correspondant au quiz moodle xml
   * @return la map groovy contenant les items à importer
   */
  Map moodleQuizTransform(InputStream moodleQuiz) {
    def xsltSream = applicationContext.getResource("classpath:$XSLT_GROOVY").getInputStream()
    ByteArrayOutputStream baos = new ByteArrayOutputStream()
    xmlTransformationHelper.transformInputWithXslt(moodleQuiz, xsltSream, baos)
    ByteArrayInputStream bais = new ByteArrayInputStream(baos.toByteArray())
    Reader reader = new InputStreamReader(bais)
    def gShell = new GroovyShell()
    def res = gShell.evaluate(reader)
    return res
  }

  /**
   * Importe dans l'attachement data store les images contenues dans un quiz moodle
   * @param moodleQuiz le quiz moodle à importer
   * @return la map ayant pour clé l'identifiant de l'image dans le fichier source
   * et comme valeur un objet encapsulant l'identifiant de l'image dans le data store
   */
  Map<String, ImageIds> importImages(InputStream moodleQuiz) {
    xmlTransformationHelper.processInputWithBase64Handler(moodleQuiz)
  }

}
