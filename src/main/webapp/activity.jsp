<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="unify.Models.*, unify.AppDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    boolean isCR = "cr".equalsIgnoreCase(currentUser.role);
    boolean isTeacher = "teacher".equalsIgnoreCase(currentUser.role);
    boolean isAdmin = "admin".equalsIgnoreCase(currentUser.role);

    List<Department> departments = AppDAO.getDepartments();

    // Determine active department filter
    String selectedDept = request.getParameter("departmentId");
    if (isCR || isTeacher) {
        selectedDept = currentUser.departmentId;
    }
    if (selectedDept == null) selectedDept = "";

    // Determine active batch filter
    String selectedBatch = request.getParameter("batchId");
    if (isCR) {
        selectedBatch = currentUser.batchId;
    }
    if (selectedBatch == null) selectedBatch = "";

    // Determine active section filter
    String selectedSec = request.getParameter("sectionId");
    if (isCR) {
        selectedSec = currentUser.sectionId;
    }
    if (selectedSec == null) selectedSec = "";

    List<Batch> batches = (!selectedDept.isEmpty()) ? AppDAO.getBatches(selectedDept) : AppDAO.getBatches(null);
    List<Section> sections = (!selectedBatch.isEmpty()) ? AppDAO.getSections(selectedBatch) : AppDAO.getSections(null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Activity — UNIFY</title>
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
        .form-card { background: white; border: 1.5px solid var(--border); border-radius: 1.25rem; padding: 2rem; max-width: 48rem; box-shadow: 0 1px 2px rgba(128,0,0,0.04), 0 8px 24px -12px rgba(128,0,0,0.12); }
        h1 { font-size: 1.5rem; font-weight: 600; letter-spacing: -0.02em; margin-bottom: 0.25rem; }
        .role-hint { font-size: 0.8rem; color: var(--muted-fg); margin-bottom: 1.5rem; }
        .role-hint span { color: var(--primary); font-weight: 600; }
        .grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; margin-bottom: 1rem; }
        .grid-2 { display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem; margin-bottom: 1rem; }
        @media(max-width:640px){ .grid-3 { grid-template-columns: 1fr; } .grid-2 { grid-template-columns: 1fr; } }
        .form-group { margin-bottom: 1rem; }
        .form-label { font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; color: var(--muted-fg); display: block; margin-bottom: 0.35rem; }
        input, select, textarea { width: 100%; border: 1.5px solid var(--border); border-radius: 0.625rem; padding: 0.5rem 0.75rem; font-size: 0.875rem; font-family: inherit; background: white; color: var(--fg); }
        input:disabled, select:disabled { background: var(--muted); color: var(--muted-fg); cursor: not-allowed; }
        input, select { height: 2.25rem; }
        textarea { resize: vertical; min-height: 80px; }
        input:focus, select:focus, textarea:focus { outline: none; border-color: var(--primary); }
        .form-actions { display: flex; justify-content: flex-end; gap: 0.75rem; padding-top: 1.25rem; border-top: 1px solid var(--border); margin-top: 0.5rem; }
        .btn-cancel { height: 2.25rem; border: 1.5px solid var(--border); border-radius: 0.625rem; padding: 0 1.25rem; font-size: 0.875rem; font-weight: 500; font-family: inherit; cursor: pointer; background: white; color: var(--muted-fg); text-decoration: none; display: inline-flex; align-items: center; }
        .btn-primary { height: 2.25rem; background: var(--primary); color: white; border: none; border-radius: 0.625rem; padding: 0 1.5rem; font-size: 0.875rem; font-weight: 600; font-family: inherit; cursor: pointer; }
        .btn-primary:hover { background: var(--primary-deep); }
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
            <% if (isAdmin) { %>
                <a href="users.jsp" class="nav-link">Manage Users</a>
                <a href="hierarchy.jsp" class="nav-link">Organization</a>
            <% } %>
            <a href="activity.jsp" class="nav-link active">Add Activity</a>
            <a href="password.jsp" class="nav-link">Change Password</a>
        </nav>
        <a href="${pageContext.request.contextPath}/logout" class="sidebar-logout">Sign out</a>
    </aside>

    <main class="main">
        <div class="form-card">
            <h1>Create Academic Activity</h1>
            <p class="role-hint">
                <% if (isCR) { %>
                    Restricted to your assigned class section.
                <% } else if (isTeacher) { %>
                    Restricted to your assigned department.
                <% } else { %>
                    System Admin — full university access.
                <% } %>
            </p>

            <%-- GET form helper for updating dropdown filters --%>
            <% if (!isCR) { %>
                <form id="filterForm" method="GET" action="activity.jsp" style="display:none"></form>
            <% } %>

            <form action="${pageContext.request.contextPath}/activity" method="POST">
                <input type="hidden" name="action" value="create">

                <div class="grid-3">
                    <%-- Department Selector --%>
                    <div class="form-group">
                        <label class="form-label">Department</label>
                        <% if (isCR || isTeacher) { %>
                            <select disabled>
                                <% for (Department d : departments) { if (d.id.equals(selectedDept)) { %>
                                    <option selected><%= d.name %></option>
                                <% } } %>
                            </select>
                            <input type="hidden" name="departmentId" value="<%= selectedDept %>">
                        <% } else { %>
                            <select name="departmentId" required onchange="location.href='activity.jsp?departmentId='+this.value">
                                <option value="">Select Department</option>
                                <% for (Department d : departments) { %>
                                    <option value="<%= d.id %>" <%= d.id.equals(selectedDept) ? "selected" : "" %>><%= d.name %></option>
                                <% } %>
                            </select>
                        <% } %>
                    </div>

                    <%-- Batch Selector --%>
                    <div class="form-group">
                        <label class="form-label">Batch</label>
                        <% if (isCR) { %>
                            <select disabled>
                                <% for (Batch b : batches) { if (b.id.equals(selectedBatch)) { %>
                                    <option selected><%= b.name %></option>
                                <% } } %>
                            </select>
                            <input type="hidden" name="batchId" value="<%= selectedBatch %>">
                        <% } else { %>
                            <select name="batchId" required onchange="location.href='activity.jsp?departmentId=<%= selectedDept %>&batchId='+this.value">
                                <option value="">Select Batch</option>
                                <% for (Batch b : batches) { %>
                                    <option value="<%= b.id %>" <%= b.id.equals(selectedBatch) ? "selected" : "" %>><%= b.name %></option>
                                <% } %>
                            </select>
                        <% } %>
                    </div>

                    <%-- Section Selector --%>
                    <div class="form-group">
                        <label class="form-label">Section</label>
                        <% if (isCR) { %>
                            <select disabled>
                                <% for (Section s : sections) { if (s.id.equals(selectedSec)) { %>
                                    <option selected><%= s.name %></option>
                                <% } } %>
                            </select>
                            <input type="hidden" name="sectionId" value="<%= selectedSec %>">
                        <% } else { %>
                            <select name="sectionId" required>
                                <option value="">Select Section</option>
                                <% for (Section s : sections) { %>
                                    <option value="<%= s.id %>" <%= s.id.equals(selectedSec) ? "selected" : "" %>><%= s.name %></option>
                                <% } %>
                            </select>
                        <% } %>
                    </div>
                </div>

                <div class="grid-2">
                    <div class="form-group">
                        <label class="form-label">Activity Type</label>
                        <select name="activityType" required>
                            <option value="class-test">Class Test</option>
                            <option value="lab-test">Lab Test</option>
                            <option value="viva">Viva</option>
                            <option value="assignment">Assignment</option>
                            <option value="presentation">Presentation</option>
                            <option value="quiz">Quiz</option>
                            <option value="mid-exam">Mid Exam</option>
                            <option value="final-exam">Final Exam</option>
                            <option value="extra-class">Extra Class</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Subject Code / Name</label>
                        <input type="text" name="subject" required placeholder="CSE-3101">
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Title</label>
                    <input type="text" name="title" required placeholder="CT 1 on Database Systems">
                </div>

                <div class="grid-2">
                    <div class="form-group">
                        <label class="form-label">Room / Venue</label>
                        <input type="text" name="room" placeholder="Room 402">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Event Date</label>
                        <input type="date" name="eventDate">
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Description / Syllabus</label>
                    <textarea name="description" placeholder="Additional details, topics covered..."></textarea>
                </div>

                <div class="form-actions">
                    <a href="dashboard.jsp" class="btn-cancel">Cancel</a>
                    <button type="submit" class="btn-primary">Save Activity</button>
                </div>
            </form>
        </div>
    </main>
</body>
</html>
