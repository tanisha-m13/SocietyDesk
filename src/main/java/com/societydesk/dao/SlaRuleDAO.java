package com.societydesk.dao;

import com.societydesk.model.SlaRule;
import com.societydesk.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class SlaRuleDAO {
    private static final Logger LOGGER = Logger.getLogger(SlaRuleDAO.class.getName());

    public List<SlaRule> findAll() {
        List<SlaRule> list = new ArrayList<>();
        String sql = "SELECT * FROM sla_rules ORDER BY resolve_hours ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                SlaRule r = new SlaRule();
                r.setPriority(rs.getString("priority"));
                r.setRespondHours(rs.getInt("respond_hours"));
                r.setResolveHours(rs.getInt("resolve_hours"));
                r.setDescription(rs.getString("description"));
                list.add(r);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching SLA rules", e);
        }
        return list;
    }

    public SlaRule findByPriority(String priority) {
        String sql = "SELECT * FROM sla_rules WHERE priority = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, priority);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    SlaRule r = new SlaRule();
                    r.setPriority(rs.getString("priority"));
                    r.setRespondHours(rs.getInt("respond_hours"));
                    r.setResolveHours(rs.getInt("resolve_hours"));
                    r.setDescription(rs.getString("description"));
                    return r;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching SLA rule for priority: " + priority, e);
        }
        return null;
    }

    public boolean update(SlaRule rule) {
        String sql = "UPDATE sla_rules SET respond_hours = ?, resolve_hours = ?, description = ? WHERE priority = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rule.getRespondHours());
            ps.setInt(2, rule.getResolveHours());
            ps.setString(3, rule.getDescription());
            ps.setString(4, rule.getPriority());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating SLA rule: " + rule.getPriority(), e);
        }
        return false;
    }
}
