/*
 * Tests specifically for Return Type Dropdown
 * on ContactInfo
 * 
*/ 
@isTest
public class sf_ContactInfoController_DPR_Test {
    
	@testSetup
    static void dataSetup(){
        checkrecursive.toggleAllTriggers(false);
        AutoComRuleHelper_datasetup_Test.dataSetup();
        checkrecursive.toggleAllTriggers(true);
    }

	/****************************************
     * Covers:								*
     * No returns displayed					*
     ***************************************/   
    @isTest
    static void noOptionsTest(){
        Case testCase = [SELECT Id, ContactId FROM Case WHERE Subject = 'CaseOnly' LIMIT 1];
		
        ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
    	sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
        
        test.startTest();
        	ctr.setReturnOptions();
        	system.assertEquals(0, ctr.returnOptions.size());
        	system.assertEquals(false, ctr.showReturnOptions);

            ctr.checkReturnTypes();
            system.assertEquals(0, ctr.returnOptions.size());
            system.assertEquals(false, ctr.showReturnOptions);

            ctr.jsSetReturnOptions();
            system.assertEquals(0, ctr.returnOptions.size());
            system.assertEquals(false, ctr.showReturnOptions);
        test.stopTest();
    }

    /****************************************
     * Covers:                              *
     * If Case closed error displayed on    *
     * checkReturnTypes                     *
     ***************************************/
     @isTest
     static void caseClosedTest(){
        Case testCase = [SELECT Id, ContactId FROM Case WHERE Subject = 'CaseOnly' LIMIT 1];
        testCase.Status = 'Closed';

        test.startTest();
            update testCase;
            ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
            sf_ContactInfoController ctr = new sf_ContactInfoController (sc);

            ctr.checkReturnTypes();
            List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
            system.debug(logginglevel.WARN,'>>> caseClosed msgs: '+msgs);
            system.assert(msgs.size() > 1);
        test.stopTest();
     }

	/****************************************
     * Covers:								*
     * Contact is a repeater, only physical *
     * should be available as an option		*
     ***************************************/ 
    @isTest
    static void repeaterOptionsTest(){
        checkrecursive.toggleAllTriggers(false);
		Case testCase = [SELECT Id, ContactId, Case_Products__c FROM Case WHERE Subject = 'digital' LIMIT 1];//Should have 1 CP
        testCase.Selected_Return_Type__c = null;
        update testCase;
        system.assertEquals(1, testCase.Case_Products__c);

        Contact repeaterCon = [SELECT Id FROM Contact WHERE Id = :testCase.ContactId];
        repeaterCon.Repeater_Status__c = trg_AutoComRuleHelper.CONTACT_REPEATER_STATUS_KNOWN;
        update repeaterCon;
        checkrecursive.toggleAllTriggers(true);
		
        ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
    	sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
        
        test.startTest();
        	ctr.setReturnOptions();
        	system.assertEquals(1, ctr.returnOptions.size());
        	system.assertEquals('Physical', ctr.returnOptions[0].getValue());
        	system.assertEquals(True, ctr.showReturnOptions);
        test.stopTest(); 
    }

	/****************************************
     * Covers:								*
     * if a physical only CP is found only	*
     * physical should be available			*
     ***************************************/   
    @isTest
    static void physicalOnlyTest(){
        Case testCase = [SELECT Id, ContactId, Selected_Return_Type__c FROM Case WHERE Subject = 'digital' LIMIT 1];
        testCase.Selected_Return_Type__c = '';
        update testCase;

        //Create second physical only case prodcut
		Case_Product__c digiCP = [SELECT Id, Case__c, ACR_Info__c, ACR_Return_Type__c, Product_available_for_return__c, Local_Product__c FROM Case_Product__c WHERE Case__c = :testCase.Id LIMIT 1];
		Case_Product__c phyCP = digiCP.clone(false,false,false,false);
        phyCP.ACR_Return_Type__c = 'Physical';
        insert phyCP;
        
        test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
    		sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
        	ctr.setReturnOptions();
        
        	//Assert mixture of Case_Product__c returntypes exists
			system.assertEquals(True, ctr.returnTypes.contains('Physical'));
			system.assertEquals(True, ctr.returnTypes.contains('Digital'));  
        	//Assert picklist is as expected
			system.assertEquals(1, ctr.returnOptions.size());   
        	system.assertEquals('Physical', ctr.returnOptions[0].getValue());
        	system.assertEquals(True, ctr.showReturnOptions);
        test.stopTest();
    }

	/****************************************
     * Covers:								*
     * if a digital CP is found all options	*
     * should be available					*
     ***************************************/    
    @isTest
    static void digitalOptionsTest(){
        Case testCase = [SELECT Id, ContactId, Selected_Return_Type__c FROM Case WHERE Subject = 'digital' LIMIT 1];
        testCase.Selected_Return_Type__c = '';
        update testCase;
        
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
            sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
            ctr.setReturnOptions(); 
        
        	system.assertEquals(3, ctr.returnOptions.size());
        	system.assertEquals(True, ctr.showReturnOptions);
        test.stopTest();              
    }
    
	/****************************************
     * Covers:								*
     * Return type alredy set				*
     ***************************************/    
    @isTest
    static void returnTypeSetTest(){
        Case testCase = [SELECT Id, ContactId, Selected_Return_Type__c FROM Case WHERE Subject = 'digital' LIMIT 1];
		test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
            sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
            ctr.setReturnOptions(); 
        
        	system.assertEquals(1, ctr.returnOptions.size());
        	system.assertEquals(True, ctr.showReturnOptions);
        test.stopTest(); 
        
    }

}