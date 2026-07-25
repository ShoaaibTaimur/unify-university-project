<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="unify.Models.*, unify.AppDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    List<Department> departments = AppDAO.getDepartments();
    List<Batch> batches = AppDAO.getBatches(null);
    List<Section> sections = AppDAO.getSections(null);
    // For the Add Section form: filter batches by selected dept
    String secFilterDept = request.getParameter("secDept");
    List<Batch> secBatches = (secFilterDept != null && !secFilterDept.isEmpty())
        ? AppDAO.getBatches(secFilterDept) : AppDAO.getBatches(null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Organization — UNIFY Admin</title>
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
        h2 { font-size: 1.5rem; font-weight: 600; letter-spacing: -0.02em; }
        .subtitle { font-size: 0.875rem; color: var(--muted-fg); margin-top: 0.25rem; }
        .form-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; margin-top: 1.5rem; }
        @media(max-width:900px){ .form-grid { grid-template-columns: 1fr; } }
        .form-card { background: white; border: 1.5px solid var(--border); border-radius: 1.25rem; padding: 1.25rem; box-shadow: 0 1px 2px rgba(128,0,0,0.04), 0 8px 24px -12px rgba(128,0,0,0.12); }
        .form-card-header { display: flex; align-items: center; gap: 0.625rem; margin-bottom: 1rem; }
        .form-card-icon { width: 2.25rem; height: 2.25rem; border-radius: 0.75rem; background: #fff0f0; color: var(--primary); display: flex; align-items: center; justify-content: center; font-size: 1rem; }
        .form-card-title { font-size: 0.9rem; font-weight: 600; }
        .form-group { margin-bottom: 0.625rem; }
        .form-label { font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; color: var(--muted-fg); display: block; margin-bottom: 0.3rem; }
        input, select { width: 100%; height: 2.25rem; border: 1.5px solid var(--border); border-radius: 0.625rem; padding: 0 0.75rem; font-size: 0.875rem; font-family: inherit; background: white; color: var(--fg); }
        input:focus, select:focus { outline: none; border-color: var(--primary); }
        .btn-add { width: 100%; height: 2.25rem; background: var(--primary); color: white; border: none; border-radius: 0.625rem; font-size: 0.875rem; font-weight: 600; font-family: inherit; cursor: pointer; margin-top: 0.375rem; }
        .btn-add:hover { background: var(--primary-deep); }
        .structure { margin-top: 2.5rem; }
        .dept-card { background: white; border: 1.5px solid var(--border); border-radius: 1.25rem; padding: 1.25rem; margin-bottom: 1rem; box-shadow: 0 1px 2px rgba(128,0,0,0.04), 0 8px 24px -12px rgba(128,0,0,0.12); }
        .dept-header { display: flex; align-items: center; justify-content: space-between; }
        .dept-name-wrap { display: flex; align-items: center; gap: 0.75rem; }
        .dept-icon { width: 2.5rem; height: 2.5rem; border-radius: 0.75rem; background: #fff0f0; color: var(--primary); display: flex; align-items: center; justify-content: center; font-size: 1.25rem; }
        .dept-name { font-size: 1.05rem; font-weight: 600; }
        .dept-count { font-size: 0.75rem; color: var(--muted-fg); }
        .batch-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 0.75rem; margin-top: 1rem; }
        .batch-card { background: var(--bg); border: 1.5px solid var(--border); border-radius: 0.875rem; padding: 0.875rem; }
        .batch-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 0.625rem; }
        .batch-name { font-size: 0.875rem; font-weight: 600; }
        .sections-wrap { display: flex; flex-wrap: wrap; gap: 0.375rem; }
        .section-pill { background: var(--muted); border-radius: 999px; padding: 0.2rem 0.625rem; font-size: 0.75rem; font-weight: 500; color: var(--fg); display: inline-flex; align-items: center; gap: 0.375rem; }
        .btn-delete-sm { background: none; border: none; cursor: pointer; font-size: 0.7rem; color: var(--muted-fg); font-family: inherit; }
        .btn-delete-sm:hover { color: #c0392b; }
        .empty-card { background: white; border: 1.5px dashed var(--border); border-radius: 1.25rem; padding: 2.5rem; text-align: center; color: var(--muted-fg); font-size: 0.875rem; }
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
            <a href="users.jsp" class="nav-link">👥 Manage Users</a>
            <a href="hierarchy.jsp" class="nav-link active">🏛️ Organization</a>
            <a href="activity.jsp" class="nav-link">➕ Add Activity</a>
            <a href="password.jsp" class="nav-link">🔐 Change Password</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="sidebar-logout">Sign out</a>
    </aside>

    <main class="main">
        <h1>Organization</h1>
        <p class="subtitle">Departments, batches, and sections — manage everything in one place.</p>

        <!-- Add forms row -->
        <div class="form-grid">
            <!-- Add Department -->
            <form action="${pageContext.request.contextPath}/hierarchy" method="POST" class="form-card">
                <input type="hidden" name="type" value="department">
                <input type="hidden" name="action" value="create">
                <div class="form-card-header">
                    <div class="form-card-icon">🏢</div>
                    <div class="form-card-title">Add Department</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Name</label>
                    <input type="text" name="name" required placeholder="e.g. CSE">
                </div>
                <button type="submit" class="btn-add">Add Department</button>
            </form>

            <!-- Add Batch -->
            <form action="${pageContext.request.contextPath}/hierarchy" method="POST" class="form-card">
                <input type="hidden" name="type" value="batch">
                <input type="hidden" name="action" value="create">
                <div class="form-card-header">
                    <div class="form-card-icon">📚</div>
                    <div class="form-card-title">Add Batch</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Department</label>
                    <select name="departmentId" required>
                        <option value="">Select department</option>
                        <% for (Department d : departments) { %>
                            <option value="<%= d.id %>"><%= d.name %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Batch Name</label>
                    <input type="text" name="name" required placeholder="e.g. Batch 55">
                </div>
                <button type="submit" class="btn-add">Add Batch</button>
            </form>

            <!-- Add Section -->
            <div class="form-card">
                <%-- Step 1: filter batches by dept via GET --%>
                <form action="hierarchy.jsp" method="GET" style="margin-bottom:0.75rem;padding-bottom:0.75rem;border-bottom:1px solid var(--border)">
                    <div class="form-card-header">
                        <div class="form-card-icon">🎓</div>
                        <div class="form-card-title">Add Section</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">1. Filter by Department</label>
                        <select name="secDept" onchange="this.form.submit()">
                            <option value="">All Departments</option>
                            <% for (Department d : departments) { %>
                                <option value="<%= d.id %>" <%= d.id.equals(secFilterDept != null ? secFilterDept : "") ? "selected" : "" %>><%= d.name %></option>
                            <% } %>
                        </select>
                    </div>
                </form>
                <%-- Step 2: create section in the filtered batch --%>
                <form action="${pageContext.request.contextPath}/hierarchy" method="POST">
                    <input type="hidden" name="type" value="section">
                    <input type="hidden" name="action" value="create">
                    <div class="form-group">
                        <label class="form-label">2. Select Batch<% if (secFilterDept != null && !secFilterDept.isEmpty()) { %> — <span style="font-weight:400;text-transform:none"><%= secBatches.isEmpty() ? "no batches in this dept" : secBatches.size() + " available" %></span><% } %></label>
                        <select name="batchId" required>
                            <option value="">Select batch</option>
                            <% for (Batch b : secBatches) { %>
                                <%
                                    String bDeptName = "";
                                    for (Department dd : departments) { if (dd.id.equals(b.departmentId)) bDeptName = dd.name; }
                                %>
                                <option value="<%= b.id %>"><%= b.name %><% if (secFilterDept == null || secFilterDept.isEmpty()) { %> (<%= bDeptName %>)<% } %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">3. Section Name</label>
                        <input type="text" name="name" required placeholder="e.g. Section A">
                    </div>
                    <button type="submit" class="btn-add">Add Section</button>
                </form>
            </div>
        </div>

        <!-- Structure tree -->
        <div class="structure">
            <h2>Structure</h2>
            <p class="subtitle" style="margin-bottom:1.25rem">Every department, its batches, and their sections.</p>

            <% if (departments.isEmpty()) { %>
                <div class="empty-card">No departments yet. Add one above to get started.</div>
            <% } %>

            <% for (Department d : departments) { %>
                <div class="dept-card">
                    <div class="dept-header">
                        <div class="dept-name-wrap">
                            <div class="dept-icon">🏢</div>
                            <div>
                                <div class="dept-name"><%= d.name %></div>
                                <div class="dept-count">
                                    <% int batchCount = 0; for (Batch b : batches) { if (b.departmentId.equals(d.id)) batchCount++; } %>
                                    <%= batchCount %> batch<%= batchCount == 1 ? "" : "es" %>
                                </div>
                            </div>
                        </div>
                        <form action="${pageContext.request.contextPath}/hierarchy" method="POST">
                            <input type="hidden" name="type" value="department">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%= d.id %>">
                            <button type="submit" class="btn-delete-sm">🗑 Delete</button>
                        </form>
                    </div>

                    <div class="batch-grid">
                        <% boolean hasBatch = false; %>
                        <% for (Batch b : batches) { if (!b.departmentId.equals(d.id)) continue; hasBatch = true; %>
                            <div class="batch-card">
                                <div class="batch-header">
                                    <div style="display:flex;align-items:center;gap:0.5rem">
                                        <span style="color:var(--primary);font-size:0.875rem">📚</span>
                                        <span class="batch-name"><%= b.name %></span>
                                        <span style="font-size:0.7rem;color:var(--muted-fg)">
                                            (<% int sc = 0; for (Section s : sections) { if (s.batchId.equals(b.id)) sc++; } %><%= sc %> sections)
                                        </span>
                                    </div>
                                    <form action="${pageContext.request.contextPath}/hierarchy" method="POST">
                                        <input type="hidden" name="type" value="batch">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= b.id %>">
                                        <button type="submit" class="btn-delete-sm">🗑</button>
                                    </form>
                                </div>
                                <div class="sections-wrap">
                                    <% boolean hasSec = false; %>
                                    <% for (Section s : sections) { if (!s.batchId.equals(b.id)) continue; hasSec = true; %>
                                        <div class="section-pill">
                                            <span>🎓</span>
                                            <%= s.name %>
                                            <form action="${pageContext.request.contextPath}/hierarchy" method="POST" style="display:inline">
                                                <input type="hidden" name="type" value="section">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="<%= s.id %>">
                                                <button type="submit" class="btn-delete-sm">×</button>
                                            </form>
                                        </div>
                                    <% } %>
                                    <% if (!hasSec) { %><span style="font-size:0.75rem;color:var(--muted-fg)">No sections yet.</span><% } %>
                                </div>
                            </div>
                        <% } %>
                        <% if (!hasBatch) { %>
                            <div style="border:1.5px dashed var(--border);border-radius:0.75rem;padding:0.875rem;font-size:0.8rem;color:var(--muted-fg)">No batches in this department yet.</div>
                        <% } %>
                    </div>
                </div>
            <% } %>
        </div>
    </main>
</body>
</html>
