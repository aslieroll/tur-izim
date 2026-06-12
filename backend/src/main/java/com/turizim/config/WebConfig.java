package com.turizim.config;

import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * CORS: yerel geliştirme origin'leri her zaman açık; üretimde dağıtılan frontend
 * {@code FRONTEND_ORIGIN} ortam değişkeni ile eklenir (virgülle birden fazla olabilir).
 *
 * <p>Credentials açık olduğu için wildcard {@code *} kullanılmaz.
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    private final List<String> allowedOriginPatterns;

    public WebConfig(@Value("${app.cors.frontend-origin:}") String frontendOrigin) {
        List<String> patterns = new ArrayList<>(List.of(
                "http://localhost:*",
                "http://127.0.0.1:*",
                "http://[::1]:*"));
        if (frontendOrigin != null && !frontendOrigin.isBlank()) {
            for (String origin : frontendOrigin.split(",")) {
                String trimmed = origin.trim();
                if (!trimmed.isEmpty()) {
                    patterns.add(trimmed);
                }
            }
        }
        this.allowedOriginPatterns = List.copyOf(patterns);
    }

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOriginPatterns(allowedOriginPatterns.toArray(String[]::new))
                .allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true);
    }
}
