/*
* @author: Chris Southworth
* @date: 05/30/2014
* @description:  Batch process used to locate Contacts who have a bounced email, and then place a checkmark in the
*	Contact_s_Email_Bounced__c flag on related cases.  A workflow will update the cases to a queue.
*/
global class sf_BatchBouncedEmail implements Database.Batchable<sObject> {		
	public String query;

	global sf_BatchBouncedEmail() {
   		this.query = 'SELECT Id, EmailBouncedDate FROM Contact WHERE EmailBouncedDate != null';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		Set<Id> contactIds = new Set<Id>();
   		for(Contact c : (List<Contact>)scope){
   			contactIds.add(c.Id);
   		}

   		List<Case> updatedCases = new List<Case>();
   		for(Case c : [SELECT Id, ContactId, Contact_s_Email_Bounced__c FROM Case 
   			WHERE ContactId IN :contactIds AND Contact_s_Email_Bounced__c = false]){

   			c.Contact_s_Email_Bounced__c = true;
   			updatedCases.add(c);
   		}

   		if(!updatedCases.isEmpty()){
   			//update updatedCases;
            Database.SaveResult[] results = Database.Update(updatedCases, false);
   		}

   	}

	global void finish(Database.BatchableContext BC) {
		//nothing to do here, but method is required
	}

}