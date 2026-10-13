<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Admin Central");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h2 class="fw-bold mb-0">System Administration</h2>
        <span class="text-muted">Master controls, user approval queues, and system parameters</span>
    </div>
    <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-primary">
            <i class="bi bi-person-check me-1"></i> User Approvals
        </a>
        <a href="${pageContext.request.contextPath}/admin/sla" class="btn btn-outline-danger">
            <i class="bi bi-stopwatch me-1"></i> Configure SLA Rules
        </a>
    </div>
</div>

<!-- High-Level Stats -->
<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-primary">
            <div class="text-muted small text-uppercase fw-semibold">Total Registered Users</div>
            <div class="fs-2 fw-bold text-dark mt-1">${metrics.totalUsers}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-warning">
            <div class="text-muted small text-uppercase fw-semibold">Pending Approvals</div>
            <div class="fs-2 fw-bold text-warning mt-1">${pendingUsers.size()}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-success">
            <div class="text-muted small text-uppercase fw-semibold">SLA Compliance Rate</div>
            <div class="fs-2 fw-bold text-success mt-1">${metrics.slaCompliance}%</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-info">
            <div class="text-muted small text-uppercase fw-semibold">Resident Rating Avg</div>
            <div class="fs-2 fw-bold text-dark mt-1">${metrics.avgRating} / 5.0</div>
        </div>
    </div>
</div>

<!-- Pending User Approval Queue -->
<div class="card shadow-sm mb-4">
    <div class="card-header py-3 d-flex justify-content-between align-items-center">
        <h5 class="mb-0 fw-bold"><i class="bi bi-clock-history me-2 text-warning"></i>Pending Account Approvals</h5>
        <span class="badge bg-warning text-dark">${pendingUsers.size()} Waiting</span>
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty pendingUsers}">
                <div class="text-center py-4 text-muted small">
                    <i class="bi bi-check2-circle text-success fs-3 d-block mb-1"></i>
                    No accounts awaiting approval.
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Role</th>
                                <th>Flat</th>
                                <th>Registered On</th>
                                <th>Approval Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="u" items="${pendingUsers}">
                                <tr>
                                    <td class="fw-bold">${u.name}</td>
                                    <td>${u.email}</td>
                                    <td>${u.phone}</td>
                                    <td><span class="badge bg-secondary">${u.role}</span></td>
                                    <td>${u.formattedFlat}</td>
                                    <td><small class="text-muted">${u.createdAt}</small></td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/admin/users" method="post" class="d-inline">
                                            <input type="hidden" name="userId" value="${u.id}">
                                            <button type="submit" name="action" value="APPROVE" class="btn btn-sm btn-success me-1">
                                                <i class="bi bi-check-lg"></i> Approve
                                            </button>
                                            <button type="submit" name="action" value="REJECT" class="btn btn-sm btn-danger">
                                                <i class="bi bi-x-lg"></i> Reject
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

<!-- Administration Links Grid -->
<div class="row g-3">
    <div class="col-md-3">
        <a href="${pageContext.request.contextPath}/admin/flats" class="text-decoration-none">
            <div class="card p-3 h-100 hover-card text-center">
                <i class="bi bi-houses fs-2 text-primary mb-2"></i>
                <h6 class="fw-bold text-dark mb-1">Flats Management</h6>
                <small class="text-muted">Register blocks and apartment numbers</small>
            </div>
        </a>
    </div>
    <div class="col-md-3">
        <a href="${pageContext.request.contextPath}/admin/categories" class="text-decoration-none">
            <div class="card p-3 h-100 hover-card text-center">
                <i class="bi bi-tags fs-2 text-success mb-2"></i>
                <h6 class="fw-bold text-dark mb-1">Complaint Categories</h6>
                <small class="text-muted">Configure maintenance categories</small>
            </div>
        </a>
    </div>
    <div class="col-md-3">
        <a href="${pageContext.request.contextPath}/admin/vendors" class="text-decoration-none">
            <div class="card p-3 h-100 hover-card text-center">
                <i class="bi bi-truck fs-2 text-warning mb-2"></i>
                <h6 class="fw-bold text-dark mb-1">Vendor Network</h6>
                <small class="text-muted">Electricians, Plumbers, Contractors</small>
            </div>
        </a>
    </div>
    <div class="col-md-3">
        <a href="${pageContext.request.contextPath}/admin/sla" class="text-decoration-none">
            <div class="card p-3 h-100 hover-card text-center">
                <i class="bi bi-stopwatch fs-2 text-danger mb-2"></i>
                <h6 class="fw-bold text-dark mb-1">SLA Resolution Rules</h6>
                <small class="text-muted">Configure target resolution hours</small>
            </div>
        </a>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
