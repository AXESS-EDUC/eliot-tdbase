package org.lilie.services.eliot.tdbase.marshaller.natif

import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.securite.DomainAutorite
import spock.lang.Specification

/**
 * @author John Tranier
 */
class PersonneMarshallerSpec extends Specification {

  PersonneMarshaller personneMarshaller = new PersonneMarshaller()

  def "testMarshall - argument null"() {
    expect:
    personneMarshaller.marshall(null) == null
  }

  def "testMarshall - cas général"(Personne personne) {
    given:
    Map representation = personneMarshaller.marshall(personne)

    expect:
    representation.size() == 3
    representation.nom == personne.nom
    representation.prenom == personne.prenom
    representation.identifiant == personne.autorite.identifiant

    where:
    personne = new Personne(
        nom: "nom",
        prenom: "prenom",
        autorite: new DomainAutorite(
            identifiant: "identifiant"
        )
    )
  }
}
