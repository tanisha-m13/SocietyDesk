package com.societydesk.model;

import java.sql.Timestamp;

public class Rating {
    private int ticketId;
    private int stars;
    private String feedback;
    private Timestamp createdAt;

    public Rating() {}

    public Rating(int ticketId, int stars, String feedback) {
        this.ticketId = ticketId;
        this.stars = stars;
        this.feedback = feedback;
    }

    public int getTicketId() { return ticketId; }
    public void setTicketId(int ticketId) { this.ticketId = ticketId; }

    public int getStars() { return stars; }
    public void setStars(int stars) { this.stars = stars; }

    public String getFeedback() { return feedback; }
    public void setFeedback(String feedback) { this.feedback = feedback; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
