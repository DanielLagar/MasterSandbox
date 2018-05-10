/*
* @author: Chris Southworth
* @date: 05/30/2014
* @description:  Test class for sf_BatchBouncedEmail.cls
*/

@isTest
private class sf_BatchBouncedEmailTest {
	public static testmethod void sf_BatchBouncedEmailTest() {

		Contact con = new Contact();
		con.LastName = 'TestLastName';
		con.FirstName = 'TestFirstName';
		con.Primary_Address_Line_1__c = 'Test Address 2';
		con.Primary_Address_Line_2__c = 'Test Address 2';
		con.Primary_Address_Line_3__c = 'Test Address 3';
		con.Primary_City__c = 'TestCity';
		con.Primary_Country__c = 'TestCountry';
		con.Primary_State_Province__c = 'TestState';
		con.Primary_Postal_Code__c = '12345';
		con.EmailBouncedDate = System.now();
		insert con;

		Case caseRecord = new Case();
		caseRecord.Contact_s_Email_Bounced__c = false;
		caseRecord.ContactId = con.Id;
		caseRecord.Contact = con;
		insert caseRecord;

		Test.startTest();

			sf_BatchBouncedEmail batch = new sf_BatchBouncedEmail();
			Database.executeBatch(batch);

		Test.stopTest();

		caseRecord = [SELECT Id, Contact_s_Email_Bounced__c FROM Case WHERE Id =:CaseRecord.Id];
		System.assertEquals(true, caseRecord.Contact_s_Email_Bounced__c, 'Contact Bounced flag should be true on case');
		
	}
}