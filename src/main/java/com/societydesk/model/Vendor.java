package com.societydesk.model;

import java.sql.Timestamp;

public class Vendor {
    private int id;
    private String name;
    private String trade;
    private String phone;
    private String email;
    private Timestamp createdAt;

    public Vendor() {}

    public Vendor(int id, String name, String trade, String phone, String email) {
        this.id = id;
        this.name = name;
        this.trade = trade;
        this.phone = phone;
        this.email = email;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getTrade() { return trade; }
    public void setTrade(String trade) { this.trade = trade; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
