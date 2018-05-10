@isTest
public class exceptionHelperQueable_Test {

	/********************************
	* String only test 				*
	********************************/
	private static testMethod void stringOnlyExceptionTest(){
		test.startTest();
			System.enqueueJob(new exceptionHelperQueable('String only exception test')); 
		test.stopTest();

		List<Exception__c> exceptionList = new List<Exception__c>([SELECT Id, Type__c, Further_Details__c FROM Exception__c]);
		system.assertEquals(1,exceptionList.size());
		system.assertEquals('String only exception test',exceptionList[0].Further_Details__c);
	}
    
	/********************************
	* Query exception test 			*
	********************************/
	private static testMethod void queryExceptionTest(){
		test.startTest();
			try{
				Contact c = [SELECT Id FROM Contact WHERE Name = 'No Contacts here today...'];
			}
			catch(exception e){
				System.enqueueJob(new exceptionHelperQueable(e,'query exception test'));
			}
			
		test.stopTest();

		List<Exception__c> exceptionList = new List<Exception__c>([SELECT Id, Type__c, Further_Details__c FROM Exception__c]);
		system.assertEquals(1,exceptionList.size());
		system.assertEquals('System.QueryException',exceptionList[0].Type__c);
		system.assertEquals('query exception test',exceptionList[0].Further_Details__c);

	}

	/********************************
	* Database.Query exception test	*
	********************************/
	private static testMethod void datbaseQueryExceptionTest(){
		test.startTest();
			String malformedQuery = 'SELECT Id FROM Case_Product__c WHERE Cheese';
			try{
				database.query(malformedQuery);
			}
			catch(exception e){
				System.enqueueJob(new exceptionHelperQueable(e,'database query exception test'));
			}
			
		test.stopTest();

		List<Exception__c> exceptionList = new List<Exception__c>([SELECT Id, Type__c, Further_Details__c FROM Exception__c]);
		system.assertEquals(1,exceptionList.size());
		system.assertEquals('System.QueryException',exceptionList[0].Type__c);
		system.assertEquals('database query exception test',exceptionList[0].Further_Details__c);
		
	}

	/********************************
	* Single DML exception test		*
	********************************/
	private static testMethod void singleDMLExceptionTest(){
		test.startTest();
			Contact con = new Contact(
	            firstName = 'No lastName = DML Exception...'
	        );
			try{
				insert con;
			}
			catch(exception e){
				system.enqueueJob(new exceptionHelperQueable(e,'single dml insert test'));
			}
		test.stopTest();

		List<Exception__c> exceptionList = new List<Exception__c>([SELECT Id, Type__c, Further_Details__c FROM Exception__c]);
		system.assertEquals(1,exceptionList.size());
		system.assertEquals('System.DmlException',exceptionList[0].Type__c);
		system.assertEquals('single dml insert test',exceptionList[0].Further_Details__c);
	}

	/********************************
	* Bulk DML exception test		*
	********************************/
	private static testMethod void  bulkDMLExceptionTest(){
		List<Contact> consToInsert = new List<Contact>();
		Contact con1 = new Contact(firstName = 'No lastName = DML Exception...');
		Contact con2 = new Contact(firstName = 'No lastName = DML Exception...');
		consToInsert.add(con1);
		consToInsert.add(con2);
		system.assertEquals(2,consToInsert.Size());

		test.startTest();
			try{
				insert consToInsert;
			}
			catch(exception e){
				system.enqueueJob(new exceptionHelperQueable(e,'bulk dml insert test'));
			}
		test.stopTest();

		List<Exception__c> exceptionList = new List<Exception__c>([SELECT Id, Type__c, Further_Details__c FROM Exception__c]);
		system.assertEquals(1,exceptionList.size());
		system.assertEquals('System.DmlException',exceptionList[0].Type__c);
		system.assertEquals('bulk dml insert test',exceptionList[0].Further_Details__c);
	}

	/********************************
	* Database.SaveResult 			*
	********************************/
	private static testMethod void  saveResultExceptionTest(){
		List<Contact> consToInsert = new List<Contact>();
		Contact con1 = new Contact(firstName = 'No lastName = DML Exception...');
		Contact con2 = new Contact(firstName = 'No lastName = DML Exception...');
		consToInsert.add(con1);
		consToInsert.add(con2);
		system.assertEquals(2,consToInsert.Size());

		test.startTest();
			Database.SaveResult[] srList = Database.insert(consToInsert, false);
			System.enqueueJob(new exceptionHelperQueable(srList,'saveResultExceptionTest'));
		test.stopTest();

		List<Exception__c> exceptionList = new List<Exception__c>([SELECT Id, Type__c, Further_Details__c FROM Exception__c]);
		system.assertEquals(2,exceptionList.size());
		system.assertEquals('Database class',exceptionList[0].Type__c);
		system.assertEquals('saveResultExceptionTest',exceptionList[0].Further_Details__c);
		system.assertEquals('Database class',exceptionList[1].Type__c);
		system.assertEquals('saveResultExceptionTest',exceptionList[1].Further_Details__c);
	}

	/********************************
	* Database.DeleteResult			*
	********************************/
	private static testMethod void  deleteResultExceptionTest(){
		List<Account> accsToInsert = new List<Account>();
		Account acc1 = new Account (Name = 'Test Account 1');
		Account acc2 = new Account (Name = 'Test Account 2');
		accsToInsert.add(acc1);
		accsToInsert.add(acc2);
		insert accsToInsert;

		List<Case> casesToInsert = new List<Case>();
		Case case1 = new Case(Subject = 'Test Case 1', AccountId = acc1.Id);
		Case case2 = new Case(Subject = 'Test Case 2', AccountId = acc2.Id);
		casesToInsert.add(case1);
		casesToInsert.add(case2);
		insert casesToInsert;

		test.startTest();
			Database.deleteResult[] drList = Database.delete(accsToInsert, false);
			System.enqueueJob(new exceptionHelperQueable(drList,'DeleteResultTest'));
		test.stopTest();

		List<Exception__c> exceptionList = new List<Exception__c>([SELECT Id, Type__c, Further_Details__c FROM Exception__c]);
		system.assertEquals(2,exceptionList.size());
		system.assertEquals('Database class',exceptionList[0].Type__c);
		system.assertEquals('DeleteResultTest',exceptionList[0].Further_Details__c);
		system.assertEquals('Database class',exceptionList[1].Type__c);
		system.assertEquals('DeleteResultTest',exceptionList[1].Further_Details__c);
	}

	/****************************************
	* Messaging.SendEmailResult				*
	* AWAITING SFDC SUPPORT - PLATFORM BUG	*
	****************************************/
	private static testMethod void  sendEmailExceptionTest(){
		test.startTest();
		test.stopTest();
	}

}