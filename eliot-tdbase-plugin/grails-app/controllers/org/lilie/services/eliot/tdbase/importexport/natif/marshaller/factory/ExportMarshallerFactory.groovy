package org.lilie.services.eliot.tdbase.importexport.natif.marshaller.factory

import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.AttachementDatastoreMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.ExportMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.PersonneMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.QuestionMarshaller
import org.lilie.services.eliot.tice.AttachementService

/**
 * Factory permettant de créer un ExportMarshaller
 *
 * @author John Tranier
 */
class ExportMarshallerFactory {

  ExportMarshaller newInstance(AttachementService attachementService) {
    SujetMarshallerFactory sujetMarshallerFactory = new SujetMarshallerFactory()
    QuestionMarshallerFactory questionMarshallerFactory = new QuestionMarshallerFactory()

    QuestionMarshaller questionMarshaller = questionMarshallerFactory.newInstance()

    return new ExportMarshaller(
        personneMarshaller: new PersonneMarshaller(),
        sujetMarshaller: sujetMarshallerFactory.newInstance(questionMarshaller),
        questionMarshaller: questionMarshaller,
        attachementService: attachementService,
        attachementDatastoreMarshaller: new AttachementDatastoreMarshaller()
    )
  }
}
