<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "My Complaints");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h2 class="fw-bold mb-0">My Complaint History</h2>
        <span class="text-muted">Overview of all maintenance requests registered for Flat ${currentUser.formattedFlat}</span>
    </div>
    <a href="${pageContext.request.contextPath}/resident/tickets/new" class="btn btn-primary px-3">
        <i class="bi bi-plus-lg me-1"></i> New Complaint
    </a>
</div>

<div class="card shadow-sm">
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty tickets}">
                <div class="text-center py-5 text-muted">
                    <i class="bi bi-card-checklist fs-1 d-block mb-2"></i>
                    No tickets found.
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Ticket ID</th>
                                <th>Title &amp; Category</th>
                                <th>Priority</th>
                                <th>Assigned To</th>
                                <th>Status</th>
                                <th>SLA Deadline</th>
                                <th>Logged On</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="t" items="${tickets}">
                                <tr>
                                    <td class="fw-bold">#${t.id}</td>
                                    <td>
                                        <div class="fw-semibold">${t.title}</div>
                                        <span class="badge bg-light text-secondary border">${t.categoryName}</span>
                                    </td>
                                    <td><span class="badge ${t.priorityBadgeClass}">${t.priority}</span></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty t.assignedToName}">
                                                <i class="bi bi-person-check text-success me-1"></i>${t.assignedToName}
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted fst-italic">Unassigned</span>
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
                                        <c:choose>
                                            <c:when test="${t.overdue}">
                                                <span class="badge bg-danger badge-sla-overdue">BREACHED</span>
                                            </c:when>
                                            <c:otherwise>
                                                <small class="text-muted">${t.slaDeadline}</small>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><small class="text-muted">${t.createdAt}</small></td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/ticket/detail?id=${t.id}" class="btn btn-sm btn-outline-primary">
                                            Details &amp; Audit
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

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
