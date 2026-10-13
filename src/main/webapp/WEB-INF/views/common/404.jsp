<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<% request.setAttribute("pageTitle", "Page Not Found"); %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row justify-content-center text-center py-5">
    <div class="col-md-6">
        <h1 class="display-1 fw-bold text-primary">404</h1>
        <h3 class="fw-bold text-dark">Page Not Found</h3>
        <p class="text-muted">The requested page or ticket resource could not be found.</p>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary px-4">
            <i class="bi bi-house-door me-1"></i> Return to Dashboard
        </a>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
