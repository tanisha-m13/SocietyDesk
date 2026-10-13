package com.societydesk.service;

import com.societydesk.dao.NotificationDAO;
import com.societydesk.dao.SlaRuleDAO;
import com.societydesk.dao.TicketDAO;
import com.societydesk.model.SlaRule;
import com.societydesk.model.Ticket;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class SlaService {
    private static final Logger LOGGER = Logger.getLogger(SlaService.class.getName());
    private final SlaRuleDAO slaRuleDAO = new SlaRuleDAO();
    private final TicketDAO ticketDAO = new TicketDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    public Timestamp calculateDeadline(String priority) {
        SlaRule rule = slaRuleDAO.findByPriority(priority);
        int resolveHours = 24; // fallback default
        if (rule != null && rule.getResolveHours() > 0) {
            resolveHours = rule.getResolveHours();
        } else {
            if ("CRITICAL".equalsIgnoreCase(priority)) resolveHours = 6;
            else if ("HIGH".equalsIgnoreCase(priority)) resolveHours = 12;
            else if ("MEDIUM".equalsIgnoreCase(priority)) resolveHours = 24;
            else if ("LOW".equalsIgnoreCase(priority)) resolveHours = 72;
        }

        return Timestamp.valueOf(LocalDateTime.now().plusHours(resolveHours));
    }

    /**
     * Core SLA Escalation Engine:
     * Overdue tickets are automatically escalated across 3 levels:
     * - Level 1: Overdue past initial deadline -> Notifies Technician & Resident & Committee
     * - Level 2: Substantially overdue -> Escalates to Committee leads
     * - Level 3: Critically overdue -> Escalates to Society Admin
     */
    public int checkAndEscalateTickets(int systemUserId) {
        List<Ticket> overdueTickets = ticketDAO.findOverdueTicketsForEscalation();
        int escalatedCount = 0;

        long now = System.currentTimeMillis();

        for (Ticket ticket : overdueTickets) {
            int currentLevel = ticket.getEscalationLevel();
            long overdueMillis = now - ticket.getSlaDeadline().getTime();
            if (overdueMillis < 0) continue; // Not overdue yet

            long overdueHours = overdueMillis / (1000 * 60 * 60);

            int targetLevel = currentLevel;
            String escalationNote;
            String notifyRole;

            // Strict tiered escalation threshold rules:
            // Level 1: Initial deadline breach (overdue by >= 0 hours, Level 0 -> 1)
            // Level 2: Unresolved after extended grace period (overdue by >= 6 hours, Level 1 -> 2)
            // Level 3: Severe ongoing breach (overdue by >= 18 hours, Level 2 -> 3)
            if (currentLevel == 0 && overdueHours >= 0) {
                targetLevel = 1;
                escalationNote = "Ticket missed SLA deadline of " + ticket.getSlaDeadline() + ". Escalated to Level 1 (Supervisor Alert).";
                notifyRole = "COMMITTEE";
            } else if (currentLevel == 1 && overdueHours >= 6) {
                targetLevel = 2;
                escalationNote = "Ticket still unresolved 6+ hours past SLA deadline. Escalated to Level 2 (Executive Committee).";
                notifyRole = "COMMITTEE";
            } else if (currentLevel == 2 && overdueHours >= 18) {
                targetLevel = 3;
                escalationNote = "Ticket critically unresolved 18+ hours past SLA deadline. Escalated to Level 3 (Society Admin Intervention).";
                notifyRole = "ADMIN";
            } else {
                // Not yet eligible for next escalation tier
                continue;
            }

            int nextLevel = targetLevel;

            boolean success = ticketDAO.escalateTicket(ticket.getId(), nextLevel, escalationNote, systemUserId);
            if (success) {
                escalatedCount++;

                // 1. Notify Resident
                notificationDAO.create(new com.societydesk.model.Notification(
                        ticket.getResidentId(), ticket.getId(),
                        "Your ticket #" + ticket.getId() + " has missed its deadline and was auto-escalated to Level " + nextLevel + "."
                ));

                // 2. Notify Assigned Technician (if assigned)
                if (ticket.getAssignedTo() != null) {
                    notificationDAO.create(new com.societydesk.model.Notification(
                            ticket.getAssignedTo(), ticket.getId(),
                            "URGENT: Assigned ticket #" + ticket.getId() + " is overdue and has been escalated to Level " + nextLevel + "!"
                    ));
                }

                // 3. Notify Committee or Admin roles
                notificationDAO.notifyRoleUsers(notifyRole, ticket.getId(),
                        "ESCALATION ALERT: Ticket #" + ticket.getId() + " (" + ticket.getTitle() + ") escalated to Level " + nextLevel);

                LOGGER.info("Ticket #" + ticket.getId() + " automatically escalated to Level " + nextLevel);
            }
        }

        return escalatedCount;
    }
}
