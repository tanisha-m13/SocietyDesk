package com.societydesk.controller;

import com.societydesk.dao.TicketDAO;
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

@WebServlet(name = "TechnicianTaskServlet", urlPatterns = {
        "/technician/dashboard",
        "/technician/tasks",
        "/technician/update"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class TechnicianTaskServlet extends HttpServlet {
    private final TicketDAO ticketDAO = new TicketDAO();
    private final TicketService ticketService = new TicketService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User technician = (User) req.getSession().getAttribute("user");
        List<Ticket> tasks = ticketDAO.findByTechnicianId(technician.getId());
        req.setAttribute("tasks", tasks);

        long assignedCount = tasks.stream().filter(t -> "ASSIGNED".equals(t.getStatus())).count();
        long inProgressCount = tasks.stream().filter(t -> "IN_PROGRESS".equals(t.getStatus()) || "REOPENED".equals(t.getStatus())).count();
        long resolvedCount = tasks.stream().filter(t -> "RESOLVED".equals(t.getStatus()) || "CLOSED".equals(t.getStatus())).count();
        long overdueCount = tasks.stream().filter(Ticket::isOverdue).count();

        req.setAttribute("assignedCount", assignedCount);
        req.setAttribute("inProgressCount", inProgressCount);
        req.setAttribute("resolvedCount", resolvedCount);
        req.setAttribute("overdueCount", overdueCount);

        req.getRequestDispatcher("/WEB-INF/views/technician/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User technician = (User) req.getSession().getAttribute("user");
        String action = req.getParameter("action");
        int ticketId = Integer.parseInt(req.getParameter("ticketId"));
        String note = req.getParameter("note");

        try {
            if ("START".equalsIgnoreCase(action)) {
                ticketService.startWork(ticketId, technician.getId(), technician.getRole(), note);
                resp.sendRedirect(req.getContextPath() + "/ticket/detail?id=" + ticketId + "&msg=Task started and marked IN_PROGRESS.");
            } else if ("RESOLVE".equalsIgnoreCase(action)) {
                Part photoPart = req.getPart("proofPhoto");
                String uploadDir = req.getServletContext().getRealPath("/uploads");
                String photoFileName = null;
                if (photoPart != null && photoPart.getSize() > 0) {
                    photoFileName = FileUtil.saveUploadedFile(photoPart, uploadDir);
                }

                ticketService.resolveTicket(ticketId, technician.getId(), technician.getRole(), note, photoFileName);
                resp.sendRedirect(req.getContextPath() + "/ticket/detail?id=" + ticketId + "&msg=Task marked RESOLVED. Awaiting resident closure.");
            } else {
                resp.sendRedirect(req.getContextPath() + "/ticket/detail?id=" + ticketId);
            }
        } catch (com.societydesk.exception.InvalidTransitionException e) {
            resp.sendRedirect(req.getContextPath() + "/ticket/detail?id=" + ticketId + "&error=" + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }
}
