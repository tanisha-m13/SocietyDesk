package com.societydesk.service;

import com.societydesk.dao.UserDAO;
import com.societydesk.model.User;
import com.societydesk.util.PasswordUtil;

import java.util.logging.Logger;

public class AuthService {
    private static final Logger LOGGER = Logger.getLogger(AuthService.class.getName());
    private final UserDAO userDAO = new UserDAO();

    public User login(String email, String plainPassword) throws Exception {
        if (email == null || email.trim().isEmpty() || plainPassword == null || plainPassword.isEmpty()) {
            throw new IllegalArgumentException("Email and password are required.");
        }

        User user = userDAO.findByEmail(email.trim());
        if (user == null) {
            throw new Exception("Invalid email or password.");
        }

        if (!PasswordUtil.checkPassword(plainPassword, user.getPasswordHash())) {
            throw new Exception("Invalid email or password.");
        }

        if ("PENDING".equalsIgnoreCase(user.getStatus())) {
            throw new Exception("Your account is pending approval by the Society Admin.");
        }

        if ("REJECTED".equalsIgnoreCase(user.getStatus()) || "INACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new Exception("Your account has been deactivated or rejected. Please contact the society office.");
        }

        return user;
    }

    public boolean register(User user, String plainPassword) throws Exception {
        if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email address is required.");
        }

        User existing = userDAO.findByEmail(user.getEmail().trim());
        if (existing != null) {
            throw new Exception("An account with this email address already exists.");
        }

        if (plainPassword == null || plainPassword.length() < 6) {
            throw new IllegalArgumentException("Password must be at least 6 characters long.");
        }

        user.setPasswordHash(PasswordUtil.hashPassword(plainPassword));
        if (user.getStatus() == null) {
            user.setStatus("PENDING");
        }

        return userDAO.create(user);
    }
}
