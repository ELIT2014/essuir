<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.storage.rdbms.DatabaseManager" %>
<%@ page import="org.dspace.storage.rdbms.TableRow" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="org.dspace.storage.rdbms.TableRowIterator" %>

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
         context = UIUtil.obtainContext(request);

         String monthNow = java.util.Calendar.getInstance().get(java.util.Calendar.MONTH) + 1 + "";
         String dayNow = java.util.Calendar.getInstance().get(java.util.Calendar.DAY_OF_MONTH) + "";
         String yearNow = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR) + "";

         int monthFrom = Integer.parseInt(request.getParameter("monthFrom") == null ? monthNow : request.getParameter("monthFrom"));
         int dayFrom = Integer.parseInt(request.getParameter("dayFrom") == null ? dayNow : request.getParameter("dayFrom"));
         int yearFrom = Integer.parseInt(request.getParameter("yearFrom") == null ? yearNow : request.getParameter("yearFrom"));

         int monthTo = Integer.parseInt(request.getParameter("monthTo") == null ? monthNow : request.getParameter("monthTo"));
         int dayTo = Integer.parseInt(request.getParameter("dayTo") == null ? dayNow : request.getParameter("dayTo"));
         int yearTo = Integer.parseInt(request.getParameter("yearTo") == null ? yearNow : request.getParameter("yearTo"));

         int faculty = Integer.parseInt(request.getParameter("faculty") == null ? yearNow : request.getParameter("faculty"));

         String showAll = request.getParameter("show") == null ? "" : request.getParameter("show");
         
         StringBuilder sb = new StringBuilder("<table align=\"center\" width=\"95%\"><tr><td>" + 
                                              "<form action=\"faculty_stat.jsp\" method=\"get\"><table>");
            
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

         sb.append("</td></tr><tr><td colspan=\"3\"><select name=\"faculty\"><option value=\"0\"></option>");

         java.util.Hashtable<Integer, String> facultyNames = new java.util.Hashtable<Integer, String>();

         try {
             TableRowIterator tri = null;
             int i = 1;
             try {
                 tri = DatabaseManager.query(context, "SELECT faculty_id, faculty_name FROM faculty ORDER BY faculty_id ");

                 while (tri.hasNext()) {
                     TableRow row = tri.next();
  
                     i = row.getIntColumn("faculty_id");

                     sb.append("<option value=\"" + i)
                       .append(faculty == i ? "\" selected=\"selected\"" : "\"" )
                       .append("\">" + row.getStringColumn("faculty_name") + "</option>");

                     facultyNames.put(i, row.getStringColumn("faculty_name"));
                 }
             } finally {
                 if (tri != null)
                     tri.close();
             }
         } catch (SQLException e) {
             %><%=e.toString()%><%
         }
         
         sb.append("</select>");
         
         sb.append("</td></tr><tr><td><input type=\"checkbox\" name=\"show\" value=\"all\"" + (showAll.equals("all") ? " checked " : "") + ">Details");

         sb.append("</td></tr></table><input type=\"submit\" value=\"Query\"/></form></td></tr></table>");
%>
  <%=sb.toString()%>
<table align="center" width="95%" border="1">
<%
    try {
        TableRowIterator tri = null;
        long docs = -1;
        long summ;
        
        if (faculty > 0) {
          int chair_id;
          String chair_name = null;
          try {
              String query = "select faculty_id, chair.chair_id, lastname, firstname, chair_name, submits from chair " +
                      "right join " +
                      "(select eperson.*, count(metadatavalue.item_id) as submits " +
                      "from eperson " +
                      "left join chair on chair.chair_id = eperson.chair_id " +
                      "right join item on item.submitter_id = eperson_id and in_archive " +
                      "right join metadatavalue on metadatavalue.item_id = item.item_id and metadata_field_id = 11 and text_value between '" + String.format("%d-%02d-%02d", yearFrom, monthFrom, dayFrom) + "' and '" + String.format("%d-%02d-%02d", yearTo, monthTo, dayTo) + "' " +
                      "group by eperson_id) person on person.chair_id = chair.chair_id  where faculty_id = " + faculty + " ORDER BY chair.chair_id, lastname, firstname  ";
              tri = DatabaseManager.query(context, query);
              summ = 0;
              chair_id = 0;
              sb.setLength(0);
              sb.append("<table width=\"100%\">");

              while (tri.hasNext()) {
                  TableRow row = tri.next();
      
                  if (row.getIntColumn("chair_id") != chair_id && chair_id > 0) {
                    sb.append("</table>");
                  
                    %><tr>
                        <td width="90%" class="evenRowOddCol"><%= chair_name %></td>
                        <td class="evenRowOddCol" align="center"><%=summ <= 0 ? "-" : summ %></td>
                    <% if (showAll.equals("all") && summ > 0) { %>
                        <tr><td colspan="2" class="evenRowEvenCol"><%= sb.toString() %></td></tr> 
                        <% } %>
                    </tr><%
                    
                    summ = 0;
                    sb.setLength(0);
                    sb.append("<table width=\"100%\">");
                  }

                  docs = row.getLongColumn("submits");
                   
                  summ += docs < 0 ? 0 : docs;

                  chair_id = row.getIntColumn("chair_id");
                  chair_name = row.getStringColumn("chair_name");

                  sb.append("<tr><td width=\"90%\">" + row.getStringColumn("lastname") + " " + row.getStringColumn("firstname") + "</td><td align=\"center\">" + (docs < 0 ? "-" : docs) + "</td></tr>");
              }

              if (chair_id > 0) {
                sb.append("</table>");

                %><tr>
                    <td width="90%" class="evenRowOddCol"><%= chair_name %></td>
                    <td class="evenRowOddCol" align="center"><%=summ <= 0 ? "-" : summ %></td>
                <% if (showAll.equals("all") && summ > 0) { %>
                    <tr><td colspan="2" class="evenRowEvenCol"><%= sb.toString() %></td></tr> 
                <% } %>
                </tr><%
              } else {
                %>No results<%
              }
          } finally {
              if (tri != null)
                  tri.close();
          }
        
        } else {
          int faculty_id;
          try {
              tri = DatabaseManager.query(context, "select faculty_id, chair.chair_id, chair_name, count(*) as submits " +
                      "from chair " +
                      "left join eperson on eperson.chair_id = chair.chair_id " +
                      "left join item on item.submitter_id = eperson_id " +
                      "left join metadatavalue on metadatavalue.item_id = item.item_id " +
                      "where in_archive and metadata_field_id = 11 and text_value between '" + String.format("%d-%02d-%02d", yearFrom, monthFrom, dayFrom) + "' and '" + String.format("%d-%02d-%02d", yearTo, monthTo, dayTo) + "' " +
                      "group by faculty_id, chair.chair_id, chair_name ORDER BY faculty_id, chair.chair_id"
              );
              summ = 0;
              faculty_id = 0;
              sb.setLength(0);
              sb.append("<table width=\"100%\">");

              while (tri.hasNext()) {
                  TableRow row = tri.next();
      
                  if (row.getIntColumn("faculty_id") != faculty_id && faculty_id > 0) {
                    sb.append("</table>");
                  
                    %><tr>
                        <td width="90%" class="evenRowOddCol"><%= facultyNames.get(faculty_id) %></td>
                        <td class="evenRowOddCol" align="center"><%=summ <= 0 ? "-" : summ %></td>
                    <% if (showAll.equals("all")) { %>
                        <tr><td colspan="2" class="evenRowEvenCol"><%= sb.toString() %></td></tr> 
                    <% } %>
                    </tr><%
                    
                    summ = 0;
                    sb.setLength(0);
                    sb.append("<table width=\"100%\">");
                  }

                  docs = row.getLongColumn("submits");

                  summ += docs < 0 ? 0 : docs;

                  faculty_id = row.getIntColumn("faculty_id");

                  sb.append("<tr><td width=\"90%\">" + row.getStringColumn("chair_name") + "</td><td align=\"center\">" + (docs < 0 ? "-" : docs) + "</td></tr>");
              }

              sb.append("</table>");
                  
              %><tr>
                  <td width="90%" class="evenRowOddCol"><%= facultyNames.get(faculty_id) %></td>
                  <td class="evenRowOddCol" align="center"><%=summ <= 0 ? "-" : summ %></td>
              <% if (showAll.equals("all")) { %>
                  <tr><td colspan="2" class="evenRowEvenCol"><%= sb.toString() %></td></tr> 
              <% } %>
              </tr><%

          } finally {
              if (tri != null)
                  tri.close();
          }
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
