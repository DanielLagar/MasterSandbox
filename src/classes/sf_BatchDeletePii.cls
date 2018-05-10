/*
* @author: John Casimiro
* @date: 02/13/2015
* @description:  Batch process used to update cases related to a contact if their PII information has been deleted.
*/
global class sf_BatchDeletePii implements Database.Batchable<sObject> {
	public String query;

	global sf_BatchDeletePii() {
   		this.query = 'Select Id, Update_Cases__c From Contact c where Update_Cases__c = true'; 
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Set<Id> contactIds = new Set<Id>();
		List<Contact> updatedContacts = new List<Contact>();
		for(Contact c : (List<Contact>)scope){
			c.Update_Cases__c = false;
			updatedContacts.add(c);
			contactIds.add(c.Id);
		}
		
		// should be 90 days. @todo move to custom setting. also change value in sf_contactInfoController.cls
		List<Case> updatedCases = [Select Id, Child_Last_Modified_Date__c From Case 
			WHERE ContactId IN :contactIds AND Status = 'Closed' and CreatedDate = LAST_N_DAYS:5];

      System.debug(LoggingLevel.INFO, 'sf_BatchDeletePii execute updatedCases : '  + updatedCases);

		if(!updatedCases.isEmpty()){
         Database.SaveResult[] results = Database.Update(updatedCases, false); //update last modified date
		}
		
		if(!updatedContacts.isEmpty()){
         Database.SaveResult[] results = Database.Update(updatedContacts, false); //update last modified date
		}

	}

	global void finish(Database.BatchableContext BC) {
		//nothing to do here, but method is required
      System.debug(LoggingLevel.INFO, 'sf_BatchDeletePii completed.');
	}
}