package com.societydesk.dao;

import com.societydesk.model.Flat;
import com.societydesk.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class FlatDAO {
    private static final Logger LOGGER = Logger.getLogger(FlatDAO.class.getName());

    public List<Flat> findAll() {
        List<Flat> list = new ArrayList<>();
        String sql = "SELECT * FROM flats ORDER BY block ASC, flat_no ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Flat f = new Flat();
                f.setId(rs.getInt("id"));
                f.setBlock(rs.getString("block"));
                f.setFlatNo(rs.getString("flat_no"));
                f.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(f);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching flats", e);
        }
        return list;
    }

    public Flat findById(int id) {
        String sql = "SELECT * FROM flats WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Flat f = new Flat();
                    f.setId(rs.getInt("id"));
                    f.setBlock(rs.getString("block"));
                    f.setFlatNo(rs.getString("flat_no"));
                    f.setCreatedAt(rs.getTimestamp("created_at"));
                    return f;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching flat by id: " + id, e);
        }
        return null;
    }

    public boolean create(Flat flat) {
        String sql = "INSERT INTO flats (block, flat_no) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, flat.getBlock());
            ps.setString(2, flat.getFlatNo());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        flat.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating flat", e);
        }
        return false;
    }
}
