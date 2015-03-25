<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page import="java.util.Locale"%>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>

<%
    Locale sessionLocale = UIUtil.getSessionLocale(request);

    String locale = sessionLocale.toString();
    String stats ="<script src=\"http://code.jquery.com/jquery-1.10.2.min.js\" type=\"text/javascript\" ></script>\n" +
            "<script type=\"text/javascript\" src=\"ajaxStatistics.js\"></script>";
    String name = locale.equals("en") ? "stat.html" : "stat_" + locale + ".html";

    stats = stats + ConfigurationManager.readNewsFile(name);
%>

<dspace:layout locbar="nolink" titlekey="jsp.layout.navbar-admin.statistics">
    <%= stats %>
</dspace:layout>
