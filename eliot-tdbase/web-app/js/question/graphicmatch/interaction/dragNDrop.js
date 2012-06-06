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
    var common = new GraphicMatchCommon();

    initWidgets();
    registerEventHandlers();

    function initWidgets() {
        common.positionHotspots();

        //hide html elements
        $('.hotspotSelector').hide();
        $('.imageContainer>.hotspotStyle').html('');

        // make elements draggable and droppable
        $(".imageContainer[qualifier=interaction]>.icons>.icon").each(function () {
            var containmentObjectId = '#' + $(this).parents('.imageContainer').attr('id');
            $(this).draggable({containment:containmentObjectId});
        });


        $('.hotspotStyle').droppable();

        common.positionIcons();
        new SeanceCopieCommon().disableDraggablesIfInCorrectionMode(".imageContainer[qualifier=interaction]>.icons>.icon");
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
            common.unHighlight(dropTarget);
            resetFieldValue(draggableId);
            delete droppedItems[dropTargetId];
        }
    }

    function onDropOver(dropTarget, draggable) {
        var dropTargetId = dropTarget.attr('id');
        var hotspotId = dropTarget.attr('hotspotId');
        var draggableId = draggable.attr('id');

        if (!(dropTargetId in droppedItems)) {
            common.highlight(dropTarget);
            setFieldValue(draggableId, hotspotId);
            droppedItems[dropTargetId] = draggableId;
        }
    }

    function onDragStop(draggable) {
        var draggableId = draggable.attr("id");

        for (var dropTargetId in droppedItems) {
            if (droppedItems[dropTargetId] == draggableId) {
                common.putDraggableIntoDroppable(draggableId, dropTargetId);
            }
        }
    }

    function setFieldValue(fieldId, value) {
        $('#' + fieldId + '_graphicMatch').val(value);
    }

    function resetFieldValue(fieldId) {
        $('#' + fieldId + '_graphicMatch').prop('selectedIndex', 0);
    }
}