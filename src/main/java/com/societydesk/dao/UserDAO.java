package com.societydesk.dao;

import com.societydesk.model.User;
import com.societydesk.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public User findByEmail(String email) {
        String sql = "SELECT u.*, f.block, f.flat_no " +
                     "FROM users u " +
                     "LEFT JOIN flats f ON u.flat_id = f.id " +
                     "WHERE LOWER(u.email) = LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findByEmail: " + email, e);
        }
        return null;
    }

    public User findById(int id) {
        String sql = "SELECT u.*, f.block, f.flat_no " +
                     "FROM users u " +
                     "LEFT JOIN flats f ON u.flat_id = f.id " +
                     "WHERE u.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findById: " + id, e);
        }
        return null;
    }

    public boolean create(User user) {
        String sql = "INSERT INTO users (name, email, password_hash, role, flat_id, phone, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getRole());
            if (user.getFlatId() != null && user.getFlatId() > 0) {
                ps.setInt(5, user.getFlatId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            ps.setString(6, user.getPhone());
            ps.setString(7, user.getStatus());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        user.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating user: " + user.getEmail(), e);
        }
        return false;
    }

    public boolean updateStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating status for user id: " + userId, e);
        }
        return false;
    }

    public List<User> findPendingUsers() {
        String sql = "SELECT u.*, f.block, f.flat_no " +
                     "FROM users u " +
                     "LEFT JOIN flats f ON u.flat_id = f.id " +
                     "WHERE u.status = 'PENDING' ORDER BY u.created_at DESC";
        return queryList(sql);
    }

    public List<User> findByRole(String role) {
        String sql = "SELECT u.*, f.block, f.flat_no " +
                     "FROM users u " +
                     "LEFT JOIN flats f ON u.flat_id = f.id " +
                     "WHERE u.role = ? AND u.status = 'ACTIVE' ORDER BY u.name ASC";
        List<User> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findByRole: " + role, e);
        }
        return list;
    }

    public List<User> findAll() {
        String sql = "SELECT u.*, f.block, f.flat_no " +
                     "FROM users u " +
                     "LEFT JOIN flats f ON u.flat_id = f.id " +
                     "ORDER BY u.id DESC";
        return queryList(sql);
    }

    public int countTotalUsers() {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting users", e);
        }
        return 0;
    }

    private List<User> queryList(String sql) {
        List<User> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error executing user query", e);
        }
        return list;
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setName(rs.getString("name"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setRole(rs.getString("role"));
        int fId = rs.getInt("flat_id");
        if (!rs.wasNull()) {
            u.setFlatId(fId);
        }
        u.setPhone(rs.getString("phone"));
        u.setStatus(rs.getString("status"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        u.setUpdatedAt(rs.getTimestamp("updated_at"));
        u.setFlatBlock(rs.getString("block"));
        u.setFlatNumber(rs.getString("flat_no"));
        return u;
    }
}
