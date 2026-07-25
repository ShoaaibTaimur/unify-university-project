<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="unify.Models.*, unify.AppDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String deptId = request.getParameter("departmentId");
    String batchId = request.getParameter("batchId");
    String secId = request.getParameter("sectionId");

    List<Department> departments = AppDAO.getDepartments();
    List<Batch> batches = AppDAO.getBatches(deptId);
    List<Section> sections = AppDAO.getSections(batchId);
    List<Activity> activities = AppDAO.getActivities(deptId, batchId, secId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UNIFY — Dashboard</title>
    <meta name="description" content="See today's activities, your next deadline, and what's coming up for your section.">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary:#800000; --primary-deep:#5C0011; --accent:#B8748A; --bg:#F8F8F8; --card:#fff; --border:#e8e0e0; --muted:#f3eded; --muted-fg:#8a7070; --fg:#2a1515; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--fg); min-height: 100vh; display: flex; }

        /* Sidebar */
        .sidebar { width: 15rem; background: white; border-right: 1.5px solid var(--border); padding: 1.5rem 0; display: flex; flex-direction: column; min-height: 100vh; position: fixed; top: 0; left: 0; z-index: 20; }
        .sidebar-logo { font-size: 1.5rem; font-weight: 700; color: var(--primary); letter-spacing: -0.02em; padding: 0 1.25rem 1.5rem; border-bottom: 1px solid var(--border); }
        .sidebar-user { padding: 1rem 1.25rem; display: flex; flex-direction: column; gap: 0.2rem; border-bottom: 1px solid var(--border); }
        .sidebar-user-name { font-size: 0.875rem; font-weight: 600; }
        .sidebar-user-role { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: white; background: var(--primary); padding: 0.15rem 0.5rem; border-radius: 999px; display: inline-block; }
        .sidebar nav { flex: 1; padding: 1rem 0; }
        .nav-link { display: flex; align-items: center; gap: 0.625rem; padding: 0.625rem 1.25rem; font-size: 0.875rem; font-weight: 500; color: var(--muted-fg); text-decoration: none; transition: all 0.15s; border-left: 3px solid transparent; }
        .nav-link:hover { color: var(--fg); background: var(--muted); }
        .nav-link.active { color: var(--primary); background: #fff0f0; border-left-color: var(--primary); font-weight: 600; }
        .sidebar-logout { margin: 1rem 1.25rem 0; padding: 0.5rem 1rem; border: 1.5px solid var(--border); border-radius: 0.75rem; font-size: 0.8rem; font-weight: 500; color: var(--muted-fg); text-align: center; text-decoration: none; transition: all 0.15s; }
        .sidebar-logout:hover { border-color: var(--primary); color: var(--primary); }

        /* Main content */
        .main { margin-left: 15rem; flex: 1; padding: 2.5rem 2rem; }

        /* Hero */
        .hero-band { background: linear-gradient(90deg, #fff0f0 0%, #F8F8F8 100%); border-bottom: 1px solid var(--border); padding: 2.5rem 2rem; margin: -2.5rem -2rem 2.5rem; }
        .hero-label { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.1em; color: var(--accent); margin-bottom: 0.5rem; }
        .hero-title { font-size: 2.25rem; font-weight: 600; letter-spacing: -0.02em; }
        .hero-title span.primary { color: var(--primary); }
        .hero-sub { font-size: 0.9rem; color: var(--muted-fg); margin-top: 0.4rem; }
        .hero-actions { display: flex; gap: 0.75rem; margin-top: 1.5rem; flex-wrap: wrap; }

        /* Filter */
        .filter-bar { background: white; border: 1.5px solid var(--border); border-radius: 1rem; padding: 1.25rem; margin-bottom: 1.75rem; display: grid; grid-template-columns: 1fr 1fr 1fr auto; gap: 0.75rem; align-items: end; }
        @media(max-width:768px){ .filter-bar { grid-template-columns: 1fr 1fr; } }
        .filter-label { font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; color: var(--muted-fg); margin-bottom: 0.35rem; }
        select { width: 100%; height: 2.25rem; border: 1.5px solid var(--border); border-radius: 0.625rem; padding: 0 0.625rem; font-size: 0.875rem; font-family: inherit; background: white; color: var(--fg); }
        select:focus { outline: none; border-color: var(--primary); }
        .btn-filter { height: 2.25rem; background: var(--muted); border: 1.5px solid var(--border); border-radius: 0.625rem; padding: 0 1rem; font-size: 0.8rem; font-weight: 600; font-family: inherit; cursor: pointer; color: var(--fg); }
        .btn-filter:hover { background: var(--border); }
        .btn-primary { height: 2.25rem; background: var(--primary); color: white; border: none; border-radius: 0.625rem; padding: 0 1.25rem; font-size: 0.875rem; font-weight: 600; font-family: inherit; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; }
        .btn-primary:hover { background: var(--primary-deep); }

        /* Activity grid */
        .section-title { font-size: 1.125rem; font-weight: 600; letter-spacing: -0.01em; margin-bottom: 0.875rem; }
        .activity-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1rem; }
        .activity-card { background: white; border: 1.5px solid var(--border); border-radius: 1rem; padding: 1.25rem; box-shadow: 0 1px 2px rgba(128,0,0,0.04), 0 8px 24px -12px rgba(128,0,0,0.12); display: flex; flex-direction: column; }
        .activity-card:hover { border-color: var(--accent); }
        .activity-badge { font-size: 0.65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; background: #fff0f0; color: var(--primary); border: 1px solid #fcc; border-radius: 999px; padding: 0.2rem 0.625rem; display: inline-block; }
        .activity-date { font-size: 0.75rem; color: var(--muted-fg); }
        .activity-meta { display: flex; align-items: center; justify-content: space-between; margin-bottom: 0.75rem; }
        .activity-title { font-size: 1rem; font-weight: 600; margin-bottom: 0.25rem; }
        .activity-subject { font-size: 0.75rem; color: var(--muted-fg); font-weight: 500; margin-bottom: 0.5rem; }
        .activity-desc { font-size: 0.8rem; color: var(--muted-fg); flex: 1; }
        .activity-actions { margin-top: 1rem; padding-top: 0.75rem; border-top: 1px solid var(--border); display: flex; justify-content: flex-end; }
        .btn-delete { background: none; border: none; font-size: 0.75rem; font-weight: 500; color: #c0392b; cursor: pointer; font-family: inherit; }
        .btn-delete:hover { color: var(--primary-deep); text-decoration: underline; }
        .empty-state { background: white; border: 1.5px dashed var(--border); border-radius: 1.25rem; padding: 4rem 2rem; text-align: center; color: var(--muted-fg); font-size: 0.9rem; }
        .empty-icon { font-size: 2rem; margin-bottom: 1rem; opacity: 0.4; }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-logo">UNIFY</div>
        <div class="sidebar-user">
            <div class="sidebar-user-name"><%= currentUser.name %></div>
            <span class="sidebar-user-role"><%= currentUser.role %></span>
        </div>
        <nav>
            <a href="index.jsp" class="nav-link">🌐 Public Home</a>
            <a href="dashboard.jsp" class="nav-link active">🏠 Dashboard</a>
            <% if ("admin".equalsIgnoreCase(currentUser.role)) { %>
                <a href="users.jsp" class="nav-link">👥 Manage Users</a>
                <a href="hierarchy.jsp" class="nav-link">🏛️ Organization</a>
            <% } %>
            <a href="activity.jsp" class="nav-link">➕ Add Activity</a>
            <a href="password.jsp" class="nav-link">🔐 Change Password</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="sidebar-logout">Sign out</a>
    </aside>

    <!-- Main -->
    <main class="main">
        <!-- Hero band -->
        <div class="hero-band">
            <p class="hero-label">Your class</p>
            <h1 class="hero-title">Academic <span class="primary">Activities</span></h1>
            <p class="hero-sub">Everything happening in your department — at a glance.</p>
            <div class="hero-actions">
                <% if ("admin".equalsIgnoreCase(currentUser.role) || "teacher".equalsIgnoreCase(currentUser.role) || "cr".equalsIgnoreCase(currentUser.role)) { %>
                    <a href="activity.jsp" class="btn-primary">+ Add New Activity</a>
                <% } %>
            </div>
        </div>

        <!-- Filter -->
        <form method="GET" action="dashboard.jsp" class="filter-bar">
            <div>
                <div class="filter-label">Department</div>
                <select name="departmentId">
                    <option value="">All Departments</option>
                    <% for (Department d : departments) { %>
                        <option value="<%= d.id %>" <%= d.id.equals(deptId != null ? deptId : "") ? "selected" : "" %>><%= d.name %></option>
                    <% } %>
                </select>
            </div>
            <div>
                <div class="filter-label">Batch</div>
                <select name="batchId">
                    <option value="">All Batches</option>
                    <% for (Batch b : batches) { %>
                        <option value="<%= b.id %>" <%= b.id.equals(batchId != null ? batchId : "") ? "selected" : "" %>><%= b.name %></option>
                    <% } %>
                </select>
            </div>
            <div>
                <div class="filter-label">Section</div>
                <select name="sectionId">
                    <option value="">All Sections</option>
                    <% for (Section s : sections) { %>
                        <option value="<%= s.id %>" <%= s.id.equals(secId != null ? secId : "") ? "selected" : "" %>><%= s.name %></option>
                    <% } %>
                </select>
            </div>
            <div style="display:flex;gap:0.5rem">
                <button type="submit" class="btn-filter">Filter</button>
                <a href="dashboard.jsp" class="btn-filter" style="display:inline-flex;align-items:center;text-decoration:none">Reset</a>
            </div>
        </form>

        <!-- Activity cards -->
        <div class="section-title">All Activities (<%= activities.size() %>)</div>

        <% if (activities.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon">🎉</div>
                <div>No activities found matching criteria.</div>
            </div>
        <% } else { %>
            <div class="activity-grid">
                <% for (Activity act : activities) { %>
                    <div class="activity-card">
                        <div class="activity-meta">
                            <span class="activity-badge"><%= act.activityType.replace("-", " ") %></span>
                            <% if (act.eventDate != null && !act.eventDate.isEmpty()) { %>
                                <span class="activity-date"><%= act.eventDate %></span>
                            <% } %>
                        </div>
                        <div class="activity-title"><%= act.title %></div>
                        <div class="activity-subject"><%= act.subject %><%= (act.room != null && !act.room.isEmpty()) ? " · " + act.room : "" %></div>
                        <% if (act.description != null && !act.description.isEmpty()) { %>
                            <div class="activity-desc"><%= act.description %></div>
                        <% } %>
                        <% if ("admin".equalsIgnoreCase(currentUser.role) || currentUser.id.equals(act.createdBy)) { %>
                            <div class="activity-actions">
                                <form action="${pageContext.request.contextPath}/activity" method="POST">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= act.id %>">
                                    <button type="submit" class="btn-delete">Delete Activity</button>
                                </form>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>
        <% } %>
    </main>
</body>
</html>
