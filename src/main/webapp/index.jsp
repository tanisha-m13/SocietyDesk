<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Welcome to SocietyDesk");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row align-items-center py-5">
    <div class="col-lg-7">
        <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2 rounded-pill mb-3">
            <i class="bi bi-shield-check me-1"></i> Transparent &amp; Accountable Housing Society Management
        </span>
        <h1 class="display-4 fw-bold text-dark mb-3">
            Say goodbye to lost complaints in WhatsApp groups.
        </h1>
        <p class="lead text-secondary mb-4">
            SocietyDesk transforms maintenance management with automated ticket tracking, priority-based SLA deadlines, and background multi-level auto-escalation.
        </p>
        <div class="d-flex flex-wrap gap-3">
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary btn-lg px-4 shadow-sm">
                        <i class="bi bi-speedometer2 me-2"></i> Open My Dashboard
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-primary btn-lg px-4 shadow-sm">
                        <i class="bi bi-box-arrow-in-right me-2"></i> Sign In
                    </a>
                    <a href="${pageContext.request.contextPath}/register" class="btn btn-outline-secondary btn-lg px-4">
                        <i class="bi bi-person-plus me-2"></i> Register Flat
                    </a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    <div class="col-lg-5 mt-4 mt-lg-0">
        <div class="card shadow-lg p-4 border-0 rounded-4 bg-white">
            <h5 class="fw-bold mb-3 d-flex align-items-center gap-2">
                <i class="bi bi-key-fill text-warning"></i> Quick Demo Access
            </h5>
            <p class="small text-muted mb-3">
                Pre-configured demonstration accounts with password: <code>Password@123</code>
            </p>
            <div class="d-grid gap-2">
                <form action="${pageContext.request.contextPath}/login" method="post">
                    <input type="hidden" name="email" value="admin@societydesk.com">
                    <input type="hidden" name="password" value="Password@123">
                    <button type="submit" class="btn btn-outline-dark w-100 text-start d-flex justify-content-between align-items-center">
                        <span><i class="bi bi-shield-lock-fill text-danger me-2"></i><strong>Admin</strong> (admin@societydesk.com)</span>
                        <i class="bi bi-arrow-right"></i>
                    </button>
                </form>
                <form action="${pageContext.request.contextPath}/login" method="post">
                    <input type="hidden" name="email" value="committee@societydesk.com">
                    <input type="hidden" name="password" value="Password@123">
                    <button type="submit" class="btn btn-outline-dark w-100 text-start d-flex justify-content-between align-items-center">
                        <span><i class="bi bi-person-badge-fill text-primary me-2"></i><strong>Committee</strong> (committee@societydesk.com)</span>
                        <i class="bi bi-arrow-right"></i>
                    </button>
                </form>
                <form action="${pageContext.request.contextPath}/login" method="post">
                    <input type="hidden" name="email" value="technician@societydesk.com">
                    <input type="hidden" name="password" value="Password@123">
                    <button type="submit" class="btn btn-outline-dark w-100 text-start d-flex justify-content-between align-items-center">
                        <span><i class="bi bi-tools text-warning me-2"></i><strong>Technician</strong> (technician@societydesk.com)</span>
                        <i class="bi bi-arrow-right"></i>
                    </button>
                </form>
                <form action="${pageContext.request.contextPath}/login" method="post">
                    <input type="hidden" name="email" value="resident@societydesk.com">
                    <input type="hidden" name="password" value="Password@123">
                    <button type="submit" class="btn btn-outline-dark w-100 text-start d-flex justify-content-between align-items-center">
                        <span><i class="bi bi-house-door-fill text-success me-2"></i><strong>Resident</strong> (resident@societydesk.com)</span>
                        <i class="bi bi-arrow-right"></i>
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<div class="row g-4 py-4">
    <div class="col-md-3">
        <div class="card h-100 p-3 border-0 bg-white shadow-sm">
            <div class="fs-1 text-primary mb-2"><i class="bi bi-stopwatch"></i></div>
            <h5 class="fw-bold">Priority SLA Deadlines</h5>
            <p class="text-muted small">Every issue receives a strict resolution deadline based on severity (Critical: 6h, High: 12h, Medium: 24h, Low: 72h).</p>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card h-100 p-3 border-0 bg-white shadow-sm">
            <div class="fs-1 text-danger mb-2"><i class="bi bi-graph-up-arrow"></i></div>
            <h5 class="fw-bold">Automatic Escalation</h5>
            <p class="text-muted small">Background workers monitor SLA deadlines and auto-escalate overdue tickets across 3 managerial levels with notifications.</p>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card h-100 p-3 border-0 bg-white shadow-sm">
            <div class="fs-1 text-success mb-2"><i class="bi bi-camera"></i></div>
            <h5 class="fw-bold">Photo Proof of Work</h5>
            <p class="text-muted small">Residents attach photos when reporting issues, and technicians upload completion photos before resolving.</p>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card h-100 p-3 border-0 bg-white shadow-sm">
            <div class="fs-1 text-info mb-2"><i class="bi bi-bar-chart-line"></i></div>
            <h5 class="fw-bold">Compliance Analytics</h5>
            <p class="text-muted small">Interactive Chart.js visual reports tracking SLA breach rates, vendor speed, and resident satisfaction ratings.</p>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
