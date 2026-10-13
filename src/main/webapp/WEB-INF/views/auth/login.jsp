<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Sign In");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row justify-content-center py-4">
    <div class="col-md-5">
        <div class="card p-4 shadow-sm border-0 rounded-4 bg-white">
            <div class="text-center mb-4">
                <i class="bi bi-door-open fs-1 text-primary"></i>
                <h3 class="fw-bold mt-2">Sign in to SocietyDesk</h3>
                <p class="text-muted small">Enter your credentials to access your society dashboard</p>
            </div>

            <form action="${pageContext.request.contextPath}/login" method="post">
                <div class="mb-3">
                    <label for="email" class="form-label fw-semibold">Email address</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light"><i class="bi bi-envelope"></i></span>
                        <input type="email" class="form-control" id="email" name="email" value="${email}" required autofocus placeholder="name@example.com">
                    </div>
                </div>

                <div class="mb-3">
                    <label for="password" class="form-label fw-semibold">Password</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light"><i class="bi bi-lock"></i></span>
                        <input type="password" class="form-control" id="password" name="password" required placeholder="Enter password">
                    </div>
                </div>

                <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold shadow-sm mb-3">
                    <i class="bi bi-box-arrow-in-right me-1"></i> Sign In
                </button>
            </form>

            <div class="border-top pt-3 text-center">
                <p class="small text-muted mb-2">Need an account?</p>
                <a href="${pageContext.request.contextPath}/register" class="btn btn-outline-secondary btn-sm w-100">
                    Register as Resident or Staff
                </a>
            </div>

            <div class="mt-4 p-3 bg-light rounded-3 small">
                <strong class="d-block mb-1 text-dark"><i class="bi bi-info-circle me-1"></i> Quick Test Credentials:</strong>
                <div>Password for all accounts: <code>Password@123</code></div>
                <div class="text-muted mt-1">
                    &bull; Admin: <code>admin@societydesk.com</code><br>
                    &bull; Committee: <code>committee@societydesk.com</code><br>
                    &bull; Technician: <code>technician@societydesk.com</code><br>
                    &bull; Resident: <code>resident@societydesk.com</code>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
