package com.turizim.security;

import java.util.Optional;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public final class SecurityContextSupport {

    private SecurityContextSupport() {}

    /** JWT veya anonim; anonimde boş döner. */
    public static Optional<TurIzimPrincipal> currentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return Optional.empty();
        }
        Object p = auth.getPrincipal();
        if (p instanceof TurIzimPrincipal tp) {
            return Optional.of(tp);
        }
        return Optional.empty();
    }
}
