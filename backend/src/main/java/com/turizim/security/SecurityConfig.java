package com.turizim.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * JWT stateless güvenlik.
 *
 * <p>Frontend henüz Authorization header göndermiyorsa {@code app.security.legacy-open-api=true}
 * ile tüm API geçici olarak açıktır. Üretimde ve güvenlik testlerinde {@code false} yapılmalıdır.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final JwtAuthenticationEntryPoint authenticationEntryPoint;
    private final JwtAccessDeniedHandler accessDeniedHandler;

    @Value("${app.security.legacy-open-api:true}")
    private boolean legacyOpenApi;

    public SecurityConfig(
            JwtAuthenticationFilter jwtAuthenticationFilter,
            JwtAuthenticationEntryPoint authenticationEntryPoint,
            JwtAccessDeniedHandler accessDeniedHandler) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
        this.authenticationEntryPoint = authenticationEntryPoint;
        this.accessDeniedHandler = accessDeniedHandler;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable());
        http.cors(cors -> {});
        http.sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS));
        http.httpBasic(b -> b.disable());
        http.formLogin(f -> f.disable());
        http.logout(l -> l.disable());

        if (legacyOpenApi) {
            http.authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
        } else {
            http.authorizeHttpRequests(
                    auth ->
                            auth.requestMatchers(HttpMethod.GET, "/api/health")
                                    .permitAll()
                                    .requestMatchers(HttpMethod.POST, "/api/auth/register/**")
                                    .permitAll()
                                    .requestMatchers(HttpMethod.POST, "/api/auth/login")
                                    .permitAll()
                                    .requestMatchers(HttpMethod.GET, "/api/auth/me")
                                    .authenticated()
                                    .requestMatchers(HttpMethod.GET, "/api/tours")
                                    .permitAll()
                                    .requestMatchers(HttpMethod.GET, "/api/tours/*")
                                    .permitAll()
                                    .requestMatchers(HttpMethod.GET, "/api/creators")
                                    .permitAll()
                                    .requestMatchers(HttpMethod.GET, "/api/creators/*/applications")
                                    .hasRole("CREATOR")
                                    .requestMatchers(HttpMethod.GET, "/api/creators/*/assignments")
                                    .hasRole("CREATOR")
                                    .requestMatchers(HttpMethod.GET, "/api/creators/*")
                                    .permitAll()
                                    .requestMatchers(HttpMethod.POST, "/api/tours/*/applications")
                                    .hasRole("CREATOR")
                                    .requestMatchers(HttpMethod.POST, "/api/agency/tours")
                                    .hasRole("AGENCY")
                                    .requestMatchers(HttpMethod.GET, "/api/agency/*/tours")
                                    .hasRole("AGENCY")
                                    .requestMatchers(HttpMethod.GET, "/api/agency/tours/*/applications")
                                    .hasRole("AGENCY")
                                    .requestMatchers(HttpMethod.POST, "/api/applications/*/select")
                                    .hasRole("AGENCY")
                                    .requestMatchers(HttpMethod.POST, "/api/publication-proofs/*/violations")
                                    .hasAnyRole("AGENCY", "ADMIN")
                                    .requestMatchers("/api/assignments/**")
                                    .hasAnyRole("CREATOR", "AGENCY")
                                    .anyRequest()
                                    .authenticated());
        }

        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        if (!legacyOpenApi) {
            http.exceptionHandling(
                    ex ->
                            ex.authenticationEntryPoint(authenticationEntryPoint)
                                    .accessDeniedHandler(accessDeniedHandler));
        }

        return http.build();
    }
}
