package com.turizim.user;

import com.turizim.common.domain.BaseEntity;
import com.turizim.domain.enums.UserRole;
import com.turizim.agency.Agency;
import com.turizim.creator.CreatorProfile;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "user_accounts")
public class UserAccount extends BaseEntity {

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false, length = 32)
    private UserRole role;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    @OneToOne(mappedBy = "userAccount", fetch = FetchType.LAZY)
    private CreatorProfile creatorProfile;

    @OneToOne(mappedBy = "userAccount", fetch = FetchType.LAZY)
    private Agency agencyEntity;

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public UserRole getRole() {
        return role;
    }

    public void setRole(UserRole role) {
        this.role = role;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public CreatorProfile getCreatorProfile() {
        return creatorProfile;
    }

    public void setCreatorProfile(CreatorProfile creatorProfile) {
        this.creatorProfile = creatorProfile;
    }

    public Agency getAgencyEntity() {
        return agencyEntity;
    }

    public void setAgencyEntity(Agency agencyEntity) {
        this.agencyEntity = agencyEntity;
    }
}
