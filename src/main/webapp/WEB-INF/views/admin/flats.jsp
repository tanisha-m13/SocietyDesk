<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Flats Management");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row g-4">
    <div class="col-md-4">
        <div class="card p-4 shadow-sm bg-white">
            <h5 class="fw-bold mb-3"><i class="bi bi-plus-circle text-primary me-2"></i>Register New Flat</h5>
            <form action="${pageContext.request.contextPath}/admin/flats" method="post">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Block / Wing <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="block" required placeholder="e.g. A, B, Tower-1">
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Flat / Apartment Number <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="flatNo" required placeholder="e.g. 101, 202">
                </div>
                <button type="submit" class="btn btn-primary w-100">
                    <i class="bi bi-building-add me-1"></i> Add Flat
                </button>
            </form>
        </div>
    </div>

    <div class="col-md-8">
        <div class="card shadow-sm">
            <div class="card-header py-3">
                <h5 class="mb-0 fw-bold"><i class="bi bi-houses me-2 text-primary"></i>Configured Society Flats</h5>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Block</th>
                                <th>Flat No.</th>
                                <th>Registered On</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="f" items="${flats}">
                                <tr>
                                    <td class="fw-bold">#${f.id}</td>
                                    <td><span class="badge bg-secondary">Block ${f.block}</span></td>
                                    <td class="fw-semibold">Flat ${f.flatNo}</td>
                                    <td><small class="text-muted">${f.createdAt}</small></td>
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
