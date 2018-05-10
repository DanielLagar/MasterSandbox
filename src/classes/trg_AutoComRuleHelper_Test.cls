/*
 * These tests were written for the trigger based approach
 * for newer ACR object
 * 
 */ 
@isTest
private class trg_AutoComRuleHelper_Test {
	
    private static final String COUNTRY = 'United States of America';
    private static final String LANGUAGE = 'English-US';
    private static final String ATTEMPT1 = 'Product Requested - Attempt 1';
    private static final String ATTEMPT2 = 'Product Requested - Attempt 2';
    private static final String ATTEMPT3 = 'Product Requested - Attempt 3';
    private static final String NOTRECEIVED = 'Not Received after 3 Attempts';
    
	@testSetup
    static void dataSetup(){
        checkrecursive.toggleAllTriggers(false);
        AutoComRuleHelper_datasetup_Test.dataSetup();
        checkrecursive.toggleAllTriggers(true);
    }   
    
	/****************************************
     * PRR Attempt 1						*
     ***************************************/
    @isTest
    static void prrFirstAttemptTest(){
        Case testCase = [SELECT Id, ContactId FROM Case WHERE Subject = 'CaseOnly' LIMIT 1];
        Local_Product__c testLP = [SELECT Id FROM Local_Product__c WHERE Name = 'Bag' LIMIT 1];
        Local_Comment_Code__c testCC = [SELECT Id FROM Local_Comment_Code__c WHERE Criticality__c = 'Critical' LIMIT 1];
        Fulfillment_Item__c firstAttemptFI = [SELECT Id FROM Fulfillment_Item__c WHERE SKU__c = '1stAttempt'];  
		
        test.startTest();
            //Create Case Product
            Case_Product__c testCP = new Case_Product__c(
                Case__c = testCase.Id,
                Local_Product__c = testLP.Id,
                Production_Code__c = 'randomvaluehere',
                Product_available_for_return__c = 'Yes - Product is available'     
            );
            insert testCP;
              
            //ChrisM Aug 2016 boolean deprecated
            checkRecursive.ACRprocessedIds.clear();
 
            Case_Comment_Code__c testCCC = new Case_Comment_Code__c(
                Case__c = testCase.Id,
                Local_Comment_Code__c = testCC.Id,
                Case_Product__c = testCP.Id
            );
            insert testCCC;
        
            //Has a FO been created?
            List<Fulfillment_Order__c> foList = new List<Fulfillment_Order__c>([SELECT Id, ACR_Info__c FROM Fulfillment_Order__c WHERE Case__c = : testCase.Id ]);
            system.assertEquals(1, foList.size());
            
            //Assert expected FI has been used
            //ORDER BY Id DESC - as createddate not reliable - i.e. created in same second
            Fulfillment_Order_Line_Item__c foli1 = [SELECT Id, Fulfillment_Item__c FROM Fulfillment_Order_Line_Item__c WHERE Fulfillment_Order__c = :foList[0].Id ORDER BY Id DESC];
            system.assertEquals(firstAttemptFI.Id, foli1.Fulfillment_Item__c,'first attempt assert failed');        

        test.stopTest();
    }
    
 	/****************************************
     * PRR Attempt 2						*
     ***************************************/
    @isTest
    static void prrSecondAttemptTest(){
        Case testCase = [SELECT Id, ContactId FROM Case WHERE Subject = 'CaseOnly' LIMIT 1];
        Local_Product__c testLP = [SELECT Id FROM Local_Product__c WHERE Name = 'Bag' LIMIT 1];
        Local_Comment_Code__c testCC = [SELECT Id FROM Local_Comment_Code__c WHERE Criticality__c = 'Critical' LIMIT 1];
        Fulfillment_Item__c firstAttemptFI = [SELECT Id FROM Fulfillment_Item__c WHERE SKU__c = '1stAttempt'];  
        
        checkrecursive.toggleAllTriggers(false);
        	testCase.Product_Return_Status__c = ATTEMPT1;
			update testCase; 
        
            //Create Case Product
            Case_Product__c testCP = new Case_Product__c(
                Case__c = testCase.Id,
                Local_Product__c = testLP.Id,
                Production_Code__c = 'randomvaluehere',
                Product_available_for_return__c = 'Yes - Product is available',
                Status__c = ATTEMPT1
            );
        	insert testCP;
            
            Case_Comment_Code__c testCCC = new Case_Comment_Code__c(
                Case__c = testCase.Id,
                Local_Comment_Code__c = testCC.Id,
                Case_Product__c = testCP.Id
            );
        	insert testCCC;
        checkrecursive.toggleAllTriggers(true);
        
        List<EmailMessage> caseEmails = new List<EmailMessage>([SELECT Id, Subject FROM EmailMessage WHERE ParentId = : testCase.Id]);
        system.assertEquals(0, caseEmails.size());    
		
        test.startTest();
        	checkRecursive.ACRprocessedIds.clear();
			testCP.Status__c = ATTEMPT2;
            update testCP;
        
            //FO should NOT be created - email sent instead!
            List<Fulfillment_Order__c> foList = new List<Fulfillment_Order__c>([SELECT Id, ACR_Info__c FROM Fulfillment_Order__c WHERE Case__c = : testCase.Id]);
            system.assertEquals(0, foList.size(), 'match incorrectly found on second attempt');
            
			caseEmails = new List<EmailMessage>([SELECT Id, Subject FROM EmailMessage WHERE ParentId = : testCase.Id]);
            system.assertEquals(1, caseEmails.size(),'email not sent');    

        test.stopTest();
    }

 	/****************************************
     * PRR Attempt 3						*
     ***************************************/
    @isTest
    static void prrThirdAttemptTest(){
        Case testCase = [SELECT Id, ContactId FROM Case WHERE Subject = 'CaseOnly' LIMIT 1];
        Local_Product__c testLP = [SELECT Id FROM Local_Product__c WHERE Name = 'Bag' LIMIT 1];
        Local_Comment_Code__c testCC = [SELECT Id FROM Local_Comment_Code__c WHERE Criticality__c = 'Critical' LIMIT 1];
        Fulfillment_Item__c firstAttemptFI = [SELECT Id FROM Fulfillment_Item__c WHERE SKU__c = '1stAttempt'];  
        
        checkrecursive.toggleAllTriggers(false);
        	testCase.Product_Return_Status__c = ATTEMPT2;
			update testCase; 
        
            //Create Case Product
            Case_Product__c testCP = new Case_Product__c(
                Case__c = testCase.Id,
                Local_Product__c = testLP.Id,
                Production_Code__c = 'randomvaluehere',
                Product_available_for_return__c = 'Yes - Product is available',
                Status__c = ATTEMPT2
            );
        	insert testCP;
            
            Case_Comment_Code__c testCCC = new Case_Comment_Code__c(
                Case__c = testCase.Id,
                Local_Comment_Code__c = testCC.Id,
                Case_Product__c = testCP.Id
            );
        	insert testCCC;
        checkrecursive.toggleAllTriggers(true);
        
		List<EmailMessage> caseEmails = new List<EmailMessage>([SELECT Id, Subject FROM EmailMessage WHERE ParentId = : testCase.Id]);
        system.assertEquals(0, caseEmails.size()); 
		
        test.startTest();
        	checkRecursive.ACRprocessedIds.clear();
			testCP.Status__c = ATTEMPT3;
            update testCP;
        
            //FO should NOT be created - email sent instead!
            List<Fulfillment_Order__c> foList = new List<Fulfillment_Order__c>([SELECT Id, ACR_Info__c FROM Fulfillment_Order__c WHERE Case__c = : testCase.Id]);
            system.assertEquals(0, foList.size(), 'match incorrectly found on third attempt');
            
			caseEmails = new List<EmailMessage>([SELECT Id, Subject FROM EmailMessage WHERE ParentId = : testCase.Id]);
            system.assertEquals(1, caseEmails.size(),'email not sent');    

        test.stopTest();
    }
    
	/****************************************
     * Represents successful creation of FO	*
     * on 1st, 2nd and 3rd attempts			*
     ***************************************/
	@isTest
    static void productReturnFOTest(){
	//Query records we need
	Case testCase = [SELECT Id, ContactId FROM Case WHERE Subject = 'CaseOnly' LIMIT 1];
	Local_Product__c testLP = [SELECT Id FROM Local_Product__c WHERE Name = 'Bag' LIMIT 1];
	Local_Comment_Code__c testCC = [SELECT Id FROM Local_Comment_Code__c WHERE Criticality__c = 'Critical' LIMIT 1];
    Fulfillment_Item__c firstAttemptFI = [SELECT Id FROM Fulfillment_Item__c WHERE SKU__c = '1stAttempt'];
    Fulfillment_Item__c secondAttemptFI = [SELECT Id FROM Fulfillment_Item__c WHERE SKU__c = '2ndAttempt']; 
        
	//Create Case Product
    Case_Product__c testCP = new Case_Product__c(
        Case__c = testCase.Id,
        Local_Product__c = testLP.Id,
		Production_Code__c = 'randomvaluehere',
		Product_available_for_return__c = 'Yes - Product is available'     
    );
    insert testCP;
    
    //clear Contact email so FOs are sent instead of emails
    Contact testCon = [SELECT Id, Email FROM Contact WHERE Id = :testCase.ContactId];
    testCon.email = '';
    update testCon;
    
    test.startTest();
        
		//ChrisM Aug 2016 boolean deprecated
		checkRecursive.ACRprocessedIds.clear();
        
        //Create Case Comment Code
        Case_Comment_Code__c testCCC = new Case_Comment_Code__c(
            Case__c = testCase.Id,
			Local_Comment_Code__c = testCC.Id,
            Case_Product__c = testCP.Id
            //TBC if other fields need to be set
        );
        insert testCCC;
        
		//Has a FO been created?
        List<Fulfillment_Order__c> foList = new List<Fulfillment_Order__c>([SELECT Id, ACR_Info__c FROM Fulfillment_Order__c WHERE Case__c = : testCase.Id ]);
        system.assertEquals(1, foList.size(),'No FO created');
        
		//Assert expected FI has been used
        //ORDER BY Id DESC - as createddate not reliable - i.e. created in same second
        Fulfillment_Order_Line_Item__c foli1 = [SELECT Id, Fulfillment_Item__c FROM Fulfillment_Order_Line_Item__c WHERE Fulfillment_Order__c = :foList[0].Id ORDER BY Id DESC];
        system.assertEquals(firstAttemptFI.Id, foli1.Fulfillment_Item__c,'first attempt FI assert failed');
        
        //Now set CP Status to 'Product Requested - Attempt 2' to fire 2nd Attempt

		//ChrisM Aug 2016 boolean deprecated
		checkRecursive.ACRprocessedIds.clear();
        
        testCP.Status__c = ATTEMPT2;
        update testCP;
        
        //Second FO should be created
		foList = new List<Fulfillment_Order__c>([SELECT Id, ACR_Info__c FROM Fulfillment_Order__c WHERE Case__c = : testCase.Id]);
        system.assertEquals(2, foList.size(), 'no match found on second attempt');
        
		//Assert expected FI has been used
        Fulfillment_Order_Line_Item__c foli2 = [SELECT Id, Fulfillment_Item__c FROM Fulfillment_Order_Line_Item__c WHERE Fulfillment_Order__c = :foList[1].Id ORDER BY Id DESC];
        system.assertEquals(secondAttemptFI.Id, foli2.Fulfillment_Item__c,'second attempt FI assert failed');
        
        //Now set CP Status to 'Product Requested - Attempt 3' to fire 3rd Attempt
        
		//ChrisM Aug 2016 boolean deprecated
		checkRecursive.ACRprocessedIds.clear();
        
        testCP.Status__c = ATTEMPT3;
        update testCP;
        
		//Third FO should NOT be created - email sent intead!
		foList = new List<Fulfillment_Order__c>([SELECT Id, ACR_Info__c FROM Fulfillment_Order__c WHERE Case__c = : testCase.Id]);
        system.assertEquals(3, foList.size(),'no match found on third attempt');
        
		//Assert expected FI has been used
        Fulfillment_Order_Line_Item__c foli3 = [SELECT Id, Fulfillment_Item__c FROM Fulfillment_Order_Line_Item__c WHERE Fulfillment_Order__c = :foList[2].Id ORDER BY Id DESC];
        system.assertEquals(secondAttemptFI.Id, foli3.Fulfillment_Item__c,'third attempt FI assert failed'); 
   	test.stopTest();
    }
    
	/****************************************
     * Medical QR							*
     ***************************************/
	@isTest
    static void medicalQRTest(){
	//Query records we need
	Case testCase = [SELECT Id, ContactId FROM Case WHERE Subject = 'CaseOnly' LIMIT 1];
        
    test.startTest();
        testCase.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 1';
        update testCase;
        
		//Has a FO been created and no email sent?
        List<Fulfillment_Order__c> foList = new List<Fulfillment_Order__c>([SELECT Id, ACR_Info__c FROM Fulfillment_Order__c WHERE Case__c = : testCase.Id ]);
        system.assertEquals(1, foList.size(),'No FO Created error'); 
        
		List<EmailMessage> caseEmails = new List<EmailMessage>([SELECT Id, Subject FROM EmailMessage WHERE ParentId = : testCase.Id]);
        system.assertEquals(0, caseEmails.size(),'Email has been sent in error');
        
		testCase.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 2';
        update testCase;
        
        //No new FO is created
		foList = new List<Fulfillment_Order__c>([SELECT Id, ACR_Info__c FROM Fulfillment_Order__c WHERE Case__c = : testCase.Id ]);
        system.assertEquals(1, foList.size(),'New FO created in error'); 

    test.stopTest();  
    }
    
	/****************************************
     * Fraud Test							*
     ***************************************/
	@isTest
    static void repeaterFraudTest(){
	//Query records we need
	Case testCase = [SELECT Id, ContactId, AccountId FROM Case WHERE Subject = 'CaseOnly' LIMIT 1];
    Contact testCon = [SELECT Id FROM Contact WHERE Id = :testCase.ContactId];
    testCon.Repeater_Status__c = 'Known Repeater';
    update testCon;
    
    test.startTest();
		testCase.Repeater_Case__c = 'Fraudulent Case';
		Update testCase;
        
		//Create FO as ACR has no template name
        List<Fulfillment_Order__c> foList = new List<Fulfillment_Order__c>([SELECT Id, ACR_Info__c FROM Fulfillment_Order__c WHERE Case__c = : testCase.Id ]);
        system.assertEquals(1, foList.size(),'No FO created error');
        
		List<EmailMessage> caseEmails = new List<EmailMessage>([SELECT Id, Subject FROM EmailMessage WHERE ParentId = : testCase.Id]);
        system.assertEquals(0, caseEmails.size(),'Email created when expected FO');

    test.stopTest();
    }
    
}