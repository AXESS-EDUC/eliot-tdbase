package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.apache.commons.io.IOUtils
import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONElement
import org.codehaus.groovy.grails.web.json.JSONObject

import javax.mail.internet.MimeUtility
import java.text.DateFormat
import java.text.SimpleDateFormat

/**
 * Méthodes utilitaires pour le marshalling
 *
 * @author John Tranier
 */
class MarshallerHelper {

  public final static DateFormat ISO_DATE_FORMAT = new SimpleDateFormat(
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
      Locale.getDefault(Locale.Category.FORMAT)
  )

  static void checkIsNotNull(String elementNom, def element) {
    if (!element) {
      throw new MarshallerException("$elementNom est obligatoire", elementNom)
    }
  }

  static void checkIsJsonElement(String elementNom, def element) {
    if (!(element instanceof JSONElement)) {
      throw new MarshallerException("$elementNom doit être un JSONElement (reçu $element de classe ${element?.class})", elementNom)
    }
  }

  static void checkIsJsonElementOrNull(String elementNom, def element) {
    if (!(element instanceof JSONElement) && !(element instanceof JSONObject.Null)) {
      throw new MarshallerException(
          "$elementNom doit être un JSONElement ou JSONObject.Null (reçu $element de classe ${element?.class})",
          elementNom
      )
    }
  }

  static void checkIsJsonArray(String elementNom, def element) {
    if (!(element instanceof JSONArray)) {
      throw new MarshallerException("$elementNom doit être un JSONArray (reçu $element de classe ${element?.class})", elementNom)
    }
  }

  static String jsonObjectToString(def jsonObject) {
    return jsonObject instanceof JSONObject.Null ?
      null :
      jsonObject.toString()
  }

  static Long jsonObjectToLong(def jsonObject) {
    return jsonObject instanceof JSONObject.Null ?
      null :
      jsonObject
  }

  static Date parseDate(String strDate) {
    return strDate ?
      ISO_DATE_FORMAT.parse(strDate) :
      null
  }

  static Date parseDate(JSONObject.Null jsonObject) {
    return null
  }

  static String asJsonString(String str) {
    if (str == null) {
      return null
    }

    return "'" + str + "'"
  }

  static byte[] getDecodedBytes(String base64String) {
    def base64Bytes = base64String.getBytes()
    InputStream decodedInputStream = MimeUtility.decode(
        new ByteArrayInputStream(base64Bytes),
        'base64'
    )
    return IOUtils.toByteArray(decodedInputStream)
  }

  static String encodeAsBase64(String data) {
    ByteArrayOutputStream bos = new ByteArrayOutputStream()
    OutputStream b64os = MimeUtility.encode(bos, 'base64')

    try {
      b64os << new ByteArrayInputStream(data.getBytes())
      b64os.flush()
      bos.toString()
    } finally {
      bos?.close()
      b64os?.close()
    }
  }
}
