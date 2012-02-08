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
  <r:require modules="eliot-tdbase-ui"/>
  <r:script>
    $(document).ready(function () {
      $('#menu-item-sujets').addClass('actif');
      initButtons();
    });
  </r:script>
  <title>TDBase - Recherche de sujets</title>
</head>

<body>
<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>
<g:if test="${afficheFormulaire}">
  <form>
    <div class="portal-form_container">
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
            <g:textField name="patternPresentation" title="titre"
                         value="${rechercheCommand.patternPresentation}"/>
          </td>
          <td width="20"/>
          <td class="label">Matière :
          </td>
          <td>
            <g:select name="matiereId" value="${rechercheCommand.matiereId}"
                      noSelection="${['null': 'Toutes']}"
                      from="${matieres}"
                      optionKey="id"
                      optionValue="libelleLong"/>
          </td>
        </tr>
        <tr>
          <td class="label">Auteur :
          </td>
          <td>
            <g:textField name="patternAuteur" title="titre"
                         value="${rechercheCommand.patternAuteur}"/>
          </td>
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

      </table>
    </div>

    <div class="form_actions">
      <g:actionSubmit value="Rechercher" action="recherche"
                      title="Lancer la recherche"/>
    </div>
  </form>
</g:if>

<g:if test="${sujets}">
  <div class="portal_pagination">
    ${sujets.totalCount} résultat(s) <g:paginate total="${sujets.totalCount}"
                                                 params="${rechercheCommand?.toParams()}"></g:paginate>
  </div>
  
<div class="portal-default_results-list">	
	<g:each in="${sujets}" status="i" var="sujetInstance">
	  <div class="${(i % 2) == 0 ? 'even' : 'odd'}">
	  	<button class="n0o-js" id="${sujetInstance.id}">Actions</button>
        <ul id="menu_actions_${sujetInstance.id}" class="tdbase-menu-actions">
	          <li><g:link action="teste" id="${sujetInstance.id}">
	            Tester
	          </g:link>
	          </li>
	          <li><g:link action="ajouteSeance" id="${sujetInstance.id}">
	            Nouvelle&nbsp;séance
	          </g:link>
	          </li>
	          <li><hr/></li>
	          <g:if test="${artefactHelper.utilisateurPeutModifierArtefact(utilisateur, sujetInstance)}">
	            <li><g:link action="edite"
	                        id="${sujetInstance.id}">Modifier</g:link></li>
	          </g:if>
	          <g:else>
	            <li>Modifier</li>
	          </g:else>
	          <g:if test="${artefactHelper.utilisateurPeutDupliquerArtefact(utilisateur, sujetInstance)}">
	            <li><g:link action="duplique"
	                        id="${sujetInstance.id}">Dupliquer</g:link></li>
	          </g:if>
	          <g:else>
	            <li>Dupliquer</li>
	          </g:else>
	          <li><hr/></li>
	          <g:if test="${artefactHelper.utilisateurPeutPartageArtefact(utilisateur, sujetInstance)}">
	            <li><g:link action="partage"
	                        id="${sujetInstance.id}">Partager</g:link></li>
	          </g:if>
	          <g:else>
	            <li>Partager</li>
	          </g:else>
	          <li><hr/></li>
	          <g:if test="${artefactHelper.utilisateurPeutSupprimerArtefact(utilisateur, sujetInstance)}">
	            <li><g:link action="supprime"
	                        id="${sujetInstance.id}">Supprimer</g:link></li>
	          </g:if>
	          <g:else>
	            <li>Supprimer</li>
	          </g:else>
        </ul>
	  	<h1> ${fieldValue(bean: sujetInstance, field: "titre")}</h1>
	  	<ul class="feature">
	  		<li><strong>Niveau :</strong> ${sujetInstance.niveau?.libelleLong}</li>
	  		<li><strong>Matière :</strong> ${sujetInstance.matiere?.libelleLong}</li> 
	  		<li><strong>Durée :</strong> ${fieldValue(bean: sujetInstance, field: "dureeMinutes")}</li>
	  		<g:if test="${afficheFormulaire}">
	  		  <li><strong>Auteur :</strong> ${sujetInstance.proprietaire.prenom} ${sujetInstance.proprietaire.nom}</li>
	  		</g:if>
	  		<li><strong>Partagé :</strong> ${sujetInstance.estPartage() ? 'oui' : 'non'}</li>
	  		<li><strong>Mise à jour le :</strong> ${sujetInstance.lastUpdated?.format('dd/MM/yy HH:mm')}</li>
	  	</ul>
	  	
	  </div>
	</g:each>
</div>
	
  <!--<div class="portal-default_table">
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
        <th>Partagé</th>
        <th>Mise à jour le</th>
        <th>Actions</th>
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
            ${sujetInstance.estPartage() ? 'oui' : 'non'}
          </td>
          <td>
            ${sujetInstance.lastUpdated?.format('dd/MM/yy HH:mm')}
          </td>
          <td>
            <button id="${sujetInstance.id}">Actions</button>
            <ul id="menu_actions_${sujetInstance.id}"
                class="tdbase-menu-actions">
              <li><g:link action="teste" id="${sujetInstance.id}">
                Tester
              </g:link>
              </li>
              <li><g:link action="ajouteSeance" id="${sujetInstance.id}">
                Nouvelle&nbsp;séance
              </g:link>
              </li>
              <li><hr/></li>
              <g:if test="${artefactHelper.utilisateurPeutModifierArtefact(utilisateur, sujetInstance)}">
                <li><g:link action="edite"
                            id="${sujetInstance.id}">Modifier</g:link></li>
              </g:if>
              <g:else>
                <li>Modifier</li>
              </g:else>
              <g:if test="${artefactHelper.utilisateurPeutDupliquerArtefact(utilisateur, sujetInstance)}">
                <li><g:link action="duplique"
                            id="${sujetInstance.id}">Dupliquer</g:link></li>
              </g:if>
              <g:else>
                <li>Dupliquer</li>
              </g:else>
              <li><hr/></li>
              <g:if test="${artefactHelper.utilisateurPeutPartageArtefact(utilisateur, sujetInstance)}">
                <li><g:link action="partage"
                            id="${sujetInstance.id}">Partager</g:link></li>
              </g:if>
              <g:else>
                <li>Partager</li>
              </g:else>
              <li><hr/></li>
              <g:if test="${artefactHelper.utilisateurPeutSupprimerArtefact(utilisateur, sujetInstance)}">
                <li><g:link action="supprime"
                            id="${sujetInstance.id}">Supprimer</g:link></li>
              </g:if>
              <g:else>
                <li>Supprimer</li>
              </g:else>

            </ul>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>-->
</g:if>
<g:else>
  <div class="portal_pagination">
    Aucun résultat
  </div>
</g:else>

</body>
</html>