package unify;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Cookie;
import unify.Models.User;

public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        boolean isPublic = uri.endsWith("/login") || uri.endsWith("/login.jsp") 
                        || uri.endsWith("/index.jsp") || uri.endsWith("/")
                        || uri.endsWith("/activities.jsp") || uri.endsWith("/activities")
                        || uri.contains("/css/");

        HttpSession session = req.getSession(true);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            Cookie[] cookies = req.getCookies();
            if (cookies != null) {
                for (Cookie c : cookies) {
                    if ("unify_user_id".equals(c.getName())) {
                        String uid = c.getValue();
                        User restored = UserDAO.getUserById(uid);
                        if (restored != null) {
                            user = restored;
                            session.setMaxInactiveInterval(365 * 24 * 60 * 60);
                            session.setAttribute("user", user);
                        }
                        break;
                    }
                }
            }
        }

        if (user != null && (uri.endsWith("/login") || uri.endsWith("/login.jsp"))) {
            res.sendRedirect(req.getContextPath() + "/dashboard.jsp");
            return;
        }

        if (isPublic || user != null) {
            chain.doFilter(request, response);
        } else {
            if (uri.endsWith("/dashboard.jsp") || uri.endsWith("/dashboard")) {
                res.sendRedirect(req.getContextPath() + "/activities.jsp");
            } else {
                res.sendRedirect(req.getContextPath() + "/login");
            }
        }
    }

    @Override
    public void destroy() {}
}
