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

<dspace:layout locbar="nolink" title="Statistics" feedData="NONE">

<%       
         String monthNow = java.util.Calendar.getInstance().get(java.util.Calendar.MONTH) + 1 + "";
         String dayNow = java.util.Calendar.getInstance().get(java.util.Calendar.DAY_OF_MONTH) + "";
         String yearNow = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR) + "";

         int monthFrom = Integer.parseInt(request.getParameter("monthFrom") == null ? monthNow : request.getParameter("monthFrom"));
         int dayFrom = Integer.parseInt(request.getParameter("dayFrom") == null ? dayNow : request.getParameter("dayFrom"));
         int yearFrom = Integer.parseInt(request.getParameter("yearFrom") == null ? yearNow : request.getParameter("yearFrom"));

         int monthTo = Integer.parseInt(request.getParameter("monthTo") == null ? monthNow : request.getParameter("monthTo"));
         int dayTo = Integer.parseInt(request.getParameter("dayTo") == null ? dayNow : request.getParameter("dayTo"));
         int yearTo = Integer.parseInt(request.getParameter("yearTo") == null ? yearNow : request.getParameter("yearTo"));

         String showAll = request.getParameter("show") == null ? "" : request.getParameter("show");
         
         StringBuilder sb = new StringBuilder("<table align=\"center\" width=\"95%\"><tr><td>" + 
                                              "<form action=\"stat.jsp\" method=\"get\"><table>");
            
         sb.append("<tr><td>From date:</td>");
         sb.append("<td colspan=\"2\" nowrap=\"nowrap\" class=\"submitFormDateLabel\">");
         sb.append("Month <select name=\"monthFrom\">");
            
         for (int j = 1; j < 13; j++) {
            sb.append("<option value=\"").append(j).append("\"")
              .append(monthFrom == j ? "\" selected=\"selected\"" : "\"" )
              .append(">")
              .append(org.dspace.content.DCDate.getMonthName(j, request.getLocale()))
              .append("</option>");
         }
    
         sb.append("</select> Day <input type=\"text\" name=\"dayFrom\" size=\"2\" maxlength=\"2\" value=\"" + dayFrom + "\"/>");
         sb.append(" Year <input type=\"text\" name=\"yearFrom\" size=\"4\" maxlength=\"4\" value=\"" + yearFrom + "\"/>");

         sb.append("</td></tr><tr><td>To date (not inclusive):</td>");

         sb.append("<td colspan=\"2\" nowrap=\"nowrap\" class=\"submitFormDateLabel\">");
         sb.append(" Month <select name=\"monthTo\">");
            
         for (int j = 1; j < 13; j++) {
            sb.append("<option value=\"").append(j).append("\"")
              .append(monthTo == j ? "\" selected=\"selected\"" : "\"" )
              .append(">")
              .append(org.dspace.content.DCDate.getMonthName(j, request.getLocale()))
              .append("</option>");
         }
    
         sb.append("</select> Day <input type=\"text\" name=\"dayTo\" size=\"2\" maxlength=\"2\" value=\"" + dayTo + "\"/>");
         sb.append(" Year <input type=\"text\" name=\"yearTo\" size=\"4\" maxlength=\"4\" value=\"" + yearTo + "\"/></td>");

         sb.append("</td></tr><tr><td><input type=\"checkbox\" name=\"show\" value=\"all\"" + (showAll.equals("all") ? " checked " : "") + ">Show all epersons");

         sb.append("</td></tr></table><input type=\"submit\" value=\"Query\"/></form></td></tr></table>");
%>
  <%=sb.toString()%>
<table align="center" width="95%" border="1">
    <tr>
        <th class="evenRowEvenCol">EPerson</th>
        <th class="evenRowEvenCol">Faculty</th>
        <th class="evenRowEvenCol">Chair</th>
        <th class="evenRowEvenCol">Count</th>
    </tr>

<%
    context = UIUtil.obtainContext(request);

    try {
        TableRowIterator tri = null;
        try {
            tri = DatabaseManager.query(context, "SELECT COUNT(*) submits " +
                                                 "  FROM item " +
                                                 "  WHERE in_archive = TRUE "+
                                                 "    AND last_modified BETWEEN DATE '" + yearFrom + "-" + monthFrom + "-" + dayFrom + "' " +
                                                 "                          AND DATE '" + yearTo + "-" + monthTo + "-" + dayTo + "' ");

            long all = tri.next().getLongColumn("submits");

            %> Summary: <%=all < 0 ? "-" : all %> <%
        } finally {
            if (tri != null)
                tri.close();
        }
        
        
        tri = null;
        long docs = -1;
        try {
            String join = showAll.equals("all") ? "LEFT" : "RIGHT";    

            tri = DatabaseManager.query(context, "SELECT lastname, firstname, chair_name, faculty_name, count_docs docs " +
                                                 "  FROM eperson " +
                                                 "  " + join + " JOIN (SELECT submitter_id, COUNT(*) count_docs " +
                                                 "      FROM item " +
                                                 "      WHERE in_archive = TRUE "+
                                                 "        AND last_modified BETWEEN DATE '" + yearFrom + "-" + monthFrom + "-" + dayFrom + "' " +
                                                 "                              AND DATE '" + yearTo + "-" + monthTo + "-" + dayTo + "' " +
                                                 "      GROUP BY submitter_id) a " +
                                                 "    ON eperson_id = submitter_id " +
						 "  LEFT JOIN (SELECT chair_id, chair_name, faculty_name  " +
                                                 "          FROM chair  " +
                                                 "          LEFT JOIN faculty  " +
                                                 "          ON chair.faculty_id = faculty.faculty_id) b " +
                                                 "  ON eperson.chair_id = b.chair_id " +
                                                 "  ORDER BY lastname, firstname ");
            while (tri.hasNext()) {
                TableRow row = tri.next();

                %><tr>
                    <td class="evenRowOddCol"><%=row.getStringColumn("lastname") + " " + row.getStringColumn("firstname") %></td>
                    <td class="evenRowOddCol"><%=row.getStringColumn("faculty_name") == null ? "" : row.getStringColumn("faculty_name")%></td>
                    <td class="evenRowOddCol"><%=row.getStringColumn("chair_name") == null ? "" : row.getStringColumn("chair_name")%></td>
                <%
                    docs = row.getLongColumn("docs");
                %>
                    <td class="evenRowOddCol" align="center"><%=docs < 0 ? "-" : docs %></td>


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
