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

    initWidgets();
    registerEventHandlers();
    new ValidationService().validate();

    function initWidgets() {
        $(".textZone").draggable({containment:'#fillgraphicsEditor', stack:'div'});
        positionTextZones();

        $(".textArea").resizable({handles:"se", stop:function (event, ui) {
            onResize($(this), ui)
        }});
    }

    function registerEventHandlers() {
        $(".textZone").bind("dragstop", function () {
            onDragStop($(this));
        });
    }

    function onDragStop(textZone) {
        var textZoneId = textZone.attr("id");
        var deleteButtonHeight = $('#' + textZoneId + '>.deleteButton').height();
        var leftOffset = $('#' + textZoneId).position().left;
        var topOffset = $('#' + textZoneId).position().top + deleteButtonHeight;
        $("#" + textZoneId + ">input.offLeft").val(leftOffset);
        $("#" + textZoneId + ">input.offTop").val(topOffset);
    }

    function onResize(textArea, ui) {
        var textZoneId = $(textArea).parents('.textZone').attr("id");
        $("#" + textZoneId + ">input.textWidth").val(ui.size.width);
        $("#" + textZoneId + ">input.textHeight").val(ui.size.height);
    }

    function positionTextZones() {
        $(".textZone").each(function () {
            var offLeft = $(this).children('.offLeft').val();
            var offTop = $(this).children('.offTop').val();
            $(this).position({
                of:$("#fillgraphicsEditor"), my:"left top", at:"left top",
                offset:offLeft + " " + offTop, collision:"none"
            });
        });
    }
}