/*
* @author: original PG class
* @date: 08/19/2014
* @description: Test class for sf_PIIPopUpCon. 
  Class migrated from Prod org
*/
@isTest
private class sf_PIIPopUpConTest{
    
    public static testmethod void testPIIPopupCon(){
        List<PIISitespageSettings__c> piiList = new List<PIISitespageSettings__c>();
        List<Task> piiTaskList = new List<Task>();
        
		Case caseobj = new Case();
      	caseobj.Country__c='United States of America';
      	caseObj.Language__c='English-US';
      	caseObj.Brand__c='Tide';
      	caseObj.Segment__c='Unknown';
      	insert caseObj;
      
		ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
      
		sf_PIIPopupCon con = new sf_PIIPopupCon(sc);
        
         //Assert no pii or task record already exists
        piiList = [SELECT Id, Fields__c, Case_Id__c, PII_URL__c, Include_DPR_Form__c FROM PIISitespageSettings__c WHERE Case_Id__c = :caseObj.Id];
        System.assertEquals(0, piiList.size());
        piiTaskList = [SELECT Id FROM Task WHERE WhatId = :caseObj.Id];
        System.assertEquals(1, piiTaskList.size());//Task gets auto created on Case open

		test.startTest();
            con.save();
            piiList = [SELECT Id, Fields__c, Case_Id__c, PII_URL__c, Include_DPR_Form__c FROM PIISitespageSettings__c];
            System.assertEquals(1, piiList.size());
        	piiTaskList = [SELECT Id FROM Task WHERE WhatId = :caseObj.Id];
        	System.assertEquals(2, piiTaskList.size());
        	con.toggleDisplayInsert();
            System.assert(!con.displayInsert);
        test.stopTest();
    }
    
    public static testmethod void dprEmailMandatoryTest(){
        //Create Case/Product data
		checkrecursive.toggleAllTriggers(false);
			AutoComRuleHelper_datasetup_Test.dataSetup();
	    checkrecursive.toggleAllTriggers(true); 
        
        Case testCase = [SELECT Id, Selected_Return_Type__c, Status FROM Case WHERE Subject = 'Digital' LIMIT 1];
		ApexPages.StandardController sc = new ApexPages.StandardController(testCase);
		sf_PIIPopupCon con = new sf_PIIPopupCon(sc);
            
        test.startTest();
        	system.assertEquals(True, con.dprAvailable);
        
        	//Now includeDPR
        	con.piiobject.Include_DPR_Form__c = True;
        	con.save();
        
        	//Test email is mandatory message
			List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
        	system.assertEquals(1, msgs.size());
  			msgs.clear();      	

        test.stopTest();
    }
    
	/****************************************************************
     * Where CPs return types all = Digital							*
     * Expected: Include_DPR_Form__c = true							*
	****************************************************************/ 
	public static testmethod void includeDPRTest(){
        //Create Case/Product data
		checkrecursive.toggleAllTriggers(false);
      		AutoComRuleHelper_datasetup_Test.dataSetup();
        checkrecursive.toggleAllTriggers(true); 
        
        Case testCase = [SELECT Id, Selected_Return_Type__c, Status FROM Case WHERE Subject = 'Digital' LIMIT 1];
		ApexPages.StandardController sc = new ApexPages.StandardController(testCase);
		sf_PIIPopupCon con = new sf_PIIPopupCon(sc);
            
        test.startTest();
        	system.assertEquals(True, con.dprAvailable);
        
        	//Now includeDPR
        	con.piiobject.Include_DPR_Form__c = True;
			con.isEmail = True;
			
        	con.save();

        	PIISitespageSettings__c pii = [SELECT Id, Fields__c, Case_Id__c, PII_URL__c, Include_DPR_Form__c FROM PIISitespageSettings__c LIMIT 1];
        	system.assertEquals(true, pii.Include_DPR_Form__c);
        
        test.stopTest();
    }

	/****************************************************************
     * Where CPs return types are mixed, if one physical all		*
     * Become physical												*
     * Expected: Include_DPR_Form__c = false						*
	****************************************************************/
	public static testmethod void mixedReturnTypeDPRTest(){
        //Create Case/Product data
		checkrecursive.toggleAllTriggers(false);
      		AutoComRuleHelper_datasetup_Test.dataSetup();
        checkrecursive.toggleAllTriggers(true); 

        Case testCase = [SELECT Id, ContactId, Selected_Return_Type__c FROM Case WHERE Subject = 'digital' LIMIT 1];
        testCase.Selected_Return_Type__c = '';
        update testCase;

        test.startTest();
            //Create second physical only case product - here as getting too many soql if before test.startTest
            Case_Product__c digiCP = [SELECT Id, Case__c, ACR_Info__c, ACR_Return_Type__c, Product_available_for_return__c, Local_Product__c FROM Case_Product__c WHERE Case__c = :testCase.Id LIMIT 1];
            Case_Product__c phyCP = digiCP.clone(false,false,false,false);
            phyCP.ACR_Return_Type__c = 'Physical';
            insert phyCP;
        
        	Integer cpCount = [SELECT Count() FROM Case_Product__c WHERE Case__C = :testCase.Id];
        	system.assertEquals(2, cpCount);

			ApexPages.StandardController sc = new ApexPages.StandardController(testCase);
			sf_PIIPopupCon con = new sf_PIIPopupCon(sc);

			system.assertEquals(False, con.dprAvailable);

        test.stopTest();
	}
}