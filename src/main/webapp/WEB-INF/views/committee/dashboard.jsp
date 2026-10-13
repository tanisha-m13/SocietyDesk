<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Committee Dashboard");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h2 class="fw-bold mb-0">Managing Committee Oversight</h2>
        <span class="text-muted">Live monitoring of maintenance queues, SLA breaches, and technician allocations</span>
    </div>
    <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/committee/tickets" class="btn btn-outline-primary">
            <i class="bi bi-filter-square me-1"></i> All Tickets
        </a>
        <a href="${pageContext.request.contextPath}/committee/reports" class="btn btn-primary shadow-sm">
            <i class="bi bi-bar-chart-line me-1"></i> View SLA Analytics
        </a>
    </div>
</div>

<!-- Metrics Summary -->
<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-warning">
            <div class="text-muted small text-uppercase fw-semibold">Unassigned Tickets</div>
            <div class="fs-2 fw-bold text-dark mt-1">${unassignedTickets.size()}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-danger">
            <div class="text-muted small text-uppercase fw-semibold">Active Escalations</div>
            <div class="fs-2 fw-bold text-danger mt-1">${escalatedTickets.size()}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-success">
            <div class="text-muted small text-uppercase fw-semibold">SLA Compliance Rate</div>
            <div class="fs-2 fw-bold text-success mt-1">${metrics.slaCompliance}%</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-primary">
            <div class="text-muted small text-uppercase fw-semibold">Avg Resolution Time</div>
            <div class="fs-2 fw-bold text-dark mt-1">${metrics.avgResolutionHours} hrs</div>
        </div>
    </div>
</div>

<!-- 1. Escalated Tickets Alert Section -->
<c:if test="${not empty escalatedTickets}">
    <div class="card border-danger border mb-4 shadow-sm">
        <div class="card-header bg-danger text-white py-3 d-flex justify-content-between align-items-center">
            <h5 class="mb-0 fw-bold"><i class="bi bi-exclamation-triangle-fill me-2"></i>Escalation Queue (Immediate Attention Required)</h5>
            <span class="badge bg-light text-danger fs-6">${escalatedTickets.size()} Breached</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Ticket</th>
                            <th>Resident / Flat</th>
                            <th>Priority</th>
                            <th>Technician</th>
                            <th>Escalation Level</th>
                            <th>SLA Missed</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="t" items="${escalatedTickets}">
                            <tr class="table-danger-subtle">
                                <td class="fw-bold">#${t.id} - ${t.title}</td>
                                <td>${t.residentName} (${t.formattedFlat})</td>
                                <td><span class="badge ${t.priorityBadgeClass}">${t.priority}</span></td>
                                <td>${not empty t.assignedToName ? t.assignedToName : '<span class="text-danger fst-italic">None</span>'}</td>
                                <td>
                                    <span class="badge bg-danger">Level ${t.escalationLevel}</span>
                                </td>
                                <td class="text-danger fw-semibold">${t.slaDeadline}</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/ticket/detail?id=${t.id}" class="btn btn-sm btn-danger">
                                        Intervene
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</c:if>

<!-- 2. Unassigned Tickets Queue -->
<div class="card shadow-sm mb-4">
    <div class="card-header py-3 d-flex justify-content-between align-items-center">
        <h5 class="mb-0 fw-bold"><i class="bi bi-person-plus-fill me-2 text-primary"></i>Unassigned Complaint Queue</h5>
        <span class="badge bg-warning text-dark">${unassignedTickets.size()} Pending Assignment</span>
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty unassignedTickets}">
                <div class="text-center py-4 text-muted small">
                    <i class="bi bi-check-circle-fill text-success fs-3 d-block mb-1"></i>
                    All raised tickets have been assigned to technicians!
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Title &amp; Category</th>
                                <th>Resident</th>
                                <th>Priority</th>
                                <th>SLA Deadline</th>
                                <th>Assign Technician</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="t" items="${unassignedTickets}">
                                <tr>
                                    <td class="fw-bold">#${t.id}</td>
                                    <td>
                                        <div class="fw-semibold">${t.title}</div>
                                        <small class="text-muted"><i class="bi bi-tag me-1"></i>${t.categoryName}</small>
                                    </td>
                                    <td>${t.residentName} (${t.formattedFlat})</td>
                                    <td><span class="badge ${t.priorityBadgeClass}">${t.priority}</span></td>
                                    <td><small class="text-muted">${t.slaDeadline}</small></td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/committee/assign" method="post" class="d-flex gap-2">
                                            <input type="hidden" name="ticketId" value="${t.id}">
                                            <select name="technicianId" class="form-select form-select-sm" required style="max-width: 220px;">
                                                <option value="">-- Choose Tech --</option>
                                                <c:forEach var="tech" items="${technicians}">
                                                    <option value="${tech.id}">${tech.name}</option>
                                                </c:forEach>
                                            </select>
                                            <button type="submit" class="btn btn-sm btn-primary">
                                                Assign
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
