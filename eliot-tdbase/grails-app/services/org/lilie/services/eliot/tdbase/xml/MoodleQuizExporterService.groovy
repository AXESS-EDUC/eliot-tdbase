/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */
package org.lilie.services.eliot.tdbase.xml

import groovy.xml.MarkupBuilder
import org.lilie.services.eliot.tdbase.Question
import org.lilie.services.eliot.tdbase.Sujet
import org.lilie.services.eliot.tdbase.impl.associate.AssociateSpecification
import org.lilie.services.eliot.tdbase.impl.associate.Association
import org.lilie.services.eliot.tdbase.impl.decimal.DecimalSpecification
import org.lilie.services.eliot.tdbase.impl.exclusivechoice.ExclusiveChoiceSpecification
import org.lilie.services.eliot.tdbase.impl.fileupload.FileUploadSpecification
import org.lilie.services.eliot.tdbase.impl.fillgap.FillGapSpecification
import org.lilie.services.eliot.tdbase.impl.fillgraphics.FillGraphicsSpecification
import org.lilie.services.eliot.tdbase.impl.graphicmatch.GraphicMatchSpecification
import org.lilie.services.eliot.tdbase.impl.integer.IntegerSpecification
import org.lilie.services.eliot.tdbase.impl.multiplechoice.MultipleChoiceSpecification
import org.lilie.services.eliot.tdbase.impl.open.OpenSpecification
import org.lilie.services.eliot.tdbase.impl.order.OrderSpecification
import org.lilie.services.eliot.tdbase.impl.slider.SliderSpecification
import org.lilie.services.eliot.tdbase.impl.statement.StatementSpecification
import org.lilie.services.eliot.tdbase.impl.multiplechoice.MultipleChoiceSpecificationReponsePossible
import org.lilie.services.eliot.tdbase.impl.exclusivechoice.ExclusiveChoiceSpecificationReponsePossible
import org.lilie.services.eliot.tdbase.impl.booleanmatch.BooleanMatchSpecification

/**
 * Service d'export d'un quiz moodle.
 * @author bert poller
 */
class MoodleQuizExporterService {

  /**
   * Exporter un sujet sous format d'un moodle quiz.
   * @param sujet
   * @return
   */
  String toMoodleQuiz(Sujet sujet) {
    new File("/home/bert/questions.json").write(sujet.questions.collect {it.specification}.toString(), "UTF-8")
    renderQuiz(sujet.questions)
  }

  /**
   * Exporter une Question sous format d'un moodle quiz.
   * @param questionSpecification
   * @return
   */
  String toMoodleQuiz(Question question) {
    if (question.type.code.equals("Composite")) {
      renderQuiz(question.exercice.questions)
    } else {
      renderQuiz([question])
    }
  }

  /**
   * Render the <quiz> tag.
   * @param questionSpecifications
   * @return
   */
  private String renderQuiz(List<Question> question) {
    def writer = new StringWriter()
    def xml = new MarkupBuilder(writer)

    xml.quiz() {
      question.each {
        if (it.type.code.equals("Composite")) {
          renderCompositeQuestion(xml, it)
        } else {
          renderQuestion(xml, it.specificationObject, it.titre)
        }
      }
    }

    prependHeader writer.toString()
  }

  private void renderCompositeQuestion(MarkupBuilder xml, Question question) {
    question.exercice.questions.each {
      renderQuestion(xml, it.specificationObject, "Question Composée -- " + it.titre)
    }
  }

  /**
   * Render the <question> tag for associate questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, AssociateSpecification specification, String title) {
    xml.question(type: "matching") {
      questionHeader(xml, title, specification.libelle)

      def fraction = 100 / specification.associations.size()

      specification.associations.each {Association association ->
        xml.subquestion {
          xml.text association.participant1
          xml.anwer(fraction: fraction) {xml.text association.participant2}
        }
      }
      xml.shuffleanswers false
      correction(xml, specification.correction)
    }
  }

  /**
   * Render the <question> tag for decimal questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, DecimalSpecification specification, String title) {
    xml.question(type: "numerical") {
      questionHeader(xml, title, specification.libelle)
      xml.answer(fraction: 100) {
        xml.text specification.valeur
        xml.unit(name: specification.unite, multiplier: 1)
        xml.tollerance specification.precision
      }
      correction(xml, specification.correction)
    }
  }

  /**
   * Render the <question> tag for Integer questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, IntegerSpecification specification, String title) {
    xml.question(type: "numerical") {
      questionHeader(xml, title, specification.libelle)
      xml.answer(fraction: 100) {
        xml.text specification.valeur
        xml.unit(name: specification.unite, multiplier: 1)
      }
      correction(xml, specification.correction)
    }
  }

  /**
   * Render the <question> tag for multiple choice questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, MultipleChoiceSpecification specification, String title) {
    xml.question(type: "multichoice") {
      questionHeader(xml, title, specification.libelle)

      def goodFraction = calculateGoodFraction(specification)
      def badFraction = calculateBadFraction(specification)

      specification.reponses.each { MultipleChoiceSpecificationReponsePossible reponse ->
        xml.answer(fraction: reponse.estUneBonneReponse ? goodFraction : badFraction) {
          xml.text reponse.libelleReponse
        }
      }
      xml.shuffleanwers specification.shuffled ? 1 : 0
      xml.single 0
      correction(xml, specification.correction)
    }
  }

  private calculateGoodFraction(MultipleChoiceSpecification specification) {
    def goodCount = specification.reponses.count {it.estUneBonneReponse}
    goodCount > 0 ? 100 / goodCount : 0
  }

  private calculateBadFraction(MultipleChoiceSpecification specification) {
    def badCount = specification.reponses.count {!it.estUneBonneReponse}
    badCount > 0 ? -100 / badCount : 0
  }

  /**
   * Render the <question> tag for exclusive choice questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, ExclusiveChoiceSpecification specification, String title) {
    xml.question(type: "multichoice") {
      questionHeader(xml, title, specification.libelle)
      def badFraction = -100 / specification.reponses.size()

      specification.reponses.eachWithIndex { ExclusiveChoiceSpecificationReponsePossible reponse, int i ->
        xml.answer(fraction: specification.indexBonneReponse.toInteger() == i + 1 ? 100 : badFraction) {
          xml.text reponse.libelleReponse
        }
      }
      xml.shuffleanwers specification.shuffled ? 1 : 0
      xml.single 1
      correction(xml, specification.correction)
    }
  }

  /**
   * Render the <question> tag for open questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, OpenSpecification specification, String title) {

    xml.question(type: "essay") {
      questionHeader(xml, title, specification.libelle)
      xml.answer(fraction: 0) {
        xml.text()
      }
      correction(xml, specification.correction)
    }

  }

  /**
   * Render the <question> tag for statement questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, StatementSpecification specification, String title) {
    xml.question(type: "description") {
      questionHeader(xml, title, specification.enonce)
    }
  }

  /**
   * Render the <question> tag for boolean match questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, BooleanMatchSpecification specification, String title) {
    xml.question(type: "shortAnswer") {
      questionHeader(xml, title, specification.libelle)
      specification.reponses.each {answer ->
        xml.answer(fraction: 100) {
          xml.text answer
        }
      }
      correction(xml, specification.correction)
    }
  }

  /**
   * Prepend a correct header at the beginning of the generated XML document.
   * @param xml
   * @return
   */
  private String prependHeader(String xml) {
    "<?xml version=\"1.0\" ?>\n" + xml
  }

  private questionHeader(MarkupBuilder xml, String title, String libelle) {
    xml.name() {
      xml.text title
    }
    xml.questiontext(format: 'html') {
      xml.text libelle
    }
  }

  private correction(MarkupBuilder xml, String correction) {
    xml.generalfeedback(format: 'html') {
      xml.text correction
    }
  }

  /**
   * Render the <question> tag for fill graphics questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, FillGraphicsSpecification specification, String title) {
    // ne peut pas être renderisé
  }

  /**
   * Render the <question> tag for graphic match questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, GraphicMatchSpecification specification, String title) {
    // ne peut pas être renderisé
  }

  /**
   * Render the <question> tag for order questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, OrderSpecification specification, String title) {
    // ne peut pas être renderisé
  }

  /**
   * Render the <question> tag for slider questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, SliderSpecification specification, String title) {
    // ne peut pas être renderisé
  }

  /**
   * Render the <question> tag for file upload questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, FileUploadSpecification specification, String title) {
    // ne peut pas être renderisé
  }

  /**
   * Render the <question> tag for fill gap  questions.
   * @param xml
   * @param theQuestion
   */
  private void renderQuestion(MarkupBuilder xml, FillGapSpecification specification, String title) {
    // ne peut pas être renderisé
  }
}