package com.turizim.tour;

import com.turizim.domain.enums.TourStatus;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TourRepository extends JpaRepository<Tour, UUID> {

    @EntityGraph(attributePaths = "agency")
    @Query("SELECT t FROM Tour t WHERE t.status = :status ORDER BY t.startDate ASC")
    List<Tour> findPublishedWithAgency(@Param("status") TourStatus status);

    @EntityGraph(attributePaths = "agency")
    @Query("SELECT t FROM Tour t WHERE t.id = :id")
    Optional<Tour> findOneByIdWithAgency(@Param("id") UUID id);

    @EntityGraph(attributePaths = "agency")
    @Query("SELECT t FROM Tour t WHERE t.agency.id = :agencyId ORDER BY t.startDate DESC")
    List<Tour> findByAgencyIdWithAgency(@Param("agencyId") UUID agencyId);

    @Query("SELECT COUNT(t) FROM Tour t WHERE t.agency.id = :agencyId AND t.status = :status")
    long countByAgencyIdAndStatus(
            @Param("agencyId") UUID agencyId, @Param("status") TourStatus status);
}
