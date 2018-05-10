public class sf_ContactUsHelperCtrl {

    public static final String DEFAULT_COUNTRY = 'United States of America';
    public static final String DEFAULT_BRAND = 'P&G'; //talk to Doug M. about this if it causes issues.
    public static final String DEFAULT_LANGUAGE = 'English-US';
    public static final String DEFAULT_EMAIL_FROM_NAME = 'P&G Care Line';
    public static final String DEFAULT_EMAIL_FROM_ADDRESS = 'noreply.im@pg.com';
    public static final Integer SOSL_PRODUCT_LIMIT = 15;


    public static String getLanguage() {
        String language = ApexPages.currentPage().getParameters().get('language');
        if (String.isEmpty(language)) language = DEFAULT_LANGUAGE;
        
        return String.escapeSingleQuotes(language);
    }
    
    public static String getCountry() {
        String country = ApexPages.currentPage().getParameters().get('country');
        if (String.isEmpty(country)) country = DEFAULT_COUNTRY;
        
        return String.escapeSingleQuotes(country);
    }    
    
    public static String getBrand() {
        String brand = ApexPages.currentPage().getParameters().get('brand');
        if (String.isEmpty(brand)) brand = DEFAULT_BRAND;
        return String.escapeSingleQuotes(brand);
    }


    //this can be used to get all fields in Contact_Us_Language__c or similar objects with a lot of fields.
    public static String createSelectAllQueryString (String sObjectApiName, String whereClause, String limitClause) {
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(sObjectApiName);
        return createSelectAllQueryString(sObjType, sObjectApiName, whereClause, limitClause, new list<string>());
    }

    //this version handles subqueries.  final param is a map of relationship names to where clauses
    //  e.g. {'Contact_Us_Brands_Languages__r' => 'Contact_Us_Brand__r.name = :brand'}; use null or blank if no where clause needed
    public static String createSelectAllQueryString (String sObjectApiName, String whereClause, String limitClause, map<string, string> subqueryWhereClauses) {
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(sObjectApiName);
        
        // get child relationships
        map<string, Schema.ChildRelationship> children = new map<string, Schema.ChildRelationship>();
        for (Schema.ChildRelationship child : sObjType.getDescribe().getChildRelationships() ) {
            children.put(child.getRelationshipName(), child);
        }
        
        //generate subqueries
        list<string> subqueries = new list<string>();
        for(string subqueryRelationship : subqueryWhereClauses.keyset()) {
            if(children.containsKey(subqueryRelationship)) {
                Schema.ChildRelationship child = children.get(subqueryRelationship);
                subqueries.add(createSelectAllQueryString(child.getChildSObject(), subqueryRelationship, subqueryWhereClauses.get(subqueryRelationship), null, new list<string>()));
            }
            else {
                system.debug('Could not find child relationship ' + subqueryRelationship + ' for sObject ' + sObjectApiName);
            }
        }
        return createSelectAllQueryString(sObjType, sObjectApiName, whereClause, limitClause, subqueries);
    }

    //internal version used by both public versions
    private static String createSelectAllQueryString (Schema.SObjectType sobjType, string fromAlias, string whereClause, string limitClause, list<string> subqueries) {
        system.debug('%%%% createSelectAllQueryString: ' + sobjType.getDescribe().getName() + ', ' + fromAlias + ', ' + whereClause + ', ' + subqueries );
        
        Map<String, Schema.SObjectField> fldObjMap = sobjType.getDescribe().fields.getMap();
 
        String queryString = 'SELECT ';
        for(Schema.SObjectField s : fldObjMap.values()) {
           String fieldName = s.getDescribe().getName();
           // Continue building your dynamic query string
           queryString += fieldName + ',';
        }
 
        for(string subquery : subqueries) {
            queryString += '(' + subquery + '),';
        }

        // Trim last comma
        queryString = queryString.removeEnd(',');
 
        // Finalize query string
        queryString += ' FROM ' + fromAlias;
       
        if (!String.isEmpty(whereClause)) {
            queryString += ' WHERE ';
            queryString += whereClause;
        }

        if (!String.isEmpty(limitClause)) {
            queryString += ' LIMIT ' + limitClause;
        }

        return queryString;
    }

    private static User sysAdmin;

    public static User getSysAdmin () {
        if (sysAdmin == null) {
            List <User> admins = new List <User> ([SELECT Id FROM User WHERE Profile.Name = 'Integration User' AND isActive = true LIMIT 1]);
            if (admins.isEmpty()) admins = [SELECT Id FROM User WHERE Profile.PermissionsAuthorApex = true AND isActive = true AND Profile.UserType='Standard' LIMIT 1];

            sysAdmin = admins[0];
        }
        
        return sysAdmin;
    }

}