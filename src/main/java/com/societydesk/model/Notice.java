package com.societydesk.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Notice {
    private int id;
    private int postedBy;
    private String title;
    private String body;
    private Date expiresOn;
    private Timestamp createdAt;

    // Join field
    private String postedByName;

    public Notice() {}

    public Notice(int postedBy, String title, String body, Date expiresOn) {
        this.postedBy = postedBy;
        this.title = title;
        this.body = body;
        this.expiresOn = expiresOn;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getPostedBy() { return postedBy; }
    public void setPostedBy(int postedBy) { this.postedBy = postedBy; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }

    public Date getExpiresOn() { return expiresOn; }
    public void setExpiresOn(Date expiresOn) { this.expiresOn = expiresOn; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getPostedByName() { return postedByName; }
    public void setPostedByName(String postedByName) { this.postedByName = postedByName; }
}
