<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Default navigation bar
--%>

<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="/WEB-INF/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.browse.BrowseInfo" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Locale" %>
<%
    // Is anyone logged in?
    EPerson user = (EPerson) request.getAttribute("dspace.current.user");

    // Is the logged in user an admin
    Boolean admin = (Boolean)request.getAttribute("is.admin");
    boolean isAdmin = (admin == null ? false : admin.booleanValue());

    // Get the current page, minus query string
    String currentPage = UIUtil.getOriginalURL(request);
    int c = currentPage.indexOf( '?' );
    if( c > -1 )
    {
        currentPage = currentPage.substring( 0, c );
    }

    // E-mail may have to be truncated
    String navbarEmail = null;

    if (user != null)
    {
        navbarEmail = user.getEmail();
    }

    // get the browse indices

	BrowseIndex[] bis = BrowseIndex.getBrowseIndices();
    BrowseInfo binfo = (BrowseInfo) request.getAttribute("browse.info");
    String browseCurrent = "";
    if (binfo != null)
    {
        BrowseIndex bix = binfo.getBrowseIndex();
        // Only highlight the current browse, only if it is a metadata index,
        // or the selected sort option is the default for the index
        if (bix.isMetadataIndex() || bix.getSortOption() == binfo.getSortOption())
        {
            if (bix.getName() != null)
    			browseCurrent = bix.getName();
        }
    }
%>


       <div class="navbar-header">
         <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
           <span class="icon-bar"></span>
           <span class="icon-bar"></span>
           <span class="icon-bar"></span>
         </button>
         <a class="navbar-brand" href="<%= request.getContextPath() %>/"><img height="25px" src="<%= request.getContextPath() %>/image/dspace-logo-only.png" /></a>
       </div>
       <nav class="collapse navbar-collapse bs-navbar-collapse" role="navigation">
         <ul class="nav navbar-nav">
           <li class="<%= currentPage.endsWith("/home.jsp")? "active" : "" %>"><a href="<%= request.getContextPath() %>/"><span class="glyphicon glyphicon-home"></span> <fmt:message key="jsp.layout.navbar-default.home"/></a></li>

           <li class="dropdown">
             <a href="#" class="dropdown-toggle" data-toggle="dropdown"><fmt:message key="jsp.layout.navbar-default.browse"/> <b class="caret"></b></a>
             <ul class="dropdown-menu">
               <li><a href="<%= request.getContextPath() %>/community-list"><fmt:message key="jsp.layout.navbar-default.communities-collections"/></a></li>
				<li class="divider"></li>
				<li class="dropdown-header"><fmt:message key="jsp.layout.navbar-default.browse-items"/></li>
				<%-- Insert the dynamic browse indices here --%>

				<%
					for (int i = 0; i < bis.length; i++)
					{
						BrowseIndex bix = bis[i];
						String key = "browse.menu." + bix.getName();
					%>
				      			<li><a href="<%= request.getContextPath() %>/browse?type=<%= bix.getName() %>"><fmt:message key="<%= key %>"/></a></li>
					<%
					}
				%>
				<%-- End of dynamic browse indices --%>
				<li class="divider"></li>
				<li><a href="<%= request.getContextPath() %>/new50items.jsp"><fmt:message key="jsp.collection-home.recentsub"/></a></li>
				<li><a href="<%= request.getContextPath() %>/top10items.jsp"><fmt:message key="jsp.top50items"/></a></li>
				<li><a href="<%= request.getContextPath() %>/top10authors.jsp"><fmt:message key="jsp.top10authors"/></a></li>
				<li><a href="<%= request.getContextPath() %>/faq.jsp"><fmt:message key="jsp.layout.navbar-default.faq"/></a></li>
				<li><a href="<%= request.getContextPath() %>/stat/pubstat"><fmt:message key="jsp.layout.navbar-admin.statistics"/></a></li>
            </ul>
          </li>
          <li class="<%= ( currentPage.endsWith( "/help" ) ? "active" : "" ) %>"><dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") %>"><fmt:message key="jsp.layout.navbar-default.help"/></dspace:popup></li>
          <li class="google" style="padding-top: 15px; padding-left: 25px;">
             <!-- Поместите этот тег туда, где должна отображаться кнопка +1. -->
             <div class="g-plusone" data-annotation="inline" data-width="200" data-href="http://essuir.sumdu.edu.ua"></div>

             <!-- Поместите этот тег за последним тегом виджета кнопка +1. -->
              <script type="text/javascript">
                  window.___gcfg = {lang: '<%= UIUtil.getSessionLocale(request).getLanguage() %>'};
                  (function() {
                      var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
                      po.src = 'https://apis.google.com/js/platform.js';
                      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
                  })();
              </script>
          </li>
       </ul>
       <div class="nav navbar-nav navbar-right">
		<ul class="nav navbar-nav navbar-right">
         <li class="dropdown">
         <%
    if (user != null)
    {
		%>
		<a href="#" class="dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-user"></span> <fmt:message key="jsp.layout.navbar-default.loggedin">
		      <fmt:param><%= StringUtils.abbreviate(navbarEmail, 35) %></fmt:param>
		  </fmt:message> <b class="caret"></b></a>
             <ul class="dropdown-menu">
                 <li><a href="<%= request.getContextPath() %>/mydspace"><fmt:message key="jsp.layout.navbar-default.users"/></a></li>
                 <li><a href="<%= request.getContextPath() %>/subscribe"><fmt:message key="jsp.layout.navbar-default.receive"/></a></li>
                 <li><a href="<%= request.getContextPath() %>/profile"><fmt:message key="jsp.layout.navbar-default.edit"/></a></li>

                 <%
                     String userEmail = "";

                     if (user != null)
                         userEmail = user.getEmail().toLowerCase();

                     if (isAdmin || userEmail.equals("library_ssu@ukr.net") || userEmail.equals("libconsult@rambler.ru")) {
                 %>
                 <li class="divider"></li>
                 <li><a href="<%= request.getContextPath() %>/home_stat.jsp"><fmt:message key="jsp.layout.navbar-admin.report"/></a></li>
                 <li><a href="<%= request.getContextPath() %>/authors.jsp"><fmt:message key="jsp.layout.navbar-admin.autocomplete"/></a></li>
                 <li><a href="<%= request.getContextPath() %>/upload/manage.jsp"><fmt:message key="jsp.layout.navbar-admin.remote"/></a></li>
                 <%
                     }
                     if (isAdmin)
                     {
                 %>
                 <li class="divider"></li>
                 <li><a href="<%= request.getContextPath() %>/dspace-admin"><fmt:message key="jsp.administer"/></a></li>
                 <%
                     }
                     if (user != null) {
                 %>
                 <li><a href="<%= request.getContextPath() %>/logout"><span class="glyphicon glyphicon-log-out"></span> <fmt:message key="jsp.layout.navbar-default.logout"/></a></li>
                 <% } %>
             </ul>
		<%
    } else {
		%>
             <a href="/password-login"><span class="glyphicon glyphicon-user"></span> <fmt:message key="jsp.layout.navbar-default.sign"/> </a>
	<% } %>

           </li>
          </ul>

	<%-- Search Box --%>
	<form method="get" action="<%= request.getContextPath() %>/simple-search" class="navbar-form navbar-right" scope="search">
	    <div class="form-group">
          <input type="text" class="form-control" style="cursor:pointer;" onclick="document.getElementById('submit').click();" placeholder="<fmt:message key="jsp.layout.navbar-default.search"/>" name="query" id="tequery" size="25" readonly/>
          <input type="hidden" name="rpp" value="20"/>
        </div>
        <button id="submit" type="submit" class="btn btn-primary"><span class="glyphicon glyphicon-search"></span></button>
<%--               <br/><a href="<%= request.getContextPath() %>/advanced-search"><fmt:message key="jsp.layout.navbar-default.advanced"/></a>
<%
			if (ConfigurationManager.getBooleanProperty("webui.controlledvocabulary.enable"))
			{
%>
              <br/><a href="<%= request.getContextPath() %>/subject-search"><fmt:message key="jsp.layout.navbar-default.subjectsearch"/></a>
<%
            }
%> --%>
	</form></div>
    </nav>
