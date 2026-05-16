package com.turizim.auth;

import com.turizim.auth.dto.AuthResponse;
import com.turizim.auth.dto.CurrentUserResponse;
import com.turizim.auth.dto.LoginRequest;
import com.turizim.auth.dto.RegisterAgencyRequest;
import com.turizim.auth.dto.RegisterCreatorRequest;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.security.SecurityContextSupport;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register/creator")
    public AuthResponse registerCreator(@Valid @RequestBody RegisterCreatorRequest body) {
        return authService.registerCreator(body);
    }

    @PostMapping("/register/agency")
    public AuthResponse registerAgency(@Valid @RequestBody RegisterAgencyRequest body) {
        return authService.registerAgency(body);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest body) {
        return authService.login(body);
    }

    /**
     * Geçerli JWT özetini döner. Frontend: Authorization: Bearer … (Flutter kalıcı entegrasyon TODO).
     */
    @GetMapping("/me")
    public CurrentUserResponse me() {
        return SecurityContextSupport.currentUser()
                .map(authService::me)
                .orElseThrow(
                        () -> new BusinessRuleException(HttpStatus.UNAUTHORIZED.value(), "Oturum yok."));
    }
}
