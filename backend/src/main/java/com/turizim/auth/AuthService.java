package com.turizim.auth;

import com.turizim.agency.Agency;
import com.turizim.agency.AgencyRepository;
import com.turizim.auth.dto.AuthResponse;
import com.turizim.auth.dto.CurrentUserResponse;
import com.turizim.auth.dto.LoginRequest;
import com.turizim.auth.dto.RegisterAgencyRequest;
import com.turizim.auth.dto.RegisterCreatorRequest;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.creator.CreatorProfile;
import com.turizim.creator.CreatorProfileRepository;
import com.turizim.domain.enums.AgencyStatus;
import com.turizim.domain.enums.UserRole;
import com.turizim.security.JwtService;
import com.turizim.security.TurIzimPrincipal;
import com.turizim.user.UserAccount;
import com.turizim.user.UserAccountRepository;
import java.util.Locale;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserAccountRepository userAccountRepository;
    private final CreatorProfileRepository creatorProfileRepository;
    private final AgencyRepository agencyRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(
            UserAccountRepository userAccountRepository,
            CreatorProfileRepository creatorProfileRepository,
            AgencyRepository agencyRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService) {
        this.userAccountRepository = userAccountRepository;
        this.creatorProfileRepository = creatorProfileRepository;
        this.agencyRepository = agencyRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public AuthResponse registerCreator(RegisterCreatorRequest req) {
        String email = normalizeEmail(req.email());
        if (userAccountRepository.existsByEmailIgnoreCase(email)) {
            throw new BusinessRuleException(HttpStatus.CONFLICT.value(), "Bu e-posta ile kayıt zaten var.");
        }
        UserAccount u = new UserAccount();
        u.setFullName(req.fullName().trim());
        u.setEmail(email);
        u.setPasswordHash(passwordEncoder.encode(req.password()));
        u.setRole(UserRole.CREATOR);
        u.setActive(true);
        u = userAccountRepository.save(u);

        CreatorProfile cp = new CreatorProfile();
        cp.setFullName(req.fullName().trim());
        cp.setEmail(email);
        cp.setUniversityName(req.universityName().trim());
        cp.setCity(req.city().trim());
        cp.setPassportType(req.passportType());
        cp.setHasValidPassport(Boolean.TRUE.equals(req.hasValidPassport()));
        cp.setHasSchengenVisa(Boolean.TRUE.equals(req.hasSchengenVisa()));
        cp.setHasUsVisa(Boolean.TRUE.equals(req.hasUsVisa()));
        cp.setHasUkVisa(Boolean.TRUE.equals(req.hasUkVisa()));
        cp.setHasOtherValidVisa(Boolean.TRUE.equals(req.hasOtherValidVisa()));
        cp.setActive(true);
        cp.setUserAccount(u);
        cp = creatorProfileRepository.save(cp);

        u.setCreatorProfile(cp);
        String token = jwtService.createToken(u, cp.getId(), null);
        return new AuthResponse(token, u.getId(), u.getRole(), u.getEmail(), u.getFullName(), cp.getId(), null);
    }

    @Transactional
    public AuthResponse registerAgency(RegisterAgencyRequest req) {
        String email = normalizeEmail(req.contactEmail());
        if (userAccountRepository.existsByEmailIgnoreCase(email)) {
            throw new BusinessRuleException(HttpStatus.CONFLICT.value(), "Bu e-posta ile kayıt zaten var.");
        }
        UserAccount u = new UserAccount();
        u.setFullName(req.name().trim());
        u.setEmail(email);
        u.setPasswordHash(passwordEncoder.encode(req.password()));
        u.setRole(UserRole.AGENCY);
        u.setActive(true);
        u = userAccountRepository.save(u);

        Agency agency = new Agency();
        agency.setName(req.name().trim());
        agency.setContactEmail(email);
        agency.setPhone(req.phone().trim());
        agency.setCity(req.city().trim());
        agency.setStatus(AgencyStatus.PENDING_APPROVAL);
        agency.setUserAccount(u);
        agency = agencyRepository.save(agency);

        u.setAgencyEntity(agency);
        String token = jwtService.createToken(u, null, agency.getId());
        return new AuthResponse(
                token, u.getId(), u.getRole(), u.getEmail(), u.getFullName(), null, agency.getId());
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest req) {
        String email = normalizeEmail(req.email());
        UserAccount u = userAccountRepository
                .findByEmailIgnoreCase(email)
                .orElseThrow(() -> new BusinessRuleException(
                        HttpStatus.UNAUTHORIZED.value(), "E-posta veya şifre hatalı."));
        if (!u.isActive()) {
            throw new BusinessRuleException(HttpStatus.FORBIDDEN.value(), "Hesap devre dışı.");
        }
        if (!passwordEncoder.matches(req.password(), u.getPasswordHash())) {
            throw new BusinessRuleException(HttpStatus.UNAUTHORIZED.value(), "E-posta veya şifre hatalı.");
        }
        UUID cid =
                creatorProfileRepository.findByUserAccount_Id(u.getId()).map(CreatorProfile::getId).orElse(null);
        UUID aid = agencyRepository.findByUserAccount_Id(u.getId()).map(Agency::getId).orElse(null);
        String token = jwtService.createToken(u, cid, aid);
        return new AuthResponse(token, u.getId(), u.getRole(), u.getEmail(), u.getFullName(), cid, aid);
    }

    public CurrentUserResponse me(TurIzimPrincipal principal) {
        return new CurrentUserResponse(
                principal.getUserId(),
                principal.getRole(),
                principal.getEmail(),
                principal.getFullName(),
                principal.getCreatorProfileId(),
                principal.getAgencyId());
    }

    private static String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
