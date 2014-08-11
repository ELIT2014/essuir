<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
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

<dspace:layout locbar="nolink" title="Visit statistics" feedData="NONE">

<%       
%>
<table align="center" width="95%" border="1">
    <tr>
        <th class="evenRowEvenCol">Item ID</th>
        <th class="evenRowEvenCol">Segment ID</th>
        <th class="evenRowEvenCol">View count</th>
    </tr>

<%
    context = UIUtil.obtainContext(request);

    try {
        TableRowIterator tri = null;

        try {
            tri = DatabaseManager.query(context, "SELECT * FROM statistics");
            while (tri.hasNext()) {
                TableRow row = tri.next();

                %><tr>
                    <td class="evenRowOddCol"><%=row.getIntColumn("item_id") %></td>
                    <td class="evenRowOddCol"><%=row.getIntColumn("sequence_id") %></td>
                    <td class="evenRowOddCol"><%=row.getIntColumn("view_cnt") %></td>
                </tr><%
            }
        } finally {
            if (tri != null)
                tri.close();
        }
    } catch (SQLException e) {
        %><%=e.toString()%><%
    }

%>
</table>
</dspace:layout>


<%
  } else {
    org.dspace.app.webui.util.JSPManager.showAuthorizeError(request, response, null);
  }
%>
