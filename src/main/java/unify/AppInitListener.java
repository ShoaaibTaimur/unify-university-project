package unify;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebListener
public class AppInitListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[AppInitListener] Checking database seed data...");
        try (Connection conn = DB.getConnection()) {
            if (isDataPresent(conn)) {
                System.out.println("[AppInitListener] Data already exists. Skipping demo seed.");
            } else {
                System.out.println("[AppInitListener] No existing data found. Seeding demo data...");
                seedDemoData(conn);
                System.out.println("[AppInitListener] Demo data seeded successfully.");
            }
        } catch (Exception e) {
            System.err.println("[AppInitListener] Failed to check/seed database: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
    }

    private boolean isDataPresent(Connection conn) {
        String sql = "SELECT COUNT(*) FROM USERS";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            // Table might not exist or error
        }
        return false;
    }

    private void seedDemoData(Connection conn) {
        executeIgnoreDup(conn, "INSERT INTO DEPARTMENTS (ID, NAME) VALUES ('dept-1', 'Computer Science & Engineering')");
        executeIgnoreDup(conn, "INSERT INTO DEPARTMENTS (ID, NAME) VALUES ('dept-2', 'Electrical & Electronic Engineering')");

        executeIgnoreDup(conn, "INSERT INTO BATCHES (ID, DEPARTMENT_ID, NAME) VALUES ('batch-1', 'dept-1', 'Batch 55')");
        executeIgnoreDup(conn, "INSERT INTO BATCHES (ID, DEPARTMENT_ID, NAME) VALUES ('batch-2', 'dept-1', 'Batch 56')");

        executeIgnoreDup(conn, "INSERT INTO SECTIONS (ID, BATCH_ID, NAME) VALUES ('sec-1', 'batch-1', 'Section A')");
        executeIgnoreDup(conn, "INSERT INTO SECTIONS (ID, BATCH_ID, NAME) VALUES ('sec-2', 'batch-1', 'Section B')");

        executeIgnoreDup(conn, "INSERT INTO USERS (ID, NAME, EMAIL, PASSWORD, ROLE, DEPARTMENT_ID, BATCH_ID, SECTION_ID) VALUES ('u-admin', 'System Admin', 'admin@unify.edu', 'admin123', 'admin', NULL, NULL, NULL)");
        executeIgnoreDup(conn, "INSERT INTO USERS (ID, NAME, EMAIL, PASSWORD, ROLE, DEPARTMENT_ID, BATCH_ID, SECTION_ID) VALUES ('u-teacher', 'Dr. Alan Turing', 'teacher@unify.edu', 'teacher123', 'teacher', 'dept-1', NULL, NULL)");
        executeIgnoreDup(conn, "INSERT INTO USERS (ID, NAME, EMAIL, PASSWORD, ROLE, DEPARTMENT_ID, BATCH_ID, SECTION_ID) VALUES ('u-cr', 'John Doe (CR)', 'cr@unify.edu', 'cr123', 'cr', 'dept-1', 'batch-1', 'sec-1')");

        executeIgnoreDup(conn, "INSERT INTO ACTIVITIES (ID, DEPARTMENT_ID, BATCH_ID, SECTION_ID, ACTIVITY_TYPE, TITLE, SUBJECT, ROOM, DESCRIPTION, EVENT_DATE, CREATED_BY) VALUES ('act-1', 'dept-1', 'batch-1', 'sec-1', 'class-test', 'Database Systems CT 1', 'CSE-3101', 'Room 402', 'Topics: ER Diagrams & SQL Queries', '2026-08-10', 'u-teacher')");
    }

    private void executeIgnoreDup(Connection conn, String sql) {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) {
            // Ignore duplicate key exceptions (ORA-00001)
        }
    }
}
