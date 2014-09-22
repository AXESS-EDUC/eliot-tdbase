package org.lilie.services.eliot.tdbase

import org.springframework.security.core.GrantedAuthority

/**
 * Les roles applicatifs de TDBase
 */
public enum RoleApplicatif implements GrantedAuthority{
    ADMINISTRATEUR,
    ENSEIGNANT,
    ELEVE,
    PARENT

    @Override
    String getAuthority() {
        return name()
    }
}