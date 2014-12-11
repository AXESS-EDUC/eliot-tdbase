package org.lilie.services.eliot.tdbase.notification

import org.lilie.services.eliot.tdbase.ModaliteActivite
import org.lilie.services.eliot.tice.scolarite.FonctionEnum
import org.lilie.services.eliot.tice.scolarite.StructureEnseignement

/**
 * Created by franck on 04/11/2014.
 */
class NotificationSeanceDaoService {

    static final String PUBLICATION_RESULTATS = "publication_resultats"
    static final String CREATION_SEANCE = "creation_seance"

    ModaliteActivite modaliteActivite
    def groovySql

    Set findAllEmailDestinatairesForPublicationResultats() {
        findAllPersonnesToNotifierForStructurEnseignementAndSupportAndEvenement(modaliteActivite.structureEnseignement,NotificationSupport.EMAIL,PUBLICATION_RESULTATS)
    }

    Set findAllSmsDestinatairesForPublicationResultats() {
        findAllPersonnesToNotifierForStructurEnseignementAndSupportAndEvenement(modaliteActivite.structureEnseignement,NotificationSupport.SMS, PUBLICATION_RESULTATS)
    }

    Set findAllEmailDestinatairesForCreationSeance() {
        findAllPersonnesToNotifierForStructurEnseignementAndSupportAndEvenement(modaliteActivite.structureEnseignement,NotificationSupport.EMAIL,CREATION_SEANCE)
    }

    Set findAllSmsDestinatairesForCreationSeance() {
        findAllPersonnesToNotifierForStructurEnseignementAndSupportAndEvenement(modaliteActivite.structureEnseignement,NotificationSupport.SMS, CREATION_SEANCE)
    }

    Set findAllPersonnesToNotifierForStructurEnseignementAndSupportAndEvenement(StructureEnseignement structureEnseignement, NotificationSupport supportNotification, String evenement) {
        def results
        if (evenement == CREATION_SEANCE) {
            results = groovySql.rows(queryForCreationSeance(structureEnseignement, supportNotification))
        } else if (evenement == PUBLICATION_RESULTATS) {
            results = groovySql.rows(queryForPublicationResultats(structureEnseignement, supportNotification))
        }
        results
    }

    private def queryForPublicationResultats(StructureEnseignement structureEnseignement, NotificationSupport supportNotification) {
        """select autorite.id_externe as personne_id_externe, personne.id as personne_id from ent.personne_propriete_scolarite as profil
    join td.preference_personne as preference on (profil.personne_id = preference.personne_id)
    join ent.propriete_scolarite as propScol on (profil.propriete_scolarite_id = propScol.id)
    join ent.personne as personne on (profil.personne_id = personne.id)
    join securite.autorite as autorite on (personne.autorite_id = autorite.id)
  where
    propScol.structure_enseignement_id = ${structureEnseignement.id} and
    propScol.fonction_id = ${FonctionEnum.ELEVE.id} and
    profil.est_active = true and
    (preference.code_support_notification = ${supportNotification.ordinal()} or preference.code_support_notification = ${NotificationSupport.E_MAIL_AND_SMS.ordinal()}) and
    preference.notification_on_publication_resultats = true
    """
    }

    private def queryForCreationSeance(StructureEnseignement structureEnseignement, NotificationSupport supportNotification) {
        """select autorite.id_externe as personne_id_externe, personne.id as personne_id from ent.personne_propriete_scolarite as profil
    join td.preference_personne as preference on (profil.personne_id = preference.personne_id)
    join ent.propriete_scolarite as propScol on (profil.propriete_scolarite_id = propScol.id)
    join ent.personne as personne on (profil.personne_id = personne.id)
    join securite.autorite as autorite on (personne.autorite_id = autorite.id)
  where
    propScol.structure_enseignement_id = ${structureEnseignement.id} and
    propScol.fonction_id = ${FonctionEnum.ELEVE.id} and
    profil.est_active = true and
    (preference.code_support_notification = ${supportNotification.ordinal()} or preference.code_support_notification = ${NotificationSupport.E_MAIL_AND_SMS.ordinal()}) and
    preference.notification_on_creation_seance = true
    """
    }


    
}
