package com.societydesk.dao;

import com.societydesk.model.Rating;
import com.societydesk.util.DBConnection;

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class RatingDAO {
    private static final Logger LOGGER = Logger.getLogger(RatingDAO.class.getName());

    public Rating findByTicketId(int ticketId) {
        String sql = "SELECT * FROM ratings WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Rating r = new Rating();
                    r.setTicketId(rs.getInt("ticket_id"));
                    r.setStars(rs.getInt("stars"));
                    r.setFeedback(rs.getString("feedback"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    return r;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching rating for ticket: " + ticketId, e);
        }
        return null;
    }

    public boolean create(Rating rating) {
        String sql = "INSERT INTO ratings (ticket_id, stars, feedback) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rating.getTicketId());
            ps.setInt(2, rating.getStars());
            ps.setString(3, rating.getFeedback());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error saving rating", e);
        }
        return false;
    }

    public double getAverageRating() {
        String sql = "SELECT AVG(stars) FROM ratings";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error calculating average rating", e);
        }
        return 0.0;
    }
}
