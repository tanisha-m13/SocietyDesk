package com.societydesk.controller;

import com.societydesk.dao.NoticeDAO;
import com.societydesk.model.Notice;
import com.societydesk.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "NoticeServlet", urlPatterns = {"/notices", "/notices/create", "/notices/delete"})
public class NoticeServlet extends HttpServlet {
    private final NoticeDAO noticeDAO = new NoticeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Notice> notices = noticeDAO.findActiveNotices();
        req.setAttribute("notices", notices);
        req.getRequestDispatcher("/WEB-INF/views/common/notices.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        User user = (User) req.getSession().getAttribute("user");

        if (!"COMMITTEE".equalsIgnoreCase(user.getRole()) && !"ADMIN".equalsIgnoreCase(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only Committee members or Admins can manage notices.");
            return;
        }

        if ("/notices/create".equals(path)) {
            String title = req.getParameter("title");
            String body = req.getParameter("body");
            String expiresOnStr = req.getParameter("expiresOn");

            Date expiresOn = null;
            if (expiresOnStr != null && !expiresOnStr.trim().isEmpty()) {
                expiresOn = Date.valueOf(expiresOnStr);
            }

            Notice notice = new Notice(user.getId(), title, body, expiresOn);
            noticeDAO.create(notice);
            resp.sendRedirect(req.getContextPath() + "/notices?msg=Notice posted successfully.");
        } else if ("/notices/delete".equals(path)) {
            int id = Integer.parseInt(req.getParameter("id"));
            noticeDAO.delete(id);
            resp.sendRedirect(req.getContextPath() + "/notices?msg=Notice removed.");
        }
    }
}
