<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="unify.Models.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Change Password — UNIFY</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary:#800000; --primary-deep:#5C0011; --accent:#B8748A; --bg:#F8F8F8; --card:#fff; --border:#e8e0e0; --muted:#f3eded; --muted-fg:#8a7070; --fg:#2a1515; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--fg); min-height: 100vh; display: flex; }
        .sidebar { width: 15rem; background: white; border-right: 1.5px solid var(--border); padding: 1.5rem 0; display: flex; flex-direction: column; min-height: 100vh; position: fixed; top: 0; left: 0; z-index: 20; }
        .sidebar-logo { font-size: 1.5rem; font-weight: 700; color: var(--primary); letter-spacing: -0.02em; padding: 0 1.25rem 1.5rem; border-bottom: 1px solid var(--border); }
        .sidebar-user { padding: 1rem 1.25rem; display: flex; flex-direction: column; gap: 0.2rem; border-bottom: 1px solid var(--border); }
        .sidebar-user-name { font-size: 0.875rem; font-weight: 600; }
        .sidebar-user-role { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: white; background: var(--primary); padding: 0.15rem 0.5rem; border-radius: 999px; display: inline-block; }
        .sidebar nav { flex: 1; padding: 1rem 0; }
        .nav-link { display: flex; align-items: center; gap: 0.625rem; padding: 0.625rem 1.25rem; font-size: 0.875rem; font-weight: 500; color: var(--muted-fg); text-decoration: none; transition: all 0.15s; border-left: 3px solid transparent; }
        .nav-link:hover { color: var(--fg); background: var(--muted); }
        .nav-link.active { color: var(--primary); background: #fff0f0; border-left-color: var(--primary); font-weight: 600; }
        .sidebar-logout { margin: 1rem 1.25rem 0; padding: 0.5rem 1rem; border: 1.5px solid var(--border); border-radius: 0.75rem; font-size: 0.8rem; font-weight: 500; color: var(--muted-fg); text-align: center; text-decoration: none; }
        .sidebar-logout:hover { border-color: var(--primary); color: var(--primary); }
        .main { margin-left: 15rem; flex: 1; padding: 2.5rem 2rem; }
        .form-card { background: white; border: 1.5px solid var(--border); border-radius: 1.25rem; padding: 2rem; max-width: 28rem; box-shadow: 0 1px 2px rgba(128,0,0,0.04), 0 8px 24px -12px rgba(128,0,0,0.12); }
        h1 { font-size: 1.5rem; font-weight: 600; letter-spacing: -0.02em; margin-bottom: 1.5rem; }
        .form-group { margin-bottom: 1rem; }
        .form-label { font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; color: var(--muted-fg); display: block; margin-bottom: 0.35rem; }
        input { width: 100%; height: 2.25rem; border: 1.5px solid var(--border); border-radius: 0.625rem; padding: 0 0.75rem; font-size: 0.875rem; font-family: inherit; background: white; color: var(--fg); }
        input:focus { outline: none; border-color: var(--primary); }
        .btn-primary { width: 100%; height: 2.25rem; background: var(--primary); color: white; border: none; border-radius: 0.625rem; font-size: 0.875rem; font-weight: 600; font-family: inherit; cursor: pointer; margin-top: 0.5rem; }
        .btn-primary:hover { background: var(--primary-deep); }
        .alert-success { background: #f0fff4; border: 1.5px solid #b2f5cb; border-radius: 0.75rem; padding: 0.75rem 1rem; font-size: 0.875rem; color: #276749; margin-bottom: 1rem; }
        .alert-error { background: #fff0f0; border: 1.5px solid #fcc; border-radius: 0.75rem; padding: 0.75rem 1rem; font-size: 0.875rem; color: #c00; margin-bottom: 1rem; }
    </style>
</head>
<body>
    <aside class="sidebar">
        <div class="sidebar-logo">UNIFY</div>
        <div class="sidebar-user">
            <div class="sidebar-user-name"><%= currentUser.name %></div>
            <span class="sidebar-user-role"><%= currentUser.role %></span>
        </div>
        <nav>
            <a href="index.jsp" class="nav-link">🌐 Public Home</a>
            <a href="dashboard.jsp" class="nav-link">🏠 Dashboard</a>
            <% if ("admin".equalsIgnoreCase(currentUser.role)) { %>
                <a href="users.jsp" class="nav-link">👥 Manage Users</a>
                <a href="hierarchy.jsp" class="nav-link">🏛️ Organization</a>
            <% } %>
            <a href="activity.jsp" class="nav-link">➕ Add Activity</a>
            <a href="password.jsp" class="nav-link active">🔐 Change Password</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="sidebar-logout">Sign out</a>
    </aside>

    <main class="main">
        <div class="form-card">
            <h1>Change Password</h1>

            <% String msg = (String) request.getAttribute("msg"); %>
            <% String error = (String) request.getAttribute("error"); %>
            <% if (msg != null) { %>
                <div class="alert-success"><%= msg %></div>
            <% } %>
            <% if (error != null) { %>
                <div class="alert-error"><%= error %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/password" method="POST">
                <div class="form-group">
                    <label class="form-label">Current Password</label>
                    <input type="password" name="currentPassword" required placeholder="••••••••">
                </div>
                <div class="form-group">
                    <label class="form-label">New Password (min. 6 characters)</label>
                    <input type="password" name="newPassword" required minlength="6" placeholder="••••••••">
                </div>
                <button type="submit" class="btn-primary">Update Password</button>
            </form>
        </div>
    </main>
</body>
</html>
