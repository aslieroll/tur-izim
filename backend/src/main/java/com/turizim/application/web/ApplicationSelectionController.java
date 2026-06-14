package com.turizim.application.web;

import com.turizim.assignment.dto.AssignmentDetailResponse;
import com.turizim.assignment.service.AssignmentWorkflowService;
import com.turizim.billing.AgencySubscriptionService;
import java.util.UUID;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/applications")
public class ApplicationSelectionController {

    private final AssignmentWorkflowService assignmentWorkflowService;
    private final AgencySubscriptionService subscriptionService;

    public ApplicationSelectionController(
            AssignmentWorkflowService assignmentWorkflowService,
            AgencySubscriptionService subscriptionService) {
        this.assignmentWorkflowService = assignmentWorkflowService;
        this.subscriptionService = subscriptionService;
    }

    @PostMapping("/{applicationId}/select")
    public AssignmentDetailResponse select(@PathVariable UUID applicationId) {
        subscriptionService.requireActivePaidSubscription();
        return assignmentWorkflowService.selectApplication(applicationId);
    }
}
