<%@ page import="org.lilie.services.eliot.tice.annuaire.groupe.GroupeType; org.lilie.services.eliot.tdbase.RechercheGroupeCommand; org.lilie.services.eliot.tdbase.ContexteActivite; org.lilie.services.eliot.tice.annuaire.groupe.GroupeType" %>
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
    <r:require module="eliot-tdbase-ui"/>
    <r:script>
    $(document).ready(function () {
      $('#menu-item-seances').addClass('actif');
      $('select[name="structureEnseignementId"]').focus();
      $(".datepicker").datetimepicker();
      var $confirmDialog = $("<div></div>")
      							.html('Êtes vous sur de vouloir supprimer la séance avec toutes les copies associées ?')
      							.dialog({
      								autoOpen: false,
      								title: "Suppression de la séance",
      								modal: true,
      								buttons : {
      									"Annuler": function() {$(this).dialog("close");return false},
      									'OK': function() {
                                            $(this).dialog("close");
                                            document.location = "${createLink(action: 'supprime', controller: 'seance', id: modaliteActivite.id)}";
                                            }
      								}
      							});
      $('.delete-actif').click(function () {
        $confirmDialog.dialog('open');
        return false;
      });


     $("#search-group-form").dialog({
           autoOpen: false,
           title: "Rechercher groupe d'apprenant",
           height: 600,
           width: 420,
           modal: true
      });

     $( "#select-other-group" )
           .click(function() {
             $( "#search-group-form" ).dialog( "open" );
           });

    $('#gestionEvaluation').click(function() {
               $('#edition_devoir').toggle();
               })
    $('#gestionActivite').click(function() {
                   $('#edition_activite').toggle();
                   })
    $('#cahierId').change(function() {
        $.get("${createLink(action: 'updateChapitres', controller: 'seance')}",
                { cahierId: $(this).val()},
                function(data) {
                    $('#selectChapitres').html(data)
                })
    })

    function showHideDureeMinutes() {
        var checked = $("#decompteTemps").prop('checked');
        if (checked) {
            var dureeMinutes = $("#dureeMinutes").val();

            if (dureeMinutes == '') {
                $("#dureeMinutes").val(${modaliteActivite.sujet?.dureeMinutes});
            }

            $("#dureeMinutesContainer").show();
        }
        else {
            $("#dureeMinutes").val('');
            $("#dureeMinutesContainer").hide();
        }
    }

    showHideDureeMinutes();

    $("#decompteTemps").change(showHideDureeMinutes);

    });
    </r:script>
    <style type='text/css' media='screen'>
    .inform {
        display: block;
        width: 53%;
        margin: 2px;
        text-transform: none;
    }

    #chapitreId option {
        white-space: pre;
    }
    </style>
    <title><g:message code="seance.edite.head.title"/></title>
</head>

<body>
<g:render template="/breadcrumps" plugin="eliot-tice-plugin"
          model="[liens: liens]"/>
<div class="portal-tabs">
    <span class="portal-tabs-famille-liens">
        <g:if test="${modaliteActivite.id}">
            <g:link action="listeResultats" controller="seance" class="modify"
                    id="${modaliteActivite.id}">Corriger les copies</g:link> |
            <g:link action="supprime" controller="seance" class="delete delete-actif"
                    id="${modaliteActivite.id}">Supprimer la séance</g:link>
        </g:if>
        <g:else>
            <span class="modify">Corriger les copies</span> |
            <span class="delete">Supprimer la séance</span>
        </g:else>
    </span>
</div>

<g:hasErrors bean="${modaliteActivite}">
    <div class="portal-messages">
        <g:eachError>
            <li class="error"><g:message error="${it}"/></li>
        </g:eachError>
    </div>
</g:hasErrors>
<g:if test="${flash.messageCode}">
    <div class="portal-messages">
        <li class="success"><g:message code="${flash.messageCode}"
                                       class="portal-messages success"/></li>
    </div>
</g:if>
<g:if test="${flash.messageTextesCode}">
    <div class="portal-messages">
        <li class="notice"><g:message code="${flash.messageTextesCode}"
                                      class="portal-messages notice"/></li>
    </div>
</g:if>


<g:form method="post" controller="seance" action="edite">
    <div class="portal-form_container edite" style="width: 69%;">
        <table>

            <tr>
                <td class="label">Classe/groupe<span class="obligatoire">*</span>&nbsp;:
                </td>
                <td>
                    <g:if test="${modaliteActivite.groupe}">
                        <strong>${modaliteActivite.groupe.nomAffichage}</strong>
                        <input type="hidden" name="groupeId" value="${modaliteActivite.groupe.id}"/>
                        <input type="hidden" name="groupeType" value="${modaliteActivite.groupe.groupeType.name()}"/>
                    </g:if>
                    <g:else>
                        <div id="structure-selection" style="float: left; margin-right: 10px;">
                            <g:select name="structureEnseignementId"
                                      noSelection="${['null': g.message(code: "default.select.null")]}"
                                      from="${structureEnseignementList}"
                                      optionKey="id"
                                      optionValue="nomAffichage"/>
                        </div>
                        <a id="select-other-group">Choisir un autre groupe ...</a>
                    </g:else>
                </td>
            </tr>
            <tr>
                <td class="label">Sujet&nbsp;:</td>
                <td>
                    <strong>${modaliteActivite.sujet.titre}</strong> <br/>
                </td>
            </tr>
            <tr>
                <td class="label">Début&nbsp;:</td>
                <td>
                    <g:textField name="dateDebut"
                                 value="${modaliteActivite.dateDebut.format('dd/MM/yyyy HH:mm')}"
                                 class="datepicker short"/>
                </td>
            </tr>
            <tr>
                <td class="label">Fin&nbsp;:</td>
                <td>
                    <g:textField name="dateFin" id="dateFin"
                                 value="${modaliteActivite.dateFin.format('dd/MM/yyyy HH:mm')}"
                                 class="datepicker short"/>
                </td>
            </tr>
            <tr>
                <td class="label">Publication des résultats&nbsp;:</td>
                <td>
                    <g:textField name="datePublicationResultats" id="datePublicationResultats"
                                 value="${modaliteActivite.datePublicationResultats?.format('dd/MM/yyyy HH:mm')}"
                                 class="datepicker short"/>
                </td>
            </tr>

            <tr>
                <td class="label"></td>
                <td>
                    <g:checkBox name="decompteTemps" title="décompte du temps"
                                checked="${modaliteActivite.decompteTemps}"/>
                    <span class="label">
                        Décompte&nbsp;du&nbsp;temps
                        <span id="dureeMinutesContainer">
                            -
                            <input id="dureeMinutes" type="text" name="dureeMinutes"
                                   value="${modaliteActivite.dureeMinutes}" class="micro"
                                   tabindex="5"/>
                            (en minutes)
                        </span>
                    </span>
                </td>
            </tr>
    
            <tr>
                <td class="label"></td>
                <td>
                    <g:checkBox name="copieAmeliorable" title="améliorable"
                                checked="${modaliteActivite.copieAmeliorable}"/> <span
                        class="label">Copie&nbsp;améliorable</span>
                </td>
            </tr>
            <tr>
                <td class="label"></td>
                <td>
                    <g:checkBox name="notifierMaintenant" title="Notifier maintenant les apprenants de la séance"
                                checked="${modaliteActivite.notifierMaintenant}"/> <span
                        class="label">Notifier maintenant les apprenants de la séance</span>
                </td>
            </tr>
            <tr>
                <td class="label"></td>
                <td>
                    <g:checkBox name="notifierAvantOuverture"
                                title="Notifier les apprenants avant l'ouverture de la séance"
                                checked="${modaliteActivite.notifierAvantOuverture}"/> <span
                        class="label">Notifier les apprenants <g:textField name="notifierNJoursAvant"
                                                                             value="${modaliteActivite.notifierNJoursAvant}"
                                                                             style="width: 20px"></g:textField> jour(s) avant</span>
                </td>
            </tr>
            <g:if test="${lienBookmarkable}">
                <tr>
                    <td class="label">Permalien&nbsp;:</td>
                    <td>
                        ${lienBookmarkable}
                    </td>
                </tr>
            </g:if>
            <g:if test="${grailsApplication.config.eliot.interfacage.notes}">
                <tr>
                    <td class="label"></td>
                    <td>
                        <g:if test="${afficheLienCreationDevoir}">
                            <a id="gestionEvaluation" class="button inform"
                               title="Créer un devoir dans Notes">Créer un devoir dans Notes</a>

                            <table id="edition_devoir"
                                   style="display: ${modaliteActivite.evaluationId ? 'table' : 'none'}">
                                <tr>
                                    <td class="label"
                                        style="width: 110px;">Classe/groupe&nbsp;-&nbsp;Matière&nbsp;:</td>
                                    <td><g:select name="serviceId"
                                                  noSelection="${['null': 'Faites votre choix...']}"
                                                  from="${services}"
                                                  optionKey="id"
                                                  optionValue="libelle"/></td>
                                </tr>

                            </table>
                        </g:if>
                        <g:if test="${afficheDevoirCree}">
                            <span class="label"><g:message code="seance.label.devoirlie"/></span>
                        </g:if>
                    </td>
                </tr>
            </g:if>
            <g:if test="${grailsApplication.config.eliot.interfacage.textes}">
                <tr>
                    <td class="label"></td>
                    <td>
                        <g:if test="${afficheLienCreationActivite}">

                            <a id="gestionActivite" class="button inform"
                               title="Créer une activité dans le cahier de textes">
                                Créer une activité dans le Cahier de textes</a>
                            <table id="edition_activite"
                                   style="display: ${modaliteActivite.activiteId ? 'table' : 'none'}">
                                <tr>
                                    <td class="label"
                                        style="width: 110px;">Cahier&nbsp;de&nbsp;textes<span
                                            class="obligatoire">*</span>&nbsp;:</td>
                                    <td><g:select name="cahierId"
                                                  noSelection="${['null': 'Faites votre choix...']}"
                                                  from="${cahiers}"
                                                  optionKey="id"
                                                  optionValue="nom"/>
                                        <span id="spinner" class="spinner" style="display:none;">
                                            <g:message code="spinner.alt"
                                                       default="Loading&hellip;"/></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label" style="width: 110px;">Chapitre&nbsp;:</td>
                                    <td id="selectChapitres">
                                        <g:render template="selectChapitres"
                                                  model="[chapitres: chapitres]"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label" style="width: 110px;">Contexte&nbsp;:</td>
                                    <td><g:select name="activiteContexteId"
                                                  from="${ContexteActivite.values()}"
                                                  valueMessagePrefix="textes.activite.contexte"/></td>
                                </tr>
                            </table>
                        </g:if>
                        <g:if test="${afficheActiviteCreee}">
                            <span class="label"><g:message code="seance.label.activitetextesliee"/></span>
                        </g:if>
                    </td>
                </tr>
            </g:if>

            <g:if test="${competencesEvaluables}">
                <tr>
                    <td class="label"></td>
                    <td>
                        <g:checkBox name="optionEvaluerCompetences" title="Evaluer les competences"
                                    checked="${modaliteActivite.optionEvaluerCompetences}"/> <span
                            class="label">Evaluer les compétences</span>
                    </td>
                </tr>
            </g:if>
        </table>
    </div>
    <g:hiddenField name="id" value="${modaliteActivite.id}"/>
    <g:hiddenField id="sujetId" name="sujet.id"
                   value="${modaliteActivite.sujet?.id}"/>
    <div class="form_actions edite">
        <g:actionSubmit value="Enregistrer" class="button"
                        action="enregistre"
                        title="Enregistrer"/>
    </div>
    <br/><br/><br/><br/><br/>
</g:form>

<div id="search-group-form" style="background-color: #ffffff">
    <g:render template="/seance/selectAutreGroupe" model="[
            etablissements        : etablissements,
            fonctionList          : fonctionList,
            groupeTypeList        : groupeTypeList,
            rechercheGroupeCommand: new RechercheGroupeCommand(etablissementId: currentEtablissement.id, groupeType: GroupeType.SCOLARITE)
    ]"/>
</div>

</body>
</html>