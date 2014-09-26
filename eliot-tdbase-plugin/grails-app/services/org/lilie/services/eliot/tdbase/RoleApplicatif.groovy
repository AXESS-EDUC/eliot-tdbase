package org.lilie.services.eliot.tdbase

import org.springframework.security.core.GrantedAuthority

/**
 * Les roles applicatifs de TDBase
 */
public enum RoleApplicatif implements GrantedAuthority{
    SUPER_ADMINISTRATEUR,
    ADMINISTRATEUR,
    ENSEIGNANT,
    ELEVE,
    PARENT

    @Override
    String getAuthority() {
        return "ROLE_${name()}"
    }
}