/**
* @author: Chris Southworth
* @date: 05/30/2014
* @description:  Test class for sf_ContactHelper.cls
*/

@isTest
private class sf_ContactHelperTest {
	
	@isTest static void flagCasesForBouncedContactEmailsTest() {
		Contact con = new Contact();
		con.LastName = 'TestLastName';
		con.FirstName = 'TestFirstName';
		con.Primary_Address_Line_1__c = 'Test Address';
		con.Primary_City__c = 'City';
		con.Primary_State_Province__c = 'ST';
		con.Primary_Postal_Code__c = '11111';
		con.EmailBouncedDate = null;
		insert con;

		Case caseRecord = new Case();
		caseRecord.Contact_s_Email_Bounced__c = false;
		caseRecord.ContactId = con.Id;
		caseRecord.Contact = con;
		insert caseRecord;

		Test.startTest();

			con.EmailBouncedDate = System.now();
			update con;

			caseRecord = [SELECT Id, Contact_s_Email_Bounced__c FROM Case WHERE Id =:CaseRecord.Id];
			System.assertEquals(true, caseRecord.Contact_s_Email_Bounced__c, 'Contact Bounced flag should be true on case');

			con.EmailBouncedDate = null;
			update con;

			caseRecord = [SELECT Id, Contact_s_Email_Bounced__c FROM Case WHERE Id =:CaseRecord.Id];
			System.assertEquals(false, caseRecord.Contact_s_Email_Bounced__c, 'Contact Bounced flag should be true on case');

		Test.stopTest();

	}
	
	/**
	* @author: Archana Sethuraman
	* @date: 08/29/2014
	* @description: 
	*	When a contact related to a case gets updated, update the Sent to CCM field on case to true
	* US428
	* 
	* DEPRECATED. replaced by synchronous process on contact info page.
	*/
	/*@isTest static void updateCaseTest() {
		
		List<Contact> contactList = new List<Contact>();
		for (Integer i =0; i <200;i++) {
			contactList.add(sf_TestDataUtility.createContact());
		}
		insert contactList;
		
		List<Case> caseList = new List<Case>();
		datetime timestamp = Datetime.now();
		for (Contact c: contactList) {
			Case caseRec = new Case(
				contactId = c.Id,
				ccm_initial_pull__c = timestamp
			);
			caseList.add(caseRec);
		}
		insert caseList;
		
		Test.startTest();

			for (Contact c: contactList) {
				c.FirstName = 'test';
			}
         
         update contactList;
			
			caseList = [
				SELECT 
					Sent_To_CCM__C  
				FROM 
					Case 
				WHERE 
					Id in: caseList 
				and 
					Sent_To_CCM__c =: true];

		Test.stopTest();

	}*/
	
}