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
  <r:require modules="question_editeJS"/>
  <g:external dir="js/eliot/tiny_mce/tiny_mce.js" plugin="eliot-tice-plugin"/>
  <script type="text/javascript">
    tinyMCE.init({
                   // General options
                   language:'fr',
                   mode:"none",
                   theme:"advanced",
                   plugins:"pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template",

                   // Theme options
                   theme_advanced_buttons1:"bold,italic,underline,strikethrough,|,forecolor,backcolor,|,justifyleft,justifycenter,justifyright,justifyfull,|,formatselect,fontselect,fontsizeselect,|,preview",
                   theme_advanced_buttons2:"cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,link,unlink,image,cleanup,help,code",
                   theme_advanced_buttons3:"tablecontrols,|,hr,removeformat,|,sub,sup,|,charmap,iespell,media,advhr",

                   theme_advanced_toolbar_location:"top",
                   theme_advanced_toolbar_align:"left",
                   theme_advanced_statusbar_location:"bottom",
                   theme_advanced_resizing:true
                 });
  </script>
  <r:script>
    $(document).ready(function () {
      $('#menu-item-contributions').addClass('actif');
      $('#question\\.titre').focus();
      $("form").attr('enctype', 'multipart/form-data');
      initButtons()
    });
  </r:script>
  <title><g:message code="question.edite.head.title"/></title>
</head>

<body>

<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>
<g:if test="${questionEnEdition}">
  <div class="portal-tabs">

    <span class="portal-tabs-famille-liens">
  <g:if test="${artefactHelper.utilisateurPeutPartageArtefact(utilisateur, question)}">
    <g:link action="partage" class="share"
            id="${question.id}">Partager l'item</g:link>&nbsp; |
  </g:if>
  <g:else>
    <span class="share">Partager l'item</span>&nbsp;| &nbsp;
  </g:else>
  </span>
  </span>
  <span class="portal-tabs-famille-liens">
    <button id="${question.id}">Actions</button>
    <ul id="menu_actions_${question.id}"
        class="tdbase-menu-actions">
      <li><g:link action="detail" controller="question${question.type.code}"
                  id="${question.id}">Aperçu</g:link></li>
      <li><hr/></li>
      <g:if test="${artefactHelper.utilisateurPeutDupliquerArtefact(utilisateur, question)}">
        <li><g:link action="duplique"
                    controller="question${question.type.code}"
                    id="${question.id}">Dupliquer</g:link></li>
      </g:if>
      <g:else>
        <li>Dupliquer</li>
      </g:else>
      <li><hr/></li>
      <g:if test="${artefactHelper.utilisateurPeutExporterArtefact(utilisateur, question)}">
        <li><g:link action="exporter" controller="question"
                    id="${question.id}">Exporter</g:link></li>
      </g:if>
      <g:else>
        <li>Exporter</li>
      </g:else>
      <li><hr/></li>
      <g:if test="${artefactHelper.utilisateurPeutSupprimerArtefact(utilisateur, question)}">
        <li><g:link action="supprime"
                    controller="question${question.type.code}"
                    id="${question.id}">Supprimer</g:link></li>
      </g:if>
      <g:else>
        <li>Supprimer</li>
      </g:else>
    </ul>
  </span>

  </div>
</g:if>
<g:else>
  <div class="portal-tabs">
    <span class="portal-tabs-famille-liens">
                <span class="share">Partager l'item</span>&nbsp;| &nbsp;
            </span>
            </span>
            <span class="portal-tabs-famille-liens">
              <button id="${question.id}">Actions</button>
  <ul id="menu_actions_${question.id}"
      class="tdbase-menu-actions">
    <li>Aperçu</li>
    <li><hr/></li>
    <li>Dupliquer</li>
    <li>Exporter</li>
    <li><hr/></li>
    <li>Supprimer</li>
  </ul>
  </span>
  </div>
</g:else>
<g:hasErrors bean="${question}">
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

<g:if test="${sujet}">
  <g:render template="/sujet/listeElements" model="[sujet: sujet]"/>
</g:if>

<g:form method="post" controller="question${question.type.code}"
        class="question">
  <div class="portal-form_container edite" style="width: 69%;">
    <p style="font-style: italic; margin-bottom: 2em"><span class="obligatoire">*</span> indique une information obligatoire</p>
    <table>
      <tr>
        <td class="label title">Titre<span class="obligatoire">*</span>&nbsp;:</td>
        <td>
          <input size="75" type="text" value="${question.titre}"
                 name="titre" id="question.titre"/><br/><br/>
        </td>
      </tr>
      <tr>
        <td class="label">Type :</td>
        <td>
          ${question.type.nom}
        </td>
      </tr>
      <g:if test="${!question.id && sujet}">
        <tr>
          <td class="label">Mati&egrave;re :</td>
          <td>
            <g:select name="matiere.id" value="${sujet.matiereId}"
                      noSelection="${['null': g.message(code:"default.select.null")]}"
                      from="${matieres}"
                      optionKey="id"
                      optionValue="libelleLong"/>
          </td>
        </tr>
        <tr>
          <td class="label">Niveau :</td>
          <td>
            <g:select name="niveau.id" value="${sujet.niveauId}"
                      noSelection="${['null': g.message(code:"default.select.null")]}"
                      from="${niveaux}"
                      optionKey="id"
                      optionValue="libelleLong"/>
          </td>
        </tr>
      </g:if>
      <g:else>
        <tr>
          <td class="label">Mati&egrave;re :</td>
          <td>
            <g:select name="matiere.id" value="${question.matiereId}"
                      noSelection="${['null': g.message(code:"default.select.null")]}"
                      from="${matieres}"
                      optionKey="id"
                      optionValue="libelleLong"/>
          </td>
        </tr>
        <tr>
          <td class="label">Niveau :</td>
          <td>
            <g:select name="niveau.id" value="${question.niveauId}"
                      noSelection="${['null': g.message(code:"default.select.null")]}"
                      from="${niveaux}"
                      optionKey="id"
                      optionValue="libelleLong"/>
          </td>
        </tr>
      </g:else>
      <tr>
        <td class="label"><g:message code="question.propriete.principalAttachement"/>&nbsp;:</td>
        <td id="question_fichier">
          <g:render template="/question/QuestionEditionFichier"
                    model="[question: question, attachementsSujet: attachementsSujets]"/>

        </td>
      </tr>
      <g:render
              template="/question/${question.type.code}/${question.type.code}Edition"
              model="[question: question]"/>
      <tr>
        <td class="label">Partage :</td>
        <td>
          <g:if test="${question.estPartage()}">
            <a href="${question.copyrightsType.lien}"
               target="_blank">${question.copyrightsType.presentation}</a>
          </g:if>
          <g:else>
            cet item n'est pas partagé
          </g:else>
        </td>
      </tr>
      <g:if test="${question.paternite}">
        <g:render template="/artefact/paternite"
                  model="[paternite: question.paternite]"/>
      </g:if>
    </table>
  </div>
  <g:hiddenField name="id" value="${question.id}"/>
  <g:hiddenField name="type.id" value="${question.typeId}"/>

  <div class="form_actions">
    <g:hiddenField name="sujetId" value="${sujet?.id}"/>
    <g:if test="${sujet && !question.id}">

      <g:actionSubmit value="Enregistrer et insérer dans le sujet"
                      action="enregistreInsertNouvelItem"
                      title="Enregistrer et insérer dans le sujet"
                      class="button"/>
    </g:if>
    <g:else>
      <g:actionSubmit value="Enregistrer"
                      action="enregistre"
                      title="Enregistrer"
                      class="button"/>

    </g:else>
  </div>
</g:form>

</body>
</html>