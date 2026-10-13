<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "SLA Configuration");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="mb-4">
    <h2 class="fw-bold mb-0">Service Level Agreement (SLA) Policies</h2>
    <span class="text-muted">Define response and resolution windows. Missed resolve windows trigger automatic background escalation.</span>
</div>

<div class="row g-4">
    <c:forEach var="rule" items="${rules}">
        <div class="col-md-6 col-lg-3">
            <div class="card h-100 shadow-sm border-top border-4 ${rule.priority == 'CRITICAL' ? 'border-danger' : (rule.priority == 'HIGH' ? 'border-warning' : (rule.priority == 'MEDIUM' ? 'border-info' : 'border-success'))}">
                <div class="card-body">
                    <h5 class="fw-bold text-dark mb-2">${rule.priority}</h5>
                    <p class="small text-muted mb-3">${rule.description}</p>

                    <form action="${pageContext.request.contextPath}/admin/sla" method="post">
                        <input type="hidden" name="priority" value="${rule.priority}">
                        <div class="mb-2">
                            <label class="form-label small fw-semibold">Respond Within (Hours)</label>
                            <input type="number" class="form-control form-control-sm" name="respondHours" value="${rule.respondHours}" min="1" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Resolve Within (Hours)</label>
                            <input type="number" class="form-control form-control-sm" name="resolveHours" value="${rule.resolveHours}" min="1" required>
                        </div>
                        <input type="hidden" name="description" value="${rule.description}">
                        <button type="submit" class="btn btn-sm btn-outline-primary w-100">
                            <i class="bi bi-save me-1"></i> Update Rule
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </c:forEach>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
