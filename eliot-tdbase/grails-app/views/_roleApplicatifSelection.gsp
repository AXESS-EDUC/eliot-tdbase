<%@ page import="org.lilie.services.eliot.tice.scolarite.FonctionEnum; org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils; org.lilie.services.eliot.tdbase.securite.RoleApplicatif" %>

<g:if test="${SpringSecurityUtils.ifAllGranted(role.authority)}">
    <et:manuelLink role="${role}"
                   class="portal-manuel"><g:message
            code="manuels.libellelien"/></et:manuelLink>
</g:if>
<sec:ifLoggedIn>
    <g:form method="get" controller="accueil" action="changeRoleApplicatif" style="float:right" title="${securiteSessionServiceProxy.etablissementListDisplay}">Accès <g:select name="roleApplicatif"
                                                                                                               from="${securiteSessionServiceProxy.rolesApplicatifsAndPerimetreByRoleApplicatif.keySet()}"
                                                                                                               optionKey="code" value="${securiteSessionServiceProxy.currentRoleApplicatif.code}"
                                                                                                               valueMessagePrefix="preferences.role" onchange="submit();"
    />
    </g:form>
</sec:ifLoggedIn>