package com.turizim.creator.service;

import com.turizim.common.exception.BusinessRuleException;
import com.turizim.creator.CreatorProfile;
import com.turizim.creator.CreatorProfileRepository;
import com.turizim.creator.dto.CreatorProfileResponse;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CreatorProfileService {

    private final CreatorProfileRepository creatorProfileRepository;

    public CreatorProfileService(CreatorProfileRepository creatorProfileRepository) {
        this.creatorProfileRepository = creatorProfileRepository;
    }

    @Transactional(readOnly = true)
    public List<CreatorProfileResponse> listAll() {
        return creatorProfileRepository.findAll().stream().map(this::toDto).toList();
    }

    @Transactional(readOnly = true)
    public CreatorProfileResponse getById(UUID id) {
        return creatorProfileRepository.findById(id).map(this::toDto).orElseThrow(() -> new BusinessRuleException(
                HttpStatus.NOT_FOUND.value(), "Üretici profili bulunamadı."));
    }

    public CreatorProfile requireCreator(UUID id) {
        return creatorProfileRepository
                .findById(id)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.BAD_REQUEST.value(), "Üretici bulunamadı."));
    }

    private CreatorProfileResponse toDto(CreatorProfile c) {
        return new CreatorProfileResponse(
                c.getId(),
                c.getFullName(),
                c.getEmail(),
                c.getUniversityName(),
                c.getCity(),
                c.getPassportType(),
                c.isHasValidPassport(),
                c.isHasSchengenVisa(),
                c.isHasUsVisa(),
                c.isHasUkVisa(),
                c.isHasOtherValidVisa(),
                c.isActive());
    }
}
