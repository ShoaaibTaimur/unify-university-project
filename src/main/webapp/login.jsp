<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign in — UNIFY</title>
    <meta name="description" content="Sign in to UNIFY as CR, Teacher, or Admin to manage academic activities.">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #800000;
            --primary-deep: #5C0011;
            --accent: #B8748A;
            --bg: #F8F8F8;
            --card: #ffffff;
            --border: #e8e0e0;
            --muted: #f3eded;
            --muted-fg: #8a7070;
            --fg: #2a1515;
            --radius: 1rem;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--fg); min-height: 100vh; display: grid; grid-template-columns: 1fr 1fr; }
        @media (max-width: 1024px) { body { grid-template-columns: 1fr; } .hero { display: none !important; } }
        .hero {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-deep) 100%);
            color: white; padding: 3rem; display: flex; flex-direction: column; justify-content: space-between;
        }
        .hero-logo { font-size: 1.75rem; font-weight: 700; letter-spacing: -0.02em; }
        .hero h2 { font-size: 2.75rem; font-weight: 600; line-height: 1.2; letter-spacing: -0.02em; margin-top: auto; }
        .hero p { font-size: 0.875rem; opacity: 0.8; margin-top: 1rem; max-width: 28rem; }
        .hero footer { font-size: 0.75rem; opacity: 0.6; margin-top: 3rem; }
        .form-side { display: flex; align-items: center; justify-content: center; padding: 2rem; position: relative; }
        .form-box { width: 100%; max-width: 24rem; }
        .btn-back { display: inline-flex; align-items: center; gap: 0.375rem; padding: 0.375rem 0.875rem; border: 1.5px solid var(--border); border-radius: 999px; font-size: 0.8rem; font-weight: 500; color: var(--fg); text-decoration: none; background: white; margin-bottom: 1.5rem; transition: all 0.15s; }
        .btn-back:hover { border-color: var(--primary); color: var(--primary); }
        .logo-mobile { font-size: 1.5rem; font-weight: 700; color: var(--primary); letter-spacing: -0.02em; margin-bottom: 1.5rem; }
        h1 { font-size: 2rem; font-weight: 600; letter-spacing: -0.02em; }
        .subtitle { font-size: 0.875rem; color: var(--muted-fg); margin-top: 0.25rem; }
        form { margin-top: 1.75rem; display: flex; flex-direction: column; gap: 1rem; }
        label { font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; color: var(--muted-fg); display: block; margin-bottom: 0.375rem; }
        input { width: 100%; height: 2.75rem; border: 1.5px solid var(--border); border-radius: 0.75rem; padding: 0 0.875rem; font-size: 0.9rem; font-family: inherit; background: white; color: var(--fg); transition: border-color 0.15s; }
        input:focus { outline: none; border-color: var(--primary); }
        .btn-primary { width: 100%; height: 2.75rem; background: var(--primary); color: white; border: none; border-radius: 0.75rem; font-size: 0.9rem; font-weight: 600; font-family: inherit; cursor: pointer; transition: background 0.15s; }
        .btn-primary:hover { background: var(--primary-deep); }
        .error-box { background: #fff0f0; border: 1.5px solid #fcc; border-radius: 0.75rem; padding: 0.75rem 1rem; font-size: 0.85rem; color: #c00; margin-bottom: 1rem; }
        .hint { margin-top: 1.5rem; background: var(--muted); border: 1.5px dashed var(--border); border-radius: 1rem; padding: 1rem; font-size: 0.75rem; color: var(--muted-fg); }
        .hint p { margin-bottom: 0.2rem; }
        .hint span { font-weight: 600; color: var(--fg); }
    </style>
</head>
<body>
    <!-- Left hero panel -->
    <div class="hero">
        <div class="hero-logo">UNIFY</div>
        <div>
            <h2>One place for every academic activity.</h2>
            <p>UNIFY brings Class Tests, Labs, Viva, Assignments, and Exams into a single premium portal — organized by Department, Batch, and Section.</p>
        </div>
        <footer>© 2026 UNIFY</footer>
    </div>

    <!-- Right form panel -->
    <div class="form-side">
        <div class="form-box">
            <a href="index.jsp" class="btn-back">← Back to home</a>
            <div class="logo-mobile">UNIFY</div>
            <h1>Sign in</h1>
            <p class="subtitle">For CRs, Teachers, and Admins.</p>

            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
                <div class="error-box" style="margin-top:1rem"><%= error %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/login" method="POST">
                <div>
                    <label>Email Address</label>
                    <input type="email" name="email" required placeholder="you@unify.edu">
                </div>
                <div>
                    <label>Password</label>
                    <input type="password" name="password" required placeholder="••••••••">
                </div>
                <button type="submit" class="btn-primary">Sign in</button>
            </form>

            <div class="hint">
                <p><span>Admin:</span> admin@unify.edu / admin123</p>
                <p><span>Teacher:</span> teacher@unify.edu / teacher123</p>
                <p><span>CR:</span> cr@unify.edu / cr123</p>
            </div>
        </div>
    </div>
</body>
</html>
