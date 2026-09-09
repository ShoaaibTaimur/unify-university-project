package unify;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import unify.Models.*;

public class AppDAO {

    public static List<Department> getDepartments() {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT * FROM DEPARTMENTS ORDER BY NAME";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Department(rs.getString("ID"), rs.getString("NAME")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static void createDepartment(String name) {
        String id = "dept-" + UUID.randomUUID().toString().substring(0, 8);
        String sql = "INSERT INTO DEPARTMENTS (ID, NAME) VALUES (?, ?)";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, name);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void deleteDepartment(String id) {
        String sql = "DELETE FROM DEPARTMENTS WHERE ID = ?";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static List<Batch> getBatches(String deptId) {
        List<Batch> list = new ArrayList<>();
        String sql = (deptId != null && !deptId.isEmpty()) 
            ? "SELECT * FROM BATCHES WHERE DEPARTMENT_ID = ? ORDER BY NAME" 
            : "SELECT * FROM BATCHES ORDER BY NAME";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (deptId != null && !deptId.isEmpty()) {
                ps.setString(1, deptId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Batch(rs.getString("ID"), rs.getString("DEPARTMENT_ID"), rs.getString("NAME")));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static void createBatch(String deptId, String name) {
        String id = "batch-" + UUID.randomUUID().toString().substring(0, 8);
        String sql = "INSERT INTO BATCHES (ID, DEPARTMENT_ID, NAME) VALUES (?, ?, ?)";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, deptId);
            ps.setString(3, name);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void deleteBatch(String id) {
        String sql = "DELETE FROM BATCHES WHERE ID = ?";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static List<Section> getSections(String batchId) {
        List<Section> list = new ArrayList<>();
        String sql = (batchId != null && !batchId.isEmpty())
            ? "SELECT * FROM SECTIONS WHERE BATCH_ID = ? ORDER BY NAME"
            : "SELECT * FROM SECTIONS ORDER BY NAME";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (batchId != null && !batchId.isEmpty()) {
                ps.setString(1, batchId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Section(rs.getString("ID"), rs.getString("BATCH_ID"), rs.getString("NAME")));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static void createSection(String batchId, String name) {
        String id = "sec-" + UUID.randomUUID().toString().substring(0, 8);
        String sql = "INSERT INTO SECTIONS (ID, BATCH_ID, NAME) VALUES (?, ?, ?)";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, batchId);
            ps.setString(3, name);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void deleteSection(String id) {
        String sql = "DELETE FROM SECTIONS WHERE ID = ?";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static List<Activity> getActivities(String deptId, String batchId, String secId) {
        List<Activity> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM ACTIVITIES WHERE 1=1");
        if (deptId != null && !deptId.isEmpty()) sql.append(" AND DEPARTMENT_ID = ?");
        if (batchId != null && !batchId.isEmpty()) sql.append(" AND BATCH_ID = ?");
        if (secId != null && !secId.isEmpty()) sql.append(" AND SECTION_ID = ?");
        sql.append(" ORDER BY EVENT_DATE DESC, TITLE ASC");

        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (deptId != null && !deptId.isEmpty()) ps.setString(idx++, deptId);
            if (batchId != null && !batchId.isEmpty()) ps.setString(idx++, batchId);
            if (secId != null && !secId.isEmpty()) ps.setString(idx++, secId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Activity a = new Activity();
                    a.id = rs.getString("ID");
                    a.departmentId = rs.getString("DEPARTMENT_ID");
                    a.batchId = rs.getString("BATCH_ID");
                    a.sectionId = rs.getString("SECTION_ID");
                    a.activityType = rs.getString("ACTIVITY_TYPE");
                    a.title = rs.getString("TITLE");
                    a.subject = rs.getString("SUBJECT");
                    a.room = rs.getString("ROOM");
                    a.description = rs.getString("DESCRIPTION");
                    a.eventDate = rs.getString("EVENT_DATE");
                    a.startDate = rs.getString("START_DATE");
                    a.endDate = rs.getString("END_DATE");
                    a.createdBy = rs.getString("CREATED_BY");
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static void createActivity(Activity a) {
        String id = "act-" + UUID.randomUUID().toString().substring(0, 8);
        String sql = "INSERT INTO ACTIVITIES (ID, DEPARTMENT_ID, BATCH_ID, SECTION_ID, ACTIVITY_TYPE, TITLE, SUBJECT, ROOM, DESCRIPTION, EVENT_DATE, START_DATE, END_DATE, CREATED_BY) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, a.departmentId);
            ps.setString(3, a.batchId);
            ps.setString(4, a.sectionId);
            ps.setString(5, a.activityType);
            ps.setString(6, a.title);
            ps.setString(7, a.subject);
            ps.setString(8, a.room);
            ps.setString(9, a.description);
            ps.setString(10, a.eventDate);
            ps.setString(11, a.startDate);
            ps.setString(12, a.endDate);
            ps.setString(13, a.createdBy);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void deleteActivity(String id) {
        String sql = "DELETE FROM ACTIVITIES WHERE ID = ?";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
