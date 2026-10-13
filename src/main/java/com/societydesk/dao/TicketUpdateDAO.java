package com.societydesk.dao;

import com.societydesk.model.TicketUpdate;
import com.societydesk.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TicketUpdateDAO {
    private static final Logger LOGGER = Logger.getLogger(TicketUpdateDAO.class.getName());

    public List<TicketUpdate> findByTicketId(int ticketId) {
        List<TicketUpdate> list = new ArrayList<>();
        String sql = "SELECT tu.*, u.name as updater_name, u.role as updater_role " +
                     "FROM ticket_updates tu " +
                     "JOIN users u ON tu.updated_by = u.id " +
                     "WHERE tu.ticket_id = ? " +
                     "ORDER BY tu.created_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TicketUpdate u = new TicketUpdate();
                    u.setId(rs.getInt("id"));
                    u.setTicketId(rs.getInt("ticket_id"));
                    u.setUpdatedBy(rs.getInt("updated_by"));
                    u.setOldStatus(rs.getString("old_status"));
                    u.setNewStatus(rs.getString("new_status"));
                    u.setNote(rs.getString("note"));
                    u.setPhotoPath(rs.getString("photo_path"));
                    u.setCreatedAt(rs.getTimestamp("created_at"));
                    u.setUpdaterName(rs.getString("updater_name"));
                    u.setUpdaterRole(rs.getString("updater_role"));
                    list.add(u);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching updates for ticket: " + ticketId, e);
        }
        return list;
    }

    public boolean create(Connection conn, TicketUpdate update) throws SQLException {
        String sql = "INSERT INTO ticket_updates (ticket_id, updated_by, old_status, new_status, note, photo_path) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, update.getTicketId());
            ps.setInt(2, update.getUpdatedBy());
            ps.setString(3, update.getOldStatus());
            ps.setString(4, update.getNewStatus());
            ps.setString(5, update.getNote());
            ps.setString(6, update.getPhotoPath());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        update.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }

    public boolean create(TicketUpdate update) {
        try (Connection conn = DBConnection.getConnection()) {
            return create(conn, update);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error logging standalone ticket update", e);
        }
        return false;
    }
}
