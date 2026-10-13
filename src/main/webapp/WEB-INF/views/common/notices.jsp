<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Society Notice Board");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h2 class="fw-bold mb-0">Notice Board &amp; Circulars</h2>
        <span class="text-muted">Official announcements and advisories from Society Management</span>
    </div>
    <c:if test="${currentUser.role == 'COMMITTEE' || currentUser.role == 'ADMIN'}">
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#newNoticeModal">
            <i class="bi bi-plus-lg me-1"></i> Post New Announcement
        </button>
    </c:if>
</div>

<!-- Notices Grid -->
<div class="row g-4">
    <c:choose>
        <c:when test="${empty notices}">
            <div class="col-12 text-center py-5 text-muted">
                <i class="bi bi-megaphone fs-1 d-block mb-2 text-secondary"></i>
                No active announcements at this time.
            </div>
        </c:when>
        <c:otherwise>
            <c:forEach var="n" items="${notices}">
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 shadow-sm border-0 bg-white rounded-4 p-3 d-flex flex-column">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle">
                                <i class="bi bi-pin-angle-fill me-1"></i> Circular
                            </span>
                            <c:if test="${currentUser.role == 'COMMITTEE' || currentUser.role == 'ADMIN'}">
                                <form action="${pageContext.request.contextPath}/notices/delete" method="post" onsubmit="return confirm('Delete this announcement?');">
                                    <input type="hidden" name="id" value="${n.id}">
                                    <button type="submit" class="btn btn-link text-danger p-0 border-0" title="Delete">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </c:if>
                        </div>

                        <h5 class="fw-bold text-dark mb-2">${n.title}</h5>
                        <p class="text-secondary small mb-3 flex-grow-1" style="white-space: pre-wrap;">${n.body}</p>

                        <div class="pt-2 border-top text-muted small d-flex justify-content-between">
                            <span><i class="bi bi-person me-1"></i>${n.postedByName}</span>
                            <span><i class="bi bi-clock me-1"></i>${n.createdAt}</span>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>

<!-- Modal for Posting Notice -->
<c:if test="${currentUser.role == 'COMMITTEE' || currentUser.role == 'ADMIN'}">
    <div class="modal fade" id="newNoticeModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/notices/create" method="post">
                    <div class="modal-header">
                        <h5 class="modal-title fw-bold">Post New Society Announcement</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Title <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="title" required placeholder="e.g. Water Tank Cleaning Notice">
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Announcement Details <span class="text-danger">*</span></label>
                            <textarea class="form-control" name="body" rows="4" required placeholder="Describe the announcement, dates, affected areas..."></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Auto-Expire Date (Optional)</label>
                            <input type="date" class="form-control" name="expiresOn">
                            <div class="form-text">Notice will automatically hide after this date.</div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Publish Announcement</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
