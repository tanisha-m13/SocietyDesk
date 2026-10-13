package com.societydesk.controller;

import com.societydesk.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String role = user.getRole();

        switch (role.toUpperCase()) {
            case "ADMIN" -> resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            case "COMMITTEE" -> resp.sendRedirect(req.getContextPath() + "/committee/dashboard");
            case "TECHNICIAN" -> resp.sendRedirect(req.getContextPath() + "/technician/dashboard");
            case "RESIDENT" -> resp.sendRedirect(req.getContextPath() + "/resident/dashboard");
            default -> resp.sendRedirect(req.getContextPath() + "/login");
        }
    }
}
