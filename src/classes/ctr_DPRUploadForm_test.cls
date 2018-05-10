@isTest
public class ctr_DPRUploadForm_test {
    
	private static String attachmentBody ='Unit Test Attachment Body';
	private static String attachmentName = 'IamanAttachment';
	private static String attachmentType = '.png';
	private static String attachmentId = null;

    @testSetup static void setupData(){
		checkrecursive.toggleAllTriggers(false);
        AutoComRuleHelper_datasetup_Test.dataSetup();
        checkrecursive.toggleAllTriggers(true);
    }

	/****************************
     * Invalid/No UID given		*
     ***************************/
	@isTest
    static void noUIDTest(){
		PageReference pageRef = Page.siteDPRUploadForm;
        Test.setCurrentPage(pageRef);   
        
		test.startTest();
        	ctr_DPRUploadForm ctr = new ctr_DPRUploadForm();
        	ctr.pii = false;
        	ctr.uid = 'cheese';
        	String pageError = ctr.errorMessage;
        	system.assertEquals(System.label.Invalid_URL,pageError);
        test.stopTest();
    }
    
	/****************************
     * Photos already received	*
     ***************************/
	@isTest
    static void photosAlreadyReceivedTest(){
        Case_Product__C cp = [SELECT Id, ACR_Info__c, ACR_Return_Type__c, Digital_Return_Id__c FROM Case_Product__c WHERE ACR_Return_Type__c = 'Digital' AND Digital_Return_Id__c != null];
        cp.Status__c = 'Photo Received';
        update cp;
        
		PageReference pageRef = Page.siteDPRUploadForm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('uid', cp.Digital_Return_Id__c);   
        
        test.startTest();
			ctr_DPRUploadForm ctr = new ctr_DPRUploadForm();
        	ctr.init();
			String pageError = ctr.errorMessage;
        	system.assertEquals(System.label.Photos_Already_Received,pageError);
        test.stopTest();
    }
    
	/****************************
     * Succesfully upload and	*
     * remove attachment		*
     ***************************/    
    @isTest
    static void successfulUploadandRemoveTest(){
        Case testCase =[SELECT Id, Selected_Return_Type__c, Status FROM Case WHERE Subject = 'Digital' LIMIT 1];
        Case_Product__C cp = [SELECT Id, ACR_Info__c, ACR_Return_Type__c, Digital_Return_Id__c FROM Case_Product__c WHERE Case__c = :testCase.Id LIMIT 1];
        system.assertNotEquals(null, cp.Digital_Return_Id__c);
        
		PageReference pageRef = Page.siteDPRUploadForm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('uid', cp.Digital_Return_Id__c);
        
        test.startTest();
        	ctr_DPRUploadForm ctr = new ctr_DPRUploadForm();
        	ctr.init();

        	ctr_DPRUploadForm.doUploadAttachment(attachmentBody, attachmentName, attachmentType, attachmentId, cp.Digital_Return_Id__c);
        	ctr.attachmentName = attachmentName;
        	ctr.saveAttachment();
        
        	List<Attachment> caseAtts = new List<Attachment>([SELECT Id FROM Attachment WHERE ParentId = :testCase.Id]);
        	system.assertEquals(1, caseAtts.size());
        
        	//Remove attachment test
        	ctr.remAttachmentIndex = '0';
        	ctr.srtAttachmentId = caseAtts[0].Id;
        	ctr.removeAttachment();
        	caseAtts = new List<Attachment>([SELECT Id FROM Attachment WHERE ParentId = :testCase.Id]);
        
        	system.assertEquals(0, caseAtts.size());
        
        test.stopTest();
    }
    
	/****************************
     * Succesfully upload and	*
     * submit form				*
     ***************************/ 
	@isTest
    static void uploadandSubmitTest(){
        Case testCase = [SELECT Id, Selected_Return_Type__c, Status FROM Case WHERE Subject = 'Digital' LIMIT 1];
        Case_Product__C cp = [SELECT Id, ACR_Info__c, ACR_Return_Type__c, Digital_Return_Id__c FROM Case_Product__c WHERE Case__c = :testCase.Id LIMIT 1];
        system.assertNotEquals(null, cp.Digital_Return_Id__c);
        
		PageReference pageRef = Page.siteDPRUploadForm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('uid', cp.Digital_Return_Id__c);
        
        test.startTest();
        	ctr_DPRUploadForm ctr = new ctr_DPRUploadForm();
        	ctr.init();

        	ctr_DPRUploadForm.doUploadAttachment(attachmentBody, attachmentName, attachmentType, attachmentId, cp.Digital_Return_Id__c);
        	ctr.attachmentName = attachmentName;
        	ctr.saveAttachment();
        
        	List<Attachment> caseAtts = new List<Attachment>([SELECT Id FROM Attachment WHERE ParentId = :testCase.Id]);
        	system.assertEquals(1, caseAtts.size());

        	ctr.submit();
        	testCase = [SELECT Id, Product_Return_Status__c, Status FROM Case WHERE Id = :testCase.Id];
        	List<EmailMessage> caseEmails = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id]);
        	system.assertEquals('Photo Received', testCase.Product_Return_Status__c);
        	system.assertEquals(1, caseEmails.size());
        
        test.stopTest();
    }
    
	/****************************
     * confirmation email		*
     * error tests				*
     ***************************/
 	@isTest
    static void noEmailThankyouTemplateTest(){
        Case testCase = [SELECT Id, Selected_Return_Type__c, Status FROM Case WHERE Subject = 'Digital' LIMIT 1];
        Case_Product__C cp = [SELECT Id, ACR_Info__c, ACR_Return_Type__c, Digital_Return_Id__c FROM Case_Product__c WHERE Case__c = :testCase.Id LIMIT 1];
        system.assertNotEquals(null, cp.Digital_Return_Id__c);
        
		PageReference pageRef = Page.siteDPRUploadForm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('uid', cp.Digital_Return_Id__c);
        
		test.startTest();
        	ctr_DPRUploadForm ctr = new ctr_DPRUploadForm();
        	ctr.init();
        	//Null thank you email so no email template is found
        	ctr.acr.Digital_Thankyou_Email__c = '';
        	ctr.submit();
		test.stopTest(); 
        
        List<Exception__c> exceptions = new List<Exception__c>([SELECT Id, Further_Details__c FROM Exception__c]);
        system.assertEquals(1, exceptions.size());
        system.assert(exceptions[0].Further_Details__c.startsWith('DPR Upload Form - Failure on confirmation email.'));
    }
    
	@isTest
    static void confirmationEmailErrorTest(){
        Case testCase = [SELECT Id, Selected_Return_Type__c, Status FROM Case WHERE Subject = 'Digital' LIMIT 1];
        Case_Product__C cp = [SELECT Id, ACR_Info__c, ACR_Return_Type__c, Digital_Return_Id__c FROM Case_Product__c WHERE Case__c = :testCase.Id LIMIT 1];
        system.assertNotEquals(null, cp.Digital_Return_Id__c);
        
		PageReference pageRef = Page.siteDPRUploadForm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('uid', cp.Digital_Return_Id__c);
        
		test.startTest();
        	ctr_DPRUploadForm ctr = new ctr_DPRUploadForm();
        	ctr.init();
        	Case_Product__c nullCP = new Case_Product__c();
        	ctr.caseCP = nullCP;

        	ctr.sendConfirmationEmail();
		test.stopTest(); 
        
        List<Exception__c> exceptions = new List<Exception__c>([SELECT Id, Further_Details__c FROM Exception__c]);
        system.assertEquals(1, exceptions.size());
        system.assert(exceptions[0].Further_Details__c.startsWith('DPR Upload Form - Failure on confirmation email.'));
    }
    
	/****************************
     * Submit error tests		*
     ***************************/ 
	@isTest
    static void submitErrorTest(){
        Case testCase = [SELECT Id, Selected_Return_Type__c, Status FROM Case WHERE Subject = 'Digital' LIMIT 1];
        Case_Product__C cp = [SELECT Id, ACR_Info__c, ACR_Return_Type__c, Digital_Return_Id__c FROM Case_Product__c WHERE Case__c = :testCase.Id LIMIT 1];
        system.assertNotEquals(null, cp.Digital_Return_Id__c);
        
		PageReference pageRef = Page.siteDPRUploadForm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('uid', cp.Digital_Return_Id__c);
        
		test.startTest();
        	ctr_DPRUploadForm ctr = new ctr_DPRUploadForm();
        	ctr.init();
        	Case_Product__c nullCP = new Case_Product__c();
        	
        	ctr.caseCP = nullCP;
        	ctr.submit();
        
        	system.assertEquals(system.label.DPR_Submit_Error, ctr.submitErrorMsg);
        test.stopTest();
    }
   
	/****************************
     * Attachment method tests	*
     ***************************/    
    @isTest
    static void attachmentTests(){
        Case testCase =[SELECT Id, Selected_Return_Type__c, Status FROM Case WHERE Subject = 'Digital' LIMIT 1];
        Case_Product__C cp = [SELECT Id, ACR_Info__c, ACR_Return_Type__c, Digital_Return_Id__c FROM Case_Product__c WHERE Case__c = :testCase.Id LIMIT 1];
        system.assertNotEquals(null, cp.Digital_Return_Id__c);
        
		PageReference pageRef = Page.siteDPRUploadForm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('uid', cp.Digital_Return_Id__c);
        
		test.startTest();
        	ctr_DPRUploadForm ctr = new ctr_DPRUploadForm();
        	ctr.init();
        
			//coverage of null
			ctr.srtAttachmentErr = '';
			ctr_DPRUploadForm.doUploadAttachment(null, null, null, null, null);
        
        	//Coverage of getAttachment
			attachmentId = ctr_DPRUploadForm.doUploadAttachment(attachmentBody, attachmentName, attachmentType, attachmentId, cp.Digital_Return_Id__c);
        	ctr_DPRUploadForm.doUploadAttachment(attachmentBody, attachmentName, attachmentType, attachmentId, cp.Digital_Return_Id__c);
        
        	//Remove attachment error
        	ctr.removeAttachment();
        
        test.stopTest();
        
		List<Exception__c> exceptions = new List<Exception__c>([SELECT Id, Further_Details__c FROM Exception__c]);
        system.assertEquals(1, exceptions.size());
        system.assert(exceptions[0].Further_Details__c.startsWith('DPR Upload Form - Error removing attachment.'));
    }    
}