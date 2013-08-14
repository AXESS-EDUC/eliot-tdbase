package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.importexport.dto.SujetDto

/**
 * Marshaller qui permet de convertir un sujet en une représentation à base de Map
 * qui pourra ensuite être convertie en XML ou en JSON
 *
 * @author John Tranier
 */
class SujetMarshaller {

  PersonneMarshaller personneMarshaller
  CopyrightsTypeMarshaller copyrightsTypeMarshaller
  EtablissementMarshaller etablissementMarshaller
  MatiereMarshaller matiereMarshaller
  NiveauMarshaller niveauMarshaller
  SujetSequenceQuestionsMarshaller sujetSequenceQuestionsMarshaller

  Map marshall(Sujet sujet) {
    if (!sujet) {
      throw new IllegalArgumentException("Le sujet ne peut pas être null")
    }

    Map representation = [
        type: sujet.sujetType.id,
        titre: sujet.titre,
        metadonnees: [
            proprietaire: personneMarshaller.marshall(sujet.proprietaire),
            dateCreated: sujet.dateCreated,
            lastUpdated: sujet.lastUpdated,
            versionSujet: sujet.versionSujet,
            paternite: sujet.paternite ? JSON.parse(sujet.paternite) : null,
            copyrightsType: copyrightsTypeMarshaller.marshall(sujet.copyrightsType),
            referentielEliot: [
                etablissement: etablissementMarshaller.marshall(sujet.etablissement),
                matiere: matiereMarshaller.marshall(sujet.matiere),
                niveau: niveauMarshaller.marshall(sujet.niveau)
            ]
        ],
        specification: [
            presentation: sujet.presentation,
            annotationPrivee: sujet.annotationPrivee,
            dureeMinutes: sujet.dureeMinutes,
            noteMax: sujet.noteMax,
            noteAutoMax: sujet.noteAutoMax,
            noteEnseignantMax: sujet.noteEnseignantMax,
            accesSequentiel: sujet.accesSequentiel,
            ordreQuestionsAleatoire: sujet.ordreQuestionsAleatoire,
            questionsSequences: sujet.questionsSequences?.collect {
              sujetSequenceQuestionsMarshaller.marshall(it)
            }
        ]
    ]

    return representation
  }

  static SujetDto parse(JSONElement jsonElement) {
    // TODO Implémenter
  }
}
