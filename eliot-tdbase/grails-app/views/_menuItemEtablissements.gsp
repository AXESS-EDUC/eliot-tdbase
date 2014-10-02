<li id="menu-item-etablissements">
    <a title="Mes établissements">Établissements</a>
    <ul>
        <g:each in="${securiteSessionServiceProxy.etablissementList}" var="etablissement">
            <li title="${etablissement.nomAffichage}">
                <g:link controller="accueil" action="changeEtablissement" id="${etablissement.id}"><g:radio name="etablissement.id" value="${etablissement.id}"
                                                                                                            checked="${etablissement == securiteSessionServiceProxy.currentEtablissement}" disabled="true"/> ${etablissement.nomAffichage}</g:link>
            </li>
        </g:each>
    </ul>
</li>