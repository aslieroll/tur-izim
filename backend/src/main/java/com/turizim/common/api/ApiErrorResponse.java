package com.turizim.common.api;

/** Standart hata gövdesi (REST). */
public record ApiErrorResponse(int status, String code, String message) {
}
