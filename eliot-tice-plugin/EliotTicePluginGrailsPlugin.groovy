import org.codehaus.groovy.grails.commons.ConfigurationHolder
import org.codehaus.groovy.grails.plugins.springsecurity.SecurityFilterPosition
import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.lilie.services.eliot.tice.AttachementDataStore
import org.lilie.services.eliot.tice.DBAttachementDataStore
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.annuaire.impl.DefaultRoleUtilisateurService
import org.lilie.services.eliot.tice.annuaire.impl.DefaultUtilisateurService
import org.lilie.services.eliot.tice.annuaire.impl.LilieRoleUtilisateurService
import org.lilie.services.eliot.tice.annuaire.impl.LilieUtilisateurService
import org.lilie.services.eliot.tice.securite.CompteUtilisateur
import org.lilie.services.eliot.tice.securite.DomainAutorite
import org.lilie.services.eliot.tice.securite.rbac.CasContainerLilieAuthenticationFilter
import org.lilie.services.eliot.tice.utils.EliotApplicationEnum
import org.lilie.services.eliot.tice.utils.EliotUrlProvider
import org.lilie.services.eliot.tice.utils.UrlServeurResolutionEnum
import org.lilie.services.eliot.tice.webservices.rest.client.RestClient
import org.lilie.services.eliot.tice.webservices.rest.client.RestOperationDirectory
import org.springframework.security.core.userdetails.UserDetailsByNameServiceWrapper
import org.springframework.security.web.authentication.preauth.PreAuthenticatedAuthenticationProvider
import org.springframework.web.context.request.RequestContextHolder

import javax.servlet.http.HttpServletRequest

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

class EliotTicePluginGrailsPlugin {
  // the group id
  def groupId = "org.lilie.services.eliot"
  // the plugin version
  def version = "2.0.4-CF-SNAPSHOT"
  // the version or versions of Grails the plugin is designed for
  def grailsVersion = "2.0.1 > *"
  // the other plugins this plugin depends on
  def dependsOn = [springSecurityCore: '1.0 > *']
  // resources that are excluded from plugin packaging
  def pluginExcludes = ["grails-app/views/error.gsp"]

  def title = "Eliot Tice Plugin"
  def author = "Franck Silvestre"
  def authorEmail = ""
  def description = '''\
      Plugin pour la création d'applications Eliot
      '''

  def doWithSpring = {

    def conf = ConfigurationHolder.config

    // configure la gestion de l'annuaire
    //
    if (conf.eliot.portail.lilie) {

      utilisateurService(LilieUtilisateurService) {
        springSecurityService = ref("springSecurityService")
      }

      roleUtilisateurService(LilieRoleUtilisateurService) {
        profilScolariteService = ref("profilScolariteService")
      }

    } else {

      utilisateurService(DefaultUtilisateurService) {
        springSecurityService = ref("springSecurityService")
      }

      roleUtilisateurService(DefaultRoleUtilisateurService) {
        profilScolariteService = ref("profilScolariteService")
      }
    }

    // configure le filtre pour la gestion du CAS Lilie
    //
    if (conf.eliot.portail.lilieCasActive) {
      println 'Configuring Spring Security Filter for CAS Lilie...'

      SpringSecurityUtils.registerProvider 'preauthAuthProvider'
      SpringSecurityUtils.registerFilter 'casContainerLilieAuthenticationFilter', SecurityFilterPosition.PRE_AUTH_FILTER

      def continueOnUnsuccessfulAuthentication = conf.eliot.portail.continueAfterUnsuccessfullCasLilieAuthentication ?: false

      casContainerLilieAuthenticationFilter(CasContainerLilieAuthenticationFilter) {
        principalSessionKey = "ENT_USERID"
        typeUserSessionKey = "ENT_USERTYPE"
        authenticationManager = ref('authenticationManager')
        continueFilterChainOnUnsuccessfulAuthentication = continueOnUnsuccessfulAuthentication
      }

      preauthAuthProvider(PreAuthenticatedAuthenticationProvider) {
        preAuthenticatedUserDetailsService = ref('userDetailsServiceWrapper')
      }

      userDetailsServiceWrapper(UserDetailsByNameServiceWrapper) {
        userDetailsService = ref('userDetailsService')
      }
      println '... finished Configuring Spring Security Filter for CAS Lilie'

    }

    // Configure la gestion du datastore
    //
    def storeFilesInDB = conf.eliot.fichiers.storedInDatabase ?: false
    if (storeFilesInDB) {
      dataStore(DBAttachementDataStore)
      println 'Configuration with file storage in database.'
    } else {
      dataStore(AttachementDataStore) { bean ->
        path = conf.eliot.fichiers.racine ?: null
        bean.initMethod = 'initFileDataStore'
      }
      println 'Configuration with file storage on file system.'
    }

    // Configure l'annuaire d'opération de webservices REST
    //

    restOperationDirectory(RestOperationDirectory)

    def user = conf.eliot.webservices.rest.client.textes.user
    def password = conf.eliot.webservices.rest.client.textes.password
    def url = conf.eliot.webservices.rest.client.textes.urlServer
    def prefixUri = conf.eliot.webservices.rest.client.textes.uriPrefix
    def conTimeout = conf.eliot.webservices.rest.client.textes.connexionTimeout ?: 15000

    restClientForTextes(RestClient) {
      authBasicUser = user
      authBasicPassword = password
      urlServer = url
      uriPrefix = prefixUri
      connexionTimeout = conTimeout
      restOperationDirectory = ref("restOperationDirectory")
      println "Auth Basic user for textes Web services client REST : ${user}"
    }

    def userNotes = conf.eliot.webservices.rest.client.notes.user
    def passwordNotes = conf.eliot.webservices.rest.client.notes.password
    def urlNotes = conf.eliot.webservices.rest.client.notes.urlServer
    def prefixUriNotes = conf.eliot.webservices.rest.client.notes.uriPrefix
    def conTimeoutNotes = conf.eliot.webservices.rest.client.notes.connexionTimeout ?: 15000

    restClientForNotes(RestClient) {
      authBasicUser = userNotes
      authBasicPassword = passwordNotes
      urlServer = urlNotes
      uriPrefix = prefixUriNotes
      connexionTimeout = conTimeoutNotes
      restOperationDirectory = ref("restOperationDirectory")
      println "Auth Basic user for Notes Web services client REST : ${userNotes}"
    }

    // configure la gestion d'EliotUrlProvider
    //

    String reqHeaderPorteur = conf.eliot.requestHeaderPorteur ?: null
    if (!reqHeaderPorteur) {
      def message = """
                    Le paramètre eliot.requestHeaderPorteur n'a pas été configuré
                    """
      throw new IllegalStateException(message)
    }

    EliotApplicationEnum applicationEnum = conf.eliot.eliotApplicationEnum ?: null
    if (!applicationEnum) {
      def message = """
              Le paramètre eliot.eliotApplicationEnum n'a pas été configuré
              """
      throw new IllegalStateException(message)
    }

    String nomAppl = conf.eliot."${applicationEnum.code}".nomApplication ?: null
    if (!nomAppl) {
      def message = """
              Le paramètre eliot.${applicationEnum.code}.nomApplication n'a pas été configuré
              """
      throw new IllegalStateException(message)
    }

    String urlResolutionMode = conf.eliot.urlResolution.mode ?: null
    if (!urlResolutionMode) {
      def message = """
              Le paramètre eliot.urlResolution.mode n'a pas été configuré
              """
      throw new IllegalStateException(message)
    }
    UrlServeurResolutionEnum urlServeurResolEnum = UrlServeurResolutionEnum.valueOf(UrlServeurResolutionEnum.class,
                                                                                    urlResolutionMode.toUpperCase())
    String urlServeurFromConfig = null
    if (urlServeurResolEnum == UrlServeurResolutionEnum.CONFIGURATION) {
      if (conf.eliot."${applicationEnum.code}".urlServeur) {
        urlServeurFromConfig = conf.eliot."${applicationEnum.code}".urlServeur
      }
      if (conf.eliot.commons?.urlServeur) {
        urlServeurFromConfig = conf.eliot.commons.urlServeur
      }
    }

    if (urlServeurResolEnum == UrlServeurResolutionEnum.CONFIGURATION && !urlServeurFromConfig) {
      def message = """
      L'url serveur de l'application ${applicationEnum.code} n'a pas " + "été configurée
      """
      throw new IllegalStateException(message)
    }

    eliotUrlProvider(EliotUrlProvider) { bean ->
      requestHeaderPorteur = reqHeaderPorteur
      nomApplication = nomAppl
      urlServeurResolutionEnum = urlServeurResolEnum
      urlServeurFromConfiguration = urlServeurFromConfig
    }

  }

  def doWithApplicationContext = { appCtx ->

    // enregistre les clients des opérations de webservice REST
    //
    def conf = ConfigurationHolder.config

    def operations = conf.eliot.webservices.rest.client.operations
    def restOperationDirectory = appCtx.restOperationDirectory

    if (operations) {
      restOperationDirectory.registerOperationsFromMaps(operations)
    }
    println "Web services REST client operations count : ${restOperationDirectory.operationCount()}"
  }

  def doWithDynamicMethods = { ctx ->
    for (controllerClass in application.controllerClasses) {
      addControllerMethods controllerClass.metaClass, ctx
    }
  }

  private void addControllerMethods(MetaClass mc, ctx) {
    if (!mc.respondsTo(null, 'getAuthenticatedUser')) {
      mc.getAuthenticatedUser = {->
        if (!ctx.springSecurityService.isLoggedIn()) return null
        Personne.get(ctx.springSecurityService.principal.personneId)
      }
    }

    if (!mc.respondsTo(null, 'getAuthenticatedPersonne')) {
      mc.getAuthenticatedPersonne = {->
        if (!ctx.springSecurityService.isLoggedIn()) return null
        Personne.get(ctx.springSecurityService.principal.personneId)
      }
    }

    if (!mc.respondsTo(null, 'getAuthenticatedCompteUtilisateur')) {
      mc.getAuthenticatedCompteUtilisateur = {->
        if (!ctx.springSecurityService.isLoggedIn()) return null
        CompteUtilisateur.get(ctx.springSecurityService.principal.compteUtilisateurId)
      }
    }

    if (!mc.respondsTo(null, 'getAuthenticatedAutorite')) {
      mc.getAuthenticatedAutorite = {->
        if (!ctx.springSecurityService.isLoggedIn()) return null
        DomainAutorite.get(ctx.springSecurityService.principal.autoriteId)
      }
    }

    // ajoute la mise à disposition du code porteur
    if (!mc.respondsTo(null, 'getCodePorteur')) {
      mc.getCodePorteur = {->
        def headerName = ConfigurationHolder.config.eliot.requestHeaderPorteur ?: "ENT_PORTEUR"
        def defaultCodePorteur = ConfigurationHolder.config.eliot.defaultCodePorteur
        HttpServletRequest request = RequestContextHolder.currentRequestAttributes().currentRequest
        def codePorteur = request.getHeader(headerName)
        if (codePorteur) {
          return codePorteur
        } else if (defaultCodePorteur) {
          return defaultCodePorteur
        } else {
          return null
        }
      }
    }
  }
}
