<%@ page import="org.lilie.services.eliot.tdbase.importexport.Format; org.lilie.services.eliot.tice.CopyrightsType" %>
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
  <r:require modules="eliot-tdbase-ui, jquery-ui, eliot-tdbase-combobox-autocomplete, jquery"/>
  <r:script>

    $(document).ready(function () {
      $('#menu-item-contributions').addClass('actif');
      initButtons();

      initComboboxAutoComplete({
        combobox: '#matiereId',

        recherche: function(recherche, callback) {
          if (recherche == null || recherche.length < 3) {
            callback([]);
          }
          else {
            $.ajax({
              url: '${g.createLink(absolute: true, uri: "/sujet/matiereBcns")}',

              data: {
                recherche: recherche
              },

              success: function(matiereBcns) {
                var options = [];

                for(var i = 0; i < matiereBcns.length; i++) {
                  options.push({
                    id: matiereBcns[i].id,
                    value: matiereBcns[i].libelleEdition + ' [' + matiereBcns[i].libelleCourt + ']'
                  });
                }

                callback(options);
              }
            });
          }
        }

      });

      initComboboxAutoComplete({
          combobox: '#niveauId',

          recherche: function(recherche, callback) {
            if (recherche == null || recherche.length < 3) {
              callback([]);
            }
            else {
              $.ajax({
                url: '${g.createLink(absolute: true, uri: "/sujet/niveaux")}',

                data: {
                  recherche: recherche
                },

                success: function(niveaux) {
                  var options = [];

                  for(var i = 0; i < niveaux.length; i++) {
                    options.push({
                      id: niveaux[i].id,
                      value:  niveaux[i].libelleLong
                    });
                  }

                  callback(options);
                }
              });
            }
          }

        });
    });

    function masqueQuestion(question) {
      $.ajax({
        url: '${g.createLink(absolute: true, uri: "/question/masque/")}' + question,

        success: function() {
          $("div.question[data-question='" + question + "']").addClass('masque');
          $("li.masqueQuestion[data-question='" + question + "']").hide();
          $("li.annuleMasqueQuestion[data-question='" + question + "']").show();
        }
      });
    }

    function annuleMasqueQuestion(question) {
      $.ajax({
        url: '${g.createLink(absolute: true, uri: "/question/annuleMasque/")}' + question,

        success: function() {
          $("div.question[data-question='" + question + "']").removeClass('masque');
          $("li.masqueQuestion[data-question='" + question + "']").show();
          $("li.annuleMasqueQuestion[data-question='" + question + "']").hide();
        }
      });
    }

    function supprimeQuestion(question, type) {
      $.ajax({
        url: '${g.createLink(absolute: true, uri: "/question")}' + type + '/supprime/' + question + '?ajax=true',

        success: function() {
          location.reload();
        }
      });
    }

  </r:script>
  <style>
  .custom-combobox-input {
    width: 15em;
  }
  </style>
  <title>
    <g:if test="${afficheFormulaire}">
      <g:message code="question.recherche.head.title"/>
    </g:if>
    <g:else>
      <g:message code="question.recherche.mesItems.head.title"/>
    </g:else>
  </title>
</title>
</head>

<body>

<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>

<g:if test="${sujet}">
  <g:render template="/sujet/listeElements" model="[sujet: sujet]"/>
</g:if>
<g:if test="${afficheFormulaire}">
  <form>
    <div class="portal-form_container recherche">
      <table>
        <tr>
          <td class="label">
            Titre :
          </td>
          <td>
            <g:textField name="patternTitre" title="titre"
                         value="${rechercheCommand.patternTitre}"/>
          </td>

          <td class="label">Type :
          </td>
          <td>
            <g:select name="typeId" value="${rechercheCommand.typeId}"
                      noSelection="${['null': 'Tous']}"
                      from="${typesQuestion}"
                      optionKey="id"
                      optionValue="nom"/>
          </td>
        </tr>
        <tr>
          <td class="label">
            Contenu :
          </td>
          <td>
            <g:textField name="patternSpecification" title="contenu"
                         value="${rechercheCommand.patternSpecification}"/>
          </td>
          <td class="label">Matière :
          </td>
          <td class="matiere">
            <g:select name="matiereId" value="${rechercheCommand.matiereId}"
                      from="${matiereBcns}"
                      optionKey="id"
                      optionValue="libelleEdition"/>
          </td>
        </tr>
        <tr>
          <g:if test="${artefactHelper.partageArtefactCCActive}">
            <td class="label">Auteur :
            </td>
            <td class="niveau">
              <g:textField name="patternAuteur" title="auteur"
                           value="${rechercheCommand.patternAuteur}"/>
            </td>
          </g:if>
          <g:else>
            <td class="label">&nbsp;
            </td>
            <td>
              &nbsp;
            </td>
          </g:else>

          <td class="label">Niveau :
          </td>
          <td>
            <g:select name="niveauId" value="${rechercheCommand.niveauId}"
                      from="${niveaux}"
                      optionKey="id"
                      optionValue="libelleLong"/>
          </td>
        </tr>
        <tr>
          <td colspan="2">
            <g:checkBox name="afficheQuestionMasquee" value="${afficheQuestionMasquee}"/>
            Afficher les items masqués
          </td>
        </tr>

      </table>
    </div>

    <div class="form_actions recherche">
      <g:hiddenField name="sujetId" value="${sujet?.id}"/>
      <g:actionSubmit value="Rechercher" action="recherche"
                      title="Lancer la recherche" class="button"/>
    </div>
  </form>
</g:if>
<g:if test="${questions}">

  <div class="portal_pagination ${afficheFormulaire ? 'partiel' : ''} ">

    <p class="nb_result">${questions.totalCount} résultat(s)</p>
    <g:if test="${afficherPager}">
      <div class="pager">
        Page(s) : <g:paginate
            total="${questions.totalCount}"
            params="${rechercheCommand?.toParams()}"></g:paginate>
      </div>
    </g:if>
  </div>

  <div class="portal-default_results-list question  ${sujet ? 'partiel' : ''}">
    <%
      def messageDialogue = g.message(code: "question.partage.dialogue", args: [CopyrightsType.getDefaultForPartage().logo, CopyrightsType.getDefaultForPartage().code, CopyrightsType.getDefaultForPartage().lien])
    %>
    <g:each in="${questions}" status="i" var="questionInstance">
      <g:set var="masque" value="${questionsMasqueesIds?.contains(questionInstance.id)}"/>
      <div
          class="${(i % 2) == 0 ? 'even' : 'odd'} question ${masque ? 'masque' : ''} ${questionInstance.estCollaboratif() ? 'collaboratif' : ''} "
          data-question="${questionInstance.id}" style="z-index: 0">
        <g:if test="${questionInstance.estCollaboratif()}">
          <h1 title="Formateurs: ${questionInstance.getContributeursAffichage()} - Sujet: ${questionInstance.sujetLie?.titre ?: 'aucun'}">
        </g:if>
        <g:else>
          <h1>
        </g:else>
          ${fieldValue(bean: questionInstance, field: "titre")}

          <g:if test="${questionInstance.estTermine() || questionInstance.estDistribue()}">
            <g:img dir="images/eliot" file="modification_inactif.png" title="Non modifiable" width="16"/>
          </g:if>
          <g:else>
            <g:img dir="images/eliot" file="modification_actif.png" title="Modifiable" width="16"/>
          </g:else>
        </h1>

        <button id="${questionInstance.id}">Actions</button>
        <ul id="menu_actions_${questionInstance.id}"
            class="tdbase-menu-actions">
          <li><g:link action="detail"
                      controller="question${questionInstance.type.code}"
                      id="${questionInstance.id}"
                      params="[sujetId: sujet?.id]">
            Aperçu
          </g:link>
          </li>
          <g:if test="${sujet}">
            <li><g:link action="insert"
                        controller="question${questionInstance.type.code}"
                        id="${questionInstance.id}"
                        params="[sujetId: sujet?.id]">
              Insérer&nbsp;dans&nbsp;le&nbsp;sujet
            </g:link>
            </li>
          </g:if>
          <g:if
              test="${artefactHelper.utilisateurPeutModifierArtefact(utilisateur, questionInstance) && afficheLiensModifier}">
            <li><g:link action="edite"
                        controller="question${questionInstance.type.code}"
                        id="${questionInstance.id}">Modifier</g:link></li>
          </g:if>
          <g:else>
            <g:if test="${questionInstance.estVerrouille()}">
              <li>En cours de modification</li>
            </g:if>
            <g:else>
              <li>Modifier</li>
            </g:else>
          </g:else>
          <g:if
              test="${artefactHelper.utilisateurPeutDupliquerArtefact(utilisateur, questionInstance) && afficheLiensModifier}">
            <li><g:link action="duplique"
                        controller="question${questionInstance.type.code}"
                        id="${questionInstance.id}">Dupliquer</g:link></li>
          </g:if>
          <g:else>
            <li>Dupliquer</li>
          </g:else>
          <li><hr/></li>
          <g:if test="${artefactHelper.partageArtefactCCActive}">
            <g:if
                test="${artefactHelper.utilisateurPeutPartageArtefact(utilisateur, questionInstance) && afficheLiensModifier}">
              <%
                def docLoc = g.createLink(action: 'partage', controller: "question${questionInstance.type.code}", id: questionInstance.id)
              %>
              <li><g:link action="partage"
                          controller="question${questionInstance.type.code}"
                          id="${questionInstance.id}"
                          onclick="afficheDialogue('${messageDialogue}','${docLoc}');return false;">Partager</g:link></li>
            </g:if>
            <g:else>
              <li>Partager</li>
            </g:else>
          </g:if>
          <g:set var="peutExporterNatifJson"
                 value="${artefactHelper.utilisateurPeutExporterArtefact(utilisateur, questionInstance, Format.NATIF_JSON)}"/>
          <g:set var="peutExporterMoodleXml"
                 value="${artefactHelper.utilisateurPeutExporterArtefact(utilisateur, questionInstance, Format.MOODLE_XML)}"/>

          <g:if test="${peutExporterNatifJson || peutExporterMoodleXml}">
            <li>
              <g:set var="urlFormatNatifJson"
                     value="${createLink(action: 'exporter', id: questionInstance.id, params: [format: Format.NATIF_JSON.name()])}"/>
              <g:set var="urlFormatMoodleXml"
                     value="${createLink(action: 'exporter', id: questionInstance.id, params: [format: Format.MOODLE_XML.name()])}"/>
              <a href="#"
                 onclick="actionExporter('${urlFormatNatifJson}', '${peutExporterMoodleXml ? urlFormatMoodleXml : null}')">Exporter</a>
            </li>
          </g:if>
          <g:else>
            <li>Exporter</li>
          </g:else>

          <li><hr/></li>
          <g:if
              test="${artefactHelper.utilisateurPeutSupprimerArtefact(utilisateur, questionInstance) && afficheLiensModifier}">
            <li>
              <a href="#" onclick="supprimeQuestion(${questionInstance.id}, '${questionInstance.type.code}');
              return false;">Supprimer</a>
            </li>
          </g:if>
          <g:else>
            <li>Supprimer</li>
          </g:else>

          <g:if test="${artefactHelper.utilisateurPeutMasquerArtefact(utilisateur, questionInstance)}">
            <li><hr/></li>

            <li style="${!masque ? '' : 'display: none;'}" class="masqueQuestion"
                data-question="${questionInstance.id}">
              <a href="#" onclick="masqueQuestion('${questionInstance.id}')">Masquer</a>
            </li>

            <li style="${masque ? '' : 'display: none;'}" class="annuleMasqueQuestion"
                data-question="${questionInstance.id}">
              <a href="#" onclick="annuleMasqueQuestion('${questionInstance.id}')">Ne plus masquer</a>
            </li>

          </g:if>

        </ul>

        <p class="date">Mise à jour le ${questionInstance.lastUpdated?.format('dd/MM/yy HH:mm')}</p>

        <p>
          <g:if
              test="${questionInstance.niveau?.libelleLong}"><strong>» Niveau :</strong> ${questionInstance.niveau?.libelleLong}</g:if>
          <g:if
              test="${questionInstance.matiereBcn?.libelleEdition}"><strong>» Matière :</strong> ${questionInstance.matiereBcn?.libelleEdition}</g:if>
          <strong>» Type :</strong>  ${questionInstance.type.nom}
          <g:if test="${artefactHelper.partageArtefactCCActive}">
            <strong>» Partagé :</strong>  ${questionInstance.estPartage() ? 'oui' : 'non'}
          </g:if>
        </p>

      </div>
    </g:each>
  </div>

</g:if>
<g:else>
  <div class="portal_pagination">
    <p class="nb_result">Aucun résultat</p>
  </div>
</g:else>

<g:render template="../importexport/export_dialog"/>
</body>
</html>