<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Register Account");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row justify-content-center py-4">
    <div class="col-md-6">
        <div class="card p-4 shadow-sm border-0 rounded-4 bg-white">
            <div class="text-center mb-4">
                <i class="bi bi-person-plus fs-1 text-primary"></i>
                <h3 class="fw-bold mt-2">Create SocietyDesk Account</h3>
                <p class="text-muted small">Registrations are subject to administrative verification</p>
            </div>

            <form action="${pageContext.request.contextPath}/register" method="post">
                <div class="row g-3">
                    <div class="col-12">
                        <label class="form-label fw-semibold">Full Name</label>
                        <input type="text" class="form-control" name="name" required placeholder="e.g. John Doe">
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Email Address</label>
                        <input type="email" class="form-control" name="email" required placeholder="john@example.com">
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Phone Number</label>
                        <input type="tel" class="form-control" name="phone" required placeholder="e.g. 9876543210">
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Password</label>
                        <input type="password" class="form-control" name="password" required minlength="6" placeholder="At least 6 characters">
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Account Role</label>
                        <select class="form-select" name="role" id="roleSelect" onchange="toggleFlatSelection()">
                            <option value="RESIDENT" selected>Resident</option>
                            <option value="TECHNICIAN">Technician / Maintenance</option>
                        </select>
                    </div>

                    <div class="col-12" id="flatSelectionGroup">
                        <label class="form-label fw-semibold">Assigned Flat (Block &amp; Flat No.)</label>
                        <select class="form-select" name="flatId" id="flatId">
                            <option value="">-- Select Your Flat --</option>
                            <c:forEach var="flat" items="${flats}">
                                <option value="${flat.id}">Block ${flat.block} - Flat ${flat.flatNo}</option>
                            </c:forEach>
                        </select>
                        <div class="form-text">Choose the flat you reside in or own.</div>
                    </div>
                </div>

                <div class="mt-4">
                    <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold shadow-sm">
                        <i class="bi bi-check2-circle me-1"></i> Submit Registration
                    </button>
                </div>
            </form>

            <div class="text-center mt-3">
                <span class="small text-muted">Already registered? </span>
                <a href="${pageContext.request.contextPath}/login" class="small fw-semibold">Sign in here</a>
            </div>
        </div>
    </div>
</div>

<script>
function toggleFlatSelection() {
    const role = document.getElementById('roleSelect').value;
    const flatGroup = document.getElementById('flatSelectionGroup');
    if (role === 'TECHNICIAN') {
        flatGroup.style.display = 'none';
    } else {
        flatGroup.style.display = 'block';
    }
}
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
