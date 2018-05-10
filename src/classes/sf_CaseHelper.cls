/**
* @author: Chris Southworth
* @date: 06/05/2014
*
*Trigger helper case trigger
*/
public with sharing class sf_CaseHelper {

   /**
    * @author: Chris Southworth
    * @date: 06/05/2014
    *
    * @description: For US461 and US465: Used to prevent the user from closing a case when there is not a valid
    *   Contact with a populated Address.  If the override fields are set to true the case can be closed
    *   (Consumer_declined_to_share_Contact_Info__c, Consumer_declined_to_share_Address__c)
    */
    /*
    //Removed as part of WR120 ChrisM
    public static void preventCloseForMissingContactAndAddress(Map<Id, Case> newMap, Map<Id, Case> oldMap){
        Set<String> contactIds = new Set<String>();
        Map<Id, Case> newlyClosedCases = new Map<Id, Case>();
        for(Case c : newMap.values()){
            if(c.Number_of_Adverse_Event__c != 0 || c.Number_of_PQC_Comments__c != 0){//contact and address are required
                if(c.Status.contains('Closed') && !oldMap.get(c.Id).Status.contains('Closed')){//case is newly closed
                    if(c.ContactId != null){//check for contact address fields
                        newlyClosedCases.put(c.Id, c);
                        contactIds.add(c.ContactId);
                    } else if(c.ContactId == null){//verify flags since contact is missing
                        if(c.Consumer_declined_to_share_Contact_Info__c == false){
                            c.addError(Label.Case_Checklist_Error_Missing_Contact);
                        } else if(c.Consumer_declined_to_share_Address__c == false){
                            c.addError(Label.Case_Checklist_Error_Missing_Address);
                        }
                    }
                }
            }
        }

        //verify contact address fields
        if(!contactIds.isEmpty()){
            Map<Id, Contact> invalidContacts = new Map<Id, Contact>([SELECT Id FROM Contact WHERE (Primary_Address_Line_1__c = null OR Primary_City__c = null 
                                        OR Primary_State_Province__c = null OR Primary_Postal_Code__c = null 
                                        OR Primary_Country__c = null) AND Id IN :contactIds]);

            for(Case c : newlyClosedCases.values()){
                if(c.ContactId != null && c.Consumer_declined_to_share_Address__c == false && invalidContacts.containsKey(c.ContactId)){
                    c.addError(Label.Case_Checklist_Error_Missing_Address);
                }
            }
        }
    }*/


    /**
    *
    *   @author: orikkers@salesforce.com
    *   @date: 09/03/2014
    *   @description: US721 Activity: Logging Followup Calls
    *                 Upon case creation an internal activity is created
    */
    public static void createInternalActivitiesForNewCases (Map <Id, Case> newCasesMap) {
        List <Task> tasksToInsertList = new List <Task> ();
        try {
            for (Case c: newCasesMap.values()) {
                if (c.Origin != sf_Constants.ORIGIN_SOCIAL_MEDIA 
                        && UserInfo.getUserType() == 'Standard' && c.Priority != '98'
                        // WR 545 - CONDITION TO CREATE THE INITIAL TASK WHEN THE CASE IS CREATED FROM CHATBOT
                    || (c.chatType__c!=NULL && c.chatType__c.containsIgNoreCase('Chatbot'))) {
                    Task tsk = new Task();                  
                    User sysAdmin = sf_ContactUsHelperCtrl.getSysAdmin();
                    //5/27/15 commented out orikkers. Per Dave. Post Launch defect #3
                    //tsk.OwnerId = sysAdmin.Id;   // WEP Data owner                 
                    tsk.WhatId = c.Id; 
                    
                    if(c.ContactId != null) {
						tsk.WhoId = c.ContactId; 
                    }

                    tsk.Subject = 'Initial Case Creation';                    
                    tsk.Status = 'Completed';  
                    tsk.Priority = c.Priority;  
                    tsk.Contact_Method__c = c.Origin;
					tsk.Direction__c = c.Direction__c;
                    tsk.ActivityDate = System.today();
                    tsk.Description = c.Summary__c; 
                    tsk.RecordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get(sf_Constants.TASK_CUSTOMER_ACTIVITY_RECORDTYPENAME).getRecordTypeId();                  

                    tasksToInsertList.add(tsk);
                } else {
                    //other cases handled through respective classes.
                }
            }

            insert tasksToInsertList;   
        } catch (Exception e) {
            System.debug('createInternalActivitiesForNewCases error: ' + e);
        }
    }
    
    /**
    *
    *   @author: asethuraman@salesforce.com
    *   @date: 09/04/2014
    *   @description: US676 TRigger MCAR and assign the case to a queue if 'reassign case' flag is true
    *   Once assigned, uncheck the flag.
    *   
    */
    public static void triggerCaseAssignmentRulesForReassignedCases (Map <Id, Case> newCasesMap) {
      
       List<Case> casesToUpdate = new List<Case>();  
       for (Case caseRec: newCasesMap.values()) {
        
         if ( caseRec.reassign_Case__c) {
             
             Metadata_Case_Assignment_Rule__c caseAssignmentRule = sf_CaseAssignmentRuleUtility.getMCARRecord(
                caseRec.Brand__c, caseRec.language__c, caseRec.country__c, caseRec.priority, caseRec.Status, caseRec.Contact_Email__c, 
                caseRec.Origin, //CDOY WR114 - Add case origin to MCAR Rules
                caseRec.Reason_For_Writing_Number__c); 
                
             caseRec.OwnerId = sf_CaseAssignmentRuleUtility.getQueueIdByName(caseAssignmentRule.Queue_Name__c);
             
             caseRec.RecordTypeId = sf_CaseAssignmentRuleUtility.getRecordTypeIdByName(sf_Constants.SOBJECTTYPE_CASE,caseAssignmentRule.Case_Record_Type_Name__c );
             caseRec.reassign_Case__c = false;
         }
       } 
    }
    
   /**
    * @author: Jason Clark
    * @date: 09/05/2014
    *
    * @description: for US765, update Region and SMO on updates to Country
    * 
    * @Update: WR 87 christopher.macduff@accenture.com
    * Using this method to also set Case currency - saving adding any more
    * logic...
    */
    public static void updateRegionSMO(list<Case> newCases, map<id, Case> oldCaseMap) {
        map<string, Country_Region_SMO__c> regions = Country_Region_SMO__c.getAll();
        for(Case c : newCases) {
            // if inserting (oldCaseMap is null) or if updating and country has changed
            if(oldCaseMap == null || oldCaseMap.get(c.id).Country__c != c.Country__c) {
                if(regions.containsKey(c.Country__c) || regions.containsKey(c.Country__c.toUpperCase())) {
                    Country_Region_SMO__c region = regions.containsKey(c.Country__c) ? regions.get(c.Country__c) : regions.get(c.Country__c.toUpperCase());
                    c.Region__c = region.Region__c;
                    c.SMO__c = region.SMO__c;
                    //Christopher.macduff@accenture.com - multi currency support WR87
                    c.Currency__c = region.Currency_ISO_Code__c;
                }
                else {
                    c.Region__c = null;
                    c.SMO__c = null;
					//Christopher.macduff@accenture.com - multi currency support WR87
                    c.Currency__c = null;
                }
            }
        }
    }
    
    
   /**
    * @author: Lauren OMeara
    * @date: 09/08/2014
    *
    * @description: for fulfillment, set the contact center on case from user's configured contact center
    */
    public static void setCaseContactCenter(list<Case> newCases, map<id, Case> oldCaseMap) {
        Set<ID> ownerIds = new set<ID>();
        Set<ID> contactCenterCaseId = new Set<ID>();
    
        for(Case c : newCases) { 

            //US769
            if (oldCaseMap == null) { //new case
                c.Creator_Language__c = UserInfo.getLocale();
            }

            String oId = String.valueOf(c.OwnerId);
    
            if(((oldCaseMap == null) && oId.startsWith('005')) || // insert
               ((oldCaseMap != null)&& oldCaseMap.get(c.ID).OwnerId <> c.OwnerId && oId.startsWith('005'))) // update
            {
                contactCentercaseId.add(c.Id);
                ownerIds.add(c.OwnerId);
            }
        }  
        
        if(ownerIds.size()>0)
        {
            Map<ID, User> userMap = new Map<ID,User>([Select ID, Contact_Center__c from User where Id in :ownerIds]);
            for(Case c : newCases) {  
                if(userMap.size() <> 0 && userMap.get(c.ownerID) <> null && contactCenterCaseId.size() <> 0 && contactCenterCaseId.contains(c.Id) )
                {
                    system.debug('test '+ userMap.get(c.ownerId).contact_Center__c);
                    //NOTE don't know why this was Contact_Center_Dummy__c
                    c.Contact_Center__c = userMap.get(c.ownerId).contact_Center__c;
                }
            }
        }
    }

    /**
    *@author: Ian Barker
    *@date: 11/11/2015
    *@description: Updates SAS Medical QR Status to Case Medical QR Status if Case field meets criteria
    **/

    public static void UpdateSASBasedOnCase(Map<Id, Case> newCases){
        List <Case> CasesToQuery = new List <Case>();
        //List <Safety_Assessment_Survey__c> 
        for (Case c: newCases.values()){
            if(c.Medical_QR_Status__c == 'Unwilling to Complete' || c.Medical_QR_Status__c == 'Sent by consumer but not received' || c.Medical_QR_Status__c == 'Unable to Re-contact Consumer'){
                CasesToQuery.add(c);
            }
        }
        List <Safety_Assessment_Survey__c> SASToUpdate = [SELECT Id, Name, Medical_QR_Status__c, Case__c FROM Safety_Assessment_Survey__c WHERE Case__c in :CasesToQuery];
        if(!SASToUpdate.isEmpty()){
            for (Case c: CasesToQuery){
                for (Safety_Assessment_Survey__c s: SASToUpdate){
                    if (s.Case__c == c.Id){
                        if (CaseMedStatNeedsUpdate(s.Medical_QR_Status__c, c.Medical_QR_Status__c)){
                            s.Medical_QR_Status__c = c.Medical_QR_Status__c;
                        }
                    }
                }
            }
        }
        update SASToUpdate;
    }

    private static Boolean CaseMedStatNeedsUpdate(String SASField, String CaseField){
        Boolean answer = FALSE;
        Map<String, Integer> StatusOrder = new Map<String, Integer>();
        StatusOrder.put('', 0);
        StatusOrder.put('Questionnaire Requested - Attempt 1', 1);
        StatusOrder.put('Questionnaire Requested - Attempt 2', 2);
        StatusOrder.put('Questionnaire Requested - Attempt 3', 3);
        StatusOrder.put('Unwilling to Complete', 4);
        StatusOrder.put('Sent by consumer but not received', 5);
        StatusOrder.put('Unable to Re-contact Consumer', 6);
        StatusOrder.put('Questionnaire Received', 7);

        //debug StatusOrder.get(SASField) && StatusOrder.get(CaseField)
        if(CaseField == NULL){
            answer = FALSE;
        } else if (SASField == NULL){
            answer = TRUE;
        } else if (StatusOrder.get(CaseField) > StatusOrder.get(SASField)){
            answer = TRUE;
        } else {
            answer = FALSE;
        }
        return answer;
    }
    
	/**
    *@author: Christopher.macduff@accenture.com
    *@date: 24/03/2016
    *@description: Updates Case Products Status if Case Product Return Reminder Status meets criteria
	*@WR: 249
    **/

    public static void updateCPBasedonCase(List<Case> newCases,Map<Id,Case> oldMap){
        List<Case> cpCases = new List<Case>(); //Cases to query for CPs
        List<Case_Product__c> cpsToUpdate = new List<Case_Product__c>();//Holds Case Product records to update
        Set<String> statusValues = new Set<String>{'Consumer has sent','Product Received','No - Consumer unwilling to return','No - Product discarded/unavailable','Photo Received','Photo - Final Attempt'}; //PRR Statuses that require CP update

        //If Case PRR field is changed and is a status that requires CP update
        for(Case c : newCases){
            Case oldCase = oldMap.get(c.Id);
            if(oldCase.Product_Return_Status__c != c.Product_Return_Status__c && statusValues.contains(c.Product_Return_Status__c)){
                system.debug('>>> Cases status has changed and CPs need updating: '+c.CaseNumber);
                cpCases.add(c);
            }
        }
        
        //Only do this query if at least one Case record
        if(!cpCases.isEmpty()){
            cpsToUpdate = [SELECT Id, Name, Status__c, Case__r.Product_Return_Status__c
                           FROM Case_Product__c
                           WHERE Case__c IN : cpCases
                           AND (Status__c != 'Product Received' OR Status__c != 'Photo Received') //Only update those which have been requested and not already received
                          ];
            system.debug('>>> CPs requiring update: '+cpsToUpdate.size());
        }

        if(!cpsToUpdate.isEmpty()){
            for(Case_Product__c cp : cpsToUpdate){
                system.debug('>>> Case status: '+cp.Case__r.Product_Return_Status__c+' : '+cp.Name+' : '+cp.Status__c);
                if(!String.isBlank(cp.Status__c)){//Only update those which have been requested and not already received
					cp.Status__c = cp.Case__r.Product_Return_Status__c;
                }
            }

		update cpsToUpdate;
        }
    }

	/**
    *@author: Christopher.macduff@accenture.com
    *@date: 15/02/2016
    *@description: Sets recordType and Country on Case reassignment to a Queue
	*Reuses existing QueueRecordType__c Custom Setting which has RecordType Id has name of setting
	*@WR: 166
    **/
    public static void setCaseRecordType(List<Case> newCases,Map<Id,Case> oldMap){
        system.debug('!!! in caseHelper.setCaseRecordType');
        List<Case> casesToUpdate = new List<Case>();
        String keyPrefix; //CDOY MCAR Clean Up

        //Check if ownership has changed and new owner is a queue
		for(Case c : newCases){
		    
			Case oldCase = oldMap.get(c.Id);
			if (c.OwnerId == null){ //CDOY MCAR Clean Up
			    c.OwnerId = sf_CaseAssignmentRuleUtility.getQueueIdByName(sf_Constants.DEFAULT_QUEUE_NAME); //CDOY MCAR Clean Up
			} //CDOY MCAR Clean Up
		    keyPrefix = c.OwnerId; //CDOY MCAR Clean Up
            system.debug('!!! old Case OwnerId: '+oldCase.OwnerId+' new Case OwnerId: '+c.OwnerId);
            system.debug('XXX case loop recordType Id: '+c.recordTypeId);
            //00G = Queue : http://help.salesforce.com/apex/HTViewSolution?id=000005995&language=en_US
			if(c.OwnerId != oldCase.OwnerId && keyPrefix.StartsWith('00G')){ 
				casesToUpdate.add(c);
			}
        }

        //Only do further processing if any Case/s need updating
        if(casesToUpdate.size() > 0){
            //Get QueueRecordType__c map
            
            Map<String, QueueRecordType__c> qrtMap = QueueRecordType__c.getAll();

            for(Case cx : casesToUpdate){
                //Now find correct RecordType & Country to reassign to
                QueueRecordType__c qrt = qrtMap.get(cx.OwnerId);

                if(qrt != null && qrt.Case_Record_Type_Id__c != cx.RecordTypeId){

                    cx.RecordTypeId = qrt.Case_Record_Type_Id__c;
                    //Note: Some records currently use "All" - shouldn't set this value
                    //Otherwise sets Country and Language according to matching qrt
                    if(qrt.Country__c != 'All'){
                        
                        cx.Country__c = qrt.Country__c;
                        cx.Language__c = qrt.Language__c;
                    }
                    else{
                        //Clear values - Agent will need to set these to progress the Case
                        cx.Country__c = '';
                        cx.Language__c = '';
                    }
                }
                else{
                    system.debug(LoggingLevel.Info,'!!! no match found or no record type change required');
                }
            }
        }
    }

    public static void UpdateChatbotTranscript(list<Case> newCases, map<id, Case> oldCaseMap){

        List<String> casesForChatbot = new List<String>();
        for(Case c : newCases){
            if (c.Chatbot_Case_Id__c != null){
                casesForChatbot.add(c.Chatbot_Case_Id__c);
            }
        }

        if(casesForChatbot != null && !casesForChatbot.isEmpty()){

            Map<id, case> caseMap = new map<Id, case>([SELECT id, Chatbot_Transcript_for_Agent__c FROM case WHERE id IN : casesForChatbot]);
            
            for(case cb : newCases){
                cb.Chatbot_Transcript_for_Agent__c = caseMap.get(cb.Chatbot_Case_Id__c).Chatbot_Transcript_for_Agent__c;
                cb.Agent_Handoff__c = true;
                cb.Chatbot_Case_Id__c = null;
            }

            Database.delete(caseMap.values());
            Database.emptyRecycleBin(new List<Id>(caseMap.keySet()));
        }

        

    }

}