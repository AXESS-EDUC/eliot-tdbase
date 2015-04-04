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

function initComboboxAutoComplete(config) {

    $.widget( "custom.combobox", {
        _create: function() {
            this.wrapper = $( "<span>" )
                .addClass( "custom-combobox" )
                .insertAfter( this.element );

            this.element.hide();
            this._createAutocomplete();
        },

        _createAutocomplete: function() {
            var that = this;
            var selected = this.element.children( ":selected" ),
                value = selected.val() ? selected.text() : "";

            var input = $( "<input>" )
                .appendTo( this.wrapper )
                .val( value )
                .attr( "title", "" )
                .addClass( "custom-combobox-input ui-widget ui-widget-content ui-state-default ui-corner-left" )
                .autocomplete({
                    delay: 0,
                    minLength: 0,
                    source: $.proxy( this, "_source" ),

                    select: function( event, ui ) {
                        ui.item.option.attr("selected", "selected");
                    }

                });
            this.input = input;

        },

        _source: function( request, response ) {
            var combobox = this.element;

            config.recherche(request.term, function(options) {
                $(combobox).children('option').remove();

                for(var i = 0; i < options.length; i++) {
                    var option = options[i];

                    option.option = $('<option/>')
                        .attr('value', option.id)
                        .text(option.value)
                        .appendTo($(combobox));
                }

                response(options);
            });
        },

       _destroy: function() {
            this.wrapper.remove();
            this.element.show();
        }
    });

    $(config.combobox).combobox();
}