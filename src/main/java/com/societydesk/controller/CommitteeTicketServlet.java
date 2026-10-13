package com.societydesk.controller;

import com.societydesk.dao.CategoryDAO;
import com.societydesk.dao.TicketDAO;
import com.societydesk.dao.UserDAO;
import com.societydesk.model.Category;
import com.societydesk.model.Ticket;
import com.societydesk.model.User;
import com.societydesk.service.ReportService;
import com.societydesk.service.TicketService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "CommitteeTicketServlet", urlPatterns = {
        "/committee/dashboard",
        "/committee/tickets",
        "/committee/assign"
})
public class CommitteeTicketServlet extends HttpServlet {
    private final TicketDAO ticketDAO = new TicketDAO();
    private final UserDAO userDAO = new UserDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final TicketService ticketService = new TicketService();
    private final ReportService reportService = new ReportService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        List<User> technicians = userDAO.findByRole("TECHNICIAN");
        List<Category> categories = categoryDAO.findAll();
        req.setAttribute("technicians", technicians);
        req.setAttribute("categories", categories);

        if ("/committee/dashboard".equals(path)) {
            List<Ticket> unassignedTickets = ticketDAO.findUnassigned();
            List<Ticket> escalatedTickets = ticketDAO.findEscalated();
            Map<String, Object> metrics = reportService.getDashboardMetrics();

            req.setAttribute("unassignedTickets", unassignedTickets);
            req.setAttribute("escalatedTickets", escalatedTickets);
            req.setAttribute("metrics", metrics);

            req.getRequestDispatcher("/WEB-INF/views/committee/dashboard.jsp").forward(req, resp);
        } else {
            // All tickets with filtering
            String searchIdStr = req.getParameter("ticketId");
            String status = req.getParameter("status");
            String catIdStr = req.getParameter("categoryId");
            String priority = req.getParameter("priority");
            String techIdStr = req.getParameter("technicianId");
            String escLevelStr = req.getParameter("escalationLevel");
            String overdueStr = req.getParameter("overdue");

            Integer searchId = (searchIdStr != null && !searchIdStr.trim().isEmpty()) ? Integer.parseInt(searchIdStr.trim()) : null;
            Integer catId = (catIdStr != null && !catIdStr.isEmpty()) ? Integer.parseInt(catIdStr) : null;
            Integer techId = (techIdStr != null && !techIdStr.isEmpty()) ? Integer.parseInt(techIdStr) : null;
            Integer escLevel = (escLevelStr != null && !escLevelStr.isEmpty() && !"ALL".equalsIgnoreCase(escLevelStr)) ? Integer.parseInt(escLevelStr) : null;
            Boolean overdueOnly = "true".equalsIgnoreCase(overdueStr);

            List<Ticket> tickets = ticketDAO.findWithFilters(searchId, status, catId, priority, techId, escLevel, overdueOnly);
            req.setAttribute("tickets", tickets);
            req.setAttribute("searchTicketId", searchId);
            req.setAttribute("selectedStatus", status);
            req.setAttribute("selectedCategory", catId);
            req.setAttribute("selectedPriority", priority);
            req.setAttribute("selectedTechId", techId);
            req.setAttribute("selectedEscLevel", escLevelStr);
            req.setAttribute("overdueOnly", overdueOnly);

            req.getRequestDispatcher("/WEB-INF/views/committee/tickets.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        User currentUser = (User) req.getSession().getAttribute("user");

        if ("/committee/assign".equals(path)) {
            int ticketId = Integer.parseInt(req.getParameter("ticketId"));
            int technicianId = Integer.parseInt(req.getParameter("technicianId"));
            String note = req.getParameter("note");

            try {
                ticketService.assignTicket(ticketId, technicianId, currentUser.getId(), currentUser.getRole(), note);
                resp.sendRedirect(req.getContextPath() + "/ticket/detail?id=" + ticketId + "&msg=Technician assigned successfully.");
            } catch (com.societydesk.exception.InvalidTransitionException e) {
                resp.sendRedirect(req.getContextPath() + "/ticket/detail?id=" + ticketId + "&error=" + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
            }
        }
    }
}
