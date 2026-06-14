package com.turizim.domain.enums;

/** Acente abonelik plan kodu. FREE varsayılandır; kayıt gerekmez. */
public enum SubscriptionPlanCode {
    /** Ücretsiz plan: 1 aktif tur, ücretli özellikler kilitli. */
    FREE,
    /** Agency Pro: 499 TL/ay, 5 aktif tur, tüm ücretli özellikler. */
    AGENCY_PRO,
    /** Agency Growth: 999 TL/ay, 20 aktif tur, öncelikli destek. */
    AGENCY_GROWTH
}
