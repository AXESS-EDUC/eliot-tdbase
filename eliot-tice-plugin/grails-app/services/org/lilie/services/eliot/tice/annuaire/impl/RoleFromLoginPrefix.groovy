package org.lilie.services.eliot.tice.annuaire.impl

import org.springframework.security.core.GrantedAuthority

/**
 * Représente un rôle déduit du préfixe du login renvoyé par CAS
 * @deprecated
 */
enum RoleFromLoginPrefix implements GrantedAuthority {
    // le CAS retourne UTnnnnnnn ALnnnnnnnn ...
    // Extrait code CAS de Lilie
    //  public static final String TYPE_UTILISATEUR_NORMAL = "UT";
    //      /** Type de l'utilisateur connecté : administrateur local */
    //      public static final String TYPE_UTILISATEUR_ADMIN_LOCAL = "AL";
    //      /** Type de l'utilisateur connecté : administrateur de la console d'admin */
    //      public static final String TYPE_UTILISATEUR_ADMIN_CONSOLE_ADMIN = "SA";
    //      /** Type de l'utilisateur connecté : administrateur de la console d'admin */
    //      public static final String TYPE_UTILISATEUR_CORRESPONDANT = "CD";


    ADMIN_LOCAL("AL"),
    CORRESPONDANT_DEPLOIEMENT("CD")

    private String prefix

    private RoleFromLoginPrefix(String prefix) {
        this.prefix = prefix
    }

    String getAuthority() {
        return this.name()
    }

    String getPrefix() {
        return prefix
    }
}
