/*
 * Fires first attempt for digital returns
 * via the submit button
 */
public class digiReturnsHelper {
    
    private static Set <String> emailTemplateNames = new Set <String>();
    private static List <Messaging.SendEmailResult> emailResults = new List <Messaging.SendEmailResult>();
    public static final String EMAIL_FROM_NAME = 'System Generated'; // used for EmailMessages sent via ACR rule
    public static final String DIGI_RETURN_FIRST_ATTEMPT = 'Photo - Attempt 1';

    //New method to handle clearing Case.PRR
    //Scenario: When a CP was added, Case Submitted. Case reopened original CP cancelled and a new CP added.
    //Need to clear Case.PRR otherwise 2nd attempt WFR doesn't get queued - unclear why
    @future
    public static void digiReturnFirstAttempt(Set<Id> caseIds){
    	Set<Id> caseIdsToProcess = new Set<Id>();
    	Map<Id,List<Case_Product__c>> allCPMap = new Map<Id,List<Case_Product__c>>();//All CPs
    	Map<Id,List<Case_Product__c>> cpToProcessMap = new Map<Id,List<Case_Product__c>>();//CPs to process

    	//CPs to process
    	if(!caseIds.isEmpty()){
            for(Case_Product__c cp : [SELECT Id, Case__c, Status__c, productstatus__c
                                        FROM Case_Product__c
                                        WHERE Case__c In :caseIds
                                        AND Product_available_for_return__c = 'Yes - Product is available'
                                        AND ACR_Return_Type__c = 'Digital']
                                        ){

            	//Populate CP to process map
            	if(cp.productstatus__c == 'Added' && String.isBlank(cp.Status__c)){
	                if(cpToProcessMap.containsKey(cp.Case__c)){
	                	cpToProcessMap.get(cp.Case__c).add(cp);
	                }
	                else{
	                	List<Case_Product__c> cpList = new List<Case_Product__c>();
	                	cpList.add(cp);
	                	cpToProcessMap.put(cp.Case__c,cpList);
	                }
	                caseIdsToProcess.add(cp.Case__c); 
            	}
            	//Populate complete CP map
                if(allCPMap.containsKey(cp.Case__c)){
                	allCPMap.get(cp.Case__c).add(cp);
                }
                else{
                	List<Case_Product__c> cpList = new List<Case_Product__c>();
                	cpList.add(cp);
                	allCPMap.put(cp.Case__c,cpList);
                }            	
            }

            List<Case> casesToUpdate = new List<Case>();
            for(Case c : [SELECT Id, Product_Return_Status__c, Active_Products__c FROM Case WHERE Id In :caseIds]){
            	Integer cpsToProcess = 0;
            	if(cpToProcessMap.get(c.Id) != null){
					cpsToProcess = cpToProcessMap.get(c.Id).size();
            	}
            	//TODO: What if multiple?
            	//'Should' only be 1 if done correctly through ContactInfo
            	if(cpsToProcess == 1 && String.isNotBlank(c.Product_Return_Status__c)){
            		c.Product_Return_Status__c = '';
            		casesToUpdate.add(c);
            	}
            }
            update casesToUpdate;

			Map<Id, Case> closedCases = new Map<Id, Case>([SELECT Id, ContactId, Country__c, Selected_Return_Type__c, Product_Return_Status__c, Active_Products__c FROM Case WHERE Id In :caseIdsToProcess]);
    		digiReturnFirstAttempt(closedCases);
    	}
    }
    
    @future
    public static void digiReturnFirstAttemptOLD(Set<Id> caseIds){
        if(!caseIds.isEmpty()){
            //Map<Id, Case> closedCases = new Map<Id, Case>([SELECT Id, ContactId, Country__c, Selected_Return_Type__c, Product_Return_Status__c FROM Case WHERE Id In :caseIds]);
            //Don't send again on re-submission, Product_Return_Status__c should be null

            //Current DEV version:
            //Map<Id, Case> closedCases = new Map<Id, Case>([SELECT Id, ContactId, Country__c, Selected_Return_Type__c, Product_Return_Status__c FROM Case WHERE Id In :caseIds AND Product_Return_Status__c='']);
            
            //Modify to use Case Product.status = '' instead
            Set<Id> caseIdsToProcess = new Set<Id>();
            for(Case_Product__c cp : [SELECT Id, Case__c
                                        FROM Case_Product__c
                                        WHERE Case__c In :caseIds
                                        AND Status__c = '' AND productstatus__c = 'added' AND Product_available_for_return__c = 'Yes - Product is available'
                                        AND ACR_Return_Type__c = 'Digital']
                                        ){
                system.debug(logginglevel.WARN, '>>> CP to process: '+cp);
                caseIdsToProcess.add(cp.Case__c);
            }

            Map<Id, Case> closedCases = new Map<Id, Case>([SELECT Id, ContactId, Country__c, Selected_Return_Type__c, Product_Return_Status__c, Active_Products__c FROM Case WHERE Id In :caseIdsToProcess]);

            digiReturnFirstAttempt(closedCases);
        }
    }
	
    /****************************************
     * CR16 - Digital Returns First Attempt *
     ***************************************/
    public static void digiReturnFirstAttempt(Map<Id, Case> closedCases){
        system.debug(logginglevel.WARN, ' >>> in digiReturnFirstAttempt closedCases: '+closedCases);
        List<Case> casesToProcess = new List<Case>();
        Set<Id> contactIds = new Set<Id>();
        Map <Id, Case_Comment_Code__c> cccMap = new Map <Id, Case_Comment_Code__c>();
        List<OutboundACR> acrsToSend = new List<OutboundACR>();

        
        for(Case c : closedCases.values()){
            system.debug(logginglevel.WARN,'>>> in digiReturnFirstAttempt. c.Selected_Return_Type__c = '+c.Selected_Return_Type__c+' Label: '+system.label.digital);
            if(c.Selected_Return_Type__c == 'Digital'){
                casesToProcess.add(c);
                contactIds.add(c.ContactId);
            }            
        }

        if(!casesToProcess.isEmpty()){
            Map <Id, Contact> contactMap = new Map <Id, Contact>([SELECT Id, Email, FirstName, LastName, Salutation, Repeater_Status__c FROM Contact WHERE Id IN :contactIds]);
            
            cccMap = new Map<Id, Case_Comment_Code__c>([SELECT Status__c, GCR_CID__c, Case_Contact_Id__c, Case__c, Case_Product__r.Product_available_for_return__c, Case_Product__r.ACR_Info__c, Case_Product__r.Status__c
                                                        FROM Case_Comment_Code__c
                                                        WHERE (
                                                            Case_Product__r.Product_available_for_return__c = :trg_AutoComRuleHelper.PRODUCT_AVAILABLE_FOR_RETURN 
                                                            AND Case_Product__r.ACR_Return_Type__c = 'Digital'
                                                            AND Case__r.Contact.Email != null
                                                            AND Case__c IN :casesToProcess)
                                                        ]);

            acrsToSend.addAll(getDigiACRs(cccMap, closedCases, contactMap));
            sendACRs(acrsToSend, closedCases);
        }

    }
    
    private static void sendACRs (List <OutboundACR> acrsToSend, Map <Id, Case> caseMap){
        //Action here
        Map <String, EmailTemplate> emailTemplateMap = new Map <String, EmailTemplate>();
        List <OutboundACR> acrsToEmail = new List <OutboundACR>();
        
        for(EmailTemplate et : [SELECT Id, DeveloperName, Subject, Body FROM EmailTemplate WHERE DeveloperName IN :emailTemplateNames]) {
            emailTemplateMap.put(et.developerName, et);
        } 
        
        system.debug(logginglevel.WARN,'>>> In sendACRs emailTemplateMap: '+emailTemplateMap);
        system.debug(logginglevel.WARN,'>>> In sendACRs acrsToSend: '+acrsToSend);
        
        for(OutboundACR acr : acrsToSend){
            if(acr.attempt == '1' && !string.isBlank(acr.digiFirstAttempt) && emailTemplateMap.containsKey(acr.digiFirstAttempt) && acr.canEmail) {
                acr.emailTemplateId = emailTemplateMap.get(acr.digiFirstAttempt).Id;
                acr.emailSubject = emailTemplateMap.get(acr.digiFirstAttempt).subject;
                acr.emailBody = emailTemplateMap.get(acr.digiFirstAttempt).body;
                acrsToEmail.add(acr);
            }
            else if(acr.attempt == '2' && !string.isBlank(acr.digiSecondAttempt) && emailTemplateMap.containsKey(acr.digiSecondAttempt) && acr.canEmail) {
                acr.emailTemplateId = emailTemplateMap.get(acr.digiSecondAttempt).Id;
                acr.emailSubject = emailTemplateMap.get(acr.digiSecondAttempt).subject;
                acr.emailBody = emailTemplateMap.get(acr.digiSecondAttempt).body;
                acrsToEmail.add(acr);
            }
            else if(acr.attempt == '3' && !string.isBlank(acr.digiThirdAttempt) && emailTemplateMap.containsKey(acr.digiThirdAttempt) && acr.canEmail) {
                acr.emailTemplateId = emailTemplateMap.get(acr.digiThirdAttempt).Id;
                acr.emailSubject = emailTemplateMap.get(acr.digiThirdAttempt).subject;
                acr.emailBody = emailTemplateMap.get(acr.digiThirdAttempt).body;
                acrsToEmail.add(acr);
            }
            else{
                System.enqueueJob(new exceptionHelperQueable('DPR Error on matching attempt. Case:  '+String.valueOf(acr.caseId)+' ACR: '+string.valueOf(acr)));
            }
            
        }
        //try to send emails
        if(acrsToEmail.size()>0){
            List <Messaging.SingleEmailMessage> emails = getACREmails(acrsToEmail);
            List <EmailMessage> ems = new List <EmailMessage>();
            emailResults = Messaging.sendEmail(emails, false); // allOrNothing = false
            //must iterate results by index; results are parallel to emails (and to OutboundACRs)
            for(integer i = 0; i<emailResults.size(); i++) {

                Messaging.SendEmailResult result = emailResults[i];
                
                system.debug('>>> emailResult: '+result);

                if(!result.isSuccess()) {
                    OutboundACR arc = acrsToEmail[i];

                    //TODO:Not bulkified...could hit limit in time based workflow context
                    //Awaiting SF support to "fix" sending Messaging.SendEmailResult to queueable
                    System.enqueueJob(new exceptionHelperQueable('DPR Error on send email. Case:  '+String.valueOf(acrsToEmail[i].caseId)+' errors: '+String.valueOf(result.getErrors())));
                } else {
 
                    EmailMessage em = new EmailMessage();  
                    em.ParentId = acrsToEmail[i].caseId; 
                    em.FromName = EMAIL_FROM_NAME;
                    em.FromAddress = 'consumercare.im@pg.com';
                    em.MessageDate = System.now(); 
                    em.ToAddress = acrsToEmail[i].email;
                    em.Subject = acrsToEmail[i].emailSubject;
                    em.HtmlBody = acrsToEmail[i].emailBody;
                    ems.add(em);
                }
            }
    
            if(ems.size() > 0){
                insert ems; 
            }  
        }
        
    }

    private static list <OutboundACR> getDigiACRs(Map<Id, Case_Comment_Code__c> cccMap, Map<Id, Case> caseMap, Map<Id, Contact> contactMap){
        List<OutboundACR> results = new List<OutboundACR>(); //Matched records to send back for action
        Set<OutboundACR> resultsSet = new Set<OutboundACR>(); //To dedupe - this no worky

        Map<String,OutboundACR> resultMap = new Map<String,OutboundACR>(); //deudping by product path? what if the same product twice?

        Set<String> acrsToGet = new Set<String>();
        Map<String, Auto_Communication_Rule__c> acrMap = new Map<String, Auto_Communication_Rule__c>();
        Set<Case_Product__c> cpSet = new Set<Case_Product__c>();//As a product can have more than one Comment - prevent's adding to the update list twice
        
        for(Case_Comment_Code__c ccc : cccMap.values()){
            acrsToGet.add(ccc.Case_Product__r.ACR_Info__c);     
        }
        
        system.debug(logginglevel.WARN,'*** in getDigiACRs acrsToGet: '+acrsToGet);
        
        //String digitalFilter = '%'+system.label.digital+'%';//For Digital only support
        
        for(Auto_Communication_Rule__c acr: [
                SELECT Id, Name, General_Search_Key__c, Generate_PDF_for_Attempt__c, Template_Unique_Name__c, Product_Search_Key__c,
                X1st_Attempt_Fulfillment_Item__c, X1st_Attempt_Fulfillment_Item__r.sku__c, X1st_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X1st_Attempt_Fulfillment_Item__r.conga_template__c, X1st_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X1st_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X1st_Attempt_Fulfillment_Item__r.Type__c, X1st_Attempt_Fulfillment_Item__r.Description__c,
                X2nd_Attempt_Fulfillment_Item__c, X2nd_Attempt_Fulfillment_Item__r.sku__c, X2nd_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X2nd_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X2nd_Attempt_Fulfillment_Item__r.Type__c, X2nd_Attempt_Fulfillment_Item__r.Description__c,
                X3rd_Attempt_Fulfillment_Item__c, X3rd_Attempt_Fulfillment_Item__r.sku__c, X3rd_Attempt_Fulfillment_Item__r.fulfillment_item_id__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__r.rtl_language__c, X3rd_Attempt_Fulfillment_Item__r.conga_template__r.HTML_Content__c, X3rd_Attempt_Fulfillment_Item__r.Type__c, X3rd_Attempt_Fulfillment_Item__r.Description__c,
                Digital_Attempt_1st_Template__c, Digital_Attempt_2nd_Template__c, Digital_Attempt_3rd_Template__c
                FROM Auto_Communication_Rule__c
                WHERE Name In :acrsToGet
                AND Supported_Return_Type__c = 'Digital'
                //AND Supported_Return_Type__c LIKE :digitalFilter //Digital only support - Picklist values = 'Digital only' and 'Digital & Physical'
                ]){
            acrMap.put(acr.Name, acr);
            emailTemplateNames.add(acr.Digital_Attempt_1st_Template__c);
            emailTemplateNames.add(acr.Digital_Attempt_2nd_Template__c); 
            emailTemplateNames.add(acr.Digital_Attempt_3rd_Template__c); 
        }

        system.debug(logginglevel.WARN,'*** in getDigiACRs emailTemplateNames: '+emailTemplateNames);
        system.debug(logginglevel.WARN,'*** in getDigiACRs caseMap: '+caseMap);
        system.debug(logginglevel.WARN,'*** in getDigiACRs contactMap: '+contactMap);
        
        //TODO: What if we change attempt no to be driven by CP.Status?
        for(Case_Comment_Code__c ccc : cccMap.values()){
            system.debug(logginglevel.WARN, '>>> ccc.Case_Product__r.Status__c: '+ccc.Case_Product__r.Status__c);
            Case c = caseMap.get(ccc.case__c);
            contact ct = contactMap.get(c.contactId);
            
            String attemptNo = '1';
            //if(c.Product_Return_Status__c != null){
            if(ccc.Case_Product__r.Status__c != null){
                //attemptNo = c.Product_Return_Status__c.right(1);
                attemptNo = ccc.Case_Product__r.Status__c.right(1);
            }
            
            Auto_Communication_Rule__c matchedACR = new Auto_Communication_Rule__c();
            matchedACR = acrMap.get(ccc.Case_Product__r.ACR_Info__c);
            if(attemptNo == '1'){         
                OutboundACR newACR = new OutboundACR(c, matchedACR, ct, attemptNo, ccc.Case_Product__c);
                newACR.canEmail = True; //always true for digi returns
                
                //Set Case_Product status
                Case_Product__c cp = new Case_Product__c();
                cp.Id = ccc.Case_Product__c;
                cp.Status__c = DIGI_RETURN_FIRST_ATTEMPT;
                cpSet.add(cp);
                
                //resultsSet.add(newACR);
                resultMap.put(matchedACR.Product_Search_Key__c,newACR);//Dedupe by ACR search key?       
            }
            
            if(attemptNo.isNumeric() && attemptNo != '1'){
                OutboundACR newACR = new OutboundACR(c, matchedACR, ct, attemptNo, ccc.Case_Product__c);
                newACR.canEmail = True; //always true for digi returns

                //resultsSet.add(newACR);
                resultMap.put(matchedACR.Product_Search_Key__c,newACR);//Dedupe by ACR search key?  
            }

        }

        List<Case_Product__c> cpsToUpdate = new List<Case_Product__c>(cpSet);
        update cpsToUpdate;

        //results.addAll(resultsSet);
        results.addAll(resultMap.values());
        system.debug(logginglevel.WARN, '>>> in digiReturnsHelper results: '+results);
        /*
        //DEBUG START - TO BE REMOVED
        Task t1 = new Task(
            subject = 'CMD DPR Debug - result list',
            Description = String.valueOf(results)
            );
        insert t1;
        Task t2 = new Task(
            subject = 'CMD DPR Debug - result map',
            Description = String.valueOf(resultMap)
            );
        insert t2;
        //DEBUG END*/
                                    
        return results;
    }
    
    private static List <Messaging.Singleemailmessage> getACREmails(list<OutboundACR> acrs) {
        List <Messaging.Singleemailmessage> emails = new List <Messaging.Singleemailmessage>();
        for(OutboundACR acr : acrs) {
            Messaging.Singleemailmessage msg = new Messaging.Singleemailmessage();
            msg.setOrgWideEmailAddressId(sf_GlobalUtilityClass.orgEmailMap.get('consumercare.im@pg.com').Id);//Id will be different in DEV/ACC unless they are refreshed
            msg.setTemplateId(acr.emailTemplateId);
            msg.setTargetObjectId(acr.contactId);
            //msg.setWhatId(acr.caseId);
            msg.setWhatId(acr.cpId);//CR16
            msg.setSaveAsActivity(false); //if TRUE, each email generates a task which fires the task trigger, INDIVIDUALLY; too many SOQL queries.
            emails.add(msg);
        }
        
        return emails;
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