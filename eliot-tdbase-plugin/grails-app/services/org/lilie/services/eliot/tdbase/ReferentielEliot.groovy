package org.lilie.services.eliot.tdbase

import org.lilie.services.eliot.tice.nomenclature.MatiereBcn
import org.lilie.services.eliot.tice.scolarite.Niveau

/**
 * Décrit le référentiel Eliot qui peut être associé à un sujet ou à une question
 * @author John Tranier
 */
class ReferentielEliot {
  MatiereBcn matiereBcn
  Niveau niveau
}
