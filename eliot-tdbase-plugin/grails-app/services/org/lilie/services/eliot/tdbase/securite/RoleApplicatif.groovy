package org.lilie.services.eliot.tdbase.securite

import org.springframework.security.core.GrantedAuthority

/**
 * Les roles applicatifs de TDBase
 */
public enum RoleApplicatif implements GrantedAuthority{
    SUPER_ADMINISTRATEUR,
    ADMINISTRATEUR,
    ENSEIGNANT,
    ELEVE,
    PARENT,
    NO_ROLE

    @Override
    String getAuthority() {
        return "ROLE_${name()}"
    }

    /**
     *
     * @return the name of the Role applicatif
     */
    String getCode() {
        name()
    }

    /**
     * Récupère le rôle applicatif à partir du préfixe de login transmis en paramètre
     * @param prefix le prefix du login
     * @return le role applicatif correspondant ou null
     */
    static RoleApplicatif getRoleApplicatifForLoginPrefix(String prefix) {
        // le CAS retourne UTnnnnnnn ALnnnnnnnn ...
        // Extrait code CAS de Lilie
        //  public static final String TYPE_UTILISATEUR_NORMAL = "UT";
        //      /** Type de l'utilisateur connecté : administrateur local */
        //      public static final String TYPE_UTILISATEUR_ADMIN_LOCAL = "AL";
        //      /** Type de l'utilisateur connecté : administrateur de la console d'admin */
        //      public static final String TYPE_UTILISATEUR_ADMIN_CONSOLE_ADMIN = "SA";
        //      /** Type de l'utilisateur connecté : administrateur de la console d'admin */
        //      public static final String TYPE_UTILISATEUR_CORRESPONDANT = "CD";
        mappingPrefixRoleApplicatif.get(prefix)
    }

    static private mappingPrefixRoleApplicatif = [
            "AL":RoleApplicatif.ADMINISTRATEUR,
            "CD":RoleApplicatif.SUPER_ADMINISTRATEUR
    ]

}