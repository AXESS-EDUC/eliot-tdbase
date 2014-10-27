package org.lilie.services.eliot.tice.webservices.test



class ScolariteController {

    static scope = "singleton"

    def getFonctionsForEtablissement() {
        def eid = params.etablissementId as Long
        if (eid > 0) {
            String resp = '''[{"code":"LAB","libelle":"PERSONNELS DE LABORATOIRE"},
                    {"code":"ORI","libelle":"ORIENTATION"},
                    {"code":"ELEVE","libelle":"ELEVE"},
                    {"code":"DIR","libelle":"DIRECTION"},
                    {"code":"DOC","libelle":"DOCUMENTATION"},
                    {"code":"CTR","libelle":"CHEF DE TRAVAUX"},
                    {"code":"EDU","libelle":"EDUCATION"},
                    {"code":"ADF","libelle":"PERSONNELS ADMINISTRATIFS"},
                    {"code":"AVS","libelle":"AUXILIAIRE DE VIE SCOLAIRE"},
                    {"code":"UI","libelle":"INVITE"},
                    {"code":"MDS","libelle":"PERSONNELS MEDICO-SOCIAUX"},
                    {"code":"APP","libelle":"APPRENTISSAGE"},
                    {"code":"AL","libelle":"ADMINISTRATEUR_LOCAL"},
                    {"code":"ENS","libelle":"ENSEIGNEMENT"}
                    ]'''
            render(text: resp, contentType: "application/json", encoding: "UTF-8")
        } else {
            render(contentType: "text/json") {
                etablissementId = eid
                erreur = "not found"
            }

        }

    }
}
