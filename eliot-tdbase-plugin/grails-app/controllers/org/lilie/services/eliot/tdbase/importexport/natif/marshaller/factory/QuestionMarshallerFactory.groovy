package org.lilie.services.eliot.tdbase.importexport.natif.marshaller.factory

import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.AttachementMarchaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.CopyrightsTypeMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.EtablissementMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MatiereBcnMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.NiveauMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.PersonneMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.QuestionCompositeMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.QuestionMarshaller

/**
 * Factory permettant de créer un QuestionMarshaller
 *
 * @author John Tranier
 */
class QuestionMarshallerFactory {

  QuestionMarshaller newInstance() {
    SujetMarshallerFactory sujetMarshallerFactory = new SujetMarshallerFactory()

    QuestionMarshaller questionMarshaller = new QuestionMarshaller(
        personneMarshaller: new PersonneMarshaller(),
        etablissementMarshaller: new EtablissementMarshaller(),
        matiereBcnMarshaller:  new MatiereBcnMarshaller(),
        niveauMarshaller: new NiveauMarshaller(),
        copyrightsTypeMarshaller: new CopyrightsTypeMarshaller(),
        attachementMarchaller: new AttachementMarchaller()
    )

    questionMarshaller.questionCompositeMarshaller =
      new QuestionCompositeMarshaller(
          sujetMarshaller: sujetMarshallerFactory.newInstance(questionMarshaller)
      )

    return questionMarshaller
  }

}
