package com.societydesk.dao;

import com.societydesk.model.Notice;
import com.societydesk.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NoticeDAO {
    private static final Logger LOGGER = Logger.getLogger(NoticeDAO.class.getName());

    public List<Notice> findActiveNotices() {
        List<Notice> list = new ArrayList<>();
        String sql = "SELECT n.*, u.name as posted_by_name " +
                     "FROM notices n " +
                     "JOIN users u ON n.posted_by = u.id " +
                     "WHERE n.expires_on IS NULL OR n.expires_on >= CURRENT_DATE() " +
                     "ORDER BY n.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching active notices", e);
        }
        return list;
    }

    public List<Notice> findAll() {
        List<Notice> list = new ArrayList<>();
        String sql = "SELECT n.*, u.name as posted_by_name " +
                     "FROM notices n " +
                     "JOIN users u ON n.posted_by = u.id " +
                     "ORDER BY n.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all notices", e);
        }
        return list;
    }

    public boolean create(Notice notice) {
        String sql = "INSERT INTO notices (posted_by, title, body, expires_on) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, notice.getPostedBy());
            ps.setString(2, notice.getTitle());
            ps.setString(3, notice.getBody());
            if (notice.getExpiresOn() != null) {
                ps.setDate(4, notice.getExpiresOn());
            } else {
                ps.setNull(4, Types.DATE);
            }
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        notice.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating notice", e);
        }
        return false;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM notices WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting notice: " + id, e);
        }
        return false;
    }

    private Notice mapRow(ResultSet rs) throws SQLException {
        Notice n = new Notice();
        n.setId(rs.getInt("id"));
        n.setPostedBy(rs.getInt("posted_by"));
        n.setTitle(rs.getString("title"));
        n.setBody(rs.getString("body"));
        n.setExpiresOn(rs.getDate("expires_on"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        n.setPostedByName(rs.getString("posted_by_name"));
        return n;
    }
}
