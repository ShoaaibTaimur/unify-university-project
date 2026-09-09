package unify;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import unify.Models.User;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            Cookie[] cookies = req.getCookies();
            if (cookies != null) {
                for (Cookie c : cookies) {
                    if ("unify_user_id".equals(c.getName())) {
                        user = UserDAO.getUserById(c.getValue());
                        if (user != null) {
                            req.getSession(true).setAttribute("user", user);
                        }
                        break;
                    }
                }
            }
        }
        if (user != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
            return;
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        User user = UserDAO.login(email, password);
        if (user != null) {
            HttpSession session = req.getSession(true);
            session.setMaxInactiveInterval(365 * 24 * 60 * 60);
            session.setAttribute("user", user);

            Cookie authCookie = new Cookie("unify_user_id", user.id);
            authCookie.setMaxAge(365 * 24 * 60 * 60);
            authCookie.setPath("/");
            authCookie.setHttpOnly(true);
            resp.addCookie(authCookie);

            resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
        } else {
            req.setAttribute("error", "Invalid email or password!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}
