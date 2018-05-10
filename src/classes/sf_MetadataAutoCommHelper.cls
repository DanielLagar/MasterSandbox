/********************************************************
    Deprecated as part of ICCS R2 2017                  *
    With the introduction of Digital Product Returns MAC*
    is now too out of date to effectively roll back to  *
********************************************************/   

/**
  * @author: Jason Clark
  * @date: 9/10/2014
  *
  * @description: Trigger Helper class for Metadata Auto Communication logic.  Used by CaseTrigger.
  */

global without sharing class sf_MetadataAutoCommHelper {
    /*
    public static final String MAC_TYPE_MEDICAL_QR = 'Medical Questionnaire';
    public static final String MAC_TYPE_RETURN_REMINDER = 'Product Return Reminder';
    public static final String MAC_TYPE_FRAUD_NOTICE = 'Fraud Notice';
    public static final String MAC_TYPE_PRODUCT_RETURN = 'Product Return';
    public static final String MEDICAL_QR_STATUS_ATTEMPT_PREFIX = 'Questionnaire Requested - Attempt ';
    public static final String PRODUCT_RETURN_STATUS_ATTEMPT_PREFIX = 'Product Requested - Attempt ';
    public static final String PRODUCT_AVAILABLE_FOR_RETURN = 'Yes - Product is available';
    public static final String MAC_FULFILLMENT_ORDER_LINE_ITEM_TYPE = 'FL';
    public static final String CONTACT_REPEATER_STATUS_KNOWN = 'Known Repeater';
    public static final String CONTACT_REPEATER_STATUS_SUSPECTED = 'Suspected Repeater';
    public static final String CASE_REPEATER_CASE_PENDING = 'Pending Validation';
    public static final String EMAIL_FROM_NAME = 'System Generated'; // used for EmailMessages sent via MAC rule
    public static Boolean firstRun = true; // used to prevent multiple runs
    
    private static Set <String> emailTemplateNames = new Set <String>();
    private static Set <Id> fraudNoticeChecked = new Set <Id>();
    
    @testVisible
    private static List <Messaging.SendEmailResult> emailResults = new List <Messaging.SendEmailResult> ();
    
    //country-language-brand key for letterHeadMap
    private static string getCLBKey(string c, string l, string b) {
        return c + ':' + l + ':' + b;
    }
    
    private static map<string, string> letterHeadMap {
        get {
            if (letterHeadMap==null) {
                letterHeadMap = new map<string, string>();
                for (Letter_Head__c lh : [select Brand__c, Country__c, Header_ID__c, Language__c from Letter_Head__c]) {
                    letterHeadMap.put(getCLBKey(lh.Country__c, lh.Language__c, lh.Brand__c), lh.Header_ID__c);
                }
            }
            return letterHeadMap;
        }
        set;    }
    

    //Called by Case's After Update trigger.  Determines all Metadata Auto Communications
    //that need to be sent for a group of Case Updates, and sends them
    public static void sendCaseMACs(map<id, Case>oldMap, map<id, Case>casesToProcess) {
        //ChrisM WR377 replacing with Set<Id>
        //system.debug('firstRun ' + firstRun);
        //if (firstRun){ 
        //   firstRun = false;
        Map<Id, Case> newMap = casesToProcess.clone();
        for(case newCase : newMap.values()){
            if(checkRecursive.ACRprocessedIds.contains(newCase.Id)){
                newMap.remove(newCase.Id);
            }
        }
        if(!newMap.isEmpty()){
            
            //determine what cases need which types of MACs.  Can be expanded for additional types
            Set <id> medicalQRCaseIds = new Set <id>();
            Set <id> returnReminderCaseIds = new Set <id>();
            Set <id> fraudNoticeCaseIds = new Set <id>();
            Set <id> contactIds = new Set <id>();
            
            for(Case newCase : newMap.values()) {
                //add to set of processed ids - recursion prevention
                checkRecursive.ACRprocessedIds.add(newCase.Id);//WR377
                
                System.debug('*** newCase = ' + newCase);
                if(newCase.contactId!=null) {
                    contactIds.add(newCase.ContactId);
                }
                Case oldCase = oldMap.get(newCase.id);
                System.debug('*** old mqr = ' + oldCase.Medical_QR_Status__c);
                if (newCase.Medical_QR_Status__c != oldCase.Medical_QR_Status__c ) {
                    medicalQRCaseIds.add(newCase.id);
                }
                System.debug('@@@ old prr = ' + oldCase.Product_Return_Status__c);
                System.debug('@@@ new prr = ' + newCase.Product_Return_Status__c);
                if (newCase.Product_Return_Status__c != oldCase.Product_Return_Status__c ) {
                    returnReminderCaseIds.add(newCase.id);
                    
                }
                System.debug('*** old fra = ' + oldCase.Repeater_Case__c);
                if (newCase.Repeater_Case__c != oldCase.Repeater_Case__c && !fraudNoticeChecked.contains(newCase.id)) {
                    fraudNoticeChecked.add(newCase.id);
                    fraudNoticeCaseIds.add(newCase.id);
                }
            }
            
            System.debug('*** MQR = ' + medicalQRCaseIds);
            System.debug('*** PRR = ' + returnReminderCaseIds);
            System.debug('*** FRA = ' + fraudNoticeCaseIds);
            
            //get all contacts for all case types 
            Map <Id, Contact> contactMap = new Map <Id, Contact>([SELECT Id, Email, FirstName, LastName, Salutation, Repeater_Status__c FROM Contact WHERE Id IN :contactIds]);
    
            //get MAC(s) for each mac type needed, mapped to matching cases
            //NOTE: helper methods should add any email template names used to emailTemplateNames.
            list<OutboundMAC> macsToSend = new list<OutboundMAC>();
            
            if(medicalQRCaseIds.size() > 0)
                macsToSend.addAll(getMedicalQRMACS(medicalQRCaseIds, newMap, contactMap));
                
            if(returnReminderCaseIds.size() > 0)
                macsToSend.addAll(getReturnReminderMACS(returnReminderCaseIds, newMap, contactMap));
           
            if (fraudNoticeCaseIds.size() > 0)
                macsToSend.addAll(getFraudNoticeMACS(fraudNoticeCaseIds, newMap, contactMap));
            
            // Get Case Comment Codes that match the criteria for Product Return MACs   
            Map <Id, Case_Comment_Code__c> cccMap = new Map <Id, Case_Comment_Code__c>([SELECT c.Status__c, c.GCR_CID__c, c.Case_Contact_Id__c, c.Case__c, 
                c.Case_Product__r.Product_available_for_return__c, c.Case_Product__c, c.Global_Product_Segment__c, c.Product_Postal_Restriction__c, Global_Comment_Path__c, Global_Product_Path__c, Product_Brand__c 
                FROM Case_Comment_Code__c c WHERE c.Case__c IN :newMap.keySet() 
                    AND c.Contact_Has_Address__c = TRUE 
                    AND c.Case_Product__r.Product_available_for_return__c = :PRODUCT_AVAILABLE_FOR_RETURN 
                    AND c.Case_Product__r.Status__c = null]);
    
            system.debug('@@@cccMap: ' + cccMap);
            system.debug('@@@cccMapSize: ' + cccMap.size());
    
            if (cccMap.size() > 0){
                system.debug('@@@Inside ccMap.size if statement!');
                //06/12/15 
                //remove segments and pass product paths
                Set <String> productPaths = new Set <String>();
                for(Case_Comment_Code__c code : cccMap.values()) {
                    system.debug('inside for loop');
                    system.debug('@@@code ' + code);
                    system.debug('@@@code.Global_Product_Path__c ' + code.Global_Product_Path__c);
                    productPaths.add(code.Global_Product_Path__c);
                    system.debug('@@@ProductPaths '+ ProductPaths);
                }
                
                macsToSend.addAll(getProductReturnMACs(cccMap, contactMap, newMap, productPaths));
            }
            
            system.debug('@@@macsToSend: ' + macsToSend);
            
            sendMacs(macsToSend, newMap);
        }//if newMap emtpy close
            
        //}//First if close
    }//method close
    
    private static void sendMacs (List <OutboundMAC> macsToSend, Map <Id, Case> caseMap) {
        //determine email or fulfillment order as appropriate
        Map <String, EmailTemplate> emailTemplateMap = new Map <String, EmailTemplate>();
        for(EmailTemplate et : [SELECT Id, DeveloperName, Subject, Body FROM EmailTemplate WHERE DeveloperName IN :emailTemplateNames]) {
            emailTemplateMap.put(et.developerName, et);
        } 
        
        system.debug('@@@emailTemplateMap: ' + emailTemplateMap);

        List <OutboundMAC> macsToEmail = new List <OutboundMAC>();
        List <OutboundMAC> macsToFulfill = new List <OutboundMAC>();
        
        for(OutboundMAC mac : macsToSend) {
            if(!string.isBlank(mac.emailTemplateName) && emailTemplateMap.containsKey(mac.emailTemplateName) && mac.canEmail) {
                mac.emailTemplateId = emailTemplateMap.get(mac.emailTemplateName).Id;
                mac.emailSubject = emailTemplateMap.get(mac.emailTemplateName).subject;
                mac.emailBody = emailTemplateMap.get(mac.emailTemplateName).body;
                macsToEmail.add(mac);
            }
            else {
                macsToFulfill.add(mac);
            }
        }
        
        system.debug('@@@macsToEmail: ' + macsToEmail);
        system.debug('@@@macsToFulfill: ' + macsToFulfill);
        
        //try to send emails
        if(macsToEmail.size()>0) {
            
            List <Messaging.SingleEmailMessage> emails = getMACEmails(macsToEmail);
            List <EmailMessage> ems = new List <EmailMessage>();
            emailResults = Messaging.sendEmail(emails, false); // allOrNothing = false
            //must iterate results by index; results are parallel to emails (and to OutboundMACs)
            for(integer i = 0; i<emailResults.size(); i++) {
                Messaging.SendEmailResult result = emailResults[i];
                if(!result.isSuccess()) {
                    OutboundMAC mac = macsToEmail[i];
                    system.debug(logginglevel.INFO, 'Could not send email, will create fulfillment order: ' + mac);
                    macsToFulfill.add(mac); //send fulfillment order instead
                } else {
                    EmailMessage em = new EmailMessage();  
                    em.ParentId = macsToEmail[i].caseId; 
                    em.FromName = EMAIL_FROM_NAME;
                    em.MessageDate = System.now(); 
                    em.ToAddress = macsToEmail[i].email;
                    em.Subject = macsToEmail[i].emailSubject;
                    em.HtmlBody = macsToEmail[i].emailBody;
                    ems.add(em);
                }
            }
            
            system.debug('@@@ems: ' + ems);
            
            if(ems.size() > 0)
                insert ems; 
        }
        
        //create fulfillment orders
        if(macsToFulfill.size()>0) {
            createFulfillmentOrders(macsToFulfill, caseMap);
        }
    }
    
    private static String getMACKey(String country, String language, String status) {
        return country + ':' + language + ':' + status; 
    }

    private static String getMACKey(String country, String language, String global_product_segment, String gcr_cid) {
        return country + ':' + language + ':' + global_product_segment + ':' + gcr_cid; 
    }


    //DEPRECATED 10/10
    //Called by Case Comment Code's After Insert trigger.  Determines all Metadata Auto Communications
    //that need to be sent for a group of Case Comment Codes, and sends them
    public static void sendCaseCommentMACs(map<id, Case_Comment_Code__c>newMap) {
        set<id> contactIds = new set<id>();
        set<id> caseIds = new set<id>();
        set<string> segments = new set<string>();
        for(Case_Comment_Code__c code : newMap.values()) {
            contactIds.add(code.Case_Contact_Id__c);
            caseIds.add(code.Case__c);
            segments.add(code.Global_Product_Segment__c);
        }
        //get all contacts
        map<id, Contact> contactMap = new map<id, Contact>([select id, email, firstname, lastname, salutation, Repeater_Status__c from Contact where id in :contactIds]);
        //get all cases
        map<id, Case> caseMap = new map<id, Case>([select id, contactId, country__c, language__c,  brand__c, origin, CaseNumber, segment__c from Case where id in :caseIds]);
        //get MAC(s) for each mac type needed, mapped to matching cases
        //NOTE: helper methods should add any email template names used to emailTemplateNames.
        list<OutboundMAC> macsToSend = new list<OutboundMAC>();
        macsToSend.addAll(getProductReturnMACs(newMap, contactMap, caseMap, segments));     
        
        sendMacs(macsToSend, caseMap);
    }
    
    @testVisible
    private static List <OutboundMAC> getMedicalQRMACS(Set <Id> caseIds, Map <Id, Case> caseMap, Map <Id, Contact> contactMap) {
        
        List <OutboundMAC> results = new List <OutboundMAC>();
        Map <String, Metadata_Auto_Communication__c> macRecordMap = new Map <String, Metadata_Auto_Communication__c>();
        List <Metadata_Auto_Communication__c> macRecords = [
           SELECT Attempt__c, Fulfillment_Item__c, Email_Template_Name__c, Item_Country__c, Item_Language__c,
                  Fulfillment_Item__r.SKU__c, Fulfillment_Item__r.Fulfillment_Item_ID__c,
                  Fulfillment_Item__r.Conga_Template__c, Fulfillment_Item__r.Conga_Template__r.RTL_Language__c,
                  Fulfillment_Item__r.Conga_Template__r.HTML_Content__c, Fulfillment_Item__r.Type__c, Fulfillment_Item__r.Description__c, Type__c, Generate_PDF__c
             FROM Metadata_Auto_Communication__c 
            WHERE Type__c = :MAC_TYPE_MEDICAL_QR
              AND Attempt__c != null 
              AND Attempt__c != ''];

        for (Metadata_Auto_Communication__c macRecord : macRecords) {
            emailTemplateNames.add( macRecord.Email_Template_Name__c );
            for(String attempt : macRecord.Attempt__c.split(';', 0)) {
                String mqrStatus = MEDICAL_QR_STATUS_ATTEMPT_PREFIX + attempt.trim();
                macRecordMap.put(getMACKey(macRecord.Item_Country__c,macRecord.Item_Language__c,mqrStatus), macRecord);
            }
        }

        System.debug('*** macRecordMap = ' + macRecordMap);
        
        for(id caseId : caseIds) {
            Case c = caseMap.get(caseId); 
            Contact ct;
            if (c.contactId!=null && contactMap.containsKey(c.contactId)) {
                ct = contactMap.get(c.contactId);
            }
            String macKey = getMacKey(c.country__c, c.Language__c, c.Medical_QR_Status__c);
            System.debug('*** KEY = ' + macKey);
            if(macRecordMap.containsKey(macKey)) {
                Metadata_Auto_Communication__c macRecord = macRecordMap.get(macKey);
                results.add(new OutboundMAC(c, macRecord, ct));
            }
        }
        
        return results;
    }
    
    @testVisible
    private static List <OutboundMAC> getFraudNoticeMACS(Set <Id> caseIds, Map <Id, Case> caseMap, Map <Id, Contact> contactMap) {
        List <OutboundMAC> results = new List <OutboundMAC>();
        Map <String, Metadata_Auto_Communication__c> macRecordMap = new Map <String, Metadata_Auto_Communication__c>();
        List <Metadata_Auto_Communication__c> macRecords = [
           SELECT Fulfillment_Item__c, Email_Template_Name__c, Item_Country__c, Item_Language__c,
                  Fulfillment_Item__r.SKU__c, Fulfillment_Item__r.Fulfillment_Item_ID__c,
                  Fulfillment_Item__r.Conga_Template__c, Fulfillment_Item__r.Conga_Template__r.RTL_Language__c,
                  Fulfillment_Item__r.Conga_Template__r.HTML_Content__c, Fulfillment_Item__r.Type__c, Fulfillment_Item__r.Description__c, Type__c, Generate_PDF__c
             FROM Metadata_Auto_Communication__c 
            WHERE Type__c = :MAC_TYPE_FRAUD_NOTICE];


        String status = ''; //not needed for fraud letters
        for (Metadata_Auto_Communication__c macRecord : macRecords) {
            emailTemplateNames.add( macRecord.Email_Template_Name__c );
            macRecordMap.put(getMACKey(macRecord.Item_Country__c,macRecord.Item_Language__c,status), macRecord);
        }

        for(Id caseId : caseIds) {
            Case c = caseMap.get(caseId); 
            // post go live update to look at fraud case since there is no more pending. 
            if (c.Repeater_Case__c == sf_RepeaterHelper.CASE_FRAUD_CASE && c.contactId!=null && contactMap.containsKey(c.contactId) 
                    && (contactMap.get(c.contactId).Repeater_Status__c == CONTACT_REPEATER_STATUS_KNOWN
                        || contactMap.get(c.contactId).Repeater_Status__c == CONTACT_REPEATER_STATUS_SUSPECTED)) { 
                Contact ct = contactMap.get(c.contactId);
                String macKey = getMacKey(c.country__c, c.Language__c, status);
                if(macRecordMap.containsKey(macKey)) {
                    System.debug('*** MATCH FOUND');
                    Metadata_Auto_Communication__c macRecord = macRecordMap.get(macKey);
                    results.add(new OutboundMAC(c, macRecord, ct));
                }
            }
        }
        return results;
        
    }
    
    @testVisible
    private static List <OutboundMAC> getReturnReminderMACS(Set <Id> caseIds, Map <Id, Case> caseMap, Map <Id, Contact> contactMap) {
        List <OutboundMAC> results = new List <OutboundMAC>();
        Map <String, Metadata_Auto_Communication__c> macRecordMap = new Map <String, Metadata_Auto_Communication__c>();
        
        system.debug('@@@MAC_TYPE_RETURN_REMINDER: ' + MAC_TYPE_RETURN_REMINDER);
        
        
        List <Metadata_Auto_Communication__c> macRecords = [
           SELECT Attempt__c, Fulfillment_Item__c, Email_Template_Name__c, Item_Country__c, Item_Language__c,
                  Fulfillment_Item__r.SKU__c, Fulfillment_Item__r.Fulfillment_Item_ID__c,
                  Fulfillment_Item__r.Conga_Template__c, Fulfillment_Item__r.Conga_Template__r.RTL_Language__c,
                  Fulfillment_Item__r.Conga_Template__r.HTML_Content__c, Fulfillment_Item__r.Type__c, Fulfillment_Item__r.Description__c, Type__c, Generate_PDF__c
             FROM Metadata_Auto_Communication__c 
            WHERE Type__c = :MAC_TYPE_RETURN_REMINDER
              AND Attempt__c != null AND Attempt__c != ''];
              
        system.debug('@@@macRecords: ' + macRecords);

        for (Metadata_Auto_Communication__c macRecord : macRecords) {
            emailTemplateNames.add( macRecord.Email_Template_Name__c );
            for(String attempt : macRecord.Attempt__c.split(';', 0)) {
                String prStatus = PRODUCT_RETURN_STATUS_ATTEMPT_PREFIX + attempt.trim();
                
                system.debug('@@@macRecord.Item_Country__c: ' + macRecord.Item_Country__c);
                system.debug('@@@macRecord.Item_Language__c: ' + macRecord.Item_Language__c);
                system.debug('@@@prStatus: ' + prStatus);
                
                macRecordMap.put(getMACKey(macRecord.Item_Country__c,macRecord.Item_Language__c,prStatus), macRecord);
            }
        }

        for(Id caseId : caseIds) {
            Case c = caseMap.get(caseId); 
            Contact ct;
            
            if (c.contactId!=null && contactMap.containsKey(c.contactId)) {
                ct = contactMap.get(c.contactId);
            }
            String macKey = getMacKey(c.country__c, c.Language__c, c.Product_Return_Status__c);
            system.debug('@@@macKey: ' + macKey);
            
            if(macRecordMap.containsKey(macKey)) {
                Metadata_Auto_Communication__c macRecord = macRecordMap.get(macKey);
                results.add(new OutboundMAC(c, macRecord, ct));
            }
        }
        
        system.debug('@@@results: ' + results);

        return results;
    }
    
    private static string getCaseFIKey(id caseId, id fulfillmentItemId) {
        return caseId + ':' + fulfillmentItemId; 
    }
    


    //06/12/15
    //update to work with paths, brands and segments
    @testVisible
    private static List <OutboundMAC> getProductReturnMACs (Map <Id, Case_Comment_Code__c> newMap, Map <Id, Contact> contactMap, Map <Id, Case> caseMap, Set <String> productPaths) {
        String QUERY_TYPE_PATH = 'Product Path';
        String QUERY_TYPE_SEGMENT = 'Segment';


        List <OutboundMAC> results = new List <OutboundMAC>();
        Set <Case_Product__c> cpRecords = new Set <Case_Product__c>();
        Map <String, Metadata_Auto_Communication__c> macRecordMap = new Map <String, Metadata_Auto_Communication__c>();
        
        // check for existing FOs
        Set <String> existingCaseFulfillmentItems = new Set <String>(); // only checking existence; a compound key (caseid:fulfillmentItemId) is easier than a map<caseid, set<fiId>>
        for(Fulfillment_Order_Line_Item__c foli : [SELECT Case__c
                                                        ,Fulfillment_Item__c 
                                                    FROM Fulfillment_Order_Line_Item__c 
                                                    WHERE Case__c IN :caseMap.keyset() 
                                                    AND Fulfillment_Order__r.status__c != 'Closed']) {
            
            existingCaseFulfillmentItems.add(getCaseFIKey(foli.case__c, foli.fulfillment_item__c));
        }
        
        // get matching MACs
        //6/15/15 salesforce
        //create dynamic query for getting product return macs due to new requirements
        // As an Admin, I need to be able to set up MAC rules for products sharing the same fulfilment item 
        // (i.e. Multiple segments or product paths).
        // I also need to be able to set up MAC rules for levels of products higher and lower than the Segment. 
        // An example would be that I would like to use the current Blades and Razors bundle 
        // for a non-critical PQC (today we only set critical and a few non-critical) 
        // at the Venus & Olay/Female Premium Blade & Razor/Sugarberry/3ct level only.  

        //split productPaths set into substrings to get segments
        Set <String> segmentSet = new Set <String> ();

        for (String path: productPaths) {
            List <String> pathElements = path.split('/');
            if (pathElements != null && pathElements.size()>1) { 
               segmentSet.add(pathElements[1]);
            }
        }


        //get two sets of records = one with paths another with brand/segment

        String returnMacQuery = 'SELECT Segment__c, Comment_Code_List__c, Fulfillment_Item__c, Email_Template_Name__c, Item_Country__c, Item_Language__c,';
        
        returnMacQuery += 'Fulfillment_Item__r.SKU__c, Fulfillment_Item__r.Fulfillment_Item_ID__c,';
        returnMacQuery += 'Fulfillment_Item__r.Conga_Template__c, Fulfillment_Item__r.Conga_Template__r.RTL_Language__c,';
        returnMacQuery += 'Fulfillment_Item__r.Conga_Template__r.HTML_Content__c, Fulfillment_Item__r.Type__c, Fulfillment_Item__r.Description__c, Type__c, Generate_PDF__c, Query_Type__c, Global_Product_Path__c ';

        returnMacQuery += ' FROM Metadata_Auto_Communication__c ';
        returnMacQuery += ' WHERE Type__c = :MAC_TYPE_PRODUCT_RETURN ';

        String pathQuery = '';
        pathQuery += returnMacQuery;
        pathQuery += ' AND Query_Type__c = \'' + QUERY_TYPE_PATH + '\' AND (';


        List <String> paths = new List <String> ();
        paths.addAll(productPaths);
        Set <String> pathsKeys = new Set <String> ();

        for (Integer i=0; i<paths.size(); i++) {
            String path = paths[i];
            List <String> xPaths = path.split ('/'); 
            String progressivePath = '';
            for (Integer l=0; l<xPaths.size(); l++) {

                progressivePath = l==0 ? xPaths[l] : progressivePath + '/' + xPaths[l];
                pathQuery += ' Global_Product_Path__c = \'' + String.escapeSingleQuotes(progressivePath) + '\' OR';
                pathsKeys.add(progressivePath);
            }
            
        }

        pathQuery = pathQuery.removeEnd('OR');
        pathQuery += ') AND Global_Product_Path__c != null'; //close or statements
        

        String segmentQuery = '';
        segmentQuery += returnMacQuery;
        segmentQuery += ' AND Query_Type__c = \'' + QUERY_TYPE_SEGMENT + '\'';

        if (!segmentSet.isEmpty())
        segmentQuery += ' AND (';
        
        for (String segment: segmentSet) {
            segmentQuery += ' Segment__c LIKE \'%' + String.escapeSingleQuotes(segment) + '%\' ';
            if (segmentSet.size()>1)
                segmentQuery += ' OR ';
        }

        segmentQuery = segmentQuery.removeEnd ('OR ');


        if (!segmentSet.isEmpty())
        segmentQuery += ' ) AND Segment__c != null ';
        
        System.debug('pathQuery ' + pathQuery);
        System.debug('segmentQuery ' + segmentQuery);

        List <Metadata_Auto_Communication__c> macRecordsWithPath = new List <Metadata_Auto_Communication__c> ();
        List <Metadata_Auto_Communication__c> macRecordsWithSegment = new List <Metadata_Auto_Communication__c> ();

        macRecordsWithPath = (List <Metadata_Auto_Communication__c>) Database.query(pathQuery);
        macRecordsWithSegment = (List <Metadata_Auto_Communication__c>) Database.query(segmentQuery);
        

        for (Metadata_Auto_Communication__c macRecord : macRecordsWithPath) {
            emailTemplateNames.add( macRecord.Email_Template_Name__c );
            for(String commentCode : macRecord.Comment_Code_List__c.split(',', 0)) {
                for (String path: pathsKeys) {
                    macRecordMap.put(getMACKey(macRecord.Item_Country__c,macRecord.Item_Language__c, path, commentCode), macRecord);
                }
                
            }
        }

        System.debug(' pathsKeys \n ' + pathsKeys + '\n');

        for (Metadata_Auto_Communication__c macRecord : macRecordsWithSegment) {
            emailTemplateNames.add( macRecord.Email_Template_Name__c );
            for(String commentCode : macRecord.Comment_Code_List__c.split(',', 0)) {
                for (String segment: macRecord.Segment__c.split('/')) {
                    macRecordMap.put(getMACKey(macRecord.Item_Country__c,macRecord.Item_Language__c, segment, commentCode), macRecord);
                }
            }
        }

        System.debug('macRecordMap \n' + macRecordMap.keyset() + '\n');
        
        //loop through comment codes
        for(Case_Comment_Code__c code : newMap.values()) {
            if (code.Product_Postal_Restriction__c) {
                continue;
            }
            
            Case c = caseMap.get(code.case__c);
            contact ct;
            if (c.contactId!=null && contactMap.containsKey(c.contactId)) {
                ct = contactMap.get(c.contactId);
            }
            String macKeyWithPath = getMacKey(c.country__c, c.Language__c, code.Global_Product_Path__c, code.GCR_CID__c);
            String macKeyWithSegment = getMacKey(c.country__c, c.Language__c, code.Global_Product_Segment__c, code.GCR_CID__c);
            
            System.debug('macKeyWithPath \n' + macKeyWithPath + '\n');
            System.debug('macKeyWithSegment \n' + macKeyWithSegment + '\n');


            if(macRecordMap.containsKey(macKeyWithPath) || macRecordMap.containsKey(macKeyWithSegment) ) {
                Metadata_Auto_Communication__c macRecord = macRecordMap.get(macKeyWithPath);
                if (macRecord == null) macRecord = macRecordMap.get(macKeyWithSegment);

                System.debug('==== matched macRecord===' + macRecord);

                String caseFIKey = getCaseFIKey(c.id, macRecord.Fulfillment_Item__c);
                if(!existingCaseFulfillmentItems.contains(caseFIKey)) {
                    OutboundMAC newMac = new OutboundMAC(c, macRecord, ct);
                    newMac.caseCommentCode = code.id;
                    newMac.canEmail = false; //product return bundles is always a fulfillment order
                    results.add(newMac);
                    existingCaseFulfillmentItems.add(caseFIKey); 
                }
                Case_Product__c cp = new Case_Product__c();
                cp.Id = code.Case_Product__c;
                cp.Status__c = PRODUCT_RETURN_STATUS_ATTEMPT_PREFIX + '1';
                if (!cpRecords.contains(cp))
                    cpRecords.add(cp);
            }
        }
              
        if (cpRecords.size() > 0){
            List <Case_Product__c> cpRecordsList = new List <Case_Product__c> (cpRecords);
            update cpRecordsList;           
        }
        return results;
    }
    
    private static List <Messaging.Singleemailmessage> getMACEmails(list<OutboundMAC> macs) {
        List <Messaging.Singleemailmessage> emails = new List <Messaging.Singleemailmessage>();
        for(OutboundMAC mac : macs) {
            Messaging.Singleemailmessage msg = new Messaging.Singleemailmessage();
            msg.setTemplateId(mac.emailTemplateId);
            msg.setTargetObjectId(mac.contactId);
            msg.setWhatId(mac.caseId);
            msg.setSaveAsActivity(false); //if TRUE, each email generates a task which fires the task trigger, INDIVIDUALLY; too many SOQL queries.
            emails.add(msg);
        }
        
        return emails;
    }
    
    @testVisible
    private static void createFulfillmentOrders(List <OutboundMAC> macs, Map <Id, Case> caseMap) {
        List <Fulfillment_Order__c> orders = new List <Fulfillment_Order__c>();
        List <Fulfillment_Order_Line_Item__c> lineitems = new List <Fulfillment_Order_Line_Item__c>();
        
        system.debug('@@@macnum ' + macs.size());
        system.debug('@@@macs: ' + macs);
        
        for(OutboundMAC mac : macs) {
            Case c = caseMap.get(mac.caseid);
            String header;
            
            if(letterHeadMap.containsKey(getCLBKey(c.country__c, c.language__c, c.brand__c))) {
                header = letterHeadMap.get(getCLBKey(c.country__c, c.language__c, c.brand__c));
            }
            
            Fulfillment_Order__c fo = new Fulfillment_Order__c();
            fo.Case__c = mac.caseId;
            fo.Conga_Merge_Template_Id__c = mac.congaTemplateId;
            system.debug('@@@mac.congaTemplateID ' + mac.congaTemplateId);
            fo.RTL_Language__c = mac.RTLLanguage;
            fo.ff_header__c = header;
            fo.contact__c = c.contactid;
            fo.trans_country__c = mac.contactCountry;
            fo.case_comment_code__c = mac.caseCommentCode;
            fo.Auto_Created__c = true;
            fo.letter_body__c = getLetterBody(mac, c);
            system.debug('@@@mac.generatePDF: ' + mac.generatePDF);
            if (mac.generatePDF)
                fo.Conga_Workflow_Trigger__c = true;
            orders.add(fo);
        }
        
        system.debug('@@@orders: ' + orders);
        
        insert orders;

        //loop by index; orders and macs are parallel
        for(integer i=0; i<macs.size(); i++) {
            OutboundMAC mac = macs[i];
            
            lineitems.add(new Fulfillment_Order_Line_Item__c(
                Fulfillment_Order__c = orders[i].id,
                Case__c = mac.caseId,
                Fulfillment_Item__c = mac.fulfillmentItemId,
                Quantity__c = 1,
                Type__c = mac.fulfillmentItemType, //added to fix Type__c issue by Ian Barker 1/8/2016
                Description__c = mac.fulFillmentItemDescription, //added to fix Type__c issue by Ian Barker 1/8/2016
                Fulfillment_SKU__c = mac.sku,
                Fulfillment_Item_ID__c = mac.itemFulId
            ));
        }
        
        system.debug('@@@lineitems: ' + lineitems);
        
        insert lineitems;        
    }
    
    private static String SafeString (String original) {
        return original==null ? '' : original;
    }
    
    private static string getLetterBody(OutboundMAC mac, Case c) {
        if(mac == null || c==null || mac.letterBody == null) {
            return '';
        }
        return mac.letterBody
                   .replace('{Case.Country}', safeString(c.Country__c))
                   .replace('{Case.ContactMethod}', safeString(c.origin))
                   .replace('{Case.Id}', safeString(c.CaseNumber))
                   .replace('{Case.Language}', safeString(c.Language__c))
                   .replace('{Account.FirstName}', safeString(mac.firstname))
                   .replace('{Account.LastName}', safeString(mac.lastname))
                   .replace('{Account.Salutation}', safeString(mac.salutation))
                   .replace('{Case.Brand}', safeString(c.brand__c))
                   .replace('{Case.Segment}', safeString(c.segment__c))
                   ;
    }
    
    

    //Internal class that represents a sepecifc outbound communication

    @testVisible
    global class OutboundMAC implements Comparable {
        public Id caseId;
        public Id contactId;
        public String contactCountry;
        public Id fulfillmentItemId;
        public String sku;
        public String itemFulId;
        public String emailTemplateName;
        public Id emailTemplateId;
        public String emailSubject;
        public String emailBody;
        public Id congaTemplateId;
        public Boolean RTLLanguage;
        public String letterBody;
        public String firstname;
        public String lastname;
        public String salutation;
        public String email;
        public Id caseCommentCode;
        public Boolean canEmail = false;
        public Boolean generatePDF = true; // default to generate PDF
        public String fulfillmentItemType; //added to fix Type__c issue by Ian Barker 1/8/2016
        public String fulfillmentItemDescription; //added to fix Type__c issue by Ian Barker 1/8/2016
        
        public OutboundMAC(Case c, Metadata_Auto_Communication__c macRecord, Contact ct) {
            this.caseId = c.id;
            this.contactId = c.contactId;
            this.contactCountry = c.country__c;
            this.fulfillmentItemId = macRecord.fulfillment_item__c;
            this.sku = macRecord.fulfillment_item__r.sku__c;
            this.itemFulId = macRecord.fulfillment_item__r.fulfillment_item_id__c;
            this.emailTemplateName = macRecord.email_template_name__c;
            this.congaTemplateId = macRecord.fulfillment_item__r.conga_template__c;
            this.RTLLanguage = macRecord.fulfillment_item__r.conga_template__r.rtl_language__c;
            this.letterBody = macRecord.fulfillment_item__r.conga_template__r.HTML_Content__c;
            this.fulfillmentItemType = macRecord.fulFillment_item__r.Type__c; //added to fix Type__c issue by Ian Barker 1/8/2016
            this.fulfillmentItemDescription = macRecord.fulFillment_item__r.Description__c; //added to fix Type__c issue by Ian Barker 1/8/2016
            if(ct!=null) {
                this.firstname = ct.firstname;
                this.lastname = ct.lastname;
                this.salutation = ct.salutation;
                this.email = ct.email;
                if(!string.isBlank(ct.email)) {
                    this.canEmail = true;
                }
            }
            //needs to handle setting to true as well
            if(macRecord.Generate_PDF__c == false){ 
                this.generatePDF = false;
            }else if(macRecord.Generate_PDF__c == true){
                this.generatePDF = true;
            }
        }
        
        // make unit testing easier
        global Integer compareTo(object otherObj) {
            OutboundMAC other = (OutboundMAC)otherObj;
            if(this.caseId < other.caseId) return -1;
            if(this.caseId > other.caseId) return 1;
            return 0;
        }   
    }
    */
}