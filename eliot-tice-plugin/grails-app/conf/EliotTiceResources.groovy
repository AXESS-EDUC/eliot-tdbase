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



modules = {

  images {
    resource url: '/images/eliot/write-btn.gif',
             attrs: [
                     width: 22,
                     height: 18
             ],
             disposition: 'inline'
  }

  'eliot-tice' {
    dependsOn 'jquery'
    resource url: [dir: 'css/eliot/blueprint/compressed', file: 'screen.css']
    resource url: [dir: 'css/eliot', file: 'portal.css']
    resource url: [dir: 'css/eliot', file: 'portal-menu.css']
    resource url: [dir: 'js/eliot', file: 'portal-menu.js']

  }

  'eliot-tice-ui' {
    dependsOn 'eliot-tice', 'jquery-ui'
    resource url: [dir: 'css/eliot/jquery', file: 'jquery-ui.css']
    resource url: [dir: 'js/eliot', file: 'jquery.editinplace.js']
    resource url: [dir: 'js/eliot', file: 'jquery-ui-timepicker-addon.js']
    resource url: [plugin: 'jquery-ui', dir: 'js/jquery/i18n', file: 'jquery.ui.datepicker-fr.js']
    resource url: [dir: 'js/eliot/i18n', file: 'jquery.ui.timepicker-fr.js']
  }

//  'eliot-tice-tiny_mce' {
//    dependsOn 'jquery'
//    resource url: [dir: 'js/eliot/tiny_mce', file: 'tiny_mce.js'], disposition: 'head', exclude:'*'
//    resource url: [dir: 'js/eliot/tiny_mce/langs', file: 'fr.js'], disposition: 'head', exclude:'*'
//    resource url: [dir: 'js/eliot/tiny_mce/langs', file: 'en.js'], disposition: 'head', exclude:'*'
//
//    resource url: [dir: 'js/eliot/tiny_mce/themes/advanced', file: 'editor_template.js'], disposition: 'head', exclude: '*'
//    resource url:[dir: 'js/eliot/tiny_mce/themes/advanced/skins/default', file: 'ui.css'], disposition: 'head', exclude: '*'
//    resource url:[dir: 'js/eliot/tiny_mce/themes/advanced/skins/default', file: 'content.css'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/themes/advanced/img', file: 'icons.gif'], exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/themes/advanced/skins/default/img', file: 'menu_arrow.gif'], exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/themes/advanced/skins/default/img', file: 'menu_check.gif'], exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/themes/advanced/langs', file: 'fr.js'], disposition: 'head', exclude:'*'
//    resource url: [dir: 'js/eliot/tiny_mce/themes/advanced/langs', file: 'en.js'], disposition: 'head', exclude:'*'
//    resource url: [dir: 'js/eliot/tiny_mce/themes/advanced/langs', file: 'fr_dlg.js'], disposition: 'head', exclude:'*'
//    resource url: [dir: 'js/eliot/tiny_mce/themes/advanced/langs', file: 'en_dlg.js'], disposition: 'head', exclude:'*'
//
//
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/pagebreak', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/style', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/layer', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/table', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/save', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/advhr', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/advimage', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/advlink', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    //resource url: [dir: 'js/eliot/tiny_mce/plugins/advlink', file: 'link.htm'], exclude: '*'
//
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/emotions', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/iespell', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/inlinepopups', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/inlinepopups/skins/clearlooks2', file: 'window.css'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/inlinepopups/skins/clearlooks2/img', file: 'corners.gif'], exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/inlinepopups/skins/clearlooks2/img', file: 'horizontal.gif'], exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/inlinepopups/skins/clearlooks2/img', file: 'vertical.gif'], exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/inlinepopups/skins/clearlooks2/img', file: 'buttons.gif'], exclude: '*'
//
//
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/insertdatetime', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/preview', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/media', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/searchreplace', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/print', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/contextmenu', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/paste', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/directionality', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/fullscreen', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/noneditable', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/visualchars', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/nonbreaking', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/xhtmlxtras', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//    resource url: [dir: 'js/eliot/tiny_mce/plugins/template', file: 'editor_plugin.js'], disposition: 'head', exclude: '*'
//
//
//  }


}