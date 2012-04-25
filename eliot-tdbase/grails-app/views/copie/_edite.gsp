<%@ page import="org.lilie.services.eliot.tice.utils.NumberUtils" %>
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



<g:set var="sujet" value="${copie.sujet}"/>
<g:form method="post" class="edite">
  <g:hiddenField name="copie.id" value="${copie.id}"/>

  <h1 class="tdbase-sujet-titre">${sujet.titre}</h1>
  <g:set var="indexReponseNonVide" value="0"/>
  <g:set var="indexQuestion" value="1"/>
  <g:set var="exericeEnCours" value="${null}"/>
  <g:set var="indexExercice" value="0"/>
  <g:set var="indexQuestionInExercice" value="1"/>
  <g:set var="etaitDansUnExercice" value="${false}"/>

  <g:each in="${copie.reponses}" var="reponse">
    <g:set var="sujetQuestion" value="${reponse.sujetQuestion}"/>
    <g:set var="question" value="${sujetQuestion.question}"/>
    <g:set var="sujetEnCours" value="${sujetQuestion.sujet}"/>

    <g:if test="${etaitDansUnExercice && sujetEnCours != exericeEnCours}">
      </div>
      <!-- Fermeture div exercice  quand exercice termine-->
      <g:set var="etaitDansUnExercice" value="${false}"/>
    </g:if>


    <g:if test="${sujetEnCours == sujet}">
      <!-- -------------------------------- -->
     <!-- mode question de premier niveau -->
     <!-- -------------------------------- -->
     <div class="tdbase-sujet-edition-question">
      <g:if test="${question.type.interaction}">
        <h1>Question ${indexQuestion}</h1>
        <g:set var="indexQuestion" value="${indexQuestion.toInteger() + 1}"/>
        <div class="tdbase-sujet-edition-question-points">
          <div id="SujetSequenceQuestions-${sujetQuestion.id}">
            <em><g:formatNumber number="${reponse.correctionNoteAutomatique}"
                                format="##0.00"/></em>
            &nbsp;/&nbsp;<strong><g:formatNumber
                  number="${sujetQuestion.points}"
                  format="##0.00"/>&nbsp;point(s)</strong>
          </div>
        </div>

        <div class="tdbase-sujet-edition-question-interaction">
          <g:hiddenField
                  name="reponsesCopie.listeReponses[${indexReponseNonVide}].reponse.id"
                  value="${reponse.id}"/>
          <g:render
                  template="/question/Interaction"
                  model="[question: question, reponse: reponse, indexReponse: indexReponseNonVide]"/>

          <g:set var="indexReponseNonVide"
                 value="${indexReponseNonVide.toInteger() + 1}"/>
          <g:if test="${afficheCorrection}">
            <g:render
                    template="/question/${question.type.code}/${question.type.code}Correction"
                    model="[question: question]"/>
          </g:if>
        </div>
      </g:if>
      <g:else>
        <div class="tdbase-sujet-edition-question-interaction">
          <g:render
                  template="/question/Preview"
                  model="[question: question]"/>
        </div>
      </g:else>
    </g:if>
    <g:elseif test="${sujetEnCours == exericeEnCours}">
      <!-- -------------------------------- -->
     <!-- mode question dans un sujet -->
     <!-- -------------------------------- -->
     <div class="tdbase-sujet-edition-question">
      <g:if test="${question.type.interaction}">
        <h2>Ex. ${indexExercice} → Question ${indexQuestionInExercice}</h2>
        <g:set var="indexQuestionInExercice"
               value="${indexQuestionInExercice.toInteger() + 1}"/>
        <div class="tdbase-sujet-edition-question-points">
          <div id="SujetSequenceQuestions-${sujetQuestion.id}">
            <em><g:formatNumber number="${reponse.correctionNoteAutomatique}"
                                format="##0.00"/></em>
            &nbsp;/&nbsp;<strong><g:formatNumber
                  number="${sujetQuestion.points}"
                  format="##0.00"/>&nbsp;point(s)</strong>
          </div>
        </div>

        <div class="tdbase-sujet-edition-question-interaction">
          <g:hiddenField
                  name="reponsesCopie.listeReponses[${indexReponseNonVide}].reponse.id"
                  value="${reponse.id}"/>
          <g:render
                  template="/question/Interaction"
                  model="[question: question, reponse: reponse, indexReponse: indexReponseNonVide]"/>

          <g:set var="indexReponseNonVide"
                 value="${indexReponseNonVide.toInteger() + 1}"/>
          <g:if test="${afficheCorrection}">
            <g:render
                    template="/question/${question.type.code}/${question.type.code}Correction"
                    model="[question: question]"/>
          </g:if>
        </div>
      </g:if>
      <g:else>
        <div class="tdbase-sujet-edition-question-interaction">
          <g:render
                  template="/question/Preview"
                  model="[question: question]"/>
        </div>
      </g:else>

    </g:elseif>
    <g:else>
      <!-- -------------------------------- -->
    <!-- entrée dans un exerice -->
    <!-- -------------------------------- -->
      <g:set var="exericeEnCours" value="${sujetQuestion.sujet}"/>
      <g:set var="indexQuestionInExercice" value="1"/>
      <g:set var="indexExercice" value="${indexExercice.toInteger() + 1}"/>
      <g:set var="etaitDansUnExercice" value="${true}"/>
      <div class="exercice" id="exercice_${indexExercice}">

      <h1>Exercice ${indexExercice}</h1>

      <div class="tdbase-sujet-edition-question">

      <g:if test="${question.type.interaction}">
        <h2>Ex. ${indexExercice} → Question ${indexQuestionInExercice}</h2>
        <g:set var="indexQuestionInExercice"
               value="${indexQuestionInExercice.toInteger() + 1}"/>
        <div class="tdbase-sujet-edition-question-points">
          <div id="SujetSequenceQuestions-${sujetQuestion.id}">
            <em><g:formatNumber number="${reponse.correctionNoteAutomatique}"
                                format="##0.00"/></em>
            &nbsp;/&nbsp;<strong><g:formatNumber
                  number="${sujetQuestion.points}"
                  format="##0.00"/>&nbsp;point(s)</strong>
          </div>
        </div>

        <div class="tdbase-sujet-edition-question-interaction">
          <g:hiddenField
                  name="reponsesCopie.listeReponses[${indexReponseNonVide}].reponse.id"
                  value="${reponse.id}"/>
          <g:render
                  template="/question/Interaction"
                  model="[question: question, reponse: reponse, indexReponse: indexReponseNonVide]"/>

          <g:set var="indexReponseNonVide"
                 value="${indexReponseNonVide.toInteger() + 1}"/>
          <g:if test="${afficheCorrection}">
            <g:render
                    template="/question/${question.type.code}/${question.type.code}Correction"
                    model="[question: question]"/>
          </g:if>
        </div>
      </g:if>
      <g:else>
        <div class="tdbase-sujet-edition-question-interaction">
          <g:render
                  template="/question/Preview"
                  model="[question: question]"/>
        </div>
      </g:else>
    </g:else>

    </div> <!-- fermeture div class = tdbase-sujet-edition-question -->

  </g:each>
  <g:if test="${etaitDansUnExercice}">
    </div>
  </g:if>
  <g:if test="${copie.estModifiable()}">
    <g:hiddenField name="nombreReponsesNonVides"
                   value="${indexReponseNonVide}"/>
    <div class="bottom">
      <div class="form_actions">
        <g:submitToRemote action="enregistreLaCopie"
                          id="hb_enregistre_copie"
                          update="date_enregistrement"/>
        <g:actionSubmit value="Enregistrer la copie" action="enregistreLaCopie"
                        class="button"
                        title="Enregistrer la copie sans la rendre"/>
        <g:actionSubmit value="Enregistrer et rendre la copie"
                        action="rendLaCopie"
                        class="button"
                        title="Enregistrer et rendre la copie"/>
      </div>
    </div>
  </g:if>
</g:form>
