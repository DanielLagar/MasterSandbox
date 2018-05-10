/*
* @author: John Casimiro
* @date: 02/13/2015
* @description:  Test class for sf_BatchDeletePii.cls
*/
@isTest
private class sf_BatchDeletePiiTest {
	public static testmethod void sf_BatchDeletePiiTest() {

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
		con.Update_Cases__c = TRUE;
		insert con;

		Case caseRecord = new Case();
		caseRecord.ContactId = con.Id;
		caseRecord.Status = 'Closed';
		insert caseRecord;

		System.debug(LoggingLevel.INFO, 'Created Test Case ' + caseRecord);

		Test.startTest();

			sf_BatchDeletePii batch = new sf_BatchDeletePii();
			Database.executeBatch(batch);

		Test.stopTest();

		caseRecord = [SELECT Id, createdDate, LastModifiedDate FROM Case WHERE Id =:CaseRecord.Id];
		//System.assertNotEquals(caseRecord.createdDate, caseRecord.LastModifiedDate, 'Case was not updated');
		System.debug('created date = ' + caseRecord.createdDate);
		System.debug('LastModifiedDate = ' + caseRecord.LastModifiedDate);
		
		
	}
}