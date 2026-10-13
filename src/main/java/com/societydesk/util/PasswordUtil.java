package com.societydesk.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility for hashing and verifying passwords using BCrypt.
 */
public class PasswordUtil {

    private PasswordUtil() {
        // Prevent instantiation
    }

    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.trim().isEmpty()) {
            throw new IllegalArgumentException("Password cannot be empty");
        }
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
    }

    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (Exception e) {
            return false;
        }
    }
}
