<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="unify.Models.*, unify.AppDAO, java.util.List" %>
<%
    // No login required — public student dashboard
    String deptId = request.getParameter("departmentId");
    String batchId = request.getParameter("batchId");
    String secId = request.getParameter("sectionId");

    List<Department> departments = AppDAO.getDepartments();
    List<Batch> batches = (deptId != null && !deptId.isEmpty()) ? AppDAO.getBatches(deptId) : AppDAO.getBatches(null);
    List<Section> sections = (batchId != null && !batchId.isEmpty()) ? AppDAO.getSections(batchId) : AppDAO.getSections(null);
    List<Activity> activities = (deptId != null && !deptId.isEmpty() && batchId != null && !batchId.isEmpty() && secId != null && !secId.isEmpty())
        ? AppDAO.getActivities(deptId, batchId, secId) : new java.util.ArrayList<>();

    // Find names for display
    String deptName = "", batchName = "", secName = "";
    for (Department d : departments) { if (d.id.equals(deptId)) deptName = d.name; }
    for (Batch b : batches) { if (b.id.equals(batchId)) batchName = b.name; }
    for (Section s : sections) { if (s.id.equals(secId)) secName = s.name; }

    boolean hasSelection = !deptName.isEmpty() && !batchName.isEmpty() && !secName.isEmpty();

    // Split activities for display
    java.util.List<Activity> todays = new java.util.ArrayList<>();
    java.util.List<Activity> upcoming = new java.util.ArrayList<>();
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    String today = sdf.format(new java.util.Date());
    for (Activity a : activities) {
        String d = a.eventDate != null ? a.eventDate : "";
        if (d.equals(today)) todays.add(a);
        else if (d.compareTo(today) > 0) upcoming.add(a);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UNIFY — Your Class Dashboard</title>
    <meta name="description" content="See today's activities, your next deadline, and what's coming up for your section.">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary:#800000; --primary-deep:#5C0011; --accent:#B8748A; --bg:#F8F8F8; --card:#fff; --border:#e8e0e0; --muted:#f3eded; --muted-fg:#8a7070; --fg:#2a1515; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--fg); }

        /* Top nav */
        .topbar { background: white; border-bottom: 1.5px solid var(--border); padding: 0 2rem; display: flex; align-items: center; justify-content: space-between; height: 3.5rem; position: sticky; top: 0; z-index: 30; }
        .topbar-logo { font-size: 1.25rem; font-weight: 700; color: var(--primary); letter-spacing: -0.02em; text-decoration: none; }
        .topbar-actions { display: flex; align-items: center; gap: 0.75rem; }
        .btn-login { padding: 0.4rem 1rem; border: 1.5px solid var(--border); border-radius: 999px; font-size: 0.8rem; font-weight: 500; color: var(--fg); text-decoration: none; background: white; transition: all 0.15s; }
        .btn-login:hover { border-color: var(--primary); color: var(--primary); }

        /* Hero */
        .hero { background: linear-gradient(135deg, #fff0f0 0%, #F8F8F8 100%); border-bottom: 1px solid var(--border); padding: 3.5rem 2rem; position: relative; overflow: hidden; }
        .hero::before { content: ''; position: absolute; top: -40%; left: 50%; transform: translateX(-50%); width: 80%; height: 160%; background: radial-gradient(ellipse at center, rgba(128,0,0,0.07) 0%, transparent 70%); pointer-events: none; }
        .hero-inner { max-width: 72rem; margin: 0 auto; display: flex; flex-direction: column; align-items: flex-start; gap: 1.5rem; }
        .hero-label { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.1em; color: var(--accent); }
        .hero h1 { font-size: 2.75rem; font-weight: 600; letter-spacing: -0.02em; line-height: 1.15; }
        .hero h1 .class-name { color: var(--primary); }
        .hero p { font-size: 0.95rem; color: var(--muted-fg); max-width: 36rem; }
        @media(max-width:640px){ .hero h1 { font-size: 2rem; } }

        /* Class picker */
        .picker-card { max-width: 72rem; margin: -1rem auto 0; padding: 0 2rem; position: relative; z-index: 10; }
        .picker-inner { background: white; border: 1.5px solid var(--border); border-radius: 1.25rem; padding: 1.25rem 1.5rem; display: grid; grid-template-columns: 1fr 1fr 1fr auto; gap: 0.875rem; align-items: end; box-shadow: 0 4px 24px -8px rgba(128,0,0,0.12); }
        @media(max-width:768px){ .picker-inner { grid-template-columns: 1fr 1fr; } .picker-submit { grid-column: span 2; } }
        @media(max-width:480px){ .picker-inner { grid-template-columns: 1fr; } .picker-submit { grid-column: auto; } }
        .picker-field label { font-size: 0.65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.07em; color: var(--muted-fg); display: block; margin-bottom: 0.35rem; }
        select { width: 100%; height: 2.25rem; border: 1.5px solid var(--border); border-radius: 0.625rem; padding: 0 0.75rem; font-size: 0.875rem; font-family: inherit; background: white; color: var(--fg); }
        select:focus { outline: none; border-color: var(--primary); }
        .btn-go { height: 2.25rem; background: var(--primary); color: white; border: none; border-radius: 0.625rem; padding: 0 1.5rem; font-size: 0.875rem; font-weight: 600; font-family: inherit; cursor: pointer; white-space: nowrap; }
        .btn-go:hover { background: var(--primary-deep); }
        .btn-reset { height: 2.25rem; background: var(--muted); border: 1.5px solid var(--border); border-radius: 0.625rem; padding: 0 1rem; font-size: 0.8rem; font-weight: 500; font-family: inherit; cursor: pointer; color: var(--muted-fg); text-decoration: none; display: inline-flex; align-items: center; }

        /* Content */
        .content { max-width: 72rem; margin: 2.5rem auto; padding: 0 2rem; display: grid; grid-template-columns: 1fr 22rem; gap: 1.5rem; }
        @media(max-width:900px){ .content { grid-template-columns: 1fr; } }
        .section-title { font-size: 1.125rem; font-weight: 600; letter-spacing: -0.01em; margin-bottom: 0.875rem; display: flex; align-items: center; gap: 0.5rem; }
        .activity-list { display: flex; flex-direction: column; gap: 0.75rem; }
        .activity-card { background: white; border: 1.5px solid var(--border); border-radius: 1rem; padding: 1.125rem 1.25rem; display: flex; align-items: flex-start; gap: 1rem; box-shadow: 0 1px 2px rgba(128,0,0,0.04); transition: border-color 0.15s, box-shadow 0.15s; }
        .activity-card:hover { border-color: var(--accent); box-shadow: 0 4px 16px -4px rgba(128,0,0,0.1); }
        .activity-color { width: 0.25rem; border-radius: 999px; flex-shrink: 0; align-self: stretch; background: var(--primary); }
        .activity-body { flex: 1; }
        .activity-badge { font-size: 0.65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; background: #fff0f0; color: var(--primary); border: 1px solid #fcc; border-radius: 999px; padding: 0.15rem 0.5rem; display: inline-block; margin-bottom: 0.35rem; }
        .activity-title { font-size: 0.9375rem; font-weight: 600; }
        .activity-meta { font-size: 0.75rem; color: var(--muted-fg); margin-top: 0.2rem; }
        .activity-date { font-size: 0.75rem; color: var(--muted-fg); text-align: right; white-space: nowrap; flex-shrink: 0; padding-top: 0.2rem; }
        .empty-box { background: white; border: 1.5px dashed var(--border); border-radius: 1.25rem; padding: 3rem 2rem; text-align: center; color: var(--muted-fg); font-size: 0.875rem; }
        .empty-icon { font-size: 2rem; margin-bottom: 0.75rem; opacity: 0.4; }

        /* Next activity countdown card */
        .countdown-card { background: linear-gradient(135deg, var(--primary) 0%, var(--primary-deep) 100%); color: white; border-radius: 1.5rem; padding: 1.5rem; position: sticky; top: 5.5rem; box-shadow: 0 8px 32px -8px rgba(128,0,0,0.4); }
        .countdown-label { font-size: 0.65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.1em; opacity: 0.7; }
        .countdown-subject { font-size: 1.25rem; font-weight: 600; margin-top: 0.5rem; letter-spacing: -0.01em; }
        .countdown-title { font-size: 0.8rem; opacity: 0.8; margin-top: 0.2rem; }
        .countdown-date { font-size: 0.8rem; opacity: 0.75; margin-top: 1.25rem; }
        .no-class-card { background: linear-gradient(135deg, var(--primary) 0%, var(--primary-deep) 100%); color: white; border-radius: 1.5rem; padding: 1.75rem; position: sticky; top: 5.5rem; box-shadow: 0 8px 32px -8px rgba(128,0,0,0.4); }
        .no-class-title { font-size: 1.1rem; font-weight: 600; margin-bottom: 0.5rem; }
        .no-class-sub { font-size: 0.8rem; opacity: 0.8; }

        /* No selection prompt */
        .prompt-section { grid-column: span 2; }
        .prompt-box { background: white; border: 1.5px solid var(--border); border-radius: 1.5rem; padding: 4rem 2rem; text-align: center; }
        .prompt-icon { font-size: 3rem; margin-bottom: 1rem; }
        .prompt-box h2 { font-size: 1.25rem; font-weight: 600; letter-spacing: -0.01em; }
        .prompt-box p { font-size: 0.875rem; color: var(--muted-fg); margin-top: 0.5rem; }

        /* Footer */
        footer { text-align: center; padding: 2rem; font-size: 0.75rem; color: var(--muted-fg); border-top: 1px solid var(--border); margin-top: 2rem; }
    </style>
</head>
<body>
    <!-- Top bar -->
    <nav class="topbar">
        <a href="index.jsp" class="topbar-logo">UNIFY</a>
        <div class="topbar-actions">
            <a href="login.jsp" class="btn-login">Sign in →</a>
        </div>
    </nav>

    <!-- Hero band -->
    <section class="hero">
        <div class="hero-inner">
            <p class="hero-label">Your class</p>
            <h1>
                <% if (hasSelection) { %>
                    <span><%= deptName %> ·</span> <span class="class-name"><%= batchName %></span> · <%= secName %>
                <% } else { %>
                    Welcome to <span class="class-name">UNIFY</span>
                <% } %>
            </h1>
            <p><%= hasSelection ? "Everything happening in your class — at a glance." : "Pick your class to see your academic activities." %></p>
        </div>
    </section>

    <!-- Class picker -->
    <div class="picker-card">
        <form method="GET" action="index.jsp" class="picker-inner">
            <div class="picker-field">
                <label>Department</label>
                <select name="departmentId" onchange="this.form.submit()">
                    <option value="">Select Department</option>
                    <% for (Department d : departments) { %>
                        <option value="<%= d.id %>" <%= d.id.equals(deptId != null ? deptId : "") ? "selected" : "" %>><%= d.name %></option>
                    <% } %>
                </select>
            </div>
            <div class="picker-field">
                <label>Batch</label>
                <select name="batchId" onchange="this.form.submit()">
                    <option value="">Select Batch</option>
                    <% for (Batch b : batches) { %>
                        <option value="<%= b.id %>" <%= b.id.equals(batchId != null ? batchId : "") ? "selected" : "" %>><%= b.name %></option>
                    <% } %>
                </select>
            </div>
            <div class="picker-field">
                <label>Section</label>
                <select name="sectionId">
                    <option value="">Select Section</option>
                    <% for (Section s : sections) { %>
                        <option value="<%= s.id %>" <%= s.id.equals(secId != null ? secId : "") ? "selected" : "" %>><%= s.name %></option>
                    <% } %>
                </select>
            </div>
            <div class="picker-submit" style="display:flex;gap:0.5rem">
                <button type="submit" class="btn-go">View Activities</button>
                <% if (hasSelection) { %><a href="index.jsp" class="btn-reset">Reset</a><% } %>
            </div>
        </form>
    </div>

    <!-- Content grid -->
    <div class="content">
        <% if (!hasSelection) { %>
            <div class="prompt-section">
                <div class="prompt-box">
                    <div class="prompt-icon">🎓</div>
                    <h2>Select your class to view activities</h2>
                    <p>Choose a Department, Batch, and Section above to see your schedule.</p>
                </div>
            </div>
        <% } else { %>

        <!-- Left: Activities -->
        <div>
            <!-- Today's activities -->
            <div class="section-title">📅 Today's Activities</div>
            <% if (todays.isEmpty()) { %>
                <div class="empty-box" style="margin-bottom:2rem">
                    <div class="empty-icon">🎉</div>
                    No activities scheduled today — enjoy your day!
                </div>
            <% } else { %>
                <div class="activity-list" style="margin-bottom:2rem">
                    <% for (Activity a : todays) { %>
                        <div class="activity-card">
                            <div class="activity-color"></div>
                            <div class="activity-body">
                                <span class="activity-badge"><%= a.activityType.replace("-"," ") %></span>
                                <div class="activity-title"><%= a.title %></div>
                                <div class="activity-meta"><%= a.subject %><%= (a.room != null && !a.room.isEmpty()) ? " · " + a.room : "" %></div>
                                <% if (a.description != null && !a.description.isEmpty()) { %>
                                    <div class="activity-meta" style="margin-top:0.25rem"><%= a.description %></div>
                                <% } %>
                            </div>
                            <div class="activity-date">Today</div>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <!-- Upcoming -->
            <div class="section-title">🗓️ Upcoming</div>
            <% if (upcoming.isEmpty()) { %>
                <p style="font-size:0.875rem;color:var(--muted-fg)">Nothing else on the horizon.</p>
            <% } else { %>
                <div class="activity-list">
                    <% for (Activity a : upcoming) { %>
                        <div class="activity-card">
                            <div class="activity-color" style="background:var(--accent)"></div>
                            <div class="activity-body">
                                <span class="activity-badge"><%= a.activityType.replace("-"," ") %></span>
                                <div class="activity-title"><%= a.title %></div>
                                <div class="activity-meta"><%= a.subject %><%= (a.room != null && !a.room.isEmpty()) ? " · " + a.room : "" %></div>
                            </div>
                            <% if (a.eventDate != null && !a.eventDate.isEmpty()) { %>
                                <div class="activity-date"><%= a.eventDate %></div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>

        <!-- Right: Next activity card -->
        <aside>
            <% Activity next = upcoming.isEmpty() ? (todays.isEmpty() ? null : todays.get(0)) : upcoming.get(0); %>
            <% if (next != null) { %>
                <div class="countdown-card">
                    <p class="countdown-label">Next Activity</p>
                    <div class="countdown-subject"><%= next.subject %></div>
                    <div class="countdown-title"><%= next.title %></div>
                    <div class="countdown-date">
                        📅 <%= next.eventDate != null && !next.eventDate.isEmpty() ? next.eventDate : "Date TBD" %>
                        <% if (next.room != null && !next.room.isEmpty()) { %><br>📍 <%= next.room %><% } %>
                    </div>
                </div>
            <% } else { %>
                <div class="no-class-card">
                    <div class="no-class-title">All clear!</div>
                    <div class="no-class-sub">No upcoming activities for this class section.</div>
                </div>
            <% } %>
        </aside>

        <% } %>
    </div>

    <footer>
        © 2026 UNIFY · <a href="login.jsp" style="color:var(--primary);text-decoration:none">Sign in as Staff</a>
    </footer>
</body>
</html>
