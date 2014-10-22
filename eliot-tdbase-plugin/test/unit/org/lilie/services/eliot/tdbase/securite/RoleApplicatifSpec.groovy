package org.lilie.services.eliot.tdbase.securite

import spock.lang.Specification
import spock.lang.Unroll

/**
 * Created by franck on 22/10/2014.
 */
class RoleApplicatifSpec extends Specification {

    @Unroll
    def "le rôle applicatif #roleAttendu est obtenu à partir du préfixe #prefix"() {

        given: "un préfixe"
        prefix

        when: "le rôle correspondant au préfixe est demandé"
        def role = RoleApplicatif.getRoleApplicatifForLoginPrefix(prefix)

        then: "le rôle applicatif correspondant ou null est retourné"
        role == roleAttendu

        where:
        prefix | roleAttendu
        "CD" | RoleApplicatif.SUPER_ADMINISTRATEUR
        "AL" | RoleApplicatif.ADMINISTRATEUR
        "UT" | null
        "SA" | null

    }

}
