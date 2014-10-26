package org.lilie.services.eliot.tdbase.webservices.rest.client

import org.lilie.services.eliot.tice.webservices.rest.client.RestClient

/**
 *
 */
class ScolariteRestService {

    static transactional = false
    RestClient restClientForScolarite

    /**
     * Récupère les fonctions admnistrables d'un établissement
     * @param etablissementId
     */
    def findFonctionsForEtablissement(Long etablissementId) {
        restClientForScolarite.invokeOperation('findFonctionsForEtablissement',
                null,
                [etablissementId: etablissementId])
    }
}
