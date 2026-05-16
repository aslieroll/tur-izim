package com.turizim.security;

import com.turizim.domain.enums.UserRole;
import java.io.Serial;
import java.io.Serializable;
import java.util.UUID;

/** JWT / SecurityContext içi kimlik; her istekte taşınır. */
public final class TurIzimPrincipal implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private final UUID userId;
    private final UserRole role;
    private final UUID creatorProfileId;
    private final UUID agencyId;
    private final String email;
    private final String fullName;

    public TurIzimPrincipal(
            UUID userId,
            UserRole role,
            UUID creatorProfileId,
            UUID agencyId,
            String email,
            String fullName) {
        this.userId = userId;
        this.role = role;
        this.creatorProfileId = creatorProfileId;
        this.agencyId = agencyId;
        this.email = email;
        this.fullName = fullName;
    }

    public UUID getUserId() {
        return userId;
    }

    public UserRole getRole() {
        return role;
    }

    public UUID getCreatorProfileId() {
        return creatorProfileId;
    }

    public UUID getAgencyId() {
        return agencyId;
    }

    public String getEmail() {
        return email;
    }

    public String getFullName() {
        return fullName;
    }
}
