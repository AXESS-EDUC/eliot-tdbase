package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tice.AttachementService
import spock.lang.Specification

/**
 * @author John Tranier
 */
class QuestionMarshallerFactorySpec extends Specification {

  def "testNewinstance"() {
    given:
    QuestionMarshallerFactory questionMarshallerFactory = new QuestionMarshallerFactory()
    AttachementService attachementService = Mock(AttachementService)

    expect:
    QuestionMarshaller questionMarshaller = questionMarshallerFactory.newInstance(attachementService)
    questionMarshaller.personneMarshaller instanceof PersonneMarshaller
    questionMarshaller.etablissementMarshaller instanceof EtablissementMarshaller
    questionMarshaller.matiereMarshaller instanceof MatiereMarshaller
    questionMarshaller.niveauMarshaller instanceof  NiveauMarshaller
    questionMarshaller.copyrightsTypeMarshaller instanceof CopyrightsTypeMarshaller
    questionMarshaller.attachementMarchaller instanceof AttachementMarchaller
    questionMarshaller.attachementMarchaller.attachementService == attachementService

  }
}
