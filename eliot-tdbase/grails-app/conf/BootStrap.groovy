import grails.util.Environment
import org.lilie.services.eliot.tice.annuaire.UtilisateurService

class BootStrap {

  UtilisateurService defaultUtilisateurService

  def init = { servletContext ->

    switch (Environment.current) {
      case Environment.DEVELOPMENT:
        bootstrapForDevelopment()
        break
    }

  }


  def destroy = {
  }

  private static final String UTILISATEUR_1_LOGIN = "_test_mary"
  private static final String UTILISATEUR_1_PASSWORD = "_test_"
  private static final String UTILISATEUR_1_NOM = "dupond"
  private static final String UTILISATEUR_1_PRENOM = "mary"

  private def bootstrapForDevelopment() {
    if (!defaultUtilisateurService.findUtilisateur(UTILISATEUR_1_LOGIN)) {
      defaultUtilisateurService.createUtilisateur(
              UTILISATEUR_1_LOGIN,
              UTILISATEUR_1_PASSWORD,
              UTILISATEUR_1_NOM,
              UTILISATEUR_1_PRENOM
      )
    }
  }

}
