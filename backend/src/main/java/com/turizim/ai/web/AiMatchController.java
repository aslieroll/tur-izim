package com.turizim.ai.web;

import com.turizim.ai.dto.AiMatchRequest;
import com.turizim.ai.dto.AiMatchResponse;
import com.turizim.ai.service.AiMatchService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ai")
public class AiMatchController {

    private final AiMatchService aiMatchService;

    public AiMatchController(AiMatchService aiMatchService) {
        this.aiMatchService = aiMatchService;
    }

    @PostMapping("/match-score")
    public AiMatchResponse matchScore(@Valid @RequestBody AiMatchRequest request) {
        return aiMatchService.evaluate(request);
    }
}
