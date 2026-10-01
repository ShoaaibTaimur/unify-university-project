package unify;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import unify.Models.*;

public class ActivityServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User current = (session != null) ? (User) session.getAttribute("user") : null;
        if (current == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        User fresh = UserDAO.getUserById(current.id);
        if (fresh != null) {
            current = fresh;
            session.setAttribute("user", current);
        }

        String action = req.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            Activity a = new Activity();
            String deptId = req.getParameter("departmentId");
            String batchId = req.getParameter("batchId");
            String secId = req.getParameter("sectionId");

            if ("cr".equalsIgnoreCase(current.role)) {
                if (current.departmentId != null) deptId = current.departmentId;
                if (current.batchId != null) batchId = current.batchId;
                if (current.sectionId != null) secId = current.sectionId;
            } else if ("teacher".equalsIgnoreCase(current.role)) {
                if (current.departmentId != null) deptId = current.departmentId;
            }

            a.departmentId = deptId;
            a.batchId = batchId;
            a.sectionId = secId;
            a.activityType = req.getParameter("activityType");
            a.title = req.getParameter("title");
            a.subject = req.getParameter("subject");
            a.room = req.getParameter("room");
            a.description = req.getParameter("description");
            a.eventDate = req.getParameter("eventDate");
            a.startDate = req.getParameter("startDate");
            a.endDate = req.getParameter("endDate");
            a.createdBy = current.id;

            AppDAO.createActivity(a);
        } else if ("delete".equalsIgnoreCase(action)) {
            String id = req.getParameter("id");
            AppDAO.deleteActivity(id);
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
    }
}
