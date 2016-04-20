import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.lilie.services.eliot.tice.Attachement
import org.lilie.services.eliot.tice.annuaire.Personne

class LogoutController {

  static scope = "singleton"

  /**
   * Index action. Redirects to the Spring security logout uri.
   */
  def index() {
    // TODO  put any pre-logout code here

    if(authenticatedPersonne) {
      libereAllVerrou(authenticatedPersonne)
    }


    redirect uri: SpringSecurityUtils.securityConfig.logout.filterProcessesUrl // '/j_spring_security_logout'
  }

  /**
   * Supprime tous les verrous détenus par cet utilisateurs sur les sujets & items
   */
  private void libereAllVerrou(Personne personne) {
    // Note : Le choix de classe du domaine Attachement est arbitraire ... Il s'agit juste d'exécuter une requête HQL
    Attachement.executeUpdate("""
        UPDATE Sujet s
        SET auteurVerrou=NULL,
          dateVerrou=NULL
        WHERE s.auteurVerrou=:auteur
      """,
        [auteur: personne]
    )

    Attachement.executeUpdate("""
        UPDATE Question q
        SET auteurVerrou=NULL,
          dateVerrou=NULL
        WHERE q.auteurVerrou=:auteur
      """,
        [auteur: personne]
    )
  }
}
