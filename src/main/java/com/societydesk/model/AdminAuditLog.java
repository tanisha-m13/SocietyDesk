package com.societydesk.model;

import java.sql.Timestamp;

public class AdminAuditLog {
    private int id;
    private int adminId;
    private String adminName;
    private String action;
    private String targetType;
    private Integer targetId;
    private String details;
    private Timestamp createdAt;

    public AdminAuditLog() {}

    public AdminAuditLog(int adminId, String action, String targetType, Integer targetId, String details) {
        this.adminId = adminId;
        this.action = action;
        this.targetType = targetType;
        this.targetId = targetId;
        this.details = details;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getAdminId() { return adminId; }
    public void setAdminId(int adminId) { this.adminId = adminId; }

    public String getAdminName() { return adminName; }
    public void setAdminName(String adminName) { this.adminName = adminName; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getTargetType() { return targetType; }
    public void setTargetType(String targetType) { this.targetType = targetType; }

    public Integer getTargetId() { return targetId; }
    public void setTargetId(Integer targetId) { this.targetId = targetId; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
