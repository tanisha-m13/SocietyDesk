package com.societydesk.controller;

import com.societydesk.dao.RatingDAO;
import com.societydesk.dao.TicketDAO;
import com.societydesk.dao.TicketUpdateDAO;
import com.societydesk.dao.UserDAO;
import com.societydesk.model.Rating;
import com.societydesk.model.Ticket;
import com.societydesk.model.TicketUpdate;
import com.societydesk.model.User;
import com.societydesk.service.TicketService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "TicketDetailServlet", urlPatterns = {"/ticket/detail", "/ticket/comment"})
public class TicketDetailServlet extends HttpServlet {
    private final TicketDAO ticketDAO = new TicketDAO();
    private final TicketUpdateDAO updateDAO = new TicketUpdateDAO();
    private final RatingDAO ratingDAO = new RatingDAO();
    private final UserDAO userDAO = new UserDAO();
    private final TicketService ticketService = new TicketService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        int ticketId = Integer.parseInt(idStr);
        Ticket ticket = ticketDAO.findById(ticketId);
        if (ticket == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Ticket not found");
            return;
        }

        User currentUser = (User) req.getSession().getAttribute("user");
        String role = currentUser.getRole();

        // Access check: resident can only see their own tickets unless committee/admin/assigned tech
        if ("RESIDENT".equals(role) && ticket.getResidentId() != currentUser.getId()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You cannot access this ticket.");
            return;
        }

        List<TicketUpdate> updates = updateDAO.findByTicketId(ticketId);
        Rating rating = ratingDAO.findByTicketId(ticketId);
        List<User> technicians = userDAO.findByRole("TECHNICIAN");

        req.setAttribute("ticket", ticket);
        req.setAttribute("updates", updates);
        req.setAttribute("rating", rating);
        req.setAttribute("technicians", technicians);

        req.getRequestDispatcher("/WEB-INF/views/common/ticket_detail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        User currentUser = (User) req.getSession().getAttribute("user");

        if ("/ticket/comment".equals(path)) {
            int ticketId = Integer.parseInt(req.getParameter("ticketId"));
            String comment = req.getParameter("comment");

            if (comment != null && !comment.trim().isEmpty()) {
                ticketService.addComment(ticketId, currentUser.getId(), comment.trim());
            }
            resp.sendRedirect(req.getContextPath() + "/ticket/detail?id=" + ticketId + "&msg=Comment added successfully.");
        }
    }
}
