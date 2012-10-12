/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 * Lilie is free software. You can redistribute it and/or modify since
 * you respect the terms of either (at least one of the both license) :
 * - under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * - the CeCILL-C as published by CeCILL-C; either version 1 of the
 * License, or any later version
 *
 * There are special exceptions to the terms and conditions of the
 * licenses as they are applied to this software. View the full text of
 * the exception in file LICENSE.txt in the directory of this software
 * distribution.
 *
 * Lilie is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Licenses for more details.
 *
 * You should have received a copy of the GNU General Public License
 * and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */


function initDragNDrop() {

    /**
     * Items that are currently dropped in a drop target.
     */
    var droppedItems = {};

    $(".fillgraphicsEditor").each(function () {
        var editorID = $(this).attr('id');

        if (showSuggestedWords(editorID)) {
            initWidgets(editorID);
            registerEventHandlers(editorID);
        }

    });

    function showSuggestedWords(editorID) {
        return $(".suggestedWords[id=" + editorID + "]").attr("show") == "true";
    }

    function initWidgets(editorID) {

        var fillgraphicsEditor = '.fillgraphicsEditor[id=' + editorID + ']';
        var suggestedWords = fillgraphicsEditor + '>.suggestedWords>.suggestedWordsList>.suggestedWord';


        //hide textareas and dimension textzone divs
        $(fillgraphicsEditor + '>.textZone>textarea').each(function () {
            $(this).hide();
            var width = $(this).css("width");
            var height = $(this).css("height");
            $(this).parent('.textZone').css("width", width);
            $(this).parent('.textZone').css("height", height);
        });

        // make elements draggable and droppable

        $(suggestedWords).draggable({containment:fillgraphicsEditor, stack:".suggestedWords"});

        $(fillgraphicsEditor + '>.textZone').droppable();

        positionSuggestedWords(fillgraphicsEditor);
    }

    function registerEventHandlers(editorID) {

        var fillgraphicsEditor = '.fillgraphicsEditor[id=' + editorID + ']';
        var suggestedWords = fillgraphicsEditor + '>.suggestedWords>.suggestedWordsList>.suggestedWord';

        $(fillgraphicsEditor + '>.textZone').bind("dropover", function (event, ui) {
            onDropOver($(this), ui.draggable);
        });

        $(fillgraphicsEditor + '>.textZone').bind("dropout", function (event, ui) {
            onDropOut($(this), ui.draggable);
        });

        $(suggestedWords).bind("dragstop", function () {
            onDragStop($(this));
        })
    }

    function onDropOut(dropTarget, draggable) {
        var dropTargetId = dropTarget.attr('id');
        var draggableId = draggable.attr('id');

        if (dropTargetId in droppedItems && droppedItems[dropTargetId] == draggableId) {
            unHighlight(dropTarget);
            setFieldValue(dropTargetId, "");
            delete droppedItems[dropTargetId];
        }
    }

    function onDropOver(dropTarget, draggable) {
        var dropTargetId = dropTarget.attr('id');
        var draggableId = draggable.attr('id');

        if (!(dropTargetId in droppedItems)) {
            highlight(dropTarget);
            setFieldValue(dropTargetId, draggable.text());
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

    function putDraggableIntoDroppable(draggableId, droppableId) {
        var droppableCenter = {top:0, left:0};
        var draggablePosition = {top:0, left:0};
        var droppableDimension = {width:0, height:0};
        var draggableDimension = {width:0, height:0};
        var droppablePosition = $('#' + droppableId).position();

        droppableDimension.width = $('#' + droppableId).outerWidth(true);
        droppableDimension.height = $('#' + droppableId).outerHeight(true);

        draggableDimension.width = $('#' + draggableId).outerWidth(true);
        draggableDimension.height = $('#' + draggableId).outerHeight(true);

        droppableCenter.top = Math.round(droppablePosition.top + droppableDimension.height / 2);
        droppableCenter.left = Math.round(droppablePosition.left + droppableDimension.width / 2);

        draggablePosition.top = Math.round(droppableCenter.top - draggableDimension.height / 2);
        draggablePosition.left = Math.round(droppableCenter.left - draggableDimension.width / 2);

        $('#' + draggableId).css('position', 'absolute');
        $('#' + draggableId).css('top', draggablePosition.top);
        $('#' + draggableId).css('left', draggablePosition.left);
    }

    function highlight(dropTarget) {
        dropTarget.removeClass("unHighlighted");
        dropTarget.addClass("highlighted");
    }

    function unHighlight(dropTarget) {
        dropTarget.removeClass("highlighted");
        dropTarget.addClass("unHighlighted");
    }

    function setFieldValue(fieldId, value) {
        $('#' + fieldId + ">textArea").val(value);
    }

    function positionSuggestedWords(fillgraphicsEditorSelector) {

        $(fillgraphicsEditorSelector + ">.textZone").each(function () {

            var textZoneValue = $(this).children('textArea').val().replace(/\r?\n/g, " ");   // replace CR,NL,... by spaces
            var suggestedWord = fillgraphicsEditorSelector + ">.suggestedWords>.suggestedWordsList>.suggestedWord[word='" + textZoneValue + "']";

            if (textZoneValue != "" && $(suggestedWord).length == 1) {

                var draggableId = $(suggestedWord).attr('id');
                var dropTargetId = $(this).attr('id');

                putDraggableIntoDroppable(draggableId, dropTargetId);
                highlight($(this));
                droppedItems[dropTargetId] = draggableId;
            }
        });

    }


}