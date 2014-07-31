package ua.edu.sumdu.olymp.essuir;

import org.dspace.content.DCValue;
import org.dspace.content.Item;
import org.dspace.content.ItemIterator;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.eperson.EPerson;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.regex.Pattern;

/**
 * Created with IntelliJ IDEA.
 * User: sergeyp
 * Date: 10/25/12
 * Time: 12:14 PM
 */
public class LinkAbstractUpdater {

    private static Hashtable<Integer, Pattern> dictionary;

    private static final int LANG_UKR = 0;
    private static final int LANG_RUS = 1;
    private static final int LANG_ENG = 2;

    private static String[] templates = {
            "При цитуванні документа, використовуйте посилання ",
            "При цитировании документа, используйте ссылку ",
            "When you are citing the document, use the following link "
    };

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.err.println("Need one argument - admin email.");

            return;
        }

        String handleURLStem = ConfigurationManager.getProperty("dspace.url") + "/handle/";

        Context c = new Context();

        EPerson admin = EPerson.findByEmail(c, args[0].toLowerCase());

        if (admin == null) {
            System.err.println("Invalid admin email. No such user!");

            c.abort();
            return;
        }

        c.setCurrentUser(admin);

        initDictionary();
        boolean needComplete = false;

        ItemIterator allItems = Item.findAll(c);
        ArrayList<Item> updatedItems = new ArrayList<Item>(256);
        try {
            while (allItems.hasNext()) {
                Item i = allItems.next();

                if (updateItem(i, handleURLStem)) {
                    needComplete |= true;
                    updatedItems.add(i);

                    if (updatedItems.size() > 254) {
                        System.out.println("Commit changes");
                        c.commit();
                        System.out.println("Decaching changes");

                        for (Item item : updatedItems) {
                            item.decache();
                        }

                        needComplete = false;
                        updatedItems.clear();
                    }
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (allItems != null) {
                allItems.close();
            }
        }

        // complete transaction
        if (needComplete) {
            System.out.println("Commit changes");
            c.complete();
        } else {
            c.abort();
        }
    }

    private static void initDictionary() {
        dictionary = new Hashtable<Integer, Pattern>();

        dictionary.put(LANG_UKR, Pattern.compile("ґ|ї|і|є"));
        dictionary.put(LANG_RUS, Pattern.compile("ё|ъ|ы|э"));
    }

    private static int detectLang(String text) {
        int lang = -1;

        if (dictionary.get(LANG_RUS).matcher(text).find()) {
            lang = LANG_RUS;
        } else if (dictionary.get(LANG_UKR).matcher(text).find()) {
            lang = LANG_UKR;
        } else {
            lang = LANG_ENG;
        }

        System.out.println("Detected lang - " + lang);

        return lang;
    }

    private static boolean updateItem(Item i, String handleURLStem) throws Exception {
        // get abstracts of item
        DCValue[] values = i.getMetadata("dc", "description", "abstract", Item.ANY);
        String url = handleURLStem + i.getHandle();

        String[] newValues = new String[values.length];
        boolean needUpdate = false;

        for (int j = 0; j < values.length; j++) {
            newValues[j] = values[j].value;

            // if need add repository link
            if (!newValues[j].contains(handleURLStem)) {
                int lang = newValues.length == 1 ? detectLang(newValues[j]) : j;

                newValues[j] = newValues[j] + "\n" + templates[lang] + url;
                needUpdate |= true;
            }
        }

        if (needUpdate) {
            i.clearMetadata("dc", "description", "abstract", Item.ANY);

            for (int j = 0; j < values.length; j++) {
                DCValue value = values[j];

                i.addMetadata(value.schema, value.element, value.qualifier, value.language, newValues[j]);
            }

            System.out.println("Update item - " + url);

            // update item
            i.update();
            return true;
        } else {
            i.decache();
            return false;
        }
    }

}
