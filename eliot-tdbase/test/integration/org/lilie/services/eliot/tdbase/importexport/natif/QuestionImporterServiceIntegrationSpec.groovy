package org.lilie.services.eliot.tdbase.importexport.natif

import grails.converters.JSON
import grails.plugin.spock.IntegrationSpec
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionAttachement
import org.lilie.services.eliot.tdbase.QuestionAttachementService
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.impl.open.OpenSpecification
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.QuestionMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.factory.QuestionMarshallerFactory
import org.lilie.services.eliot.tdbase.utils.TdBaseInitialisationTestService
import org.lilie.services.eliot.tice.Attachement
import org.lilie.services.eliot.tice.AttachementDto
import org.lilie.services.eliot.tice.AttachementService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.utils.BootstrapService

/**
 * @author John Tranier
 */
class QuestionImporterServiceIntegrationSpec extends IntegrationSpec {

  TdBaseInitialisationTestService tdBaseInitialisationTestService
  SujetService sujetService
  QuestionService questionService
  QuestionImporterService questionImporterService
  AttachementService attachementService
  QuestionAttachementService questionAttachementService
  BootstrapService bootstrapService

  Personne personne

  def setup() {
    personne = tdBaseInitialisationTestService.utilisateur1.personne
    bootstrapService.bootstrapForIntegrationTest()

    assert Matiere.first()
    assert Niveau.first()
  }

  void testImporteQuestion(String titre,
                           Matiere matiere,
                           Niveau niveau,
                           boolean hasPrincipalAttachement,
                           Boolean estInsereDansLaQuestion,
                           int nbQuestionAttachements) {
    given:
    Question question = creeQuestion(
        titre,
        hasPrincipalAttachement,
        estInsereDansLaQuestion,
        nbQuestionAttachements
    )
    assert question.id

    String questionExportee = exporteQuestion(question)
    assert questionExportee

    Sujet sujet = sujetService.createSujet(personne, 'sujet')

    when:
    Question questionImportee = questionImporterService.importeQuestion(
        questionExportee.bytes,
        sujet,
        personne,
        matiere,
        niveau
    )

    then:
    questionImportee.id
    questionImportee.id != question.id
    questionImportee.titre == question.titre
    questionImportee.type == question.type
    questionImportee.titreNormalise == question.titreNormalise
    questionImportee.copyrightsType == question.copyrightsType
    questionImportee.specification == question.specification
    questionImportee.specificationNormalise == question.specificationNormalise
    questionImportee.estAutonome == question.estAutonome
    questionImportee.paternite == question.paternite
    questionImportee.versionQuestion == question.versionQuestion
    questionImportee.matiere?.id == matiere?.id
    questionImportee.niveau?.id == niveau?.id
    questionImportee.publication == null
    questionImportee.etablissement == null
    !questionImportee.publie

    if(hasPrincipalAttachement) {
      checkPrincipalAttachement(questionImportee, question)
    }
    else {
      assert !questionImportee.principalAttachement
    }

    checkQuestionAttachements(questionImportee.questionAttachements, question.questionAttachements)

    where:
    titre = "titre"
    matiere << [null, null, Matiere.first()]
    niveau << [null, null, Niveau.first()]
    hasPrincipalAttachement << [true, true, false]
    estInsereDansLaQuestion << [null, false, true]
    nbQuestionAttachements << [0, 1, 5]
  }

  private String exporteQuestion(Question question) {
    QuestionMarshallerFactory questionMarshallerFactory = new QuestionMarshallerFactory()
    QuestionMarshaller questionMarshaller = questionMarshallerFactory.newInstance(attachementService)
    def converter = questionMarshaller.marshall(question) as JSON
    return converter.toString(false)
  }

  private Question creeQuestion(String titre,
                                boolean hasPrincipalAttachement,
                                Boolean estInsereDansLaQuestion,
                                int nbQuestionAttachement) {
    Question question = questionService.createQuestion(
        [
            titre: titre,
            type: QuestionTypeEnum.Open.questionType,
            versionQuestion: 5
        ],
        new OpenSpecification(
            libelle: titre,
            nombreLignesReponse: 5
        ),
        personne
    )

    if(hasPrincipalAttachement) {
      Attachement attachement = creeAttachement("principalAttachement")
      questionAttachementService.createPrincipalAttachementForQuestion(
          attachement,
          question,
          estInsereDansLaQuestion
      )
    }

    nbQuestionAttachement.times {
      Attachement attachement = creeAttachement("questionAttachement-$it")
      questionAttachementService.createAttachementForQuestion(
          attachement,
          question,
          estInsereDansLaQuestion,
          it
      )
    }

    return question
  }

  private Attachement creeAttachement(String nom) {
    String blob = "blob-$nom"

    return attachementService.createAttachement(
        new AttachementDto(
            taille: blob.size(),
            nom: "nom-$nom",
            typeMime: "typeMime-$nom",
            nomFichierOriginal: "nomFichierOriginal-$nom",
            inputStream: new ByteArrayInputStream(blob.bytes)
        )
    )
  }

  private void checkPrincipalAttachement(Question questionImportee, Question question) {
    assert questionImportee.principalAttachementEstInsereDansLaQuestion ==
        question.principalAttachementEstInsereDansLaQuestion

    checkAttachement(questionImportee.principalAttachement, question.principalAttachement)
  }

  private void checkQuestionAttachements(SortedSet<QuestionAttachement> questionAttachementsImportes,
                                         SortedSet<QuestionAttachement> questionAttachements) {

    assert questionAttachementsImportes?.size() == questionAttachements?.size()

    Iterator iterator = questionAttachements.iterator()
    questionAttachementsImportes.each { QuestionAttachement questionAttachementImporte ->
      QuestionAttachement questionAttachement = (QuestionAttachement)iterator.next()

        assert questionAttachementImporte.rang == questionAttachement.rang
        assert questionAttachementImporte.estInsereDansLaQuestion == questionAttachement.estInsereDansLaQuestion
        checkAttachement(questionAttachementImporte.attachement, questionAttachement.attachement)
    }
  }

  private void checkAttachement(Attachement attachementImporte, Attachement attachement) {
    assert attachementImporte.id != attachement.id
    assert attachementImporte.chemin == attachement.chemin
    assert attachementImporte.nom == attachement.nom
    assert attachementImporte.nomFichierOriginal == attachement.nomFichierOriginal
    assert attachementImporte.taille == attachement.taille
    assert attachementImporte.typeMime == attachement.typeMime
    assert attachementImporte.aSupprimer == attachement.aSupprimer
  }
}
