/**
* @author: Oleg Rikkers
* @date: 07/22/2014
* @description: 
	Test class
*/

@isTest
private class sf_AttachmentTriggerHelperTest {
	
	@isTest static void test_method_one() {
		Account a = new Account ();
		a.Name = 'Test';
		insert a;
		Attachment att = new Attachment ();
		att.ParentId = a.Id; 
		att.Name = 'skjenkjfnejnfsjkennskjeskjenkjfnejnfsjkennskjeskjenkjfnejnfsjkennskjenkjfnejnfsjkenfjkekjenkjfnejnfsjknfjksenfkjsenfjksenf.pdf';
		att.Body = Blob.valueOf(att.Name);
		insert att;

		System.assertEquals(80,[SELECT Id, Name FROM Attachment].Name.length());
	}

	
   /**
	* @author: Archana Sethuraman
	* @date: 08/29/2014
	* @description: 
		When an Attachment related to a case gets updated, update the Sent to CCM field on case to true
	US428
	*/
	@isTest static void updateCaseTest() {
		
		
		List<Case> caseList = new List<Case>();
		for (Integer i =0; i <200;i++) {
			Case caseRec = new Case(CCM_Initial_Pull__c = System.now());
			caseList.add(caseRec);
		}
		insert caseList;
		
		List<Attachment> attachmentList = new List<Attachment>();
		for (Case c: caseList) {
			Attachment att = sf_TestDataUtility.createAttachment(c.Id);
			attachmentList.add(att);
		}
		insert attachmentList;
		
		Test.startTest();

			for (Attachment a: attachmentList) {
				a.Name = 'test';
			}
         
         update attachmentList;
			
			caseList = [
				SELECT 
					Child_Last_Modified_Date__c, CreatedDate  
				FROM 
					Case 
				WHERE 
					Id in: caseList];
			System.assertNotEquals(null, caseList[0].Child_Last_Modified_Date__c, 'Child_Last_Modified_Date__cshould be set on case');

		Test.stopTest();

	}

}