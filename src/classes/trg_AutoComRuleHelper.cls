/*
 * Rework of sf_MetadataAutoCommHelper
 * @author: christopher.macduff@accenture.com
 * @date: 20th Jan 2016
 *
 * If you see MAC...I mean ACR...
 *
 * @description: Trigger Helper class for Metadata Auto Communication logic.  Used by CaseTrigger.
 */

public class trg_AutoComRuleHelper {
    public static final String PRODUCT_AVAILABLE_FOR_RETURN = 'Yes - Product is available';
    public static final String PRODUCT_RETURN_STATUS_ATTEMPT_PREFIX = 'Product Requested - Attempt ';
    public static final String EMAIL_FROM_NAME = 'System Generated'; // used for EmailMessages sent via ACR rule
    public static final String ACR_FULFILLMENT_ORDER_LINE_ITEM_TYPE = 'FL';
    public static final String ACR_TYPE_PRODUCT_RETURN = 'Product Return';
    public static final String ACR_PRODUCT_RETURN_PHYSICAL = 'Physical';//CR16
    public static final String ACR_PRODUCT_RETURN_DIGITAL = 'Digital';//CR16
    public static final String ACR_TYPE_MEDICAL_QR = 'Medical Questionnaire';
    public static final String ACR_TYPE_FRAUD_NOTICE = 'Fraud Notice';
    public static final String CONTACT_REPEATER_STATUS_KNOWN = 'Known Repeater';
    public static final String CONTACT_REPEATER_STATUS_SUSPECTED = 'Suspected Repeater';
    //Used so that only attempts 1,2,3 fire ACR. Add new values as required
    public static final Set<String> physicalProductReturnStatuses = new Set<String>{'Product Requested - Attempt 1','Product Requested - Attempt 2','Product Requested - Attempt 3'};
	public static final Set<String> digitalProductReturnStatuses = new Set<String>{'Photo - Attempt 1','Photo - Attempt 2','Photo - Attempt 3','Photo - Final Attempt'};//TODO: Does null need to be a valid status as well?
    public static final Set<String> medicalStatuses = new Set<String>{'Questionnaire Requested - Attempt 1','Questionnaire Requested - Attempt 2','Questionnaire Requested - Attempt 3'};
    
    //Might not need these, could resuse set above
    public static final String PRODUCT_RETURN_STATUS_ATTEMPT_1 = 'Product Requested - Attempt 1';
    public static final String PRODUCT_RETURN_STATUS_ATTEMPT_2 = 'Product Requested - Attempt 2';
    public static final String PRODUCT_RETURN_STATUS_ATTEMPT_3 = 'Product Requested - Attempt 3';
    
    private static Set <String> emailTemplateNames = new Set <String>();
    private static Set <Id> fraudNoticeChecked = new Set <Id>();
 
    public static void getACRs(map<id, Case>oldMap, map<id, Case>casesToProcess){
        system.debug(logginglevel.WARN,'!!! ACR in getACRs');
        //Have to clone trigger.newMap as cannot alter collection
		Map<Id, Case> newMap = casesToProcess.clone();
        Map<Id, Case> digiReturnCaseMap = new Map<Id, Case>();
        
        //Don't use a static boolean: https://help.salesforce.com/apex/HTViewHelpDoc?id=workflow_time_action_considerations.htm&language=en
        for(case newCase : newMap.values()){
            if(checkRecursive.ACRprocessedIds.contains(newCase.Id)){
                newMap.remove(newCase.Id);
            }
        }
        
        if(!newMap.isEmpty()){
      
            //Sets to pass to repective type matching method
            Set <id> medicalQRCaseIds = new Set <id>();
            Set <id> returnReminderCaseIds = new Set <id>();
            Set <id> fraudNoticeCaseIds = new Set <id>();
            
            Set <id> contactIds = new Set <id>();
            
            //List to pass to "do" method
            List<OutboundACR> acrsToSend = new List<OutboundACR>();
            
            //Determine Type
            for(Case newCase : newMap.values()){
                checkRecursive.ACRprocessedIds.add(newCase.Id);

                Case oldCase = oldMap.get(newCase.id);
                
                if(newCase.contactId!=null) {
                    contactIds.add(newCase.ContactId);
                }  
                if (newCase.Medical_QR_Status__c != oldCase.Medical_QR_Status__c && medicalStatuses.contains(newCase.Medical_QR_Status__c)) {
                    medicalQRCaseIds.add(newCase.id);
                }
                if (newCase.Product_Return_Status__c != oldCase.Product_Return_Status__c && physicalProductReturnStatuses.contains(newCase.Product_Return_Status__c)) {
                    //Should find same rule as product return but then use matching FF item look up for attempt no.
                    system.debug(logginglevel.WARN,'!!! ACR Adding to returnReminderCaseIds');
                    returnReminderCaseIds.add(newCase.id);
                }
                //TODO Add digital here //digiReturnsFollowup
				if (!String.IsBlank(oldCase.Product_Return_Status__c) && newCase.Product_Return_Status__c != oldCase.Product_Return_Status__c && digitalProductReturnStatuses.contains(newCase.Product_Return_Status__c)) {
                    //Should find same rule as product return but then use matching FF item look up for attempt no.
                    //digiReturnsHelper.digiReturnsFollowup(oldMap, newMap)
                    digiReturnCaseMap.put(newCase.Id, newCase);
                }
                if (newCase.Repeater_Case__c != oldCase.Repeater_Case__c && !fraudNoticeChecked.contains(newCase.id)) {
                    fraudNoticeChecked.add(newCase.id);
                    fraudNoticeCaseIds.add(newCase.id);    
                }
            }
            //START CR16 - Send for digital followup
            if(!digiReturnCaseMap.isEmpty()){
                system.debug(logginglevel.WARN,'!!! ACR Calling digiReturnsHelper.digiReturnsFollowup');
                digiReturnsHelper.digiReturnFirstAttempt(digiReturnCaseMap);
            }
            //FIN CR16 - Send for digital followup

            //get all contacts for all case types 
            Map <Id, Contact> contactMap = new Map <Id, Contact>([SELECT Id, Email, FirstName, LastName, Salutation, Repeater_Status__c FROM Contact WHERE Id IN :contactIds]);
 
			/************************************************************************************
			 * CR16 - updated query to only include CPs with return type = physical as these	*
			 * should be actioned as soon as they can be - allows the advisor to amend the		*
			 * FO order to include additional items before submitting Case						*
			 * Digital returns will only be actions on Case submission							*
			************************************************************************************/
      
            //NOTE: Historical "in flow" ACR cases - these won't have ACR_Return_Type__c or Case_Product__r.ACR_Info__c populated
            system.debug(logginglevel.WARN,'>>> About to build tempCCCMap. newMap.keySet(): '+newMap.keySet());
            system.debug(logginglevel.WARN,'>>> About to build tempCCCMap. returnReminderCaseIds: '+returnReminderCaseIds);

			Map <Id, Case_Comment_Code__c> tempCCCMap = new Map <Id, Case_Comment_Code__c>([
                SELECT c.Status__c, c.GCR_CID__c, c.Case_Contact_Id__c, c.Case__c, c.Case_Product__r.ACR_Return_Type__c, c.Case__r.Selected_Return_Type__c,
                c.Case_Product__r.Product_available_for_return__c, c.Case_Product__c, c.Global_Product_Segment__c,
                c.Product_Postal_Restriction__c, Global_Comment_Path__c, Global_Product_Path__c, Product_Brand__c,
                Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c, c.Case_Product__r.ACR_Info__c, c.ACR_Info__c,
                c.name
                FROM Case_Comment_Code__c c
                WHERE (
                    c.Case__c IN :newMap.keySet() 
                    AND c.Contact_Has_Address__c = TRUE 
                    AND c.Case_Product__r.Product_available_for_return__c = :PRODUCT_AVAILABLE_FOR_RETURN 
                    AND c.Case_Product__r.Status__c = null
					AND(c.Case_Product__r.ACR_Return_Type__c = 'Physical' OR c.Case_Product__r.ACR_Return_Type__c = null OR c.Case__r.Selected_Return_Type__c = 'Physical')//Digital will always have return type set
                	)
                    OR c.Case__c IN :returnReminderCaseIds
            ]);

            system.debug(logginglevel.WARN,'>>> Built tempCCCMap: '+tempCCCMap);
            
            Map<Id, Case_Comment_Code__c> cccMap = new Map<Id, Case_Comment_Code__c>();//Original no ACR_Info__c, supporting historical Cases
            Map<Id, Case_Comment_Code__c> newCCCMap = new Map<Id, Case_Comment_Code__c>();//New includes ACR_Info__c
            
            for(Case_Comment_Code__c ccc : tempCCCMap.values()){
                system.debug(logginglevel.WARN,'>>> in tempCCCMap loop: '+ccc.name+' || '+ccc.Case_Product__r.ACR_Return_Type__c + ' || '+ccc.Case__r.Selected_Return_Type__c + ' || '+ccc.ACR_Info__c);
                if(String.isBlank(ccc.Case_Product__r.ACR_Info__c)){
                    cccMap.put(ccc.Id, ccc);
                }
                
                //else if(ccc.ACR_Info__c != getProductReturnACR.NO_MATCH){//wrong field!
                else if(ccc.Case_Product__r.ACR_Info__c != getProductReturnACR.NO_MATCH){
                    newCCCMap.put(ccc.Id, ccc);
                }
            }
            
            //Split into those with ACR Info
            system.debug(logginglevel.WARN,'>>> cccMap size: '+cccMap.size());
    
            //Create search key for each Case
            //TODO: store search key on CCC record?
            Set<String> caseSearchKeys = new Set<String>(); //Stores Case search Keys
            //loop through comment codes looking for product returns
            for(Case_Comment_Code__c ccc : cccMap.values()){
                Case c = newMap.get(ccc.case__c);
                contact ct = contactMap.get(c.contactId);
                String caseSearchPathKey = c.Country__c+':'+c.Language__c+':'+ccc.Global_Product_Path__c+':'+ccc.Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c;
                String caseSearchSegmentKey = c.Country__c+':'+c.Language__c+':'+ccc.Global_Product_Segment__c+':'+ccc.Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c;
                system.debug(logginglevel.WARN,'>>> caseSearchPathKey: '+caseSearchPathKey);
                system.debug(logginglevel.WARN,'>>> caseSearchSegmentKey: '+caseSearchSegmentKey);
                caseSearchKeys.add(caseSearchPathKey);
                caseSearchKeys.add(caseSearchSegmentKey);
            }
            
            //Call product return matching method
            if (cccMap.size() > 0){
                acrsToSend.addAll(getProductReturnACRS(cccMap, contactMap, newMap, caseSearchKeys));
            }
            
            //New CR16 method - we already know the ACR!
            if(newCCCMap.size() > 0){
                //Map<Id, Case_Comment_Code__c> cccMap, Map<Id, Case> caseMap, Map<Id, Contact> contactMap
                try{
                    acrsToSend.addAll(getProductReturnACRS(newCCCMap, newMap, contactMap));
                }
                catch(exception e){
                    System.enqueueJob(new exceptionHelperQueable(e,'***ACR newCCCMap/getProductReturnACRS newCCCMap: '+newCCCMap+ ' **newMap: '+newMap+ ' **contactMap: '+contactMap));
                }
            }
            
            //Need empty checks to prevent dereference errors if lists are empty
            if(!medicalQRCaseIds.isEmpty()){
                acrsToSend.addAll(getMedicalStatusACRS(medicalQRCaseIds, newMap, contactMap)); //Find matching medical status ACRs
            }
            if(!fraudNoticeCaseIds.isEmpty()){
                acrsToSend.addAll(getFraudNoticeACRS(fraudNoticeCaseIds, newMap, contactMap)); //Find matching fraud notice ARCs
            }
    
            //Now do something with results...
            sendACRs(acrsToSend, newMap);
        }
    }
    
    //Replaced OutboundACR with OutboundACR
    public static void sendACRs (List <OutboundACR> acrsToSend, Map <Id, Case> caseMap) {
        system.debug('>>> in sendACRs method count: '+acrsToSend.size());
        
        //determine email or fulfillment order as appropriate
        Map <String, EmailTemplate> emailTemplateMap = new Map <String, EmailTemplate>();
        for(EmailTemplate et : [SELECT Id, DeveloperName, Subject, Body FROM EmailTemplate WHERE DeveloperName IN :emailTemplateNames]) {
            emailTemplateMap.put(et.developerName, et);
        } 

        List <OutboundACR> acrsToEmail = new List <OutboundACR>();
        List <OutboundACR> acrsToFulfill = new List <OutboundACR>();
        
        for(OutboundACR arc : acrsToSend) {
            
            if(!string.isBlank(arc.emailTemplateName) && emailTemplateMap.containsKey(arc.emailTemplateName) && arc.canEmail) {
                system.debug('>>> in sendACRs method: attempting to send email');
                arc.emailTemplateId = emailTemplateMap.get(arc.emailTemplateName).Id;
                arc.emailSubject = emailTemplateMap.get(arc.emailTemplateName).subject;
                arc.emailBody = emailTemplateMap.get(arc.emailTemplateName).body;
                acrsToEmail.add(arc);
            }
            else {
                system.debug('>>> in sendACRs method: sending to fulfil');
                system.debug('>>> arc details: '+arc.ACRName);
                acrsToFulfill.add(arc);
            }

        }
        //try to send emails
        if(acrsToEmail.size()>0) {
            
            List <Messaging.SingleEmailMessage> emails = getACREmails(acrsToEmail);
            List <EmailMessage> ems = new List <EmailMessage>();
            emailResults = Messaging.sendEmail(emails, false); // allOrNothing = false
            //must iterate results by index; results are parallel to emails (and to OutboundACRs)
            for(integer i = 0; i<emailResults.size(); i++) {

                Messaging.SendEmailResult result = emailResults[i];
                

                if(!result.isSuccess()) {
                    OutboundACR arc = acrsToEmail[i];
                    system.debug(logginglevel.INFO, 'Could not send email, will create fulfillment order: ' + arc.ACRName);
                    //TODO:Not bulkified...could limit in time based workflow context
                    System.enqueueJob(new exceptionHelperQueable('ACR Error on send email. Case:  '+String.valueOf(acrsToEmail[i].caseId)+' errors: '+String.valueOf(result.getErrors())));
                
                    acrsToFulfill.add(arc); //send fulfillment order instead
                } else {
 
                    EmailMessage em = new EmailMessage();  
                    em.ParentId = acrsToEmail[i].caseId; 
                    em.FromName = EMAIL_FROM_NAME;
                    em.FromAddress = 'consumercare.im@pg.com';//ChrisM Aug 2016 Added
                    em.MessageDate = System.now(); 
                    em.ToAddress = acrsToEmail[i].email;
                    em.Subject = acrsToEmail[i].emailSubject;
                    em.HtmlBody = acrsToEmail[i].emailBody;
                    ems.add(em);
                }
            }
    
            if(ems.size() > 0)
                insert ems; 
        }

        //create fulfillment orders
        if(acrsToFulfill.size()>0) {
            createFulfillmentOrders(acrsToFulfill, caseMap);
        }
    }//Method fin
    
    /********************************
    * createFulfillmentOrders       *
    * Creates FF/FI records         *
    ********************************/
    
    private static void createFulfillmentOrders(List <OutboundACR> acrs, Map <Id, Case> caseMap) {
        system.debug('>>> in createFulfillmentOrders method');
        Set<Fulfillment_Order__c> ordersSet = new Set<Fulfillment_Order__c>();
        List <Fulfillment_Order__c> orders = new List <Fulfillment_Order__c>();
        List <Fulfillment_Order_Line_Item__c> lineitems = new List <Fulfillment_Order_Line_Item__c>();
		List <OutboundACR> acrsWithFOs = new List<OutboundACR>();//WR456 ACRs with an FO populated - valid to create
        
        system.debug(logginglevel.WARN,'!!!!!!! createFulfillmentOrders acrs: '+acrs);
        
        for(OutboundACR acr : acrs) {
            Case c = caseMap.get(acr.caseid);
            String header;
            
            system.debug('>>> acr.caseid '+acr.caseid);
            system.debug('>>> case details: '+c);
            
            if(letterHeadMap.containsKey(getCLBKey(c.country__c, c.language__c, c.brand__c))) {
                header = letterHeadMap.get(getCLBKey(c.country__c, c.language__c, c.brand__c));
            }
            
            /****************************************
            * Handle Multiple Fufillment Items here *
            *****************************************/
            Fulfillment_Item__c ffItem = new Fulfillment_Item__c();
            
            //Vars
            Id congaTemplateId;
            Boolean RTLLanguage = false;
            Boolean genPDF = false;
            system.debug('>>> Case Attempt no: '+c.Product_Return_Status__c);
            system.debug('>>> ACR Attempt no: '+acr.attempt);
            system.debug('>>> ACR Name: '+acr.acrNAME);
            system.debug('>>> ACR generate PDF for attempt: '+acr.generatePDFAttempt);//new multiselect picklist
            Set<String> pdfAttempts = new Set<String>();
            if(String.isNotEmpty(acr.generatePDFAttempt)){
                pdfAttempts.addAll(acr.generatePDFAttempt.split(';'));
            }

            //Where's Case or Switch :(
            //https://success.salesforce.com/ideaview?id=08730000000BrSIAA0
            if(acr.attempt == '1' || acr.attempt == null){ //Or null
                congaTemplateId = acr.congaTemplateId;
                RTLLanguage = acr.RTLLanguage;
                acr.letterBody = acr.letterBody;
            }
            else if(acr.attempt == '2'){
                congaTemplateId = acr.FI2_congaTemplateId;
                RTLLanguage = acr.FI2_RTLLanguage;  
                acr.letterBody = acr.FI2_letterBody;
            }
            else if(acr.attempt == '3'){
                congaTemplateId = acr.FI3_congaTemplateId;
                RTLLanguage = acr.FI3_RTLLanguage;
                acr.letterBody = acr.FI3_letterBody;
            }
            //TODO: Confirm this works here and does not need to be in the attempt ifs above
            if(pdfAttempts.contains(acr.attempt)){
                system.debug('>>> PDF Attempt matched');
                genPDF = true;
            }
            
            Fulfillment_Order__c fo = new Fulfillment_Order__c();
            fo.Case__c = acr.caseId;
            fo.Conga_Merge_Template_Id__c = congaTemplateId;
            fo.RTL_Language__c = RTLLanguage;
            fo.ff_header__c = header;
            fo.contact__c = c.contactid;
            fo.trans_country__c = acr.contactCountry;
            fo.case_comment_code__c = acr.caseCommentCode;
            fo.Auto_Created__c = true;
            fo.letter_body__c = getLetterBody(acr, c);
            fo.ACR_Info__c = acr.ACRName;

            if(genPdf){
                fo.Conga_Workflow_Trigger__c = true;
            } 
            //WR456 - Don't create FO if no conga template Id.
            //1st Attempt should always be processed regardless of null congaTemplateId or not
            //2nd or 3rd attempt should only be processed with a congatemplateId
            system.debug(logginglevel.WARN, '&&& acr.attempt: '+acr.attempt+' congaTemplateId: '+congaTemplateId);
            Set<String> attemptVals = new Set<String>{'2','3'};
            if(!attemptVals.contains(acr.attempt) || (String.isNotBlank(congaTemplateId) && attemptVals.contains(acr.attempt)) ){
				orders.add(fo);
                acrsWithFOs.add(acr);//only pass ACR with FOs for further processing
            }
            
        }//for loop close
        insert orders;

		//loop by index; orders and acrs are parallel
        for(integer i=0; i<acrsWithFOs.size(); i++) {
            OutboundACR acr = acrsWithFOs[i];
            
            //Vars
            Id fulfillmentItemId;
            String sku = '';
            String itemFulId = '';
            String itemType = '';
            
            if(acr.attempt == '1' || acr.attempt == '0'){
                fulfillmentItemId = acr.fulfillmentItemId;
                sku = acr.sku;
                itemFulId = acr.itemFulId;
                itemType = acr.fulfillmentItemType;
            }
            else if(acr.attempt == '2'){
                fulfillmentItemId = acr.FI2_fulfillmentItemId;
                sku = acr.FI2_sku;
                itemFulId = acr.FI2_itemFulId; 
                itemType = acr.FI2_fulfillmentItemType;
            }
            else if(acr.attempt == '3'){
                fulfillmentItemId = acr.FI3_fulfillmentItemId;
                sku = acr.FI3_sku;
                itemFulId = acr.FI3_itemFulId;
                itemType = acr.FI3_fulfillmentItemType;
            }
            
            lineitems.add(new Fulfillment_Order_Line_Item__c(
                Fulfillment_Order__c = orders[i].id,
                Case__c = acr.caseId,
                Fulfillment_Item__c = fulfillmentItemId,
                Quantity__c = 1,
                Type__c = itemType,
                Fulfillment_SKU__c = sku,
                Fulfillment_Item_ID__c = itemFulId
            ));
        }
        insert lineitems;        
    }
    
    
    /********************************
    * getMedicalStatusACRS          *
    * look for Medical status ACR   *
    ********************************/
    private static list <OutboundACR> getMedicalStatusACRS(Set <Id> caseIds, Map <Id, Case> caseMap, Map <Id, Contact> contactMap){
        system.debug('>>> looking for a medical status match. In getMedicalStatusACRS');
        List<OutboundACR> results = new List<OutboundACR>();
        
        Set<String> caseSearchKeys = new Set<String>(); //Stores Case search Keys
        
        for(id caseId : caseIds) {
            Case c = caseMap.get(caseId);
            system.debug('>>> medical search key: '+c.Country__c+':'+c.Language__c+':'+ACR_TYPE_MEDICAL_QR);
            caseSearchKeys.add(c.Country__c+':'+c.Language__c+':'+ACR_TYPE_MEDICAL_QR);
        }

        List<Auto_Communication_Rule__c> acrRecords = new List<Auto_Communication_Rule__c>([
            SELECT Id, Name, General_Search_Key__c, Generate_PDF_for_Attempt__c, Template_Unique_Name__c, 
                X1st_Attempt_Fulfillment_Item__c, X1st_Attempt_Fulfillment_Item__r.sku__c, X1st_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X1st_Attempt_Fulfillment_Item__r.conga_template__c, X1st_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X1st_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X1st_Attempt_Fulfillment_Item__r.Type__c, X1st_Attempt_Fulfillment_Item__r.Description__c,
                X2nd_Attempt_Fulfillment_Item__c, X2nd_Attempt_Fulfillment_Item__r.sku__c, X2nd_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X2nd_Attempt_Fulfillment_Item__r.Type__c, X2nd_Attempt_Fulfillment_Item__r.Description__c,
                X3rd_Attempt_Fulfillment_Item__c, X3rd_Attempt_Fulfillment_Item__r.sku__c, X3rd_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X3rd_Attempt_Fulfillment_Item__r.Type__c, X3rd_Attempt_Fulfillment_Item__r.Description__c,
				Digital_Attempt_1st_Template__c, Digital_Attempt_2nd_Template__c, Digital_Attempt_3rd_Template__c
            FROM Auto_Communication_Rule__c
            WHERE General_Search_Key__c IN :caseSearchKeys]);
        
        Map<String, Auto_Communication_Rule__c> acrMap = new Map<String, Auto_Communication_Rule__c>();

        for(Auto_Communication_Rule__c acrRecord : acrRecords){
            emailTemplateNames.add(acrRecord.Template_Unique_Name__c);
            acrMap.put(acrRecord.General_Search_Key__c, acrRecord);
        }

        for(id caseId : caseIds) {
            Case c = caseMap.get(caseId); 
            Contact ct;
            if (c.contactId!=null && contactMap.containsKey(c.contactId)) {
                ct = contactMap.get(c.contactId);
            }
            String caseSearchKey = (c.Country__c+':'+c.Language__c+':'+ACR_TYPE_MEDICAL_QR);
            if(acrMap.containsKey(caseSearchKey)){
                Auto_Communication_Rule__c arc = acrMap.get(caseSearchKey);
                String attemptNo = c.Medical_QR_Status__c.right(1);
                
                system.debug('!!!!!! acr: '+arc);
                system.debug('!!!!!! attemptNo: '+attemptNo);
                
                OutboundACR newACR = new OutboundACR(c, arc, ct, attemptNo, null); //c = case, ct = contact
                if(attemptNo=='1'){
                    newACR.canEmail = false;                    
                }
                results.add(newACR);
            }
            
        }  
        return results;
    }

    /********************************
    * getFraudNoticeACRS            *
    * look for fraud notice ACR     *
    ********************************/
    private static list <OutboundACR> getFraudNoticeACRS(Set <Id> caseIds, Map <Id, Case> caseMap, Map <Id, Contact> contactMap){
        system.debug('>>> looking for a fraud notice match. In getFraudNoticeACRS');
        List<OutboundACR> results = new List<OutboundACR>();
        
        Set<String> caseSearchKeys = new Set<String>(); //Stores Case search Keys
        
        for(id caseId : caseIds) {
            Case c = caseMap.get(caseId);
            caseSearchKeys.add(c.Country__c+':'+c.Language__c+':'+ACR_TYPE_FRAUD_NOTICE);
        }
        
        List<Auto_Communication_Rule__c> acrRecords = new List<Auto_Communication_Rule__c>([
            SELECT Id, Name, General_Search_Key__c, Generate_PDF_for_Attempt__c, Template_Unique_Name__c, 
                X1st_Attempt_Fulfillment_Item__c, X1st_Attempt_Fulfillment_Item__r.sku__c, X1st_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X1st_Attempt_Fulfillment_Item__r.conga_template__c, X1st_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X1st_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X1st_Attempt_Fulfillment_Item__r.Type__c, X1st_Attempt_Fulfillment_Item__r.Description__c,
                X2nd_Attempt_Fulfillment_Item__c, X2nd_Attempt_Fulfillment_Item__r.sku__c, X2nd_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X2nd_Attempt_Fulfillment_Item__r.Type__c, X2nd_Attempt_Fulfillment_Item__r.Description__c,
                X3rd_Attempt_Fulfillment_Item__c, X3rd_Attempt_Fulfillment_Item__r.sku__c, X3rd_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X3rd_Attempt_Fulfillment_Item__r.Type__c, X3rd_Attempt_Fulfillment_Item__r.Description__c,
            	Digital_Attempt_1st_Template__c, Digital_Attempt_2nd_Template__c, Digital_Attempt_3rd_Template__c
            FROM Auto_Communication_Rule__c
            WHERE General_Search_Key__c IN :caseSearchKeys]);
        Map<String,Auto_Communication_Rule__c> arcMap = new Map<String,Auto_Communication_Rule__c>();

        for(Auto_Communication_Rule__c acrRecord : acrRecords){
            emailTemplateNames.add(acrRecord.Template_Unique_Name__c);
            arcMap.put(acrRecord.General_Search_Key__c, acrRecord);
        }

        for(Id caseId : caseIds) {
            Case c = caseMap.get(caseId);
            if (c.Repeater_Case__c == sf_RepeaterHelper.CASE_FRAUD_CASE && c.contactId!=null && contactMap.containsKey(c.contactId) 
                    && (contactMap.get(c.contactId).Repeater_Status__c == CONTACT_REPEATER_STATUS_KNOWN
                        || contactMap.get(c.contactId).Repeater_Status__c == CONTACT_REPEATER_STATUS_SUSPECTED)) { 
                Contact ct = contactMap.get(c.contactId);
                String caseSearchKey = (c.Country__c+':'+c.Language__c+':'+ACR_TYPE_FRAUD_NOTICE);
                if(arcMap.containsKey(caseSearchKey)){
                    Auto_Communication_Rule__c arc = arcMap.get(caseSearchKey);
                    String attemptNo = '1';//Attempt doesn't matter for fraud so set to 1?
                    results.add(new OutboundACR(c, arc, ct, attemptNo, null));
                }
            }
        }        
        return results;
    }
    
    public static void dprToPhysical(Map<Id, Case_Comment_Code__c> cccMap, Map<Id, Case> caseMap, Map<Id, Contact> contactMap){
        List<OutboundACR> acrsToSend = new List<OutboundACR>();
        acrsToSend = getProductReturnACRS(cccMap, caseMap, contactMap);
        sendACRs(acrsToSend,caseMap);//TODO how to force physical?
        //update Case fields
        List<Case> casesToUpdate = new List<Case>();
        for(Case c : caseMap.values()){
            c.Product_Return_Status__c = PRODUCT_RETURN_STATUS_ATTEMPT_1;
            c.Selected_Return_Type__c = ACR_PRODUCT_RETURN_PHYSICAL;
            casesToUpdate.add(c);
        }
		//Shouldn't call ACR code again as deactivated in d2p_ext.processSelected
        update casesToUpdate; 
    }
   	
	/********************************************
     * New for CR16 - We already know the ACR!	*
     * getProductReturnACRS         			*
     * look for product return ACR  			*
     *******************************************/
    public static list <OutboundACR> getProductReturnACRS(Map<Id, Case_Comment_Code__c> cccMap, Map<Id, Case> caseMap, Map<Id, Contact> contactMap){
        List<OutboundACR> results = new List<OutboundACR>(); //Matched records to send back for action
        Set<OutboundACR> resultsSet = new Set<OutboundACR>(); //To dedupe
        Set<String> acrsToGet = new Set<String>();
        Map<String, Auto_Communication_Rule__c> acrMap = new Map<String, Auto_Communication_Rule__c>();
        Set <Case_Product__c> cpRecords = new Set <Case_Product__c>(); //Case products to update status 
        Set<String> localExistingFFI = new Set<String>(); //local set for loop and attempts 2,3 

        try{
            //Check for existing FOs
            Set <String> existingCaseFulfillmentItems = new Set <String>(); // only checking existence; a compound key (caseid:fulfillmentItemId) is easier than a map<caseid, set<fiId>>
            for(Fulfillment_Order_Line_Item__c foli : [SELECT Case__c,Fulfillment_Item__c 
                                                        FROM Fulfillment_Order_Line_Item__c 
                                                        WHERE Case__c IN :caseMap.keyset() 
                                                        AND Fulfillment_Order__r.status__c != 'Closed']) {
                
                existingCaseFulfillmentItems.add(getCaseFIKey(foli.case__c, foli.fulfillment_item__c));
            }
            
            //Populate acrsToGet Set - used to Query ACR records
            for(Case_Comment_Code__c ccc : cccMap.values()){
                acrsToGet.add(ccc.Case_Product__r.ACR_Info__c);     
            }
            system.debug(logginglevel.WARN,'*** in ACR NEW getProductReturnACRS acrsToGet: '+acrsToGet);
            
            if(acrsToGet.size() > 0){//TODO: necessary?
                for(Auto_Communication_Rule__c acr: [
                        SELECT Id, Name, General_Search_Key__c, Generate_PDF_for_Attempt__c, Template_Unique_Name__c, 
                        X1st_Attempt_Fulfillment_Item__c, X1st_Attempt_Fulfillment_Item__r.sku__c, X1st_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X1st_Attempt_Fulfillment_Item__r.conga_template__c, X1st_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X1st_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X1st_Attempt_Fulfillment_Item__r.Type__c, X1st_Attempt_Fulfillment_Item__r.Description__c,
                        X2nd_Attempt_Fulfillment_Item__c, X2nd_Attempt_Fulfillment_Item__r.sku__c, X2nd_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X2nd_Attempt_Fulfillment_Item__r.Type__c, X2nd_Attempt_Fulfillment_Item__r.Description__c,
                        X3rd_Attempt_Fulfillment_Item__c, X3rd_Attempt_Fulfillment_Item__r.sku__c, X3rd_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X3rd_Attempt_Fulfillment_Item__r.Type__c, X3rd_Attempt_Fulfillment_Item__r.Description__c,
                        Digital_Attempt_1st_Template__c, Digital_Attempt_2nd_Template__c, Digital_Attempt_3rd_Template__c
                        FROM Auto_Communication_Rule__c
                        WHERE Name In :acrsToGet
                        //AND Supported_Return_Type__c = :system.label.physical//TODO: Why digital should support physical
                        ]){
                    acrMap.put(acr.Name, acr);
                    emailTemplateNames.add(acr.Template_Unique_Name__c);
                }            
            }        

            //Now match Case up to ACR to create outboundACR
            String caseFIKey = '';
            for(Case_Comment_Code__c ccc : cccMap.values()){
                Case c = caseMap.get(ccc.case__c);
                contact ct = contactMap.get(c.contactId);
                Auto_Communication_Rule__c matchedACR = new Auto_Communication_Rule__c();
                matchedACR = acrMap.get(ccc.Case_Product__r.ACR_Info__c);
                system.debug(logginglevel.WARN,'*** in ACR NEW getProductReturnACRS matchedACR: '+matchedACR);
                system.debug(logginglevel.WARN,'*** in ACR NEW getProductReturnACRS c.Product_Return_Status__c: '+c.Product_Return_Status__c);
                
                String attemptNo = '1';//1 so can also be used to set cp status
                if(!String.isBlank(c.Product_Return_Status__c)){
                    attemptNo = c.Product_Return_Status__c.right(1);
                }
                if(attemptNo == '1'){
                    caseFIKey = getCaseFIKey(ccc.Case__c, matchedACR.X1st_Attempt_Fulfillment_Item__c);
                }
                else if(attemptNo == '2'){
                    caseFIKey = getCaseFIKey(ccc.Case__c, matchedACR.X2nd_Attempt_Fulfillment_Item__c);
                }
                else if(attemptNo == '3'){
                    caseFIKey = getCaseFIKey(ccc.Case__c, matchedACR.X3rd_Attempt_Fulfillment_Item__c);
                }
                    
                system.debug(logginglevel.WARN,'*** in ACR NEW getProductReturnACRS attempt: '+attemptNo);
                system.debug(logginglevel.WARN,'*** in ACR NEW getProductReturnACRS CaseComment: '+ccc.Id);
                system.debug(logginglevel.WARN,'*** in ACR NEW getProductReturnACRS caseFIKey: '+caseFIKey);
                system.debug(logginglevel.WARN,'*** in ACR NEW getProductReturnACRS existing Case FFI? '+existingCaseFulfillmentItems.contains(caseFIKey));

                //Note: 2nd and 3rd Item will likely be the same - need to allow this "duplicate" item through
                if(attemptNo == '1' && !existingCaseFulfillmentItems.contains(caseFIKey)){
                    OutboundACR newACR = new OutboundACR(c, matchedACR, ct, attemptNo, ccc.Case_Product__c); //c = case, ct = contact
                    newACR.caseCommentCode = ccc.Id;
                    newACR.canEmail = false; //product return bundles is always a fulfillment order //This won't work for product returns
                    resultsSet.add(newACR); //Changing to Set
                    existingCaseFulfillmentItems.add(caseFIKey);                    
                }

                //Don't overwrite if 2nd/3d attempt as value already set via WFR
                if(attemptNo == '1'){
                    system.debug(logginglevel.WARN,'*** in ACR NEW getProductReturnACRS setting cp status');
                    Case_Product__c cp = new Case_Product__c();
                    cp.Id = ccc.Case_Product__c;
                    cp.Status__c = PRODUCT_RETURN_STATUS_ATTEMPT_PREFIX + '1';
                    if (!cpRecords.contains(cp)){
                        cpRecords.add(cp);
                    }                    
                }
                    
                //if(attemptNo != '1' && !localExistingFFI.contains(caseFIKey)){
                if(attemptNo.isNumeric() && attemptNo != '1' && !localExistingFFI.contains(caseFIKey)){//WR434 prevent ACR firing on completed statuses again
                    OutboundACR newACR = new OutboundACR(c, matchedACR, ct, attemptNo, ccc.Case_Product__c);
                    resultsSet.add(newACR);
                    localExistingFFI.add(caseFIKey);
                }            
            }///CCC for loop end
            
            if (cpRecords.size() > 0){
                system.debug(logginglevel.WARN,'*** in ACR NEW getProductReturnACRS cpRecords: '+cpRecords);
                List <Case_Product__c> cpsToUpdate = new List <Case_Product__c> (cpRecords);
                update cpsToUpdate;           
            }     

            results.addAll(resultsSet);
                                        
            return results;//Send matched records back for actions
        }
        catch(exception e){
            System.enqueueJob(new exceptionHelperQueable(e,'ACR Exception in getProductReturnACRS ccmap: '+cccMap+' **caseMap: '+caseMap+' **contactMap: '+contactMap));
            return null;
        }
    }
    /********************************
     * Existing PHYSICAL			*
     * product return ACR  			*
     *******************************/
    private static list <OutboundACR> getProductReturnACRS(Map<Id, Case_Comment_Code__c> cccMap, Map<Id, Contact> contactMap, Map<Id, Case> caseMap, Set<String> caseSearchKeys) {
        system.debug('>>> looking for a product return match. In getProductReturnACRS');

        List<OutboundACR> results = new List<OutboundACR>(); //Matched records to send back for action
        Set<OutboundACR> resultsSet = new Set<OutboundACR>(); //To dedupe
        Set<String> localExistingFFI = new Set<String>(); //local set for loop and attempts 2,3 
        //Attempting to use set to dedupe...
        Set <Case_Product__c> cpRecords = new Set <Case_Product__c>(); //Case products to update status 
        List<Case> caseLoop = new List<Case>(); //To pass to getPRR
        
        //Query ACRs where search key is in Set
        Map<String, Auto_Communication_Rule__c> ACRMap = new Map<String, Auto_Communication_Rule__c>();
        
        // check for existing FOs
        Set <String> existingCaseFulfillmentItems = new Set <String>(); // only checking existence; a compound key (caseid:fulfillmentItemId) is easier than a map<caseid, set<fiId>>
        for(Fulfillment_Order_Line_Item__c foli : [SELECT Case__c,Fulfillment_Item__c 
                                                    FROM Fulfillment_Order_Line_Item__c 
                                                    WHERE Case__c IN :caseMap.keyset() 
                                                    AND Fulfillment_Order__r.status__c != 'Closed']) {
            
            existingCaseFulfillmentItems.add(getCaseFIKey(foli.case__c, foli.fulfillment_item__c));
        }
        
        If(caseSearchKeys.size() > 0 ){
            List<Auto_Communication_Rule__c> ACRList = new List<Auto_Communication_Rule__c>([
               SELECT Id, Name, Product_Search_Key__c, Generate_PDF_for_Attempt__c, Template_Unique_Name__c, 
                X1st_Attempt_Fulfillment_Item__c, X1st_Attempt_Fulfillment_Item__r.sku__c, X1st_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X1st_Attempt_Fulfillment_Item__r.conga_template__c, X1st_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X1st_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X1st_Attempt_Fulfillment_Item__r.Type__c, X1st_Attempt_Fulfillment_Item__r.Description__c,
                X2nd_Attempt_Fulfillment_Item__c, X2nd_Attempt_Fulfillment_Item__r.sku__c, X2nd_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X2nd_Attempt_Fulfillment_Item__r.Type__c, X2nd_Attempt_Fulfillment_Item__r.Description__c,
                X3rd_Attempt_Fulfillment_Item__c, X3rd_Attempt_Fulfillment_Item__r.sku__c, X3rd_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X3rd_Attempt_Fulfillment_Item__r.Type__c, X3rd_Attempt_Fulfillment_Item__r.Description__c,
                Digital_Attempt_1st_Template__c, Digital_Attempt_2nd_Template__c, Digital_Attempt_3rd_Template__c
                FROM Auto_Communication_Rule__c
                WHERE Product_Search_Key__c IN :caseSearchKeys
                AND Type__c = :ACR_TYPE_PRODUCT_RETURN
            ]);
            
            For(Auto_Communication_Rule__c acr : ACRList){
                emailTemplateNames.add(acr.Template_Unique_Name__c);
                ACRMap.put(acr.Product_Search_Key__c, acr);
            }          
        }

        //Now match up Case to ACR
        For(Case_Comment_Code__c ccc : cccMap.values()){
            
            Case c = caseMap.get(ccc.case__c);
            contact ct = contactMap.get(c.contactId);
            
            String caseSearchPathKey = c.Country__c+':'+c.Language__c+':'+ccc.Global_Product_Path__c+':'+ccc.Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c;
            String caseSearchSegmentKey = c.Country__c+':'+c.Language__c+':'+ccc.Global_Product_Segment__c+':'+ccc.Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c;
            
            Auto_Communication_Rule__c matchedACR = new Auto_Communication_Rule__c();
            
            //Look for segment match first
            //Confirmed this is correct with Christina Northlich Feb 2017
            If(ACRMap.containsKey(caseSearchSegmentKey)){
                System.debug('>>> Match found on Product Segment');
                matchedACR = ACRMap.get(caseSearchSegmentKey);
                system.debug('>>> Matched ACR: \n'+matchedACR);
                
            }
            Else if(ACRMap.containsKey(caseSearchPathKey)){
                System.debug('>>> Match found on Product Path');
                matchedACR = ACRMap.get(caseSearchPathKey);
                system.debug('>>> Matched ACR: \n'+matchedACR);
            }

            String caseFIKey = '';
            system.debug('>>> Matched ACR: '+matchedACR.Name);
			system.debug('>>> Case product return status: '+c.Product_Return_Status__c);            
            
            //matchedACR != null doesn't work...
            //Too many ifs ;(
            if(matchedACR.Id != null){
                String attemptNo = '1'; //changing from 0 - 1 so can also be used to set cp status
                if(!String.isBlank(c.Product_Return_Status__c)){
                    attemptNo = c.Product_Return_Status__c.right(1);
                }
                if(attemptNo == '1'){
                    caseFIKey = getCaseFIKey(ccc.Case__c, matchedACR.X1st_Attempt_Fulfillment_Item__c);
                }
                else if(attemptNo == '2'){
                    caseFIKey = getCaseFIKey(ccc.Case__c, matchedACR.X2nd_Attempt_Fulfillment_Item__c);
                }
                else if(attemptNo == '3'){
                    caseFIKey = getCaseFIKey(ccc.Case__c, matchedACR.X3rd_Attempt_Fulfillment_Item__c);
                }
                
                system.debug('>>> attempt: '+attemptNo);
                system.debug('>>> CaseComment: '+ccc.Id);
                system.debug('>>> caseFIKey: '+caseFIKey);
                system.debug('>>> existing Case FFI? '+existingCaseFulfillmentItems.contains(caseFIKey));

                //Note: 2nd and 3rd Item will likely be the same - need to allow this "duplicate" item through
                if(attemptNo == '1' && !existingCaseFulfillmentItems.contains(caseFIKey)){
                    OutboundACR newACR = new OutboundACR(c, matchedACR, ct, attemptNo, ccc.Case_Product__c); //c = case, ct = contact
                    newACR.caseCommentCode = ccc.Id;
                    newACR.canEmail = false; //product return bundles is always a fulfillment order //This won't work for product returns
                    resultsSet.add(newACR); //Changing to Set
                    existingCaseFulfillmentItems.add(caseFIKey);                    
                }

                //Don't overwrite if 2nd/3d attempt as value already set via WFR
                if(attemptNo == '1'){
                    system.debug('>>> setting cp status');
                    Case_Product__c cp = new Case_Product__c();
                    cp.Id = ccc.Case_Product__c;
                    cp.Status__c = PRODUCT_RETURN_STATUS_ATTEMPT_PREFIX + '1';
                    if (!cpRecords.contains(cp)){
                        cpRecords.add(cp);
                    }                    
                }
                
                if(attemptNo.isNumeric() && attemptNo != '1' && !localExistingFFI.contains(caseFIKey)){//WR434 prevent ACR firing on completed statuses again
                    OutboundACR newACR = new OutboundACR(c, matchedACR, ct, attemptNo, ccc.Case_Product__c);
                    resultsSet.add(newACR);
                    localExistingFFI.add(caseFIKey);
                }
            }

        }
        system.debug('>>> cpRecords size: '+cpRecords.size());
        if (cpRecords.size() > 0){
            system.debug('>>> cpRecords: '+cpRecords);
            List <Case_Product__c> cpRecordsList = new List <Case_Product__c> (cpRecords);
            update cpRecordsList;           
        }
    
        system.debug('>>> resultsSet size: '+resultsSet.size());
        results.addAll(resultsSet);
        
        return results;//Send matched records back for actions
    }

    private static string getCaseFIKey(id caseId, id fulfillmentItemId) {
        return caseId + ':' + fulfillmentItemId; 
    }
    
    private static List <Messaging.SendEmailResult> emailResults = new List <Messaging.SendEmailResult> ();
    
    private static List <Messaging.Singleemailmessage> getACREmails(list<OutboundACR> acrs) {
        List <Messaging.Singleemailmessage> emails = new List <Messaging.Singleemailmessage>();
        for(OutboundACR acr : acrs) {
            Messaging.Singleemailmessage msg = new Messaging.Singleemailmessage();
            msg.setOrgWideEmailAddressId(sf_GlobalUtilityClass.orgEmailMap.get('consumercare.im@pg.com').Id);//Id will be different in DEV/ACC unless they are refreshed
            msg.setTemplateId(acr.emailTemplateId);
            msg.setTargetObjectId(acr.contactId);
            msg.setWhatId(acr.caseId);
            msg.setSaveAsActivity(false); //if TRUE, each email generates a task which fires the task trigger, INDIVIDUALLY; too many SOQL queries.
            emails.add(msg);
        }
        
        return emails;
    }
    
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
        set;
    }
    
    private static string getLetterBody(OutboundACR acr, Case c) {
        if(acr == null || c==null || acr.letterBody == null) {
            return '';
        }
        return acr.letterBody
                   .replace('{Case.Country}', safeString(c.Country__c))
                   .replace('{Case.ContactMethod}', safeString(c.origin))
                   .replace('{Case.Id}', safeString(c.CaseNumber))
                   .replace('{Case.Language}', safeString(c.Language__c))
                   .replace('{Account.FirstName}', safeString(acr.firstname))
                   .replace('{Account.LastName}', safeString(acr.lastname))
                   .replace('{Account.Salutation}', safeString(acr.salutation))
                   .replace('{Case.Brand}', safeString(c.brand__c))
                   .replace('{Case.Segment}', safeString(c.segment__c))
                   ;
    }
    
    private static String SafeString (String original) {
        return original==null ? '' : original;
    }
    
	/**
     *   Internal class that represents a specifc outbound communication
     */
    public class OutboundACR{
        public Id caseId;
        public Id cpId;//CR16 Need CP.Id
        public Id contactId;
        public String contactCountry;
        public String ACRName;       
        public Id fulfillmentItemId;
        public String fulfillmentItemType;
        public String fulfillmentItemDescription;
        public String sku;
        public String itemFulId;
        public String emailTemplateName;
        public Id emailTemplateId;
        public String emailSubject;
        public String emailBody;
        public Id congaTemplateId;
        public Boolean RTLLanguage;
        public String letterBody;
        public String digiFirstAttempt; //CR16
        
        public Id FI2_fulfillmentItemId;
        public String FI2_fulfillmentItemType;
        public String FI2_fulfillmentItemDescription;
        public String FI2_sku;
        public String FI2_itemFulId;
        public String FI2_emailTemplateName;
        public Id FI2_emailTemplateId;
        public String FI2_emailSubject;
        public String FI2_emailBody;
        public Id FI2_congaTemplateId;
        public Boolean FI2_RTLLanguage;
        public String FI2_letterBody;
		public String digiSecondAttempt; //CR16
        
        public Id FI3_fulfillmentItemId;
        public String FI3_fulfillmentItemType;
        public String FI3_fulfillmentItemDescription;
        public String FI3_sku;
        public String FI3_itemFulId;
        public String FI3_emailTemplateName;
        public Id FI3_emailTemplateId;
        public String FI3_emailSubject;
        public String FI3_emailBody;
        public Id FI3_congaTemplateId;
        public Boolean FI3_RTLLanguage;
        public String FI3_letterBody;
        public String digiThirdAttempt; //CR16
        
        public String firstname;
        public String lastname;
        public String salutation;
        public String email;
        public Id caseCommentCode;
        public Boolean canEmail = false;
        
        public String generatePDFAttempt = ''; //Attempts to generate a PDF for
        
        public String attempt;
        
        public OutboundACR(Case c, Auto_Communication_Rule__c ACR, Contact ct, String AttemptNo,Id cpId) {
            this.ACRName = ACR.Name;         
            this.caseId = c.id;
            this.cpId = cpId;
            this.attempt = AttemptNo;
            this.contactId = c.contactId;
            this.contactCountry = c.country__c;
            this.fulfillmentItemId = ACR.X1st_Attempt_Fulfillment_Item__c;
            this.sku = ACR.X1st_Attempt_Fulfillment_Item__r.sku__c;
            this.itemFulId = ACR.X1st_Attempt_Fulfillment_Item__r.fulfillment_item_id__c;
            this.emailTemplateName = ACR.Template_Unique_Name__c;
            this.congaTemplateId = ACR.X1st_Attempt_Fulfillment_Item__r.conga_template__c;
            this.RTLLanguage = ACR.X1st_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c;
            this.letterBody = ACR.X1st_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c;

            this.fulfillmentItemType = ACR.X1st_Attempt_Fulfillment_Item__r.Type__c;
            this.fulfillmentItemDescription = ACR.X1st_Attempt_Fulfillment_Item__r.Description__c;
            this.digiFirstAttempt = ACR.Digital_Attempt_1st_Template__c;//CR16

            this.FI2_fulfillmentItemId = ACR.X2nd_Attempt_Fulfillment_Item__c;
            this.FI2_sku = ACR.X2nd_Attempt_Fulfillment_Item__r.sku__c;
            this.FI2_itemFulId = ACR.X2nd_Attempt_Fulfillment_Item__r.fulfillment_item_id__c;
            this.FI2_emailTemplateName = ACR.Template_Unique_Name__c;
            this.FI2_congaTemplateId = ACR.X2nd_Attempt_Fulfillment_Item__r.conga_template__c;
            this.FI2_RTLLanguage = ACR.X2nd_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c;
            this.FI2_letterBody = ACR.X2nd_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c;
            this.FI2_fulfillmentItemType = ACR.X2nd_Attempt_Fulfillment_Item__r.Type__c;
            this.FI2_fulfillmentItemDescription = ACR.X2nd_Attempt_Fulfillment_Item__r.Description__c;
            this.digiSecondAttempt = ACR.Digital_Attempt_2nd_Template__c;//CR16
            
            this.FI3_fulfillmentItemId = ACR.X3rd_Attempt_Fulfillment_Item__c;
            this.FI3_sku = ACR.X3rd_Attempt_Fulfillment_Item__r.sku__c;
            this.FI3_itemFulId = ACR.X3rd_Attempt_Fulfillment_Item__r.fulfillment_item_id__c;
            this.FI3_emailTemplateName = ACR.Template_Unique_Name__c;
            this.FI3_congaTemplateId = ACR.X3rd_Attempt_Fulfillment_Item__r.conga_template__c;
            this.FI3_RTLLanguage = ACR.X3rd_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c;
            this.FI3_letterBody = ACR.X3rd_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c;
            this.FI3_fulfillmentItemType = ACR.X3rd_Attempt_Fulfillment_Item__r.Type__c;
            this.FI3_fulfillmentItemDescription = ACR.X3rd_Attempt_Fulfillment_Item__r.Description__c;
            this.digiThirdAttempt = ACR.Digital_Attempt_3rd_Template__c;//CR16

            if(ct!=null) {
                this.firstname = ct.firstname;
                this.lastname = ct.lastname;
                this.salutation = ct.salutation;
                this.email = ct.email;
                if(!string.isBlank(ct.email)) {
                    this.canEmail = true;
                }
            }
            
            this.generatePDFAttempt = ACR.Generate_PDF_for_Attempt__c;

        }
    }
}