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

  Map marshall(Sujet sujet, AttachementDataStore attachementDataStore) {
    if (!sujet) {
      throw new IllegalArgumentException("Le sujet ne peut pas être null")
    }

    Map representation = [
        class: ExportClass.SUJET.name(),
        type: sujet.sujetType.nom,
        titre: sujet.titre,
        id: sujet.id.toString(),
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
              sujetSequenceQuestionsMarshaller.marshall(it, attachementDataStore)
            } ?: []
        ]
    ]

    return representation
  }

  static SujetDto parse(JSONElement jsonElement, AttachementDataStore attachementDataStore) {
    MarshallerHelper.checkClass(ExportClass.SUJET, jsonElement)
    MarshallerHelper.checkIsNotNull('type', jsonElement.type)
    MarshallerHelper.checkIsNotNull('titre', jsonElement.titre)
    MarshallerHelper.checkIsJsonElement('metadonnees', jsonElement.metadonnees)
    MarshallerHelper.checkIsJsonElement('metadonnees.proprietaire', jsonElement.metadonnees.proprietaire)
    MarshallerHelper.checkIsJsonElement('metadonnees.copyrightsType', jsonElement.metadonnees.copyrightsType)
    MarshallerHelper.checkIsJsonElement('specification', jsonElement.specification)
    MarshallerHelper.checkIsJsonArray('specification.questionsSequences', jsonElement.specification.questionsSequences)

    return new SujetDto(
        titre: jsonElement.titre,
        proprietaire: PersonneMarshaller.parse(jsonElement.metadonnees.proprietaire),
        type: jsonElement.type,
        versionSujet: jsonElement.metadonnees.versionSujet,
        paternite: MarshallerHelper.jsonObjectToString(jsonElement.metadonnees.paternite),
        copyrightsType: CopyrightsTypeMarshaller.parse(jsonElement.metadonnees.copyrightsType),
        presentation: MarshallerHelper.jsonObjectToString(jsonElement.specification.presentation),
        annotationPrivee: MarshallerHelper.jsonObjectToString(jsonElement.specification.annotationPrivee),
        dureeMinutes: MarshallerHelper.jsonObjectToObject(jsonElement.specification.dureeMinutes),
        noteMax: MarshallerHelper.jsonObjectToObject(jsonElement.specification.noteMax),
        noteAutoMax: MarshallerHelper.jsonObjectToObject(jsonElement.specification.noteAutoMax),
        noteEnseignantMax: MarshallerHelper.jsonObjectToObject(jsonElement.specification.noteEnseignantMax),
        accesSequentiel: MarshallerHelper.jsonObjectToObject(jsonElement.specification.accesSequentiel),
        ordreQuestionsAleatoire: MarshallerHelper.jsonObjectToObject(jsonElement.specification.ordreQuestionsAleatoire),
        questionsSequences: jsonElement.specification.questionsSequences.collect {
          SujetSequenceQuestionsMarshaller.parse(it, attachementDataStore)
        }
    )
  }
}
