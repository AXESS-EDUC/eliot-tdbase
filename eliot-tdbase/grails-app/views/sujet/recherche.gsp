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
  <title>TDBase - Recherche de sujets</title>
</head>

<body>
<div class="column span-22 last middle">
  <g:render template="/breadcrumps" model="[liens: liens]"/>
  <g:if test="${afficheFormulaire}">
    <form>
      <div class="portal-form_container">
        <table>
          <tr>
            <td class="label">
              Titre :
            </td>
            <td>
              <g:textField name="patternTitre" title="titre" value="${rechercheCommand.patternTitre}"/>
            </td>
            <td width="20"/>
            <td class="label">Type :
            </td>
            <td>
              <g:select name="typeId" value="${rechercheCommand.typeId}"
                      noSelection="${['null':'Tous']}"
                      from="${typesSujet}"
                      optionKey="id"
                      optionValue="nom" />
            </td>
          </tr>
          <tr>
            <td class="label">
              Description :
            </td>
            <td>
              <g:textField name="patternPresentation" title="titre" value="${rechercheCommand.patternPresentation}"/>
            </td>
            <td width="20"/>
            <td class="label">Matière :
            </td>
            <td>
               <g:select name="matiereId" value="${rechercheCommand.matiereId}"
                      noSelection="${['null':'Toutes']}"
                      from="${matieres}"
                      optionKey="id"
                      optionValue="libelleLong" />
            </td>
          </tr>
          <tr>
            <td class="label">Auteur :
            </td>
            <td>
              <g:textField name="patternAuteur" title="titre" value="${rechercheCommand.patternAuteur}"/>
            </td>
            <td width="20"/>
            <td class="label">Niveau :
            </td>
            <td>
              <g:select name="niveauId" value="${rechercheCommand.niveauId}"
                      noSelection="${['null':'Tous']}"
                      from="${niveaux}"
                      optionKey="id"
                      optionValue="libelleLong" />
            </td>
          </tr>

        </table>
      </div>

      <div class="form_actions">
        <g:actionSubmit value="Rechercher" action="recherche" title="Lancer la recherche"/>
      </div>
    </form>
  </g:if>

  <g:if test="${sujets}">
    <div class="portal_pagination">
      ${sujets.totalCount} résultat(s) <g:paginate total="${sujets.totalCount}" params="${rechercheCommand?.toParams()}"></g:paginate>
    </div>

    <div class="portal-default_table">
      <table>
        <thead>
        <tr>
          <th>Titre</th>
          <th>Niveau</th>
          <th>Matière</th>
          <th>Dur&eacute;e</th>
          <g:if test="${afficheFormulaire}">
            <th>Auteur</th>
          </g:if>
          <th>Accès public</th>
          <th>Modifier</th>
          <th>Séance</th>
          <th>Mise à jour le</th>
        </tr>
        </thead>

        <tbody>
        <g:each in="${sujets}" status="i" var="sujetInstance">
          <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
            <td>
              ${fieldValue(bean: sujetInstance, field: "titre")}
            </td>
            <td>
              ${sujetInstance.niveau?.libelleLong}
            </td>
            <td>
              ${sujetInstance.matiere?.libelleLong}
            </td>
            <td>
              ${fieldValue(bean: sujetInstance, field: "dureeMinutes")}
            </td>
            <g:if test="${afficheFormulaire}">
              <td>${sujetInstance.proprietaire.prenom} ${sujetInstance.proprietaire.nom}</td>
            </g:if>
            <td>
              ${sujetInstance.accesPublic ? 'oui' : 'non'}
            </td>
            <td>
              <g:link action="edite"
                      id="${sujetInstance.id}">
                <img border="0"
                     src="/eliot-tdbase/images/eliot/write-btn.gif"
                     width="18" height="16"/>
              </g:link>
            </td>
            <td>

               <g:link action="ajouteSeance"
                      id="${sujetInstance.id}">
                <img border="0"
                     src="/eliot-tdbase/images/eliot/ActionIconAdd.gif"
                     width="20" height="19"/>
              </g:link>

            </td>
            <td>
              ${sujetInstance.lastUpdated?.format('dd/MM/yy HH:mm')}
            </td>
          </tr>
        </g:each>
        </tbody>
      </table>
    </div>
  </g:if>
  <g:else>
     <div class="portal_pagination">
      Aucun résultat
    </div>
  </g:else>
</div>

</body>
</html>