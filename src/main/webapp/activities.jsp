<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="unify.Models.*, unify.AppDAO, java.util.List, java.util.Map, java.util.HashMap" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String deptId = request.getParameter("departmentId");
    String batchId = request.getParameter("batchId");
    String secId = request.getParameter("sectionId");
    String typeFilter = request.getParameter("activityType");
    String search = request.getParameter("search");

    List<Department> departments = AppDAO.getDepartments();
    List<Batch> batches = (deptId != null && !deptId.isEmpty()) ? AppDAO.getBatches(deptId) : AppDAO.getBatches(null);
    List<Section> sections = (batchId != null && !batchId.isEmpty()) ? AppDAO.getSections(batchId) : AppDAO.getSections(null);
    List<Activity> rawActivities = AppDAO.getActivities(deptId, batchId, secId);

    Map<String, String> deptMap = new HashMap<>();
    for (Department d : departments) deptMap.put(d.id, d.name);

    Map<String, String> batchMap = new HashMap<>();
    for (Batch b : AppDAO.getBatches(null)) batchMap.put(b.id, b.name);

    Map<String, String> secMap = new HashMap<>();
    for (Section s : AppDAO.getSections(null)) secMap.put(s.id, s.name);

    List<Activity> activities = new java.util.ArrayList<>();
    for (Activity a : rawActivities) {
        boolean matchType = (typeFilter == null || typeFilter.isEmpty() || typeFilter.equalsIgnoreCase(a.activityType));
        boolean matchSearch = true;
        if (search != null && !search.trim().isEmpty()) {
            String q = search.toLowerCase().trim();
            matchSearch = (a.title != null && a.title.toLowerCase().contains(q))
                       || (a.subject != null && a.subject.toLowerCase().contains(q))
                       || (a.room != null && a.room.toLowerCase().contains(q))
                       || (a.description != null && a.description.toLowerCase().contains(q));
        }
        if (matchType && matchSearch) {
            activities.add(a);
        }
    }

    String deptName = (deptId != null && deptMap.containsKey(deptId)) ? deptMap.get(deptId) : "";
    String batchName = (batchId != null && batchMap.containsKey(batchId)) ? batchMap.get(batchId) : "";
    String secName = (secId != null && secMap.containsKey(secId)) ? secMap.get(secId) : "";

    StringBuilder filterLabel = new StringBuilder();
    if (!deptName.isEmpty()) filterLabel.append(deptName);
    if (!batchName.isEmpty()) {
        if (filterLabel.length() > 0) filterLabel.append(" · ");
        filterLabel.append(batchName);
    }
    if (!secName.isEmpty()) {
        if (filterLabel.length() > 0) filterLabel.append(" · ");
        filterLabel.append(secName);
    }
    if (filterLabel.length() == 0) {
        filterLabel.append("All Departments & Sections");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>All Activities — UNIFY</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary:#800000; --primary-deep:#5C0011; --accent:#B8748A; --bg:#F8F8F8; --card:#fff; --border:#e8e0e0; --muted:#f3eded; --muted-fg:#8a7070; --fg:#2a1515; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--fg); min-height: 100vh; display: flex; flex-direction: column; }
        .topbar { background: white; border-bottom: 1.5px solid var(--border); padding: 0.875rem 2rem; display: flex; align-items: center; justify-content: space-between; position: sticky; top: 0; z-index: 30; }
        .topbar-brand { display: flex; align-items: center; gap: 2rem; }
        .topbar-logo { font-size: 1.25rem; font-weight: 700; color: var(--primary); text-decoration: none; letter-spacing: -0.02em; }
        .topbar-links { display: flex; align-items: center; gap: 1.25rem; }
        .topbar-link { font-size: 0.875rem; font-weight: 500; color: var(--muted-fg); text-decoration: none; transition: color 0.15s; }
        .topbar-link:hover, .topbar-link.active { color: var(--primary); font-weight: 600; }
        .topbar-actions { display: flex; align-items: center; gap: 0.875rem; }
        .btn-login { padding: 0.45rem 1rem; border-radius: 999px; background: var(--primary); color: white; text-decoration: none; font-size: 0.8125rem; font-weight: 600; transition: background 0.15s; }
        .btn-login:hover { background: var(--primary-deep); }
        .user-tag { font-size: 0.75rem; font-weight: 600; background: var(--muted); padding: 0.35rem 0.75rem; border-radius: 999px; border: 1px solid var(--border); }
        .container { width: 100%; max-width: 78rem; margin: 0 auto; padding: 2rem 1.5rem; flex: 1; }
        .page-header { margin-bottom: 1.75rem; display: flex; flex-wrap: wrap; align-items: flex-end; justify-content: space-between; gap: 1rem; }
        .page-title { font-size: 1.75rem; font-weight: 700; letter-spacing: -0.02em; }
        .page-title span { color: var(--primary); }
        .page-sub { font-size: 0.875rem; color: var(--muted-fg); margin-top: 0.3rem; }
        .filter-card { background: white; border: 1.5px solid var(--border); border-radius: 1.25rem; padding: 1.25rem 1.5rem; margin-bottom: 2rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03); }
        .filter-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1rem; align-items: flex-end; }
        .filter-field { display: flex; flex-direction: column; gap: 0.35rem; }
        .filter-field label { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-fg); }
        .filter-field select, .filter-field input { width: 100%; height: 2.35rem; border: 1.5px solid var(--border); border-radius: 0.625rem; padding: 0 0.75rem; font-size: 0.85rem; font-family: inherit; background: white; color: var(--fg); }
        .filter-field select:focus, .filter-field input:focus { outline: none; border-color: var(--primary); }
        .filter-btns { display: flex; gap: 0.5rem; }
        .btn-filter { height: 2.35rem; padding: 0 1.25rem; background: var(--primary); color: white; border: none; border-radius: 0.625rem; font-size: 0.85rem; font-weight: 600; font-family: inherit; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; text-decoration: none; }
        .btn-filter:hover { background: var(--primary-deep); }
        .btn-reset { height: 2.35rem; padding: 0 1rem; border: 1.5px solid var(--border); background: white; color: var(--muted-fg); border-radius: 0.625rem; font-size: 0.85rem; font-weight: 500; font-family: inherit; display: inline-flex; align-items: center; justify-content: center; text-decoration: none; }
        .btn-reset:hover { border-color: var(--primary); color: var(--primary); }
        .status-strip { display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.25rem; flex-wrap: wrap; gap: 0.75rem; }
        .status-badge { font-size: 0.8125rem; font-weight: 600; color: var(--primary); background: #fff0f0; border: 1px solid #fcc; padding: 0.3rem 0.85rem; border-radius: 999px; }
        .count-pill { font-size: 0.85rem; font-weight: 600; color: var(--muted-fg); }
        .activity-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1.25rem; }
        .activity-card { background: white; border: 1.5px solid var(--border); border-radius: 1.125rem; padding: 1.35rem; display: flex; flex-direction: column; transition: transform 0.15s, box-shadow 0.15s, border-color 0.15s; cursor: pointer; position: relative; }
        .activity-card:hover { transform: translateY(-3px); box-shadow: 0 10px 24px -10px rgba(128,0,0,0.12); border-color: var(--accent); }
        .card-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 0.625rem; }
        .badge-type { font-size: 0.6875rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; background: #fff0f0; color: var(--primary); border: 1px solid #fcc; border-radius: 999px; padding: 0.2rem 0.6rem; }
        .badge-date { font-size: 0.75rem; font-weight: 600; color: var(--muted-fg); background: var(--bg); border: 1px solid var(--border); border-radius: 999px; padding: 0.15rem 0.55rem; }
        .card-title { font-size: 1.0625rem; font-weight: 600; margin-bottom: 0.35rem; color: var(--fg); line-height: 1.35; }
        .card-sub { font-size: 0.8125rem; color: var(--primary); font-weight: 600; margin-bottom: 0.5rem; }
        .card-class { font-size: 0.72rem; color: var(--muted-fg); background: var(--bg); border: 1px solid var(--border); border-radius: 0.5rem; padding: 0.35rem 0.625rem; margin-bottom: 0.75rem; display: inline-flex; align-items: center; gap: 0.25rem; }
        .card-desc { font-size: 0.8125rem; color: var(--muted-fg); line-height: 1.45; flex: 1; margin-bottom: 0.75rem; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
        .card-footer { border-top: 1px solid var(--border); padding-top: 0.75rem; display: flex; align-items: center; justify-content: space-between; font-size: 0.75rem; color: var(--muted-fg); }
        .empty-state { background: white; border: 1.5px dashed var(--border); border-radius: 1.5rem; padding: 4rem 2rem; text-align: center; color: var(--muted-fg); }
        .empty-icon { font-size: 2.75rem; margin-bottom: 1rem; opacity: 0.5; }
        .modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.5); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 100; opacity: 0; pointer-events: none; transition: opacity 0.2s ease; padding: 1rem; }
        .modal-overlay.active { opacity: 1; pointer-events: auto; }
        .modal-card { background: white; border-radius: 1.5rem; border: 1.5px solid var(--border); width: 100%; max-width: 32rem; padding: 1.75rem; box-shadow: 0 20px 40px -10px rgba(0,0,0,0.25); transform: translateY(12px); transition: transform 0.2s ease; position: relative; max-height: 90vh; overflow-y: auto; }
        .modal-overlay.active .modal-card { transform: translateY(0); }
        .modal-close { position: absolute; top: 1.25rem; right: 1.25rem; width: 2rem; height: 2rem; border-radius: 999px; border: 1px solid var(--border); background: var(--bg); color: var(--fg); font-size: 1rem; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.15s; }
        .modal-close:hover { background: var(--primary); color: white; border-color: var(--primary); }
        .modal-badge { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; background: #fff0f0; color: var(--primary); border: 1px solid #fcc; border-radius: 999px; padding: 0.2rem 0.625rem; display: inline-block; margin-bottom: 0.75rem; }
        .modal-title { font-size: 1.35rem; font-weight: 700; letter-spacing: -0.01em; margin-bottom: 0.35rem; color: var(--fg); }
        .modal-subject { font-size: 0.9rem; font-weight: 600; color: var(--primary); margin-bottom: 1rem; }
        .modal-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; background: var(--bg); border: 1.5px solid var(--border); border-radius: 1rem; padding: 1rem; margin-bottom: 1.25rem; }
        .modal-item-label { font-size: 0.65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: var(--muted-fg); }
        .modal-item-val { font-size: 0.875rem; font-weight: 600; color: var(--fg); margin-top: 0.2rem; }
        .modal-desc-label { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: var(--muted-fg); margin-bottom: 0.35rem; }
        .modal-desc-text { font-size: 0.875rem; line-height: 1.5; color: var(--fg); white-space: pre-wrap; background: white; border: 1px solid var(--border); border-radius: 0.75rem; padding: 0.875rem; }
        footer { text-align: center; padding: 2rem; font-size: 0.75rem; color: var(--muted-fg); border-top: 1px solid var(--border); margin-top: 3rem; background: white; }
    </style>
</head>
<body>
    <nav class="topbar">
        <div class="topbar-brand">
            <a href="index.jsp" class="topbar-logo">UNIFY</a>
            <div class="topbar-links">
                <a href="index.jsp" class="topbar-link">Home</a>
                <a href="activities.jsp" class="topbar-link active">All Activities</a>
                <% if (currentUser != null) { %>
                    <a href="dashboard.jsp" class="topbar-link">Dashboard</a>
                <% } %>
            </div>
        </div>
        <div class="topbar-actions">
            <% if (currentUser != null) { %>
                <span class="user-tag"><%= currentUser.name %> (<%= currentUser.role %>)</span>
                <a href="${pageContext.request.contextPath}/logout" class="btn-reset" style="height:2rem;font-size:0.75rem">Sign out</a>
            <% } else { %>
                <a href="login.jsp" class="btn-login">Sign in →</a>
            <% } %>
        </div>
    </nav>

    <main class="container">
        <div class="page-header">
            <div>
                <h1 class="page-title">Academic <span>Activities</span></h1>
                <p class="page-sub">Public portal for class schedules, tests, labs, assignments, and exams.</p>
            </div>
            <% if (currentUser != null && ("admin".equalsIgnoreCase(currentUser.role) || "teacher".equalsIgnoreCase(currentUser.role) || "cr".equalsIgnoreCase(currentUser.role))) { %>
                <a href="activity.jsp" class="btn-filter" style="text-decoration:none">+ Add Activity</a>
            <% } %>
        </div>

        <form method="GET" action="activities.jsp" class="filter-card">
            <div class="filter-grid">
                <div class="filter-field">
                    <label>Department</label>
                    <select name="departmentId" onchange="location.href='activities.jsp?departmentId='+this.value">
                        <option value="">All Departments</option>
                        <% for (Department d : departments) { %>
                            <option value="<%= d.id %>" <%= d.id.equals(deptId != null ? deptId : "") ? "selected" : "" %>><%= d.name %></option>
                        <% } %>
                    </select>
                </div>
                <div class="filter-field">
                    <label>Batch</label>
                    <select name="batchId" onchange="location.href='activities.jsp?departmentId=<%= deptId != null ? deptId : "" %>&batchId='+this.value">
                        <option value="">All Batches</option>
                        <% for (Batch b : batches) { %>
                            <option value="<%= b.id %>" <%= b.id.equals(batchId != null ? batchId : "") ? "selected" : "" %>><%= b.name %></option>
                        <% } %>
                    </select>
                </div>
                <div class="filter-field">
                    <label>Section</label>
                    <select name="sectionId">
                        <option value="">All Sections</option>
                        <% for (Section s : sections) { %>
                            <option value="<%= s.id %>" <%= s.id.equals(secId != null ? secId : "") ? "selected" : "" %>><%= s.name %></option>
                        <% } %>
                    </select>
                </div>
                <div class="filter-field">
                    <label>Activity Type</label>
                    <select name="activityType">
                        <option value="">All Types</option>
                        <option value="class-test" <%= "class-test".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>Class Test</option>
                        <option value="lab-test" <%= "lab-test".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>Lab Test</option>
                        <option value="viva" <%= "viva".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>Viva</option>
                        <option value="assignment" <%= "assignment".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>Assignment</option>
                        <option value="presentation" <%= "presentation".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>Presentation</option>
                        <option value="quiz" <%= "quiz".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>Quiz</option>
                        <option value="mid-exam" <%= "mid-exam".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>Mid Exam</option>
                        <option value="final-exam" <%= "final-exam".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>Final Exam</option>
                        <option value="extra-class" <%= "extra-class".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>Extra Class</option>
                    </select>
                </div>
                <div class="filter-btns">
                    <button type="submit" class="btn-filter">Filter</button>
                    <a href="activities.jsp" class="btn-reset">Reset</a>
                </div>
            </div>
        </form>

        <div class="status-strip">
            <div class="status-badge">Showing: <%= filterLabel.toString() %></div>
            <div class="count-pill"><%= activities.size() %> activities found</div>
        </div>

        <% if (activities.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon">📭</div>
                <h3 style="font-size:1.15rem;font-weight:600;margin-bottom:0.5rem">No activities found</h3>
                <p style="font-size:0.875rem;margin-bottom:1.25rem">No activities match your current selection.</p>
                <a href="activities.jsp" class="btn-filter" style="display:inline-flex">View All Activities</a>
            </div>
        <% } else { %>
            <div class="activity-grid">
                <% for (Activity act : activities) { 
                    String actDept = act.departmentId != null && deptMap.containsKey(act.departmentId) ? deptMap.get(act.departmentId) : "";
                    String actBatch = act.batchId != null && batchMap.containsKey(act.batchId) ? batchMap.get(act.batchId) : "";
                    String actSec = act.sectionId != null && secMap.containsKey(act.sectionId) ? secMap.get(act.sectionId) : "";
                    String classLabel = actBatch + (!actBatch.isEmpty() && !actSec.isEmpty() ? " · " : "") + actSec;
                    if (classLabel.isEmpty()) classLabel = actDept;
                    if (classLabel.isEmpty()) classLabel = "All Classes";
                %>
                    <div class="activity-card" onclick="openActivityModal('<%= act.activityType.replace("-", " ") %>', '<%= act.title.replace("'","\\'") %>', '<%= act.subject.replace("'","\\'") %>', '<%= act.eventDate != null ? act.eventDate : "TBD" %>', '<%= act.room != null ? act.room.replace("'","\\'") : "N/A" %>', '<%= act.description != null ? act.description.replace("'","\\'").replace("\n","\\n") : "No description provided." %>', '<%= actDept.replace("'","\\'") %>', '<%= actBatch.replace("'","\\'") %>', '<%= actSec.replace("'","\\'") %>')">
                        <div class="card-top">
                            <span class="badge-type"><%= act.activityType.replace("-", " ") %></span>
                            <span class="badge-date"><%= (act.eventDate != null && !act.eventDate.isEmpty()) ? act.eventDate : "Date TBD" %></span>
                        </div>
                        <div class="card-title"><%= act.title %></div>
                        <div class="card-sub"><%= act.subject %><%= (act.room != null && !act.room.isEmpty()) ? " · " + act.room : "" %></div>
                        <div class="card-class">🎓 <%= classLabel %></div>
                        <% if (act.description != null && !act.description.isEmpty()) { %>
                            <div class="card-desc"><%= act.description %></div>
                        <% } %>
                        <div class="card-footer">
                            <span>Click for details</span>
                            <% if (currentUser != null && ("admin".equalsIgnoreCase(currentUser.role) || currentUser.id.equals(act.createdBy))) { %>
                                <form action="${pageContext.request.contextPath}/activity" method="POST" onclick="event.stopPropagation()">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= act.id %>">
                                    <button type="submit" style="background:none;border:none;color:#c0392b;cursor:pointer;font-size:0.75rem;font-weight:600">Delete</button>
                                </form>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </main>

    <div id="activityModal" class="modal-overlay" onclick="if(event.target===this)closeActivityModal()">
        <div class="modal-card">
            <button class="modal-close" onclick="closeActivityModal()">✕</button>
            <span id="mType" class="modal-badge">Class Test</span>
            <div id="mTitle" class="modal-title">Activity Details</div>
            <div id="mSubject" class="modal-subject">Subject</div>

            <div class="modal-grid">
                <div>
                    <div class="modal-item-label">📅 Date</div>
                    <div id="mDate" class="modal-item-val">Date</div>
                </div>
                <div>
                    <div class="modal-item-label">📍 Room / Venue</div>
                    <div id="mRoom" class="modal-item-val">Room</div>
                </div>
                <div>
                    <div class="modal-item-label">🏢 Department</div>
                    <div id="mDept" class="modal-item-val">General</div>
                </div>
                <div>
                    <div class="modal-item-label">🎓 Class Section</div>
                    <div id="mClass" class="modal-item-val">All Sections</div>
                </div>
            </div>

            <div class="modal-desc-label">Syllabus & Details</div>
            <div id="mDesc" class="modal-desc-text">Description</div>
        </div>
    </div>

    <script>
        function openActivityModal(type, title, subject, date, room, desc, dept, batch, sec) {
            document.getElementById('mType').innerText = type.toUpperCase();
            document.getElementById('mTitle').innerText = title;
            document.getElementById('mSubject').innerText = subject;
            document.getElementById('mDate').innerText = date || 'Date TBD';
            document.getElementById('mRoom').innerText = room || 'N/A';
            document.getElementById('mDept').innerText = dept || 'General';
            document.getElementById('mClass').innerText = (batch && sec) ? (batch + ' · ' + sec) : (batch || dept || 'All Sections');
            document.getElementById('mDesc').innerText = desc || 'No detailed syllabus or description provided for this activity.';
            document.getElementById('activityModal').classList.add('active');
        }
        function closeActivityModal() {
            document.getElementById('activityModal').classList.remove('active');
        }
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') closeActivityModal();
        });
    </script>

    <footer>
        © 2026 UNIFY · <a href="login.jsp" style="color:var(--primary);text-decoration:none">Sign in as Staff</a>
    </footer>
</body>
</html>
