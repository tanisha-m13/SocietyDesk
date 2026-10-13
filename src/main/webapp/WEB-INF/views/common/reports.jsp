<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Reports & SLA Compliance");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h2 class="fw-bold mb-0">Reports &amp; SLA Compliance Analytics</h2>
        <span class="text-muted">Key Performance Indicators, category bottlenecks, and resolution efficiency</span>
    </div>
</div>

<!-- KPI Cards -->
<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-success">
            <div class="text-muted small text-uppercase fw-semibold">SLA Compliance Rate</div>
            <div class="fs-2 fw-bold text-success mt-1">${metrics.slaCompliance}%</div>
            <small class="text-muted">Tickets resolved within target hours</small>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-primary">
            <div class="text-muted small text-uppercase fw-semibold">Avg Resolution Speed</div>
            <div class="fs-2 fw-bold text-dark mt-1">${metrics.avgResolutionHours} hrs</div>
            <small class="text-muted">From creation to official closure</small>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-danger">
            <div class="text-muted small text-uppercase fw-semibold">Escalated Tickets</div>
            <div class="fs-2 fw-bold text-danger mt-1">${metrics.escalatedTickets}</div>
            <small class="text-muted">Missed SLA deadlines triggered</small>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card p-3 border-start border-4 border-warning">
            <div class="text-muted small text-uppercase fw-semibold">Resident Satisfaction</div>
            <div class="fs-2 fw-bold text-dark mt-1">${metrics.avgRating} <span class="fs-6 text-muted">/ 5.0</span></div>
            <small class="text-muted">Feedback rating average</small>
        </div>
    </div>
</div>

<!-- Chart.js Visualizations Grid -->
<div class="row g-4 mb-4">
    <div class="col-lg-6">
        <div class="card shadow-sm p-4 h-100 bg-white">
            <h5 class="fw-bold mb-3"><i class="bi bi-pie-chart-fill text-primary me-2"></i>Complaints by Status Lifecycle</h5>
            <div style="position: relative; height: 320px;">
                <canvas id="statusChart"></canvas>
            </div>
        </div>
    </div>

    <div class="col-lg-6">
        <div class="card shadow-sm p-4 h-100 bg-white">
            <h5 class="fw-bold mb-3"><i class="bi bi-bar-chart-fill text-success me-2"></i>Complaints Volume by Category</h5>
            <div style="position: relative; height: 320px;">
                <canvas id="categoryChart"></canvas>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function () {
    fetch('${pageContext.request.contextPath}/api/reports/chart-data')
        .then(response => response.json())
        .then(data => {
            // 1. Status Chart (Doughnut)
            const statusLabels = Object.keys(data.statusCounts);
            const statusValues = Object.values(data.statusCounts);

            const statusColors = {
                'OPEN': '#3b82f6',
                'ASSIGNED': '#06b6d4',
                'IN_PROGRESS': '#f59e0b',
                'RESOLVED': '#10b981',
                'CLOSED': '#64748b',
                'REOPENED': '#ef4444'
            };

            const bgColors = statusLabels.map(label => statusColors[label] || '#94a3b8');

            new Chart(document.getElementById('statusChart'), {
                type: 'doughnut',
                data: {
                    labels: statusLabels,
                    datasets: [{
                        data: statusValues,
                        backgroundColor: bgColors,
                        borderWidth: 2,
                        borderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom'
                        }
                    }
                }
            });

            // 2. Category Chart (Bar)
            const catLabels = Object.keys(data.categoryCounts);
            const catValues = Object.values(data.categoryCounts);

            new Chart(document.getElementById('categoryChart'), {
                type: 'bar',
                data: {
                    labels: catLabels,
                    datasets: [{
                        label: 'Total Tickets',
                        data: catValues,
                        backgroundColor: '#3b82f6',
                        borderRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: { precision: 0 }
                        }
                    }
                }
            });
        })
        .catch(err => console.error("Error loading chart data:", err));
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
