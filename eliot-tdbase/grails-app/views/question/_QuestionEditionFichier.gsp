<%@ page import="org.lilie.services.eliot.tice.Attachement" %>
%{--
  - Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
  - This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
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
  -  <http://www.gnu.org/licenses/> and
  -  <http://www.cecill.info/licences.fr.html>.
  --}%

<g:set var="attachement" value="${question.principalAttachement}"/>
<g:if test="${attachement}">
  %{--on force une verif sur base car l'attacchement suite à une erreur de
        validation, peut être dans le cache hibernate sant être en base--}%
   <g:set var="attachement" value="${Attachement.findById(attachement.id)}"/>
</g:if>
<g:if test="${!question.doitSupprimerPrincipalAttachement && attachement}">
  ${attachement.nomFichierOriginal}&nbsp;
  <g:submitToRemote action="supprimePrincipalAttachement"
                    controller="question${question.type.code}"
                    update="question_fichier"
                    value="Suppr" class="button"/>
  <br/>
</g:if>
<g:else>
  <g:if test="${attachementsSujet}">
    <g:select name="principalAttachementId"
              noSelection="${['null': g.message(code:"default.select.null")]}"
                        from="${attachementsSujet}"
                        optionKey="id"
                        optionValue="nom"/>  OU
  </g:if>
  <input type="file" name="principalAttachementFichier">
</g:else>
<br/>
<g:checkBox name="principalAttachementEstInsereDansLaQuestion"
                title="Le document attaché est inséré dans le sujet"
                checked="${question.principalAttachementEstInsereDansLaQuestion}"/>
    Le document est inséré dans le sujet

