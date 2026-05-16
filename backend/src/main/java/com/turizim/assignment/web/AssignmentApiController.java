package com.turizim.assignment.web;

import com.turizim.assignment.dto.AssignmentDetailResponse;
import com.turizim.assignment.dto.MockDepositResponse;
import com.turizim.assignment.service.AssignmentWorkflowService;
import com.turizim.publication.dto.PublicationProofRequest;
import com.turizim.publication.dto.PublicationProofResponse;
import com.turizim.publication.service.PublicationWorkflowService;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/assignments")
public class AssignmentApiController {

    private final AssignmentWorkflowService assignmentWorkflowService;
    private final PublicationWorkflowService publicationWorkflowService;

    public AssignmentApiController(
            AssignmentWorkflowService assignmentWorkflowService,
            PublicationWorkflowService publicationWorkflowService) {
        this.assignmentWorkflowService = assignmentWorkflowService;
        this.publicationWorkflowService = publicationWorkflowService;
    }

    @GetMapping("/{assignmentId}")
    public AssignmentDetailResponse get(@PathVariable UUID assignmentId) {
        return assignmentWorkflowService.getDetail(assignmentId);
    }

    @PostMapping("/{assignmentId}/confirm")
    public AssignmentDetailResponse confirm(@PathVariable UUID assignmentId) {
        return assignmentWorkflowService.confirmCreator(assignmentId);
    }

    @GetMapping("/{assignmentId}/deposit")
    public MockDepositResponse deposit(@PathVariable UUID assignmentId) {
        return assignmentWorkflowService.getDeposit(assignmentId);
    }

    @PostMapping("/{assignmentId}/publication-proof")
    public PublicationProofResponse submitProof(
            @PathVariable UUID assignmentId, @Valid @RequestBody PublicationProofRequest body) {
        return publicationWorkflowService.upsert(assignmentId, body);
    }

    @GetMapping("/{assignmentId}/publication-proof")
    public PublicationProofResponse getProof(@PathVariable UUID assignmentId) {
        return publicationWorkflowService.get(assignmentId);
    }
}
