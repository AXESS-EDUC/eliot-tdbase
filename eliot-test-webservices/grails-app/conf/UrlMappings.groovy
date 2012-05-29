class UrlMappings {

  static mappings = {
    "/$controller/$action?/$id?" {
      constraints {
        // apply constraints here
      }
    }

    "/api-rest/v2/cahiers/$cahierId/chapitres"(controller: 'textes',action: 'getStructure')
    "/api-rest/v2/cahiers-service"(controller: 'textes',action: 'getCahiersService')
    "/api-rest/v2/cahiers/$cahierId/activite"(controller: 'textes',action: 'insertActivite')
    "/api-rest/v2/services-evaluables" (controller: 'notes',action: 'getServicesEvaluables')
    "/api-rest/v2/cahiers/evaluation" (controller: 'notes',action: 'createDevoir')
    "/api-rest/v2/cahiers/evaluation/notes" (controller: 'notes',action: 'updateNotes')
    "/"(view: "/index")
    "500"(view: '/error')
  }
}
