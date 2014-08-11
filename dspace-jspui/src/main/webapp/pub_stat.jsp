<%--
  - FAQ page JSP
  -
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.io.File" %>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Locale"%>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.browse.ItemCounter" %>

<%
    Locale sessionLocale = UIUtil.getSessionLocale(request);
    
    String locale = sessionLocale.toString();
    String stats = locale.equals("en") ? "stat.html" : "stat_" + locale + ".html";

    stats = ConfigurationManager.readNewsFile(stats);
    
    org.dspace.core.Context context = org.dspace.app.webui.util.UIUtil.obtainContext(request);
    ua.edu.sumdu.essuir.StatisticData sd = ua.edu.sumdu.essuir.EssuirStatistics.getTotalStatistic(context);

    long totalViews = sd.getTotalViews();
    long totalDownloads = sd.getTotalDownloads();

    stats = String.format(stats, sd.getTotalCount(), totalViews, totalDownloads,
            totalViews - 237448 - 619598, totalViews - 237448,
            totalDownloads - 322936 - 1005971, totalDownloads - 322936);
    
    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));
%>

<dspace:layout locbar="nolink" titlekey="jsp.layout.navbar-admin.statistics">
     <%= stats %>
</dspace:layout>
