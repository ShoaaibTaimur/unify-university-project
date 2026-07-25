package unify;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DB {
    private static final String URL = System.getenv("ORACLE_URL") != null 
        ? System.getenv("ORACLE_URL") 
        : "jdbc:oracle:thin:@localhost:1521/FREEPDB1";
    private static final String USER = System.getenv("ORACLE_USER") != null 
        ? System.getenv("ORACLE_USER") 
        : "unify";
    private static final String PASS = System.getenv("ORACLE_PASS") != null 
        ? System.getenv("ORACLE_PASS") 
        : "unify";

    static {
        try {
            Class.forName("oracle.jdbc.OracleDriver");
        } catch (ClassNotFoundException e) {
            System.err.println("Oracle JDBC Driver not found in classpath!");
        }
    }

    public static Connection getConnection() throws SQLException {
        if (System.getenv("ORACLE_URL") != null) {
            return DriverManager.getConnection(System.getenv("ORACLE_URL"), USER, PASS);
        }
        try {
            return DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521/FREEPDB1", USER, PASS);
        } catch (SQLException e) {
            return DriverManager.getConnection("jdbc:oracle:thin:@localhost:1522/FREEPDB1", USER, PASS);
        }
    }
}
