package com.turizim.security;

import java.util.List;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

public class TurIzimAuthentication extends AbstractAuthenticationToken {

    private final TurIzimPrincipal principal;

    public TurIzimAuthentication(TurIzimPrincipal principal) {
        super(List.of(new SimpleGrantedAuthority("ROLE_" + principal.getRole().name())));
        this.principal = principal;
        setAuthenticated(true);
    }

    @Override
    public Object getCredentials() {
        return null;
    }

    @Override
    public TurIzimPrincipal getPrincipal() {
        return principal;
    }
}
