/**
*
*Controller for sf_ProductSearchConsoleComponent page
*
*@author    Chris Southworth
*@date      05/23/2014
*
*/

global class sf_ChecklistConsoleComponentCtrl {
    public String caseId {get; set;}
    public Case caseRecord {get; set;}
    //public Integer productComment {get; set;}//ChrisM May 2017 this is not used anymore? 
    public Boolean contactMandatory {get; set;}
    public Boolean addressMandatory {get; set;}
    public Boolean linkedContact {get; set;}
    public Boolean populatedAddress {get; set;}
    public Boolean closeCaseButtonEnabled {get; set;}
    public Boolean caseClosed {get; set;}

    //Survey tracking
    public Integer surveyCount {get; set;}
    public Integer surveyMax {get; set;}
    public Boolean surveysComplete {get; set;}
    public Boolean sasSurveysComplete {get; set;}
    public Integer sasSurveyCount {
        get {
            if (sasSurveyCount == null) {
                sasSurveyCount = [SELECT Id FROM Safety_Assessment_Survey__c WHERE Case__c = :caseId AND Metadata_Survey_Trigger__c != null].size();
            }

            return sasSurveyCount;
        }

        set;
    }

    public Integer sasCompletedSurveyCount {
        get {
            if (sasCompletedSurveyCount == null) {
                sasCompletedSurveyCount = [SELECT Id FROM Safety_Assessment_Survey__c WHERE Case__c = :caseId AND Survey_Completed__c = true AND Metadata_Survey_Trigger__c != null].size();
            }

            return sasCompletedSurveyCount;
        }

        set;
    }


    //US779 checklist item for production code verification
    public Integer prodCodeRequiredCount {
        get {
            return [SELECT Id FROM Case_Product__c 
                        WHERE Case__c = :caseId 
                        AND (Number_of_PQC_Comments__c > 0 OR Number_of_Adverse_Event_Comments__c > 0)].size();
        }

        private set;
    }

    public Integer prodCodeVerificationCompletedCount {
        get {
            return [SELECT Id FROM Case_Product__c 
                    WHERE Case__c = :caseId 
                    AND (Number_of_PQC_Comments__c > 0 OR Number_of_Adverse_Event_Comments__c > 0) 
                    AND (Production_Code__c != null OR Production_Code_Verification__c != null)].size();
        }

        private set;
    }

    public boolean productionCodesVerified {
        get {
            return prodCodeVerificationCompletedCount == prodCodeRequiredCount;
        }

        set;
    }

    //CR16 Do any products require a digital or physical return?
    public boolean returnTypeSet {get;set;}
    
    public list<Case_Product__c> returnCPS {
        get{
            //TODO: Historical with no ACR_Info__c?
            returnCPS = new List<Case_Product__c>();
            returnCPS = [SELECT Name, Consumer_Facing_Brand__c, Product_Path__c, ACR_Info__c, ACR_Return_Type__c, Case__r.Selected_Return_Type__c
                            FROM Case_Product__c
                            WHERE Case__c = :caseId 
                         	AND productstatus__c = 'Added'
                            AND ACR_Info__c != null
                            AND Product_available_for_return__c = 'Yes - Product is Available'
                        	AND ACR_Info__c != :getProductReturnACR.NO_MATCH];

            if(!returnCPS.isEmpty()){
                returnTypeSet = String.isNotBlank(returnCPS[0].Case__r.Selected_Return_Type__c);
            }
            else{
                returnTypeSet = false;
            }
            
            return returnCPS;
        }
        set;
    }


    //TODO: Historical with no ACR_Info__c?
    /*
    If a return is required AND
    Digital || Physical 
        Show "Please advise the consumer that we would like to retrieve the product: Digital and Physical available"
    Phyiscal
        Show "Please advise the consumer that we would like to retrieve the product: Only Physical available"

    */
    public String agentMessage{get;set;}
    public boolean returnRequired{
        get{
            Set<String> repeaterStatuses = new Set<String>();
            repeaterStatuses.add(trg_AutoComRuleHelper.CONTACT_REPEATER_STATUS_KNOWN);
            repeaterStatuses.add(trg_AutoComRuleHelper.CONTACT_REPEATER_STATUS_SUSPECTED);
            returnRequired = false;
            agentMessage = '';
            String caseContactRepeaterStatus = '';
            Set<String> returnTypes = new Set<String>();
            Integer digiCPCount = 0; //CP count where matching ACR supports digital
            Integer returnCPCount = 0; //CP count where available for return and with a matching ACR
            if(String.isNotBlank(caseId)){
                //Contact a repeater?
                if(!String.IsBlank(caseRecord.Contact.Repeater_Status__c)){
                    caseContactRepeaterStatus = caseRecord.Contact.Repeater_Status__c;
                }
                //Products for return? Digital support?
                for(Case_Product__c cp : [SELECT Name, ACR_Info__c, ACR_Return_Type__c FROM Case_Product__c WHERE Case__c = :caseRecord.Id AND Product_available_for_return__c = 'Yes - Product is available' AND Productstatus__c = 'Added']){
                    returnTypes.add(cp.ACR_Return_Type__c);
                    if(cp.ACR_Return_Type__c == 'Digital'){
                        digiCPCount ++;
                    }
                    if(String.isNotBlank(cp.ACR_Info__c)){
                        returnCPCount ++;
                    }
                }
                
                //START Debugs - to be removed before ACC
                system.debug(logginglevel.WARN, '!!!!!! returnCPCount: '+ returnCPCount);
                system.debug(logginglevel.WARN, '!!!!!! String.IsBlank(caseRecord.Selected_Return_Type__c): '+String.IsBlank(caseRecord.Selected_Return_Type__c));
                system.debug(logginglevel.WARN, '!!!!!! returnTypes '+returnTypes);
                system.debug(logginglevel.WARN, '!!!!!! caseRecord.Consumer_Wants_Follow_Up__c: '+caseRecord.Consumer_Wants_Follow_Up__c);
                system.debug(logginglevel.WARN, '!!!!!! caseRecord.High_Priority__c: '+caseRecord.High_Priority__c);
                system.debug(logginglevel.WARN, '!!!!!! digiCPCount: '+digiCPCount); 
                system.debug(logginglevel.WARN, '!!!!!! caseContactRepeaterStatus: '+caseContactRepeaterStatus);
                //FIN Debugs - to be removed before ACC
    
                //Digital or physical?
                if(
                returnCPCount > 0 &&
                String.IsBlank(caseRecord.Selected_Return_Type__c) &&
                (returnTypes.contains('Physical') || caseRecord.Consumer_Wants_Follow_Up__c || caseRecord.High_Priority__c || digiCPCount > 1
                ||
                repeaterStatuses.contains(caseContactRepeaterStatus))){//If repeater force physical
                    returnRequired = True;
                    agentMessage = system.label.AgentChecklist_physical;
                }
                else if(returnTypes.contains('Digital') && String.IsBlank(caseRecord.Selected_Return_Type__c)){
                    returnRequired = True;
                    agentMessage = system.label.AgentChecklist_dpr;
                }                
            }
            return returnRequired;
        }
        private set;
    }

    //Make Product available for return required. 6/1/15
    public Integer prodAvailForReturnRequiredCount {
        get {
            return [SELECT Id FROM Case_Product__c 
                    
                        WHERE Case__c = :caseId
                        AND (Number_of_PQC_Comments__c > 0 OR Number_of_Adverse_Event_Comments__c > 0) 
                        AND ProductStatus__c != 'Cancelled'].size();
        }

        private set;
    }

    public Integer prodAvailForReturnCompletedCount {
        get {
            return [SELECT Id FROM Case_Product__c 
                    WHERE Case__c = :caseId 
                    AND (Number_of_PQC_Comments__c > 0 OR Number_of_Adverse_Event_Comments__c > 0)  
                    AND ProductStatus__c != 'Cancelled'
                    AND Product_available_for_return__c != null].size();
        }

        private set;
    }

    public boolean prodAvailForReturnVerified {
        get {
            return prodAvailForReturnRequiredCount == prodAvailForReturnCompletedCount;
        }

        set;
    }

    //Make at least one comment code required. 6/1/15
    public Integer commentCodeRequiredCount {
        get {
            return [SELECT Id FROM Case_Product__c 
                        WHERE Case__c = :caseId
                        AND ProductStatus__c != 'Cancelled' AND CreatedBy.Profile.Name != :sf_Constants.INTEGRATION_USER_PROFILE_NAME].size();
        }

        private set;
    }

    public Integer commentCodeCompletedCount {
        get {
            return [SELECT Id FROM Case_Product__c 
                    WHERE Case__c = :caseId 
                    AND ProductStatus__c != 'Cancelled'
                    AND Number_of_Comment_Codes__c>0 AND CreatedBy.Profile.Name != :sf_Constants.INTEGRATION_USER_PROFILE_NAME].size();
        }

        private set;
    }

    public boolean commentCodeEnteredVerified {
        get {
            return commentCodeRequiredCount == commentCodeCompletedCount;
        }

        set;
    }
    
    // Cas: removed 1/29/15 no longer want to have agents wait for the PDF to generate
    // Fulfillment 
    /*public Boolean pdfsNeeded {get;set;}
    public Integer countPdfsNeeded {
        get {
            return [SELECT Id FROM Fulfillment_Order__c 
                    WHERE Case__c = :caseId 
                    AND Status__c = 'Open' 
                    AND PDF_Generated__c = false
                    AND No_Letter_Needed__c = false].size();
        }

        private set;
    }
    public Integer countPdfsTotal {
        get {
            return [SELECT Id FROM Fulfillment_Order__c 
                    WHERE Case__c = :caseId
                    AND Status__c = 'Open'
                    AND No_Letter_Needed__c = false].size();
        }

        private set;
    }
    public Integer countPdfsCompleted {
        get {
            return countPdfsTotal - countPdfsNeeded;
        }
        private set;
    }*/

    public sf_ChecklistConsoleComponentCtrl(ApexPages.StandardController sc) {
        system.debug(logginglevel.WARN, '****************** CTR INIT ******************');
        //Grab case id and case fields
        caseId = sc.getId();

        //default page variables
        contactMandatory = false;
        addressMandatory = false;
        linkedContact = false;
        populatedAddress = false;
        closeCaseButtonEnabled = false;
        caseClosed = false;
        // Cas: removed 1/29/15 no longer want to have agents wait for the PDF to generate
        //pdfsNeeded = false;
        
        //default survey variables
        surveyCount = 0;
        surveyMax = 0;
        surveysComplete = false;
        sasSurveysComplete = false;

        if(caseId != null){
            caseRecord = [SELECT Id, ContactId, Contact.Primary_Address_Line_1__c, Contact.Primary_City__c, 
                            Contact.Primary_Country__c, Contact.Primary_Postal_Code__c, Contact.Primary_State_Province__c, Contact.Repeater_Status__c,
                            Status, Consumer_declined_to_share_Contact_Info__c, Consumer_declined_to_share_Address__c,
                            Number_of_Adverse_Event__c, Number_of_PQC_Comments__c, CCM_Initial_Pull__c, isClosed, Not_Handled_Reason__c,
                            Case_Products__c, Case_Comment_Code__c, ClosedDate, Closed_Date__c, Product_Return_Status__c,Initial_Case_Submission_By__c,
							Selected_Return_Type__c, Consumer_Wants_Follow_Up__c, High_Priority__c
                            FROM Case WHERE Id =:caseId LIMIT 1];

            //TODO: ChrisM May 2017 this is not used anymore?                
            /*productComment = [SELECT Count() FROM Case_Product__c 
                              WHERE Case__c = :caseId 
                              AND (Number_of_PQC_Comments__c > 0 OR Number_of_Adverse_Event_Comments__c > 0)  
                              AND ProductStatus__c != 'Cancelled'
                              AND Product_available_for_return__c = 'Yes - Product is Available'];*/

            //If the case is closed disable checkboxes on vf page
            checkCaseStatus();

            //Check for linked contact record.  If record is found uncheck the override flag.
            checkLinkedContact();
            //Check for populated address on contact record.
            checkAddress();

            //Query to see if we have any comment codes with AE or PQC types, flag contact as mandatory if found.
            checkForMandatoryItems();
            
            checkSurveyProgress();
            
            // Cas: removed 1/29/15 no longer want to have agents wait for the PDF to generate
            //checkFulfillmentOrders();

            //If case is open check if we need to enable close button
            checkCloseButtonStatus();
        }
    }
    
    
   /**
    * @author: Chris Southworth, Oleg Rikkers (Portions taken from sf_CaseSurveyProbingQuestionsCtrl)
    * @date: 06/30/2014
    * @param: None
    * @description: Check for questions on surveys
    * @return: void
    */
    public void checkSurveyProgress(){

        //10-13-14 orikkers - adding survey count back by popular request


        List<Survey__c> surveys = [SELECT Id, Survey_Fieldset__c, Has_Data__c, Survey_Type__c, Status__c FROM Survey__c WHERE Case__c = :caseRecord.Id LIMIT 1];
        List <Survey__c> completedSurvey  = [SELECT Id, Survey_Fieldset__c, Has_Data__c, Survey_Type__c FROM Survey__c WHERE Case__c =:caseId AND Status__c = 'Complete'];

        surveyMax = surveys.size();

        if (surveyMax > 0) {
            if (completedSurvey.size() > 0) surveyCount = 1;
        }
        
        //Check Safety Assessment Survey's to see if all are completed.
        if(sasCompletedSurveyCount >= sasSurveyCount && sasSurveyCount > 0){
            sasSurveysComplete = true;  
        }

        if (surveyMax == 1 && surveyCount == 1)
            surveysComplete = true;
    }
    
   /**
    * @author: Chris Southworth
    * @date: 05/27/2014
    * @param: None
    * @description: A method that sets the caseClosed flag to tell the VF page whether to let the user modify override 
    *  checkboxes. 
    * @return: void
    */
    public void checkCaseStatus(){
        if(caseRecord.Status == 'Closed' || caseRecord.Status == 'Closed and Locked'){
            caseClosed = true;
        } else {
            caseClosed = false;
        }
    }
    

   /**
    * @author: Chris Southworth
    * @date: 05/27/2014
    * @param: None
    * @description: A method that determines if the contact checkboxes should be checked or not.  If the override checkbox
    *   is selected, then the 'Add Contact to Case' checkbox should become checked as well.
    * @return: void
    */
    public void checkLinkedContact(){
        if(caseRecord.ContactId != null){
            linkedContact = true;
            caseRecord.Consumer_declined_to_share_Contact_Info__c = false;
        } else {
            //If no record is found uncheck the 'Add Contact to case' box on the checklist, unless the override is selected.
            linkedContact = false;
            //if the override box is selected check the 'Add Contact to case' checkbox
            if(caseRecord.Consumer_declined_to_share_Contact_Info__c){
                linkedContact = true;
            }
        }
    }

   /**
    * @author: Chris Southworth
    * @date: 05/28/2014
    * @param: None
    * @description: A method that determines if the contact checkboxes should be checked or not.  If the override checkbox
    *   is selected, then the 'Add Contact to Case' checkbox should become checked as well.
    * @return: void
    */
    public void checkAddress(){
        System.debug('***Contact: ' + caseRecord.Contact);
        if(caseRecord.ContactId != null){
            /*Pre WR120
            if(caseRecord.Contact.Primary_Address_Line_1__c != null && caseRecord.Contact.Primary_City__c != null
                && caseRecord.Contact.Primary_State_Province__c != null && caseRecord.Contact.Primary_Postal_Code__c != null
                && caseRecord.Contact.Primary_Country__c != null){
                populatedAddress = true;
                caseRecord.Consumer_declined_to_share_Address__c = false;
            } else {*/
            
            /*Post WR120 Scenarios
             1. If both state/postcode required check all fields have a value
			 2. If state required only all fields except postcode must have a value
			 3. If postcode required only all fields except state must have a value
			 4. If neither state/postcode are required only Address Line 1, City, Country must have a value
			*/
            Country_Status__c countrystatus = Country_Status__c.getInstance(caseRecord.Contact.Primary_Country__c);  
            if(countrystatus == null){ //If none found assume both postcode and state are required
                countrystatus = new Country_Status__c(
                    Uses_Postal_Codes__c = True,
                    Uses_States__c = True
                );    
            }
            //Scenario 1
            if(countrystatus.Uses_Postal_Codes__c && countrystatus.Uses_States__c
				&& caseRecord.Contact.Primary_Address_Line_1__c != null && caseRecord.Contact.Primary_City__c != null
				&& caseRecord.Contact.Primary_State_Province__c != null && caseRecord.Contact.Primary_Postal_Code__c != null
                && caseRecord.Contact.Primary_Country__c != null){
                populatedAddress = true;
                caseRecord.Consumer_declined_to_share_Address__c = false;
            }
            //Scenario 2
            else if(!countrystatus.Uses_Postal_Codes__c && countrystatus.Uses_States__c
				&& caseRecord.Contact.Primary_Address_Line_1__c != null && caseRecord.Contact.Primary_City__c != null
				&& caseRecord.Contact.Primary_State_Province__c != null && caseRecord.Contact.Primary_Country__c != null){
                populatedAddress = true;
                caseRecord.Consumer_declined_to_share_Address__c = false;
            }
			//Scenario 3
            else if(countrystatus.Uses_Postal_Codes__c && !countrystatus.Uses_States__c
				&& caseRecord.Contact.Primary_Address_Line_1__c != null && caseRecord.Contact.Primary_City__c != null
				&& caseRecord.Contact.Primary_Postal_Code__c != null && caseRecord.Contact.Primary_Country__c != null){
                populatedAddress = true;
                caseRecord.Consumer_declined_to_share_Address__c = false;
            }
            //Scenario 4
            else if(!countrystatus.Uses_Postal_Codes__c && !countrystatus.Uses_States__c
				&& caseRecord.Contact.Primary_Address_Line_1__c != null && caseRecord.Contact.Primary_City__c != null
                && caseRecord.Contact.Primary_Country__c != null){
                populatedAddress = true;
                caseRecord.Consumer_declined_to_share_Address__c = false;
            }            
            //And finally...
            else {				  
                populatedAddress = false;
                if(caseRecord.Consumer_declined_to_share_Address__c){
                    populatedAddress = true;
                }
            }
        }else {
            populatedAddress = false;
            if(caseRecord.Consumer_declined_to_share_Address__c){
                populatedAddress = true;
            }
        }
    }

   /**
    * @author: Chris Southworth
    * @date: 05/27/2014
    * @param: None
    * @description: A method that determines if there are mandatory items that need to be populated by the agent. 
    *   contactMandatory is set to true if the case field Number_of_Adverse_Event__c or Number_of_PQC_Comments__c is more than 0
    *   addressMandatory is set to true if the case field Number_of_Adverse_Event__c or Number_of_PQC_Comments__c is more than 0
    * @return: void
    */
    public void checkForMandatoryItems(){
        contactMandatory = false;
        addressMandatory = false;

        if(caseRecord.Number_of_Adverse_Event__c != 0 || caseRecord.Number_of_PQC_Comments__c != 0){
            contactMandatory = true;
            addressMandatory = true;
        }
    }

   /**
    * @author: Chris Southworth
    * @date: 05/23/2014
    * @param: None
    * @description: A method that determines if the close button on the page should be enabled or disabled.  This is determined by
    *   checking to make sure all required information is on the record.  If not the button is disabled.
    * @return: void
    */
    public void checkCloseButtonStatus(){
        closeCaseButtonEnabled = true;
        if(!caseRecord.Status.toLowerCase().contains('close')){
            if(contactMandatory){
                if(!linkedContact){
                    closeCaseButtonEnabled = false;
                }
            }
            if(addressMandatory){
                if(!populatedAddress){
                    closeCaseButtonEnabled = false;
                }
            }
            if(!surveysComplete && surveyMax > 0){
                closeCaseButtonEnabled = false;
            }

            if(sasSurveyCount != sasCompletedSurveyCount){
                closeCaseButtonEnabled = false;
            }

            if(!productionCodesVerified) closeCaseButtonEnabled = false;

            if(caseRecord.Not_Handled_Reason__c == null
                    && caseRecord.Case_Comment_Code__c == 0) {

                closeCaseButtonEnabled = false;
            }

            if(!prodAvailForReturnVerified) {
                closeCaseButtonEnabled = false;
            }

            if(!commentCodeEnteredVerified){
                closeCaseButtonEnabled = false;
            }

            //Return required - has return type been set?
            //Allow case to be saved if consumer declined and no return type set
            if(!returnCPS.isEmpty() && !returnTypeSet && !caseRecord.Consumer_declined_to_share_Contact_Info__c){
                closeCaseButtonEnabled = false;
            }
            

            // Cas: removed 1/29/15 no longer want to have agents wait for the PDF to generate
            /*if (pdfsNeeded){
                closeCaseButtonEnabled = false;
            }*/

        } else {
            closeCaseButtonEnabled = false;
        }
    }

   /**
    * @author: Chris Southworth
    * @date: 05/23/2014
    * @param: None
    * @description: A method that is initiated from the visual force page when the contact override checkbox is selected.
    *   This is used to update the 'Add Contact to Case' checkbox to checked on the page, and updates whether the close
    *   date is enabled or disabled based on the change.
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference contactOverrideChanged(){
        if(contactMandatory && caseRecord.Consumer_declined_to_share_Contact_Info__c){
            linkedContact = true;
        } else {
            linkedContact = false;
        }
        update caseRecord;
        checkCloseButtonStatus();

        return null;
    }

   /**
    * @author: Chris Southworth
    * @date: 05/28/2014
    * @param: None
    * @description: A method that is initiated from the visual force page when the address override checkbox is selected.
    *   This is used to update the 'Populate Address on Contact' checkbox to checked on the page, and updates whether the close
    *   date is enabled or disabled based on the change.
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference addressOverrideChanged(){
        if(addressMandatory && caseRecord.Consumer_declined_to_share_Address__c){
            populatedAddress = true;
        } else {
            populatedAddress = false;
        }
        update caseRecord;
        checkCloseButtonStatus();

        return null;
    }

    /****************************************************************
        Is a return required? No move to closeCase()                *
        Yes confirm Case.Selected_Return_Type__c has a value set    *
        DO NOT WANT - replacd with another checklist item           *
    /***************************************************************/
    /*@RemoteAction
    global static boolean returnTypeRequiredandSet(String caseId){
        system.debug(logginglevel.WARN, '!!!!!! in returnTypeRequiredandSet');
        Case currentCase = [SELECT Id, Selected_Return_Type__c FROM Case WHERE Id = :caseId];
        Integer returnCPCount = [SELECT COUNT() FROM Case_Product__c WHERE Case__c = :caseId AND ACR_Info__c != null AND Product_available_for_return__c = 'Yes - Product is Available'];
        if(returnCPCount > 0 && String.IsBlank(currentCase.Selected_Return_Type__c)){
            system.debug(logginglevel.WARN, '!!!!!! in returnTypeRequiredandSet returning false');
            return false;
        }
        else{
            system.debug(logginglevel.WARN, '!!!!!! in returnTypeRequiredandSet returning true');
            return true;
        }

    }*/
    
    /**
    * @author: Chris Southworth
    * @date: 05/23/2014
    * @param: None
    * @description: A method that closes that is activated from the visual force page and closes the case.
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference closeCase(){
        if(closeCaseButtonEnabled == true){
            try{
                system.debug('>>> in checklist closeCase. caseRecord: '+caseRecord);
                caseRecord.Status = 'Closed';
                // Removed and replaced with a WF Rule
                // if(caseRecord.Closed_Date__c == null){
                //  caseRecord.Closed_Date__c = System.now();
                //}
                //orikkers - always set ccm pull date 3/20/15
                //List<Case_Comment_Code__c> codes = [select id from Case_Comment_Code__c where Case__c = :caseRecord.Id and (GCC_Level_1__c = :sf_Constants.COMMENT_CODE_TYPE_AE OR GCC_Level_1__c = :sf_Constants.COMMENT_CODE_TYPE_PQC)];
                //if(caseRecord.Number_of_Adverse_Event__c != 0 || caseRecord.Number_of_PQC_Comments__c != 0){
                //if (codes.size() > 0){
                //  if(caseRecord.CCM_Initial_Pull__c == null){
                        //caseRecord.CCM_Initial_Pull__c = System.now();
                //  }
                    //caseRecord.Sent_to_CCM__c = true; //@todo remove? no longer needed?
                //}



                //7-23-2015 US65 post go live - SFDC
                Global_Org_Settings__c orgSettings = Global_Org_Settings__c.getInstance();
                orgSettings = orgSettings == null ? new Global_Org_Settings__c (CCM_Retreival_Delay_Minutes__c = 0.0) : orgSettings;
                Integer ccmPullDelayInMinutes = (Integer) orgSettings.CCM_Retreival_Delay_Minutes__c;
                ccmPullDelayInMinutes = ccmPullDelayInMinutes == null || ccmPullDelayInMinutes < 0 ? 0 : ccmPullDelayInMinutes;
                Datetime currentTime = System.now();
                caseRecord.CCM_Initial_Pull__c = caseRecord.CCM_Initial_Pull__c == null ? currentTime.addMinutes(ccmPullDelayInMinutes) : caseRecord.CCM_Initial_Pull__c;
                caseRecord.CCM_Initial_Pull__c = caseRecord.CCM_Initial_Pull__c > currentTime ? caseRecord.CCM_Initial_Pull__c : currentTime;
                //added 10/5/2015 by Ian Barker
                //if (caseRecord.Initial_Case_Submission_By__c == NULL && caseRecord.ClosedDate == NULL && caseRecord.Closed_Date__c == NULL){
                if (caseRecord.ClosedDate != NULL || caseRecord.Closed_Date__c != NULL){
                }else{
                    caseRecord.Initial_Case_Submission_By__c = UserInfo.getName();
                    String id = UserInfo.getUserId();
                    List<User> templist = [SELECT Id, Location__c FROM User WHERE Id = :id];
                    //best practices. Because if templist.size is zero, all sorts of things would break.
                    if(templist.size() != 0){
                        caseRecord.Initial_Case_Submission_By_Location__c = templist[0].Location__c;
                    }
                }
                

                caseRecord.Sent_to_CCM__c = true;
                
                //START CR16 - future method
                //Calls digi ACR process plus updates Case Products
                Set<Id> caseIds = new Set<Id>();
                caseIds.add(caseRecord.Id);
                digiReturnsHelper.digiReturnFirstAttempt(caseIds);
                //FIN CR16

                update caseRecord;
            } catch(Exception e){
                caseClosed = false;
                System.enqueueJob(new exceptionHelperQueable(e,'Checklist - error on closing Case: '+String.ValueOf(caseRecord)));
                ApexPages.addMessages (e);
                System.debug('***ERROR 1: ' + e);
                System.debug('***ERROR 2: ' + e.getStackTraceString());
                System.debug('***ERROR 3: ' + e.getLineNumber());
            }
        }
        return null;
    }

    //orikkers - added a reopen button 3/20/15
    public PageReference openCase () {
        caseRecord.Status = 'Reopened by User';
        update caseRecord;
        return null;
    }
    
    @RemoteAction
    global static Boolean verifyCaseStatus(String caseId){
        try{ 
            Case c = [SELECT Id, isClosed FROM Case WHERE Id = :caseId];
            return c.isClosed;
        } catch(Exception e){
            return true; //Record was not found and thus has been closed and access isn't available for the user
        }
    }
    
    // Cas: removed 1/29/15 no longer want to have agents wait for the PDF to generate
    /**
    * @author: John Casimiro
    * @date: 01/20/2015
    * @param: None
    * @description: A method that determines if the fulfillment orders are complete in order to submit a case. Incomplete Orders should prevent closure of a Case.
    * @return: void
    */
    /*public void checkFulfillmentOrders(){
        if(countPdfsNeeded > 0)
            pdfsNeeded = true;
        else 
            pdfsNeeded = false;
            
    }*/
    
}