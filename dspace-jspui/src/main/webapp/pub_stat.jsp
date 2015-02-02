<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page import="java.util.Locale"%>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>

<%
    Locale sessionLocale = UIUtil.getSessionLocale(request);

    String locale = sessionLocale.toString();
    String stats = locale.equals("en") ? "stat.html" : "stat_" + locale + ".html";

    stats = ConfigurationManager.readNewsFile(stats);

    org.dspace.core.Context context = org.dspace.app.webui.util.UIUtil.obtainContext(request);
    ua.edu.sumdu.essuir.StatisticData sd = ua.edu.sumdu.essuir.EssuirStatistics.getTotalStatistic(context);

    long totalViews = sd.getTotalViews();
    long totalDownloads = sd.getTotalDownloads();

    final int year2011Views = 237448;
    final int year2011Downloads = 322936;

    final int year2012Views = 750963;
    final int year2012Downloads = 1198317;

    final int year2013Views = 1309485;
    final int year2013Downloads = 2638394;

    final int year2014Views = 4003814;
    final int year2014Downloads = 4491129 ;

    final int janViews = 109276;
    final int janDownloads = 189743;

    final int febViews = -1;  // current month
    final int febDownloads = -1;


    stats = String.format(stats, sd.getTotalCount(), totalViews, totalDownloads,
            totalViews - year2011Views - year2012Views - year2013Views - year2014Views - janViews, // current month views
            totalViews - year2011Views - year2012Views - year2013Views - year2014Views, // current year views
            totalDownloads - year2011Downloads  - year2012Downloads - year2013Downloads - year2014Downloads - janDownloads, // current month downloads
            totalDownloads - year2011Downloads - year2012Downloads - year2013Downloads - year2014Downloads); // current year downloads
%>

<dspace:layout locbar="nolink" titlekey="jsp.layout.navbar-admin.statistics">
    <%= stats %>
</dspace:layout>
