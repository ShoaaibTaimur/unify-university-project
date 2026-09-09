# UNIFY — `db.sql` SQL*Plus Code & Java Linkage Guide

This guide explains how **SQL*Plus code in `db.sql`** works and **which Java/JSP files trigger or use each part**.

---

### 1. SQL*Plus Specific Syntax in `db.sql`

| SQL*Plus Command | Where in `db.sql` | What it Does & Why |
| :--- | :--- | :--- |
| **`SET DEFINE OFF;`** | Line 1 | In SQL*Plus, `&` triggers variable prompts. This disables prompts so strings like `'Computer Science & Engineering'` don't pause execution. |
| **Slash `/`** | Lines 18, 29, 42, 54, 81, 95, 108, 132, 148, 170 | SQL*Plus command buffer terminator. Standard SQL ends with `;`, but **multi-line PL/SQL blocks and triggers require `/` on a new line to compile and execute**. |
| **`COMMIT;`** | Line 172 | Tells SQL*Plus to permanently commit all DDL and seed DML transactions. |

---

### 2. PL/SQL Triggers in `db.sql` & Their Java Callers

| Trigger in `db.sql` | Type & Logic | Triggered by Which File | What Happens |
| :--- | :--- | :--- | :--- |
| **`TRG_VALIDATE_USER_DATA`**<br>(Lines 96–108) | `BEFORE INSERT OR UPDATE ON USERS`<br>• Lowers & trims email.<br>• Throws `-20001` if CR lacks dept/batch/sec. | **`UserServlet.java`**<br>(calls `UserDAO.createUser`)<br>**`AppInitListener.java`** | Normalizes email for case-insensitive login. Blocks invalid CR creation. |
| **`TRG_CHECK_CR_ACTIVITY_SCOPE`**<br>(Lines 109–132) | `BEFORE INSERT OR UPDATE ON ACTIVITIES`<br>• Looks up creator in `USERS`.<br>• If `cr`, verifies target section matches CR's section; else throws `-20002`. | **`ActivityServlet.java`**<br>(calls `AppDAO.createActivity`) | Prevents CR from posting activities/exams into other classes at database level. |
| **`TRG_AUDIT_ACTIVITIES`**<br>(Lines 133–148) | `AFTER INSERT OR UPDATE OR DELETE ON ACTIVITIES`<br>• Writes record to `ACTIVITY_LOGS`. | **`ActivityServlet.java`**<br>(calls `AppDAO.createActivity` or `deleteActivity`) | Automatically records audit trail without writing logging code in Java. |

---

### 3. Tables & Anonymous Blocks in `db.sql` & Their Java Callers

| Object in `db.sql` | SQL / PL/SQL Logic | Used / Called by Java & JSP |
| :--- | :--- | :--- |
| **`USERS`**<br>(Lines 3–18) | Dynamic PL/SQL: `EXECUTE IMMEDIATE` catching `SQLCODE != -955` (skip if exists). | • **`UserDAO.java`**: `login()`, `getUserById()`, `createUser()`.<br>• **`LoginServlet.java`**: authenticates login form.<br>• **`AuthFilter.java`**: re-hydrates user from cookie. |
| **`DEPARTMENTS`, `BATCHES`, `SECTIONS`**<br>(Lines 20–56) | Foreign keys with `ON DELETE CASCADE`. Dynamic block trap `-955`. | • **`AppDAO.java`**: loads dropdown hierarchies.<br>• **`HierarchyServlet.java`**: admin creates/deletes classes.<br>• **`index.jsp`**: client-side dropdown cascade. |
| **`ACTIVITIES`**<br>(Lines 58–81) | Foreign keys referencing hierarchy and `USERS(ID)`. | • **`AppDAO.java`**: `getActivities()`, `createActivity()`.<br>• **`ActivityServlet.java`**: handles activity form submission.<br>• **`index.jsp` & `activities.jsp`**: public display. |
| **`ACTIVITY_LOGS`**<br>(Lines 83–95) | Identity primary key (`GENERATED ALWAYS AS IDENTITY`). | • **Populated solely by trigger `TRG_AUDIT_ACTIVITIES`**.<br>• Queried in SQL*Plus for security audits. |
| **Seed Block**<br>(Lines 149–170) | Anonymous PL/SQL: checks `COUNT(*) FROM USERS = 0`, inserts demo data with `DUP_VAL_ON_INDEX` traps. | • Creates default logins: `admin@unify.edu`, `teacher@unify.edu`, `cr@unify.edu` (password: `...123`). |

---

### 4. Interactive SQL*Plus Command for Viva / Demo

```bash
docker exec -it unify-oracle sqlplus unify/unify@localhost:1521/FREEPDB1
```

```sql
-- 1. Check trigger audit logs created by ActivityServlet:
SELECT LOG_ID, ACTIVITY_ID, ACTION_TYPE, PERFORMED_BY, LOG_TIMESTAMP FROM ACTIVITY_LOGS;

-- 2. Test Scope Guard Trigger (Throws ORA-20002):
INSERT INTO ACTIVITIES (ID, DEPARTMENT_ID, BATCH_ID, SECTION_ID, ACTIVITY_TYPE, TITLE, SUBJECT, CREATED_BY)
VALUES ('test-1', 'dept-2', 'batch-1', 'sec-1', 'quiz', 'Hacked Quiz', 'CSE-101', 'u-cr');
```
