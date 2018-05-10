@isTest
private class sf_CaseSummaryPopoutCompExtTest {
	
	@isTest static void testInit() {
		


		Contact con = new Contact();
		con.LastName = 'TestLastName';
		con.FirstName = 'TestFirstName';
		con.Primary_Address_Line_1__c = '123 Main Street';
		con.Primary_Address_Line_2__c = 'apt 200';
		con.Primary_Address_Line_3__c = 'something';
		con.Primary_City__c = 'TestCity123';
		con.Primary_Country__c = 'United States';
		con.Primary_State_Province__c = 'Minnesota';
		con.Primary_Postal_Code__c = '55123';
		con.Update_Cases__c = TRUE;
		insert con;

		Case caseRecord = new Case();
		caseRecord.ContactId = con.Id;
		caseRecord.Status = 'Closed';
		insert caseRecord;


		sf_CaseSummaryPopoutCompExt ext = new sf_CaseSummaryPopoutCompExt (new ApexPages.StandardController (caseRecord));
		sf_CaseSummaryPopoutCompExt.checkObjectId(caseRecord.Id);
		ext.caseId = caseRecord.Id;
		ext.setCaseId();
		ext.saveSummary();
	}
	
}