package com.societydesk.controller;

import com.google.gson.Gson;
import com.societydesk.service.ReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "ReportServlet", urlPatterns = {
        "/committee/reports",
        "/admin/reports",
        "/api/reports/chart-data"
})
public class ReportServlet extends HttpServlet {
    private final ReportService reportService = new ReportService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/api/reports/chart-data".equals(path)) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");

            Map<String, Object> data = new HashMap<>();
            data.put("statusCounts", reportService.getStatusBreakdown());
            data.put("categoryCounts", reportService.getCategoryBreakdown());
            data.put("metrics", reportService.getDashboardMetrics());

            resp.getWriter().write(gson.toJson(data));
            return;
        }

        Map<String, Object> metrics = reportService.getDashboardMetrics();
        req.setAttribute("metrics", metrics);
        req.getRequestDispatcher("/WEB-INF/views/common/reports.jsp").forward(req, resp);
    }
}
