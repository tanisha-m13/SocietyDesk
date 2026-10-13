package com.societydesk.model;

import java.sql.Timestamp;

public class Notification {
    private int id;
    private int userId;
    private Integer ticketId;
    private String message;
    private boolean isRead;
    private Timestamp createdAt;

    public Notification() {}

    public Notification(int userId, Integer ticketId, String message) {
        this.userId = userId;
        this.ticketId = ticketId;
        this.message = message;
        this.isRead = false;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Integer getTicketId() { return ticketId; }
    public void setTicketId(Integer ticketId) { this.ticketId = ticketId; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean isRead) { this.isRead = isRead; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
