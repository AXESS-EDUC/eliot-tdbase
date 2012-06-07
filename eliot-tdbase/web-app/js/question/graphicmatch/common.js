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
function GraphicMatchCommon() {

    this.positionHotspots = function () {
        $(".hotspots>li").each(function () {
            var id = $(this).attr('id');
            var hotspotId = $(this).attr('hotspotId');
            var hotspotDiv = $("<div>" + hotspotId + "</div>");

            hotspotDiv.attr('id', id);
            hotspotDiv.attr('hotspotId', hotspotId);

            hotspotDiv.addClass('hotspotStyle');
            hotspotDiv.addClass('unHighlightedHotspot');

            $(this).parents('.imageContainer').append(hotspotDiv);

            var offLeft = $(this).attr('leftdistance');
            var offTop = $(this).attr('topdistance');
            var width = $(this).attr('width');
            var height = $(this).attr('height');

            hotspotDiv.css('position', 'absolute');
            hotspotDiv.css('top', offTop + 'px');
            hotspotDiv.css('left', offLeft + 'px');
            hotspotDiv.css("width", width + 'px');
            hotspotDiv.css("height", height + 'px');
            $(this).remove();
        });
    };

    /**
     * For each graphic between an icon and an hotspot, stored in
     * '.hotspotSelector',position the icon inside the corresponding hotspot.
     */
    this.positionIcons = function () {
        $(".hotspotSelector").each(function () {

            var selectedHotspot = $(this).val();

            if (!selectedHotspot) {
                selectedHotspot = $(this).html();
            }

            if (selectedHotspot && selectedHotspot != "-1") {
                var hotspotId = $(this).parents(".imageContainer").children("[hotspotid=" + selectedHotspot + "]").attr('id');
                var iconId = $(this).parents('.icon').attr('id');

                new GraphicMatchCommon().putDraggableIntoDroppable(iconId, hotspotId);
                new GraphicMatchCommon().highlight($('#' + hotspotId));
            }
        });
    };

    this.putDraggableIntoDroppable = function (draggableId, droppableId) {
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
    };

    this.highlight = function (dropTarget) {
        dropTarget.removeClass("unHighlightedHotspot");
        dropTarget.addClass("highlightedHotspot");
    };

    this.unHighlight = function (dropTarget) {
        dropTarget.removeClass("highlightedHotspot");
        dropTarget.addClass("unHighlightedHotspot");
    };

}