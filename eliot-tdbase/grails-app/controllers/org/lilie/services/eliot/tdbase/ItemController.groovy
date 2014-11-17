package org.lilie.services.eliot.tdbase

import org.lilie.services.eliot.tdbase.securite.SecuriteSessionService
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement
import org.lilie.services.eliot.tice.scolarite.Niveau
import org.lilie.services.eliot.tice.scolarite.ScolariteService

class ItemController {

    SecuriteSessionService securiteSessionServiceProxy
    ScolariteService scolariteService

/**
 *
 * Action recherche structure
 */
    def rechercheMatieres(RechercheMatieresCommand command) {
        def allEtabs = securiteSessionServiceProxy.etablissementList
        def etabs = allEtabs
        if (command.etablissementId) {
            etabs = [Etablissement.get(command.etablissementId)]
        }
        def codePattern = null
        if (command.patternCode) {
            codePattern = command.patternCode
        }
        def limit = grailsApplication.config.eliot.listes.structures.maxrecherche
        def matieres = scolariteService.findMatieres(etabs, codePattern, limit)
        render(view: "/item/_selectMatiere", model: [
                rechercheMatieresCommand: command,
                etablissements          : allEtabs,
                matieres                : matieres
        ])
    }
}

class RechercheMatieresCommand {
    String patternCode
    Long etablissementId
}