package unify;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import unify.Models.User;

public class UserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User current = (session != null) ? (User) session.getAttribute("user") : null;
        if (current == null || !"admin".equalsIgnoreCase(current.role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin role required");
            return;
        }

        String action = req.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            String name = req.getParameter("name");
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            String role = req.getParameter("role");
            String deptId = req.getParameter("departmentId");
            String batchId = req.getParameter("batchId");
            String secId = req.getParameter("sectionId");

            UserDAO.createUser(name, email, password, role, deptId, batchId, secId);
        } else if ("delete".equalsIgnoreCase(action)) {
            String id = req.getParameter("id");
            UserDAO.deleteUser(id);
        }
        resp.sendRedirect(req.getContextPath() + "/users.jsp");
    }
}
