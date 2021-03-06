package org.lilie.services.eliot.tdbase.importexport.natif.marshaller.factory

import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.CopyrightsTypeMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.EtablissementMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MatiereBcnMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.NiveauMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.PersonneMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.SujetMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.SujetSequenceQuestionsMarshaller
import spock.lang.Specification

/**
 * @author John Tranier
 */
class SujetMarshallerFactorySpec extends Specification {

  def "testNewInstance"() {
    given:
    SujetMarshallerFactory sujetMarshallerFactory = new SujetMarshallerFactory()

    SujetMarshaller sujetMarshaller = sujetMarshallerFactory.newInstance()

    expect:
    sujetMarshaller.personneMarshaller instanceof PersonneMarshaller
    sujetMarshaller.copyrightsTypeMarshaller instanceof CopyrightsTypeMarshaller
    sujetMarshaller.etablissementMarshaller instanceof EtablissementMarshaller
    sujetMarshaller.matiereBcnMarshaller instanceof MatiereBcnMarshaller
    sujetMarshaller.niveauMarshaller instanceof NiveauMarshaller
    sujetMarshaller.sujetSequenceQuestionsMarshaller instanceof SujetSequenceQuestionsMarshaller
  }
}
