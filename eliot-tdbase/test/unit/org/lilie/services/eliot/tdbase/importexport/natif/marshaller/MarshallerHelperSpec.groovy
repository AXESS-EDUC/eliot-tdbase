package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import spock.lang.Specification

/**
 * @author John Tranier
 */
class MarshallerHelperSpec extends Specification {

  def "testGetDecodedBytes"() {
    given:
    String data = 'Une chaîne à encoder'

    expect:
    MarshallerHelper.getDecodedBytes(
        MarshallerHelper.encodeAsBase64(data)
    ) == data.getBytes()

  }

  def "testCheckClass - OK"() {
    given:
    String json = """
    {
      class: '${ExportClass.SUJET.name()}'
    }
    """

    when:
    MarshallerHelper.checkClass(ExportClass.SUJET, JSON.parse(json))

    then:
    notThrown(Exception)
  }

  def "testCheckClass - KO"(String json) {

    when:
    MarshallerHelper.checkClass(ExportClass.SUJET, JSON.parse(json))

    then:
    def e = thrown(MarshallerException)
    e.attribut == 'class'

    where:
    json << [
        """
    {
      class: '${ExportClass.QUESTION_COMPOSITE.name()}'
    }
    """,
        """
    {
    }
    """
    ]
  }

  def "testCheckClassIn - OK"(ExportClass exportClass) {
    given:
    List<ExportClass> allExportClass = [ExportClass.QUESTION_COMPOSITE, ExportClass.QUESTION_ATOMIQUE]
    String json = """
    {
      class: '${exportClass.name()}'
    }
    """

    when:
    MarshallerHelper.checkClassIn(allExportClass, JSON.parse(json))

    then:
    notThrown(Exception)

    where:
    exportClass << [ExportClass.QUESTION_ATOMIQUE, ExportClass.QUESTION_COMPOSITE]
  }

  def "testCheckClassIn - KO"(String json) {
    when:
    MarshallerHelper.checkClassIn(
        [
            ExportClass.SUJET,
            ExportClass.ETABLISSEMENT
        ],
        JSON.parse(json)
    )

    then:
    def e = thrown(MarshallerException)
    e.attribut == 'class'

    where:
    json << [
        """
    {
      class: '${ExportClass.QUESTION_COMPOSITE.name()}'
    }
    """,
        """
    {
    }
    """
    ]
  }

  def "testVersionFormat - OK"() {
    given:
    String versionFormat = "1.0"
    String json = """
    {
      formatVersion: '$versionFormat'
    }
    """

    when:
    MarshallerHelper.checkFormatVersion(versionFormat, JSON.parse(json))

    then:
    notThrown(Exception)
  }

  def "testVersionFormat - KO"() {
    given:
    String versionFormat = "1.0"
    String json = """
    {
      formatVersion: '2.0'
    }
    """

    when:
    MarshallerHelper.checkFormatVersion(versionFormat, JSON.parse(json))

    then:
    def e = thrown(MarshallerException)
    e.attribut == 'formatVersion'
  }
}
