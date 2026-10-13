package com.societydesk.filter;

import com.societydesk.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(filterName = "RoleFilter", urlPatterns = {
        "/resident/*",
        "/committee/*",
        "/technician/*",
        "/admin/*"
})
public class RoleFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());
        String role = user.getRole();

        boolean authorized = true;

        if (path.startsWith("/admin") && !"ADMIN".equalsIgnoreCase(role)) {
            authorized = false;
        } else if (path.startsWith("/committee") && !"COMMITTEE".equalsIgnoreCase(role) && !"ADMIN".equalsIgnoreCase(role)) {
            authorized = false;
        } else if (path.startsWith("/technician") && !"TECHNICIAN".equalsIgnoreCase(role) && !"ADMIN".equalsIgnoreCase(role)) {
            authorized = false;
        } else if (path.startsWith("/resident") && !"RESIDENT".equalsIgnoreCase(role) && !"ADMIN".equalsIgnoreCase(role)) {
            authorized = false;
        }

        if (!authorized) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You do not possess the required privileges.");
            return;
        }

        chain.doFilter(request, response);
    }
}
