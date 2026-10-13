<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Ticket #" + request.getAttribute("ticket") != null ? "Ticket Details" : "Ticket");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="mb-3">
    <a href="javascript:history.back()" class="btn btn-outline-secondary btn-sm">
        <i class="bi bi-arrow-left me-1"></i> Back
    </a>
</div>

<!-- Ticket Header Card -->
<div class="card p-4 shadow-sm mb-4 bg-white border-0 rounded-4">
    <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-3">
        <div>
            <div class="d-flex align-items-center gap-2 mb-1">
                <h3 class="fw-bold mb-0 text-dark">#${ticket.id} &mdash; ${ticket.title}</h3>
                <span class="badge ${ticket.statusBadgeClass} fs-6">${ticket.status}</span>
                <c:if test="${ticket.escalationLevel > 0}">
                    <span class="badge bg-danger fs-6 badge-sla-overdue">
                        <i class="bi bi-exclamation-triangle-fill me-1"></i> Escalated Level ${ticket.escalationLevel}
                    </span>
                </c:if>
            </div>
            <p class="text-muted small mb-0">
                Created on <strong>${ticket.createdAt}</strong> &bull; Category: <span class="badge bg-light text-dark border">${ticket.categoryName}</span>
            </p>
        </div>

        <div class="text-end">
            <span class="badge ${ticket.priorityBadgeClass} px-3 py-2 fs-6 mb-1 d-inline-block">
                Priority: ${ticket.priority}
            </span>
            <div class="small">
                <c:choose>
                    <c:when test="${ticket.overdue}">
                        <span class="text-danger fw-bold"><i class="bi bi-alarm-fill me-1"></i>SLA Missed: ${ticket.slaDeadline}</span>
                    </c:when>
                    <c:otherwise>
                        <span class="text-muted"><i class="bi bi-clock me-1"></i>SLA Target: ${ticket.slaDeadline}</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Description & Resident/Tech Info Grid -->
    <div class="row g-3 pt-3 border-top">
        <div class="col-lg-8">
            <h6 class="fw-bold text-uppercase small text-muted">Problem Description</h6>
            <div class="p-3 bg-light rounded-3 text-secondary mb-3" style="white-space: pre-wrap;">${ticket.description}</div>

            <!-- Attached Defect Photo -->
            <c:if test="${not empty ticket.photoPath}">
                <h6 class="fw-bold text-uppercase small text-muted">Attached Defect Photo</h6>
                <div class="mb-3">
                    <a href="${pageContext.request.contextPath}/uploads/${ticket.photoPath}" target="_blank">
                        <img src="${pageContext.request.contextPath}/uploads/${ticket.photoPath}" alt="Defect Photo" class="img-thumbnail" style="max-height: 220px; object-fit: cover;">
                    </a>
                </div>
            </c:if>
        </div>

        <div class="col-lg-4 border-start-lg">
            <div class="p-3 bg-light rounded-3 mb-3">
                <h6 class="fw-bold text-dark mb-2"><i class="bi bi-house-door me-2 text-primary"></i>Resident Info</h6>
                <div><strong>${ticket.residentName}</strong></div>
                <div class="text-muted small">Flat: <strong>${ticket.formattedFlat}</strong></div>
                <div class="text-muted small">Phone: ${ticket.residentPhone}</div>
            </div>

            <div class="p-3 bg-light rounded-3 mb-3">
                <h6 class="fw-bold text-dark mb-2"><i class="bi bi-tools me-2 text-warning"></i>Assigned Technician</h6>
                <c:choose>
                    <c:when test="${not empty ticket.assignedToName}">
                        <div><strong>${ticket.assignedToName}</strong></div>
                        <div class="text-muted small">Phone: ${ticket.assignedToPhone}</div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-muted fst-italic">No technician assigned yet.</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Resident Rating Card if Closed -->
            <c:if test="${not empty rating}">
                <div class="p-3 bg-success-subtle border border-success-subtle rounded-3">
                    <h6 class="fw-bold text-success mb-1"><i class="bi bi-star-fill text-warning me-1"></i>Resident Rating</h6>
                    <div class="text-warning fs-5">
                        <c:forEach begin="1" end="${rating.stars}">★</c:forEach>
                        <c:forEach begin="${rating.stars + 1}" end="5">☆</c:forEach>
                    </div>
                    <c:if test="${not empty rating.feedback}">
                        <div class="small text-muted mt-1 fst-italic">"${rating.feedback}"</div>
                    </c:if>
                </div>
            </c:if>
        </div>
    </div>
</div>

<!-- Action Trays depending on User Role and Ticket Status -->
<div class="card p-3 shadow-sm mb-4 bg-white border-0 rounded-4">
    <h5 class="fw-bold mb-3"><i class="bi bi-lightning-charge-fill text-primary me-2"></i>Workflow Actions</h5>
    <div class="d-flex flex-wrap gap-2 align-items-center">

        <!-- 1. Committee Member / Admin Assign Form -->
        <c:if test="${(currentUser.role == 'COMMITTEE' || currentUser.role == 'ADMIN')}">
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#assignModal">
                <i class="bi bi-person-plus me-1"></i> ${not empty ticket.assignedToName ? 'Reassign Technician' : 'Assign Technician'}
            </button>
        </c:if>

        <!-- 2. Technician Actions -->
        <c:if test="${currentUser.role == 'TECHNICIAN' && currentUser.id == ticket.assignedTo}">
            <c:if test="${ticket.status == 'ASSIGNED'}">
                <form action="${pageContext.request.contextPath}/technician/update" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="START">
                    <input type="hidden" name="ticketId" value="${ticket.id}">
                    <button type="submit" class="btn btn-warning">
                        <i class="bi bi-play-circle me-1"></i> Start Work (Mark In-Progress)
                    </button>
                </form>
            </c:if>

            <c:if test="${ticket.status == 'IN_PROGRESS' || ticket.status == 'REOPENED'}">
                <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#resolveModal">
                    <i class="bi bi-check-circle me-1"></i> Mark as Resolved
                </button>
            </c:if>
        </c:if>

        <!-- 3. Resident Verification Actions (When ticket is marked RESOLVED) -->
        <c:if test="${currentUser.role == 'RESIDENT' && currentUser.id == ticket.residentId && ticket.status == 'RESOLVED'}">
            <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#closeModal">
                <i class="bi bi-patch-check-fill me-1"></i> Confirm Fix &amp; Close Ticket
            </button>
            <button type="button" class="btn btn-outline-danger" data-bs-toggle="modal" data-bs-target="#reopenModal">
                <i class="bi bi-arrow-counterclockwise me-1"></i> Reopen Ticket (Issue Not Fixed)
            </button>
        </c:if>

        <c:if test="${ticket.status == 'CLOSED'}">
            <span class="text-muted small"><i class="bi bi-lock-fill me-1"></i>This ticket has been officially closed and verified.</span>
        </c:if>
    </div>
</div>

<!-- Modals for Workflow Actions -->

<!-- Committee Assign Modal -->
<div class="modal fade" id="assignModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/committee/assign" method="post">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Assign Technician to Ticket #${ticket.id}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="ticketId" value="${ticket.id}">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Select Technician</label>
                        <select name="technicianId" class="form-select" required>
                            <option value="">-- Choose Technician --</option>
                            <c:forEach var="tech" items="${technicians}">
                                <option value="${tech.id}" ${ticket.assignedTo == tech.id ? 'selected' : ''}>
                                    ${tech.name} (${tech.email})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Assignment Instructions / Note</label>
                        <textarea class="form-control" name="note" rows="2" placeholder="Optional directions for the technician..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Confirm Assignment</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Technician Resolve Modal -->
<div class="modal fade" id="resolveModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/technician/update" method="post" enctype="multipart/form-data">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Resolve Ticket #${ticket.id}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="action" value="RESOLVE">
                    <input type="hidden" name="ticketId" value="${ticket.id}">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Resolution Note <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="note" rows="3" required placeholder="Explain how the issue was fixed..."></textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Upload Proof of Work Photo</label>
                        <input type="file" class="form-control" name="proofPhoto" accept="image/*">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-success">Mark as Resolved</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Resident Close & Rate Modal -->
<div class="modal fade" id="closeModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/resident/tickets/rate" method="post">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Confirm Resolution &amp; Rate Service</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="ticketId" value="${ticket.id}">
                    <p class="text-secondary small">Please confirm the maintenance work was completed satisfactorily.</p>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Rate Technician's Service</label>
                        <select name="stars" class="form-select" required>
                            <option value="5" selected>★★★★★ - Excellent (5 Stars)</option>
                            <option value="4">★★★★☆ - Good (4 Stars)</option>
                            <option value="3">★★★☆☆ - Average (3 Stars)</option>
                            <option value="2">★★☆☆☆ - Poor (2 Stars)</option>
                            <option value="1">★☆☆☆☆ - Very Poor (1 Star)</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Feedback / Comments</label>
                        <textarea class="form-control" name="feedback" rows="2" placeholder="Share your experience..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-success">Confirm &amp; Close Ticket</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Resident Reopen Modal -->
<div class="modal fade" id="reopenModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/resident/tickets/reopen" method="post">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title fw-bold">Reopen Ticket #${ticket.id}</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="ticketId" value="${ticket.id}">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Why is this issue still unresolved? <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="reason" rows="3" required placeholder="Describe what is still broken or incomplete..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger">Submit Reopen Request</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Complete Audit Timeline & Lifecycle History -->
<div class="row g-4">
    <div class="col-lg-8">
        <div class="card p-4 shadow-sm bg-white border-0 rounded-4">
            <h5 class="fw-bold mb-4 d-flex align-items-center gap-2">
                <i class="bi bi-clock-history text-primary"></i> Lifecycle Audit Trail &amp; Activity Log
            </h5>

            <div class="timeline">
                <c:forEach var="u" items="${updates}">
                    <div class="timeline-item">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <div>
                                <strong class="text-dark">${u.updaterName}</strong>
                                <span class="badge bg-light text-secondary border small ms-1">${u.updaterRole}</span>
                                <c:if test="${not empty u.newStatus}">
                                    <span class="ms-2 small text-muted">&rarr; Status: <strong>${u.newStatus}</strong></span>
                                </c:if>
                            </div>
                            <small class="text-muted"><i class="bi bi-clock me-1"></i>${u.createdAt}</small>
                        </div>
                        <div class="text-secondary small bg-light p-2 rounded-2 mt-1">
                            ${u.note}
                        </div>
                        <c:if test="${not empty u.photoPath}">
                            <div class="mt-2">
                                <span class="small fw-semibold text-muted d-block mb-1">Proof Attachment:</span>
                                <a href="${pageContext.request.contextPath}/uploads/${u.photoPath}" target="_blank">
                                    <img src="${pageContext.request.contextPath}/uploads/${u.photoPath}" class="img-thumbnail" style="max-height: 140px;">
                                </a>
                            </div>
                        </c:if>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- Post Comment Box -->
    <div class="col-lg-4">
        <div class="card p-4 shadow-sm bg-white border-0 rounded-4 h-100">
            <h5 class="fw-bold mb-3"><i class="bi bi-chat-left-dots text-primary me-2"></i>Add Comment / Note</h5>
            <p class="text-muted small">Post a question or update regarding this ticket.</p>

            <form action="${pageContext.request.contextPath}/ticket/comment" method="post">
                <input type="hidden" name="ticketId" value="${ticket.id}">
                <div class="mb-3">
                    <textarea class="form-control" name="comment" rows="4" required placeholder="Type your note or update here..."></textarea>
                </div>
                <button type="submit" class="btn btn-outline-primary w-100">
                    <i class="bi bi-send me-1"></i> Post Comment
                </button>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
