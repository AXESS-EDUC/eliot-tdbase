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
    <meta name="layout" content="eliot-tdbase-activite"/>
    <r:require modules="eliot-tdbase"/>
    <title><g:message code="utilisateur.preference.head.title"/></title>
</head>

<body>
<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>

<div>
    <div class="portal-tabs">
        <span class="portal-tabs-famille-liens">
            Préférences
        </span>
    </div>
</div>
<g:hasErrors bean="${preferencePersonne}">
    <div class="portal-messages">
        <g:eachError>
            <li class="error"><g:message error="${it}"/></li>
        </g:eachError>
    </div>
</g:hasErrors>
<g:if test="${flash.messageTextesCode}">
    <div class="portal-messages">
        <li class="success"><g:message code="${flash.messageTextesCode}"
                                       class="portal-messages success"/></li>
    </div>
</g:if>

<g:form method="post" controller="utilisateur" action="enregistrePreference">
    <g:hiddenField name="id" value="${preferencePersonne.id}"/>
    <div class="portal-form_container edite" style="width: 69%;">
        <table>
            <tr>
                <td class="label"><g:message code="utilisateur.preference.notificationOnCreationSeance"/>&nbsp;
                </td>
                <td>
                    <g:checkBox id="notificationOnCreationSeance" name="notificationOnCreationSeance"
                                value="${preferencePersonne.notificationOnCreationSeance}"/></td>
            </tr>
            <tr>
                <td class="label"><g:message code="utilisateur.preference.notificationOnPubicationResultats"/>&nbsp;
                </td>
                <td>
                    <g:checkBox id="notificationOnPublicationResultats" name="notificationOnPublicationResultats"
                                value="${preferencePersonne.notificationOnPublicationResultats}"/></td>
            </tr>
            <tr>
                <td class="label"><g:message code="utilisateur.preference.supportNotifications"/>&nbsp;
                </td>
                <td>
                    <g:checkBox id="e_mail" name="e_mail"
                                value="${preferencePersonne.codeSupportNotification & 1}"/> e-mail
                    <g:checkBox id="sms" name="sms"
                                value="${preferencePersonne.codeSupportNotification & 2}"/> SMS

                </td>
            </tr>
        </table>
    </div>

    <div class="form_actions edite">
        <g:actionSubmit value="Enregistrer" class="button"
                        action="enregistrePreference" controller="utilisateur"
                        title="Enregistrer"/>
    </div>

</g:form>

<r:script>
    $(document).ready(function () {
        updateCheckboxesState();

        $('#notificationOnCreationSeance').change(function () {
            updateCheckboxesState();
        })
        $('#notificationOnPublicationResultats').change(function () {
            updateCheckboxesState();
        })

        function updateCheckboxesState() {
            if ($('#notificationOnCreationSeance').is(':checked') ||
                    $('#notificationOnPublicationResultats').is(':checked')) {
                $('#e_mail').prop('disabled', false);
                $('#sms').prop('disabled', false);
            } else {
                $('#e_mail').prop('checked', false);
                $('#sms').prop('checked', false);
                $('#e_mail').prop('disabled', true);
                $('#sms').prop('disabled', true);
            }
        }
    });

</r:script>

</body>
</html>