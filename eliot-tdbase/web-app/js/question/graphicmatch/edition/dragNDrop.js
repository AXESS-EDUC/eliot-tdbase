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


    var validationService = new ValidationService();

    initWidgets();
    registerEventHandlers();
    new ValidationService().validate();

    function initWidgets() {
        //hide html tags
        $(".hotspotLabel").hide();
        $(".hotspotAttribute").hide();

        // style html tags
        $('[name="hotspotSupressButton"]').addClass('hotspotSupressButton');

        $('.hotspot_resizable').addClass('hotspotStyle');
        $('.hotspot_draggable').addClass('unHighlightedHotspot');
        $(".hotspot_draggable").css('position', 'absolute');

        // make hotspots draggable
        $(".hotspot_draggable").draggable({containment:'.imageContainer', stack:'div'});

        // make hotspots resizable
        $(".hotspot_resizable").resizable({handles:"se", stop:function (event, ui) {
            onResizeStopped($(this), ui)
        }, start:function (event, ui) {
            onBeginResize($(this), ui)
        }});

        resizeHotspots();
        positionHotspots();
        addHotpotIds();
    }

    function registerEventHandlers() {

        $(".hotspot_draggable").bind("dragstop", function () {
            onDragStop($(this));
        })
    }

    function positionHotspots() {
        $(".hotspot_resizable").each(function () {
            var offLeft = $(this).children('#offLeft').val();
            var offTop = $(this).children('#offTop').val();

            $(this).parents('.hotspot_draggable').position({
                of:$(".imageContainer"), my:"left top", at:"left top",
                offset:offLeft + " " + offTop, collision:"none"
            });
        });
    }

    /**
     * Memorize the position of the hotspot relative to the image.
     * @param hotspot
     */
    function onDragStop(hotspot) {
        var imageLeft = $('.imageContainer').position().left;
        var imageTop = $('.imageContainer').position().top;

        var hotspotLeft = hotspot.position().left - imageLeft;
        var hotspotTop = hotspot.position().top - imageTop;

        hotspot.children('.hotspot_resizable').children('input#offLeft').val(hotspotLeft);
        hotspot.children('.hotspot_resizable').children('input#offTop').val(hotspotTop);
    }

    function addHotpotIds() {
        $(".hotspot_resizable").each(function () {

            var id = $(this).children(".idField").val();

            $(this).append("<span class='hotspotId'>" + id + "</span>");

        });
    }


    function resizeHotspots() {

        $(".hotspot_resizable").each(function () {

            var width = $(this).children('#width').val();
            var height = $(this).children('#height').val();
            $(this).css("width", width);
            $(this).css("height", height);
        });

    }

    function onResizeStopped(hotSpot, ui) {
        var hotspotId = $(hotSpot).attr("id");
        $("#" + hotspotId + ">input#width").val(ui.size.width);
        $("#" + hotspotId + ">input#height").val(ui.size.height);
    }

    /**
     * Sets the maximum size that a resizable can have based on its
     * position within the image container.
     * @param hotSpot
     * @param ui
     */
    function onBeginResize(hotSpot, ui) {
        var maxHeight = $('.imageContainer').height() - hotSpot.parent().position().top;
        var maxWidth = $('.imageContainer').width() - hotSpot.parent().position().left;
        hotSpot.resizable("option", "maxHeight", maxHeight);
        hotSpot.resizable("option", "maxWidth", maxWidth);
    }
}