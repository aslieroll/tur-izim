package com.turizim.tour.web;

import com.turizim.application.dto.TourApplicationResponse;
import com.turizim.application.service.TourApplicationService;
import java.util.List;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/agency/tours")
public class AgencyTourApplicationsController {

    private final TourApplicationService tourApplicationService;

    public AgencyTourApplicationsController(TourApplicationService tourApplicationService) {
        this.tourApplicationService = tourApplicationService;
    }

    @GetMapping("/{tourId}/applications")
    public List<TourApplicationResponse> listTourApplications(@PathVariable UUID tourId) {
        return tourApplicationService.listForTour(tourId);
    }
}
