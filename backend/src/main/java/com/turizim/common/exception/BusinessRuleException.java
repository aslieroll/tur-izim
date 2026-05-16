package com.turizim.common.exception;

/** İş kuralı ihlali; HTTP durum kodu taşır. */
public class BusinessRuleException extends RuntimeException {

    private final int status;

    public BusinessRuleException(int status, String message) {
        super(message);
        this.status = status;
    }

    public int getStatus() {
        return status;
    }
}
