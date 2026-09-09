# UNIFY — Exam Quick-Revision Architecture

### 1. Tech Stack
- **Web / Presentation**: JSP 2.3, Vanilla JS (DOM & Cascading), Tailwind CSS.
- **Server / Backend**: Apache Tomcat 9, Java Servlet API 4.0.1, JDBC (`ojdbc8`).
- **Database**: Oracle Database 23ai / Free (`FREEPDB1`).
- **Containers**: Docker (`unify-oracle` on `1521`, `unify-tomcat` on `8080`).

---

### 2. All Files at a Glance

| File | Type | What it Does |
| :--- | :--- | :--- |
| `DB.java` | Java | Connection factory (`localhost:1521/FREEPDB1`, `unify`/`unify`). Fallback port `1522`. |
| `Models.java` | Java | DTO models: `User`, `Department`, `Batch`, `Section`, `Activity`. |
| `UserDAO.java` | Java | User database queries: `login()`, `getUserById()`, `createUser()`, `updatePassword()`. |
| `AppDAO.java` | Java | Hierarchy & activity queries: `getActivities()`, `createActivity()`, `createBatch()`, etc. |
| `LoginServlet.java` | Servlet | Handles `/login`. Validates user, creates session, sets 1-year `unify_user_id` cookie. |
| `LogoutServlet.java` | Servlet | Handles `/logout`. Destroys session, deletes cookie (`Max-Age=0`), redirects to login. |
| `AuthFilter.java` | Filter | Global gatekeeper. Whitelists public URLs; re-hydrates user from cookie if session expired. |
| `ActivityServlet.java`| Servlet | Handles `/activity`. Creates/deletes activities. Forces CR to stay in their own section. |
| `HierarchyServlet.java`| Servlet | Handles `/hierarchy`. Admin-only CRUD for departments, batches, sections. |
| `UserServlet.java` | Servlet | Handles `/users`. Admin-only user account management. |
| `PasswordServlet.java`| Servlet | Handles `/password`. Validates old password and updates to new password. |
| `index.jsp` | JSP | Public home screen. Class picker + today/upcoming/all activities + countdown card. |
| `activities.jsp` | JSP | Public full activities directory with search by keyword and activity type filter. |
| `dashboard.jsp` | JSP | Faculty/CR protected landing page with schedule overview and quick actions. |
| `activity.jsp` | JSP | Form to post new activities (CR fields auto-locked to their class). |
| `hierarchy.jsp` | JSP | Admin page to add/delete departments, batches, sections. |
| `users.jsp` | JSP | Admin page to view and create teacher/CR users. |
| `password.jsp` | JSP | Self-service password change page. |
| `web.xml` | XML | Servlet/filter mappings + 1-year session timeout configuration. |
| `db.sql` | SQL | Table DDL, PL/SQL triggers, anonymous blocks, and initial seed data. |
| `setup.sh` | Shell | Full project bootstrapper (Docker pull, CSS build, Java compile, DB init). |
| `restart.sh` | Shell | Fast rebuild script (recompiles Java, updates WAR, restarts Tomcat). |

---

### 3. PL/SQL: Where, How, and Why

| PL/SQL Object | Where | How it Works | Why Used |
| :--- | :--- | :--- | :--- |
| **`TRG_VALIDATE_USER_DATA`** | `db.sql:96` | `BEFORE INSERT/UPDATE ON USERS`<br>1. Lowers & trims email.<br>2. Raises error `-20001` if CR has no dept/batch/sec. | Data integrity: ensures emails are uniform and CRs always have a class assigned. |
| **`TRG_CHECK_CR_ACTIVITY_SCOPE`** | `db.sql:109`| `BEFORE INSERT/UPDATE ON ACTIVITIES`<br>Checks creator role. If `cr`, verifies target section == CR's assigned section; else raises `-20002`. | Security: stops a CR from posting exams/activities into another class section. |
| **`TRG_AUDIT_ACTIVITIES`** | `db.sql:133`| `AFTER INSERT/UPDATE/DELETE ON ACTIVITIES`<br>Inserts row into `ACTIVITY_LOGS` table with action type and timestamp. | Audit trail: permanent history of who created, edited, or deleted an activity. |
| **Anonymous Blocks** | `db.sql:3-95`| `BEGIN EXECUTE IMMEDIATE '...'; EXCEPTION WHEN OTHERS (SQLCODE != -955) ... END; /` | Idempotent migration: skips table creation if table already exists (error `-955`). |

---

### 4. Authentication & Password Matching Flow

1. **Submit**: Form on `login.jsp` posts `email` and `password` to `/login`.
2. **Match (`UserDAO.java`)**:
   ```sql
   SELECT * FROM USERS WHERE LOWER(EMAIL) = LOWER(?) AND PASSWORD = ?
   ```
3. **Session & Cookie (`LoginServlet.java`)**:
   - `session.setAttribute("user", user)`
   - Adds HTTP-Only persistent cookie: `unify_user_id` with `Max-Age = 31536000` (1 year).
4. **Auto-Login Rehydration (`AuthFilter.java`)**:
   - If session is null on browser restart, reads `unify_user_id` cookie, queries `UserDAO.getUserById(id)`, and automatically restores session. User stays logged in permanently until `/logout`.
5. **Logout (`LogoutServlet.java`)**:
   - Invalidates session and expires cookie (`Max-Age=0`).

---

### 5. Home Screen Filter Logic (`index.jsp`)

- **No premature loading**: Changing Department/Batch/Section dropdowns updates the UI via **client-side JavaScript** without refreshing the page.
- **Trigger**: Data loads **only** when clicking `<button type="submit" class="btn-go">Load in Home Screen</button>`, which sends `applyFilter=true`.
- **Logic**: `boolean hasSelection = "true".equals(applyFilter) && (hasId...)`.
