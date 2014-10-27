package org.lilie.services.eliot.tdbase.webservices.rest.client

import grails.test.mixin.TestFor
import groovyx.net.http.ContentType
import groovyx.net.http.Method
import org.lilie.services.eliot.tice.webservices.rest.client.GenericRestOperation
import org.lilie.services.eliot.tice.webservices.rest.client.RestClient
import org.lilie.services.eliot.tice.webservices.rest.client.RestOperation
import org.lilie.services.eliot.tice.webservices.rest.client.RestOperationDirectory
import org.vertx.groovy.core.Vertx
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.services.ServiceUnitTestMixin} for usage instructions
 */
@TestFor(ScolariteRestService)
class ScolariteRestServiceSpec extends Specification {

    RestOperationDirectory restOperationDirectory = new RestOperationDirectory()
    def httpserver
    def port = 8796
    ScolariteRestService scolariteRestService

    void setup() {
        def vertx = Vertx.newVertx()
        httpserver = vertx.createHttpServer()
        httpserver.requestHandler { req ->
            def rep = req.response
            rep.putHeader("Content-Type","application/json").end(getJsonToReturn())
        }.listen(port)
        RestOperation restOperation = new GenericRestOperation(contentType: ContentType.JSON,
                description: "Retourne la liste des fonctions administrables pour un établissement donné",
                operationName: "findFonctionsForEtablissement",
                method: Method.GET,
                requestBodyTemplate: null,
                responseContentStructure: "List<eliot-scolarite#fonction#standard>",
                urlServer: "http://localhost:$port",
                uriTemplate: '/eliot-test-webservices/echanges/v2/wsprofilsetab')
        restOperationDirectory.addOperation(restOperation)
        scolariteRestService = new ScolariteRestService(restClientForScolarite: new RestClient(restOperationDirectory: restOperationDirectory))
    }

    void cleanup() {
        httpserver.close()
    }


    void testRestClientInvokeOperation() {
        given: "un id d'établissement "
        def etablissementId = 1

        and:"un hack pour ajouter la methode dynamque encodeAsURL"
        String.metaClass.encodeAsURL = { "1" }

        when:"on déclenche la récupération des fonctions de l'établissement"
        List<Map<String,String>> res = scolariteRestService.findFonctionsForEtablissement(etablissementId)

        then: "on récupère une liste de map contenant les codes fonctions avec les libellés"
        res.size() == 14
        res.get(0).get('code') == 'LAB'
        res.get(0).get('libelle') == 'PERSONNELS DE LABORATOIRE'
        res.get(13).get('code') == 'ENS'
        res.get(13).get('libelle') == 'ENSEIGNEMENT'


    }

    private String getJsonToReturn() {
        '''[{"code":"LAB","libelle":"PERSONNELS DE LABORATOIRE"},
                    {"code":"ORI","libelle":"ORIENTATION"},
                    {"code":"ELEVE","libelle":"ELEVE"},
                    {"code":"DIR","libelle":"DIRECTION"},
                    {"code":"DOC","libelle":"DOCUMENTATION"},
                    {"code":"CTR","libelle":"CHEF DE TRAVAUX"},
                    {"code":"EDU","libelle":"EDUCATION"},
                    {"code":"ADF","libelle":"PERSONNELS ADMINISTRATIFS"},
                    {"code":"AVS","libelle":"AUXILIAIRE DE VIE SCOLAIRE"},
                    {"code":"UI","libelle":"INVITE"},
                    {"code":"MDS","libelle":"PERSONNELS MEDICO-SOCIAUX"},
                    {"code":"APP","libelle":"APPRENTISSAGE"},
                    {"code":"AL","libelle":"ADMINISTRATEUR_LOCAL"},
                    {"code":"ENS","libelle":"ENSEIGNEMENT"}
                    ]'''
    }
}


