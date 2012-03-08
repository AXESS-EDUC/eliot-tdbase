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
import org.lilie.services.eliot.tdbase.impl.booleanmatch.BooleanMatchSpecification
import org.lilie.services.eliot.tdbase.impl.composite.CompositeSpecification
import org.lilie.services.eliot.tdbase.impl.decimal.DecimalSpecification
import org.lilie.services.eliot.tdbase.impl.document.DocumentSpecification
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
        //new File("/home/bert/questions.json").write(sujet.questions.collect {it.specification}.toString(), "UTF-8")
        renderQuiz(sujet.questions)
    }

    /**
     * Exporter une Question sous format d'un moodle quiz.
     * @param questionSpecification
     * @return
     */
    String toMoodleQuiz(Question question) {
        renderQuiz([question])
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
            question.each {renderQuestion(xml, it.specificationObject, it.titre)}
        }

        prependHeader writer.toString()
    }

    /**
     * Render the <question> tag for associate questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, AssociateSpecification specification, String title) {
        xml.question(type: "to_be_implemented_associate")
    }

    /**
     * Render the <question> tag for boolean questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, BooleanMatchSpecification specification, String title) {
        xml.question(type: "to_be_implemented_booleanMatch")
    }

    /**
     * Render the <question> tag for composite questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, CompositeSpecification specification, String title) {
        xml.question(type: "to_be_implemented_compositeQuestion")
    }

    /**
     * Render the <question> tag for decimal questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, DecimalSpecification specification, String title) {
        xml.question(type: "to_be_implemented decimal")
    }

    /**
     * Render the <question> tag for documentation questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, DocumentSpecification specification, String title) {
        xml.question(type: "to_be_implemented_documentSpecification")
    }

    /**
     * Render the <question> tag for exclusive choice questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, ExclusiveChoiceSpecification specification, String title) {
        xml.question(type: "to_be_implemented_exclusiveChoiceSpecification")
    }

    /**
     * Render the <question> tag for file upload questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, FileUploadSpecification specification, String title) {
        xml.question(type: "to_be_implemented_fileUploadSpecification")
    }

    /**
     * Render the <question> tag for fill gap  questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, FillGapSpecification specification, String title) {
        xml.question(type: "to_be_implemented_fill gap")
    }

    /**
     * Render the <question> tag for fill graphics questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, FillGraphicsSpecification specification, String title) {
        xml.question(type: "to_be_implemented_fill graphics")
    }

    /**
     * Render the <question> tag for graphic match questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, GraphicMatchSpecification specification, String title) {
        xml.question(type: "to_be_implemented_graphic match")
    }

    /**
     * Render the <question> tag for Integer questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, IntegerSpecification specification, String title) {
        xml.question(type: "numerical") {
            xml.name() {
                xml.text title
            }
            xml.questiontext(format:'html') {
                xml.text specification.libelle
            }
        }
    }

    /**
     * Render the <question> tag for multiple choice questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, MultipleChoiceSpecification specification, String title) {
        xml.question(type: "to_be_implemented multiple choice")
    }

    /**
     * Render the <question> tag for open questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, OpenSpecification specification, String title) {
        xml.question(type: "to_be_implemented open question")
    }

    /**
     * Render the <question> tag for order questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, OrderSpecification specification, String title) {
        xml.question(type: "to_be_implemented order question")
    }

    /**
     * Render the <question> tag for slider questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, SliderSpecification specification, String title) {
        xml.question(type: "to_be_implemented slider")
    }

    /**
     * Render the <question> tag for statement questions.
     * @param xml
     * @param theQuestion
     */
    private void renderQuestion(MarkupBuilder xml, StatementSpecification specification, String title) {
        xml.question(type: "to_be_implemented statement")
    }

    /**
     * Prepend a correct header at the beginning of the generated XML document.
     * @param xml
     * @return
     */
    private String prependHeader(String xml) {
        "<?xml version=\"1.0\" ?>\n" + xml
    }
}