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

function initButtons() {
    $('button').button({
                           icons:{
                               primary:"ui-icon-gear",
                               secondary:"ui-icon-triangle-1-s"
                           },
                           text:false
                       }).click(function (event) {
                                    var currentIdMenu = "#menu_actions_" + this.id;
                                    $(currentIdMenu).css("left", this.offsetLeft);

                                    $('button').removeClass("active");
                                    $(this).addClass("active");

                                    // calcul de l'offsetTop
                                    var hauteurMenu = $(currentIdMenu).height();
                                    var hauteurBouton = $(this).height();
                                    var offsetTopDefaut = $(this).offset().top + hauteurBouton;
                                    var marginTopDefaut = $(this).marginTop;
                                    if (offsetTopDefaut + hauteurMenu - document.body.scrollTop > $(window).innerHeight()) {
                                        var offsetTopCible = hauteurMenu + hauteurBouton;
                                        $(currentIdMenu).css("marginTop", -offsetTopCible);
                                        $(currentIdMenu).addClass("top");
                                    } else {
                                        $(currentIdMenu).css("marginTop", "0");
                                        $(currentIdMenu).removeClass("top");
                                    }

                                    $('.tdbase-menu-actions').hide();
                                    $(currentIdMenu).toggle();

                                    event.stopPropagation();
                                });

    //Hide the menus if visible                        
    $('html').click(function () {
        $('.tdbase-menu-actions').hide();
        $('button').removeClass("active");
    });
    // Hide on leave block
    $('div.portal-default_results-list>div').mouseleave(function () {
        $('.tdbase-menu-actions').hide();
        $('button').removeClass("active");
        $(this).css('z-index', 0)
    });
    $('div.portal-default_results-list>div').mouseover(function () {
        $(this).css('z-index', 1)
    });

}
