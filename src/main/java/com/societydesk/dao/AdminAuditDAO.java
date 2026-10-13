package com.societydesk.dao;

import com.societydesk.model.AdminAuditLog;
import com.societydesk.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AdminAuditDAO {
    private static final Logger LOGGER = Logger.getLogger(AdminAuditDAO.class.getName());

    public boolean logAction(int adminId, String action, String targetType, Integer targetId, String details) {
        String sql = "INSERT INTO admin_audit_logs (admin_id, action, target_type, target_id, details) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, adminId);
            ps.setString(2, action);
            ps.setString(3, targetType);
            if (targetId != null) {
                ps.setInt(4, targetId);
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            ps.setString(5, details);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error inserting admin audit log", e);
        }
        return false;
    }

    public List<AdminAuditLog> findRecent(int limit) {
        List<AdminAuditLog> list = new ArrayList<>();
        String sql = "SELECT a.*, u.name as admin_name FROM admin_audit_logs a " +
                     "JOIN users u ON a.admin_id = u.id " +
                     "ORDER BY a.created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AdminAuditLog log = new AdminAuditLog();
                    log.setId(rs.getInt("id"));
                    log.setAdminId(rs.getInt("admin_id"));
                    log.setAdminName(rs.getString("admin_name"));
                    log.setAction(rs.getString("action"));
                    log.setTargetType(rs.getString("target_type"));
                    int targetId = rs.getInt("target_id");
                    if (!rs.wasNull()) {
                        log.setTargetId(targetId);
                    }
                    log.setDetails(rs.getString("details"));
                    log.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching admin audit logs", e);
        }
        return list;
    }
}
