/*
* @author: salesforce.com
* @date: 05/11/2015
* @description:  Test class for sf_DAMImageProxyCtrl
*/

@isTest
private class sf_DAMImageProxyCtrlTest {
	
	@testSetup 
	static void setupData () {

        Global_Product__c gp = new Global_Product__c();
        gp.Path__c = 'TestBrand/TestSegment';
        insert gp;

        Local_Product__c lp = new Local_Product__c ();
        lp.Name = 'Test Path';
        lp.Country__c = 'China';
        lp.Translated_Path__c = 'Test Path/Test/Path';
        lp.Global_Product__c = gp.Id;
        lp.Image_Url_Thumb__c = 'https://test.salesforce.com';
        insert lp;

       	Product_Search_Configuration__c conf = new 	Product_Search_Configuration__c ();
       	insert conf;
	}

	@isTest static void testInit() {
		sf_DAMImageProxyCtrl ctrl = new sf_DAMImageProxyCtrl ();
		sf_DAMImageProxyCtrl ctrl2 = new sf_DAMImageProxyCtrl (new ApexPages.StandardController (new Account()));
	}
	
	@isTest static void testCallouts() {

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('sf_MissingProductImage');
		mock.setStatusCode(302);
		mock.setHeader('Content-Type', 'application/json');
		mock.setHeader('Location', 'https//google.com');

		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();
		List <Local_Product__c> lpList = sf_DAMImageProxyCtrl.getDamImageThumbnailUrlInBulk(new List <Id> {[SELECT Id, Image_Url_Thumb__c FROM Local_Product__c].Id});
		Test.stopTest();
		System.assertNotEquals(null, lpList[0].Image_Url_Thumb__c);

	}

	@isTest static void testCallouts2() {

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('sf_MissingProductImage');
		mock.setStatusCode(302);
		mock.setHeader('Content-Type', 'application/json');
		mock.setHeader('Location', 'https//google.com');
		
		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();
		String url = sf_DAMImageProxyCtrl.getDamImageUrl('https://test.salesforce.com');
		Test.stopTest();
		System.assertNotEquals(null, url);

	}

	@isTest static void testCalloutsFail() {

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('sf_MissingProductImage');
		mock.setStatusCode(500);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();
		List <Local_Product__c> lpList = sf_DAMImageProxyCtrl.getDamImageThumbnailUrlInBulk(new List <Id> {[SELECT Id, Image_Url_Thumb__c FROM Local_Product__c].Id});
		Test.stopTest();
		System.assertNotEquals(null, lpList[0].Image_Url_Thumb__c);

	}

	@isTest static void testCalloutsFail2() {

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('sf_MissingProductImage');
		mock.setStatusCode(500);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();
		String url = sf_DAMImageProxyCtrl.getDamImageUrl('https://test.salesforce.com');
		Test.stopTest();
		System.assertNotEquals(null, url);

	}


	
}