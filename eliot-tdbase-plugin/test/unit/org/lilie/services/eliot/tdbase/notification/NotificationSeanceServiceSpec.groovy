package org.lilie.services.eliot.tdbase.notification

import grails.test.mixin.TestFor
import org.lilie.services.eliot.tdbase.ModaliteActivite
import org.lilie.services.eliot.tice.annuaire.Personne
import org.lilie.services.eliot.tice.scolarite.Etablissement
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.services.ServiceUnitTestMixin} for usage instructions
 */
@TestFor(NotificationSeanceService)
class NotificationSeanceServiceSpec extends Specification {


	NotificationSeanceService notificationSeanceService
	NotificationSeanceDaoService notificationSeanceDaoService
	ModaliteActivite modaliteActivite
	Personne demandeur

	def setup() {

		modaliteActivite = Mock(ModaliteActivite) {
			findEtablissement() >> Mock(Etablissement) {
				getIdExterne() >> "etabIdExt"
			}
		}
		notificationSeanceDaoService = Mock(NotificationSeanceDaoService) {
			findAllEmailDestinatairesForPublicationResultats(modaliteActivite) >> listIdsExt1
			findAllSmsDestinatairesForPublicationResultats(modaliteActivite) >> listIdsExt2
			findAllEmailDestinatairesForCreationSeance(modaliteActivite) >> listIdsExt3
			findAllSmsDestinatairesForCreationSeance(modaliteActivite) >> listIdsExt4
		}
		demandeur = Mock(Personne) {
			getIdExterne() >> "demandIdExt"
		}

		notificationSeanceService = new NotificationSeanceService()
		notificationSeanceService.notificationSeanceDaoService = notificationSeanceDaoService
	}

	void "test la récupération d'une notification par email de la publication d'un resultat"() {
		given: "une séance"
		modaliteActivite

		and: "un demandeur"
		demandeur

		when:"la récupération de la notification est déclenchée"
		def notif = notificationSeanceService.getEmailNotificationOnPublicationResultatsForSeance(demandeur,"titre",
				"message",modaliteActivite)

		then:" la notification est créée avec le support email"
		notif.supports == [NotificationSupport.EMAIL]

		and:"le demandeur de la notif a été  mise à jour"
		notif.demandeurIdexterne == "demandIdExt"

		and:"les titres et messages sont OK"
		notif.titre == "titre"
		notif.message == "message"

		and: "la liste des destinataires est OK"
		notif.destinatairesIdExterne == listIdsExt1

	}

	void "test la récupération d'une notification par sms de la publication d'un resultat"() {
		given: "une séance"
		modaliteActivite

		and: "un demandeur"
		demandeur

		when:"la récupération de la notification est déclenchée"
		def notif = notificationSeanceService.getSmsNotificationOnPublicationResultatsForSeance(demandeur,"titre",
				"message",modaliteActivite)

		then:" la notification est créée avec le support sms"
		notif.supports == [NotificationSupport.SMS]

		and:"le demandeur de la notif a été  mise à jour"
		notif.demandeurIdexterne == "demandIdExt"

		and:"les titres et messages sont OK"
		notif.titre == "titre"
		notif.message == "message"

		and: "la liste des destinataires est OK"
		notif.destinatairesIdExterne == listIdsExt2

	}

	void "test la récupération d'une notification par email de la création d'une séance"() {
		given: "une séance"
		modaliteActivite

		and: "un demandeur"
		demandeur

		when:"la récupération de la notification est déclenchée"
		def notif = notificationSeanceService.getEmailNotificationOnCreationSeanceForSeance(demandeur,"titre",
				"message",modaliteActivite)

		then:" la notification est créée avec le support sms"
		notif.supports == [NotificationSupport.EMAIL]

		and:"le demandeur de la notif a été  mise à jour"
		notif.demandeurIdexterne == "demandIdExt"

		and:"les titres et messages sont OK"
		notif.titre == "titre"
		notif.message == "message"

		and: "la liste des destinataires est OK"
		notif.destinatairesIdExterne == listIdsExt3

	}

	void "test la récupération d'une notification par sms de la création d'une séance"() {
		given: "une séance"
		modaliteActivite

		and: "un demandeur"
		demandeur

		when:"la récupération de la notification est déclenchée"
		def notif = notificationSeanceService.getSmsNotificationOnCreationSeanceForSeance(demandeur,"titre",
				"message",modaliteActivite)

		then:" la notification est créée avec le support sms"
		notif.supports == [NotificationSupport.SMS]

		and:"le demandeur de la notif a été  mise à jour"
		notif.demandeurIdexterne == "demandIdExt"

		and:"les titres et messages sont OK"
		notif.titre == "titre"
		notif.message == "message"

		and: "la liste des destinataires est OK"
		notif.destinatairesIdExterne == listIdsExt4

	}



	private static final ArrayList<String> listIdsExt1 = ["idext1", "idext2"]
	private static final ArrayList<String> listIdsExt2 = ["idext1"]
	private static final ArrayList<String> listIdsExt3 = ["idext1", "idext3"]
	private static final ArrayList<String> listIdsExt4 = ["idext3", "idext4"]
}
