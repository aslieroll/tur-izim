package com.turizim.domain.enums;

/**
 * Pasaport beyanı. Yurt dışı uygunluk kapısında tür hiyerarşisi {@link #satisfiesMinimum(PassportType)} ile kıyaslanır.
 */
public enum PassportType {
    NONE,
    OTHER,
    TURKISH_ORDINARY,
    TURKISH_SPECIAL,
    TURKISH_SERVICE,
    TURKISH_DIPLOMATIC;

    /**
     * Üreticinin pasaport türü, acentanın istediği minimum türü karşılıyor mu?
     *
     * @param required tur ilanındaki minimum; {@code null} ise ek tür kısıtı yoktur.
     */
    public boolean satisfiesMinimum(PassportType required) {
        if (required == null || required == NONE) {
            return true;
        }
        if (this == NONE || !isTurkishLadderType(this) || !isTurkishLadderType(required)) {
            return this == required;
        }
        return rankTurkish() >= required.rankTurkish();
    }

    private static boolean isTurkishLadderType(PassportType t) {
        return t == TURKISH_ORDINARY
                || t == TURKISH_SPECIAL
                || t == TURKISH_SERVICE
                || t == TURKISH_DIPLOMATIC;
    }

    private int rankTurkish() {
        return switch (this) {
            case TURKISH_ORDINARY -> 1;
            case TURKISH_SPECIAL -> 2;
            case TURKISH_SERVICE -> 3;
            case TURKISH_DIPLOMATIC -> 4;
            default -> 0;
        };
    }
}
