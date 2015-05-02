<%@ page import="org.lilie.services.eliot.tice.scolarite.FonctionEnum; org.lilie.services.eliot.tice.scolarite.Fonction; org.lilie.services.eliot.tdbase.RechercheContributeurCommand; org.lilie.services.eliot.tdbase.SujetType" %>
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
    <r:require modules="eliot-tdbase-ui, jquery, jquery-ui, jquery-template, eliot-tdbase-combobox-autocomplete"/>

    <script id="contributeurTemplate" type="text/html">
    <tr>
        <td>
            <input type="hidden" name="contributeurId" value="{{= id}}" />
            <input type="text" value="{{= nomAffichage}}" disabled="disabled"/>
        </td>
        <td>
            {{if !persistant}} <input type="button" class="button" value="Supprimer" onclick="supprimerContributeur({{= id}}); return false;"/> {{/if}}
        </td>
    </tr>
    </script>

    <r:script>
      // Tableau contenant tous les contributeurs (ceux qui sont persistants + ceux qui viennent d'être ajoutés)
      var contributeurList = [];
      var tempContributeurList = [];
      var fonctionSelectionneeId = null;

      function renderContributeurList() {
        var divContributeurList = $('#contributeurList');

        divContributeurList.html('');

        if(contributeurList.length === 0) {
            divContributeurList.append('Aucun contributeur');
        }
        else {
            divContributeurList.append('<table>');
            $.each(contributeurList, function(index, contributeur) {
                $('#contributeurTemplate').tmpl(contributeur).appendTo(divContributeurList);
            });
            divContributeurList.append('</table>');
        }
      }

      function supprimerContributeur(id) {
        for (var i = 0; i < contributeurList.length; i++) {
          if (contributeurList[i].id == id) {
            contributeurList.splice(i, 1);
            break;
          }
        }

        renderContributeurList();
      }

      function searchContributeurOnLoad() {
        $('#search-contributeur-pagination a').each(function() {
          var a = $(this);
          var href = a.prop('href');
          a.prop('href', '#');
          var params = getUrlParams(href);
          a.click(function() {
            $('#offset').val(params.offset);
            $('#search-contributeur-button').click();
          });
        });

        initCheckboxes();
      }

      function ouvreContrubuteurPopup() {
        tempContributeurList = [];

        contributeurList.forEach(function(formateur) {
          tempContributeurList.push(formateur);
        });

        initCheckboxes();
        $('#search-contributeur-form').dialog('open');
      }

      function initCheckboxes() {
        var checkboxes = $('.formateur-checkbox')
        checkboxes.unbind('change');
        checkboxes.prop('checked', false);
        checkboxes.prop('disabled', false);

        tempContributeurList.forEach(function(formateur) {
          var checkbox = $('#formateur-checkbox' + formateur.id);
          checkbox.prop('checked', true);
          if (formateur.persistant) {
            checkbox.prop('disabled', true);
          }
        });

        checkboxes.change(function() {
          if(this.checked) {
            tempContributeurList.push({
              id: $(this).data('id'),
              nomAffichage: $(this).data('nomaffichage'),
              persistant: false
            });
          }
          else {
            var id = $(this).data('id');

            for (var i = 0; i < tempContributeurList.length; i++) {
              if (tempContributeurList[i].id == id) {
                tempContributeurList.splice(i, 1);
                break;
              }
            }
          }
        });
      }

      function getUrlParams(url) {
        var params = {};
        var paramsStrings = url.split('?')[1].split('&');

        for (var i = 0; i < paramsStrings.length; i++) {
          var paramStrings = paramsStrings[i].split('=');
          params[paramStrings[0]] = paramStrings[1];
        }
        return params;
      }

      function ajouterFormateursSelectionnes() {
        $("#search-contributeur-form").dialog("close");
        contributeurList = [];

        tempContributeurList.forEach(function(formateur) {
          contributeurList.push(formateur);
        });

        renderContributeurList();
      }

      $(document).ready(function () {
        $('#menu-item-sujets').addClass('actif');
        $('input[name="titre"]').focus();

        initComboboxAutoComplete({
          combobox: '#matiereBcn\\.id',

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
                      value:  matiereBcns[i].libelleEdition + ' [' + matiereBcns[i].libelleCourt + ']'
                    });
                  }

                  callback(options);
                }
              });
            }
          }

        });

        $("#search-contributeur-form").dialog({
             autoOpen: false,
             title: "Rechercher formateurs",
             height: 600,
             width: 420,
             modal: true
        });

        <g:each in="${sujet.contributeurs}" var="contributeur">
            contributeurList.push({
              id: ${contributeur.id},
              nomAffichage: '${contributeur.nomAffichage.encodeAsJavaScript()}',
              persistant: true
          });
        </g:each>

        // TODO *** For test
        //contributeurList.push({
        //    nomAffichage : 'John Doe',
        //    persistant: true
        //});
        //contributeurList.push({
        //    nomAffichage : 'Laura Ingall',
        //    persistant: false
        //});

        renderContributeurList();
      });
    </r:script>
    <title><g:message code="sujet.editeProprietes.head.title"/></title>

    <style>
    #contributeurList table {
        width: auto;
        margin-left: 0;
    }

    #contributeurList td {
        text-align: left;
    }

    #contributeurList td input {
        width: 19em;
    }

    #contributeurList td input.button {
        margin-top: -2px;
        width: auto;
    }
    </style>
</head>

<body>
<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>

<g:hasErrors bean="${sujet}">
    <div class="portal-messages">
        <g:eachError>
            <li class="error"><g:message error="${it}"/></li>
        </g:eachError>
    </div>
</g:hasErrors>


<form method="post" action="#" class="sujet" enctype="multipart/form-data">
    <div class="portal-form_container edite">
        <p style="font-style: italic; margin-bottom: 2em"><span
                class="obligatoire">*</span> indique une information obligatoire</p>
        <table>
            <tr>
                <td class="label title">Titre<span class="obligatoire">*</span>&nbsp;:</td>
                <td>
                    <input size="80" type="text" value="${sujet.titre}" name="titre" tabindex="1" style="width: 400px"/>
                </td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td class="label">Type<span class="obligatoire">*</span>&nbsp;:</td>
                <td>
                    <g:select name="sujetType.id" value="${sujet.sujetType?.id}"
                              from="${typesSujet}"
                              optionKey="id"
                              optionValue="nom" tabindex="2"/>
                </td>
            </tr>
            <tr>
                <td class="label">Mati&egrave;re&nbsp;:</td>
                <td>
                    <g:select name="matiereBcn.id"
                              value="${sujet.matiereBcn?.id}"
                              from="${matiereBcns}"
                              optionKey="id"
                              optionValue="libelleEdition" tabindex="3"/>
                </td>
            </tr>
            <tr>
                <td class="label">Niveau&nbsp;:</td>
                <td>
                    <g:select name="niveau.id" value="${sujet.niveau?.id}"
                              noSelection="${['null': g.message(code: "default.select.null")]}"
                              from="${niveaux}"
                              optionKey="id"
                              optionValue="libelleLong" tabindex="4"/>
                </td>
            </tr>
            <tr>
                <td class="label">Travail collaboratif&nbsp;:</td>
                <td>
                    <div id="contributeurList"></div>
                    <input type="button"
                           class="button"
                           onclick="ouvreContrubuteurPopup();"
                           value="Ajouter des contributeurs"/>
                    <br/>&nbsp;
                </td>
            </tr>
            <tr>
                <td class="label">Dur&eacute;e&nbsp;:</td>
                <td>
                    <input type="text" name="dureeMinutes" value="${sujet.dureeMinutes}" class="micro" tabindex="5"/>
                    (en minutes)
                </td>
            </tr>

            <tr>
                <td class="label">Ordre&nbsp;questions&nbsp;:</td>
                <td>
                    <g:checkBox name="ordreQuestionsAleatoire"
                                checked="${sujet.ordreQuestionsAleatoire}" tabindex="5"/>
                    Al&eacute;atoire</td>
            </tr>

            <tr>
                <td class="label">Description&nbsp;:</td>
                <td>
                    <g:textArea cols="56" rows="10" name="presentation"
                                value="${sujet.presentation}" tabindex="6"/>
                </td>
            </tr>
            <g:if test="${artefactHelper.partageArtefactCCActive}">
                <tr>
                    <td class="label">Partage :</td>
                    <td>
                        <g:if test="${sujet.estPartage()}">
                            <a href="${sujet.copyrightsType.lien}"
                               target="_blank"><img src="${sujet.copyrightsType.logo}"
                                                    title="${sujet.copyrightsType.code}"
                                                    style="float: left;margin-right: 10px;"/> ${sujet.copyrightsType.presentation}
                            </a>
                        </g:if>
                        <g:else>
                            ce sujet n'est pas partagé
                        </g:else>
                    </td>
                </tr>
                <g:if test="${sujet.paternite}">
                    <g:render template="/artefact/paternite"
                              model="[paternite: sujet.paternite]"/>
                </g:if>
            </g:if>
        </table>
    </div>
    <g:hiddenField name="id" value="${sujet.id}"/>
    <div class="form_actions">
        <g:actionSubmit value="Enregistrer" action="enregistrePropriete"
                        class="button"
                        title="Enregistrer" tabindex="7"/>
    </div>
</form>

<div id="search-contributeur-form" style="background-color: #ffffff">
    <g:render template="/sujet/selectContributeur" model="[
            etablissements              : etablissements,
            fonctionList                : fonctionList,
            rechercheContributeurCommand: new RechercheContributeurCommand( etablissementId: currentEtablissement.id,
                                                                            fonctionId: FonctionEnum.ENS.id,
                                                                            max: 3)
    ]"/>
</div>

</body>
</html>