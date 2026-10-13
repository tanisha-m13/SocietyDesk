package com.societydesk.controller;

import com.societydesk.dao.NotificationDAO;
import com.societydesk.model.Notification;
import com.societydesk.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "NotificationServlet", urlPatterns = {"/notifications", "/notifications/read"})
public class NotificationServlet extends HttpServlet {
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        List<Notification> list = notificationDAO.findByUserId(user.getId(), 50);
        req.setAttribute("notifications", list);
        req.getRequestDispatcher("/WEB-INF/views/common/notifications.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        notificationDAO.markAllAsRead(user.getId());
        resp.sendRedirect(req.getContextPath() + "/notifications?msg=All notifications marked as read.");
    }
}
