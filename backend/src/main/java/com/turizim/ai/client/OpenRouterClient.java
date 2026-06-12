package com.turizim.ai.client;

import com.fasterxml.jackson.databind.JsonNode;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * OpenRouter Chat Completions istemcisi.
 *
 * <p>API anahtarı yapılandırılmamışsa veya çağrı başarısız olursa {@code null} döner;
 * istek asla AI hatası yüzünden patlamaz — çağıran taraf fallback özet üretir.
 */
@Component
public class OpenRouterClient {

    private static final Logger log = LoggerFactory.getLogger(OpenRouterClient.class);

    private static final String SYSTEM_PROMPT =
            "You are an assistant for a tour marketplace. Explain in 1-2 Turkish sentences why this"
                    + " creator is or is not a good match for this tour. Use only objective criteria"
                    + " such as technical requirements, equipment, category fit, verification, and"
                    + " previous delivery score. Do not mention artistic taste. Do not invent data.";

    private final String apiKey;
    private final String model;
    private final RestClient restClient;

    public OpenRouterClient(
            @Value("${app.ai.openrouter.api-key:}") String apiKey,
            @Value("${app.ai.openrouter.model:openai/gpt-4o-mini}") String model,
            @Value("${app.ai.openrouter.base-url:https://openrouter.ai/api/v1}") String baseUrl) {
        this.apiKey = apiKey;
        this.model = model;
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(5_000);
        requestFactory.setReadTimeout(10_000);
        this.restClient = RestClient.builder().baseUrl(baseUrl).requestFactory(requestFactory).build();
    }

    public boolean isConfigured() {
        return apiKey != null && !apiKey.isBlank();
    }

    /**
     * Eşleşme bağlamı için kısa, acente odaklı Türkçe açıklama ister.
     *
     * @return özet metni; anahtar yoksa veya çağrı başarısızsa {@code null}
     */
    public String summarizeMatch(String matchContext) {
        if (!isConfigured()) {
            log.debug("OPENROUTER_API_KEY tanımlı değil; AI özeti atlanıyor.");
            return null;
        }
        try {
            Map<String, Object> body = Map.of(
                    "model", model,
                    "max_tokens", 160,
                    "messages",
                            List.of(
                                    Map.of("role", "system", "content", SYSTEM_PROMPT),
                                    Map.of("role", "user", "content", matchContext)));
            JsonNode response = restClient
                    .post()
                    .uri("/chat/completions")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .body(JsonNode.class);
            String content = extractContent(response);
            if (content == null || content.isBlank()) {
                log.warn("OpenRouter yanıtı boş içerik döndürdü; fallback özet kullanılacak.");
                return null;
            }
            return content.trim();
        } catch (Exception ex) {
            log.warn("OpenRouter çağrısı başarısız; fallback özet kullanılacak: {}", ex.getMessage());
            return null;
        }
    }

    private static String extractContent(JsonNode response) {
        if (response == null) {
            return null;
        }
        JsonNode content = response.path("choices").path(0).path("message").path("content");
        return content.isTextual() ? content.asText() : null;
    }
}
