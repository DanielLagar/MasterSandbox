/********************************************************
*	Test class for removing Contacts from a Case.		*
********************************************************/
@isTest
public class removeContact_test {

	@testSetup
    static void setupData(){
    	checkrecursive.toggleAllTriggers(false);

		Account testAccount = new Account(Name='Test Account');
		insert testAccount;

		List<Contact> consToInsert = new List<Contact>();
		Contact con1 = new Contact(FirstName = 'con1', LastName = 'con1', AccountId = testAccount.Id, email = 'con1@pgsandbox.net');
		consToInsert.add(con1);
		Contact con2 = new Contact(FirstName = 'con2', LastName = 'con2', AccountId = testAccount.Id, email = 'con2@pgsandbox.net');
		consToInsert.add(con2);
		Contact con3 = new Contact(FirstName = 'con3', LastName = 'con3', AccountId = testAccount.Id, email = 'con3@pgsandbox.net');
		consToInsert.add(con3);
		insert consToInsert;

		List<Case> casesToInsert = new List<Case>();

		//submitted
		Case testCase2 = new Case(
			subject = 'testCase2',
			AccountId = testAccount.Id,
			Closed_Date__c = Datetime.now(),
			ContactId = con1.Id
		);
		casesToInsert.add(testCase2);

		//nonPrimaryTask
		Case testCase4 = new Case(
			subject = 'testCase4',
			AccountId = testAccount.Id,
			ContactId = con1.Id
		);
		casesToInsert.add(testCase4);

		//primaryWithOtherCases + nonPrimaryWithOtherCases
		Case testCase5 = new Case(
			subject = 'testCase5',
			AccountId = testAccount.Id,
			ContactId = con2.Id
		);
		casesToInsert.add(testCase5);

		//primaryWithOtherCases + nonPrimaryWithOtherCases
		Case testCase6 = new Case(
			subject = 'testCase6',
			AccountId = testAccount.Id,
			ContactId = con1.Id
		);
		casesToInsert.add(testCase6);	

		//primaryRemoval
		Case testCase7 = new Case(
			subject = 'testCase7',
			AccountId = testAccount.Id,
			ContactId = con3.Id
		);
		casesToInsert.add(testCase7);

		insert casesToInsert;

		List<Case_Contact__c> ccsToInsert = new List<Case_Contact__c>();
		for(Case c : casesToInsert){
			if(c.Id == testCase7.Id){
				Case_Contact__c cc1 = new Case_Contact__c(Case__c = c.Id, Contact__c = con3.Id, Case_Primary_Contact__c = True);
				ccsToInsert.add(cc1);
			}
			else if(c.Id == testCase5.Id){
				Case_Contact__c cc2 = new Case_Contact__c(Case__c = c.Id, Contact__c = con1.Id, Case_Primary_Contact__c = False);
				Case_Contact__c cc3 = new Case_Contact__c(Case__c = c.Id, Contact__c = con2.Id, Case_Primary_Contact__c = True);
				ccsToInsert.add(cc2);
				ccsToInsert.add(cc3);
			}
			else{
				Case_Contact__c cc2 = new Case_Contact__c(Case__c = c.Id, Contact__c = con1.Id, Case_Primary_Contact__c = True);
				Case_Contact__c cc3 = new Case_Contact__c(Case__c = c.Id, Contact__c = con2.Id, Case_Primary_Contact__c = False);
				ccsToInsert.add(cc2);
				ccsToInsert.add(cc3);				
			}
		}
		insert ccsToInsert;

    	checkrecursive.toggleAllTriggers(true);
    }

	/********************************************************
	* Case submitted and Non-Primary Contact				*
	* Expected result: CC set to "Cancelled"				*
	********************************************************/
	@isTest
	static void submittedNonPrimary(){
		Case testCase = [SELECT Id, ContactId, AccountId FROM Case WHERE Subject = 'testCase2' LIMIT 1];
		Case_Contact__c primCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c
									FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = True];
		Case_Contact__c nonPrimCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c
									FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = False];

		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);

		test.startTest();
			sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
			ctr.selectedConId = nonPrimCC.Contact__c;//Set selected Contact to non-primary
			ctr.setContactId();
			system.assertEquals(nonPrimCC.Contact__c,ctr.ContactInfo.Id);
        
			ctr.removeCaseContact();

			Case postRemove = [SELECT Id, AccountId, ContactId FROM Case WHERE Subject = 'testCase2' LIMIT 1];
			system.assertEquals(testCase.AccountId, postRemove.AccountId);
			system.assertEquals(testCase.ContactId, postRemove.ContactId);
			nonPrimCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c, Contact_Status__c FROM Case_Contact__c WHERE Id = :nonPrimCC.Id];
			system.assertEquals('Cancelled',nonPrimCC.Contact_Status__c);
		test.StopTest();
	}
    /********************************************************
	* Case submitted and Primary Contacts 					*
	* Expected result: No changes made with error message 	*
	********************************************************/
	@isTest
	static void submittedPrimary(){
		Case testCase = [SELECT Id, AccountId, ContactId FROM Case WHERE Subject = 'testCase2' LIMIT 1];
		Case_Contact__c primCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c
									FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = True];

		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);

		test.startTest();
			sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
			ctr.removeCaseContact();

			List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
			system.assertEquals(1, msgs.size());

			Case postRemove = [SELECT Id, AccountId, ContactId FROM Case WHERE Subject = 'testCase4' LIMIT 1];
			system.assertEquals(testCase.AccountId, postRemove.AccountId);
			system.assertEquals(testCase.ContactId, postRemove.ContactId);
			primCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c FROM Case_Contact__c WHERE Id = :primCC.Id];
			system.assertNotEquals(null, primCC);
		test.stopTest();
	}

    /********************************************************
	* Case submitted and Non-Primary Contact with FO		*
	* Expected result: No changes made with error message 	*
	********************************************************/
	@isTest
	static void submittedNonPrimaryFO(){
		Case testCase = [SELECT Id, ContactId, AccountId FROM Case WHERE Subject = 'testCase2' LIMIT 1];
		Case_Contact__c primCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c
									FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = True];
		Case_Contact__c nonPrimCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c
									FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = False];

		Fulfillment_Order__c testFO = new Fulfillment_Order__c(
			Case__c = testCase.Id,
			Contact__c = nonPrimCC.Contact__c
		);
		insert testFO;

		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);

		test.startTest();
			sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
			ctr.selectedConId = nonPrimCC.Contact__c;//Set selected Contact to non-primary
			ctr.setContactId();

			system.assertEquals(nonPrimCC.Contact__c,ctr.ContactInfo.Id);

			ctr.removeCaseContact();

			List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
			system.assertEquals(1, msgs.size());

			Case postRemove = [SELECT Id, AccountId, ContactId FROM Case WHERE Subject = 'testCase2' LIMIT 1];
			system.assertEquals(testCase.AccountId, postRemove.AccountId);
			system.assertEquals(testCase.ContactId, postRemove.ContactId);
			nonPrimCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c FROM Case_Contact__c WHERE Id = :nonPrimCC.Id];
			system.assertNotEquals(null, nonPrimCC);
		test.StopTest();
	}

	/********************************************************
	* Case not submitted and with FO 						*
	* Expected result: No changes made with error message 	*
	********************************************************/
	@isTest
	static void primaryFO(){
		Case testCase = [SELECT Id, AccountId, ContactId FROM Case WHERE Subject = 'testCase4' LIMIT 1];
		Case_Contact__c primCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c
									FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = True];

		Fulfillment_Order__c testFO = new Fulfillment_Order__c(
			Case__c = testCase.Id,
			Contact__c = primCC.Contact__c
		);
		insert testFO;

		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);

		test.startTest();
			sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
			ctr.removeCaseContact();

			List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
			system.assertEquals(1, msgs.size());

			Case postRemove = [SELECT Id, AccountId, ContactId FROM Case WHERE Subject = 'testCase4' LIMIT 1];
			system.assertEquals(testCase.AccountId, postRemove.AccountId);
			system.assertEquals(testCase.ContactId, postRemove.ContactId);
			primCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c FROM Case_Contact__c WHERE Id = :primCC.Id];
			system.assertNotEquals(null, primCC);
		test.stopTest();
	}

	/********************************************************
	* Case not submitted and with Task 						*
	* Expected result: No changes made with error message 	*
	********************************************************/
	@isTest
	static void primaryTask(){
		Case testCase = [SELECT Id, AccountId, ContactId FROM Case WHERE Subject = 'testCase4' LIMIT 1];
		Case_Contact__c primCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c
									FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = True];
		Task testTask = new Task(
			subject = 'This is a test task',
			whoId = primCC.Contact__c,
			whatId = primCC.Case__c
		);
		insert testTask;

		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);

		test.startTest();
			sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
			ctr.removeCaseContact();

			List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
			system.assertEquals(1, msgs.size());

			Case postRemove = [SELECT Id, AccountId, ContactId FROM Case WHERE Subject = 'testCase4' LIMIT 1];
			system.assertEquals(testCase.AccountId, postRemove.AccountId);
			system.assertEquals(testCase.ContactId, postRemove.ContactId);
			primCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c FROM Case_Contact__c WHERE Id = :primCC.Id];
			system.assertNotEquals(null, primCC);
		test.StopTest();
	}

	/********************************************************
	* Case not submitted, Primary and with other Case		*
	* Expected result: Case updated and Case Contact deleted*
	********************************************************/
	@isTest
	static void primaryWithOtherCases(){
		Case testCase = [SELECT Id, ContactId FROM Case WHERE Subject = 'testCase6' LIMIT 1];
		Id primConId = testCase.ContactId;
		List<Case_Contact__c> ccList = new List<Case_Contact__c>([SELECT Id, Contact__c, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__c = :testCase.Id]);
		for(Case_Contact__c cc : ccList){
			if(cc.Case_Primary_Contact__c){
				system.assertEquals(testCase.ContactId, cc.Contact__c);
			}
			else{
				system.assertNotEquals(testCase.ContactId, cc.Contact__c);
			}
		}

		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);

		test.startTest();
			sf_ContactInfoController ctr = new sf_ContactInfoController (sc);

			ctr.removeCaseContact();

        	testCase = [SELECT Id, ContactId, AccountId FROM Case WHERE Id = :testCase.Id];
        	ccList = new List<Case_Contact__c>([SELECT Id, Contact__c, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__c = :testCase.Id]);
        	system.assertEquals(1, ccList.size());
        	system.assertEquals(null,testCase.ContactId);
        	system.assertEquals(null,testCase.AccountId);
        	//Confirm Contact not deleted
        	List<Contact> conList = new List<Contact>([SELECT Id, LastName FROM Contact WHERE Id = :primConId]);
        	system.assertEquals(1,conList.size());
		test.StopTest();
	}

	/********************************************************
	* Case not submitted, Non-Primary and with other Case	*
	* Expected result: Case Contact deleted					*
	********************************************************/
	@isTest
	static void nonPrimaryWithOtherCases(){
		Case testCase = [SELECT Id, ContactId, Contact.Name FROM Case WHERE Subject = 'testCase5' LIMIT 1];//Should be con2.Id

		Case_Contact__c primCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c
									FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = True];//Should be con2.Id
		Case_Contact__c nonPrimCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c
									FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = False];//Should be con1.Id

		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);

		test.startTest();
			sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
			ctr.selectedConId = nonPrimCC.Contact__c;//Set selected Contact to non-primary
			ctr.setContactId();

			ctr.removeCaseContact();

        	testCase = [SELECT Id, ContactId, Contact.Name, AccountId FROM Case WHERE Id = :testCase.Id];
        	List<Case_Contact__c> ccList = new List<Case_Contact__c>([SELECT Id, Contact__c, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__c = :testCase.Id]);
        	system.assertEquals(1, ccList.size());
        	system.assertEquals(primCC.Id,ccList[0].Id);
        	system.assertEquals(primCC.Contact__c,testCase.ContactId);
        	system.assertNotEquals(null,testCase.AccountId);
        	//Confirm neither Contact has been deleted
        	List<Contact> conList = new List<Contact>([SELECT Id, LastName FROM Contact WHERE Id = :primCC.Contact__c OR Id = :nonPrimCC.Contact__c]);
        	system.assertEquals(2, conList.size());

		test.StopTest();
	}

	/********************************************************
	* Case not submitted, Primary and with no other Case	*
	* Expected result: Case updated and both Contact		*
	* and Case Contact deleted 								*
	********************************************************/
	@isTest
	static void primaryRemoval(){
		Contact testCon = [SELECT Id, AccountId FROM Contact WHERE LastName = 'con3'];
		Case testCase = [SELECT Id FROM Case WHERE ContactId = :testCon.Id];

		system.assertEquals(1, [SELECT Count() FROM Case_Contact__c WHERE Case__c = :testCase.Id]);

		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
        
        test.startTest();
			sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
        	system.assertEquals(testCon.Id, ctr.contactInfo.Id);
			Boolean canRemove = ctr.canRemoveContact;

        	ctr.removeCaseContact();

        	testCase = [SELECT Id, ContactId, AccountId FROM Case WHERE Id = :testCase.Id];
        	system.assertEquals(0, [SELECT Count() FROM Case_Contact__c WHERE Case__c = :testCase.Id]);
        	system.assertEquals(null,testCase.ContactId);
        	system.assertEquals(null,testCase.AccountId);
		test.stopTest();
	}

	/********************************************************
	* Case not submitted, non-Primary and with no other Case	*
	* Expected result: Case updated and both Contact		*
	* and Case Contact deleted 								*
	********************************************************/
	@isTest
	static void nonPrimaryRemoval(){
		Case testCase = [SELECT Id,AccountId FROM Case WHERE Subject = :'testCase7'];
		Case_Contact__c primCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c
									FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = True];//Should be con1.Id

		Contact newCon = new Contact(firstName='newCon', lastName = 'newCon', AccountId = testcase.AccountId);
		insert newCon;

		Case_Contact__c nonPrimCC =  new Case_Contact__c(Case__c = testCase.Id, Contact__c = newCon.Id, Case_Primary_Contact__c = False, Contact_Status__c = 'Active');
		insert nonPrimCC;

		nonPrimCC = [SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c
					FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = False];//Should be newCon.Id

		system.assertEquals(2, [SELECT Count() FROM Case_Contact__c WHERE Case__c = :testCase.Id]);

		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
        
        test.startTest();
			sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
			ctr.selectedConId = nonPrimCC.Contact__c;//Set selected Contact to non-primary
			ctr.setContactId();
			system.assertEquals(nonPrimCC.Contact__c,ctr.ContactInfo.Id);

			ctr.removeCaseContact();

        	testCase = [SELECT Id, ContactId, AccountId FROM Case WHERE Id = :testCase.Id];
        	system.assertEquals(primCC.Contact__c,testCase.ContactId);
        	system.assertEquals(1, [SELECT Count() FROM Case_Contact__c WHERE Case__c = :testCase.Id]);
        	system.assertNotEquals(null,testCase.ContactId);
        	system.assertNotEquals(null,testCase.AccountId);
		test.stopTest();
	}
}