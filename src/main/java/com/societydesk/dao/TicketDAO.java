package com.societydesk.dao;

import com.societydesk.model.Ticket;
import com.societydesk.model.TicketUpdate;
import com.societydesk.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TicketDAO {
    private static final Logger LOGGER = Logger.getLogger(TicketDAO.class.getName());
    private final TicketUpdateDAO updateDAO = new TicketUpdateDAO();

    public boolean create(Ticket ticket) {
        String sql = "INSERT INTO tickets (resident_id, category_id, title, description, priority, status, photo_path, sla_deadline, escalation_level) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, ticket.getResidentId());
            ps.setInt(2, ticket.getCategoryId());
            ps.setString(3, ticket.getTitle());
            ps.setString(4, ticket.getDescription());
            ps.setString(5, ticket.getPriority());
            ps.setString(6, ticket.getStatus() != null ? ticket.getStatus() : "OPEN");
            ps.setString(7, ticket.getPhotoPath());
            ps.setTimestamp(8, ticket.getSlaDeadline());
            ps.setInt(9, ticket.getEscalationLevel());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        ticket.setId(rs.getInt(1));
                    }
                }
                // Record initial update in ticket_updates
                TicketUpdate initial = new TicketUpdate(ticket.getId(), ticket.getResidentId(), null, "OPEN",
                        "Ticket created with priority " + ticket.getPriority(), ticket.getPhotoPath());
                updateDAO.create(initial);
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating ticket", e);
        }
        return false;
    }

    public Ticket findById(int id) {
        String sql = "SELECT t.*, u.name as resident_name, u.phone as resident_phone, " +
                     "f.block as flat_block, f.flat_no as flat_number, " +
                     "c.name as category_name, tech.name as assigned_to_name, tech.phone as assigned_to_phone " +
                     "FROM tickets t " +
                     "JOIN users u ON t.resident_id = u.id " +
                     "LEFT JOIN flats f ON u.flat_id = f.id " +
                     "JOIN categories c ON t.category_id = c.id " +
                     "LEFT JOIN users tech ON t.assigned_to = tech.id " +
                     "WHERE t.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding ticket by id: " + id, e);
        }
        return null;
    }

    public List<Ticket> findByResidentId(int residentId) {
        String sql = baseSelectSql() + " WHERE t.resident_id = ? ORDER BY t.created_at DESC";
        return queryListWithParam(sql, residentId);
    }

    public List<Ticket> findByTechnicianId(int technicianId) {
        String sql = baseSelectSql() + " WHERE t.assigned_to = ? ORDER BY t.sla_deadline ASC";
        return queryListWithParam(sql, technicianId);
    }

    public List<Ticket> findUnassigned() {
        String sql = baseSelectSql() + " WHERE t.assigned_to IS NULL AND t.status = 'OPEN' ORDER BY t.created_at ASC";
        return queryList(sql);
    }

    public List<Ticket> findEscalated() {
        String sql = baseSelectSql() + " WHERE t.escalation_level > 0 AND t.status NOT IN ('RESOLVED', 'CLOSED') ORDER BY t.escalation_level DESC, t.sla_deadline ASC";
        return queryList(sql);
    }

    public List<Ticket> findAll() {
        String sql = baseSelectSql() + " ORDER BY t.created_at DESC";
        return queryList(sql);
    }

    public List<Ticket> findWithFilters(Integer ticketId, String status, Integer categoryId, String priority,
                                        Integer technicianId, Integer escalationLevel, Boolean overdueOnly) {
        StringBuilder sql = new StringBuilder(baseSelectSql());
        sql.append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (ticketId != null && ticketId > 0) {
            sql.append(" AND t.id = ? ");
            params.add(ticketId);
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND t.status = ? ");
            params.add(status);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND t.category_id = ? ");
            params.add(categoryId);
        }
        if (priority != null && !priority.trim().isEmpty() && !"ALL".equalsIgnoreCase(priority)) {
            sql.append(" AND t.priority = ? ");
            params.add(priority);
        }
        if (technicianId != null && technicianId > 0) {
            sql.append(" AND t.assigned_to = ? ");
            params.add(technicianId);
        }
        if (escalationLevel != null && escalationLevel >= 0) {
            sql.append(" AND t.escalation_level = ? ");
            params.add(escalationLevel);
        }
        if (Boolean.TRUE.equals(overdueOnly)) {
            sql.append(" AND t.status NOT IN ('RESOLVED', 'CLOSED') AND t.sla_deadline < NOW() ");
        }

        sql.append(" ORDER BY t.created_at DESC");

        List<Ticket> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findWithFilters", e);
        }
        return list;
    }

    public List<Ticket> findWithFilters(String status, Integer categoryId, String priority, Boolean overdueOnly) {
        return findWithFilters(null, status, categoryId, priority, null, null, overdueOnly);
    }

    /**
     * Transaction: Assign ticket to technician and log update atomically
     */
    public boolean assignTicket(int ticketId, int technicianId, int assignedBy, String note) {
        String updateTicketSql = "UPDATE tickets SET assigned_to = ?, status = 'ASSIGNED' WHERE id = ?";
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            // 1. Fetch current status
            String oldStatus = "OPEN";
            Ticket t = findById(ticketId);
            if (t != null) {
                oldStatus = t.getStatus();
            }

            // 2. Update Ticket
            try (PreparedStatement ps = conn.prepareStatement(updateTicketSql)) {
                ps.setInt(1, technicianId);
                ps.setInt(2, ticketId);
                ps.executeUpdate();
            }

            // 3. Log Update
            TicketUpdate update = new TicketUpdate(ticketId, assignedBy, oldStatus, "ASSIGNED",
                    note != null && !note.trim().isEmpty() ? note : "Ticket assigned to technician", null);
            updateDAO.create(conn, update);

            conn.commit(); // Commit Transaction
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error assigning ticket: rolling back", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Failed rollback on assignTicket", ex);
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
        return false;
    }

    /**
     * Transaction: Update ticket status and record update log
     */
    public boolean updateStatus(int ticketId, int updatedBy, String newStatus, String note, String photoPath) {
        String updateSql = "UPDATE tickets SET status = ?, closed_at = ? WHERE id = ?";
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            Ticket t = findById(ticketId);
            if (t == null) {
                return false;
            }
            String oldStatus = t.getStatus();

            Timestamp closedAt = "CLOSED".equalsIgnoreCase(newStatus) ? Timestamp.valueOf(LocalDateTime.now()) : null;

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, newStatus);
                if (closedAt != null) {
                    ps.setTimestamp(2, closedAt);
                } else {
                    ps.setNull(2, Types.TIMESTAMP);
                }
                ps.setInt(3, ticketId);
                ps.executeUpdate();
            }

            TicketUpdate update = new TicketUpdate(ticketId, updatedBy, oldStatus, newStatus, note, photoPath);
            updateDAO.create(conn, update);

            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating status: rolling back", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Failed rollback on updateStatus", ex);
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
        return false;
    }

    /**
     * Escalation query: find overdue tickets that can be escalated
     */
    public List<Ticket> findOverdueTicketsForEscalation() {
        String sql = baseSelectSql() +
                " WHERE t.status NOT IN ('RESOLVED', 'CLOSED') " +
                " AND t.sla_deadline < NOW() " +
                " AND t.escalation_level < 3";
        return queryList(sql);
    }

    public boolean escalateTicket(int ticketId, int newLevel, String note, int systemUserId) {
        String sql = "UPDATE tickets SET escalation_level = ? WHERE id = ?";
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, newLevel);
                ps.setInt(2, ticketId);
                ps.executeUpdate();
            }

            Ticket t = findById(ticketId);
            String currentStatus = (t != null) ? t.getStatus() : "OPEN";

            TicketUpdate update = new TicketUpdate(ticketId, systemUserId, currentStatus, currentStatus,
                    "[AUTOMATIC ESCALATION] " + note, null);
            updateDAO.create(conn, update);

            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error escalating ticket: " + ticketId, e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback error", ex);
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
        return false;
    }

    // --- Analytics & Reporting Queries ---

    public Map<String, Integer> getStatusCounts() {
        Map<String, Integer> map = new HashMap<>();
        String sql = "SELECT status, COUNT(*) FROM tickets GROUP BY status";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString(1), rs.getInt(2));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting status counts", e);
        }
        return map;
    }

    public Map<String, Integer> getCategoryCounts() {
        Map<String, Integer> map = new HashMap<>();
        String sql = "SELECT c.name, COUNT(t.id) FROM categories c " +
                     "LEFT JOIN tickets t ON c.id = t.category_id " +
                     "GROUP BY c.name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString(1), rs.getInt(2));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting category counts", e);
        }
        return map;
    }

    public double getSlaCompliancePercentage() {
        String sql = "SELECT " +
                     "COUNT(CASE WHEN closed_at <= sla_deadline THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) " +
                     "FROM tickets WHERE status IN ('RESOLVED', 'CLOSED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error calculating SLA compliance", e);
        }
        return 100.0;
    }

    public double getAverageResolutionHours() {
        String sql = "SELECT AVG(TIMESTAMPDIFF(HOUR, created_at, closed_at)) " +
                     "FROM tickets WHERE status IN ('RESOLVED', 'CLOSED') AND closed_at IS NOT NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error calculating average resolution time", e);
        }
        return 0.0;
    }

    private String baseSelectSql() {
        return "SELECT t.*, u.name as resident_name, u.phone as resident_phone, " +
               "f.block as flat_block, f.flat_no as flat_number, " +
               "c.name as category_name, tech.name as assigned_to_name, tech.phone as assigned_to_phone " +
               "FROM tickets t " +
               "JOIN users u ON t.resident_id = u.id " +
               "LEFT JOIN flats f ON u.flat_id = f.id " +
               "JOIN categories c ON t.category_id = c.id " +
               "LEFT JOIN users tech ON t.assigned_to = tech.id ";
    }

    private List<Ticket> queryList(String sql) {
        List<Ticket> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error executing ticket query", e);
        }
        return list;
    }

    private List<Ticket> queryListWithParam(String sql, int param) {
        List<Ticket> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error executing ticket query with param: " + param, e);
        }
        return list;
    }

    private Ticket mapRow(ResultSet rs) throws SQLException {
        Ticket t = new Ticket();
        t.setId(rs.getInt("id"));
        t.setResidentId(rs.getInt("resident_id"));
        t.setCategoryId(rs.getInt("category_id"));
        t.setTitle(rs.getString("title"));
        t.setDescription(rs.getString("description"));
        t.setPriority(rs.getString("priority"));
        t.setStatus(rs.getString("status"));
        t.setPhotoPath(rs.getString("photo_path"));
        int assigned = rs.getInt("assigned_to");
        if (!rs.wasNull()) {
            t.setAssignedTo(assigned);
        }
        t.setSlaDeadline(rs.getTimestamp("sla_deadline"));
        t.setEscalationLevel(rs.getInt("escalation_level"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        t.setUpdatedAt(rs.getTimestamp("updated_at"));
        t.setClosedAt(rs.getTimestamp("closed_at"));

        t.setResidentName(rs.getString("resident_name"));
        t.setResidentPhone(rs.getString("resident_phone"));
        t.setFlatBlock(rs.getString("flat_block"));
        t.setFlatNumber(rs.getString("flat_number"));
        t.setCategoryName(rs.getString("category_name"));
        t.setAssignedToName(rs.getString("assigned_to_name"));
        t.setAssignedToPhone(rs.getString("assigned_to_phone"));
        return t;
    }
}
