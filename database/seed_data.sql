-- ==============================================================
-- SocietyDesk: Comprehensive Demo Seed Data
-- ==============================================================

USE societydesk_db;

-- 1. Ensure Categories exist
INSERT IGNORE INTO categories (id, name, description) VALUES
(1, 'Plumbing', 'Water leakage, pipe blocks, tap repair, drainage issues'),
(2, 'Electrical', 'Power tripping, wiring faults, switchboard issues, lights'),
(3, 'Elevator / Lift', 'Lift breakdown, abnormal sound, door stuck, display issues'),
(4, 'Carpentry', 'Door alignment, lock replacement, window mesh, woodwork'),
(5, 'Housekeeping & Sanitation', 'Garbage collection, corridor cleaning, pest control'),
(6, 'Security', 'Gate security, intercom malfunction, CCTV issues, visitor parking');

-- 2. Additional Users (Password for all: Password@123)
-- BCrypt Hash: $2a$12$mspbTPzBdy6OLFBlLNCXquTU0N56.53pFMOzekepbF2wp6IP34NwO
INSERT IGNORE INTO users (id, name, email, password_hash, role, flat_id, phone, status) VALUES
(6, 'Ramesh Patel (Plumber)', 'plumber@societydesk.com', '$2a$12$mspbTPzBdy6OLFBlLNCXquTU0N56.53pFMOzekepbF2wp6IP34NwO', 'TECHNICIAN', NULL, '9876500010', 'ACTIVE'),
(7, 'Vikram Joshi (Lift Tech)', 'lifttech@societydesk.com', '$2a$12$mspbTPzBdy6OLFBlLNCXquTU0N56.53pFMOzekepbF2wp6IP34NwO', 'TECHNICIAN', NULL, '9876500011', 'ACTIVE'),
(8, 'Rohan Mehta', 'rohan@societydesk.com', '$2a$12$mspbTPzBdy6OLFBlLNCXquTU0N56.53pFMOzekepbF2wp6IP34NwO', 'RESIDENT', 2, '9876500021', 'ACTIVE'),
(9, 'Priya Sen', 'priya@societydesk.com', '$2a$12$mspbTPzBdy6OLFBlLNCXquTU0N56.53pFMOzekepbF2wp6IP34NwO', 'RESIDENT', 3, '9876500022', 'ACTIVE'),
(10, 'Deepak Nair (New Buyer)', 'deepak@societydesk.com', '$2a$12$mspbTPzBdy6OLFBlLNCXquTU0N56.53pFMOzekepbF2wp6IP34NwO', 'RESIDENT', 4, '9876500023', 'PENDING');

-- 3. Clear existing demo tickets & updates if any, then insert structured tickets
DELETE FROM ratings;
DELETE FROM notifications;
DELETE FROM ticket_updates;
DELETE FROM tickets;

-- Ticket 1: OPEN (Unassigned, fresh complaint by Ananya Verma)
INSERT INTO tickets (id, resident_id, category_id, title, description, priority, status, photo_path, assigned_to, sla_deadline, escalation_level, created_at)
VALUES (1, 4, 1, 'Ceiling Seepage in Guest Bedroom', 'Persistent dampness and dripping water observed along the exterior corner of bedroom ceiling.', 'HIGH', 'OPEN', NULL, NULL, DATE_ADD(NOW(), INTERVAL 10 HOUR), 0, DATE_SUB(NOW(), INTERVAL 2 HOUR));

-- Ticket 2: ASSIGNED (Corridor lighting assigned to Suresh Kumar)
INSERT INTO tickets (id, resident_id, category_id, title, description, priority, status, photo_path, assigned_to, sla_deadline, escalation_level, created_at)
VALUES (2, 8, 2, 'Corridor Lighting Tripping on 2nd Floor', 'The entire second-floor common passage lights trip whenever the timer switches on in the evening.', 'MEDIUM', 'ASSIGNED', NULL, 3, DATE_ADD(NOW(), INTERVAL 16 HOUR), 0, DATE_SUB(NOW(), INTERVAL 4 HOUR));

-- Ticket 3: IN_PROGRESS (Carpentry work underway by Suresh Kumar)
INSERT INTO tickets (id, resident_id, category_id, title, description, priority, status, photo_path, assigned_to, sla_deadline, escalation_level, created_at)
VALUES (3, 9, 4, 'Main Safety Grille Door Latch Jammed', 'The safety grille door lock deadbolt is sticking and cannot be opened from the outside without excessive force.', 'MEDIUM', 'IN_PROGRESS', NULL, 3, DATE_ADD(NOW(), INTERVAL 12 HOUR), 0, DATE_SUB(NOW(), INTERVAL 6 HOUR));

-- Ticket 4: RESOLVED (Ready for Resident Verification & Rating!)
INSERT INTO tickets (id, resident_id, category_id, title, description, priority, status, photo_path, assigned_to, sla_deadline, escalation_level, created_at)
VALUES (4, 4, 2, 'Master Bathroom Exhaust Fan Sparking', 'Exhaust fan made abnormal rattling noise and showed sparks when powered on.', 'HIGH', 'RESOLVED', NULL, 3, DATE_ADD(NOW(), INTERVAL 4 HOUR), 0, DATE_SUB(NOW(), INTERVAL 8 HOUR));

-- Ticket 5: CLOSED & RATED (5 Stars Satisfaction)
INSERT INTO tickets (id, resident_id, category_id, title, description, priority, status, photo_path, assigned_to, sla_deadline, escalation_level, created_at, closed_at)
VALUES (5, 8, 1, 'Kitchen Sink Drain Clogged', 'Water overflowing from kitchen sink drain pipe below the counter basin.', 'MEDIUM', 'CLOSED', NULL, 6, DATE_SUB(NOW(), INTERVAL 1 DAY), 0, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY));

-- Ticket 6: CLOSED & RATED (4 Stars Satisfaction)
INSERT INTO tickets (id, resident_id, category_id, title, description, priority, status, photo_path, assigned_to, sla_deadline, escalation_level, created_at, closed_at)
VALUES (6, 9, 5, 'Litter in Wing A Basement Lift Lobby', 'Discarded packing boxes and debris left unattended near the basement lift entrance.', 'LOW', 'CLOSED', NULL, 3, DATE_SUB(NOW(), INTERVAL 2 DAY), 0, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY));

-- Ticket 7: REOPENED (Issue Not Fixed - Resident Rejected Resolution)
INSERT INTO tickets (id, resident_id, category_id, title, description, priority, status, photo_path, assigned_to, sla_deadline, escalation_level, created_at)
VALUES (7, 8, 3, 'Lift B Jerking and Display Malfunction', 'Elevator B jerks noticeably when stopping at floor 3 and the floor indicator display is blank.', 'HIGH', 'REOPENED', NULL, 7, DATE_ADD(NOW(), INTERVAL 8 HOUR), 0, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- Ticket 8: OVERDUE & ESCALATED (Level 1 Supervisor Escalation)
INSERT INTO tickets (id, resident_id, category_id, title, description, priority, status, photo_path, assigned_to, sla_deadline, escalation_level, created_at)
VALUES (8, 4, 6, 'Main Gate Intercom Audio Distorted', 'Security guard intercom phone has heavy static buzz and cannot hear incoming flat calls.', 'HIGH', 'ASSIGNED', NULL, 3, DATE_SUB(NOW(), INTERVAL 4 HOUR), 1, DATE_SUB(NOW(), INTERVAL 16 HOUR));

-- Ticket 9: OVERDUE & ESCALATED (Level 2 Executive Committee Escalation!)
INSERT INTO tickets (id, resident_id, category_id, title, description, priority, status, photo_path, assigned_to, sla_deadline, escalation_level, created_at)
VALUES (9, 9, 1, 'Overhead Water Tank Float Valve Leakage', 'Water overflowing continuously from rooftop tank into the building storm drain.', 'CRITICAL', 'IN_PROGRESS', NULL, 6, DATE_SUB(NOW(), INTERVAL 8 HOUR), 2, DATE_SUB(NOW(), INTERVAL 20 HOUR));

-- 4. Ratings for Closed Tickets
INSERT INTO ratings (ticket_id, stars, feedback, created_at) VALUES
(5, 5, 'Technician Ramesh arrived within 2 hours with all plumbing tools and cleared the line cleanly. Excellent job!', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(6, 4, 'Resolved in a timely manner. Good cleanup of the basement corridor.', DATE_SUB(NOW(), INTERVAL 2 DAY));

-- 5. Ticket Update Audit History
INSERT INTO ticket_updates (ticket_id, updated_by, old_status, new_status, note, photo_path, created_at) VALUES
(1, 4, NULL, 'OPEN', 'Ticket registered by resident Ananya Verma (Flat A-101) with priority HIGH.', NULL, DATE_SUB(NOW(), INTERVAL 2 HOUR)),

(2, 8, NULL, 'OPEN', 'Ticket registered by resident Rohan Mehta (Flat A-102).', NULL, DATE_SUB(NOW(), INTERVAL 4 HOUR)),
(2, 2, 'OPEN', 'ASSIGNED', 'Assigned to Suresh Kumar for evening inspection of MCB panel.', NULL, DATE_SUB(NOW(), INTERVAL 3 HOUR)),

(3, 9, NULL, 'OPEN', 'Ticket registered by resident Priya Sen (Flat A-201).', NULL, DATE_SUB(NOW(), INTERVAL 6 HOUR)),
(3, 2, 'OPEN', 'ASSIGNED', 'Assigned to technician Suresh Kumar.', NULL, DATE_SUB(NOW(), INTERVAL 5 HOUR)),
(3, 3, 'ASSIGNED', 'IN_PROGRESS', 'Inspection completed; applying lubricant and realigning strike plate.', NULL, DATE_SUB(NOW(), INTERVAL 2 HOUR)),

(4, 4, NULL, 'OPEN', 'Ticket registered by resident Ananya Verma.', NULL, DATE_SUB(NOW(), INTERVAL 8 HOUR)),
(4, 2, 'OPEN', 'ASSIGNED', 'Assigned to Suresh Kumar.', NULL, DATE_SUB(NOW(), INTERVAL 7 HOUR)),
(4, 3, 'ASSIGNED', 'IN_PROGRESS', 'Technician dismantling motor housing.', NULL, DATE_SUB(NOW(), INTERVAL 5 HOUR)),
(4, 3, 'IN_PROGRESS', 'RESOLVED', 'Replaced faulty capacitor and internal wiring harness. Tested unit for 15 minutes, functioning normally.', NULL, DATE_SUB(NOW(), INTERVAL 1 HOUR)),

(5, 8, NULL, 'OPEN', 'Ticket created.', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 2, 'OPEN', 'ASSIGNED', 'Assigned to Ramesh Patel.', NULL, DATE_SUB(NOW(), INTERVAL 36 HOUR)),
(5, 6, 'ASSIGNED', 'IN_PROGRESS', 'Clearing drainage trap with auger.', NULL, DATE_SUB(NOW(), INTERVAL 30 HOUR)),
(5, 6, 'IN_PROGRESS', 'RESOLVED', 'Cleared blockage and tested water flow.', NULL, DATE_SUB(NOW(), INTERVAL 26 HOUR)),
(5, 8, 'RESOLVED', 'CLOSED', 'Resident verified kitchen drainage. Service approved.', NULL, DATE_SUB(NOW(), INTERVAL 24 HOUR)),

(7, 8, NULL, 'OPEN', 'Ticket created.', NULL, DATE_SUB(NOW(), INTERVAL 28 HOUR)),
(7, 2, 'OPEN', 'ASSIGNED', 'Assigned to Vikram Joshi.', NULL, DATE_SUB(NOW(), INTERVAL 24 HOUR)),
(7, 7, 'ASSIGNED', 'IN_PROGRESS', 'Reset controller panel.', NULL, DATE_SUB(NOW(), INTERVAL 18 HOUR)),
(7, 7, 'IN_PROGRESS', 'RESOLVED', 'Controller recalibrated.', NULL, DATE_SUB(NOW(), INTERVAL 10 HOUR)),
(7, 8, 'RESOLVED', 'REOPENED', 'Issue persisted: Lift still jerked heavily when stopping at 3rd floor this morning.', NULL, DATE_SUB(NOW(), INTERVAL 3 HOUR)),

(8, 4, NULL, 'OPEN', 'Ticket created.', NULL, DATE_SUB(NOW(), INTERVAL 16 HOUR)),
(8, 2, 'OPEN', 'ASSIGNED', 'Assigned to Suresh Kumar.', NULL, DATE_SUB(NOW(), INTERVAL 14 HOUR)),
(8, 1, 'ASSIGNED', 'ASSIGNED', '[AUTOMATIC ESCALATION] Ticket missed SLA deadline of 12 hours. Escalated to Level 1 (Supervisor Alert).', NULL, DATE_SUB(NOW(), INTERVAL 4 HOUR)),

(9, 9, NULL, 'OPEN', 'Ticket created with priority CRITICAL.', NULL, DATE_SUB(NOW(), INTERVAL 20 HOUR)),
(9, 2, 'OPEN', 'ASSIGNED', 'Assigned to Ramesh Patel.', NULL, DATE_SUB(NOW(), INTERVAL 18 HOUR)),
(9, 6, 'ASSIGNED', 'IN_PROGRESS', 'Sourcing heavy-duty 50mm replacement float ball valve.', NULL, DATE_SUB(NOW(), INTERVAL 15 HOUR)),
(9, 1, 'IN_PROGRESS', 'IN_PROGRESS', '[AUTOMATIC ESCALATION] Ticket missed 6-hour Critical SLA deadline. Escalated to Level 1.', NULL, DATE_SUB(NOW(), INTERVAL 14 HOUR)),
(9, 1, 'IN_PROGRESS', 'IN_PROGRESS', '[AUTOMATIC ESCALATION] Ticket still unresolved 6+ hours past deadline. Escalated to Level 2 (Executive Committee).', NULL, DATE_SUB(NOW(), INTERVAL 8 HOUR));

-- 6. Active Society Notices
DELETE FROM notices;
INSERT INTO notices (id, posted_by, title, body, expires_on, created_at) VALUES
(1, 2, 'Annual General Body Meeting (AGM) 2026', 'Notice is hereby given that the Annual General Meeting of Society residents will be held on Sunday at 10:30 AM in the Clubhouse. Agenda includes maintenance budget approval and election of new committee members.', DATE_ADD(CURRENT_DATE(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(2, 2, 'Overhead Water Tank Cleaning Schedule', 'Please be advised that municipal water supply to all Wings (A, B, C) will be suspended from 10:00 AM to 4:00 PM this Saturday due to semi-annual tank sanitization. Kindly store sufficient water.', DATE_ADD(CURRENT_DATE(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(3, 1, 'New EV Charging Bays Activated in Basement Parking', 'Two dual-gun 7.4kW EV charging stations are now functional in Basement Level 1. Residents interested in registering their vehicle RFID tags may contact the society office.', DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 4 HOUR));

-- 7. In-App Notifications
INSERT INTO notifications (user_id, ticket_id, message, is_read, created_at) VALUES
(4, 4, 'Ticket #4 (Master Bathroom Exhaust Fan Sparking) has been marked as RESOLVED. Please verify the fix and close or reopen.', FALSE, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
(4, 8, 'Your ticket #8 has missed its deadline and was auto-escalated to Level 1 (Supervisor Alert).', FALSE, DATE_SUB(NOW(), INTERVAL 4 HOUR)),
(3, 8, 'URGENT: Assigned ticket #8 is overdue and has been escalated to Level 1!', FALSE, DATE_SUB(NOW(), INTERVAL 4 HOUR)),
(2, 9, 'ESCALATION ALERT: Ticket #9 (Overhead Water Tank Float Valve Leakage) escalated to Level 2!', FALSE, DATE_SUB(NOW(), INTERVAL 8 HOUR)),
(2, 1, 'New ticket #1 raised: Ceiling Seepage in Guest Bedroom (Priority: HIGH)', TRUE, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
(1, NULL, 'New user Deepak Nair (Flat A-202) has registered and requires account approval.', FALSE, DATE_SUB(NOW(), INTERVAL 30 MINUTE));

-- 8. Admin Audit Trail
DELETE FROM admin_audit_logs;
INSERT INTO admin_audit_logs (admin_id, action, target_type, target_id, details, created_at) VALUES
(1, 'SYSTEM_INIT', 'SYSTEM', NULL, 'SocietyDesk system initialized with base SLA rules and categories.', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(1, 'FLAT_CREATED', 'FLAT', 1, 'Registered initial society blocks and flat allocations.', DATE_SUB(NOW(), INTERVAL 4 DAY)),
(1, 'VENDOR_REGISTERED', 'VENDOR', 1, 'Added Apex Electricals to contractor directory.', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(1, 'USER_APPROVE', 'USER', 4, 'Approved resident account for Ananya Verma (Flat A-101).', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(1, 'USER_APPROVE', 'USER', 8, 'Approved resident account for Rohan Mehta (Flat A-102).', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, 'SLA_RULE_UPDATED', 'SLA', NULL, 'Verified Critical resolution window configured to 6 hours.', DATE_SUB(NOW(), INTERVAL 1 DAY));
