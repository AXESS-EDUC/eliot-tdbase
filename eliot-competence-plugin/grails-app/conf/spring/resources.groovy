import org.lilie.services.eliot.competence.CompetenceImporter
import org.lilie.services.eliot.competence.DomaineImporter

beans = {
  competenceImporter(CompetenceImporter)

  domaineImporter(DomaineImporter) {
    competenceImporter = ref('competenceImporter')
  }
}