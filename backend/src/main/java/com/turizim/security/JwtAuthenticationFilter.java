package com.turizim.security;

import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;

    public JwtAuthenticationFilter(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        if (StringUtils.hasText(header) && header.startsWith("Bearer ")) {
            String raw = header.substring(7).trim();
            if (StringUtils.hasText(raw)) {
                try {
                    TurIzimPrincipal p = jwtService.parseAndValidate(raw);
                    SecurityContextHolder.getContext()
                            .setAuthentication(new TurIzimAuthentication(p));
                } catch (JwtException ignored) {
                    // Geçersiz token: SecurityContext boş kalır; korumalı uçlar 401 döner.
                }
            }
        }
        filterChain.doFilter(request, response);
    }
}
