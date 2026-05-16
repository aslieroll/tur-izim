package com.turizim.common.api;

import com.turizim.common.dto.HealthResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class HealthController {

    private static final String SERVICE_NAME = "tur-izim-backend";

    @GetMapping("/health")
    public HealthResponse health() {
        return new HealthResponse("UP", SERVICE_NAME);
    }
}
