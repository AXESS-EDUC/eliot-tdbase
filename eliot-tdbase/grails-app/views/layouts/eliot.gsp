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
<!doctype html>
<!--[if lt IE 7 ]> <html lang="en" class="no-js ie6"> <![endif]-->
<!--[if IE 7 ]>    <html lang="en" class="no-js ie7"> <![endif]-->
<!--[if IE 8 ]>    <html lang="en" class="no-js ie8"> <![endif]-->
<!--[if IE 9 ]>    <html lang="en" class="no-js ie9"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><!--> <html lang="en" class="no-js"><!--<![endif]-->
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <title><g:layoutTitle default="TDbase"/></title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="shortcut icon"
        href="${resource(dir: 'images', file: 'favicon.ico')}"
        type="image/x-icon">
  <link rel="apple-touch-icon"
        href="${resource(dir: 'images', file: 'apple-touch-icon.png')}">
  <link rel="apple-touch-icon" sizes="114x114"
        href="${resource(dir: 'images', file: 'apple-touch-icon-retina.png')}">
  <link rel="stylesheet" type="text/css"
        href="${resource(dir: 'css/eliot/blueprint/compressed', file: 'screen.css')}"/>
  <link rel="stylesheet" type="text/css"
        href="${resource(dir: 'css/eliot', file: 'BatchNavigation.css')}"/>
  <link rel="stylesheet" type="text/css"
        href="${resource(dir: 'css/eliot', file: 'portal.css')}"/>
  <link rel="stylesheet" type="text/css"
        href="${resource(dir: 'css/eliot', file: 'portal-menu.css')}"/>
  <link rel="stylesheet" type="text/css"
        href="${resource(dir: 'css/eliot', file: 'tdbase.css')}"/>
  <g:layoutHead/>
</head>

<body>
<div class="container">
  <div class="column span-22 last middle">
    <div class="portal-menu" style="margin-bottom:15px;">
      <ul id="portal-hz-menu">
        <li>
          <a title="Séances">Séances</a>
          <ul>
            <li title="Liste des séances">
              <a title="Séances"
                 href="#">Liste des séances</a>
            </li>
            <li title="Nouvelle">
              <a title="Nouvelle séance"
                 href="#">Nouvelle</a>
            </li>
          </ul>
        </li>
        <li class="actif">
          <a title="Sujets">Sujets</a>
          <ul>
            <li title="Nouveau">
              <a title="Pour créer un nouveau sujet"
                 href="#">Nouveau</a>
            </li>
            <li title="Rechercher">
              <a href="#">Rechercher</a>
            </li>
            <li title="Mes sujets">
              <a title="Lister mes sujets"
                 href="#">Mes sujets</a>
            </li>
          </ul>
        </li>
        <li>
          <a title="Mes contributions">Mes contributions</a>
          <ul>
            <li title="Questions">
              <a title="Rechercher mes questions"
                 href="#">Questions</a>
            </li>
            <li title="Documents">
              <a title="Rechercher mes documents"
                 href="#">Documents</a>
            </li>
            <li title="Enonces">
              <a title="Rechercher mes éléments d'énoncé"
                 href="#">Eléments d'énoncés</a>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
  <g:layoutBody/>
  <div class="column span-22 last middle" id="portal-footer">
    %{--footer à compléter--}%
  </div>
</div>
<g:javascript src="eliot/overlib.js"/>
<g:javascript src="eliot/portal-menu.js"/>
<g:javascript src="eliot/NoBacktrack.js"/>

</body>
</html>