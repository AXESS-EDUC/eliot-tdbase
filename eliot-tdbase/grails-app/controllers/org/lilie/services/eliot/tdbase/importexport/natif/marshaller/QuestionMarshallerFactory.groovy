package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import org.lilie.services.eliot.tice.AttachementService

/**
 * Factory permettant de créer un QuestionMarshaller
 *
 * @author John Tranier
 */
class QuestionMarshallerFactory {

  QuestionMarshaller newInstance(AttachementService attachementService) {
    return new QuestionMarshaller(
        personneMarshaller: new PersonneMarshaller(),
        etablissementMarshaller: new EtablissementMarshaller(),
        matiereMarshaller:  new MatiereMarshaller(),
        niveauMarshaller: new NiveauMarshaller(),
        copyrightsTypeMarshaller: new CopyrightsTypeMarshaller(),
        attachementMarchaller: new AttachementMarchaller(
            attachementService: attachementService
        )
    )

  }

}
