@isTest
public class dprLinks_ext_test {

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
            dprLinks_ext ext =  new dprLinks_ext(sc);
            list<Case_Product__c> cpList = new List<Case_Product__c>(ext.cps);
            system.assertEquals(0, cpList.size());
        test.stopTest();
    }
    
	/****************************
     * Valid CPS found			*
     ***************************/
	@isTest
    static void validCPTest(){
        Case validCase = [SELECT Id FROM Case WHERE Subject = 'digital' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(validCase);
        
        test.startTest();
            dprLinks_ext ext =  new dprLinks_ext(sc);
            list<Case_Product__c> cpList = new List<Case_Product__c>(ext.cps);
            system.assertEquals(1, cpList.size());        
        test.stopTest();
    }
}