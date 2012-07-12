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

    $(".fillGapTextContainer").each(function () {
        var containerID = $(this).attr('id');

        if (showSuggestedWords(containerID)) {
            initWidgets(containerID);
            registerEventHandlers(containerID);
        }

    });

    function showSuggestedWords(containerID) {
        return $(".gapWords[id=" + containerID + "]").attr("show") == "true";
    }

    function initWidgets(containerID) {

        var fillGapTextContainer = '.fillGapTextContainer[id=' + containerID + ']';
        var gapWords = fillGapTextContainer + '>.gapWords>.gapWordsList>.gapWord';

        //hide gap textField
        $(fillGapTextContainer + ' .gapText .gapElement .gapField').hide();

        // set up drop zone
        $(fillGapTextContainer + ' .gapText .gapElement').addClass("dropZone");
        for (i = 0; i <= 20; i++) {
            $(fillGapTextContainer + ' .gapText .gapElement').append("&nbsp;");
        }

        // make elements draggable and droppable
        $(gapWords).draggable({containment:fillGapTextContainer, stack:".gapWord"});
        $(fillGapTextContainer + ' .gapText .gapElement').droppable();

        positionSuggestedWords(fillGapTextContainer);
    }

    function registerEventHandlers(containerID) {

        var fillGapTextContainer = '.fillGapTextContainer[id=' + containerID + ']';
        var gapElements = $(fillGapTextContainer + ' .gapText .gapElement');
        var gapWords = $(fillGapTextContainer + '>.gapWords>.gapWordsList>.gapWord');

        gapElements.bind("dropover", function (event, ui) {
            onDropOver($(this), ui.draggable);
        });

        gapElements.bind("dropout", function (event, ui) {
            onDropOut($(this), ui.draggable);
        });

        gapWords.bind("dragstop", function () {
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
            setFieldValue(dropTargetId, draggable.attr("word"));
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
        $('#' + fieldId + ">input").val(value);
    }

    function positionSuggestedWords(fillGapTextContainer) {


        var gapElements = $(fillGapTextContainer + ' .gapText .gapElement');

        $(gapElements).each(function () {

            var textFieldValue = $(this).children('input').val();
            var matchingGapWords = fillGapTextContainer + ">.gapWords>.gapWordsList>.gapWord[word='" + textFieldValue + "']";


            if (textFieldValue != "" && $(matchingGapWords).length > 0) {

                var draggableId = getNotYetDraggedGapWordId(matchingGapWords);
                var dropTargetId = $(this).attr('id');

                putDraggableIntoDroppable(draggableId, dropTargetId);
                highlight($(this));
                droppedItems[dropTargetId] = draggableId;
            }
        });
    }

    /**
     * Cherche parmis les mots suggerés ceux qui ne sont pas encore placés dans un trou.
     * @param matchingGapWords
     */
    function getNotYetDraggedGapWordId(matchingGapWords) {
        var result;

        $(matchingGapWords).each(function () {

            var draggableId = $(this).attr('id');
            var hit = false;

            // see if present in list of already dragged items
            for (var dropTargetId in droppedItems) {
                if (droppedItems[dropTargetId] == draggableId) {
                    hit = true;
                }
            }

            // if not present then we have found a result.
            if (!hit) {
                result = draggableId;
            }

        });

        return result;

    }


}