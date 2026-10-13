<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Technician Work Orders");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h2 class="fw-bold mb-0">Technician Work Orders</h2>
        <span class="text-muted">Assigned maintenance jobs &bull; Technician: <strong>${currentUser.name}</strong></span>
    </div>
</div>

<!-- Task Stats -->
<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-info">
            <div class="text-muted small text-uppercase fw-semibold">New Assignments</div>
            <div class="fs-2 fw-bold text-dark mt-1">${assignedCount}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-warning">
            <div class="text-muted small text-uppercase fw-semibold">Active In Progress</div>
            <div class="fs-2 fw-bold text-dark mt-1">${inProgressCount}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-danger">
            <div class="text-muted small text-uppercase fw-semibold">Overdue Deadlines</div>
            <div class="fs-2 fw-bold text-danger mt-1">${overdueCount}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-success">
            <div class="text-muted small text-uppercase fw-semibold">Completed / Resolved</div>
            <div class="fs-2 fw-bold text-dark mt-1">${resolvedCount}</div>
        </div>
    </div>
</div>

<!-- Tasks List -->
<div class="card shadow-sm">
    <div class="card-header py-3">
        <h5 class="mb-0 fw-bold"><i class="bi bi-tools me-2 text-primary"></i>My Assigned Maintenance Tasks</h5>
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty tasks}">
                <div class="text-center py-5 text-muted">
                    <i class="bi bi-check2-circle fs-1 text-success d-block mb-2"></i>
                    You have no active maintenance tasks assigned.
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Ticket ID</th>
                                <th>Issue &amp; Category</th>
                                <th>Location (Flat)</th>
                                <th>Resident Contact</th>
                                <th>Priority</th>
                                <th>SLA Deadline</th>
                                <th>Status</th>
                                <th>Quick Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="t" items="${tasks}">
                                <tr>
                                    <td class="fw-bold">#${t.id}</td>
                                    <td>
                                        <div class="fw-semibold">${t.title}</div>
                                        <small class="text-muted"><i class="bi bi-tag me-1"></i>${t.categoryName}</small>
                                    </td>
                                    <td><strong>Flat ${t.formattedFlat}</strong></td>
                                    <td>
                                        <div>${t.residentName}</div>
                                        <small class="text-muted"><i class="bi bi-telephone me-1"></i>${t.residentPhone}</small>
                                    </td>
                                    <td><span class="badge ${t.priorityBadgeClass}">${t.priority}</span></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${t.overdue}">
                                                <span class="badge bg-danger badge-sla-overdue">OVERDUE</span>
                                            </c:when>
                                            <c:otherwise>
                                                <small class="text-muted">${t.slaDeadline}</small>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge ${t.statusBadgeClass}">${t.status}</span>
                                        <c:if test="${t.escalationLevel > 0}">
                                            <span class="badge bg-danger ms-1">Escalated L${t.escalationLevel}</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <div class="d-flex gap-1">
                                            <a href="${pageContext.request.contextPath}/ticket/detail?id=${t.id}" class="btn btn-sm btn-outline-secondary">
                                                View
                                            </a>
                                            <c:if test="${t.status == 'ASSIGNED'}">
                                                <form action="${pageContext.request.contextPath}/technician/update" method="post" style="display:inline;">
                                                    <input type="hidden" name="action" value="START">
                                                    <input type="hidden" name="ticketId" value="${t.id}">
                                                    <button type="submit" class="btn btn-sm btn-warning">
                                                        Start Work
                                                    </button>
                                                </form>
                                            </c:if>
                                            <c:if test="${t.status == 'IN_PROGRESS' || t.status == 'REOPENED'}">
                                                <button type="button" class="btn btn-sm btn-success" data-bs-toggle="modal" data-bs-target="#resolveModal${t.id}">
                                                    Mark Resolved
                                                </button>
                                            </c:if>
                                        </div>

                                        <!-- Resolve Modal for this task -->
                                        <div class="modal fade" id="resolveModal${t.id}" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content">
                                                    <form action="${pageContext.request.contextPath}/technician/update" method="post" enctype="multipart/form-data">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title fw-bold">Resolve Ticket #${t.id}</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <input type="hidden" name="action" value="RESOLVE">
                                                            <input type="hidden" name="ticketId" value="${t.id}">
                                                            <div class="mb-3">
                                                                <label class="form-label fw-semibold">Resolution Note <span class="text-danger">*</span></label>
                                                                <textarea class="form-control" name="note" rows="3" required placeholder="Explain what repair or work was executed to fix the issue..."></textarea>
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label fw-semibold">Upload Proof of Work Photo (Optional)</label>
                                                                <input type="file" class="form-control" name="proofPhoto" accept="image/*">
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                            <button type="submit" class="btn btn-success">Submit &amp; Mark Resolved</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
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
