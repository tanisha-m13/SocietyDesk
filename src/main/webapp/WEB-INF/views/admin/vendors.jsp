<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Vendor Network");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row g-4">
    <div class="col-md-4">
        <div class="card p-4 shadow-sm bg-white">
            <h5 class="fw-bold mb-3"><i class="bi bi-truck text-warning me-2"></i>Add Service Vendor</h5>
            <form action="${pageContext.request.contextPath}/admin/vendors" method="post">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Agency / Vendor Name <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="name" required placeholder="e.g. Apex Electricals">
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Trade / Specialization <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="trade" required placeholder="e.g. Electrical, Elevator">
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Contact Phone <span class="text-danger">*</span></label>
                    <input type="tel" class="form-control" name="phone" required placeholder="e.g. 9876543210">
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Email Address</label>
                    <input type="email" class="form-control" name="email" placeholder="contact@agency.com">
                </div>
                <button type="submit" class="btn btn-warning w-100">
                    <i class="bi bi-plus-lg me-1"></i> Register Vendor
                </button>
            </form>
        </div>
    </div>

    <div class="col-md-8">
        <div class="card shadow-sm">
            <div class="card-header py-3">
                <h5 class="mb-0 fw-bold"><i class="bi bi-person-badge me-2 text-warning"></i>Contracted Society Vendors</h5>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Vendor</th>
                                <th>Trade</th>
                                <th>Phone</th>
                                <th>Email</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="v" items="${vendors}">
                                <tr>
                                    <td class="fw-bold">#${v.id}</td>
                                    <td class="fw-semibold">${v.name}</td>
                                    <td><span class="badge bg-light text-dark border">${v.trade}</span></td>
                                    <td>${v.phone}</td>
                                    <td><small class="text-muted">${v.email}</small></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
