package com.turizim.billing;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AgencySubscriptionRepository extends JpaRepository<AgencySubscription, UUID> {

    Optional<AgencySubscription> findByAgency_Id(UUID agencyId);
}
