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
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.core.Constants"  %>

<%  org.dspace.core.Context context = org.dspace.app.webui.util.UIUtil.obtainContext(request); 
    EPerson user = (EPerson) request.getAttribute("dspace.current.user");
    String userEmail = "";

    if (user != null)
        userEmail = user.getEmail().toLowerCase();

    Boolean admin = (Boolean) request.getAttribute("is.admin");
    boolean isAdmin = (admin == null ? false : admin.booleanValue());

    if (isAdmin || userEmail.equals("library_ssu@ukr.net") || userEmail.equals("libconsult@rambler.ru")) {

	String action = request.getParameter("action");	
	String id = request.getParameter("id");
	String collection = request.getParameter("collection");

	if (action != null) {
	   	String query = null;
		
		if (action.equals("add")) {
			query = "INSERT INTO eperson_service VALUES ('" + id + "', '" + collection + "'); COMMIT; ";
		} else if (action.equals("remove")) {
			query = "DELETE FROM eperson_service WHERE eperson_id=" + id + "; COMMIT; ";
		}

	        try {
	            if (query != null && DatabaseManager.updateQuery(context, query) >= 1) {
	            } else {
	                %><palign="center" style="color: red">Операция не выполнена!<br/><%
	            }
        	} catch (SQLException e) {
		    context.getDBConnection().rollback();

	            try {
	                java.io.FileWriter writer = new java.io.FileWriter("D:/projcoder.txt", true);
	                writer.write("Authors remove exception at " + (new java.util.Date()) + "\n");
			writer.write("\t" + e + "\n");	
			writer.close();
	            } catch (Exception exc) {}
	            %><p align="center" style="color: red">Операция не выполнена!<br/> <%
	        }
	}


	Collection[] collections = Collection.findAuthorized(context, null, Constants.ADD);
	EPerson[] epeople = EPerson.findAll(context, EPerson.ID);

	java.util.Hashtable<Integer, Collection> colls = new java.util.Hashtable<Integer, Collection>();

	for (int i = 0; i < collections.length; i++) 
		colls.put(collections[i].getID(), collections[i]);

	java.util.Hashtable<Integer, EPerson> persons = new java.util.Hashtable<Integer, EPerson>();

	for (int i = 0; i < epeople.length; i++) 
		persons.put(epeople[i].getID(), epeople[i]);

	EPerson ep = null;
%>

<dspace:layout locbar="nolink" title="Удаленная отправка ресурсов" feedData="NONE">

<table align="center" width="80%" border="1">
    <tr>
	<th bgcolor="lightsteelblue">Пользователь</th>
	<th bgcolor="lightsteelblue">Коллекция</th>
	<th bgcolor="lightsteelblue">Действие</th>
    </tr>
<%
	
    try {
        TableRowIterator tri = null;

        try {
            tri = DatabaseManager.query(context, "SELECT * FROM eperson_service;");

	    String link = null;

            while (tri.hasNext()) {
                TableRow row = tri.next();

                link = "?action=remove&id=" + row.getIntColumn("eperson_id");

                %>
		<tr>
			<td>    <% ep = persons.get(row.getIntColumn("eperson_id")); %>
				<%=ep.getFirstName() + " " + ep.getLastName() + " ("+ ep.getEmail() + ")" %>
			</td>
			<td>
				<%=colls.get(row.getIntColumn("collection_id")).getMetadata("name") %>
			</td>
			<td bgcolor="white" align="center">
				<a href="manage.jsp<%=link%>">Удалить</a>
			</td>
		</tr>
<%
            }
        } finally {
            if (tri != null)
                tri.close();
        }
    } catch (SQLException e) {
            try {
                java.io.FileWriter writer = new java.io.FileWriter("D:/projcoder.txt", true);
                writer.write("Authors exception at " + (new java.util.Date()) + "\n");
		writer.write("\t" + e + "\n");	
		writer.close();
            } catch (Exception exc) {}
    }
%>

</table>

</br>
</br>

<table align="center" border="1" width="80%"><tr><th bgcolor="lightsteelblue">

Добавить новое разрешение на удаленную отправку</th></tr><tr><td>

<table width="100%">
<form action="manage.jsp">
	<tr><td>Пользователь</td><td>
		<select name="id">

<%
	for (int i = 0; i < epeople.length; i++) {
		%><option value="<%=epeople[i].getID() %>"
		<%= id != null && id.equals(epeople[i].getID() + "") ? " selected=\"selected\" " : "" %>
			><%= epeople[i].getFirstName() + " " + epeople[i].getLastName() + " ("+ epeople[i].getEmail() + ")"
		%></option><%
	}
%>

		</select>
	</td></tr>
	<tr><td>Коллекция</td><td>
	<select name="collection">

<%
	for (int i = 0; i < collections.length; i++) {
		%><option value="<%=collections[i].getID() %>"
		<%= collection != null && collection.equals(collections[i].getID() + "") ? " selected=\"selected\" " : "" %>
			><%=collections[i].getMetadata("name") 
		%></option><%
	}
%>

	</select></td></tr>
	<tr><td colspan="2" align="right">
		<input name="action" value="add" type="hidden" />
		<input value="Добавить" type="submit" />
	</td></tr>
</form>
</table></td></th></table>

</dspace:layout>

<%
  } else {
    org.dspace.app.webui.util.JSPManager.showAuthorizeError(request, response, null);
  }
%>
