class UrlMappings {

  static mappings = {
    "/$controller/$action?/$id?" {
      constraints {
        // apply constraints here
      }
    }

    "/api-rest/v2/cahiers/$cahierId/chapitres"(controller: 'textes',action: 'getStructure')

    "/"(view: "/index")
    "500"(view: '/error')
  }
}
