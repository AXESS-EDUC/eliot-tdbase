package org.lilie.services.eliot.tdbase.importexport.natif.marshaller.factory

import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.CopyrightsTypeMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.EtablissementMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MatiereBcnMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.NiveauMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.PersonneMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.QuestionMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.SujetMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.SujetSequenceQuestionsMarshaller

/**
 * Factory permettant de créer un SujetMarshaller
 *
 * @author John Tranier
 */
class SujetMarshallerFactory {


  SujetMarshaller newInstance() {
    QuestionMarshallerFactory questionMarshallerFactory = new QuestionMarshallerFactory()

    return newInstance(
        questionMarshallerFactory.newInstance()
    )
  }

  SujetMarshaller newInstance(QuestionMarshaller questionMarshaller) {
    return new SujetMarshaller(
        personneMarshaller: new PersonneMarshaller(),
        copyrightsTypeMarshaller: new CopyrightsTypeMarshaller(),
        etablissementMarshaller: new EtablissementMarshaller(),
        matiereBcnMarshaller: new MatiereBcnMarshaller(),
        niveauMarshaller: new NiveauMarshaller(),
        sujetSequenceQuestionsMarshaller: new SujetSequenceQuestionsMarshaller(
            questionMarshaller: questionMarshaller
        )
    )
  }
}
