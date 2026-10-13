<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("pageTitle", "Resident Dashboard");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h2 class="fw-bold mb-0">Welcome, ${currentUser.name}</h2>
        <span class="text-muted">Flat: <strong>${currentUser.formattedFlat}</strong></span>
    </div>
    <a href="${pageContext.request.contextPath}/resident/tickets/new" class="btn btn-primary px-4 shadow-sm">
        <i class="bi bi-plus-lg me-1"></i> Raise New Complaint
    </a>
</div>

<!-- Stat Cards -->
<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-primary">
            <div class="text-muted small text-uppercase fw-semibold">Open Complaints</div>
            <div class="fs-2 fw-bold text-dark mt-1">${openCount}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-warning">
            <div class="text-muted small text-uppercase fw-semibold">In Progress</div>
            <div class="fs-2 fw-bold text-dark mt-1">${inProgressCount}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-info">
            <div class="text-muted small text-uppercase fw-semibold">Resolved (Action Needed)</div>
            <div class="fs-2 fw-bold text-dark mt-1">${resolvedCount}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-success">
            <div class="text-muted small text-uppercase fw-semibold">Closed &amp; Rated</div>
            <div class="fs-2 fw-bold text-dark mt-1">${closedCount}</div>
        </div>
    </div>
</div>

<div class="row g-4">
    <!-- Recent Complaints Table -->
    <div class="col-lg-8">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center py-3">
                <h5 class="mb-0 fw-bold"><i class="bi bi-ticket-detailed me-2 text-primary"></i>My Recent Maintenance Tickets</h5>
                <a href="${pageContext.request.contextPath}/resident/tickets" class="btn btn-sm btn-outline-secondary">View All</a>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty tickets}">
                        <div class="text-center py-5 text-muted">
                            <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary"></i>
                            <p class="mb-2">No complaints raised yet.</p>
                            <a href="${pageContext.request.contextPath}/resident/tickets/new" class="btn btn-sm btn-primary">Raise a Ticket</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>ID</th>
                                        <th>Category &amp; Title</th>
                                        <th>Priority</th>
                                        <th>Status</th>
                                        <th>SLA Deadline</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="t" items="${tickets}">
                                        <tr>
                                            <td class="fw-bold">#${t.id}</td>
                                            <td>
                                                <div class="fw-semibold">${t.title}</div>
                                                <small class="text-muted"><i class="bi bi-tag me-1"></i>${t.categoryName}</small>
                                            </td>
                                            <td>
                                                <span class="badge ${t.priorityBadgeClass}">${t.priority}</span>
                                            </td>
                                            <td>
                                                <span class="badge ${t.statusBadgeClass}">${t.status}</span>
                                                <c:if test="${t.escalationLevel > 0}">
                                                    <span class="badge bg-danger ms-1">Escalated L${t.escalationLevel}</span>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${t.overdue}">
                                                        <span class="text-danger fw-semibold"><i class="bi bi-exclamation-triangle-fill me-1"></i>Overdue</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="small text-muted">${t.slaDeadline}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/ticket/detail?id=${t.id}" class="btn btn-sm btn-outline-primary">
                                                    View Timeline
                                                </a>
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
    </div>

    <!-- Active Notices Sidebar -->
    <div class="col-lg-4">
        <div class="card h-100">
            <div class="card-header py-3">
                <h5 class="mb-0 fw-bold"><i class="bi bi-megaphone me-2 text-danger"></i>Society Announcements</h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty notices}">
                        <div class="text-center py-4 text-muted small">No active notices at this time.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="list-group list-group-flush">
                            <c:forEach var="n" items="${notices}">
                                <div class="list-group-item px-0 py-3">
                                    <h6 class="fw-bold mb-1 text-primary">${n.title}</h6>
                                    <p class="small text-muted mb-1">${n.body}</p>
                                    <div class="d-flex justify-content-between align-items-center small text-secondary">
                                        <span><i class="bi bi-person me-1"></i>${n.postedByName}</span>
                                        <span><i class="bi bi-clock me-1"></i>${n.createdAt}</span>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
