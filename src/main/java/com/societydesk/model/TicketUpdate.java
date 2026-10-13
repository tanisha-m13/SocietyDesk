package com.societydesk.model;

import java.sql.Timestamp;

public class TicketUpdate {
    private int id;
    private int ticketId;
    private int updatedBy;
    private String oldStatus;
    private String newStatus;
    private String note;
    private String photoPath;
    private Timestamp createdAt;

    // Join fields
    private String updaterName;
    private String updaterRole;

    public TicketUpdate() {}

    public TicketUpdate(int ticketId, int updatedBy, String oldStatus, String newStatus, String note, String photoPath) {
        this.ticketId = ticketId;
        this.updatedBy = updatedBy;
        this.oldStatus = oldStatus;
        this.newStatus = newStatus;
        this.note = note;
        this.photoPath = photoPath;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getTicketId() { return ticketId; }
    public void setTicketId(int ticketId) { this.ticketId = ticketId; }

    public int getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(int updatedBy) { this.updatedBy = updatedBy; }

    public String getOldStatus() { return oldStatus; }
    public void setOldStatus(String oldStatus) { this.oldStatus = oldStatus; }

    public String getNewStatus() { return newStatus; }
    public void setNewStatus(String newStatus) { this.newStatus = newStatus; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getPhotoPath() { return photoPath; }
    public void setPhotoPath(String photoPath) { this.photoPath = photoPath; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getUpdaterName() { return updaterName; }
    public void setUpdaterName(String updaterName) { this.updaterName = updaterName; }

    public String getUpdaterRole() { return updaterRole; }
    public void setUpdaterRole(String updaterRole) { this.updaterRole = updaterRole; }
}
