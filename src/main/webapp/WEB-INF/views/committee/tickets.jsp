<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Society Maintenance Queue");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h2 class="fw-bold mb-0">Maintenance Ticket Queue</h2>
        <span class="text-muted">Master log of all complaints, active technicians, and SLA statuses</span>
    </div>
</div>

<!-- Filter Bar -->
<div class="card p-3 mb-4 shadow-sm bg-white">
    <form action="${pageContext.request.contextPath}/committee/tickets" method="get" class="row g-2 align-items-end">
        <div class="col-md-2">
            <label class="form-label small fw-semibold">Search Ticket #</label>
            <input type="number" name="ticketId" class="form-control form-control-sm" placeholder="e.g. 101" value="${searchTicketId != null ? searchTicketId : ''}">
        </div>

        <div class="col-md-2">
            <label class="form-label small fw-semibold">Status</label>
            <select name="status" class="form-select form-select-sm">
                <option value="ALL">All Statuses</option>
                <option value="OPEN" ${selectedStatus == 'OPEN' ? 'selected' : ''}>OPEN</option>
                <option value="ASSIGNED" ${selectedStatus == 'ASSIGNED' ? 'selected' : ''}>ASSIGNED</option>
                <option value="IN_PROGRESS" ${selectedStatus == 'IN_PROGRESS' ? 'selected' : ''}>IN_PROGRESS</option>
                <option value="RESOLVED" ${selectedStatus == 'RESOLVED' ? 'selected' : ''}>RESOLVED</option>
                <option value="CLOSED" ${selectedStatus == 'CLOSED' ? 'selected' : ''}>CLOSED</option>
                <option value="REOPENED" ${selectedStatus == 'REOPENED' ? 'selected' : ''}>REOPENED</option>
            </select>
        </div>

        <div class="col-md-2">
            <label class="form-label small fw-semibold">Category</label>
            <select name="categoryId" class="form-select form-select-sm">
                <option value="">All Categories</option>
                <c:forEach var="c" items="${categories}">
                    <option value="${c.id}" ${selectedCategory == c.id ? 'selected' : ''}>${c.name}</option>
                </c:forEach>
            </select>
        </div>

        <div class="col-md-2">
            <label class="form-label small fw-semibold">Technician</label>
            <select name="technicianId" class="form-select form-select-sm">
                <option value="">All Technicians</option>
                <c:forEach var="tech" items="${technicians}">
                    <option value="${tech.id}" ${selectedTechId == tech.id ? 'selected' : ''}>${tech.name}</option>
                </c:forEach>
            </select>
        </div>

        <div class="col-md-2">
            <label class="form-label small fw-semibold">Escalation</label>
            <select name="escalationLevel" class="form-select form-select-sm">
                <option value="ALL">All Levels</option>
                <option value="0" ${selectedEscLevel == '0' ? 'selected' : ''}>Normal (L0)</option>
                <option value="1" ${selectedEscLevel == '1' ? 'selected' : ''}>Level 1 (Supervisor)</option>
                <option value="2" ${selectedEscLevel == '2' ? 'selected' : ''}>Level 2 (Committee)</option>
                <option value="3" ${selectedEscLevel == '3' ? 'selected' : ''}>Level 3 (Admin)</option>
            </select>
        </div>

        <div class="col-md-1">
            <div class="form-check pt-3">
                <input class="form-check-input" type="checkbox" name="overdue" value="true" id="overdueOnly" ${overdueOnly ? 'checked' : ''}>
                <label class="form-check-label small fw-semibold text-danger" for="overdueOnly">
                    Overdue
                </label>
            </div>
        </div>

        <div class="col-md-1">
            <button type="submit" class="btn btn-primary btn-sm w-100" title="Apply Filter">
                <i class="bi bi-funnel"></i> Filter
            </button>
        </div>
    </form>
</div>

<!-- Tickets List Table -->
<div class="card shadow-sm">
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty tickets}">
                <div class="text-center py-5 text-muted">
                    No tickets match the selected criteria.
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Title</th>
                                <th>Resident / Flat</th>
                                <th>Category</th>
                                <th>Priority</th>
                                <th>Technician</th>
                                <th>Status</th>
                                <th>SLA Deadline</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="t" items="${tickets}">
                                <tr>
                                    <td class="fw-bold">#${t.id}</td>
                                    <td class="fw-semibold">${t.title}</td>
                                    <td>${t.residentName} <small class="text-muted d-block">${t.formattedFlat}</small></td>
                                    <td><span class="badge bg-light text-secondary border">${t.categoryName}</span></td>
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
                                    <td>
                                        <a href="${pageContext.request.contextPath}/ticket/detail?id=${t.id}" class="btn btn-sm btn-outline-primary">
                                            View
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
