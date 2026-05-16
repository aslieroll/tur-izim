package com.turizim.application;

import com.turizim.creator.CreatorProfile;
import com.turizim.tour.Tour;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TourApplicationRepository extends JpaRepository<TourApplication, UUID> {

    boolean existsByTourAndCreator(Tour tour, CreatorProfile creator);

    @EntityGraph(attributePaths = {"tour", "creator", "tour.agency"})
    List<TourApplication> findByTour_IdOrderByCreatedAtDesc(UUID tourId);

    @EntityGraph(attributePaths = {"tour", "creator", "tour.agency"})
    List<TourApplication> findByCreator_IdOrderByCreatedAtDesc(UUID creatorId);

    @Query(
            """
            SELECT DISTINCT a FROM TourApplication a
            JOIN FETCH a.tour t
            JOIN FETCH t.agency
            JOIN FETCH a.creator c
            WHERE a.id = :id
            """)
    Optional<TourApplication> findFetchedById(@Param("id") UUID id);
}
