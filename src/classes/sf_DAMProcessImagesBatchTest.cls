/**
* @author: salesforce
* @date: 03/09/2015
*
* @description: test class for sf_DAMProcessImagesBatch
*/

@isTest
private class sf_DAMProcessImagesBatchTest {
	
	@testSetup static void createLP () {
		Global_Product__c gp = new Global_Product__c();
        //gp.Name = 'test product';
        insert gp;

    	List <Local_Product__c> lpl = new List <Local_Product__c> ();

    	for (Integer i=0; i<5; i++) {
    		Local_Product__c lp = new Local_Product__c ();
	    	lp.Name = 'tester' + i;
	    	lp.Country__c = 'China';
	    	lp.Translated_Path__c = 'tester path ' + i;
            lp.Global_Product__c = gp.Id;
            lp.GTIN_Number__c = '123123123123' + i;

	    	lpl.add(lp);
    	}

    	insert lpl;
	}


	@isTest static void testBatch1() {
		sf_DAMProcessImagesBatch b = new sf_DAMProcessImagesBatch (null, new List <String> {'orikkers@salesforce.com'});
		Test.setMock(HttpCalloutMock.class, new sf_DAMServiceHttpCalloutMockImpl());
		Test.startTest();

		Database.executeBatch (b);
		Test.stopTest();

		List <Local_Product__c> lpList = [SELECT Id, GTIN_Number__c FROM Local_Product__c WHERE Last_Dam_Request__c != null];

		System.assertEquals(1, lpList.size()); //we pass LIMIT 1 to test classes
	}
	
	@isTest static void testBatchFail() {
		Test.setMock(HttpCalloutMock.class, new sf_DAMServiceHttpCalloutMockImpl());
		sf_DAMProcessImagesBatch b = new sf_DAMProcessImagesBatch ('SELECT Id FROM Case', new List <String> {'orikkers@salesforce.com'});
	}
	
}