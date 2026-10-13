# SocietyDesk &mdash; Housing Society Complaint and Issue Tracking System with Automatic Escalation

**SocietyDesk** is a production-grade web application built with **Java Servlets, JSP, JDBC, and MySQL** that replaces informal complaint handling in housing societies with a structured, trackable, and accountable workflow.

---

## 🌟 Key Pillars of the Application

### 1. 🏠 Society Management
- **Flats & Residencies**: Manage residential blocks and apartment numbers.
- **Role-Based Registrations**: Resident and Technician signups start in `PENDING` state and require **Admin Approval** before login is permitted.
- **Admin Audit Trail**: Every privileged administrative decision (approval, rejection, category change, flat registration, SLA tuning) is logged in `admin_audit_logs`.

### 2. 🎫 Complaint Lifecycle & Strict State Transition Matrix
Enforced in [`TicketService.java`](src/main/java/com/societydesk/service/TicketService.java) with custom [`InvalidTransitionException`](src/main/java/com/societydesk/exception/InvalidTransitionException.java):

```
OPEN ──(Committee Assigns)──> ASSIGNED ──(Tech Starts Work)──> IN_PROGRESS ──(Tech Resolves)──> RESOLVED
                                  ▲                                                                │
                                  │                         ┌──────────────────────────────────────┴────────┐
                                  │                         ▼                                               ▼
                         (Committee Reassigns)        (Resident Reopens)                           (Resident Confirms)
                                  │                         │                                               │
                                  └──────── REOPENED ◄──────┘                                             CLOSED (Rated 1-5★)
```

| Current Status | Action | Allowed Role | Target Status | Description |
| :--- | :--- | :--- | :--- | :--- |
| **`OPEN`** | Assign Technician | `COMMITTEE`, `ADMIN` | **`ASSIGNED`** | Committee allocates an active technician. |
| **`ASSIGNED`** | Start Work | Assigned `TECHNICIAN`, `ADMIN` | **`IN_PROGRESS`** | Technician begins physical maintenance. |
| **`IN_PROGRESS`** | Resolve Issue | Assigned `TECHNICIAN`, `ADMIN` | **`RESOLVED`** | Fix submitted with resolution note & optional proof photo. |
| **`RESOLVED`** | Confirm Fix | `RESIDENT` (owner), `ADMIN` | **`CLOSED`** | Resident confirms fix, rates 1–5 stars with feedback. |
| **`RESOLVED`** | Reject Fix | `RESIDENT` (owner), `ADMIN` | **`REOPENED`** | Resident rejects fix with explanation; urgent alert triggered. |
| **`REOPENED`** | Reassign/Restart | `COMMITTEE`, `ADMIN`, or Tech | **`ASSIGNED`** / **`IN_PROGRESS`** | Re-queued for investigation. |

---

### 3. ⏱️ SLA Rules & Background Multi-Level Automatic Escalation

#### Formal SLA Rules Matrix
| Priority | First Response SLA | Full Resolution SLA | Scope / Fault Examples |
| :--- | :---: | :---: | :--- |
| **`CRITICAL`** | 1 Hour | **6 Hours** | Main water burst, elevator breakdown, total phase power outage, security gate fault. |
| **`HIGH`** | 4 Hours | **12 Hours** | Common corridor lights out, minor plumbing leaks, intercom failure. |
| **`MEDIUM`** | 8 Hours | **24 Hours** | Flat electrical switchboard faults, bathroom tap seepage, woodwork repairs. |
| **`LOW`** | 24 Hours | **72 Hours** | Cosmetic repairs, corridor painting touch-ups, general society inquiries. |

#### Tiered Escalation Specifications & Recurrence Prevention
Managed by [`EscalationJob.java`](src/main/java/com/societydesk/job/EscalationJob.java) running via a daemon `ScheduledExecutorService` in [`AppStartupListener.java`](src/main/java/com/societydesk/listener/AppStartupListener.java):

- **Level 0 (Normal)**: `now < sla_deadline` (Ticket is within SLA).
- **Level 1 (Supervisor Alert)**: Overdue by $\ge$ 0 hours (`currentLevel == 0`). In-app notification sent to Resident, Assigned Technician, and Committee.
- **Level 2 (Executive Committee)**: Overdue by $\ge$ 6 hours (`currentLevel == 1`). Prevents consecutive 60-second re-escalation by verifying overdue duration threshold. Committee reviews delay.
- **Level 3 (Society Admin Intervention)**: Overdue by $\ge$ 18 hours (`currentLevel == 2`). Hard ceiling reached; alerts Society Admin for contractor penalty/intervention.

---

### 4. 📊 Monitoring, Search & Visual Reporting
- **Multi-Criteria Search**: Filter complaints by **Ticket ID**, **Status**, **Category**, **Priority**, **Technician**, **Escalation Level**, or **Overdue Only**.
- **Real-Time KPIs**: Total tickets, open complaints, in-progress count, resolved count, active escalations, SLA compliance rate (%), and average resolution hours.
- **Interactive Chart.js Visuals**: Dynamic doughnut chart of complaint status distribution and bar chart of category volume breakdown.

---

### 5. 🔐 Advanced Java Architecture & Technical Concepts
- **Servlet Lifecycle**: `doGet` / `doPost` controller handling with `@WebServlet`.
- **Presentation**: JSP 3.0 with Jakarta JSTL tag library (`<c:forEach>`, `<c:choose>`, `<c:if>`).
- **Data Access**: JDBC using DAO pattern with parameterized `PreparedStatement` (SQL injection prevention).
- **Transactions**: Explicit `conn.setAutoCommit(false)`, `commit()`, and `rollback()` in [`TicketDAO.java`](src/main/java/com/societydesk/dao/TicketDAO.java) for atomic updates.
- **Connection Pool**: HikariCP high-performance connection pooling loaded from `db.properties`.
- **Security & Filters**: `AuthFilter` (session validation) and `RoleFilter` (role-based access control).
- **Password Hashing**: BCrypt with 12 salt rounds (`jbcrypt:0.4`).
- **File Uploads**: `@MultipartConfig` and `FileUtil` for defect/proof photo storage.
- **Multithreading**: `ScheduledExecutorService` daemon thread with top-level `Throwable` guard.

---

## 🧪 15-Point Test-Case Execution Table

| Test ID | Test Scenario | Pre-Conditions | Expected Result | Result |
| :---: | :--- | :--- | :--- | :---: |
| **TC01** | User Registration | Valid Flat selected | Account created with status `PENDING` | **PASS** |
| **TC02** | Login with Pending Account | Status is `PENDING` | Login blocked with "Awaiting Admin Approval" message | **PASS** |
| **TC03** | Admin User Approval | User is `PENDING` | Status updated to `ACTIVE`; event logged in `admin_audit_logs` | **PASS** |
| **TC04** | Valid Role Login | Status is `ACTIVE` | Authenticates; session created; redirects to role dashboard | **PASS** |
| **TC05** | Unauthorized URL Access | Role is `RESIDENT` | Direct visit to `/admin/users` blocked with HTTP 403 Forbidden | **PASS** |
| **TC06** | Ticket Creation & SLA Target | Resident logged in | Ticket created; SLA deadline set to exact resolve window | **PASS** |
| **TC07** | Defect Photo Upload | Valid JPG (< 5MB) | Stored with unique UUID in `/uploads`; filename saved in DB | **PASS** |
| **TC08** | Illegal State Transition Jump | Ticket is `OPEN` | Direct jump to `RESOLVED` throws `InvalidTransitionException` | **PASS** |
| **TC09** | Committee Assigns Technician | Ticket is `OPEN` | Atomic transaction sets `assigned_to`, `ASSIGNED`, writes audit update | **PASS** |
| **TC10** | Technician Starts Work | Ticket is `ASSIGNED` | Status moves to `IN_PROGRESS`; resident notified | **PASS** |
| **TC11** | Technician Submits Fix | Ticket is `IN_PROGRESS` | Status moves to `RESOLVED`; proof photo stored; resident alerted | **PASS** |
| **TC12** | Resident Reopens Ticket | Ticket is `RESOLVED` | Status moves to `REOPENED`; explanation logged; urgent alert sent | **PASS** |
| **TC13** | Resident Rating & Closure | Ticket is `RESOLVED` | Status moves to `CLOSED`; `closed_at` recorded; 1–5★ rating saved | **PASS** |
| **TC14** | Automated SLA Escalation | Deadline expired | Background job escalates ticket to Level 1; alerts sent | **PASS** |
| **TC15** | Repeat Escalation Prevention | Already Level 1 (< 6h) | Scheduler runs 60s later; ticket remains Level 1 (no jump to L2) | **PASS** |

---

## 🚀 Setup & Execution Guide

### 1. Database Setup
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p < database/schema.sql
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p < database/seed.sql
```

Update your MySQL password in `src/main/resources/db.properties` if needed:
```properties
db.username=root
db.password=YOUR_MYSQL_PASSWORD
```

### 2. Run Application (1-Click Embedded Tomcat)
```powershell
mvn compile exec:java
```
Access the application at:
👉 **[http://localhost:8080](http://localhost:8080)**

*(Alternatively, build the standalone WAR using `mvn clean package` and deploy `target/SocietyDesk.war` to Apache Tomcat).*

---

## 🔑 Pre-Configured Test Accounts (Password: `Password@123`)
- **Admin**: `admin@societydesk.com`
- **Committee**: `committee@societydesk.com`
- **Technician**: `technician@societydesk.com`
- **Resident**: `resident@societydesk.com`
