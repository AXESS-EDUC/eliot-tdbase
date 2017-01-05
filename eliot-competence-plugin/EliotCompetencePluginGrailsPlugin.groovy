import org.lilie.services.eliot.competence.CompetenceImporter
import org.lilie.services.eliot.competence.DomaineImporter

class EliotCompetencePluginGrailsPlugin {
    // the plugin version
    def version = "1.0"
    // the version or versions of Grails the plugin is designed for
    def grailsVersion = "1.3.7 > *"
    // the other plugins this plugin depends on
    def dependsOn = [:]
    // resources that are excluded from plugin packaging
    def pluginExcludes = [
            "grails-app/views/error.gsp"
    ]

    def author = "John Tranier"
    def authorEmail = "john.tranier@ticetime.com"
    def title = "eliot-competence-plugin"
    def description = '''\\
Plugin de gestion des référentiels de compétences Eliot
'''

    // URL to the plugin's documentation
//    def documentation = "http://grails.org/plugin/eliot-competence-plugin"

    def doWithWebDescriptor = { xml ->
    }

    def doWithSpring = {
      competenceImporter(CompetenceImporter)

      domaineImporter(DomaineImporter) {
        competenceImporter = ref('competenceImporter')
      }
    }

    def doWithDynamicMethods = { ctx ->
    }

    def doWithApplicationContext = { applicationContext ->
    }

    def onChange = { event ->
    }

    def onConfigChange = { event ->
    }
}
