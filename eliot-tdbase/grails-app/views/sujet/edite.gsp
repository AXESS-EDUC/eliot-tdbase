<%@ page import="org.lilie.services.eliot.tdbase.importexport.Format; org.lilie.services.eliot.tice.CopyrightsType; org.lilie.services.eliot.tice.utils.NumberUtils" %>
%{--
  - Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
  - This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
  -
  - Lilie is free software. You can redistribute it and/or modify since
  - you respect the terms of either (at least one of the both license) :
  -  under the terms of the GNU Affero General Public License as
  - published by the Free Software Foundation, either version 3 of the
  - License, or (at your option) any later version.
  -  the CeCILL-C as published by CeCILL-C; either version 1 of the
  - License, or any later version
  -
  - There are special exceptions to the terms and conditions of the
  - licenses as they are applied to this software. View the full text of
  - the exception in file LICENSE.txt in the directory of this software
  - distribution.
  -
  - Lilie is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - Licenses for more details.
  -
  - You should have received a copy of the GNU General Public License
  - and the CeCILL-C along with Lilie. If not, see :
  -  <http://www.gnu.org/licenses/> and
  -  <http://www.cecill.info/licences.fr.html>.
  --}%


<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta name="layout" content="eliot-tdbase"/>
    <r:require module="eliot-tdbase-ui"/>
    <r:script>
    $(document).ready(function() {
      $('#menu-item-sujets').addClass('actif');

      $(".editinplace").editInPlace({
        default_text:"",
      	bg_out: "#fff",
        url: "${g.createLink(controller: 'sujet', action: 'updatePoints')}"
      });
      initButtons();
    });
    </r:script>
    <title><g:message code="sujet.edite.head.title"/></title>
</head>

<body>

<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>

<div class="portal-tabs">
    <g:render template="menuSujet"
              model="${[
                  artefactHelper: artefactHelper,
                  utilisateur: utilisateur,
                  sujet : sujet,
                  modeEdition: true
              ]}"/>

  <span class="portal-tabs-famille-liens">
    <button id="toolbar_${sujet.id}">Actions</button>
    <ul id="menu_actions_toolbar_${sujet.id}" class="tdbase-menu-actions">
      <g:render template="menuActions"
                model="${[
                    artefactHelper: artefactHelper,
                    sujet         : sujet,
                    utilisateur   : utilisateur
                ]}"/>
    </ul>
  </span>
</div>


<g:hasErrors bean="${sujet}">
    <div class="portal-messages">
        <g:eachError>
            <li class="error"><g:message error="${it}"/></li>
        </g:eachError>
    </div>
</g:hasErrors>
<g:if test="${flash.messageCode}">
    <div class="portal-messages">
        <li class="success"><g:message code="${flash.messageCode}"
                                       args="${flash.messageArgs}"
                                       class="portal-messages success"/></li>
    </div>
</g:if>

<div class="portal-form_container edite full">
    <span class="title">${sujet.titre}</span>
</div>

<g:if test="${sujet}">
    <div class="tdbase-sujet-edition">
        <g:set var="indexQuestion" value="1"/>
        <g:set var="indexExercice" value="1"/>
        <g:each in="${sujet.questionsSequences}" var="sujetQuestion" status="rang">
            <g:set var="question" value="${sujetQuestion.question}"/>
            <div class="tdbase-sujet-edition-question">
                <g:if test="${question.estComposite()}">
                    <h1>Exercice ${indexExercice}</h1>
                </g:if>
                <g:elseif test="${question.type.interaction}">
                    <h1>Question ${indexQuestion}</h1>
                    <g:set var="indexQuestion" value="${indexQuestion.toInteger() + 1}"/>
                </g:elseif>
                <g:else>
                    <h1>${question.type.nom}</h1>
                </g:else>

                <button id="${sujetQuestion.id}">Actions</button>
                <ul id="menu_actions_${sujetQuestion.id}"
                    class="tdbase-menu-actions">
                    <g:if test="${artefactHelper.utilisateurPeutModifierArtefact(utilisateur, sujetQuestion.question)}">
                        <li><g:link action="edite"
                                    controller="question${sujetQuestion.question.type.code}"
                                    id="${sujetQuestion.question.id}">Modifier
                        </g:link></li>
                    </g:if>
                    <g:else>
                        <li>Modifier</li>
                    </g:else>
                    <g:if test="${artefactHelper.utilisateurPeutDupliquerArtefact(utilisateur, sujetQuestion.question)}">
                        <li><g:link action="dupliqueDansSujet"
                                    controller="question${sujetQuestion.question.type.code}"
                                    id="${sujetQuestion.id}">Dupliquer&nbsp;et&nbsp;modifier</g:link></li>
                    </g:if>
                    <g:else>
                        <li>Dupliquer&nbsp;et&nbsp;modifier</li>
                    </g:else>
                    <li><hr/></li>
                    <li>
                        <g:if test="${rang > 0}">
                            <g:link action="remonteElement" controller="sujet"
                                    id="${sujetQuestion.id}">
                                Déplacer&nbsp;vers&nbsp;le&nbsp;haut
                            </g:link>
                        </g:if>
                        <g:else>
                            Déplacer&nbsp;vers&nbsp;le&nbsp;haut
                        </g:else>
                    </li>
                    <li>
                        <g:if test="${rang < sujet.questionsSequences.size() - 1}">
                            <g:link action="descendElement" controller="sujet"
                                    id="${sujetQuestion.id}">
                                Déplacer&nbsp;vers&nbsp;le&nbsp;bas
                            </g:link>
                        </g:if>
                        <g:else>
                            Déplacer&nbsp;vers&nbsp;le&nbsp;bas
                        </g:else>
                    </li>
                    <li><hr/></li>
                    <li>
                        <g:link action="ajouteElement" controller="sujet"
                                id="${sujet.id}" params="[direction: 'avant',
                                                          rang     : rang]">
                            Insérer&nbsp;un&nbsp;item&nbsp;avant
                        </g:link>
                    </li>
                    <li>
                        <g:link action="ajouteElement" controller="sujet"
                                id="${sujet.id}" params="[rang: rang]">
                            Insérer&nbsp;un&nbsp;item&nbsp;après
                        </g:link>
                    </li>
                    <li><hr/></li>
                    <li><g:link action="supprimeFromSujet" controller="sujet"
                                id="${sujetQuestion.id}">
                        Retirer</g:link></li>

                    <li><hr/></li>

                    <g:set var="peutExporterNatifJson"
                           value="${artefactHelper.utilisateurPeutExporterArtefact(utilisateur, question, Format.NATIF_JSON)}"/>
                    <g:set var="peutExporterMoodleXml"
                           value="${artefactHelper.utilisateurPeutExporterArtefact(utilisateur, question, Format.MOODLE_XML)}"/>

                    <g:if test="${peutExporterNatifJson || peutExporterMoodleXml}">
                        <li>
                            <g:set var="urlFormatNatifJson"
                                   value="${createLink(controller: 'question', action: 'exporter', id: question.id, params: [format: Format.NATIF_JSON.name()])}"/>
                            <g:set var="urlFormatMoodleXml"
                                   value="${createLink(controller: 'question', action: 'exporter', id: question.id, params: [format: Format.MOODLE_XML.name()])}"/>
                            <a href="#"
                               onclick="actionExporter('${urlFormatNatifJson}', '${peutExporterMoodleXml ? urlFormatMoodleXml : null}')">Exporter</a>
                        </li>
                    </g:if>
                    <g:else>
                        Exporter
                    </g:else>

                </ul>

                <g:if test="${question.estComposite()}">
                    <div class="tdbase-sujet-edition-question-preview">
                        <g:render
                                template="/question/Preview"
                                model="[question: question, indexExercice: indexExercice]"/>
                    </div>
                    <g:set var="indexExercice" value="${indexExercice.toInteger() + 1}"/>
                </g:if>
                <g:else>
                    <g:if test="${question.type.interaction}">
                        <div class="tdbase-sujet-edition-question-points">
                            <div class="editinplace"
                                 id="SujetSequenceQuestions-${sujetQuestion.id}"
                                 title="Cliquez pour modifier le barème...">
                                ${NumberUtils.formatFloat(sujetQuestion.points)}
                            </div>
                            <span class="point">point(s)</span>
                        </div>
                    </g:if>
                    <div class="tdbase-sujet-edition-question-preview">
                        <g:render
                                template="/question/Preview"
                                model="[question: question, indexQuestion: indexQuestion]"/>
                    </div>
                </g:else>
            </div>

        </g:each>
    </div>
</g:if>

<g:render template="../importexport/export_dialog"/>
</body>
</html>