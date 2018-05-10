public class d2p_consoleComp_ext {

    public case currentCase {get;set;}//The Current Case
    public List<cpWrapper> cpList {get;set;}//The ACR matching CPs to display
    public String caseId {get; set;}

    public d2p_consoleComp_ext(ApexPages.StandardController stdctr){
        currentCase = (case)stdctr.getRecord(); //for use with button on Case layout 
    }
    
	/*
	* @description: A method that grabs the case fields based on the caseId sent from the VF page as part of an action function
	* @return: PageReference is returned NULL to stay on page
	*/
    public PageReference setCaseId(){
        system.debug('>>> setCaseId : '+caseId);
    	if(caseId != null && !String.isBlank(caseId)){
    		currentCase = [SELECT Id, CaseNumber, Product_Return_Status__c, ContactId FROM Case WHERE Id =:caseId];
    	}
    	return null;
    }
    
    //Method to find/build ACR matching Case Products to display
    public List<cpWrapper> getACRCaseProducts(){
		cpList = new List<cpWrapper>();
        system.debug('>>> in getACRCaseProducts : '+currentCase);
		for(Case_Product__c cp : [SELECT Id, Name, ACR_Info__c, Status__c, Product_Path__c FROM Case_Product__c WHERE Case__c = :currentCase.Id AND ACR_Info__c != null]){
			if(trg_AutoComRuleHelper.digitalProductReturnStatuses.contains(cp.Status__c) || trg_AutoComRuleHelper.physicalProductReturnStatuses.contains(cp.Status__c)){
				cpWrapper cpw = new cpWrapper(cp, True, True);
				cpList.add(cpw);
			}
			else{
				cpWrapper cpw = new cpWrapper(cp, false, false);
				cpList.add(cpw);
			}
		}

        return cpList;
    }
    
    //Swap selected from Digital to Physical OR start Physical
    public void processSelected(){
        //send to ACR to action
        //Should only send Case Comment Codes associatated to selected CPs
        Set<Id> cpIds = new Set<Id>();
        for(cpWrapper cpw : cpList){
            if(cpw.selected){
                system.debug('!!! selected CP: '+cpw);
                cpIds.add(cpw.caseProduct.Id);
                //Clear current status
                cpw.caseProduct.status__c = '';
                
            }
        }
        if(cpIds.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.No_Product_s_Selected));
        }
        else{
            Map<Id, Case_Comment_Code__c> cccMap = new Map<Id,Case_Comment_Code__c>([SELECT Status__c, GCR_CID__c, Case_Contact_Id__c, Case__c, Case_Product__r.Product_available_for_return__c,
                                                                                     Case_Product__c, Global_Product_Segment__c, Product_Postal_Restriction__c, Global_Comment_Path__c, Global_Product_Path__c,
                                                                                     Product_Brand__c, Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c, Case_Product__r.ACR_Info__c
                                                                                     FROM Case_Comment_Code__C
                                                                                     WHERE Case__c = :currentCase.Id AND Case_Product__c IN :cpIds]);
            Map<Id, Case> caseMap = new Map<Id, Case>();
            
            currentCase.Product_Return_Status__c = '';
            currentCase.Selected_Return_Type__c = 'Physical';
            caseMap.put(currentCase.Id, currentCase);
            Map<Id, Contact> conMap = new Map<Id,Contact>([SELECT Id, Email, FirstName, LastName, Salutation, Repeater_Status__c FROM Contact WHERE Id = :currentCase.ContactId]);

            
            try{
                checkRecursive.ACREnabled = false;//prevent ACR firing on Case edit
                trg_AutoComRuleHelper.dprToPhysical(cccMap, caseMap, conMap);
                checkRecursive.ACREnabled = true;
            }
            catch(exception e){
                System.enqueueJob(new exceptionHelperQueable(e,'Error on converting Digital to Physical. CCCMap: '+String.ValueOf(cccMap)+' *CaseMap: '+String.ValueOf(caseMap)+' *ConMap: '+String.valueOf(conMap)));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Something went wrong - details: '+e.getMessage()+' : '+e.getStackTraceString()));
            }            
        }
    }
    
    //Wrapper for Case checklist and to provide selected CPs to process
    public class cpWrapper{
        public Case_Product__c caseProduct {get;set;}
        public Boolean selected {get;set;}//Selected by advisor
        public Boolean inprogress {get;set;}//Is in an in progress return process
        
        public cpWrapper(Case_Product__c cp, Boolean selectedCP, Boolean cpInProgress){
            caseProduct = cp;
            selected = selectedCP;
            inprogress = cpInProgress;
        }
    }
}