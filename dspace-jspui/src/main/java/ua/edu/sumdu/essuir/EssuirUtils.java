package ua.edu.sumdu.essuir;


import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Hashtable;

import org.apache.log4j.Logger;
import org.dspace.core.ConfigurationManager;


public class EssuirUtils {
	private static Logger logger = Logger.getLogger(EssuirUtils.class);
	
	
	public static Hashtable<String, Long> getTypesCount() {
		Hashtable<String, Long> types = new Hashtable<String, Long>();
		
		try {
	        Connection c = null;
	        try {
	            Class.forName(ConfigurationManager.getProperty("db.driver"));
        
        	    c = DriverManager.getConnection(ConfigurationManager.getProperty("db.url"),
                	                            ConfigurationManager.getProperty("db.username"),
                        	                    ConfigurationManager.getProperty("db.password"));

	            Statement s = c.createStatement();

        	    ResultSet resSet = s.executeQuery(
		        	    "SELECT text_value, COUNT(*) AS cnts FROM metadatavalue" +
			        	"	WHERE metadata_field_id = 66 " +
			        	"		AND item_id IN (SELECT item_id FROM item WHERE in_archive) " +
			        	"	GROUP BY text_value; ");

	            while (resSet.next()) {
		            types.put(resSet.getString("text_value"), resSet.getLong("cnts"));
        	    }
	
        	    s.close();
	        } finally {
	            if (c != null) 
	                c.close();
	        }
		} catch (Exception e) {
			logger.error(e);
		}
		
		return types;
	}

}
