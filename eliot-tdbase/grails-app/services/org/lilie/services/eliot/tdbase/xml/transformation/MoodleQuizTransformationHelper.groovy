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

import javax.activation.FileTypeMap
import javax.mail.internet.MimeUtility
import javax.xml.stream.XMLInputFactory
import javax.xml.stream.XMLStreamReader
import javax.xml.transform.TransformerFactory
import javax.xml.transform.stream.StreamResult
import javax.xml.transform.stream.StreamSource
import org.lilie.services.eliot.tice.AttachementDataStore
import org.lilie.services.eliot.tice.ImageIds
import org.lilie.services.eliot.tice.jackrabbit.core.data.version_2_4_0.DataRecord
import org.lilie.services.eliot.tice.jackrabbit.core.data.version_2_4_0.DataStore

/**
 *
 * @author franck Silvestre
 */
class MoodleQuizTransformationHelper {

  DataStore dataStore

  /**
   * Transforme un fichier XML avec une feuille de style XSLT
   * @param input l'inputstream correspondant au fichier XML à transformer
   * @param xslt l'inputstreao correspondant au fichier XSLT
   * @param result l'outputstream réceptionnant le résultat
   */
  def transformInputWithXslt(InputStream input, InputStream xslt, OutputStream result = System.out) {
    def factory = TransformerFactory.newInstance()
    def transformer = factory.newTransformer(new StreamSource(xslt))
    transformer.transform(new StreamSource(input), new StreamResult(result))
  }

  /**
   * Traite un inputstream pour extraire les images encodées en base 64
   * @param input l'input stream à traiter
   */
  Map<String, ImageIds> processInputWithBase64Handler(InputStream input) {
    XMLStreamReader reader = XMLInputFactory.newInstance().createXMLStreamReader(input)
    def processor = new MoodleQuizBase64DecoderHandler(dataStore: dataStore);
    processor.process(reader)
  }


}

/**
 * Classe permettant d'extraire les images d'un fichier Moodle
 */
class MoodleQuizBase64DecoderHandler {

  DataStore dataStore
  private Map<String, ImageIds> images = [:]
  private ImageIds currentImage


  Map<String, ImageIds> process(XMLStreamReader reader) {
    while (reader.hasNext()) {
      if (reader.startElement) {
        processStartElement(reader)
      }
      if (reader.endElement) {
        processEndElement(reader)
      }
      reader.next()
    }
    images
  }

  def processStartElement(XMLStreamReader element) {
    def elementName = element.name.toString()
    if (elementName == 'image') {
      currentImage = new ImageIds(sourceId: element.getElementText())
      def mt = FileTypeMap.getDefaultFileTypeMap().getContentType(currentImage.sourceId)
      currentImage.contentType = mt
      currentImage.fileName = currentImage.sourceId.split(File.separator).last()
    }
    if (elementName == 'image_base64') {
      if (currentImage) {
        InputStream encodedIs = new ByteArrayInputStream(element.getElementText().bytes)
        InputStream decodedIs = MimeUtility.decode(encodedIs, 'base64')
        DataRecord dataRecord = dataStore.addRecord(decodedIs)
        currentImage.dataSoreId = dataRecord.identifier.toString()
        currentImage.size = dataRecord.length
      }
    }
  }

  def processEndElement(XMLStreamReader element) {
    def elementName = element.name.toString()
    if (elementName == 'image_base64') {
      if (currentImage) {
        images.put(currentImage.sourceId, currentImage)
        currentImage = null
      }
    }
  }


}

