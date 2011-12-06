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

.participantDraggable {
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

.participantDroppable {
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
    background: #FFFFFF;
}

</style>

<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>
<script type="text/javascript">

    var droppedItems = {};

    $(document).ready(function () {
        initWidgets();
        registerEventHandlers();
    });

    function registerEventHandlers() {
        $(".participantDroppable").bind("dropover", function (event, ui) {
            onDropIn($(this), ui.draggable);
        });

        $(".participantDroppable").bind("dropout", function (event, ui) {
            onDropOut($(this), ui.draggable);
        });
    }

    function initWidgets() {
        $(".participantDraggable").draggable();
        $(".participantDroppable").droppable();
        positionParticipants();
    }

    function setFieldValue(fieldId, value) {
        $("#" + fieldId).attr("value", value);
    }

    function resetFieldValue(fieldId) {
        $("#" + fieldId).removeAttr("value");
    }

    function onDropOut(dropTarget, draggable) {
        var dropTargetId = dropTarget.attr('id');
        var draggableId = draggable.attr('id');

        if (dropTargetId in droppedItems && droppedItems[dropTargetId] == draggableId) {
            dropTarget.removeClass("highlighted");
            resetFieldValue(dropTargetId + "_hidden");
            delete droppedItems[dropTargetId];
        }
    }

    function onDropIn(dropTarget, draggable) {
        var dropTargetId = dropTarget.attr('id');
        var draggableId = draggable.attr('id');

        if (!(dropTargetId in droppedItems)) {
            dropTarget.addClass("highlighted");
            setFieldValue(dropTargetId + "_hidden", getDraggableValue(draggableId));
            droppedItems[dropTargetId] = draggableId;
        }
    }

    function getDraggableValue(draggableId) {
        return $("#" + draggableId + " p").text();
    }

    function getDroppableValue(droppableId) {
        return $("#" + droppableId + "_hidden").attr("value");
    }

    function positionParticipants() {
        $(".participantDroppable input").each(function () {
            var droppableValue = $(this).val();
            var droppableId = $(this).parent(".participantDroppable").attr("id");

            if (droppableValue) {
                var draggableId = findMatchingDraggableIdByDroppableValue(droppableValue);
                putDraggableIntoDroppable(draggableId, droppableId);
            }
        });
    }

    function findMatchingDraggableIdByDroppableValue(droppableValue) {

        var theParentId;

        $(".participantDraggable p").each(function () {
            if (droppableValue == $(this).text()) {
                theParentId = $(this).parent(".participantDraggable").attr("id");
            }
        });

        return theParentId;
    }

    function putDraggableIntoDroppable(draggableId, droppableId) {

        $("#" + draggableId).position({my:"center center", at:"center center", of:$("#" + droppableId), collision:"none"});
        $("#" + droppableId).addClass("highlighted");
        droppedItems[droppableId] = draggableId;
    }

</script>

<g:set var="questionspecifobject" value="${question.specificationObject}"/>
<g:set var="reponsespecifobject" value="${reponse?.specificationObject}"/>
${questionspecifobject.libelle} <br/>
<table id="participantDropTargets">
    <g:each status="i" in="${questionspecifobject.associations}" var="association">
        <tr>
            <td id="droppable${indexReponse}_${i}left" class="participantDroppable">
                <g:hiddenField id="droppable${indexReponse}_${i}left_hidden"
                               name="reponsesCopie.listeReponses[${indexReponse}].specificationObject.valeursDeReponse[${i}].participant1"
                               value="${reponsespecifobject?.valeursDeReponse?.getAt(i)?.participant1}"/>
            </td>
            <td id="droppable${indexReponse}_${i}right" class="participantDroppable">
                <g:hiddenField id="droppable${indexReponse}_${i}right_hidden"
                               name="reponsesCopie.listeReponses[${indexReponse}].specificationObject.valeursDeReponse[${i}].participant2"
                               value="${reponsespecifobject?.valeursDeReponse?.getAt(i)?.participant2}"/>
            </td>
        </tr>
    </g:each>
</table>
<table>
    <tr id="participantDraggables">
        <g:each status="i" in="${questionspecifobject.participants}" var="participant">
            <td id="draggable${indexReponse}_${i}" class="participantDraggable">
                <p>${participant}</p>
            </td>
        </g:each>
    </tr>
</table>