package com.turizim.agency;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AgencyRepository extends JpaRepository<Agency, UUID> {

    Optional<Agency> findByUserAccount_Id(UUID userAccountId);
}
