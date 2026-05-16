package com.turizim.security;

import com.turizim.domain.enums.UserRole;
import com.turizim.user.UserAccount;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.UUID;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class JwtService {

    private final SecretKey key;
    private final long expirationMs;

    public JwtService(
            @Value("${app.security.jwt.secret}") String secret,
            @Value("${app.security.jwt.expiration-ms:3600000}") long expirationMs) {
        byte[] bytes = secret.getBytes(StandardCharsets.UTF_8);
        if (bytes.length < 32) {
            throw new IllegalStateException("app.security.jwt.secret must be at least 256 bits (32 bytes).");
        }
        this.key = Keys.hmacShaKeyFor(bytes);
        this.expirationMs = expirationMs;
    }

    public String createToken(UserAccount user, UUID creatorId, UUID agencyId) {
        Date now = new Date();
        Date exp = new Date(now.getTime() + expirationMs);
        return Jwts.builder()
                .subject(user.getId().toString())
                .claim("role", user.getRole().name())
                .claim("email", user.getEmail())
                .claim("fn", user.getFullName())
                .claim("cid", creatorId != null ? creatorId.toString() : null)
                .claim("aid", agencyId != null ? agencyId.toString() : null)
                .issuedAt(now)
                .expiration(exp)
                .signWith(key)
                .compact();
    }

    public TurIzimPrincipal parseAndValidate(String token) {
        try {
            Claims claims =
                    Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
            UUID userId = UUID.fromString(claims.getSubject());
            UserRole role = UserRole.valueOf(claims.get("role", String.class));
            String cid = claims.get("cid", String.class);
            String aid = claims.get("aid", String.class);
            UUID creatorProfileId = cid == null || cid.isBlank() ? null : UUID.fromString(cid);
            UUID agencyId = aid == null || aid.isBlank() ? null : UUID.fromString(aid);
            return new TurIzimPrincipal(
                    userId,
                    role,
                    creatorProfileId,
                    agencyId,
                    claims.get("email", String.class),
                    claims.get("fn", String.class));
        } catch (ExpiredJwtException e) {
            throw new JwtException("Token süresi doldu.", e);
        } catch (JwtException | IllegalArgumentException e) {
            throw new JwtException("Geçersiz token.", e);
        }
    }
}
