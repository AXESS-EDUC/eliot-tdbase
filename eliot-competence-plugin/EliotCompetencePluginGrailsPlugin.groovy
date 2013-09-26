import org.lilie.services.eliot.competence.CompetenceImporter
import org.lilie.services.eliot.competence.DomaineImporter

class EliotCompetencePluginGrailsPlugin {
    // the plugin version
    def version = "1.0-SNAPSHOT"
    // the version or versions of Grails the plugin is designed for
    def grailsVersion = "1.3.7 > *"
    // the other plugins this plugin depends on
    def dependsOn = [:]
    // resources that are excluded from plugin packaging
    def pluginExcludes = [
            "grails-app/views/error.gsp"
    ]

    // TODO Fill in these fields
    def author = "John Tranier"
    def authorEmail = "john.tranier@ticetime.com"
    def title = "eliot-competence-plugin"
    def description = '''\\
Plugin de gestion des référentiels de compétences Eliot
'''

    // URL to the plugin's documentation
//    def documentation = "http://grails.org/plugin/eliot-competence-plugin"

    def doWithWebDescriptor = { xml ->
        // TODO Implement additions to web.xml (optional), this event occurs before 
    }

    def doWithSpring = {
      competenceImporter(CompetenceImporter)

      domaineImporter(DomaineImporter) {
        competenceImporter = ref('competenceImporter')
      }
    }

    def doWithDynamicMethods = { ctx ->
        // TODO Implement registering dynamic methods to classes (optional)
    }

    def doWithApplicationContext = { applicationContext ->
        // TODO Implement post initialization spring config (optional)
    }

    def onChange = { event ->
        // TODO Implement code that is executed when any artefact that this plugin is
        // watching is modified and reloaded. The event contains: event.source,
        // event.application, event.manager, event.ctx, and event.plugin.
    }

    def onConfigChange = { event ->
        // TODO Implement code that is executed when the project configuration changes.
        // The event is the same as for 'onChange'.
    }
}