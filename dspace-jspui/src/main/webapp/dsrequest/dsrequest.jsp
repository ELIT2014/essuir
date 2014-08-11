<%@ page contentType="text/xml;charset=UTF-8" %><%@ 
    taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %><%@ 
    taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %><%@ 
    page import="org.apache.commons.lang.StringEscapeUtils" %><%@ 
    page import="java.net.URLEncoder"            %><%@ 
    page import="org.dspace.content.Item"        %><%@ 
    page import="org.dspace.sort.SortOption" %><%@ 
    page import="java.util.Enumeration" %><%@ 
    page import="java.util.Set" %><%@ 
    page import="org.apache.commons.lang.StringEscapeUtils" %><%@ 
    page import="org.dspace.app.webui.util.UIUtil" %><%

	SortOption so = (SortOption) request.getAttribute("sortedBy");
	Item[] items = (Item[]) request.getAttribute("items");
	Integer pagetotal = (Integer) request.getAttribute("pagetotal");
	int etAl = UIUtil.getIntParameter(request, "etal");

	boolean showThumbs = false;
    	String listFields = "dc.identifier.uri, dc.title, dc.contributor.*, dc.date.issued(date), dc.identifier.citation, dc.type";
    	String dateField = "dc.date.issued";
    	String titleField = "dc.title";
    	String authorField = "dc.contributor.*";

        // Arrays used to hold the information we will require when outputting each row
        String[] fieldArr  = listFields.split("\\s*,\\s*");
        boolean isDate[]   = new boolean[fieldArr.length];
        boolean isAuthor[] = new boolean[fieldArr.length];
        boolean viewFull[] = new boolean[fieldArr.length];

	out.println("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>");
	out.println("<response>");

	StringBuilder sb = new StringBuilder();

        try
        {
            sb.append("\t<itemsCount>" + pagetotal + "</itemsCount>\n\r");
            sb.append("\t<items>\n\r");

	    // now output each item row
            for (int i = 0; i < items.length; i++)
            {
            	sb.append("\t\t<item>\n\r"); 
		org.dspace.content.DCValue[] metadataArray = null;


		// uri
		metadataArray = items[i].getMetadata("dc", "identifier", "uri", Item.ANY);
		sb.append("\t\t\t<uri>");
		if (metadataArray != null && metadataArray.length > 0) {
			String uri = metadataArray[0].value;

			sb.append(StringEscapeUtils.escapeXml(uri));
		}
		sb.append("</uri>\n\r");
		      
           
		// title
		metadataArray = items[i].getMetadata("dc", "title", null, Item.ANY);
		sb.append("\t\t\t<title>");
		if (metadataArray != null && metadataArray.length > 0) {
			String title = metadataArray[0].value;
	
			sb.append(StringEscapeUtils.escapeXml(title));
		}
		sb.append("</title>\n\r");


		// authors
		metadataArray = items[i].getMetadata("dc", "contributor", Item.ANY, Item.ANY);
		if (metadataArray != null && metadataArray.length > 0) {
			int authorsCount = metadataArray.length;

			sb.append("\t\t\t<authorsCount>" + authorsCount + "</authorsCount>\n\r");

			int loopLimit = metadataArray.length;
			if (etAl > 0 && loopLimit > etAl)
				loopLimit = etAl;

			sb.append("\t\t\t<authors>\n\r");
			for (int j = 0; j < loopLimit; j++) {
				sb.append("\t\t\t\t<author>" + StringEscapeUtils.escapeXml(metadataArray[j].value) + "</author>\n\r");
			}
			sb.append("\t\t\t</authors>\n\r");
		}


		// publication date
		metadataArray = items[i].getMetadata("dc", "date", "issued", Item.ANY);
		sb.append("\t\t\t<publicationDate>");
		if (metadataArray != null && metadataArray.length > 0) {
			String date = metadataArray[0].value;

			sb.append(StringEscapeUtils.escapeXml(date));
		}
		sb.append("</publicationDate>\n\r");


		// citation
		metadataArray = items[i].getMetadata("dc", "identifier", "citation", Item.ANY);
		sb.append("\t\t\t<citation>");
		if (metadataArray != null && metadataArray.length > 0) {
			String citation = metadataArray[0].value;

			sb.append(StringEscapeUtils.escapeXml(citation));
		}
		sb.append("</citation>\n\r");


		// document type
		metadataArray = items[i].getMetadata("dc", "type", null, Item.ANY);
		sb.append("\t\t\t<documentType>");
		if (metadataArray != null && metadataArray.length > 0) {
			String docType = metadataArray[0].value;

			sb.append(StringEscapeUtils.escapeXml(docType));
		}
		sb.append("</documentType>\n\r");

		sb.append("\t\t</item>\n\r");
            }
            sb.append("\t</items>\n\r");
	    
	    sb.append("\t<errorMessage>No errors</errorMessage>\n\r");
	    
	    out.println(sb.toString());
        } catch (Exception e) {
	    out.println("\t<errorMessage>");
	    e.printStackTrace(new java.io.PrintWriter(out));
	    out.println("</errorMessage>");
        }

	out.println("</response>");
%>

