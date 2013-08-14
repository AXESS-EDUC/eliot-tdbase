package org.lilie.services.eliot.tdbase.importexport.natif.marshaller.factory

import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.CopyrightsTypeMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.EtablissementMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MatiereMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.NiveauMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.PersonneMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.SujetMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.SujetSequenceQuestionsMarshaller
import org.lilie.services.eliot.tice.AttachementService

/**
 * Factory permettant de créer un SujetMarshaller
 *
 * @author John Tranier
 */
class SujetMarshallerFactory {

  QuestionMarshallerFactory questionMarshallerFactory = new QuestionMarshallerFactory()

  SujetMarshaller newInstance(AttachementService attachementService) {
    return new SujetMarshaller(
        personneMarshaller: new PersonneMarshaller(),
        copyrightsTypeMarshaller: new CopyrightsTypeMarshaller(),
        etablissementMarshaller: new EtablissementMarshaller(),
        matiereMarshaller: new MatiereMarshaller(),
        niveauMarshaller: new NiveauMarshaller(),
        sujetSequenceQuestionsMarshaller: new SujetSequenceQuestionsMarshaller(
            questionMarshaller: questionMarshallerFactory.newInstance(attachementService)
        )
    )
  }
}
