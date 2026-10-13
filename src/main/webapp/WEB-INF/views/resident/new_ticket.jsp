<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Raise New Complaint");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row justify-content-center">
    <div class="col-lg-8">
        <div class="card p-4 shadow-sm border-0 rounded-4 bg-white">
            <div class="d-flex align-items-center gap-3 mb-4 border-bottom pb-3">
                <div class="bg-primary-subtle p-3 rounded-circle text-primary">
                    <i class="bi bi-tools fs-3"></i>
                </div>
                <div>
                    <h3 class="fw-bold mb-0">Raise a Maintenance Complaint</h3>
                    <p class="text-muted small mb-0">Flat: <strong>${currentUser.formattedFlat}</strong> &bull; Reported by: ${currentUser.name}</p>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/resident/tickets/new" method="post" enctype="multipart/form-data">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Complaint Title <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="title" required placeholder="e.g. Master Bedroom Ceiling Leakage">
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Category <span class="text-danger">*</span></label>
                        <select class="form-select" name="categoryId" required>
                            <option value="">-- Choose Category --</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}">${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Priority Level <span class="text-danger">*</span></label>
                        <select class="form-select" name="priority" required id="prioritySelect">
                            <option value="CRITICAL">Critical (Burst pipes, major sparks - 6h SLA)</option>
                            <option value="HIGH">High (Corridor lights, minor leaks - 12h SLA)</option>
                            <option value="MEDIUM" selected>Medium (Standard flat repairs - 24h SLA)</option>
                            <option value="LOW">Low (Cosmetic/general requests - 72h SLA)</option>
                        </select>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold">Detailed Description <span class="text-danger">*</span></label>
                    <textarea class="form-control" name="description" rows="4" required placeholder="Please describe the issue, exact location in the flat/building, and convenient times for technician visit..."></textarea>
                </div>

                <div class="mb-4">
                    <label class="form-label fw-semibold">Attach Photo (Optional)</label>
                    <input type="file" class="form-control" name="photo" accept="image/jpeg,image/png,image/webp">
                    <div class="form-text">Attach a photo of the defect (JPG, PNG, WebP up to 5MB) to help the technician arrive prepared.</div>
                </div>

                <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                    <a href="${pageContext.request.contextPath}/resident/dashboard" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i> Cancel
                    </a>
                    <button type="submit" class="btn btn-primary px-4 py-2 fw-semibold shadow-sm">
                        <i class="bi bi-send-check me-1"></i> Submit Complaint
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
