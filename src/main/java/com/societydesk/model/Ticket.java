package com.societydesk.model;

import java.sql.Timestamp;
import java.time.Instant;

public class Ticket {
    private int id;
    private int residentId;
    private int categoryId;
    private String title;
    private String description;
    private String priority; // LOW, MEDIUM, HIGH, CRITICAL
    private String status;   // OPEN, ASSIGNED, IN_PROGRESS, RESOLVED, CLOSED, REOPENED
    private String photoPath;
    private Integer assignedTo;
    private Timestamp slaDeadline;
    private int escalationLevel; // 0, 1, 2, 3
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Timestamp closedAt;

    // Join fields for views
    private String residentName;
    private String residentPhone;
    private String flatBlock;
    private String flatNumber;
    private String categoryName;
    private String assignedToName;
    private String assignedToPhone;

    public Ticket() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getResidentId() { return residentId; }
    public void setResidentId(int residentId) { this.residentId = residentId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPhotoPath() { return photoPath; }
    public void setPhotoPath(String photoPath) { this.photoPath = photoPath; }

    public Integer getAssignedTo() { return assignedTo; }
    public void setAssignedTo(Integer assignedTo) { this.assignedTo = assignedTo; }

    public Timestamp getSlaDeadline() { return slaDeadline; }
    public void setSlaDeadline(Timestamp slaDeadline) { this.slaDeadline = slaDeadline; }

    public int getEscalationLevel() { return escalationLevel; }
    public void setEscalationLevel(int escalationLevel) { this.escalationLevel = escalationLevel; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public Timestamp getClosedAt() { return closedAt; }
    public void setClosedAt(Timestamp closedAt) { this.closedAt = closedAt; }

    public String getResidentName() { return residentName; }
    public void setResidentName(String residentName) { this.residentName = residentName; }

    public String getResidentPhone() { return residentPhone; }
    public void setResidentPhone(String residentPhone) { this.residentPhone = residentPhone; }

    public String getFlatBlock() { return flatBlock; }
    public void setFlatBlock(String flatBlock) { this.flatBlock = flatBlock; }

    public String getFlatNumber() { return flatNumber; }
    public void setFlatNumber(String flatNumber) { this.flatNumber = flatNumber; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getAssignedToName() { return assignedToName; }
    public void setAssignedToName(String assignedToName) { this.assignedToName = assignedToName; }

    public String getAssignedToPhone() { return assignedToPhone; }
    public void setAssignedToPhone(String assignedToPhone) { this.assignedToPhone = assignedToPhone; }

    public String getFormattedFlat() {
        if (flatBlock != null && flatNumber != null) {
            return flatBlock + "-" + flatNumber;
        }
        return "N/A";
    }

    public boolean isOverdue() {
        if ("CLOSED".equalsIgnoreCase(status) || "RESOLVED".equalsIgnoreCase(status)) {
            return false;
        }
        if (slaDeadline == null) {
            return false;
        }
        return slaDeadline.toInstant().isBefore(Instant.now());
    }

    public String getPriorityBadgeClass() {
        if (priority == null) return "bg-secondary";
        return switch (priority.toUpperCase()) {
            case "CRITICAL" -> "bg-danger";
            case "HIGH" -> "bg-warning text-dark";
            case "MEDIUM" -> "bg-info text-dark";
            case "LOW" -> "bg-success";
            default -> "bg-secondary";
        };
    }

    public String getStatusBadgeClass() {
        if (status == null) return "bg-secondary";
        return switch (status.toUpperCase()) {
            case "OPEN" -> "bg-primary";
            case "ASSIGNED" -> "bg-info text-dark";
            case "IN_PROGRESS" -> "bg-warning text-dark";
            case "RESOLVED" -> "bg-success";
            case "CLOSED" -> "bg-secondary";
            case "REOPENED" -> "bg-danger";
            default -> "bg-secondary";
        };
    }
}
