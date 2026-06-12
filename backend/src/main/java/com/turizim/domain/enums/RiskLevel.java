package com.turizim.domain.enums;

/** AI Match Assistant risk seviyesi; deterministik skora göre türetilir. */
public enum RiskLevel {
    LOW,
    MEDIUM,
    HIGH;

    public static RiskLevel fromScore(int fitnessScore) {
        if (fitnessScore >= 75) {
            return LOW;
        }
        if (fitnessScore >= 50) {
            return MEDIUM;
        }
        return HIGH;
    }
}
