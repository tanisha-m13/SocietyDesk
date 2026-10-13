package com.societydesk.exception;

/**
 * Thrown when an illegal or unauthorized ticket lifecycle transition is attempted.
 * For example: attempting to move directly from OPEN to RESOLVED, or a Resident
 * attempting to assign a technician.
 */
public class InvalidTransitionException extends Exception {
    private final String currentStatus;
    private final String attemptedStatus;
    private final String userRole;

    public InvalidTransitionException(String currentStatus, String attemptedStatus, String userRole) {
        super(String.format("Invalid lifecycle transition: Cannot move from '%s' to '%s' as role '%s'",
                currentStatus, attemptedStatus, userRole));
        this.currentStatus = currentStatus;
        this.attemptedStatus = attemptedStatus;
        this.userRole = userRole;
    }

    public InvalidTransitionException(String message) {
        super(message);
        this.currentStatus = null;
        this.attemptedStatus = null;
        this.userRole = null;
    }

    public String getCurrentStatus() { return currentStatus; }
    public String getAttemptedStatus() { return attemptedStatus; }
    public String getUserRole() { return userRole; }
}
