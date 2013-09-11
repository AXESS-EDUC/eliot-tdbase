package org.lilie.services.eliot.tdbase.importexport.natif.marshaller.factory

import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.AttachementMarchaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.CopyrightsTypeMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.EtablissementMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MatiereMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.NiveauMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.PersonneMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.QuestionMarshaller
import spock.lang.Specification

/**
 * @author John Tranier
 */
class QuestionMarshallerFactorySpec extends Specification {

  def "testNewinstance"() {
    given:
    QuestionMarshallerFactory questionMarshallerFactory = new QuestionMarshallerFactory()

    QuestionMarshaller questionMarshaller = questionMarshallerFactory.newInstance()

    expect:
    questionMarshaller.personneMarshaller instanceof PersonneMarshaller
    questionMarshaller.etablissementMarshaller instanceof EtablissementMarshaller
    questionMarshaller.matiereMarshaller instanceof MatiereMarshaller
    questionMarshaller.niveauMarshaller instanceof  NiveauMarshaller
    questionMarshaller.copyrightsTypeMarshaller instanceof CopyrightsTypeMarshaller
    questionMarshaller.attachementMarchaller instanceof AttachementMarchaller

  }
}
