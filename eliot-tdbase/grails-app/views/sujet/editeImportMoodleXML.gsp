%{--
  - Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
  - This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
  -
  -  Lilie is free software. You can redistribute it and/or modify since
  -  you respect the terms of either (at least one of the both license) :
  -  - under the terms of the GNU Affero General Public License as
  -  published by the Free Software Foundation, either version 3 of the
  -  License, or (at your option) any later version.
  -  - the CeCILL-C as published by CeCILL-C; either version 1 of the
  -  License, or any later version
  -
  -  There are special exceptions to the terms and conditions of the
  -  licenses as they are applied to this software. View the full text of
  -  the exception in file LICENSE.txt in the directory of this software
  -  distribution.
  -
  -  Lilie is distributed in the hope that it will be useful,
  -  but WITHOUT ANY WARRANTY; without even the implied warranty of
  -  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  -  Licenses for more details.
  -
  -  You should have received a copy of the GNU General Public License
  -  and the CeCILL-C along with Lilie. If not, see :
  -  <http://www.gnu.org/licenses/> and
  -  <http://www.cecill.info/licences.fr.html>.
  --}%

<%@ page import="org.lilie.services.eliot.tdbase.SujetType" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta name="layout" content="eliot-tdbase"/>
  <r:require modules="jquery, jquery-ui, eliot-tdbase-combobox-autocomplete"/>
  <r:script>
    $(document).ready(function () {
      $('#menu-item-sujets').addClass('actif');
      $("form").attr('enctype', 'multipart/form-data');

      initComboboxAutoComplete({
        combobox: '#matiereId',

        recherche: function(recherche, callback) {
          if (recherche == null || recherche.length < 3) {
            callback([]);
          }
          else {
            $.ajax({
              url: '${g.createLink(absolute:true, uri:"/sujet/matiereBcns")}',

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
  </r:script>
  <title><g:message code="sujet.editeImportMoodleXML.head.title" /></title>
</head>

<body>
<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>

<g:if test="${flash.errorMessageCode}">
  <div class="portal-messages">
    <li class="error"><g:message code="${flash.errorMessageCode}"
                                   class="portal-messages error"/></li>
  </div>
</g:if>

<form method="post" action="#" class="sujet">
  <div class="portal-form_container edite">
    <table>
      <tr>
        <td>&nbsp;</td>
        <td><b><g:message code="importexport.MOODLE_XML.explication.format"/></b></td>
      </tr>
      <tr>
        <td class="label">Mati&egrave;re&nbsp;:</td>
        <td class="matiere">
          <g:select name="matiereId"
                    from="${matiereBcns}"
                    optionKey="id"
                    optionValue="libelleEdition"/>
        </td>
      </tr>
      <tr>
        <td class="label">Niveau&nbsp;:</td>
        <td class="niveau">
          <g:select name="niveauId" value="${sujet.niveau?.id}"
                    from="${niveaux}"
                    optionKey="id"
                    optionValue="libelleLong"/>
        </td>
      </tr>
      <tr>
        <td class="label">Fichier&nbsp;:</td>
        <td id="fichier_import_td">
          <input type="file" name="fichierImport"> (max. ${fichierMaxSize}Mo)
        </td>
      </tr>
    </table>
  </div>
  <g:hiddenField name="sujetId" value="${sujet.id}"/>
  <div class="form_actions">
    <g:actionSubmit value="Importer" action="importMoodleXML"
                    class="button"
                    title="Importer"/>
  </div>
</form>

</body>
</html>