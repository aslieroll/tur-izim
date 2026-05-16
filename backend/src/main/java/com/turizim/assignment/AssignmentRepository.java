package com.turizim.assignment;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AssignmentRepository extends JpaRepository<Assignment, UUID> {

    Optional<Assignment> findByApplication_Id(UUID applicationId);

    @Query(
            """
            SELECT DISTINCT a FROM Assignment a
            JOIN FETCH a.tour t
            JOIN FETCH t.agency
            JOIN FETCH a.creator c
            JOIN FETCH a.application app
            WHERE a.id = :id
            """)
    Optional<Assignment> findDetailById(@Param("id") UUID id);

    @Query(
            """
            SELECT DISTINCT a FROM Assignment a
            JOIN FETCH a.tour t
            JOIN FETCH t.agency
            JOIN FETCH a.creator c
            JOIN FETCH a.application app
            WHERE a.creator.id = :creatorId
            ORDER BY a.createdAt DESC
            """)
    List<Assignment> findDetailByCreatorId(@Param("creatorId") UUID creatorId);
}
