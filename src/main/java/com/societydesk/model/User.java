package com.societydesk.model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String name;
    private String email;
    private String passwordHash;
    private String role;     // RESIDENT, TECHNICIAN, COMMITTEE, ADMIN
    private Integer flatId;
    private String phone;
    private String status;   // PENDING, ACTIVE, REJECTED, INACTIVE
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Supplementary join fields
    private String flatBlock;
    private String flatNumber;

    public User() {}

    public User(String name, String email, String passwordHash, String role, Integer flatId, String phone, String status) {
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.flatId = flatId;
        this.phone = phone;
        this.status = status;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Integer getFlatId() { return flatId; }
    public void setFlatId(Integer flatId) { this.flatId = flatId; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getFlatBlock() { return flatBlock; }
    public void setFlatBlock(String flatBlock) { this.flatBlock = flatBlock; }

    public String getFlatNumber() { return flatNumber; }
    public void setFlatNumber(String flatNumber) { this.flatNumber = flatNumber; }

    public String getFormattedFlat() {
        if (flatBlock != null && flatNumber != null) {
            return flatBlock + "-" + flatNumber;
        }
        return "N/A";
    }

    public boolean isActive() {
        return "ACTIVE".equalsIgnoreCase(this.status);
    }
}
