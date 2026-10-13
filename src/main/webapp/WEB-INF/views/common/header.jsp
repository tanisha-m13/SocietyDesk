<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    com.societydesk.model.User currentUser = (com.societydesk.model.User) session.getAttribute("user");
    request.setAttribute("currentUser", currentUser);
    if (currentUser != null) {
        com.societydesk.dao.NotificationDAO nDao = new com.societydesk.dao.NotificationDAO();
        int unreadCount = nDao.countUnread(currentUser.getId());
        request.setAttribute("unreadCount", unreadCount);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle != null ? pageTitle : 'SocietyDesk'} | Housing Society Tracking</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.min.js"></script>
    <style>
        :root {
            --primary-blue: #1e3a8a;
            --accent-blue: #3b82f6;
            --bg-light: #f8fafc;
        }
        body {
            background-color: var(--bg-light);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .navbar-brand {
            font-weight: 700;
            letter-spacing: -0.5px;
        }
        .main-content {
            flex: 1 0 auto;
        }
        .card {
            border: none;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            border-radius: 0.75rem;
        }
        .card-header {
            background-color: #fff;
            border-bottom: 1px solid #f1f5f9;
            font-weight: 600;
        }
        .badge-sla-overdue {
            animation: pulse-red 1.5s infinite;
        }
        @keyframes pulse-red {
            0% { opacity: 1; }
            50% { opacity: 0.6; }
            100% { opacity: 1; }
        }
        .timeline-item {
            border-left: 2px solid #e2e8f0;
            padding-left: 1.5rem;
            position: relative;
            padding-bottom: 1.5rem;
        }
        .timeline-item::before {
            content: '';
            position: absolute;
            left: -7px;
            top: 4px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background-color: var(--accent-blue);
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top shadow-sm" style="background-color: #0f172a !important;">
    <div class="container-fluid px-lg-4">
        <a class="navbar-brand text-primary d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/">
            <i class="bi bi-building-gear fs-4 text-primary"></i>
            <span class="text-white">Society<span class="text-primary">Desk</span></span>
        </a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarMain">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <c:if test="${not empty currentUser}">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/dashboard">
                            <i class="bi bi-speedometer2 me-1"></i> Dashboard
                        </a>
                    </li>

                    <!-- Resident Navigation -->
                    <c:if test="${currentUser.role == 'RESIDENT'}">
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/resident/tickets/new">
                                <i class="bi bi-plus-circle me-1"></i> Raise Complaint
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/resident/tickets">
                                <i class="bi bi-ticket-detailed me-1"></i> My Complaints
                            </a>
                        </li>
                    </c:if>

                    <!-- Committee Navigation -->
                    <c:if test="${currentUser.role == 'COMMITTEE' || currentUser.role == 'ADMIN'}">
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/committee/tickets">
                                <i class="bi bi-list-task me-1"></i> Ticket Queue
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/committee/reports">
                                <i class="bi bi-graph-up me-1"></i> SLA Reports
                            </a>
                        </li>
                    </c:if>

                    <!-- Technician Navigation -->
                    <c:if test="${currentUser.role == 'TECHNICIAN'}">
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/technician/dashboard">
                                <i class="bi bi-tools me-1"></i> My Work Orders
                            </a>
                        </li>
                    </c:if>

                    <!-- Admin Navigation -->
                    <c:if test="${currentUser.role == 'ADMIN'}">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                                <i class="bi bi-sliders me-1"></i> Admin Setup
                            </a>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/users"><i class="bi bi-people me-2"></i>User Approvals</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/flats"><i class="bi bi-houses me-2"></i>Manage Flats</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/categories"><i class="bi bi-tags me-2"></i>Categories</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/vendors"><i class="bi bi-truck me-2"></i>Vendors</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/sla"><i class="bi bi-stopwatch me-2"></i>SLA Rules</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/audit"><i class="bi bi-journal-text me-2"></i>System Audit Logs</a></li>
                            </ul>
                        </li>
                    </c:if>

                    <!-- Notices for everyone -->
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/notices">
                            <i class="bi bi-megaphone me-1"></i> Notices
                        </a>
                    </li>
                </c:if>
            </ul>

            <ul class="navbar-nav ms-auto align-items-center gap-2">
                <c:choose>
                    <c:when test="${not empty currentUser}">
                        <!-- Notification Bell -->
                        <li class="nav-item">
                            <a class="nav-link position-relative px-2" href="${pageContext.request.contextPath}/notifications">
                                <i class="bi bi-bell fs-5"></i>
                                <c:if test="${unreadCount > 0}">
                                    <span class="position-absolute top-1 start-100 translate-middle badge rounded-pill bg-danger">
                                        ${unreadCount}
                                    </span>
                                </c:if>
                            </a>
                        </li>

                        <!-- User Profile Dropdown -->
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle d-flex align-items-center gap-2 text-white" href="#" role="button" data-bs-toggle="dropdown">
                                <span class="badge bg-primary text-uppercase">${currentUser.role}</span>
                                <span>${currentUser.name}</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow">
                                <li class="dropdown-header text-muted small">Flat: ${currentUser.formattedFlat}</li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Logout</a></li>
                            </ul>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item">
                            <a class="btn btn-outline-light btn-sm px-3" href="${pageContext.request.contextPath}/login">Login</a>
                        </li>
                        <li class="nav-item">
                            <a class="btn btn-primary btn-sm px-3" href="${pageContext.request.contextPath}/register">Register</a>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>

<div class="main-content py-4">
    <div class="container-fluid px-lg-4">
        <!-- Toast / Alert Flash Messages -->
        <c:if test="${not empty param.msg}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> ${param.msg}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> ${param.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
