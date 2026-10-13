<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Complaint Categories");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row g-4">
    <div class="col-md-4">
        <div class="card p-4 shadow-sm bg-white">
            <h5 class="fw-bold mb-3"><i class="bi bi-tag text-success me-2"></i>Add Complaint Category</h5>
            <form action="${pageContext.request.contextPath}/admin/categories" method="post">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Category Name <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="name" required placeholder="e.g. Plumbing, Security">
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Description</label>
                    <textarea class="form-control" name="description" rows="3" placeholder="Scope of issues covered..."></textarea>
                </div>
                <button type="submit" class="btn btn-success w-100">
                    <i class="bi bi-plus-lg me-1"></i> Add Category
                </button>
            </form>
        </div>
    </div>

    <div class="col-md-8">
        <div class="card shadow-sm">
            <div class="card-header py-3">
                <h5 class="mb-0 fw-bold"><i class="bi bi-tags me-2 text-success"></i>Existing Complaint Categories</h5>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Category Name</th>
                                <th>Description</th>
                                <th>Created On</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${categories}">
                                <tr>
                                    <td class="fw-bold">#${c.id}</td>
                                    <td><span class="badge bg-light text-dark border fw-semibold">${c.name}</span></td>
                                    <td class="text-muted small">${c.description}</td>
                                    <td><small class="text-muted">${c.createdAt}</small></td>
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
