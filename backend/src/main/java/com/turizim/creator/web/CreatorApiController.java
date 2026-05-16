package com.turizim.creator.web;

import com.turizim.application.dto.TourApplicationResponse;
import com.turizim.application.service.TourApplicationService;
import com.turizim.assignment.dto.AssignmentDetailResponse;
import com.turizim.assignment.service.AssignmentWorkflowService;
import com.turizim.creator.dto.CreatorProfileResponse;
import com.turizim.creator.service.CreatorProfileService;
import java.util.List;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/creators")
public class CreatorApiController {

    private final CreatorProfileService creatorProfileService;
    private final TourApplicationService tourApplicationService;
    private final AssignmentWorkflowService assignmentWorkflowService;

    public CreatorApiController(
            CreatorProfileService creatorProfileService,
            TourApplicationService tourApplicationService,
            AssignmentWorkflowService assignmentWorkflowService) {
        this.creatorProfileService = creatorProfileService;
        this.tourApplicationService = tourApplicationService;
        this.assignmentWorkflowService = assignmentWorkflowService;
    }

    @GetMapping
    public List<CreatorProfileResponse> list() {
        return creatorProfileService.listAll();
    }

    @GetMapping("/{creatorId}")
    public CreatorProfileResponse get(@PathVariable UUID creatorId) {
        return creatorProfileService.getById(creatorId);
    }

    @GetMapping("/{creatorId}/applications")
    public List<TourApplicationResponse> applications(@PathVariable UUID creatorId) {
        return tourApplicationService.listForCreator(creatorId);
    }

    @GetMapping("/{creatorId}/assignments")
    public List<AssignmentDetailResponse> assignments(@PathVariable UUID creatorId) {
        return assignmentWorkflowService.listForCreator(creatorId);
    }
}
