package com.turizim.publication;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PublicationProofRepository extends JpaRepository<PublicationProof, UUID> {

    Optional<PublicationProof> findByAssignment_Id(UUID assignmentId);
}
