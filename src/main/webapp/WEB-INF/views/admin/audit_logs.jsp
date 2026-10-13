<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Administrative Audit Logs");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h2 class="fw-bold mb-0">System &amp; Administrative Audit Log</h2>
        <span class="text-muted">Immutable tracking of user approvals, SLA updates, category/flat modifications, and assignments</span>
    </div>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-secondary btn-sm">
        <i class="bi bi-arrow-left me-1"></i> Back to Dashboard
    </a>
</div>

<div class="card shadow-sm">
    <div class="card-header py-3 d-flex justify-content-between align-items-center">
        <h5 class="mb-0 fw-bold"><i class="bi bi-journal-text me-2 text-primary"></i>Audit Trail Log</h5>
        <span class="badge bg-light text-secondary border">${auditLogs.size()} Total Logged Actions</span>
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty auditLogs}">
                <div class="text-center py-5 text-muted">
                    <i class="bi bi-journal-x fs-1 d-block mb-2"></i>
                    No audit entries recorded yet.
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Timestamp</th>
                                <th>Admin / Actor</th>
                                <th>Action Performed</th>
                                <th>Target Type</th>
                                <th>Target ID</th>
                                <th>Details</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="log" items="${auditLogs}">
                                <tr>
                                    <td><small class="text-muted"><i class="bi bi-clock me-1"></i>${log.createdAt}</small></td>
                                    <td>
                                        <strong>${log.adminName}</strong>
                                        <small class="text-muted d-block">ID: #${log.adminId}</small>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${log.action.startsWith('USER_APPROVE')}"><span class="badge bg-success">USER_APPROVED</span></c:when>
                                            <c:when test="${log.action.startsWith('USER_REJECT')}"><span class="badge bg-danger">USER_REJECTED</span></c:when>
                                            <c:when test="${log.action.startsWith('USER_DEACTIVATE')}"><span class="badge bg-warning text-dark">USER_DEACTIVATED</span></c:when>
                                            <c:when test="${log.action == 'TICKET_ASSIGNED'}"><span class="badge bg-primary">TICKET_ASSIGNED</span></c:when>
                                            <c:when test="${log.action == 'SLA_RULE_UPDATED'}"><span class="badge bg-danger">SLA_RULE_UPDATED</span></c:when>
                                            <c:when test="${log.action == 'CATEGORY_CREATED'}"><span class="badge bg-info text-dark">CATEGORY_CREATED</span></c:when>
                                            <c:when test="${log.action == 'FLAT_CREATED'}"><span class="badge bg-secondary">FLAT_CREATED</span></c:when>
                                            <c:otherwise><span class="badge bg-dark">${log.action}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><span class="badge bg-light text-dark border">${log.targetType}</span></td>
                                    <td>
                                        <c:if test="${not empty log.targetId}">
                                            <code>#${log.targetId}</code>
                                        </c:if>
                                    </td>
                                    <td><span class="small text-secondary">${log.details}</span></td>
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
