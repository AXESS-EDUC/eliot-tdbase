class UrlMappings {

	static mappings = {
		"/$controller/$action?/$id?"{
			constraints {
				// apply constraints here
			}
		}

		"/"(controller: 'competence', action: 'afficheArbreCompetence')
		"500"(view:'/error')
	}
}
