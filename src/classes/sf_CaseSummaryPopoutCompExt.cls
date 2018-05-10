global with sharing class sf_CaseSummaryPopoutCompExt {
	
	public Case caseRecord {get; set;}
	public String caseId {get; set;}

	public sf_CaseSummaryPopoutCompExt(ApexPages.StandardController sc) {
		caseRecord = (Case) sc.getRecord();
	}

	/*
	* @author: John Casimiro
	* @date: 05/09/2014
	* @param: unknownId - Id of the record currently selected in the service cloud console
	* @description: Returns the name of the sObject type based on the unknownId.
	* @return: String value of the sObject type
	*/
    @RemoteAction
    global static String checkObjectId(Id unknownId){
        Schema.SObjectType s =  unknownId.getSObjectType();
        return string.valueof(s);
    } 

    /*
	* @author: Chris Southworth
	* @date: 05/14/2014
	* @param: None
	* @description: A method that grabs the case fields based on the caseId sent from the VF page as part of an action function
	* @return: PageReference is returned NULL to stay on page
	*/
    public PageReference setCaseId(){
    	if(caseId != null && !String.isBlank(caseId)){
    		caseRecord = [SELECT Id, Summary__c, CaseNumber FROM Case WHERE Id =:caseId];
    	}
    	return null;
    }

    public void saveSummary() {
    	update caseRecord;
    }
}