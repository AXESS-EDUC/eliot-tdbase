class UrlMappings {

  static mappings = {
    "/$controller/$action?/$id?" {
      constraints {
        // apply constraints here
      }
    }

    // "/"(view:"/index")
    "/" {
      controller = "sujet"
      action = "recherche"
    }
    "500"(view: '/error')
  }
}
