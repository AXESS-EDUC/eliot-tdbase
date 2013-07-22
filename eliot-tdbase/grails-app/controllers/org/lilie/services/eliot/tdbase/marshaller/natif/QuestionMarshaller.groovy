package org.lilie.services.eliot.tdbase.marshaller.natif

import grails.converters.JSON
import org.lilie.services.eliot.tdbase.Question

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
  AttachementMarchaller attachementMarchaller = new AttachementMarchaller()

  Map marshall(Question question) {
    if (!question) {
      throw new IllegalArgumentException("La question ne peut pas être null")
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
            referentiel: [
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

}