package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.lilie.services.eliot.tdbase.importexport.dto.PersonneDto
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MarshallerException
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.MarshallerHelper
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.PersonneMarshaller
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.securite.DomainAutorite
import spock.lang.Specification

/**
 * @author John Tranier
 */
class PersonneMarshallerSpec extends Specification {

  PersonneMarshaller personneMarshaller

  def setup() {
    personneMarshaller = new PersonneMarshaller()
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

  def "testMarshall - argument null"() {
    expect:
    personneMarshaller.marshall(null) == null
  }

  def "testParse - cas général"(String nom, String prenom, String identifiant) {
    given:
    String json = """
      {
        nom: $nom,
        prenom: $prenom,
        identifiant: $identifiant
      }
    """

    PersonneDto personneDto = PersonneMarshaller.parse(
        JSON.parse(json)
    )

    expect:
    personneDto.nom == nom
    personneDto.prenom == prenom
    personneDto.identifiant == identifiant

    where:
    nom << [null, 'nom']
    prenom << [null, 'prenom']
    identifiant = 'identifiant'
  }

  def "testParse - erreur identifiant manquant"(String nom, String prenom, String identifiant) {
    given:
    String json = """
      {
        nom: '$nom',
        prenom: '$prenom',
        identifiant: ${MarshallerHelper.asJsonString(identifiant)}
      }
    """

    when:
    PersonneMarshaller.parse(
        JSON.parse(json)
    )

    then:
    MarshallerException e = thrown(MarshallerException)
    e.attribut == 'personne.identifiant'

    where:
    nom = 'nom'
    prenom = 'prenom'
    identifiant << [null, '']
  }
}
