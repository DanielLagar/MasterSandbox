@isTest
private class sf_InternalActivityTriggerHandlerTest {
	
	@isTest static void test_method_one() {

		Case c = new Case ();
		insert c;

		Internal_Activity__c ia = new Internal_Activity__c ();
		ia.Reminder__c = true;
		ia.Reminder_Date__c = System.today();
		ia.Case__c = c.Id;
		insert ia;

		ia.Article_ID__c = 'test';
		ia.Type__c = sf_Constants.INTERNAL_ACTIVITY_TYPE_KNOWLEDGE_MISSING_INCOMPLETE_KNOWLEDGE;
		update ia;


		
	}


	@isTest static void test_method_two() {

		Case c = new Case ();
		insert c;

		Internal_Activity__c ia = new Internal_Activity__c ();
		ia.Reminder__c = true;
		ia.Reminder_Date__c = System.today();
		ia.Assessment_Close_Date__c =  System.today() + 20;
		ia.Assessment_Open_Date__c =  System.today() + 3;
		ia.Case__c = c.Id;
		insert ia;

		ia.Article_ID__c = 'test';
		ia.Assessment_Close_Date__c = System.today() + 30;
		ia.Type__c = sf_Constants.INTERNAL_ACTIVITY_TYPE_KNOWLEDGE_MISSING_INCOMPLETE_KNOWLEDGE;
		update ia;
	}

	
}