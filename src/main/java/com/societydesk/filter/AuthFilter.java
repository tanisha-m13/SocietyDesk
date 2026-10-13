package com.societydesk.filter;

import com.societydesk.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {
        "/resident/*",
        "/committee/*",
        "/technician/*",
        "/admin/*",
        "/ticket/*",
        "/notices/*",
        "/notifications/*",
        "/dashboard"
})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            String targetUri = httpRequest.getRequestURI();
            String contextPath = httpRequest.getContextPath();
            httpResponse.sendRedirect(contextPath + "/login?error=Please log in to access this page.");
            return;
        }

        // Set common attributes for views if not present
        httpRequest.setAttribute("currentUser", user);

        chain.doFilter(request, response);
    }
}
