/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 * Lilie is free software. You can redistribute it and/or modify since
 * you respect the terms of either (at least one of the both license) :
 * - under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * - the CeCILL-C as published by CeCILL-C; either version 1 of the
 * License, or any later version
 *
 * There are special exceptions to the terms and conditions of the
 * licenses as they are applied to this software. View the full text of
 * the exception in file LICENSE.txt in the directory of this software
 * distribution.
 *
 * Lilie is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Licenses for more details.
 *
 * You should have received a copy of the GNU General Public License
 * and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */
package org.lilie.services.eliot.tdbase.emaeval.score

import org.lilie.services.eliot.competence.Competence
import org.lilie.services.eliot.competence.SourceReferentiel

/**
 * Représente l'évaluation des compétences sur une copie
 *
 * L'évaluation consiste à associer à chaque compétence la liste des notes
 * obtenues aux questions qui porte sur la competence
 *
 * @author John Tranier
 */
class EvaluationCopie {
  Map<Competence, List<Note>> evaluationCompetence = [:]

  void addNote(Competence competence, Note note) {
    List<Note> noteList = evaluationCompetence[competence]

    if (!noteList) {
      noteList = []
    }

    noteList << note
    evaluationCompetence.put(competence, noteList)
  }

  /**
   * @return les scores d'un élève (i.e. de sa copie) sur les compétences
   * évaluées dans une séance TD Base au format attendu par EmaEval
   * à savoir une Map associant les identifiants de compétences EmaEval au score sur la compétence
   * (valeur entre 0 et 1)
   *
   * Comme un sujet TD Base peut comprendre plusieurs questions associées à la même compétence, la moyenne des notes
   * obtenues est calculée pour chaque compétence
   */
  Map<Long, Float> getEmaEvalScore() {
    Map<Long, Float> scoreParCompetence = [:]

    evaluationCompetence.each { Competence competence, List<Note> noteList ->
      Float moyenne = calculeMoyenne(noteList)
      scoreParCompetence.put(
          Long.parseLong(
              competence.getIdExterne(SourceReferentiel.EMA_EVAL)
          ),
          moyenne
      )
    }

    return scoreParCompetence
  }

  private static Float calculeMoyenne(List<Note> noteList) {
    if (!noteList) {
      throw new IllegalArgumentException(
          "La liste de note est vide !"
      )
    }

    Float denominateur = 0
    Float numerateur = 0
    noteList.each { Note note ->
      denominateur += note.note
      numerateur += note.noteMax
    }

    return denominateur / numerateur
  }

  @Override
  public String toString() {
    return "EvaluationCopie{" +
        "evaluationCompetence=" + evaluationCompetence +
        '}';
  }
}
