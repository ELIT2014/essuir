<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.storage.rdbms.DatabaseManager" %>
<%@ page import="org.dspace.storage.rdbms.TableRowIterator" %>
<%@ page import="org.dspace.storage.rdbms.TableRow" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
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

<dspace:layout locbar="nolink" title="Statistics 2011" feedData="NONE">

<%

	class StatCounter {
	
		public StatCounter(int counters) {
			this.cnt = new int[counters];
		}
	
		public void setCount(int cnt, int value) {
			this.cnt[cnt] = value;
		}
		
		public int getCount(int cnt) {
			return this.cnt[cnt];
		}
	
		public void incCount(int cnt) {
			this.cnt[cnt]++;
		}
		
		public boolean isCountZeros() {
			int s = 0;
			
			for (int i = 0; i < cnt.length; i++) {
				if (cnt[i] != 0)
					s++;
			}
			
			return s == 0;
		}

		public String toString() {
			String c = cnt[0] + "";
			
			for (int i = 1; i < cnt.length; i++)
				c += ", " + cnt[i];

			return c;
		}
		
		
		private int[] cnt;
	}

	class StatValue {
		public static final int AUTHOR = 3;
		public static final int SUBMITED = 11;
		public static final int ISSUE = 15;
		public static final int LANG = 38;
	
		public StatValue(String value, int type) {
			this.value = value;
			this.type = type;
		}
		
		public String getValue() {
			return value;
		}
		
		public int getType() {
			return type;
		}

		public String toString() {
			return value + "(" + type + ")";
		}
		
		private String value;
		private int type;
	}


	class StatItem {
	
		public StatItem(int submitterID) {
			this.submitterID = submitterID;
		}
		
		public void addValue(StatValue v) {
			values.add(v);
		}
		
		public ArrayList<StatValue> getValues() {
			return values;
		}

		public int getSubmitterID() {
			return submitterID;
		}
		
		public String toString() {
			return "{" + submitterID + " - " + values + "}";
		}
		
		private ArrayList<StatValue> values = new ArrayList<StatValue>();
		private int submitterID;
	}

	
	class StatPerson extends StatCounter {
		
		public StatPerson(String lastname, String firstname, int facultyID, int chairID, int counters) {
			super(counters);
			
			this.lastname = lastname;
			this.firstname = firstname;
			this.facultyID = facultyID;
			this.chairID = chairID;
		}

		public String getLastname() {
			return lastname;
		}

		public String getFirstName () {
			return firstname;
		}
		
		public int getFacultyID() {
			return facultyID;
		}

		public int getChairID() {
			return chairID;
		}
		
		public String toString() {
			return "{" + lastname + ", " + firstname + " - " 
					+ facultyID + " - " + super.toString() + "}";
		}
		
		
		private String lastname;
		private String firstname;
		private int facultyID;
		private int chairID;
	}


	class StatChair extends StatCounter {
		
		public StatChair(String name, int counters) {
			super(counters);
			
			this.name = name;
		}
		
		public String getName() {
			return name;
		}
		
		public void addPerson(StatPerson p) {
			persons.add(p);
		}
		
		public ArrayList<StatPerson> getPersons() {
			return persons;
		}
		
		private String name = "";
		private ArrayList<StatPerson> persons = new ArrayList<StatPerson>();
	}
	

	class StatFaculty extends StatCounter {
		
		public StatFaculty(String name, int counters) {
			super(counters);

			this.name = name;
		}
		
		public void addChair(Integer id, StatChair c) {
			chairs.put(id, c);
		}
		
		public Hashtable<Integer, StatChair> getChairs() {
			return chairs;
		}
		
		public String getName() {
			return name;
		}
		
		
		private String name = "";
		private Hashtable<Integer, StatChair> chairs = new Hashtable<Integer, StatChair>();
	}

	
	class StatUtils {
	
		public StatUtils(Connection c) {
			this.c = c;
		}
	
		public StatFaculty getFaculty(int id) throws SQLException {
			return getFaculties().get(id);
		}

		public StatPerson getPerson(int id) throws SQLException {
			return getPersons().get(id);
		}

		public StatItem getItem(int id) throws SQLException {
			return getItems().get(id);
		}
		
		Hashtable<Integer, StatItem> getItems() throws SQLException {
			if (items != null)
				return items;
			
			items = new Hashtable<Integer, StatItem>();
			
	        Statement s = c.createStatement();

	        
	        ResultSet res = s.executeQuery("SELECT item.item_id, submitter_id, text_value, metadata_field_id " +
	        							   "    FROM item " +
	        							   "    LEFT JOIN ( " +
	        							   "    	SELECT item_id, text_value, metadata_field_id " +
	        							   "    			FROM metadatavalue " +
	        							   "    			WHERE metadata_field_id IN (3, 11, 15, 38) " +
	        							   "    		ORDER BY item_id, metadata_field_id, text_value) AS b " +
	                                       "    	ON b.item_id = item.item_id " +
	                                       "    WHERE in_archive;");
	
	        while (res.next()) {
				StatValue v = new StatValue(res.getString("text_value"), res.getInt("metadata_field_id"));
				
				StatItem i = getItem(res.getInt("item_id"));
				if (i == null) {
					i = new StatItem(res.getInt("submitter_id"));
					items.put(res.getInt("item_id"), i);
				}
	        	
				i.addValue(v);
	        }
	
	        s.close();
			
			return items;
		}
		
		Hashtable<Integer, StatPerson> getPersons() throws SQLException {
			if (persons != null)
				return persons;
			
			persons = new Hashtable<Integer, StatPerson>();
			
	        Statement s = c.createStatement();
	
	        ResultSet res = s.executeQuery("SELECT eperson_id, eperson.chair_id, lastname, firstname, faculty_id FROM eperson " +
	        							   "    LEFT JOIN chair " +
	        							   "    ON eperson.chair_id = chair.chair_id " +
	                                       "    ORDER BY faculty_id, lastname, firstname; ");

	        Hashtable<Integer, StatFaculty> table = getFaculties();
	        
	        while (res.next()) {
				StatFaculty sf = table.get(res.getInt("faculty_id"));
				StatPerson sp = null;
				if (sf == null) {
	        		sf = table.get(-1);

	        		sp = new StatPerson(res.getString("lastname"), res.getString("firstname"), -1, -1, 4);
	        	} else {
	        		sp = new StatPerson(res.getString("lastname"), 
	        				res.getString("firstname"), res.getInt("faculty_id"), res.getInt("chair_id"), 4);
	        	}	            
				
				StatChair sc = sf.getChairs().get(res.getInt("chair_id"));
				if (sc == null)
					sc = sf.getChairs().get(-1);
				sc.addPerson(sp);
				
	        	persons.put(res.getInt("eperson_id"), sp);
	        }
	
	        s.close();
			
			return persons;
		}
		
		Hashtable<Integer, StatFaculty> getFaculties() throws SQLException {
			if (table != null)
				return table;
			
			table = new Hashtable<Integer, StatFaculty>();
			
	        Statement s = c.createStatement();
	
	        ResultSet res = s.executeQuery("SELECT faculty_id, faculty_name " +
	                                           "    FROM faculty; ");
	
	        while (res.next()) {
	            table.put(res.getInt("faculty_id"), new StatFaculty(res.getString("faculty_name"), 4));
	        }
	
	        s.close();
            table.put(-1, new StatFaculty("Unknown faculty", 4));

	        s = c.createStatement();
	    	
	        res = s.executeQuery("SELECT chair_id, faculty_id, chair_name " +
	                                           "    FROM chair; ");
	
	        while (res.next()) {
	            table.get(res.getInt("faculty_id")).
	            		addChair(res.getInt("chair_id"), new StatChair(res.getString("chair_name"), 4));
	        }
	
	        s.close();
            table.get(-1).addChair(-1, new StatChair("Unknown chair", 4));
	        
	        
			return table;
		}

		private Hashtable<Integer, StatFaculty> table = null;
		private Hashtable<Integer, StatPerson> persons = null;
		private Hashtable<Integer, StatItem> items = null;
		private Connection c = null;
	}

	class ItemFilter {

		public boolean filterAuthor(StatItem item, StatPerson p) {
			ArrayList<StatValue> v = item.getValues();
			
			for (StatValue s : v) {
				if (s.getType() == StatValue.AUTHOR) {
					String val = s.getValue();
					
					if (val.contains(p.getFirstName()) && val.contains(p.getLastname()))
						return true;
				}
			}
			
			return false;
		}
		
		
		public boolean filterYear(StatItem item) {
			ArrayList<StatValue> v = item.getValues();
			
			for (StatValue s : v) {
				if (s.getType() == StatValue.SUBMITED) {
					if (s.getValue().startsWith("2011")) return true;
				}
			}
			
			return false;
		}
		
		public boolean filterLang(StatItem item) {
			ArrayList<StatValue> v = item.getValues();
			
			for (StatValue s : v) {
				if (s.getType() == StatValue.LANG) {
					if (s.getValue().startsWith("en")) return true;
				}
			}
			
			return false;
		}
		
		public boolean filterIssue(StatItem item) {
			ArrayList<StatValue> v = item.getValues();
			
			for (StatValue s : v) {
				if (s.getType() == StatValue.ISSUE) {
					if (s.getValue().startsWith("2011")) return true;
				}
			}
			
			return false;
		}
	}

	

    try {
        Connection c = null;
        try {
            Class.forName(ConfigurationManager.getProperty("db.driver"));
        
            c = DriverManager.getConnection(ConfigurationManager.getProperty("db.url"),
                                            ConfigurationManager.getProperty("db.username"),
                                            ConfigurationManager.getProperty("db.password"));
            StatUtils u = new StatUtils(c);
            ItemFilter f = new ItemFilter();
            
            for (StatItem i : u.getItems().values()) {
            	StatPerson p = u.getPerson(i.getSubmitterID());
            	StatFaculty sf = u.getFaculty(p.getFacultyID());
            	StatChair sc = sf.getChairs().get(p.getChairID());
            	
            	if (f.filterYear(i) && f.filterAuthor(i, p)) {
            		p.incCount(0);
            		sf.incCount(0);
            		sc.incCount(0);
            		
            		if (f.filterLang(i)) {
            			p.incCount(1);
                		sf.incCount(1);
                		sc.incCount(1);
                		
            			if (f.filterIssue(i)) {
                			p.incCount(2);
                    		sf.incCount(2);
                    		sc.incCount(2);
            			}                			
            		}
            	}
            	
            	if (f.filterYear(i) && f.filterLang(i)) {
            		p.incCount(3);
            		sf.incCount(3);
            		sc.incCount(3);
            	}
            }
            
%>            
  
<table align="center" width="95%" border="1">
    <tr>
        <th class="evenRowEvenCol"></th>
        <th class="evenRowEvenCol">Личных добавлено в 2011-ом</th>
        <th class="evenRowEvenCol">В том числе на английском</th>
        <th class="evenRowEvenCol">В том числе на английском опубликованых в 2011-ом</th>
        <th class="evenRowEvenCol">Всего добавлено в 2011-ом на английском</th>
    </tr>

<%

			for (StatFaculty sf : u.getFaculties().values()) {
	            %><tr>
	                <td class="evenRowEvenCol"><b><%= sf.getName() %></b></td>
	                <td class="evenRowEvenCol" align="center"><b><%= sf.getCount(0) %></b></td>
	                <td class="evenRowEvenCol" align="center"><b><%= sf.getCount(1) %></b></td>
	                <td class="evenRowEvenCol" align="center"><b><%= sf.getCount(2) %></b></td>
	                <td class="evenRowEvenCol" align="center"><b><%= sf.getCount(3) %></b></td>
	            </tr><%
				
				for (StatChair sc : sf.getChairs().values()) {
		            %><tr>
	            	    <td class="evenRowOddCol"><%= sc.getName() %></td>
	        	        <td class="evenRowOddCol" align="center"><%= sc.getCount(0) %></td>
	    	            <td class="evenRowOddCol" align="center"><%= sc.getCount(1) %></td>
		                <td class="evenRowOddCol" align="center"><%= sc.getCount(2) %></td>
		                <td class="evenRowOddCol" align="center"><%= sc.getCount(3) %></td>
		            </tr><%
					
					for (StatPerson p : sc.getPersons()) {
						if (!p.isCountZeros()) {
				            %><tr>
			                	<td class="oddRowOddCol"><i><%= p.getLastname() + " " + p.getFirstName() %></i></td>
			                	<td class="oddRowOddCol" align="center"><i><%= p.getCount(0) %></i></td>
			                	<td class="oddRowOddCol" align="center"><i><%= p.getCount(1) %></i></td>
			                	<td class="oddRowOddCol" align="center"><i><%= p.getCount(2) %></i></td>
			                	<td class="oddRowOddCol" align="center"><i><%= p.getCount(3) %></i></td>
			            	</tr><%
						}
					}
				}
			}

//			for (StatPerson p : u.getPersons().values()) {
//			}
//            out.println(u.getPersons());
        } finally {
            if (c != null) 
                c.close();
        }
    } catch (Exception e) {
    	e.printStackTrace();
/*            try {
                java.io.FileWriter writer = new java.io.FileWriter("D:/projcoder.txt", true);
                writer.write("Autocomplete exception at " + (new java.util.Date()) + " - Locale: [" + locale + "] - Request: ["+ q +"]\n");
		writer.write("\t" + e + "\n");	
		writer.close();
            } catch (Exception exc) {}
*/
    }
%>
</table>
</dspace:layout>


<%
  } else {
    org.dspace.app.webui.util.JSPManager.showAuthorizeError(request, response, null);
  }
%>
