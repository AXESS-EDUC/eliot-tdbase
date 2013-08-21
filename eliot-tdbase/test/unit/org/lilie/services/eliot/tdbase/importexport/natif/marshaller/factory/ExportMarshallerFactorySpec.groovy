package org.lilie.services.eliot.tdbase.importexport.natif.marshaller.factory

import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.ExportMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.PersonneMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.QuestionMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.SujetMarshaller
import org.lilie.services.eliot.tice.AttachementService
import spock.lang.Specification

/**
 * @author John Tranier
 */
class ExportMarshallerFactorySpec extends Specification {
  def "testNewInstance"() {
    given:
    ExportMarshallerFactory exportMarshallerFactory = new ExportMarshallerFactory()
    AttachementService attachementService = Mock(AttachementService)

    ExportMarshaller exportMarshaller = exportMarshallerFactory.newInstance(attachementService)

    expect:
    exportMarshaller.personneMarshaller instanceof PersonneMarshaller
    exportMarshaller.sujetMarshaller instanceof SujetMarshaller
    exportMarshaller.questionMarshaller instanceof QuestionMarshaller
    exportMarshaller.questionMarshaller.attachementMarchaller.attachementService == attachementService
  }
}
