package com.turizim.creator;

import com.turizim.common.domain.BaseEntity;
import com.turizim.domain.enums.PassportType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;

@Entity
@Table(name = "creator_profiles")
public class CreatorProfile extends BaseEntity {

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(name = "email", nullable = false)
    private String email;

    @Column(name = "university_name", nullable = false)
    private String universityName;

    @Column(name = "city", nullable = false)
    private String city;

    @Enumerated(EnumType.STRING)
    @Column(name = "passport_type", nullable = false, length = 40)
    private PassportType passportType = PassportType.NONE;

    @Column(name = "has_valid_passport", nullable = false)
    private boolean hasValidPassport;

    @Column(name = "has_schengen_visa", nullable = false)
    private boolean hasSchengenVisa;

    @Column(name = "has_us_visa", nullable = false)
    private boolean hasUsVisa;

    @Column(name = "has_uk_visa", nullable = false)
    private boolean hasUkVisa;

    @Column(name = "has_other_valid_visa", nullable = false)
    private boolean hasOtherValidVisa;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

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

    public String getUniversityName() {
        return universityName;
    }

    public void setUniversityName(String universityName) {
        this.universityName = universityName;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public PassportType getPassportType() {
        return passportType;
    }

    public void setPassportType(PassportType passportType) {
        this.passportType = passportType;
    }

    public boolean isHasValidPassport() {
        return hasValidPassport;
    }

    public void setHasValidPassport(boolean hasValidPassport) {
        this.hasValidPassport = hasValidPassport;
    }

    public boolean isHasSchengenVisa() {
        return hasSchengenVisa;
    }

    public void setHasSchengenVisa(boolean hasSchengenVisa) {
        this.hasSchengenVisa = hasSchengenVisa;
    }

    public boolean isHasUsVisa() {
        return hasUsVisa;
    }

    public void setHasUsVisa(boolean hasUsVisa) {
        this.hasUsVisa = hasUsVisa;
    }

    public boolean isHasUkVisa() {
        return hasUkVisa;
    }

    public void setHasUkVisa(boolean hasUkVisa) {
        this.hasUkVisa = hasUkVisa;
    }

    public boolean isHasOtherValidVisa() {
        return hasOtherValidVisa;
    }

    public void setHasOtherValidVisa(boolean hasOtherValidVisa) {
        this.hasOtherValidVisa = hasOtherValidVisa;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
