<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "User Management & Approvals");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h2 class="fw-bold mb-0">User Accounts &amp; Approvals</h2>
        <span class="text-muted">Approve new registrations, manage roles, and review accounts</span>
    </div>
</div>

<div class="card shadow-sm mb-4">
    <div class="card-header py-3">
        <h5 class="mb-0 fw-bold"><i class="bi bi-people me-2 text-primary"></i>All Registered Users</h5>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Role</th>
                        <th>Flat</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="u" items="${allUsers}">
                        <tr>
                            <td class="fw-bold">#${u.id}</td>
                            <td>${u.name}</td>
                            <td>${u.email}</td>
                            <td>${u.phone}</td>
                            <td><span class="badge bg-primary text-uppercase">${u.role}</span></td>
                            <td>${u.formattedFlat}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.status == 'ACTIVE'}"><span class="badge bg-success">ACTIVE</span></c:when>
                                    <c:when test="${u.status == 'PENDING'}"><span class="badge bg-warning text-dark">PENDING</span></c:when>
                                    <c:when test="${u.status == 'REJECTED'}"><span class="badge bg-danger">REJECTED</span></c:when>
                                    <c:otherwise><span class="badge bg-secondary">${u.status}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <form action="${pageContext.request.contextPath}/admin/users" method="post" class="d-inline">
                                    <input type="hidden" name="userId" value="${u.id}">
                                    <c:if test="${u.status == 'PENDING'}">
                                        <button type="submit" name="action" value="APPROVE" class="btn btn-sm btn-success">
                                            Approve
                                        </button>
                                        <button type="submit" name="action" value="REJECT" class="btn btn-sm btn-outline-danger">
                                            Reject
                                        </button>
                                    </c:if>
                                    <c:if test="${u.status == 'ACTIVE' && u.id != currentUser.id}">
                                        <button type="submit" name="action" value="DEACTIVATE" class="btn btn-sm btn-outline-warning">
                                            Deactivate
                                        </button>
                                    </c:if>
                                    <c:if test="${u.status == 'INACTIVE' || u.status == 'REJECTED'}">
                                        <button type="submit" name="action" value="APPROVE" class="btn btn-sm btn-outline-success">
                                            Reactivate
                                        </button>
                                    </c:if>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
