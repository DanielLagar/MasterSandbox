/**
* @author: salesforce
* @date: 03/16/2015
*
* @description: Test class for sf_DAMService
*/

@isTest
private class sf_DAMServiceTest {
	
	@isTest static void testSuccess() {
		// Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new sf_DAMServiceHttpCalloutMockImpl());
        System.assertEquals( sf_DAMService.republishAssetsByGTIN (new List <String> {'123123', '123123123'}), sf_DAMService.SUCCESS_MESSAGE);
	}
	
	@isTest static void testError() {
		Test.setMock(HttpCalloutMock.class, new sf_DAMServiceHttpCalloutMockImpl(true));
		System.assertNotEquals( sf_DAMService.republishAssetsByGTIN (new List <String> {'123123', '123123123'}), sf_DAMService.SUCCESS_MESSAGE);
	}
	
}