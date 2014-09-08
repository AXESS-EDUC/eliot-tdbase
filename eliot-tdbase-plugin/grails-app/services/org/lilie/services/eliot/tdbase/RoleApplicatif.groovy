package org.lilie.services.eliot.tdbase

import org.springframework.security.core.GrantedAuthority

/**
 * Les roles applicatifs de TDBase
 */
public enum RoleApplicatif implements GrantedAuthority{
    ENSEIGNANT,
    ELEVE,
    PARENT,
    ADMINISTRATEUR

    @Override
    String getAuthority() {
        return name()
    }
}