package com.turizim.tour.web;

import com.turizim.application.dto.TourApplicationResponse;
import com.turizim.application.service.TourApplicationService;
import com.turizim.tour.dto.CreateTourRequest;
import com.turizim.tour.dto.TourSummaryResponse;
import com.turizim.tour.service.TourService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/agency")
public class AgencyPortalController {

    private final TourService tourService;

    public AgencyPortalController(TourService tourService) {
        this.tourService = tourService;
    }

    @PostMapping("/tours")
    public TourSummaryResponse createTour(@Valid @RequestBody CreateTourRequest body) {
        return tourService.create(body);
    }

    @GetMapping("/{agencyId}/tours")
    public List<TourSummaryResponse> listAgencyTours(@PathVariable UUID agencyId) {
        return tourService.listByAgency(agencyId);
    }
}
