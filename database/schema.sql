-- ==============================================================
-- SocietyDesk: Database Schema Definition
-- Target DBMS: MySQL 8.0+
-- Database: societydesk_db
-- ==============================================================

CREATE DATABASE IF NOT EXISTS societydesk_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE societydesk_db;

-- 1. Drop existing tables in reverse dependency order
DROP TABLE IF EXISTS admin_audit_logs;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS notices;
DROP TABLE IF EXISTS ticket_updates;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS sla_rules;
DROP TABLE IF EXISTS vendors;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS flats;
DROP TABLE IF EXISTS categories;

-- 2. Flats table
CREATE TABLE flats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    block VARCHAR(20) NOT NULL,
    flat_no VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_block_flat UNIQUE (block, flat_no)
) ENGINE=InnoDB;

-- 3. Users table
-- Roles: RESIDENT, TECHNICIAN, COMMITTEE, ADMIN
-- Status: PENDING, ACTIVE, REJECTED, INACTIVE
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('RESIDENT', 'TECHNICIAN', 'COMMITTEE', 'ADMIN') NOT NULL DEFAULT 'RESIDENT',
    flat_id INT NULL,
    phone VARCHAR(20) NULL,
    status ENUM('PENDING', 'ACTIVE', 'REJECTED', 'INACTIVE') NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_flat FOREIGN KEY (flat_id) REFERENCES flats(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 4. Categories table
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 5. Vendors table (Service Providers / Contractors)
CREATE TABLE vendors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    trade VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(120) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 6. SLA Rules table
-- Priority: LOW, MEDIUM, HIGH, CRITICAL
CREATE TABLE sla_rules (
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') PRIMARY KEY,
    respond_hours INT NOT NULL,
    resolve_hours INT NOT NULL,
    description VARCHAR(255) NULL
) ENGINE=InnoDB;

-- 7. Tickets table
-- Status: OPEN, ASSIGNED, IN_PROGRESS, RESOLVED, CLOSED, REOPENED
-- Escalation Level: 0 (Normal), 1 (Level 1 Escalated), 2 (Level 2 Escalated), 3 (Max Escalated)
CREATE TABLE tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    resident_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') NOT NULL DEFAULT 'MEDIUM',
    status ENUM('OPEN', 'ASSIGNED', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REOPENED') NOT NULL DEFAULT 'OPEN',
    photo_path VARCHAR(255) NULL,
    assigned_to INT NULL,
    sla_deadline DATETIME NOT NULL,
    escalation_level TINYINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    closed_at DATETIME NULL,
    CONSTRAINT fk_tickets_resident FOREIGN KEY (resident_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_tickets_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    CONSTRAINT fk_tickets_assigned_to FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Index for SLA escalation background queries
CREATE INDEX idx_tickets_sla ON tickets(status, sla_deadline);
CREATE INDEX idx_tickets_resident ON tickets(resident_id);
CREATE INDEX idx_tickets_assigned ON tickets(assigned_to);
CREATE INDEX idx_tickets_status ON tickets(status);

-- 8. Ticket Updates table (Full audit trail and lifecycle history)
CREATE TABLE ticket_updates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    updated_by INT NOT NULL,
    old_status ENUM('OPEN', 'ASSIGNED', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REOPENED') NULL,
    new_status ENUM('OPEN', 'ASSIGNED', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REOPENED') NOT NULL,
    note TEXT NOT NULL,
    photo_path VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_updates_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    CONSTRAINT fk_updates_user FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_ticket_updates_ticket ON ticket_updates(ticket_id);

-- 9. Notices table (Announcements by Committee / Admin)
CREATE TABLE notices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    posted_by INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    expires_on DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notices_user FOREIGN KEY (posted_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_notices_expires ON notices(expires_on);

-- 10. Notifications table (In-app real-time alerts)
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    ticket_id INT NULL,
    message VARCHAR(300) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_notifications_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read);

-- 11. Ratings table (Resident feedback upon ticket resolution)
CREATE TABLE ratings (
    ticket_id INT PRIMARY KEY,
    stars TINYINT NOT NULL CHECK (stars BETWEEN 1 AND 5),
    feedback TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ratings_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 12. Admin & System Audit Logs
CREATE TABLE admin_audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    action VARCHAR(50) NOT NULL,
    target_type VARCHAR(50) NOT NULL,
    target_id INT NULL,
    details TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_admin FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_admin_audit_created ON admin_audit_logs(created_at);
