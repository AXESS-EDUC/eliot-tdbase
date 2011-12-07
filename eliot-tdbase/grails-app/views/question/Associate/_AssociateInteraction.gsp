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


<style type="text/css">

.participant {
    float: left;
    margin: 0 2px 0 2px;
    border: solid 1px #FFD324;
    background: #FFF6BF;
    color: #817134;
    display: inline-block;
    height: 1em;
    padding: 0.5em 0.5em 0.5em 0.5em;
    text-decoration: none;
}

.associationCell {
    float: left;
    margin: 5px 5px 5px 5px;
    border: solid 1px #808080;
    background: #f5f5f5;
    display: inline-block;
    height: 1.5em;
    width: 17em;
    padding: 0.5em 0.5em 0.5em 0.5em;
}

.highlighted {
    background: #b5bdff;
}

</style>

<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>
<script type="text/javascript">

    var droppedItems = {};

    $(document).ready(function () {
        initWidgets();
        registerEventHandlers();
    });

    function initWidgets() {

        // make participants draggable
        $(".participant").each(function () {
            var containmentObjectId = calculateContainmentObjectId($(this));
            $(this).draggable({containment:containmentObjectId});
        });

        // convert associationcells into drop targets
        $(".associationCell").droppable();

        // hide association table cells' input fields
        $('.associationCell input').hide();

        positionParticipants();
    }

    function registerEventHandlers() {
        $(".associationCell").bind("dropover", function (event, ui) {
            onDropOver($(this), ui.draggable);
        });

        $(".associationCell").bind("dropout", function (event, ui) {
            onDropOut($(this), ui.draggable);
        });

        $(".participant").bind("dragstop", function () {
            onDragStop($(this));
        })
    }

    function setFieldValue(fieldId, value) {
        $("#" + fieldId).attr("value", value);
    }

    function resetFieldValue(fieldId) {
        $("#" + fieldId).attr("value", "");
    }

    function calculateContainmentObjectId(draggable) {
        var result = draggable.attr("id").substr(11);
        result = result.substr(0, result.indexOf("_"));
        result = "#associateQuestion_" + result;

        return result;
    }

    function onDropOut(dropTarget, draggable) {
        var dropTargetId = dropTarget.attr('id');
        var draggableId = draggable.attr('id');

        if (dropTargetId in droppedItems && droppedItems[dropTargetId] == draggableId) {
            dropTarget.removeClass("highlighted");
            resetFieldValue(dropTargetId + "_field");
            delete droppedItems[dropTargetId];
        }
    }

    function onDropOver(dropTarget, draggable) {
        var dropTargetId = dropTarget.attr('id');
        var draggableId = draggable.attr('id');

        if (!(dropTargetId in droppedItems)) {
            dropTarget.addClass("highlighted");
            setFieldValue(dropTargetId + "_field", getDraggableValue(draggableId));
            droppedItems[dropTargetId] = draggableId;
        }
    }

    function onDragStop(draggable) {
        var draggableId = draggable.attr("id");

        for (var dropTargetId in droppedItems) {
            if (droppedItems[dropTargetId] == draggableId) {
                putDraggableIntoDroppable(draggableId, dropTargetId);
            }
        }
    }

    function getDraggableValue(draggableId) {
        return $("#" + draggableId + " p").text();
    }

    function getDroppableValue(droppableId) {
        return $("#" + droppableId + "_field").attr("value");
    }

    function positionParticipants() {
        $(".associationCell input").each(function () {
            var droppableValue = $(this).val();
            var droppableId = $(this).parent(".associationCell").attr("id");

            if (droppableValue) {
                var draggableId = findMatchingDraggableIdByDroppableValue(droppableValue);
                putDraggableIntoDroppable(draggableId, droppableId);
                $("#" + droppableId).addClass("highlighted");
            }
        });
    }

    function findMatchingDraggableIdByDroppableValue(droppableValue) {
        var theParentId;

        $(".participant p").each(function () {
            if (droppableValue == $(this).text()) {
                theParentId = $(this).parent(".participant").attr("id");
            }
        });

        return theParentId;
    }

    function putDraggableIntoDroppable(draggableId, droppableId) {
        $("#" + draggableId).position({my:"center center", at:"center center", of:$("#" + droppableId), collision:"none"});
        droppedItems[droppableId] = draggableId;
    }

</script>


<g:set var="questionspecifobject" value="${question.specificationObject}"/>
<g:set var="reponsespecifobject" value="${reponse?.specificationObject}"/>

<div id="associateQuestion_${indexReponse}">
    ${questionspecifobject.libelle} <br/>

    <table>
        <g:each status="i" in="${questionspecifobject.associations}" var="association">
            <tr>
                <td id="association${indexReponse}_${i}left" class="associationCell">
                    <g:textField id="association${indexReponse}_${i}left_field"
                                 name="reponsesCopie.listeReponses[${indexReponse}].specificationObject.valeursDeReponse[${i}].participant1"
                                 value="${reponsespecifobject?.valeursDeReponse?.getAt(i)?.participant1}"/>
                </td>
                <td>------</td>
                <td id="association${indexReponse}_${i}right" class="associationCell">
                    <g:textField id="association${indexReponse}_${i}right_field"
                                 name="reponsesCopie.listeReponses[${indexReponse}].specificationObject.valeursDeReponse[${i}].participant2"
                                 value="${reponsespecifobject?.valeursDeReponse?.getAt(i)?.participant2}"/>
                </td>
            </tr>
        </g:each>
    </table>

    <table>
        <tr id="participants">
            <g:each status="i" in="${questionspecifobject.participants}" var="participant">
                <td id="participant${indexReponse}_${i}" class="participant">
                    <p>${participant}</p>
                </td>
            </g:each>
        </tr>
    </table>
</div>