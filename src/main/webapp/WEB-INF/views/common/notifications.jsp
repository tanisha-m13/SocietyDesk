<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Notifications");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h2 class="fw-bold mb-0">Notifications &amp; Alerts</h2>
        <span class="text-muted">Lifecycle events, assignments, and automated SLA escalations</span>
    </div>
    <form action="${pageContext.request.contextPath}/notifications/read" method="post">
        <button type="submit" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-check2-all me-1"></i> Mark All as Read
        </button>
    </form>
</div>

<div class="card shadow-sm">
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty notifications}">
                <div class="text-center py-5 text-muted">
                    <i class="bi bi-bell-slash fs-1 d-block mb-2 text-secondary"></i>
                    No notifications yet.
                </div>
            </c:when>
            <c:otherwise>
                <div class="list-group list-group-flush">
                    <c:forEach var="n" items="${notifications}">
                        <div class="list-group-item p-3 d-flex justify-content-between align-items-center ${!n.read ? 'bg-light fw-semibold' : ''}">
                            <div class="d-flex align-items-start gap-3">
                                <div class="mt-1">
                                    <c:choose>
                                        <c:when test="${!n.read}"><i class="bi bi-circle-fill text-primary small"></i></c:when>
                                        <c:otherwise><i class="bi bi-check-circle text-muted small"></i></c:otherwise>
                                    </c:choose>
                                </div>
                                <div>
                                    <div class="text-dark">${n.message}</div>
                                    <small class="text-muted"><i class="bi bi-clock me-1"></i>${n.createdAt}</small>
                                </div>
                            </div>
                            <c:if test="${not empty n.ticketId}">
                                <a href="${pageContext.request.contextPath}/ticket/detail?id=${n.ticketId}" class="btn btn-sm btn-outline-primary ms-3">
                                    View Ticket
                                </a>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
