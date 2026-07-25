package unify;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import unify.Models.User;

public class UserDAO {

    public static User login(String email, String password) {
        String sql = "SELECT * FROM USERS WHERE LOWER(EMAIL) = LOWER(?) AND PASSWORD = ?";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM USERS ORDER BY ROLE, NAME";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static User createUser(String name, String email, String password, String role, String deptId, String batchId, String secId) {
        String id = "u-" + UUID.randomUUID().toString().substring(0, 8);
        String sql = "INSERT INTO USERS (ID, NAME, EMAIL, PASSWORD, ROLE, DEPARTMENT_ID, BATCH_ID, SECTION_ID) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, name);
            ps.setString(3, email);
            ps.setString(4, password);
            ps.setString(5, role);
            ps.setString(6, deptId == null || deptId.isEmpty() ? null : deptId);
            ps.setString(7, batchId == null || batchId.isEmpty() ? null : batchId);
            ps.setString(8, secId == null || secId.isEmpty() ? null : secId);
            ps.executeUpdate();
            return new User(id, name, email, password, role, deptId, batchId, secId);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static boolean deleteUser(String id) {
        String sql = "DELETE FROM USERS WHERE ID = ?";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean updatePassword(String userId, String newPassword) {
        String sql = "UPDATE USERS SET PASSWORD = ? WHERE ID = ?";
        try (Connection conn = DB.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setString(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private static User mapUser(ResultSet rs) throws SQLException {
        return new User(
            rs.getString("ID"),
            rs.getString("NAME"),
            rs.getString("EMAIL"),
            rs.getString("PASSWORD"),
            rs.getString("ROLE"),
            rs.getString("DEPARTMENT_ID"),
            rs.getString("BATCH_ID"),
            rs.getString("SECTION_ID")
        );
    }
}
