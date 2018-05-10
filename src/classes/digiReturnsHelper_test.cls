@isTest
public class digiReturnsHelper_test {
    
    @testSetup static void setupData(){
		checkrecursive.toggleAllTriggers(false);
        AutoComRuleHelper_datasetup_Test.dataSetup();
        checkrecursive.toggleAllTriggers(true);
    }
    
	/************************************
     * Digital return first attempt		*
     ***********************************/
	@isTest
    static void dprFirstAttemptTest(){
		Case testCase = [SELECT Id FROM Case WHERE Subject = 'Digital' LIMIT 1];
        Set<Id> caseIds = new Set<Id>{testCase.Id};
        List<EmailMessage> caseEmails = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id]);
        system.assertEquals(0, caseEmails.size());
        
       	test.startTest();
        	digiReturnsHelper.digiReturnFirstAttempt(caseIds);
        test.stopTest();
        
		caseEmails = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id]);
		system.assertEquals(1,caseEmails.size());
    }
    /************************************
     * Digital return first attempt     *
     * with cancelled product           *
     ***********************************/    
     @isTest
     static void dprCancelledProduct(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Digital' LIMIT 1];
        Set<Id> caseIds = new Set<Id>{testCase.Id};
        List<EmailMessage> caseEmails = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id]);
        system.assertEquals(0, caseEmails.size());

        Case_Product__c orgCP = new Case_Product__c();
        orgCP = [SELECT Id, Local_Product__c,ACR_Info__c FROM Case_Product__c WHERE Case__c = :testCase.Id LIMIT 1];
        orgCP.Status__c = digiReturnsHelper.DIGI_RETURN_FIRST_ATTEMPT;
        //testCase.Product_Return_Status__c = digiReturnsHelper.DIGI_RETURN_FIRST_ATTEMPT;//WFR?
        update orgCP;

        test.startTest();

            //Now cancel CP
            orgCP.productstatus__c = 'cancelled';
            update orgCP;
            //Now add new CP/CC
            Case_Product__c newCP = new Case_Product__c(
                Case__c = testCase.Id,
                Local_Product__c = orgCP.Local_Product__c,
                Production_Code__c = 'new CP!',
                ACR_Info__c = orgCP.ACR_Info__c,
                ACR_Return_Type__c = 'Digital',
                Product_available_for_return__c = 'Yes - Product is available'     
            );
            insert newCP;
                
            Case_Comment_Code__c newCCC = new Case_Comment_Code__c(
                Case__c = testCase.Id,
                Local_Comment_Code__c = [SELECT Id FROM Local_Comment_Code__c WHERE Level_2__c = 'Foreign Material' LIMIT 1].Id,
                Case_Product__c = orgCP.Id
            );
            insert newCCC;
            //Now resubmit
            digiReturnsHelper.digiReturnFirstAttempt(caseIds);

        test.stopTest();    

        testCase = [SELECT Id, Product_Return_Status__c, CaseNumber FROM Case WHERE Id = :testCase.Id];
        //system.assertEquals(digiReturnsHelper.DIGI_RETURN_FIRST_ATTEMPT,testCase.Product_Return_Status__c);
        system.debug(logginglevel.WARN, '!!!!!!! Post testCase: '+testCase);
        newCP = [SELECT Id, Status__c, Name FROM Case_Product__c WHERE Id = :newCP.Id];
        system.debug(logginglevel.WARN, '!!!!!!! Post newCP: '+newCP);
        //system.assertEquals(digiReturnsHelper.DIGI_RETURN_FIRST_ATTEMPT,newCP.Status__c);*/
        caseEmails = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id]);
        system.assertEquals(1,caseEmails.size());

     }
    
	/************************************
     * Digital return second attempt	*
     ***********************************/
	@isTest
    static void dprSecondAttemptTest(){
        //Get Case/CP and update to attempt 2
        Case testCase = [SELECT Id, ContactId, Country__c, Selected_Return_Type__c, Product_Return_Status__c FROM Case WHERE Subject = 'Digital' LIMIT 1];
        Case_Product__c cp = [SELECT Id FROM Case_Product__c WHERE Case__c = :testCase.Id LIMIT 1];
        List<SObject> updateRecords = new List<SObject>();
        cp.Status__c = 'Photo - Attempt 2';
        updateRecords.add(cp);
        testCase.Product_Return_Status__c = 'Photo - Attempt 2';
        updateRecords.add(testCase);
        update updateRecords;

        Map<Id, Case> caseMap = new Map<Id, Case>();
        caseMap.put(testCase.Id, testCase);
        
        //Assert no email records before 2nd attempt
		List<EmailMessage> caseEmails = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id]);
        system.assertEquals(0, caseEmails.size());

		test.startTest();
        	digiReturnsHelper.digiReturnFirstAttempt(caseMap);
        test.stopTest();
        
		caseEmails = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id]);
        system.assertEquals(1,caseEmails.size());
    }
    
	/************************************
     * Digital return third attempt		*
     ***********************************/
	@isTest
    static void dprThirdAttemptTest(){
        //Get Case/CP and update to attempt 3
        Case testCase = [SELECT Id, ContactId, Country__c, Selected_Return_Type__c, Product_Return_Status__c FROM Case WHERE Subject = 'Digital' LIMIT 1];
        Case_Product__c cp = [SELECT Id FROM Case_Product__c WHERE Case__c = :testCase.Id LIMIT 1];
        List<SObject> updateRecords = new List<SObject>();
        cp.Status__c = 'Photo - Attempt 3';
        updateRecords.add(cp);
        testCase.Product_Return_Status__c = 'Photo - Attempt 3';
        updateRecords.add(testCase);
        update updateRecords;

        Map<Id, Case> caseMap = new Map<Id, Case>();
        caseMap.put(testCase.Id, testCase);
        
        //Assert no email records before 3rd attempt
		List<EmailMessage> caseEmails = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id]);
        system.assertEquals(0, caseEmails.size());

		test.startTest();
        	digiReturnsHelper.digiReturnFirstAttempt(caseMap);
        test.stopTest();
        
		caseEmails = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id]);
        system.assertEquals(1,caseEmails.size());
    }
}