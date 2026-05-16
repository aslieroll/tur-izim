package com.turizim.common.dto;

/** Health check API response DTO. */
public record HealthResponse(String status, String service) {
}
