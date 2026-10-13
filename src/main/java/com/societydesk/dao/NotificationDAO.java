package com.societydesk.dao;

import com.societydesk.model.Notification;
import com.societydesk.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NotificationDAO {
    private static final Logger LOGGER = Logger.getLogger(NotificationDAO.class.getName());

    public List<Notification> findByUserId(int userId, int limit) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching notifications for user: " + userId, e);
        }
        return list;
    }

    public int countUnread(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = FALSE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting unread notifications", e);
        }
        return 0;
    }

    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE user_id = ? AND is_read = FALSE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error marking notifications as read", e);
        }
        return false;
    }

    public boolean create(Notification notif) {
        String sql = "INSERT INTO notifications (user_id, ticket_id, message, is_read) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, notif.getUserId());
            if (notif.getTicketId() != null) {
                ps.setInt(2, notif.getTicketId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, notif.getMessage());
            ps.setBoolean(4, notif.isRead());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating notification", e);
        }
        return false;
    }

    public void notifyRoleUsers(String role, Integer ticketId, String message) {
        String sql = "INSERT INTO notifications (user_id, ticket_id, message) " +
                     "SELECT id, ?, ? FROM users WHERE role = ? AND status = 'ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (ticketId != null) {
                ps.setInt(1, ticketId);
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, message);
            ps.setString(3, role);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error notifying role: " + role, e);
        }
    }

    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserId(rs.getInt("user_id"));
        int tId = rs.getInt("ticket_id");
        if (!rs.wasNull()) {
            n.setTicketId(tId);
        }
        n.setMessage(rs.getString("message"));
        n.setRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }
}
