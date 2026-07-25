# UNIFY - Academic Activity Portal (Java/JSP/Oracle Stack)

Unified academic portal tracking Class Tests, Labs, Viva, Assignments, and Exams organized by Department, Batch, and Section. Recreated with Java Servlets, JSP, Oracle DB (Docker), HTML, and Tailwind CSS. Zero JavaScript.

## Stack & Technologies

- **Backend**: Java Servlets, JSP, JDBC, JSTL
- **Build Tool**: Apache Ant (`build.xml`)
- **Web Server**: Apache Tomcat
- **Database**: Oracle Database (Dockerized via `gvenzl/oracle-free` & SQL*Plus DDL `db.sql`)
- **Styling**: HTML5 + Tailwind CSS (compiled via CLI, zero runtime client JS)

## Project Structure

```
unify-jsp-app/
├── setup.sh                  # Automation script (Docker boot, DB seed, CSS compilation)
├── README.md                 # Project documentation
├── docker-compose.yml        # Oracle Free DB Docker service
├── db.sql                    # Oracle DDL & DML seed script (SQL*Plus)
├── build.xml                 # Apache Ant build script
├── tailwind.config.js        # Tailwind CSS config
├── package.json              # Tailwind CSS build dependencies
└── src/
    └── main/
        ├── java/
        │   └── unify/        # Flat Java package
        │       ├── DB.java           # JDBC Connection Manager
        │       ├── Models.java       # User, Department, Batch, Section, Activity models
        │       ├── UserDAO.java      # Database operations for Users & Auth
        │       ├── AppDAO.java       # Database operations for Depts, Batches, Sections & Activities
        │       ├── AuthFilter.java   # Session-based authentication & RBAC Filter
        │       ├── LoginServlet.java
        │       ├── LogoutServlet.java
        │       ├── UserServlet.java
        │       ├── HierarchyServlet.java
        │       ├── ActivityServlet.java
        │       └── PasswordServlet.java
        └── webapp/
            ├── WEB-INF/
            │   └── web.xml   # Deployment descriptor & servlet mappings
            ├── css/
            │   ├── input.css # Tailwind source
            │   └── style.css # Compiled Tailwind CSS stylesheet
            ├── login.jsp     # Login view
            ├── dashboard.jsp # Activities view & filters
            ├── users.jsp     # Admin user management view
            ├── hierarchy.jsp # Admin department/batch/section view
            ├── activity.jsp  # Activity create form
            └── password.jsp  # Change password view
```

## Quick Start Guide

Run single command:

```bash
cd unify-jsp-app
./setup.sh
```

`setup.sh` handles:
1. Oracle DB Docker boot with `sudo`.
2. DB table creation and data seeding (`db.sql`).
3. Tailwind CSS build.
4. Java compilation & WAR generation via Apache Ant (`ant war`).
5. Launching Apache Tomcat Docker container (`unify-tomcat`).

Access live app at: **`http://localhost:8080`**

## Default Login Credentials

| Role | Email | Password | Access Rights |
|---|---|---|---|
| **Admin** | `admin@unify.edu` | `admin123` | Full system access (User management, Dept/Batch/Section CRUD, Activity CRUD) |
| **Teacher** | `teacher@unify.edu` | `teacher123` | Activity CRUD for assigned Department |
| **CR** | `cr@unify.edu` | `cr123` | Activity CRUD for assigned Dept, Batch & Section |
