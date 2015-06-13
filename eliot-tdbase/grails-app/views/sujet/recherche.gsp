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
      $('#menu-item-sujets').addClass('actif');
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
    });

    function masqueSujet(sujet) {
      $.ajax({
        url: '${g.createLink(absolute: true, uri: "/sujet/masque/")}' + sujet,

        success: function() {
          $("div.sujet[data-sujet='" + sujet + "']").addClass('masque');
          $("li.masqueSujet[data-sujet='" + sujet + "']").hide();
          $("li.annuleMasqueSujet[data-sujet='" + sujet + "']").show();
        }
      });
    }

    function annuleMasqueSujet(sujet) {
      $.ajax({
        url: '${g.createLink(absolute: true, uri: "/sujet/annuleMasque/")}' + sujet,

        success: function() {
          $("div.sujet[data-sujet='" + sujet + "']").removeClass('masque');
          $("li.masqueSujet[data-sujet='" + sujet + "']").show();
          $("li.annuleMasqueSujet[data-sujet='" + sujet + "']").hide();
        }
      });
    }

    function supprimeSujet(sujet) {
      $.ajax({
        url: '${g.createLink(absolute: true, uri: "/sujet/supprime/")}' + sujet + '?ajax=true',

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
      <g:message code="sujet.recherche.head.title"/>
    </g:if>
    <g:else>
      <g:message code="sujet.recherche.mesSujets.head.title"/>
    </g:else>
  </title>
</head>

<body>
<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>
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
                    <td width="20"/>
                    <td class="label">Type :
                    </td>
                    <td>
                        <g:select name="typeId" value="${rechercheCommand.typeId}"
                                  noSelection="${['null': 'Tous']}"
                                  from="${typesSujet}"
                                  optionKey="id"
                                  optionValue="nom"/>
                    </td>
                </tr>
                <tr>
                    <td class="label">
                        Description :
                    </td>
                    <td>
                        <g:textField name="patternPresentation" title="description"
                                     value="${rechercheCommand.patternPresentation}"/>
                    </td>
                    <td width="20"/>
                    <td class="label">Matière :
                    </td>
                    <td>
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
                        <td>
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
                    <td width="20"/>
                    <td class="label">Niveau :
                    </td>
                    <td>
                        <g:select name="niveauId" value="${rechercheCommand.niveauId}"
                                  noSelection="${['null': 'Tous']}"
                                  from="${niveaux}"
                                  optionKey="id"
                                  optionValue="libelleLong"/>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <g:checkBox name="afficheSujetMasque" value="${afficheSujetMasque}"/>
                        Afficher les sujets masqués
                    </td>
                </tr>

            </table>
        </div>

        <div class="form_actions recherche">
            <g:actionSubmit value="Rechercher" action="recherche" class="button"
                            title="Lancer la recherche"/>
        </div>
    </form>
</g:if>

<g:if test="${sujets}">

    <div class="portal_pagination">
        <p class="nb_result">${sujets.totalCount} résultat(s)</p>

        <g:if test="${affichePager}">
            <div class="pager">Page(s) : <g:paginate total="${sujets.totalCount}"
                                                     params="${rechercheCommand?.toParams()}"></g:paginate></div>
        </g:if>
    </div>

    <div class="portal-default_results-list sujet">
        <%
            def messageDialogue = g.message(code: "sujet.partage.dialogue", args: [CopyrightsType.getDefaultForPartage().logo, CopyrightsType.getDefaultForPartage().code, CopyrightsType.getDefaultForPartage().lien])
        %>
        <g:each in="${sujets}" status="i" var="sujet">
            <g:set var="masque" value="${sujetsMasquesIds?.contains(sujet.id)}"/>
            <div class="${(i % 2) == 0 ? 'even' : 'odd'} sujet ${masque ? 'masque' : ''}" data-sujet="${sujet.id}" style="z-index: 0">

                <h1>
                  ${fieldValue(bean: sujet, field: "titre")}
                  <g:if test="${sujet.estCollaboratif()}">
                    <g:img dir="images/eliot" file="collaborative.png" title="Formateurs: ${sujet.getContributeursAffichage()}" />
                  </g:if>
                  <g:if test="${sujet.estTermine() || sujet.estDistribue()}">
                    <g:img dir="images/eliot" file="termine.png" title="Non modifiable" />
                  </g:if>
                </h1>

                <button id="${sujet.id}">Actions</button>
                <ul id="menu_actions_${sujet.id}" class="tdbase-menu-actions">
                  <g:render template="menuActions"
                            model="${[
                                artefactHelper    : artefactHelper,
                                sujet             : sujet,
                                utilisateur       : utilisateur,
                                modeRecherche     : true,
                                masque            : masque,
                                jsSupprimeSujet   : 'supprimeSujet'
                            ]}"/>
                </ul>

                <p class="date">Mise à jour le ${sujet.lastUpdated?.format('dd/MM/yy HH:mm')}</p>

                <p>
                    <g:if
                            test="${sujet.niveau?.libelleLong}"><strong>» Niveau :</strong> ${sujet.niveau?.libelleLong}</g:if>
                    <g:if
                            test="${sujet.matiereBcn?.libelleEdition}"><strong>» Matière :</strong> ${sujet.matiereBcn?.libelleEdition}</g:if>
                    <g:if
                            test="${fieldValue(bean: sujet, field: "dureeMinutes")}"><strong>» Durée :</strong> ${fieldValue(bean: sujet, field: "dureeMinutes")}</g:if>
                    <g:if test="${artefactHelper.partageArtefactCCActive && afficheFormulaire}">
                        <strong>» Auteur :</strong> ${sujet.proprietaire.prenom} ${sujet.proprietaire.nom}
                    </g:if>
                    <g:if test="${artefactHelper.partageArtefactCCActive}">
                        <strong>» Partagé :</strong> ${sujet.estPartage() ? 'oui' : 'non'}
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