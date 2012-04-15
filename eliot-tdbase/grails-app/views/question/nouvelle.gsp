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

<%@ page import="org.lilie.services.eliot.tdbase.QuestionTypeEnum" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta name="layout" content="eliot-tdbase"/>
  <r:require modules="jquery"/>
  <r:script>
    $(document).ready(function() {
      $('#menu-item-contributions').addClass('actif');
      $("select").change(function() {
        $("form").submit();
      })
    });
  </r:script>
  <title><g:message code="question.nouvelle.head.title" /></title>
</head>

<body>

  <g:render template="/breadcrumps" plugin="eliot-tice-plugin"
            model="[liens: liens]"/>

  <div style="width:80%; padding:15px; margin: auto;">
    <h4>Créer un nouvel item</h4>
    <ul>
      <li>
        <g:link action="edite"
                controller="question${QuestionTypeEnum.Statement}"
                params="[creation:true, questionTypeId:QuestionTypeEnum.Statement.id]">
          Un énoncé
        </g:link>
      </li>
      <li>
        <g:link action="edite" controller="question${QuestionTypeEnum.Document}"
                params="[creation:true, questionTypeId:QuestionTypeEnum.Document.id]">
          Un document
        </g:link>
      </li>
      <li>

          <g:form method="get" action="edite"
                  controller="question">
            <g:hiddenField name="creation" value="true"/>
            Une question de type <g:select name="questionTypeId"
                                           noSelection="${['null': g.message(code:"default.select.null")]}"
                                           from="${typesQuestionSupportes}"
                                           optionKey="id"
                                           optionValue="nom"/>
          </g:form>

      </li>
    </ul>


  </div>


</body>
</html>