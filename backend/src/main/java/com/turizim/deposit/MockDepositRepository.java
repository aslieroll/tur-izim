package com.turizim.deposit;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MockDepositRepository extends JpaRepository<MockDeposit, UUID> {

    Optional<MockDeposit> findByAssignment_Id(UUID assignmentId);
}
