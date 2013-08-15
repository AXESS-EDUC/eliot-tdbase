package org.lilie.services.eliot.tdbase.importexport.natif.marshaller

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONElement
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAtomiqueDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionDto

/**
 * Marshaller qui permet de convertir une question en une représentation à base de Map
 * qui pourra ensuite être convertie en XML ou en JSON
 *
 * @author John Tranier
 */
public class QuestionMarshaller {

  PersonneMarshaller personneMarshaller
  EtablissementMarshaller etablissementMarshaller
  MatiereMarshaller matiereMarshaller
  NiveauMarshaller niveauMarshaller
  CopyrightsTypeMarshaller copyrightsTypeMarshaller
  AttachementMarchaller attachementMarchaller
  QuestionCompositeMarshaller questionCompositeMarshaller

  Map marshall(Question question) {
    if (!question) {
      throw new IllegalArgumentException("La question ne peut pas être null")
    }

    if(question.exercice) { // Question composite
      return questionCompositeMarshaller.marshall(question)
    }

    Map representation = [
        type: question.type.code,
        titre: question.titre,
        metadonnees: [
            proprietaire: personneMarshaller.marshall(question.proprietaire),
            dateCreated: question.dateCreated,
            lastUpdated: question.lastUpdated,
            versionQuestion: question.versionQuestion,
            estAutonome: question.estAutonome,
            paternite: question.paternite ? JSON.parse(question.paternite) : null,
            copyrightsType: copyrightsTypeMarshaller.marshall(question.copyrightsType),
            referentielEliot: [
                etablissement: etablissementMarshaller.marshall(question.etablissement),
                matiere: matiereMarshaller.marshall(question.matiere),
                niveau: niveauMarshaller.marshall(question.niveau)
            ]
        ],
        specification: JSON.parse(question.specification),
        principalAttachement: attachementMarchaller.marshallPrincipalAttachement(
            question.principalAttachement,
            question.principalAttachementEstInsereDansLaQuestion
        ),
        questionAttachements: attachementMarchaller.marshallQuestionAttachements(question.questionAttachements)
    ]

    return representation
  }

  static QuestionDto parse(JSONElement jsonElement) {

    MarshallerHelper.checkIsNotNull('type', jsonElement.type)

    if(jsonElement.type == QuestionTypeEnum.Composite.name()) {
      return QuestionCompositeMarshaller.parse(jsonElement)
    }

    MarshallerHelper.checkIsNotNull('titre', jsonElement.titre)
    MarshallerHelper.checkIsJsonElement('metadonnees', jsonElement.metadonnees)
    MarshallerHelper.checkIsJsonElement('metadonnees.proprietaire', jsonElement.metadonnees.proprietaire)
    MarshallerHelper.checkIsJsonElement('metadonnees.copyrightsType', jsonElement.metadonnees.copyrightsType)
    MarshallerHelper.checkIsNotNull('specification', jsonElement.specification)
    MarshallerHelper.checkIsJsonElementOrNull('principalAttachement', jsonElement.principalAttachement)
    MarshallerHelper.checkIsJsonArray('questionAttachements', jsonElement.questionAttachements)

    return new QuestionAtomiqueDto(
        type: jsonElement.type,
        titre: jsonElement.titre,
        proprietaire: PersonneMarshaller.parse(jsonElement.metadonnees.proprietaire),
        dateCreated: MarshallerHelper.parseDate(jsonElement.metadonnees.dateCreated),
        lastUpdated: MarshallerHelper.parseDate(jsonElement.metadonnees.lastUpdated),
        versionQuestion: jsonElement.metadonnees.versionQuestion,
        estAutonome: jsonElement.metadonnees.estAutonome,
        paternite: MarshallerHelper.jsonObjectToString(jsonElement.metadonnees.paternite),
        copyrightsType: CopyrightsTypeMarshaller.parse(jsonElement.metadonnees.copyrightsType),
        etablissement: jsonElement.metadonnees.referentielEliot ?
          EtablissementMarshaller.parse(jsonElement.metadonnees.referentielEliot.etablissement) :
          null,
        matiere: jsonElement.metadonnees.referentielEliot ?
          MatiereMarshaller.parse(jsonElement.metadonnees.referentielEliot.matiere) :
          null,
        niveau: jsonElement.metadonnees.referentielEliot ?
          NiveauMarshaller.parse(jsonElement.metadonnees.referentielEliot.niveau) :
          null,
        specification: jsonElement.specification,
        principalAttachement: AttachementMarchaller.parsePrincipalAttachement(jsonElement.principalAttachement),
        questionAttachements: AttachementMarchaller.parseQuestionAttachements(jsonElement.questionAttachements)
    )
  }
}

