package com.societydesk.service;

import com.societydesk.dao.RatingDAO;
import com.societydesk.dao.TicketDAO;
import com.societydesk.dao.UserDAO;

import java.util.HashMap;
import java.util.Map;

public class ReportService {
    private final TicketDAO ticketDAO = new TicketDAO();
    private final UserDAO userDAO = new UserDAO();
    private final RatingDAO ratingDAO = new RatingDAO();

    public Map<String, Object> getDashboardMetrics() {
        Map<String, Object> metrics = new HashMap<>();
        Map<String, Integer> statusCounts = ticketDAO.getStatusCounts();

        int totalTickets = statusCounts.values().stream().mapToInt(Integer::intValue).sum();
        int openTickets = statusCounts.getOrDefault("OPEN", 0) + statusCounts.getOrDefault("REOPENED", 0);
        int inProgressTickets = statusCounts.getOrDefault("ASSIGNED", 0) + statusCounts.getOrDefault("IN_PROGRESS", 0);
        int closedTickets = statusCounts.getOrDefault("CLOSED", 0) + statusCounts.getOrDefault("RESOLVED", 0);
        int escalatedTickets = ticketDAO.findEscalated().size();

        metrics.put("totalTickets", totalTickets);
        metrics.put("openTickets", openTickets);
        metrics.put("inProgressTickets", inProgressTickets);
        metrics.put("closedTickets", closedTickets);
        metrics.put("escalatedTickets", escalatedTickets);
        metrics.put("slaCompliance", String.format("%.1f", ticketDAO.getSlaCompliancePercentage()));
        metrics.put("avgResolutionHours", String.format("%.1f", ticketDAO.getAverageResolutionHours()));
        metrics.put("avgRating", String.format("%.1f", ratingDAO.getAverageRating()));
        metrics.put("totalUsers", userDAO.countTotalUsers());

        return metrics;
    }

    public Map<String, Integer> getStatusBreakdown() {
        return ticketDAO.getStatusCounts();
    }

    public Map<String, Integer> getCategoryBreakdown() {
        return ticketDAO.getCategoryCounts();
    }
}
