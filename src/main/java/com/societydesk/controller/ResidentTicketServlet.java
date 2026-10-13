package com.societydesk.controller;

import com.societydesk.dao.CategoryDAO;
import com.societydesk.dao.NoticeDAO;
import com.societydesk.dao.TicketDAO;
import com.societydesk.model.Category;
import com.societydesk.model.Notice;
import com.societydesk.model.Ticket;
import com.societydesk.model.User;
import com.societydesk.service.TicketService;
import com.societydesk.util.FileUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ResidentTicketServlet", urlPatterns = {
        "/resident/dashboard",
        "/resident/tickets",
        "/resident/tickets/new",
        "/resident/tickets/rate",
        "/resident/tickets/reopen"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      // 1MB in memory
        maxFileSize = 5 * 1024 * 1024,        // 5MB max uploaded file
        maxRequestSize = 10 * 1024 * 1024     // 10MB total multipart request
)
public class ResidentTicketServlet extends HttpServlet {
    private final TicketDAO ticketDAO = new TicketDAO();
    private final TicketService ticketService = new TicketService();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final NoticeDAO noticeDAO = new NoticeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        String path = req.getServletPath();

        if ("/resident/tickets/new".equals(path)) {
            List<Category> categories = categoryDAO.findAll();
            req.setAttribute("categories", categories);
            req.getRequestDispatcher("/WEB-INF/views/resident/new_ticket.jsp").forward(req, resp);
            return;
        }

        // List resident tickets
        List<Ticket> myTickets = ticketDAO.findByResidentId(user.getId());
        req.setAttribute("tickets", myTickets);

        if ("/resident/dashboard".equals(path)) {
            List<Notice> activeNotices = noticeDAO.findActiveNotices();
            req.setAttribute("notices", activeNotices);

            long openCount = myTickets.stream().filter(t -> "OPEN".equals(t.getStatus()) || "REOPENED".equals(t.getStatus())).count();
            long inProgressCount = myTickets.stream().filter(t -> "ASSIGNED".equals(t.getStatus()) || "IN_PROGRESS".equals(t.getStatus())).count();
            long resolvedCount = myTickets.stream().filter(t -> "RESOLVED".equals(t.getStatus())).count();
            long closedCount = myTickets.stream().filter(t -> "CLOSED".equals(t.getStatus())).count();

            req.setAttribute("openCount", openCount);
            req.setAttribute("inProgressCount", inProgressCount);
            req.setAttribute("resolvedCount", resolvedCount);
            req.setAttribute("closedCount", closedCount);

            req.getRequestDispatcher("/WEB-INF/views/resident/dashboard.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/WEB-INF/views/resident/my_tickets.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        String path = req.getServletPath();

        if ("/resident/tickets/new".equals(path)) {
            handleCreateTicket(req, resp, user);
        } else if ("/resident/tickets/rate".equals(path)) {
            handleRatingAndClose(req, resp, user);
        } else if ("/resident/tickets/reopen".equals(path)) {
            handleReopen(req, resp, user);
        }
    }

    private void handleCreateTicket(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        try {
            String title = req.getParameter("title");
            String description = req.getParameter("description");
            String priority = req.getParameter("priority");
            int categoryId = Integer.parseInt(req.getParameter("categoryId"));

            Part photoPart = req.getPart("photo");
            String uploadDir = req.getServletContext().getRealPath("/uploads");
            String photoFileName = null;
            if (photoPart != null && photoPart.getSize() > 0) {
                photoFileName = FileUtil.saveUploadedFile(photoPart, uploadDir);
            }

            Ticket ticket = new Ticket();
            ticket.setResidentId(user.getId());
            ticket.setCategoryId(categoryId);
            ticket.setTitle(title);
            ticket.setDescription(description);
            ticket.setPriority(priority);
            ticket.setPhotoPath(photoFileName);

            boolean success = ticketService.createTicket(ticket);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/ticket/detail?id=" + ticket.getId() + "&msg=Ticket created successfully!");
            } else {
                req.setAttribute("error", "Failed to create ticket. Please verify your inputs.");
                req.setAttribute("categories", categoryDAO.findAll());
                req.getRequestDispatcher("/WEB-INF/views/resident/new_ticket.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("categories", categoryDAO.findAll());
            req.getRequestDispatcher("/WEB-INF/views/resident/new_ticket.jsp").forward(req, resp);
        }
    }

    private void handleRatingAndClose(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        int ticketId = Integer.parseInt(req.getParameter("ticketId"));
        int stars = Integer.parseInt(req.getParameter("stars"));
        String feedback = req.getParameter("feedback");

        try {
            ticketService.confirmAndCloseTicket(ticketId, user.getId(), user.getRole(), stars, feedback);
            resp.sendRedirect(req.getContextPath() + "/ticket/detail?id=" + ticketId + "&msg=Thank you! Ticket marked closed.");
        } catch (com.societydesk.exception.InvalidTransitionException e) {
            resp.sendRedirect(req.getContextPath() + "/ticket/detail?id=" + ticketId + "&error=" + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    private void handleReopen(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        int ticketId = Integer.parseInt(req.getParameter("ticketId"));
        String reason = req.getParameter("reason");

        try {
            ticketService.reopenTicket(ticketId, user.getId(), user.getRole(), reason);
            resp.sendRedirect(req.getContextPath() + "/ticket/detail?id=" + ticketId + "&msg=Ticket reopened and flagged for committee review.");
        } catch (com.societydesk.exception.InvalidTransitionException e) {
            resp.sendRedirect(req.getContextPath() + "/ticket/detail?id=" + ticketId + "&error=" + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }
}
