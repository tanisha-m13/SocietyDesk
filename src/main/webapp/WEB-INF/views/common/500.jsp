<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<% request.setAttribute("pageTitle", "Server Error"); %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row justify-content-center text-center py-5">
    <div class="col-md-6">
        <h1 class="display-1 fw-bold text-warning">500</h1>
        <h3 class="fw-bold text-dark">Internal Server Error</h3>
        <p class="text-muted">An unexpected server error occurred while processing the request.</p>
        <c:if test="${not empty exception}">
            <div class="text-danger small bg-light p-3 rounded mb-3 text-start">
                <code>${exception.message}</code>
            </div>
        </c:if>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary px-4">
            <i class="bi bi-arrow-clockwise me-1"></i> Return to Dashboard
        </a>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
