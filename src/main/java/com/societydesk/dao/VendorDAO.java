package com.societydesk.dao;

import com.societydesk.model.Vendor;
import com.societydesk.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class VendorDAO {
    private static final Logger LOGGER = Logger.getLogger(VendorDAO.class.getName());

    public List<Vendor> findAll() {
        List<Vendor> list = new ArrayList<>();
        String sql = "SELECT * FROM vendors ORDER BY name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Vendor v = new Vendor();
                v.setId(rs.getInt("id"));
                v.setName(rs.getString("name"));
                v.setTrade(rs.getString("trade"));
                v.setPhone(rs.getString("phone"));
                v.setEmail(rs.getString("email"));
                v.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(v);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching vendors", e);
        }
        return list;
    }

    public boolean create(Vendor vendor) {
        String sql = "INSERT INTO vendors (name, trade, phone, email) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, vendor.getName());
            ps.setString(2, vendor.getTrade());
            ps.setString(3, vendor.getPhone());
            ps.setString(4, vendor.getEmail());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        vendor.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating vendor", e);
        }
        return false;
    }
}
