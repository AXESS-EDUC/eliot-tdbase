<%@ page import="org.lilie.services.eliot.tdbase.QuestionTypeEnum" %>
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
  <r:require modules="jquery"/>
  <r:script>
    $(document).ready(function() {
      $('#menu-item-sujets').addClass('actif');
    });
  </r:script>
  <title>TDBase - Ajout d'un élément</title>
</head>

<body>

<div class="column span-22 last middle">
  <g:render template="/breadcrumps" model="[liens: liens]"/>
  <g:render template="/sujet/listeElements" model="[sujet:sujet]"/>
  <div style="width:80%; padding:15px; margin: auto;">
  <h4>Créer et ajouter un élément</h4>
  <ul>
    <li>
      <g:link action="edite" controller="question"
                params="[creation:true, questionTypeId:QuestionTypeEnum.Statement.id, sujetId:sujet.id]">
        Un élément d'énoncé
      </g:link>
    </li>
    <li>
      <g:link action="edite" controller="question"
                params="[creation:true, questionTypeId:QuestionTypeEnum.Document.id, sujetId:sujet.id]">
        Un document
      </g:link>
    </li>
    <li>
      <g:link action="edite" controller="question"
                params="[creation:true, questionTypeId:QuestionTypeEnum.MultipleChoice.id, sujetId:sujet.id]">
        Une question de type QCM
      </g:link>
    </li>
  </ul>

  <h4>Rechercher et ajouter un élément</h4>
  <ul>
    <li>
      <g:link action="recherche" controller="question"
                params="[typeId:QuestionTypeEnum.Statement.id, sujetId:sujet.id]">
        Un élément d'énoncé
      </g:link>
    </li>
    <li>
      <g:link action="recherche" controller="question"
                params="[typeId:QuestionTypeEnum.Document.id, sujetId:sujet.id]">
        Un document
      </g:link>
    </li>
    <li>
      <g:link action="recherche" controller="question"
                params="[typeId:QuestionTypeEnum.MultipleChoice.id, sujetId:sujet.id]">
        Une question de type QCM
      </g:link>
    </li>
  </ul>

  <h4>Importer et ajouter un élément</h4>
  <ul>
    <li>Un élément d'énoncé</li>
    <li>Un document</li>
    <li>Une question de type...</li>
  </ul>
  </div>
</div>

</body>
</html>