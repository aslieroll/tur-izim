package com.turizim.tour.web;

import com.turizim.application.dto.ApplicationSubmitRequest;
import com.turizim.application.dto.TourApplicationResponse;
import com.turizim.application.service.TourApplicationService;
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
@RequestMapping("/api/tours")
public class TourApiController {

    private final TourService tourService;
    private final TourApplicationService tourApplicationService;

    public TourApiController(TourService tourService, TourApplicationService tourApplicationService) {
        this.tourService = tourService;
        this.tourApplicationService = tourApplicationService;
    }

    @GetMapping
    public List<TourSummaryResponse> listPublished() {
        return tourService.listPublished();
    }

    @GetMapping("/{id}")
    public TourSummaryResponse getPublished(@PathVariable UUID id) {
        return tourService.getById(id);
    }

    @PostMapping("/{tourId}/applications")
    public TourApplicationResponse apply(
            @PathVariable UUID tourId, @Valid @RequestBody ApplicationSubmitRequest body) {
        return tourApplicationService.submit(tourId, body);
    }
}
