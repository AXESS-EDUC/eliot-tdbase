package org.lilie.services.eliot.tdbase

import org.lilie.services.eliot.tice.CopyrightsType
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Matiere
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.utils.StringUtils
import org.springframework.transaction.annotation.Transactional

class SujetService {

  static transactional = false

  /**
   * Créé un sujet
   * @param proprietaire le proprietaire du sujet
   * @param titre le titre du sujet
   * @return le sujet créé
   */
  @Transactional
  Sujet createSujet(Personne proprietaire, String titre) {
    Sujet sujet = new Sujet(
            proprietaire: proprietaire,
            titre: titre,
            titreNormalise: StringUtils.normalise(titre),
            accesPublic: false,
            accesSequentiel: false,
            ordreQuestionsAleatoire: false,
            publie: false,
            versionSujet: 1,
            copyrightsType: CopyrightsType.getDefault()
    )
    sujet.save()
    return sujet
  }

  /**
   * Recherche de sujets
   * @param chercheur la personne effectuant la recherche
   * @param patternTitre le pattern saisi pour le titre
   * @param patternAuteur le pattern saisi pour l'auteur
   * @param patternPresentation  le pattern saisi pour la presentation
   * @param matiere la matiere
   * @param niveau le niveau
   * @param paginationAndSortingSpec les specifications pour l'ordre et
   * la pagination
   * @return la liste des sujets
   */
  List<Sujet> findSujets(Personne chercheur,
                         String patternTitre,
                         String patternAuteur,
                         String patternPresentation,
                         Matiere matiere,
                         Niveau niveau,
                         Map paginationAndSortingSpec = null) {
    if (!chercheur) {
      throw new IllegalArgumentException("sujet.recherche.chercheur.null")
    }
    def criteria = Sujet.createCriteria()
    List<Sujet> sujets = criteria.list {
      if (patternAuteur) {
        String patternAuteurNormalise = "%${StringUtils.normalise(patternAuteur)}%"
        proprietaire {
          or {
            like "nomNormalise", patternAuteurNormalise
            like "prenomNormalise", patternAuteurNormalise
          }
        }
      }
      if (patternTitre) {
        like "titreNormalise", "%${StringUtils.normalise(patternTitre)}%"
      }
      if (patternPresentation) {
        like "presentationNormalise", "%${StringUtils.normalise(patternPresentation)}%"
      }
      if (matiere) {
        eq "matiere", matiere
      }
      if (niveau) {
        eq "niveau", niveau

      }
      or {
        eq 'proprietaire', chercheur
        eq 'publie', true
      }
      if (paginationAndSortingSpec) {
        def sortArg = paginationAndSortingSpec['sort'] ?: 'titre'
        def orderArg = paginationAndSortingSpec['order'] ?: 'asc'
        if (sortArg) {
          order "${sortArg}", orderArg
        }

        Integer maxArg = paginationAndSortingSpec['max'] as Integer
        if (maxArg) {
          maxResults maxArg
        }
        Integer offsetArg = paginationAndSortingSpec['offset'] as Integer
        if (offsetArg) {
          firstResult offsetArg
        }
      }
    }
    return sujets
  }

  /**
   * Recherche de tous les sujet pour un proprietaire donné
   * @param chercheur la personne effectuant la recherche
   * @param paginationAndSortingSpec les specifications pour l'ordre et
   * la pagination
   * @return la liste des sujets
   */
  List<Sujet> findSujetsForProprietaire(Personne proprietaire,
                                        Map paginationAndSortingSpec = null) {
     return findSujets(proprietaire,null, null, null, null, null,
                       paginationAndSortingSpec)
  }

  /**
   * Retourne le nombre de sujet du proprietaire passé en paramètre
   * @param proprietaire le proprietaire
   * @return  le nombre de sujets
   */
  Long nombreSujetsForProprietaire(Personne proprietaire) {
     return Sujet.countByProprietaire(proprietaire)
  }

}
