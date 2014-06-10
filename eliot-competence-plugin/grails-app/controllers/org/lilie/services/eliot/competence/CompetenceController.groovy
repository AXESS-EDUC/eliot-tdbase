package org.lilie.services.eliot.competence

/**
 * Contrôleur donnant accès à des représentations des arbres de compétences qui peuvent
 * être exploitées par des applications utilisant ce plugin
 *
 * @author John Tranier
 */
class CompetenceController {

  static scope = "singleton"

  ReferentielService referentielService

  /**
   * Affiche un arbre de compétence
   * L'arbre est constitué de domaines et de compétences.
   * Les compétences sont nécessairement des feuilles de l'arbres.
   *
   * @param command
   *  - command.referentielId : l'identifiant du référentiel de compétence
   *  - command.lectureSeule : si false, des cases à cocher seront ajoutées devant chaque compétence
   *    permettant leur sélection ; la valeur par défaut des cases à cocher dépend de la valeur
   *    de command.competenceSectionIdList ;
   *    si true, les compétences sont présentées sans case à cocher
   *  - command.selectionUniquement : si false, toutes les compétences du référentiel sont
   *    incluses dans l'arbre des compétenfces ; si true, seules les compétences sélectionnées
   *    sont présentées
   *  - command.competenceSelectionIdList : list des identifiants des compétences sélectionnées
   * @return le fragment HTML représentant l'arbre de compétence
   */
  def afficheArbreCompetence(AfficheArbreCompetenceCommand command) {

    render(
        template: '/competence/affiche_arbre_competence',
        model: [
            referentiel: referentielService.fetchReferentielById(command.referentielId),
            lectureSeule: command.lectureSeule,
            selectionUniquement: command.selectionUniquement,
            competenceSelectionList: command.competenceSelectionList
        ]
    )
  }
}

class AfficheArbreCompetenceCommand {
  Long referentielId
  boolean lectureSeule = true
  boolean selectionUniquement = false
  List<Long> competenceSelectionIdList = []

  List<Competence> getCompetenceSelectionList() {
    return competenceSelectionIdList.collect { Competence.load(it) }
  }
}
