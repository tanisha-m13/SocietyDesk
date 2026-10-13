package com.societydesk.service;

import com.societydesk.dao.*;
import com.societydesk.exception.InvalidTransitionException;
import com.societydesk.model.Notification;
import com.societydesk.model.Rating;
import com.societydesk.model.Ticket;
import com.societydesk.model.TicketUpdate;

import java.sql.Timestamp;
import java.util.logging.Logger;

/**
 * TicketService manages ticket creation and validates all lifecycle state transitions
 * against the formalized transition matrix, throwing InvalidTransitionException on violations.
 */
public class TicketService {
    private static final Logger LOGGER = Logger.getLogger(TicketService.class.getName());
    private final TicketDAO ticketDAO = new TicketDAO();
    private final TicketUpdateDAO updateDAO = new TicketUpdateDAO();
    private final SlaService slaService = new SlaService();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final RatingDAO ratingDAO = new RatingDAO();
    private final AdminAuditDAO auditDAO = new AdminAuditDAO();

    public boolean createTicket(Ticket ticket) {
        if (ticket.getPriority() == null || ticket.getPriority().trim().isEmpty()) {
            ticket.setPriority("MEDIUM");
        }
        Timestamp deadline = slaService.calculateDeadline(ticket.getPriority());
        ticket.setSlaDeadline(deadline);
        ticket.setStatus("OPEN");
        ticket.setEscalationLevel(0);

        boolean created = ticketDAO.create(ticket);
        if (created) {
            notificationDAO.notifyRoleUsers("COMMITTEE", ticket.getId(),
                    "New ticket #" + ticket.getId() + " raised: " + ticket.getTitle() + " (Priority: " + ticket.getPriority() + ")");
        }
        return created;
    }

    /**
     * Transition: OPEN or REOPENED -> ASSIGNED
     * Allowed Roles: COMMITTEE, ADMIN
     */
    public boolean assignTicket(int ticketId, int technicianId, int assignedBy, String role, String note)
            throws InvalidTransitionException {
        if (!"COMMITTEE".equalsIgnoreCase(role) && !"ADMIN".equalsIgnoreCase(role)) {
            throw new InvalidTransitionException("Unauthorized: Only Committee members or Admins can assign technicians.");
        }

        Ticket t = ticketDAO.findById(ticketId);
        if (t == null) {
            throw new IllegalArgumentException("Ticket not found with id: " + ticketId);
        }

        String cur = t.getStatus();
        if (!"OPEN".equalsIgnoreCase(cur) && !"REOPENED".equalsIgnoreCase(cur) && !"ASSIGNED".equalsIgnoreCase(cur)) {
            throw new InvalidTransitionException(cur, "ASSIGNED", role);
        }

        boolean assigned = ticketDAO.assignTicket(ticketId, technicianId, assignedBy, note);
        if (assigned) {
            // Log administrative action
            auditDAO.logAction(assignedBy, "TICKET_ASSIGNED", "TICKET", ticketId,
                    "Assigned ticket #" + ticketId + " to technician #" + technicianId + (note != null ? " (" + note + ")" : ""));

            // Notify Technician
            notificationDAO.create(new Notification(technicianId, ticketId,
                    "You have been assigned ticket #" + ticketId + " (" + t.getTitle() + "). Please review and start work."));

            // Notify Resident
            notificationDAO.create(new Notification(t.getResidentId(), ticketId,
                    "Your ticket #" + ticketId + " has been assigned to a technician."));
        }
        return assigned;
    }

    /**
     * Transition: ASSIGNED or REOPENED -> IN_PROGRESS
     * Allowed Roles: TECHNICIAN (assigned), ADMIN
     */
    public boolean startWork(int ticketId, int technicianId, String role, String note)
            throws InvalidTransitionException {
        Ticket t = ticketDAO.findById(ticketId);
        if (t == null) {
            throw new IllegalArgumentException("Ticket not found: " + ticketId);
        }

        if (!"ADMIN".equalsIgnoreCase(role) && (t.getAssignedTo() == null || t.getAssignedTo() != technicianId)) {
            throw new InvalidTransitionException("Unauthorized: Only the assigned technician can start work on this ticket.");
        }

        String cur = t.getStatus();
        if (!"ASSIGNED".equalsIgnoreCase(cur) && !"REOPENED".equalsIgnoreCase(cur)) {
            throw new InvalidTransitionException(cur, "IN_PROGRESS", role);
        }

        boolean updated = ticketDAO.updateStatus(ticketId, technicianId, "IN_PROGRESS",
                (note != null && !note.trim().isEmpty()) ? note : "Technician has started work on this issue.", null);

        if (updated) {
            notificationDAO.create(new Notification(t.getResidentId(), ticketId,
                    "Work has started on your ticket #" + ticketId + "."));
        }
        return updated;
    }

    /**
     * Transition: IN_PROGRESS -> RESOLVED
     * Allowed Roles: TECHNICIAN (assigned), ADMIN
     */
    public boolean resolveTicket(int ticketId, int technicianId, String role, String note, String proofPhotoPath)
            throws InvalidTransitionException {
        Ticket t = ticketDAO.findById(ticketId);
        if (t == null) {
            throw new IllegalArgumentException("Ticket not found: " + ticketId);
        }

        if (!"ADMIN".equalsIgnoreCase(role) && (t.getAssignedTo() == null || t.getAssignedTo() != technicianId)) {
            throw new InvalidTransitionException("Unauthorized: Only the assigned technician can mark this ticket resolved.");
        }

        String cur = t.getStatus();
        if (!"IN_PROGRESS".equalsIgnoreCase(cur)) {
            throw new InvalidTransitionException(cur, "RESOLVED", role);
        }

        boolean updated = ticketDAO.updateStatus(ticketId, technicianId, "RESOLVED",
                (note != null && !note.trim().isEmpty()) ? note : "Issue resolved by technician. Awaiting resident confirmation.",
                proofPhotoPath);

        if (updated) {
            notificationDAO.create(new Notification(t.getResidentId(), ticketId,
                    "Ticket #" + ticketId + " has been marked as RESOLVED. Please verify the fix and confirm or reopen."));
        }
        return updated;
    }

    /**
     * Transition: RESOLVED -> CLOSED
     * Allowed Roles: RESIDENT (owner), ADMIN
     */
    public boolean confirmAndCloseTicket(int ticketId, int residentId, String role, int stars, String feedback)
            throws InvalidTransitionException {
        Ticket t = ticketDAO.findById(ticketId);
        if (t == null) {
            throw new IllegalArgumentException("Ticket not found: " + ticketId);
        }

        if (!"ADMIN".equalsIgnoreCase(role) && t.getResidentId() != residentId) {
            throw new InvalidTransitionException("Unauthorized: Only the resident who logged this ticket can close it.");
        }

        String cur = t.getStatus();
        if (!"RESOLVED".equalsIgnoreCase(cur)) {
            throw new InvalidTransitionException(cur, "CLOSED", role);
        }

        boolean updated = ticketDAO.updateStatus(ticketId, residentId, "CLOSED",
                "Resolution verified and confirmed by resident. Issue officially closed.", null);

        if (updated) {
            if (stars >= 1 && stars <= 5) {
                ratingDAO.create(new Rating(ticketId, stars, feedback));
            }
            if (t.getAssignedTo() != null) {
                notificationDAO.create(new Notification(t.getAssignedTo(), ticketId,
                        "Resident confirmed resolution for ticket #" + ticketId + " with " + stars + " star rating."));
            }
        }
        return updated;
    }

    /**
     * Transition: RESOLVED -> REOPENED
     * Allowed Roles: RESIDENT (owner), ADMIN
     */
    public boolean reopenTicket(int ticketId, int residentId, String role, String reason)
            throws InvalidTransitionException {
        Ticket t = ticketDAO.findById(ticketId);
        if (t == null) {
            throw new IllegalArgumentException("Ticket not found: " + ticketId);
        }

        if (!"ADMIN".equalsIgnoreCase(role) && t.getResidentId() != residentId) {
            throw new InvalidTransitionException("Unauthorized: Only the resident who logged this ticket can reopen it.");
        }

        String cur = t.getStatus();
        if (!"RESOLVED".equalsIgnoreCase(cur)) {
            throw new InvalidTransitionException(cur, "REOPENED", role);
        }

        boolean updated = ticketDAO.updateStatus(ticketId, residentId, "REOPENED",
                "Ticket REOPENED by resident. Reason: " + reason, null);

        if (updated) {
            if (t.getAssignedTo() != null) {
                notificationDAO.create(new Notification(t.getAssignedTo(), ticketId,
                        "ALERT: Ticket #" + ticketId + " was REOPENED by the resident: " + reason));
            }
            notificationDAO.notifyRoleUsers("COMMITTEE", ticketId,
                    "URGENT: Ticket #" + ticketId + " was REOPENED by resident. Committee review required.");
        }
        return updated;
    }

    public boolean addComment(int ticketId, int userId, String comment) {
        Ticket t = ticketDAO.findById(ticketId);
        if (t == null) return false;
        TicketUpdate update = new TicketUpdate(ticketId, userId, t.getStatus(), t.getStatus(), comment, null);
        return updateDAO.create(update);
    }
}
