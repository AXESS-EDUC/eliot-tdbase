/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */

/**
 * Created by IntelliJ IDEA.
 * User: fsil
 * Date: 27/02/12
 * Time: 14:27
 * To change this template use File | Settings | File Templates.
 */

var quest = {
    "questionTypeCode":"GraphicMatch",
    "libelle":"Airports tags",
    "correction":"",
    "graphicMatches":{"2":"2", "1":"1", "3":"3"},
    "attachmentId":102,
    "hotspots":[
    {"topDistance":89, "leftDistance":5, "id":"1"},
    {"topDistance":90, "leftDistance":126, "id":"2"},
    {"topDistance":152, "leftDistance":62, "id":"3"}
], "icons":[
    {"id":"1", "attachmentId":103},
    {"id":"2", "attachmentId":104},
    {"id":"3", "attachmentId":105}
]}


var quest2 = {
    "items":[
        {"title":"Airport Tags"},
        { "questionTypeCode":"Statement", "enonce":"<p>The International Air Transport Association assigns three-letter codes to identify airports worldwide. For example, London Heathrow has code LHR.</p>" } ,
        { "questionTypeCode":"GraphicMatch",
            "libelle":"Some of the labels on the following diagram are missing: can you identify the correct three-letter codes for the unlabelled airports?", "attachmentSrc":"images/ukairtags.png",
            "hotspots":[
            {"id":"A", "topDistance":108, "leftDistance":12 } ,
            {"id":"B", "topDistance":103, "leftDistance":128 } ,
            {"id":"C", "topDistance":165, "leftDistance":66 }],
            "icons":[
            {"id":"GLA", "attachmentSrc":"images/GLA.png"} ,
            {"id":"EDI", "attachmentSrc":"images/EDI.png"} ,
            {"id":"MAN", "attachmentSrc":"images/MAN.png"}],
            "graphicMatches":{ "GLA":"A", "EDI":"B", "MAN":"C" }
        }
    ]
}