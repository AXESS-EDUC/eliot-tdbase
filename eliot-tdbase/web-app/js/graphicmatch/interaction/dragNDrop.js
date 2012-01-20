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

    initWidgets();
    registerEventHandlers();

    function initWidgets() {
        new Common().positionHotspots();

        //hide html elements
        $('.hotspotSelector').hide();
        $('div[indexReponse]>.hotspotStyle').html('');

        // make elements draggable and droppable

        $(".icon").each(function () {
            var containmentObjectId = '#' + $(this).parents('.imageContainer').attr('id');
            $(this).draggable({containment:containmentObjectId});
            $(this).css('z-index', '1');
        });


        $('.hotspotStyle').droppable();

        positionIcons();
    }

    function registerEventHandlers() {

        $(".hotspotStyle").bind("dropover", function (event, ui) {
            onDropOver($(this), ui.draggable);
        });

        $(".hotspotStyle").bind("dropout", function (event, ui) {
            onDropOut($(this), ui.draggable);
        });

        $(".icon").bind("dragstop", function () {
            onDragStop($(this));
        })
    }

    function onDropOut(dropTarget, draggable) {
        var dropTargetId = dropTarget.attr('id');
        var draggableId = draggable.attr('id');

        if (dropTargetId in droppedItems && droppedItems[dropTargetId] == draggableId) {
            unHighlight(dropTarget);
            resetFieldValue(draggableId);
            delete droppedItems[dropTargetId];
        }
    }

    function onDropOver(dropTarget, draggable) {
        var dropTargetId = dropTarget.attr('id');
        var hotspotId = dropTarget.attr('hotspotId');
        var draggableId = draggable.attr('id');

        if (!(dropTargetId in droppedItems)) {
            highlight(dropTarget);
            setFieldValue(draggableId, hotspotId);
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

    function highlight(dropTarget) {
        dropTarget.removeClass("unHighlightedHotspot");
        dropTarget.addClass("highlightedHotspot");
    }

    function unHighlight(dropTarget) {
        dropTarget.removeClass("highlightedHotspot");
        dropTarget.addClass("unHighlightedHotspot");
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

    function setFieldValue(fieldId, value) {
        $('#' + fieldId + '_graphicMatch').val(value);
    }

    function resetFieldValue(fieldId) {
        $('#' + fieldId + '_graphicMatch').prop('selectedIndex', 0);
    }

    /**
     * For each graphic between an icon and an hotspot, stored in
     * '.hotspotSelector',position the icon inside the corresponding hotspot.
     */
    function positionIcons() {
        $(".hotspotSelector").each(function () {
            var selectedHotspot = $(this).val();
            var icon = $(this).parent('.icon');

            if (selectedHotspot && selectedHotspot != "-1") {
                var indexReponse = $(this).parents('.imageContainer').attr('indexreponse');
                var hotspotId = 'hotspot_' + indexReponse + '_' + selectedHotspot;
                putDraggableIntoDroppable(icon.attr('id'), hotspotId);
                highlight($('#' + hotspotId));
            }
        });
    }
}