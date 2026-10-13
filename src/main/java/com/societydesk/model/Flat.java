package com.societydesk.model;

import java.sql.Timestamp;

public class Flat {
    private int id;
    private String block;
    private String flatNo;
    private Timestamp createdAt;

    public Flat() {}

    public Flat(int id, String block, String flatNo) {
        this.id = id;
        this.block = block;
        this.flatNo = flatNo;
    }

    public Flat(String block, String flatNo) {
        this.block = block;
        this.flatNo = flatNo;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getBlock() { return block; }
    public void setBlock(String block) { this.block = block; }

    public String getFlatNo() { return flatNo; }
    public void setFlatNo(String flatNo) { this.flatNo = flatNo; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getFormatted() {
        return block + "-" + flatNo;
    }
}
