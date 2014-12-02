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

    final int janViews = 129489;  // current month
    final int janDownloads = 234202;
    final int febViews = 318459;
    final int febDownloads = 615975;


    final int marViews = 162056;
    final int marDownloads = 455284;

    final int aprViews = 160888;
    final int aprDownloads = 385879;

    final int mayViews = 152717;
    final int mayDownloads = 407188;

    final int juneViews = 164901;
    final int juneDownloads = 353624;

    final int julyViews = 71293;
    final int julyDownloads = 133070;

    final int augustViews = 86200;
    final int augustDownloads = 68163;

    final int septemberViews = 300045;
    final int septemberDownloads = 492900;

    final int octoberViews = 186357;
    final int octoberDownloads = 576457;

    final int novemberViews = 161357;
    final int novemberDownloads = 418954;

    final int decemberViews = -1; // current month
    final int decemberDownloads = -1;

    stats = String.format(stats, sd.getTotalCount(), totalViews, totalDownloads,
            totalViews - year2011Views - year2012Views - year2013Views - janViews - febViews - marViews - aprViews - mayViews - juneViews - julyViews - augustViews - septemberViews - octoberViews - novemberViews, // current month views
            totalViews - year2011Views - year2012Views - year2013Views, // current year views
            totalDownloads - year2011Downloads  - year2012Downloads - year2013Downloads - janDownloads - febDownloads - marDownloads - aprDownloads - mayDownloads - juneDownloads - julyDownloads - augustDownloads - septemberDownloads - octoberDownloads - novemberDownloads, // current month downloads
            totalDownloads - year2011Downloads - year2012Downloads - year2013Downloads); // current year downloads
%>

<dspace:layout locbar="nolink" titlekey="jsp.layout.navbar-admin.statistics">
    <%= stats %>
</dspace:layout>
