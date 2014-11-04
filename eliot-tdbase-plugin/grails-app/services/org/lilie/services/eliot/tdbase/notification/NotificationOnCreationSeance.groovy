package org.lilie.services.eliot.tdbase.notification

import org.lilie.services.eliot.tdbase.ModaliteActivite
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement

import javax.sql.DataSource

/**
 * Created by franck on 04/11/2014.
 */
class NotificationOnCreationSeance extends AbstractNotification {

    ModaliteActivite modaliteActivite
    def groovySql

    @Override
    Set findAllPersonnesToNotifier() {
        findAllPersonnesToNotifierForStructurEnseignement(modaliteActivite.structureEnseignement)
    }

    Set findAllPersonnesToNotifierForStructurEnseignement(StructureEnseignement structureEnseignement) {
        def results = groovySql.rows(queryForStructureEnseignement(structureEnseignement))
        results
    }


    private def queryForStructureEnseignement(StructureEnseignement structureEnseignement) {
        """select profil.personne_id as personne_id from ent.personne_propriete_scolarite as profil
    left outer join td.preference_personne as preference on (profil.personne_id = preference.personne_id and preference.notification_on_creation_seance = true)
    join ent.propriete_scolarite as propScol on (profil.propriete_scolarite_id = propScol.id)
  where
    propScol.structure_enseignement_id = ${structureEnseignement.id} and
    propScol.fonction_id = ${FonctionEnum.ELEVE.id} and
    profil.est_active = true"""
    }
}
