<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.dspace.core.Constants" %>
<%@ page import="org.dspace.content.Item"        %>
<%@ page import="org.dspace.sort.SortOption" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.Set" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>


<%
  String query = (String) request.getAttribute("query");
  
  String query1       = request.getParameter("query1") == null ? "" : request.getParameter("query1");
  String query2       = request.getParameter("query2") == null ? "" : request.getParameter("query2");
  String query3       = request.getParameter("query3") == null ? "" : request.getParameter("query3");

  String field1       = request.getParameter("field1") == null ? "ANY" : request.getParameter("field1");
  String field2       = request.getParameter("field2") == null ? "ANY" : request.getParameter("field2");
  String field3       = request.getParameter("field3") == null ? "ANY" : request.getParameter("field3");

  String conjunction1   = request.getParameter("conjunction1") == null ? "AND" : request.getParameter("conjunction1");
  String conjunction2   = request.getParameter("conjunction2") == null ? "AND" : request.getParameter("conjunction2");

  String order = (String)request.getAttribute("order");
  String ascSelected = (SortOption.ASCENDING.equalsIgnoreCase(order)   ? "selected=\"selected\"" : "");
  String descSelected = (SortOption.DESCENDING.equalsIgnoreCase(order) ? "selected=\"selected\"" : "");
  SortOption so = (SortOption)request.getAttribute("sortedBy");
  String sortedBy = (so == null) ? null : so.getName();

  // Get the attributes
  Item[] items = (Item[]) request.getAttribute("items");

  int pageTotal   = ((Integer)request.getAttribute("pagetotal")).intValue();
  int rpp         = UIUtil.getIntParameter(request, "rpp");
  int etAl        = UIUtil.getIntParameter(request, "etal");

  String searchScope = "";

%>

<dspace:layout locbar="nolink" titlekey="jsp.search.advanced.title">

<form action="<%= request.getContextPath() %>/dsrequest" method="get">
<input type="hidden" name="creation" value="true"/>
        <p><strong>Create request link</strong>&nbsp;</p>

         <table cellspacing="2" border="0" width="400">
      <tr>
                <td>
                    <table border="0">
            <tr>
            <td width="12%" align="left" valign="top"></td>
              <td width="20%" align="left" valign="top" nowrap="nowrap">
                <%-- Search type: <br> --%>
                <label for="tfield1"><fmt:message key="jsp.search.advanced.type"/></label> <br/>
                  <select name="field1" id="tfield1">
                    <option value="ANY" <%= field1.equals("ANY") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.keyword"/></option>
                    <option value="author" <%= field1.equals("author") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.author"/></option>
                    <option value="title" <%= field1.equals("title") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.title"/></option>
                    <option value="keyword" <%= field1.equals("keyword") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.subject"/></option>
                    <option value="abstract" <%= field1.equals("abstract") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.abstract"/></option>
                    <option value="series" <%= field1.equals("series") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.series"/></option>
                    <option value="sponsor" <%= field1.equals("sponsor") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.sponsor"/></option>
                    <option value="identifier" <%= field1.equals("identifier") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.id"/></option>
                    <option value="language" <%= field1.equals("language") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.language"/></option>
                  </select>
            </td>

            <td align="left" valign="top" nowrap="nowrap" width="68%">
                <%-- Search for: <br> --%>
                <label for="tquery1"><fmt:message key="jsp.search.advanced.searchfor"/></label> <br/>
                <input type="text" name="query1" id="tquery1" value="<%=StringEscapeUtils.escapeHtml(query1)%>" size="30" />
                <br/>
            </td>
          </tr>


            <tr>
            <td width="12%" align="left" valign="top"></td>
              <td width="20%" align="left">
                <label for="ttype"><fmt:message key="itemlist.dc.type"/>:</label><br/>
</td>
<td>

<%
      java.util.Locale sessionLocale = org.dspace.app.webui.util.UIUtil.getSessionLocale(request);
      String locale = sessionLocale.toString();
      java.util.List vList = org.dspace.app.util.DCInputsReader.getInputsReader(locale).getPairs("common_types");

      out.println("<select name=type>");
      String type = request.getParameter("type");

      out.println("<option value=\"any\" " + (type == null || type.equals("") ? "selected=\"selected\"" : "") + "></option>");

      for (int i = 0; i < vList.size(); i += 2) { 
        out.println("<option value=\"" + vList.get(i + 1) + "\"" + (vList.get(i + 1).equals(type) ? "selected=\"selected\"" : "") + ">" + vList.get(i) + "</option>");
      }

      out.println("</select>");
%>




            </td>

          </tr>



          <tr>
            <td width="12%" align="left" valign="top">
              <select name="conjunction1">
                <option value="AND" <%= conjunction1.equals("AND") ? "selected=\"selected\"" : "" %>> <fmt:message key="jsp.search.advanced.logical.and" /> </option>
    <option value="OR" <%= conjunction1.equals("OR") ? "selected=\"selected\"" : "" %>> <fmt:message key="jsp.search.advanced.logical.or" /> </option>
                <option value="NOT" <%= conjunction1.equals("NOT") ? "selected=\"selected\"" : "" %>> <fmt:message key="jsp.search.advanced.logical.not" /> </option>
              </select>
            </td>
            <td width="20%" align="left" valign="top" nowrap="nowrap">
                  <select name="field2">
                    <option value="ANY" <%= field2.equals("ANY") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.keyword"/></option>
                    <option value="author" <%= field2.equals("author") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.author"/></option>
                    <option value="title" <%= field2.equals("title") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.title"/></option>
                    <option value="keyword" <%= field2.equals("keyword") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.subject"/></option>
                    <option value="abstract" <%= field2.equals("abstract") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.abstract"/></option>
                    <option value="series" <%= field2.equals("series") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.series"/></option>
                    <option value="sponsor" <%= field2.equals("sponsor") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.sponsor"/></option>
                    <option value="identifier" <%= field2.equals("identifier") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.id"/></option>
                    <option value="language" <%= field2.equals("language") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.language"/></option>
                  </select>
           </td>
            <td align="left" valign="top" nowrap="nowrap" width="68%">
              <input type="text" name="query2" value="<%=StringEscapeUtils.escapeHtml(query2)%>" size="30"/>
            </td>
          </tr>
          <tr>
            <td width="12%" align="left" valign="top">
              <select name="conjunction2">
                <option value="AND" <%= conjunction2.equals("AND") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.logical.and" /> </option>
                <option value="OR" <%= conjunction2.equals("OR") ? "selected=\"selected\"" : "" %>> <fmt:message key="jsp.search.advanced.logical.or" /> </option>
                <option value="NOT" <%= conjunction2.equals("NOT") ? "selected=\"selected\""  : "" %>> <fmt:message key="jsp.search.advanced.logical.not" /> </option>
              </select>
            </td>
            <td width="20%" align="left" valign="top" nowrap="nowrap">

                  <select name="field3">
                    <option value="ANY" <%= field3.equals("ANY") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.keyword"/></option>
                    <option value="author" <%= field3.equals("author") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.author"/></option>
                    <option value="title" <%= field3.equals("title") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.title"/></option>
                    <option value="keyword" <%= field3.equals("keyword") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.subject"/></option>
                    <option value="abstract" <%= field3.equals("abstract") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.abstract"/></option>
                    <option value="series" <%= field3.equals("series") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.series"/></option>
                    <option value="sponsor" <%= field3.equals("sponsor") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.sponsor"/></option>
                    <option value="identifier" <%= field3.equals("identifier") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.id"/></option>
                    <option value="language" <%= field3.equals("language") ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.search.advanced.type.language"/></option>
                  </select>
                  <br/>
            </td>
            <td align="left" valign="top" nowrap="nowrap" width="68%">
              <input type="text" name="query3" value="<%=StringEscapeUtils.escapeHtml(query3)%>" size="30"/>
            </td>

  </tr>
  <tr>
    <td colspan="2" align="right">
           <fmt:message key="search.results.perpage"/>
    </td>
    <td align="left">
           <select name="rpp">
<%                 String selected = (-1 == rpp ? "selected=\"selected\"" : ""); %>
                   <option value="<%= -1 %>" <%= selected %>>All</option>
<%
               for (int i = 5; i <= 100 ; i += 5)
               {
                   selected = (i == rpp ? "selected=\"selected\"" : "");
%>
                   <option value="<%= i %>" <%= selected %>><%= i %></option>
<%
               }
%>
           </select>
    </td>
  </tr>

  <tr>
    <td colspan="2" align="right">
           Starts from item
    </td>
    <td align="left">

<%	int start = UIUtil.getIntParameter(request, "start");
%>
           <input name="start" value="<%= start %>" />
    </td>
  </tr>


  <tr>
    <td colspan="2" align="right">
               <fmt:message key="search.results.sort-by"/>
    </td>
    <td align="left">
<%
           Set<SortOption> sortOptions = SortOption.getSortOptions();
           if (sortOptions.size() > 1)
           {
%>
               <select name="sort_by">
                   <option value="0"><fmt:message key="search.sort-by.relevance"/></option>
<%
               for (SortOption sortBy : sortOptions)
               {
                   if (sortBy.isVisible())
                   {
                       selected = (sortBy.getName().equals(sortedBy) ? "selected=\"selected\"" : "");
                       String mKey = "search.sort-by." + sortBy.getName();
                       %> <option value="<%= sortBy.getNumber() %>" <%= selected %>><fmt:message key="<%= mKey %>"/></option><%
                   }
               }
%>
               </select>
<%
           }
%>
    
    </td>
  </tr>

  <tr>
    <td colspan="2" align="right">
           <fmt:message key="search.results.order"/>
    </td>
    <td align="left">
           <select name="order">
               <option value="ASC" <%= ascSelected %>><fmt:message key="search.order.asc" /></option>
               <option value="DESC" <%= descSelected %>><fmt:message key="search.order.desc" /></option>
           </select>
    </td>
  </tr>


  <tr>
    <td colspan="2" align="right">
           <fmt:message key="search.results.etal" />
    </td>
    <td align="left">
           <select name="etal">
<%
               String unlimitedSelect = "";
               if (etAl < 1)
               {
                   unlimitedSelect = "selected=\"selected\"";
               }
%>
               <option value="0" <%= unlimitedSelect %>><fmt:message key="browse.full.etal.unlimited"/></option>
<%
               boolean insertedCurrent = false;
               for (int i = 0; i <= 50 ; i += 5)
               {
                   // for the first one, we want 1 author, not 0
                   if (i == 0)
                   {
                       String sel = (i + 1 == etAl ? "selected=\"selected\"" : "");
                       %><option value="1" <%= sel %>>1</option><%
                   }

                   // if the current i is greated than that configured by the user,
                   // insert the one specified in the right place in the list
                   if (i > etAl && !insertedCurrent && etAl > 1)
                   {
                       %><option value="<%= etAl %>" selected="selected"><%= etAl %></option><%
                       insertedCurrent = true;
                   }

                   // determine if the current not-special case is selected
                   selected = (i == etAl ? "selected=\"selected\"" : "");

                   // do this for all other cases than the first and the current
                   if (i != 0 && i != etAl)
                   {
%>
                       <option value="<%= i %>" <%= selected %>><%= i %></option>
<%
                   }
               }
%>
           </select>
    </td>
  </tr>

  </table>
</td>
</tr>
  <tr>
    <td valign="bottom" align="right" nowrap="nowrap">
      &nbsp; &nbsp; &nbsp;
      <input type="submit" name="submit" value="Generate" />
            &nbsp;  &nbsp; &nbsp;
      <input type="reset" name="reset" value="Reset" />
    </td>
  </tr>
</table>
</form>

<br/>
Result link:<br/>
<input size="60" value="<%= "http://essuir.sumdu.edu.ua/dsrequest?query=" + 
              URLEncoder.encode(query, Constants.DEFAULT_ENCODING) + 
              "&rpp=" + rpp + "&start=" + start + "&sort_by=" + (so == null ? 0 : so.getNumber()) + "&order=" + order + "&etal=" + etAl +"" %>"/>
<br/>
<br/>
Search results:<br/>
<%    if (items.length > 0) { %>
        <dspace:itemlist items="<%= items %>" sortOption="<%= so %>" authorLimit="<%= etAl %>" />
<%  } %>



</dspace:layout>
