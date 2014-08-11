<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.storage.rdbms.DatabaseManager" %>
<%@ page import="org.dspace.storage.rdbms.TableRowIterator" %>
<%@ page import="org.dspace.storage.rdbms.TableRow" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="java.sql.SQLException" %>

<% org.dspace.core.Context context = org.dspace.app.webui.util.UIUtil.obtainContext(request); 
   
   EPerson user = (EPerson) request.getAttribute("dspace.current.user");
   String userEmail = "";

   if (user != null)
       userEmail = user.getEmail().toLowerCase();

   Boolean admin = (Boolean) request.getAttribute("is.admin");
   boolean isAdmin = (admin == null ? false : admin.booleanValue());

   if (isAdmin || userEmail.equals("library_ssu@ukr.net") || userEmail.equals("libconsult@rambler.ru")) {
%>

<dspace:layout locbar="nolink" title="Statistics" feedData="NONE">

<%       
        StringBuilder sb = new StringBuilder("<pre>");
            
	try {
		java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.InputStreamReader(new java.io.FileInputStream("D:/projcoder.txt")));
		String line = "";

		line = reader.readLine();
		while (line != null) {
			sb.append(line + "\n");

			line = reader.readLine();
		}
		reader.close();
	} catch (Exception e) {}

        sb.append("</pre>");
%>

  <%=sb.toString()%>

</dspace:layout>

<%
  } else {
    org.dspace.app.webui.util.JSPManager.showAuthorizeError(request, response, null);
  }
%>
