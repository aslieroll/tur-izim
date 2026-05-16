package com.turizim.admin.web;

import com.turizim.admin.dto.ViolationCreateRequest;
import com.turizim.admin.dto.ViolationReportResponse;
import com.turizim.admin.service.ViolationReportService;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/publication-proofs")
public class PublicationViolationController {

    private final ViolationReportService violationReportService;

    public PublicationViolationController(ViolationReportService violationReportService) {
        this.violationReportService = violationReportService;
    }

    @PostMapping("/{proofId}/violations")
    public ViolationReportResponse report(
            @PathVariable UUID proofId, @Valid @RequestBody ViolationCreateRequest body) {
        return violationReportService.report(proofId, body);
    }
}
