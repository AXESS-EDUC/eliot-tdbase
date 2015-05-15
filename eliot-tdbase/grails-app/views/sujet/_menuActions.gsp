<%@ page import="org.lilie.services.eliot.tdbase.importexport.Format; org.lilie.services.eliot.tice.CopyrightsType; org.lilie.services.eliot.tice.utils.NumberUtils" %>
%{--
  - Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
  -  This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
  -
  -  Lilie is free software. You can redistribute it and/or modify since
  -  you respect the terms of either (at least one of the both license) :
  -  - under the terms of the GNU Affero General Public License as
  -  published by the Free Software Foundation, either version 3 of the
  -  License, or (at your option) any later version.
  -  - the CeCILL-C as published by CeCILL-C; either version 1 of the
  -  License, or any later version
  -
  -  There are special exceptions to the terms and conditions of the
  -  licenses as they are applied to this software. View the full text of
  -  the exception in file LICENSE.txt in the directory of this software
  -  distribution.
  -
  -  Lilie is distributed in the hope that it will be useful,
  -  but WITHOUT ANY WARRANTY; without even the implied warranty of
  -  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  -  Licenses for more details.
  -
  -  You should have received a copy of the GNU General Public License
  -  and the CeCILL-C along with Lilie. If not, see :
  -   <http://www.gnu.org/licenses/> and
  -   <http://www.cecill.info/licences.fr.html>.
  --}%


<li>
  <g:if test="${copie}">
    <g:link action="reinitialiseCopieTest" id="${copie.id}">
      Réinitialiser la copie
    </g:link>
  </g:if>
  <g:else>
    <g:link action="teste" id="${sujet.id}">
      Tester
    </g:link>
  </g:else>
</li>
<g:if test="${artefactHelper.utilisateurPeutCreerSeance(utilisateur, sujet)}">
  <li>
    <g:link action="ajouteSeance" id="${sujet.id}">
      Nouvelle&nbsp;séance
    </g:link>
  </li>
</g:if>
<g:else>
  <li>Nouvelle&nbsp;séance</li>
</g:else>
<li><hr/></li>
<g:if test="${artefactHelper.utilisateurPeutModifierArtefact(utilisateur, sujet)}">
  <li><g:link action="edite"
              id="${sujet.id}">Modifier</g:link></li>
</g:if>
<g:else>
  <g:if test="${sujet.estVerrouille()}">
    <li>En cours de modification</li>
  </g:if>
  <g:else>
    <li>Modifier</li>
  </g:else>

</g:else>
<g:if test="${artefactHelper.utilisateurPeutDupliquerArtefact(utilisateur, sujet)}">
  <li><g:link action="duplique"
              id="${sujet.id}">Dupliquer</g:link></li>
</g:if>
<g:else>
  <li>Dupliquer</li>
</g:else>
<li><hr/></li>
<g:if test="${artefactHelper.partageArtefactCCActive}">
  <g:if test="${artefactHelper.utilisateurPeutPartageArtefact(utilisateur, sujet)}">
    <%
      def docLoc = g.createLink(action: 'partage', id: sujet.id)
      def message = g.message(code: "sujet.partage.dialogue", args: [CopyrightsType.getDefaultForPartage().logo, CopyrightsType.getDefaultForPartage().code, CopyrightsType.getDefaultForPartage().lien])
    %>
    <li><g:link action="partage"
                id="${sujet.id}"
                onclick="afficheDialogue('${message}', '${docLoc}');return false;">Partager</g:link></li>
  </g:if>
  <g:else>
    <li>Partager</li>
  </g:else>
</g:if>
<g:set var="peutExporterNatifJson"
       value="${artefactHelper.utilisateurPeutExporterArtefact(utilisateur, sujet, Format.NATIF_JSON)}"/>
<g:set var="peutExporterMoodleXml"
       value="${artefactHelper.utilisateurPeutExporterArtefact(utilisateur, sujet, Format.MOODLE_XML)}"/>

<g:if test="${peutExporterNatifJson || peutExporterMoodleXml}">
  <li>
    <g:set var="urlFormatNatifJson"
           value="${createLink(action: 'exporter', id: sujet.id, params: [format: Format.NATIF_JSON.name()])}"/>
    <g:set var="urlFormatMoodleXml"
           value="${createLink(action: 'exporter', id: sujet.id, params: [format: Format.MOODLE_XML.name()])}"/>
    <a href="#"
       onclick="actionExporter('${urlFormatNatifJson}', '${peutExporterMoodleXml ? urlFormatMoodleXml : null}')">Exporter</a>
  </li>
</g:if>
<g:else>
  <li>Exporter</li>
</g:else>


<li><hr/></li>
<g:if test="${artefactHelper.utilisateurPeutSupprimerArtefact(utilisateur, sujet)}">
  <li><g:link action="supprime"
              id="${sujet.id}">Supprimer</g:link></li>
</g:if>
<g:else>
  <li>Supprimer</li>
</g:else>
