@isTest
public class d2p_consoleComp_ext_test {

	@testSetup static void setupData(){
		checkrecursive.toggleAllTriggers(false);
        AutoComRuleHelper_datasetup_Test.dataSetup();
        checkrecursive.toggleAllTriggers(true);
    }
    
	/****************************
     * No valid CPS found		*
     ***************************/
	@isTest
    static void noValidCPTest(){
		Case noCPCase = [SELECT Id FROM Case WHERE Subject = 'CaseOnly' LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(noCPCase);
        
        test.startTest();
            d2p_consoleComp_ext ext = new d2p_consoleComp_ext(sc);
            ext.caseId = noCPCase.Id;
            ext.setCaseId();
            List<d2p_consoleComp_ext.cpWrapper> cps = new List<d2p_consoleComp_ext.cpWrapper>(ext.getACRCaseProducts());
            system.assertEquals(0, cps.size());
        test.stopTest();
    }
    
	/****************************
     * Valid and in progress CP	*
     * found and processed to	*
     * physical					*
     ***************************/
	@isTest
    static void inprogressCPTest(){
        Case validCase = [SELECT Id FROM Case WHERE Subject = 'digital' LIMIT 1];
        Case_Product__c validCP = [SELECT Id, Status__c FROM Case_Product__c WHERE Case__c = :validCase.Id LIMIT 1];
        
        checkrecursive.toggleAllTriggers(false);
        	List<SObject> updateRecords = new List<SObject>();
            validCP.Status__c = 'Photo - Attempt 2';
            validCase.Product_Return_Status__c = 'Photo - Attempt 2';
            updateRecords.add(validCP);
            updateRecords.add(validCase);
            update updateRecords;
        checkrecursive.toggleAllTriggers(true);

        ApexPages.StandardController sc = new ApexPages.StandardController(validCase);
        
		test.startTest();
        	//Open page and confirm 1 CP is displayed
            d2p_consoleComp_ext ext = new d2p_consoleComp_ext(sc);
            ext.caseId = validCase.Id;
            ext.setCaseId();
            List<d2p_consoleComp_ext.cpWrapper> cps = new List<d2p_consoleComp_ext.cpWrapper>(ext.getACRCaseProducts());
            system.assertEquals(1, cps.size());
        
			//Now select and process
        	//Already selected as in progress
        	ext.processSelected();

            validCP = [SELECT Id, Status__c FROM Case_Product__c WHERE Case__c = :validCase.Id LIMIT 1];
        	system.assertEquals('Product Requested - Attempt 1', validCP.Status__c);
        test.stopTest();
    }
    
	/****************************
     * Valid and NOT in progress*
     * CP found and processed 	*
     * to physical				*
     ***************************/
	@isTest
    static void validCPTest(){
		Case validCase = [SELECT Id FROM Case WHERE Subject = 'digital' LIMIT 1];
        Case_Product__c validCP = [SELECT Id, Status__c FROM Case_Product__c WHERE Case__c = :validCase.Id LIMIT 1];
        
		ApexPages.StandardController sc = new ApexPages.StandardController(validCase);
        
		test.startTest();
        	//Open page and confirm 1 CP is displayed
            d2p_consoleComp_ext ext = new d2p_consoleComp_ext(sc);
            ext.caseId = validCase.Id;
            ext.setCaseId();
            List<d2p_consoleComp_ext.cpWrapper> cps = new List<d2p_consoleComp_ext.cpWrapper>(ext.getACRCaseProducts());
            system.assertEquals(1, cps.size());

			//Try to process without selecting a CP
			ext.processSelected();
			List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
			system.assertEquals(1, msgs.size());    
        
        test.stopTest();
    }
}