package com.societydesk.model;

public class SlaRule {
    private String priority; // LOW, MEDIUM, HIGH, CRITICAL
    private int respondHours;
    private int resolveHours;
    private String description;

    public SlaRule() {}

    public SlaRule(String priority, int respondHours, int resolveHours, String description) {
        this.priority = priority;
        this.respondHours = respondHours;
        this.resolveHours = resolveHours;
        this.description = description;
    }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public int getRespondHours() { return respondHours; }
    public void setRespondHours(int respondHours) { this.respondHours = respondHours; }

    public int getResolveHours() { return resolveHours; }
    public void setResolveHours(int resolveHours) { this.resolveHours = resolveHours; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
