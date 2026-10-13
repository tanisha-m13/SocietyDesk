package com.societydesk.job;

import com.societydesk.service.SlaService;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * EscalationJob runs in the background at regular intervals.
 * It detects tickets that missed their SLA deadline and escalates them automatically.
 */
public class EscalationJob implements Runnable {
    private static final Logger LOGGER = Logger.getLogger(EscalationJob.class.getName());
    private final SlaService slaService = new SlaService();
    private final int systemUserId;

    public EscalationJob(int systemUserId) {
        this.systemUserId = systemUserId;
    }

    @Override
    public void run() {
        try {
            LOGGER.info("[EscalationJob] Checking for overdue tickets...");
            int escalated = slaService.checkAndEscalateTickets(systemUserId);
            if (escalated > 0) {
                LOGGER.info("[EscalationJob] Completed run: " + escalated + " ticket(s) automatically escalated.");
            }
        } catch (Throwable e) {
            LOGGER.log(Level.SEVERE, "[EscalationJob] Unexpected error during automated ticket escalation execution", e);
        }
    }
}
