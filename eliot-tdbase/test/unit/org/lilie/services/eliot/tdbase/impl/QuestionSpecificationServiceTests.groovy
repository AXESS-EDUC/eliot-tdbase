package org.lilie.services.eliot.tdbase.impl

import grails.validation.ValidationErrors
import org.lilie.services.eliot.tdbase.QuestionSpecification
import org.lilie.services.eliot.tdbase.QuestionSpecificationService
import org.lilie.services.eliot.tdbase.Specification
import org.lilie.services.eliot.tdbase.impl.decimal.DecimalSpecification
import org.lilie.services.eliot.tdbase.impl.decimal.QuestionDecimalSpecificationService
import org.lilie.services.eliot.tdbase.impl.document.DocumentSpecification
import org.lilie.services.eliot.tdbase.impl.document.QuestionDocumentSpecificationService
import org.lilie.services.eliot.tdbase.impl.exclusivechoice.ExclusiveChoiceSpecification
import org.lilie.services.eliot.tdbase.impl.exclusivechoice.ExclusiveChoiceSpecificationReponsePossible
import org.lilie.services.eliot.tdbase.impl.exclusivechoice.QuestionExclusiveChoiceSpecificationService
import org.lilie.services.eliot.tdbase.impl.fillgap.FillGapSpecification
import org.lilie.services.eliot.tdbase.impl.integer.IntegerSpecification
import org.lilie.services.eliot.tdbase.impl.integer.QuestionIntegerSpecificationService
import org.lilie.services.eliot.tdbase.impl.multiplechoice.MultipleChoiceSpecification
import org.lilie.services.eliot.tdbase.impl.multiplechoice.MultipleChoiceSpecificationReponsePossible
import org.lilie.services.eliot.tdbase.impl.multiplechoice.QuestionMultipleChoiceSpecificationService
import org.lilie.services.eliot.tdbase.impl.order.OrderSpecification
import org.lilie.services.eliot.tdbase.impl.statement.QuestionStatementSpecificationService
import org.lilie.services.eliot.tdbase.impl.statement.StatementSpecification

class QuestionSpecificationServiceTests extends GroovyTestCase {

  void testServices() {

    def testSetup = [
            [new QuestionDecimalSpecificationService(), decimalSpecification()],
            [new QuestionDocumentSpecificationService(), documentSpecification()],
            [new QuestionExclusiveChoiceSpecificationService(), exclusiveChoiseSpec()],
            // [new QuestionFillGapSpecificationService(), fillGapSpecification()],
            [new QuestionIntegerSpecificationService(), integerSpecification()],
            [new QuestionMultipleChoiceSpecificationService(), multipleChoiceSpecification()],
            // [new QuestionOrderSpecificationService(), orderSpecification()],
            [new QuestionStatementSpecificationService(), new StatementSpecification([enonce: "We should improve our carbon footprint."])]
    ]

    testSetup.each {
      executeTestgetSpecificationFromObjectAndViceVersa((QuestionSpecificationService) it[0], (QuestionSpecification) it[1])
      executeTestGetObjectFromNullSpecification(it[0])
      executeTestSpecificationNormaliseFromObject(it[0], it[1])
    }

  }



  def orderSpecification() {

    def List<String> orderedItems = ["TheNumberOne", "TheNumberTwo", "TheNumberThree"];

    new OrderSpecification([libelle: "Please put this mess into order!",
                                   correction: "Yes chap, that's the right way of doing it",
                                   orderedItems: orderedItems])
  }

  def fillGapSpecification() {

    new FillGapSpecification([
                                     libelle: "Please fill in the gaps.",
                                     modeDeSaisie: "MLM",
                                     texteATrous: "The color of blood is {=red}. Major blood vessels are {~feet=arteries=veins} and {=veins=arteries~hair~\\~moo\\}\\=\\{}.",
                                     correction: "The color of blood is red. Major blood vessels are arteries and veins."
                             ])
  }


  def integerSpecification() {
    new IntegerSpecification([
                                     libelle: "IntegerSpec",
                                     valeur: 1i,
                                     unite: "hour",
                                     correction: "should be between 1 and 24"
                             ])
  }

  def multipleChoiceSpecification() {
    def rep1 = new MultipleChoiceSpecificationReponsePossible(
            libelleReponse: "réponse 1",
            id: "1"
    )
    def rep2 = new MultipleChoiceSpecificationReponsePossible(
            libelleReponse: "réponse 2",
            estUneBonneReponse: true,
            id: "2"
    )
    def rep3 = new MultipleChoiceSpecificationReponsePossible(
            libelleReponse: "réponse 3",
            estUneBonneReponse: true,
            id: "3"
    )
    def specObject = new MultipleChoiceSpecification(
            libelle: "Quelle est la bonne réponse",
            correction: "Attention la 1 n'est pas la bonne",
            reponses: [rep1, rep2, rep3]
    )
    specObject
  }

  def decimalSpecification() {
    new DecimalSpecification(
            libelle: "Hello Title",
            valeur: 12,
            unite: "km",
            precision: 1,
            correction: "Kilometrers should be a positive number"
    )
  }

  def documentSpecification() {
    new DocumentSpecification(
            auteur: "Franck",
            source: "aSource",
            presentation: "aPresentation",
            type: "aType",
            urlExterne: "http://where.can.i.find.you",
            questionAttachementId: 23,
            estInsereDansLeSujet: true
    )
  }

  def exclusiveChoiseSpec() {

    def resp1 = new ExclusiveChoiceSpecificationReponsePossible(libelleReponse: "Response1", id: "1");
    def resp2 = new ExclusiveChoiceSpecificationReponsePossible(libelleReponse: "Response2", id: "2");
    def resp3 = new ExclusiveChoiceSpecificationReponsePossible(libelleReponse: "Response3", id: "3");

    new ExclusiveChoiceSpecification(
            libelle: "An Exclusive Choice",
            correction: "Thats what was supposed to be done!",
            reponses: [resp1, resp2, resp3],
            indexBonneReponse: "2"
    )
  }

  def executeTestgetSpecificationFromObjectAndViceVersa(QuestionSpecificationService service, QuestionSpecification specObject) {
    String specString = service.getSpecificationFromObject(specObject)

    Specification specObject2 = service.getObjectFromSpecification(specString)
    superCoolValidator(specObject, specObject2)
    println "Json initial: ${specString}"
    println "Json généré : ${service.getSpecificationFromObject(specObject2)}"

//        assertEquals(service.getSpecificationFromObject(specObject2), specString)
  }

  def executeTestGetObjectFromNullSpecification(service) {
    assertNotNull service.getObjectFromSpecification(null)
  }

  def executeTestSpecificationNormaliseFromObject(QuestionSpecificationService service, Specification specObject) {

    /*    assertNull(service.getSpecificationNormaliseFromObject(null));
   specObject.libelle = "ToTo"

   println(service.getSpecificationNormaliseFromObject(specObject))
   assertEquals("TOTO", service.getSpecificationNormaliseFromObject(specObject))*/
  }

  def superCoolValidator(spec1, spec2) {

    spec1.properties.each {

      if (it.value instanceof List) {
        def propertyName = it.key
        def spec1List = it.value
        def spec2List = spec2.getProperty(it.key)

        Map index = new HashMap()
        spec1List.each {
          index.put(it.properties, it.properties)
        }
        spec2List.each {
          assertEquals("Erreur lors de la comparaison de " + spec1.class.name + "." + propertyName, index.get(it.properties), it.properties)
        }
      }

      else if (it.value instanceof Float) {

        assertNotNull spec2.getProperty(it.key)
        assertEquals "Specification initiale et celle generée ne sont pas égales", it.value, spec2.getProperty(it.key), 0f
      } else if (!(it.value instanceof ValidationErrors)) {
        assertEquals("Specification initiale et celle generée ne sont pas égales", it.value, spec2.getProperty(it.key))
      }
    }
  }

  def testGetTexteATrous() {
    def fillGap = fillGapSpecification()
    println fillGap.texteATrous
    println fillGap.motsSugeres
    println fillGap.toMap()
  }
}