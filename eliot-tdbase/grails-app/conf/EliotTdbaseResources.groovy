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

  'eliot-tdbase' {
    dependsOn 'eliot-tice'
    resource url: [dir: 'images/eliot', file: 'tdbasefavicon.ico']
    resource url: [dir: 'css/eliot', file: 'tdbase.css']
    resource url: [dir: 'js', file: 'application.js']
  }

  'eliot-tdbase-ui' {
    dependsOn 'eliot-tice-ui','eliot-tdbase'
    resource url: [dir: 'js/eliot', file: 'eliot-tdbase-ui.js']
    resource url: [dir: 'css/eliot', file: 'tdbase-ui.css']
  }

  jmol {
    resource url: [dir: 'js/lib/jmol', file: 'Jmol.js'],
             disposition: 'head'
  }

  modernizr {
    resource id: 'js', url: [dir: 'js/lib', file: 'modernizr.js'],
             disposition: 'head', nominify: true
  }

  question_editeJS{
    dependsOn "eliot-tdbase-ui"
    resource url: [dir: 'js/question/', file: 'edite.js']
  }

  associateJS {
    dependsOn "modernizr", "eliot-tice-ui", "seanceCopie_Common"
    resource url: [dir: 'js/question/associate', file: 'load.js']
    resource url: [dir: 'js/question/associate', file: 'dragNDrop.polyfill.js']
    resource url: [dir: 'js/question/associate', file: 'dragNDrop.js']
  }

  orderJS {
    dependsOn "modernizr", "eliot-tice-ui", "seanceCopie_Common"
    resource url: [dir: 'js/question/order', file: 'load.js']
    resource url: [dir: 'js/question/order', file: 'dragNDrop.polyfill.js']
    resource url: [dir: 'js/question/order', file: 'dragNDrop.js']
  }

  graphicMatch_Common {
    dependsOn "modernizr", "eliot-tice-ui"
    resource url: [dir: 'js/question/graphicmatch', file: 'common.js'], disposition: 'head'
    resource url: [dir: 'css/question/graphicmatch', file: 'style.css']
  }

  graphicMatch_EditionJS {
    dependsOn "graphicMatch_Common"
    resource url: [dir: 'js/question/graphicmatch/edition', file: 'load.js']
    resource url: [dir: 'js/question/graphicmatch/edition', file: 'dragNDrop.polyfill.js']
    resource url: [dir: 'js/question/graphicmatch/edition', file: 'dragNDrop.js']
  }

  graphicMatch_InteractionJS {
    dependsOn "graphicMatch_Common", "seanceCopie_Common"
    resource url: [dir: 'js/question/graphicmatch/interaction', file: 'load.js']
    resource url: [dir: 'js/question/graphicmatch/interaction', file: 'dragNDrop.polyfill.js']
    resource url: [dir: 'js/question/graphicmatch/interaction', file: 'dragNDrop.js']
  }

  graphicMatch_PreviewJS {
    dependsOn "graphicMatch_Common"
    resource url: [dir: 'js/question/graphicmatch/preview', file: 'load.js']
  }

  graphicMatch_DetailsJS {
    dependsOn "graphicMatch_PreviewJS"
  }

  graphicMatch_CorrectionJS {
    dependsOn "graphicMatch_Common"
    resource url: [dir: 'js/question/graphicmatch/correction', file: 'load.js']
  }

  fillGraphics_Common {
    dependsOn "modernizr", "eliot-tice-ui"
    resource url: [dir: 'css/question/fillgraphics', file: 'style.css']
    resource url: [dir: 'js/question/fillgraphics', file: 'common.js']
  }

  fillGap_Common {
    dependsOn "modernizr", "eliot-tice-ui"
    resource url: [dir: 'css/question/fillgap', file: 'style.css']
  }

  fillGraphics_EditionJS {
    dependsOn "fillGraphics_Common"
    resource url: [dir: 'js/question/fillgraphics/edition', file: 'dragNDrop.polyfill.js']
    resource url: [dir: 'js/question/fillgraphics/edition', file: 'dragNDrop.js']
    resource url: [dir: 'js/question/fillgraphics/edition', file: 'load.js']
  }

  fillGraphics_InteractionJS {
    dependsOn "fillGraphics_Common"
    resource url: [dir: 'js/question/fillgraphics/interaction', file: 'dragNDrop.polyfill.js']
    resource url: [dir: 'js/question/fillgraphics/interaction', file: 'dragNDrop.js']
    resource url: [dir: 'js/question/fillgraphics/interaction', file: 'load.js']
  }

  fillGap_InteractionJS {
    dependsOn "fillGap_Common"
    resource url: [dir: 'js/question/fillgap/interaction', file: 'dragNDrop.polyfill.js']
    resource url: [dir: 'js/question/fillgap/interaction', file: 'dragNDrop.js']
    resource url: [dir: 'js/question/fillgap/interaction', file: 'load.js']
  }

  fillGraphics_PreviewJS {
    dependsOn "fillGraphics_Common"
    resource url: [dir: 'js/question/fillgraphics/preview', file: 'load.js']
  }


  seanceCopie_Common {
    dependsOn "eliot-tdbase-ui"
    resource url: [dir: 'js/seance/copie', file: 'common.js']
  }

  seanceCopie_CorrigeJS {
    dependsOn "seanceCopie_Common"
    resource url: [dir: 'js/seance/copie', file: 'corrige.js']
  }

  seanceCopie_VisualiseJS {
    dependsOn "seanceCopie_Common"
    resource url: [dir: 'js/seance/copie', file: 'visualise.js']
  }



  copieEdite_CopieModifiable {
    dependsOn "eliot-tdbase-ui"
    resource url: [dir: 'js/copie/edite', file: 'editeCopieModifiable.js']
  }

  copieEdite_CopieNonModifiable {
    dependsOn "seanceCopie_Common"
    resource url: [dir: 'js/copie/edite', file: 'editeCopieNonModifiable.js']
  }

  copieEdite_CopieModifiableEnTest {
    dependsOn "eliot-tdbase-ui"
    resource url: [dir: 'js/copie/edite', file: 'editeCopieModifiableEnTest.js']
  }

  copieEdite_CopieNonModifiableEnTest {
    dependsOn "seanceCopie_Common"
    resource url: [dir: 'js/copie/edite', file: 'editeCopieNonModifiableEnTest.js']
  }
}