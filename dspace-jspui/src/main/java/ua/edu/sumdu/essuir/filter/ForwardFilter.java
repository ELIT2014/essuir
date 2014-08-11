package ua.edu.sumdu.essuir.filter;


import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;


public class ForwardFilter implements Filter {

    protected FilterConfig filterConfig = null;

    public void destroy() {
        this.filterConfig = null;
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        String url = request.getServerName();
  
        if (!url.endsWith("essuir.sumdu.edu.ua")) 
            ((javax.servlet.http.HttpServletResponse)response).sendRedirect("http://lib.sumdu.edu.ua/library/DocSearchForm"); 
        else
            chain.doFilter(request, response);
    }

    public void init(FilterConfig filterConfig) throws ServletException {
        this.filterConfig = filterConfig;
    }

}
