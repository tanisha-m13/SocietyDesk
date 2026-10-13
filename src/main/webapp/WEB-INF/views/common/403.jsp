<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<% request.setAttribute("pageTitle", "Access Denied"); %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row justify-content-center text-center py-5">
    <div class="col-md-6">
        <h1 class="display-1 fw-bold text-danger">403</h1>
        <h3 class="fw-bold text-dark">Access Denied</h3>
        <p class="text-muted">You do not possess the required administrative or role permissions to access this area.</p>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary px-4">
            <i class="bi bi-shield-lock me-1"></i> Return to Your Dashboard
        </a>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
