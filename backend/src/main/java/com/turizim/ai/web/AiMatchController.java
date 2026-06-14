package com.turizim.ai.web;

import com.turizim.ai.dto.AiMatchRequest;
import com.turizim.ai.dto.AiMatchResponse;
import com.turizim.ai.service.AiMatchService;
import com.turizim.billing.AgencySubscriptionService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ai")
public class AiMatchController {

    private final AiMatchService aiMatchService;
    private final AgencySubscriptionService subscriptionService;

    public AiMatchController(
            AiMatchService aiMatchService,
            AgencySubscriptionService subscriptionService) {
        this.aiMatchService = aiMatchService;
        this.subscriptionService = subscriptionService;
    }

    @PostMapping("/match-score")
    public AiMatchResponse matchScore(@Valid @RequestBody AiMatchRequest request) {
        subscriptionService.requireActivePaidSubscription();
        return aiMatchService.evaluate(request);
    }
}
