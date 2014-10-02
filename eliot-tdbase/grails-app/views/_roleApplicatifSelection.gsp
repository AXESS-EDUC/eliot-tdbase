<%@ page import="org.lilie.services.eliot.tice.scolarite.FonctionEnum; org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils; org.lilie.services.eliot.tdbase.RoleApplicatif" %>
<g:if test="${SpringSecurityUtils.ifAllGranted(authority)}">
    <et:manuelLink fonctionEnum="${FonctionEnum.ENS}"
                   class="portal-manuel"><g:message
            code="manuels.libellelien"/></et:manuelLink>
</g:if>
<sec:ifLoggedIn>
    <g:form method="get" controller="accueil" action="changeRoleApplicatif" style="float:right">Rôle <g:select name="roleApplicatif"
                                                                                                               from="${securiteSessionServiceProxy.roleApplicatifList}"
                                                                                                               optionKey="code" value="${securiteSessionServiceProxy.currentRoleApplicatif.code}"
                                                                                                               valueMessagePrefix="preferences.role" onchange="submit();"
    /></g:form>
</sec:ifLoggedIn>