package com.turizim.tour.web;

import com.turizim.application.dto.TourApplicationResponse;
import com.turizim.application.service.TourApplicationService;
import com.turizim.billing.AgencySubscriptionService;
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
    private final AgencySubscriptionService subscriptionService;

    public AgencyTourApplicationsController(
            TourApplicationService tourApplicationService,
            AgencySubscriptionService subscriptionService) {
        this.tourApplicationService = tourApplicationService;
        this.subscriptionService = subscriptionService;
    }

    @GetMapping("/{tourId}/applications")
    public List<TourApplicationResponse> listTourApplications(@PathVariable UUID tourId) {
        subscriptionService.requireActivePaidSubscription();
        return tourApplicationService.listForTour(tourId);
    }
}
