package com.societydesk.controller;

import com.societydesk.dao.FlatDAO;
import com.societydesk.model.Flat;
import com.societydesk.model.User;
import com.societydesk.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {
    private final AuthService authService = new AuthService();
    private final FlatDAO flatDAO = new FlatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Flat> flats = flatDAO.findAll();
        req.setAttribute("flats", flats);
        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String phone = req.getParameter("phone");
        String role = req.getParameter("role");
        String flatIdStr = req.getParameter("flatId");

        Integer flatId = null;
        if (flatIdStr != null && !flatIdStr.trim().isEmpty()) {
            try {
                flatId = Integer.parseInt(flatIdStr);
            } catch (NumberFormatException ignored) {}
        }

        if (role == null || (!role.equals("RESIDENT") && !role.equals("TECHNICIAN"))) {
            role = "RESIDENT";
        }

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole(role);
        user.setFlatId(flatId);
        user.setStatus("PENDING"); // New accounts require admin approval

        try {
            authService.register(user, password);
            resp.sendRedirect(req.getContextPath() + "/login?msg=Registration successful! Your account is awaiting Admin approval.");
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("user", user);
            req.setAttribute("flats", flatDAO.findAll());
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        }
    }
}
