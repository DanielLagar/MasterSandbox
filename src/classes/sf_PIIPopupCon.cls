/*
* @author: original PG class
* @date: 08/19/2014
* @description: Test class for sf_PIIPopUpCon. Class migrated from Prod org
* DATE              NAME                CHANGE DESCRIPTION
* ...
* 19/06/2017    Acceture      WR508 - Chat Redsign: New attributes to the class to hold selected pii details
*/
global class sf_PIIPopupCon{
	public PIISitespageSettings__c piiobject { get;set; }
	public boolean displayInsert { get;set; }
	public case caseobj { get;set; }
    
	// WR508 - Chat/Pii Revamp : ADDITIONAL ATTRIBUTES
    public Boolean isName { get; set; }
    public Boolean isEmail { get; set; }
	public Boolean isPhone { get; set; }
    public Boolean isAddress { get; set; }
    public Boolean isValid { get; set; }
    
	public sf_PIIPopupCon(ApexPages.StandardController standcon) {
    	piiobject = new PIISitespageSettings__c();
    	displayInsert = true;
		// WR508 - Chat/Pii Revamp : DEFAULT TO NAME AND INITIALIZE MULTIPICKLIST
        isValid = false;
        isName = true;
      	isAddress = false;
        isPhone = false;
        isEmail = false;
          
        piiobject.Fields__c = 'FirstName; LastName;';
    	caseobj = (case) standcon.getRecord();
        // WR508 - Chat/Pii Revamp : ADDITIONAL FIELD 'Origin' QUERIED
        // WR574 - ADDITIONAL FIELD 'chat_key__c' QUERIED
    	caseobj = [ SELECT Id, ContactId,chat_key__c, AccountId, Origin FROM Case WHERE Id = :caseobj.Id ];
        if (caseobj.Origin == 'Chat' && String.isNotEmpty(caseObj.ContactId) ) {
      		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.msgPrechatExist));
            isName = false;
        }
        // WR508 - Chat/Pii Revamp : CHANGED DEFAULT TO NAME ONLY
		//initiate with few default fields
		//piiobject.Fields__c = 'FirstName; LastName;';// AddressLine1; AddressLine2; City; State; Country; Postal/ZipCode
  }
    
  //CR16 Do any products require a digital or physical return?
  //only ONE CP supporting digi
  public boolean dprAvailable{
    get{
      dprAvailable = false;
      Set<String> returnTypes = new Set<String>();
      AggregateResult[] results = [ SELECT ACR_Return_Type__c FROM Case_Product__c 
                                          WHERE Case__c = :caseobj.Id GROUP BY ACR_Return_Type__c];
      for (AggregateResult ar : results){
        returnTypes.add(String.valueOf(ar.get('ACR_Return_Type__c')));
      }
      if(returnTypes.contains('Physical')){
        dprAvailable = false;//If one CP is physical the whole Case becomes physical
      }
      else if(returnTypes.contains('Digital')){
                //How many CPs support digi and are available for return?
                Integer digiCPCount = [SELECT Count()
                                       FROM Case_Product__c
                                       WHERE Case__c = :caseobj.Id
                                       AND Product_available_for_return__c = 'Yes - Product is available'
                                       AND Productstatus__c = 'Added'
                                       AND ACR_Return_Type__c = 'Digital'
                                       AND Status__c = '' ];
                                        
                if(digiCPCount == 1){
                    dprAvailable = true;
                }
        
      }
      return dprAvailable;
    }
    private set;
  }
  // WR508 - Chat/Pii Revamp
    private void mapFieldData () {
        piiobject.Fields__c = '';
        piiobject.Fields__c += isName ? (String.isNotEmpty(piiobject.Fields__c) ? ';' : '') + 'FirstName;LastName' : '';
        piiobject.Fields__c += isAddress ? (String.isNotEmpty(piiobject.Fields__c) ? ';' : '') + 'AddressLine1; AddressLine2; City; State; Country; Postal/ZipCode' : '' ;
        piiobject.Fields__c += isEmail ? (String.isNotEmpty(piiobject.Fields__c) ? ';' : '') + 'Email' : '';
        piiobject.Fields__c += isPhone ? (String.isNotEmpty(piiobject.Fields__c) ? ';' : '') + 'Phone' : '';
    }
    
	public void save() {
        sf_SocialMediaUtility smUtil = new sf_SocialMediaUtility();
        // WR508 - Chat/Pii Revamp : MAP DATA TO MULTI SELECT FIELD
        mapFieldData();
        system.debug('0000 : ' +  piiobject.Fields__c);
        // WR508 - Chat/Pii Revamp : USE RETURN VALUE FROM VALIDATE METHOD
        //Validate input fields
        isValid = validateFields(caseobj.Id, piiobject.Include_DPR_Form__c, piiobject.Fields__c);
        if(!isValid) {
            // WR508 - Chat/Pii Revamp : THIS CONDITION TO CHECK IF PII IS SUBMITTED AGAIN FOR THS SAME OBJECT
            if (String.isEmpty(piiobject.Id)) {
        
                if(piiobject.Include_DPR_Form__c){
                    Case_Product__c dprCP = [ SELECT Id
                                                   , Digital_Return_Id__c
                                              FROM Case_Product__c
                                              WHERE Case__c = :caseobj.Id
                                                AND Product_available_for_return__c = 'Yes - Product is available'
                                                AND Productstatus__c = 'Added'
                                                AND ACR_Return_Type__c = 'Digital'
                                                AND Status__c = '' LIMIT 1 ];
                    
                    piiobject.DPR_UID__c = dprCP.Digital_Return_Id__c;
                }
                    
                system.debug('###### in SAVE ######');
                piiobject.IsActive__c = true;
                piiobject.Case_Id__c = caseobj.Id;
                insert piiobject;
                system.debug(piiobject);
    
                //create a closed activity in the case object
                smUtil.createTask('Consumer PII Request', 'Consumer PII Request', 'Social Media', 'Completed', 'Low', caseobj.Id
                                , sf_GlobalUtilityClass.TASK_INTERNAL_ACTIVITY_RT_ID, caseobj.contactId, null);
            } else {
                update piiobject;
            }
            //make it invisible
            displayInsert = caseobj.Origin != 'Chat' ? false : true;
            
            //retrieve full fields from the same object
            piiobject = [SELECT Id, Fields__c, Case_Id__c, PII_URL__c, Include_DPR_Form__c 
                         FROM PIISitespageSettings__c WHERE Id=:piiobject.Id];
		}
	}
    
    	/*
       * @author:         Accenture
       * @date:           03/10/2017
       * @description:    ADDED TO TOGGLE THE DISPLAYINSERT WHEN THERE IS NO CUSTOM EVENT HAPPENED TO THE CHAT CASES
       * @input:          NONE
       * @return:         NONE
       */
      public void toggleDisplayInsert(){
         displayInsert = false;
      }
  
	// WR508 - Chat/Pii Revamp : ADDED RETURN VALUE
	@RemoteAction
	global static Boolean validateFields(String caseId, Boolean includeDpr, String selectedFields) {
		Boolean retVal = false;
		//if the case is not associated with an account, then firstname, lastname and email are mandatory
		Case currentcase = [ SELECT AccountId FROM Case WHERE Id = :caseId ];
		if (currentcase.AccountId == NULL) {
			if (!selectedFields.contains('FirstName')) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ContactUs_EM_Firstname));
				retVal = true;
      		}
			if (!selectedFields.contains('LastName')) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ContactUs_EM_Lastname));
			retVal = true;
      		}
    	}
        
		// CR16 - If DPR selected email is mandatory
		// WR508 - Chat/Pii Revamp : REMOVED EMAIL CONDITION AS EMAIL IS ALWAYS MANDATORY NOW
		if (includeDpr && !selectedFields.contains('Email')) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.DPR_Email_Mandatory));
            retVal = true;
		}
        
        return retVal;
	}
}