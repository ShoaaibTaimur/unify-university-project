package unify;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import unify.Models.User;

public class PasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User current = (session != null) ? (User) session.getAttribute("user") : null;
        if (current == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String currentPass = req.getParameter("currentPassword");
        String newPass = req.getParameter("newPassword");

        if (current.password.equals(currentPass) && newPass != null && newPass.length() >= 6) {
            UserDAO.updatePassword(current.id, newPass);
            current.password = newPass;
            req.setAttribute("msg", "Password updated successfully!");
        } else {
            req.setAttribute("error", "Invalid current password or new password too short.");
        }
        req.getRequestDispatcher("/password.jsp").forward(req, resp);
    }
}
