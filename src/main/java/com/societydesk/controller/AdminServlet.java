package com.societydesk.controller;

import com.societydesk.dao.*;
import com.societydesk.model.*;
import com.societydesk.service.ReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminServlet", urlPatterns = {
        "/admin/dashboard",
        "/admin/users",
        "/admin/flats",
        "/admin/categories",
        "/admin/vendors",
        "/admin/sla",
        "/admin/audit"
})
public class AdminServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final FlatDAO flatDAO = new FlatDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final VendorDAO vendorDAO = new VendorDAO();
    private final SlaRuleDAO slaRuleDAO = new SlaRuleDAO();
    private final ReportService reportService = new ReportService();
    private final AdminAuditDAO auditDAO = new AdminAuditDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        switch (path) {
            case "/admin/dashboard" -> {
                Map<String, Object> metrics = reportService.getDashboardMetrics();
                List<User> pendingUsers = userDAO.findPendingUsers();
                List<AdminAuditLog> recentAudit = auditDAO.findRecent(10);
                req.setAttribute("metrics", metrics);
                req.setAttribute("pendingUsers", pendingUsers);
                req.setAttribute("recentAudit", recentAudit);
                req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
            }
            case "/admin/users" -> {
                List<User> allUsers = userDAO.findAll();
                List<User> pendingUsers = userDAO.findPendingUsers();
                req.setAttribute("allUsers", allUsers);
                req.setAttribute("pendingUsers", pendingUsers);
                req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
            }
            case "/admin/flats" -> {
                List<Flat> flats = flatDAO.findAll();
                req.setAttribute("flats", flats);
                req.getRequestDispatcher("/WEB-INF/views/admin/flats.jsp").forward(req, resp);
            }
            case "/admin/categories" -> {
                List<Category> categories = categoryDAO.findAll();
                req.setAttribute("categories", categories);
                req.getRequestDispatcher("/WEB-INF/views/admin/categories.jsp").forward(req, resp);
            }
            case "/admin/vendors" -> {
                List<Vendor> vendors = vendorDAO.findAll();
                req.setAttribute("vendors", vendors);
                req.getRequestDispatcher("/WEB-INF/views/admin/vendors.jsp").forward(req, resp);
            }
            case "/admin/sla" -> {
                List<SlaRule> rules = slaRuleDAO.findAll();
                req.setAttribute("rules", rules);
                req.getRequestDispatcher("/WEB-INF/views/admin/sla.jsp").forward(req, resp);
            }
            case "/admin/audit" -> {
                List<AdminAuditLog> auditLogs = auditDAO.findRecent(100);
                req.setAttribute("auditLogs", auditLogs);
                req.getRequestDispatcher("/WEB-INF/views/admin/audit_logs.jsp").forward(req, resp);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        User admin = (User) req.getSession().getAttribute("user");
        int adminId = (admin != null) ? admin.getId() : 1;

        switch (path) {
            case "/admin/users" -> {
                int userId = Integer.parseInt(req.getParameter("userId"));
                String action = req.getParameter("action"); // APPROVE, REJECT, DEACTIVATE
                String newStatus = "ACTIVE";
                if ("REJECT".equalsIgnoreCase(action)) newStatus = "REJECTED";
                else if ("DEACTIVATE".equalsIgnoreCase(action)) newStatus = "INACTIVE";

                userDAO.updateStatus(userId, newStatus);
                auditDAO.logAction(adminId, "USER_" + action.toUpperCase(), "USER", userId,
                        "Admin updated status of user #" + userId + " to " + newStatus);

                resp.sendRedirect(req.getContextPath() + "/admin/users?msg=User status updated to " + newStatus);
            }
            case "/admin/flats" -> {
                String block = req.getParameter("block");
                String flatNo = req.getParameter("flatNo");
                Flat flat = new Flat(block, flatNo);
                flatDAO.create(flat);
                auditDAO.logAction(adminId, "FLAT_CREATED", "FLAT", flat.getId(),
                        "Added Flat Block " + block + " - " + flatNo);
                resp.sendRedirect(req.getContextPath() + "/admin/flats?msg=Flat added successfully.");
            }
            case "/admin/categories" -> {
                String name = req.getParameter("name");
                String description = req.getParameter("description");
                Category cat = new Category(name, description);
                categoryDAO.create(cat);
                auditDAO.logAction(adminId, "CATEGORY_CREATED", "CATEGORY", cat.getId(),
                        "Created category: " + name);
                resp.sendRedirect(req.getContextPath() + "/admin/categories?msg=Category added successfully.");
            }
            case "/admin/vendors" -> {
                String name = req.getParameter("name");
                String trade = req.getParameter("trade");
                String phone = req.getParameter("phone");
                String email = req.getParameter("email");
                Vendor vendor = new Vendor(0, name, trade, phone, email);
                vendorDAO.create(vendor);
                auditDAO.logAction(adminId, "VENDOR_REGISTERED", "VENDOR", vendor.getId(),
                        "Registered vendor: " + name + " (" + trade + ")");
                resp.sendRedirect(req.getContextPath() + "/admin/vendors?msg=Vendor added successfully.");
            }
            case "/admin/sla" -> {
                String priority = req.getParameter("priority");
                int respondHours = Integer.parseInt(req.getParameter("respondHours"));
                int resolveHours = Integer.parseInt(req.getParameter("resolveHours"));
                String description = req.getParameter("description");

                slaRuleDAO.update(new SlaRule(priority, respondHours, resolveHours, description));
                auditDAO.logAction(adminId, "SLA_RULE_UPDATED", "SLA", null,
                        "Updated SLA for " + priority + " to Resolve: " + resolveHours + "h, Respond: " + respondHours + "h");
                resp.sendRedirect(req.getContextPath() + "/admin/sla?msg=SLA Rule updated for " + priority);
            }
        }
    }
}
