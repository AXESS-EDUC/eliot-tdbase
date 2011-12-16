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

/**
 * Méthode d'initialisation.
 */
function initDragNDrop() {

    var movingItemId = "";
    var setItems = {};

    hideHTML();
    initData();
    initWidgets();
    registerEventHandlers();

    /**
     * Cacher les elements du formulaire.
     */
    function hideHTML() {
        $('.orderedLastOrdinal').hide();
        $('.ordinalSelector').hide();
    }

    /**
     * Initialisation de la backing data structure.
     */
    function initData() {
        $(".dropTarget").each(function () {

            var dropTargetId = $(this).attr('id');
            var itemId = $(this).children(".orderedItemCell").attr('id');

            setItems[dropTargetId] = itemId;
        });
    }

    /**
     * Rendre les elements html draggable et droppable.
     */
    function initWidgets() {
        $(".orderedItemCell").each(function () {
            var containmentObjectId = calculateContainmentObjectId($(this));
            $(this).draggable({axis:"y", containment:containmentObjectId});
        });

        $(".dropTarget").droppable();

        $('.orderedItemCell').addClass('draggableItem');
    }

    /**
     * Calcul de l'identifiant du containeur pour restreindre le mouvement des draggables.
     * @param draggable
     */
    function calculateContainmentObjectId(draggable) {
        var result = draggable.attr("id").substr(11);
        result = result.substr(0, result.indexOf("_"));
        result = "#orderQuestionContainment_" + result;
        return result;
    }

    function registerEventHandlers() {
        $(".dropTarget").bind("dropover", function (event, ui) {
            onDropOver($(this));
        });

        $(".dropTarget").bind("dropout", function (event, ui) {
            onDropOut($(this));
        });

        $('.orderedItemCell').bind("dragstop", function () {
            onDragStop($(this));
        })
    }

    function onDropOut(droppable) {

        if (movingItemId == "") {
            var currentDroppableId = droppable.attr('id');
            movingItemId = setItems[currentDroppableId];
            setItems[currentDroppableId] = "";
        }
    }

    function onDropOver(droppable) {
        if (movingItemId != "") {
            var currentDroppableId = droppable.attr('id');
            var currentItemId = setItems[currentDroppableId];
            var emptyDroppableId = getEmptyDroppableId();
            move(currentItemId, emptyDroppableId);
            setOrdinal(currentItemId, emptyDroppableId);
            setItems[emptyDroppableId] = currentItemId;
            setItems[currentDroppableId] = "";
        }
    }

    function onDragStop(draggable) {
        var emptyDroppableId = getEmptyDroppableId();
        move(movingItemId, emptyDroppableId);
        setOrdinal(movingItemId, emptyDroppableId);
        setItems[emptyDroppableId] = movingItemId;
        movingItemId = "";
    }

    /**
     * Retrouve l'id du droppable qui n'a pas un item associé.
     */
    function getEmptyDroppableId() {

        for (var droppableId in setItems) {

            if (setItems[droppableId] == "")
                return droppableId;
        }

        return null;
    }

    function move(draggableId, droppableId) {
        if (draggableId && droppableId) {
            $("#" + draggableId).position({my:"center center", at:"center center", of:$("#" + droppableId), collision:"none"});
        }
    }

    /**
     * Sets the value of the draggables select form input element based on the droppable'position
     * which is encoded in its id.
     * @param draggableId the draggable's id
     * @param droppableId the droppable's id
     */
    function setOrdinal(draggableId, droppableId) {
        var ordinal = 1 + parseInt(droppableId.substr(droppableId.indexOf('_') + 1, droppableId.length));
        $('#' + draggableId + ' select').val(ordinal);
    }
}

