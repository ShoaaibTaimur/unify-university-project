package unify;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import unify.Models.User;

public class HierarchyServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User current = (session != null) ? (User) session.getAttribute("user") : null;
        if (current == null || !"admin".equalsIgnoreCase(current.role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin role required");
            return;
        }

        String type = req.getParameter("type");
        String action = req.getParameter("action");
        String id = req.getParameter("id");
        String name = req.getParameter("name");

        if ("department".equalsIgnoreCase(type)) {
            if ("create".equalsIgnoreCase(action)) AppDAO.createDepartment(name);
            else if ("delete".equalsIgnoreCase(action)) AppDAO.deleteDepartment(id);
        } else if ("batch".equalsIgnoreCase(type)) {
            String deptId = req.getParameter("departmentId");
            if ("create".equalsIgnoreCase(action)) AppDAO.createBatch(deptId, name);
            else if ("delete".equalsIgnoreCase(action)) AppDAO.deleteBatch(id);
        } else if ("section".equalsIgnoreCase(type)) {
            String batchId = req.getParameter("batchId");
            if ("create".equalsIgnoreCase(action)) AppDAO.createSection(batchId, name);
            else if ("delete".equalsIgnoreCase(action)) AppDAO.deleteSection(id);
        }

        resp.sendRedirect(req.getContextPath() + "/hierarchy.jsp");
    }
}
