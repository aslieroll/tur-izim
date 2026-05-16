package com.turizim.application.web;

import com.turizim.assignment.dto.AssignmentDetailResponse;
import com.turizim.assignment.service.AssignmentWorkflowService;
import java.util.UUID;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/applications")
public class ApplicationSelectionController {

    private final AssignmentWorkflowService assignmentWorkflowService;

    public ApplicationSelectionController(AssignmentWorkflowService assignmentWorkflowService) {
        this.assignmentWorkflowService = assignmentWorkflowService;
    }

    @PostMapping("/{applicationId}/select")
    public AssignmentDetailResponse select(@PathVariable UUID applicationId) {
        return assignmentWorkflowService.selectApplication(applicationId);
    }
}
