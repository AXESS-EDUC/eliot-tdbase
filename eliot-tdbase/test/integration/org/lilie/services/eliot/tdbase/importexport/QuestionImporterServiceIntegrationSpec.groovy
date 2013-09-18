package org.lilie.services.eliot.tdbase.importexport

import grails.converters.JSON
import grails.plugin.spock.IntegrationSpec
import groovy.json.JsonSlurper
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.QuestionAttachement
import org.lilie.services.eliot.tdbase.QuestionAttachementService
import org.lilie.services.eliot.tdbase.QuestionService
import org.lilie.services.eliot.tdbase.QuestionTypeEnum
import org.lilie.services.eliot.tdbase.ReferentielEliot
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.SujetService
import org.lilie.services.eliot.tdbase.SujetTypeEnum
import org.lilie.services.eliot.tdbase.impl.open.OpenSpecification
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionAtomiqueDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionCompositeDto
import org.lilie.services.eliot.tdbase.importexport.dto.QuestionDto
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.ExportMarshaller
import org.lilie.services.eliot.tdbase.importexport.natif.marshaller.factory.ExportMarshallerFactory
import org.lilie.services.eliot.tdbase.utils.TdBaseInitialisationTestService
import org.lilie.services.eliot.tice.Attachement
import org.lilie.services.eliot.tice.AttachementDto
import org.lilie.services.eliot.tice.AttachementService
import org.lilie.services.eliot.tice.CopyrightsTypeEnum
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

  void "testImporteQuestion - question atomique OK"(ReferentielEliot referentielEliot,
                                                    boolean hasPrincipalAttachement,
                                                    Boolean estInsereDansLaQuestion,
                                                    int nbQuestionAttachements) {
    given:
    String titre = "titre"
    Question question = creeQuestion(
        titre,
        hasPrincipalAttachement,
        estInsereDansLaQuestion,
        nbQuestionAttachements
    )
    assert question.id

    String questionExportee = exporteQuestion(question)
    assert questionExportee

    QuestionDto questionDto = ExportMarshaller.parse(
        JSON.parse(questionExportee)
    ).question

    Sujet sujet = sujetService.createSujet(personne, 'sujet')

    when:
    Question questionImportee = questionImporterService.importeQuestion(
        (QuestionAtomiqueDto)questionDto,
        sujet,
        personne,
        referentielEliot
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
    questionImportee.versionQuestion == question.versionQuestion
    questionImportee.matiere?.id == referentielEliot?.matiere?.id
    questionImportee.niveau?.id == referentielEliot?.niveau?.id
    questionImportee.publication == null
    questionImportee.etablissement == null
    !questionImportee.publie
    new JsonSlurper().parseText(questionImportee.paternite) ==
        new JsonSlurper().parseText(question.paternite)

    if (hasPrincipalAttachement) {
      checkPrincipalAttachement(questionImportee, question)
    } else {
      assert !questionImportee.principalAttachement
    }

    checkQuestionAttachements(questionImportee.questionAttachements, question.questionAttachements)

    where:
    referentielEliot << [
        null,
        null,
        new ReferentielEliot(
            matiere: Matiere.first(),
            niveau: Niveau.first()
        )
    ]
    hasPrincipalAttachement << [true, true, false]
    estInsereDansLaQuestion << [null, false, true]
    nbQuestionAttachements << [0, 1, 5]
  }

  void "testImporteQuestion - question composite OK"(int nbQuestion) {
    given:
    Sujet exercice = creeExercice(nbQuestion)
    Question questionComposite = exercice.questionComposite
    assert questionComposite

    String questionExportee = exporteQuestion(questionComposite)
    assert questionExportee

    QuestionDto questionDto = ExportMarshaller.parse(
        JSON.parse(questionExportee)
    ).question

    Sujet sujet = sujetService.createSujet(personne, 'sujet')

    when:
    Question questionImportee = questionImporterService.importeQuestion(
        (QuestionCompositeDto) questionDto,
        sujet,
        personne
    )

    then:
    questionImportee.id
    questionImportee.id == questionImportee.exercice.questionComposite.id
    questionImportee.type.code == QuestionTypeEnum.Composite.name()
    questionImportee.exercice.id
    questionImportee.exercice.id != sujet.id
    questionImportee.exercice.sujetType.nom == SujetTypeEnum.Exercice.name()
    questionImportee.exercice.titre == exercice.titre
    (questionImportee.exercice.questionsSequences ?: []).size() == nbQuestion

    where:
    nbQuestion << [0, 1, 3]
  }

  private String exporteQuestion(Question question) {
    ExportMarshallerFactory exportMarshallerFactory = new ExportMarshallerFactory()
    ExportMarshaller exportMarshaller = exportMarshallerFactory.newInstance(attachementService)
    def converter = exportMarshaller.marshall(
        question,
        new Date(),
        personne
    ) as JSON
    return converter.toString(false)
  }

  private Sujet creeExercice(int nbQuestion) {
    Sujet sujet = sujetService.updateProprietes(
        new Sujet(),
        [
            titre: 'exercice',
            sujetType: SujetTypeEnum.Exercice.sujetType,
        ],
        personne
    )

    nbQuestion.times {
      Question question = creeQuestion("question-$it", false, null, 0)
      sujetService.insertQuestionInSujet(question, sujet, personne)
    }

    return sujet
  }

  private Question creeQuestion(String titre,
                                boolean hasPrincipalAttachement,
                                Boolean estInsereDansLaQuestion,
                                int nbQuestionAttachement) {
    Question question = questionService.createQuestion(
        [
            titre: titre,
            type: QuestionTypeEnum.Open.questionType,
            versionQuestion: 5,
            copyrightsType: CopyrightsTypeEnum.CC_BY_NC.copyrightsType
        ],
        new OpenSpecification(
            libelle: titre,
            nombreLignesReponse: 5
        ),
        personne
    )
    assert !question.hasErrors()

    if (hasPrincipalAttachement) {
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
            bytes: blob.bytes
        )
    )
  }

  private void checkPrincipalAttachement(Question questionImportee, Question question) {
    assert questionImportee.principalAttachementEstInsereDansLaQuestion ==
        question.principalAttachementEstInsereDansLaQuestion

    checkAttachement(questionImportee.principalAttachement, question.principalAttachement)
  }

  private void checkQuestionAttachements(List<QuestionAttachement> questionAttachementsImportes,
                                         List<QuestionAttachement> questionAttachements) {

    assert questionAttachementsImportes?.size() == questionAttachements?.size()

    Iterator iterator = questionAttachements.iterator()
    questionAttachementsImportes.each { QuestionAttachement questionAttachementImporte ->
      QuestionAttachement questionAttachement = (QuestionAttachement) iterator.next()

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
