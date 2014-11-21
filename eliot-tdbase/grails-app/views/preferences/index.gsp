<%@ page import="org.lilie.services.eliot.tdbase.securite.RoleApplicatif; org.lilie.services.eliot.tdbase.securite.RoleApplicatif; org.lilie.services.eliot.tice.scolarite.FonctionEnum; org.lilie.services.eliot.tice.scolarite.Fonction" %>
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


<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta name="layout" content="eliot-tdbase-admin"/>
    <r:require modules="eliot-tdbase"/>
    <title><g:message code="preferences.head.title"/></title>
</head>

<body>
<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>

<div>
    <div class="portal-tabs">
        <span class="portal-tabs-famille-liens">
            Établissement ${etablissement.nomAffichage}
        </span>
     </div>
</div>
<g:if test="${flash.messageTextesCode}">
    <div class="portal-messages">
        <li class="success"><g:message code="${flash.messageTextesCode}"
                                      class="portal-messages success"/></li>
    </div>
</g:if>

<g:form method="post" controller="preferences" action="enregistre">
    <g:hiddenField name="prefEtabId" value="${preferenceEtablissement.id}"/>
    <%
        def rolesModifiables = [org.lilie.services.eliot.tdbase.securite.RoleApplicatif.ENSEIGNANT, org.lilie.services.eliot.tdbase.securite.RoleApplicatif.ELEVE]
    %>
    <div class="portal-form_container edite" style="width: 69%;">
        <table>

            <tr>
                <td class="label">&nbsp;
                </td>
                <g:each in="${rolesModifiables*.name()}" var="codeRole">
                    <td class="label" title="${message(code:'preferences.aide.role.'+codeRole)}">
                        <g:message code="preferences.role.$codeRole" default="$codeRole"/>
                    </td>
                </g:each>
            </tr>
            <g:each in="${fonctions}" var="fonction">
                <tr>
                <td class="label">
                    ${fonction.libelle}
                </td>
                    <g:each in="${rolesModifiables}" var="role">
                        <td class="label">
                            <g:checkBox name="fonction__${fonction.code}__role__${role.name()}"
                                        checked="${mappingFonctionRole.hasRoleForFonction(role,FonctionEnum.valueOf(fonction.code)).associe}"
                                        disabled="${!mappingFonctionRole.hasRoleForFonction(role,FonctionEnum.valueOf(fonction.code)).modifiable}"
                            />
                        </td>
                    </g:each>
                </tr>
            </g:each>
        </table>
    </div>

    <div class="form_actions edite">
        <g:actionSubmit value="Enregistrer" class="button"
                        action="enregistre" controller="preferences"
                        title="Enregistrer"/>
    </div>

</g:form>

</body>
</html>