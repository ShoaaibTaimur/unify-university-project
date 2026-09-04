<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="unify.Models.*, unify.UserDAO, unify.AppDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    List<User> users = UserDAO.getAllUsers();
    List<Department> departments = AppDAO.getDepartments();
    List<Batch> batches = AppDAO.getBatches(null);
    List<Section> sections = AppDAO.getSections(null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Users — UNIFY Admin</title>
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
        h1 { font-size: 2rem; font-weight: 600; letter-spacing: -0.02em; }
        .subtitle { font-size: 0.875rem; color: var(--muted-fg); margin-top: 0.25rem; }
        .layout { display: grid; grid-template-columns: 22rem 1fr; gap: 1.5rem; margin-top: 2rem; }
        @media(max-width:900px){ .layout { grid-template-columns: 1fr; } }
        .card { background: white; border: 1.5px solid var(--border); border-radius: 1.25rem; padding: 1.5rem; box-shadow: 0 1px 2px rgba(128,0,0,0.04); }
        .card h3 { font-size: 1rem; font-weight: 600; margin-bottom: 1.25rem; }
        .form-group { margin-bottom: 0.875rem; }
        .form-label { font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; color: var(--muted-fg); display: block; margin-bottom: 0.35rem; }
        input, select { width: 100%; height: 2.25rem; border: 1.5px solid var(--border); border-radius: 0.625rem; padding: 0 0.75rem; font-size: 0.875rem; font-family: inherit; background: white; color: var(--fg); }
        input:focus, select:focus { outline: none; border-color: var(--primary); }
        .btn-primary { width: 100%; height: 2.25rem; background: var(--primary); color: white; border: none; border-radius: 0.625rem; font-size: 0.875rem; font-weight: 600; font-family: inherit; cursor: pointer; margin-top: 0.5rem; }
        .btn-primary:hover { background: var(--primary-deep); }
        table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
        thead th { padding: 0.75rem 1rem; text-align: left; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: var(--muted-fg); background: var(--muted); border-bottom: 1.5px solid var(--border); }
        tbody td { padding: 0.75rem 1rem; border-bottom: 1px solid var(--border); }
        tbody tr:last-child td { border-bottom: none; }
        .user-name { font-weight: 600; }
        .user-email { font-size: 0.75rem; color: var(--muted-fg); }
        .role-badge { font-size: 0.65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; background: #fff0f0; color: var(--primary); border: 1px solid #fcc; border-radius: 999px; padding: 0.15rem 0.5rem; }
        .btn-delete { background: none; border: none; font-size: 0.8rem; font-weight: 500; color: #c0392b; cursor: pointer; font-family: inherit; }
        .btn-delete:hover { color: var(--primary-deep); text-decoration: underline; }
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
            <a href="index.jsp" class="nav-link">Public Home</a>
            <a href="dashboard.jsp" class="nav-link">Dashboard</a>
            <a href="users.jsp" class="nav-link active">Manage Users</a>
            <a href="hierarchy.jsp" class="nav-link">Organization</a>
            <a href="activity.jsp" class="nav-link">Add Activity</a>
            <a href="password.jsp" class="nav-link">Change Password</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="sidebar-logout">Sign out</a>
    </aside>

    <main class="main">
        <h1>Users</h1>
        <p class="subtitle">Manage CRs, Teachers, and Admins across the university.</p>

        <div class="layout">
            <!-- Create user form -->
            <div class="card">
                <h3>Create New Account</h3>
                <form action="${pageContext.request.contextPath}/users" method="POST">
                    <input type="hidden" name="action" value="create">
                    <div class="form-group">
                        <label class="form-label">Full Name</label>
                        <input type="text" name="name" required placeholder="John Doe">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Email Address</label>
                        <input type="email" name="email" required placeholder="user@unify.edu">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Password</label>
                        <input type="password" name="password" required placeholder="Minimum 6 characters">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Role</label>
                        <select name="role" required>
                            <option value="cr">Class Representative (CR)</option>
                            <option value="teacher">Teacher</option>
                            <option value="admin">System Admin</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Department</label>
                        <select name="departmentId">
                            <option value="">None</option>
                            <% for (Department d : departments) { %>
                                <option value="<%= d.id %>"><%= d.name %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Batch</label>
                        <select name="batchId">
                            <option value="">None</option>
                            <% for (Batch b : batches) { %>
                                <option value="<%= b.id %>"><%= b.name %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Section</label>
                        <select name="sectionId">
                            <option value="">None</option>
                            <% for (Section s : sections) { %>
                                <option value="<%= s.id %>"><%= s.name %></option>
                            <% } %>
                        </select>
                    </div>
                    <button type="submit" class="btn-primary">Create User</button>
                </form>
            </div>

            <!-- Users table -->
            <div class="card" style="padding: 0; overflow: hidden;">
                <div style="padding: 1.5rem 1.5rem 0;">
                    <h3>All Accounts (<%= users.size() %>)</h3>
                </div>
                <div style="overflow-x:auto; margin-top: 0.75rem;">
                    <table>
                        <thead>
                            <tr>
                                <th>Name & Email</th>
                                <th>Role</th>
                                <th style="text-align:right">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (User u : users) { %>
                                <tr>
                                    <td>
                                        <div class="user-name"><%= u.name %></div>
                                        <div class="user-email"><%= u.email %></div>
                                    </td>
                                    <td><span class="role-badge"><%= u.role %></span></td>
                                    <td style="text-align:right">
                                        <% if (!u.id.equals(currentUser.id)) { %>
                                            <form action="${pageContext.request.contextPath}/users" method="POST" style="display:inline">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="<%= u.id %>">
                                                <button type="submit" class="btn-delete">Delete</button>
                                            </form>
                                        <% } else { %>
                                            <span style="font-size:0.75rem;color:var(--muted-fg)">You</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
