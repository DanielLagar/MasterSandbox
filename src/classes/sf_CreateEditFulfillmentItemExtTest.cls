@isTest
private with sharing class sf_CreateEditFulfillmentItemExtTest {

	@testSetup
	public static void setupData () {
		String userLanguage = 'Chinese';

        Case c = new Case ();
        c.Country__c = 'China';
        c.Language__c = 'Chinese';
        insert c;

        Global_Product__c gp = new Global_Product__c();
        gp.Path__c = 'TestBrand/TestSegment';
        insert gp;

        Local_Product__c lp = new Local_Product__c ();
        lp.Name = 'Test Path';
        lp.Country__c = 'China';
        lp.Translated_Path__c = 'Test Path/Test/Path';
        lp.Global_Product__c = gp.Id;
        insert lp;
        
        Case_Product__c cp = new Case_Product__c ();
        cp.Case__c = c.Id;
        cp.Local_Product__c = lp.Id;
        insert cp;

        Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
        insert gcc;

        Local_Comment_Code__c cc = new Local_Comment_Code__c ();
        cc.Level_1__c = 'TestLevel1';
        cc.Level_2__c = 'TestLevel2';
        cc.Level_3__c = 'Test Classify';
        cc.Global_Comment_Code__c = gcc.Id;
        cc.Translated_Language__c = 'Chinese';
        cc.Inactive__c = false;
        insert cc;
        
        Product_Comment_Code__c pcc = new Product_Comment_Code__c();
        pcc.Global_Comment_Code__c = gcc.Id;
        pcc.Global_Product__c = gp.Id;
        pcc.Global_Product_Brand__c = 'TestBrand';
        pcc.Global_Product_Segment__c = 'TestSegment';
        insert pcc;
        
        //Unable to Classify
        Global_Comment_Code__c gccUTC = new Global_Comment_Code__c ();
        gccUTC.Reason_Required__c = true;
        insert gccUTC;

        Local_Comment_Code__c ccUTC = new Local_Comment_Code__c ();
        ccUTC.Level_1__c = 'Unable To Classify';
        ccUTC.Level_2__c = 'Unable To Classify';
        ccUTC.Level_3__c = 'Unable To Classify';
        ccUTC.Global_Comment_Code__c = gccUTC.Id;
        ccUTC.Translated_Language__c = 'Chinese';
        //ccUTC.Country__c = 'China';
        ccUTC.Inactive__c = false;
        insert ccUTC;
        
        Product_Comment_Code__c pccUTC = new Product_Comment_Code__c();
        pccUTC.Global_Comment_Code__c = gccUTC.Id;
        pccUTC.Global_Product__c = gp.Id;
        pccUTC.Global_Product_Brand__c = 'TestBrand';
        pccUTC.Global_Product_Segment__c = 'TestSegment';
        insert pccUTC;

        Fulfillment_Order__c ffoObj=new Fulfillment_Order__c();
        ffoObj.Case__c = c.Id;
        insert ffoObj;
	}


	public static testMethod void testpageLoad () {

		Test.startTest();
		Fulfillment_Item__c ffi = new Fulfillment_Item__c ();
		sf_CreateEditFulfillmentItemExt ext = new sf_CreateEditFulfillmentItemExt (new ApexPages.StandardController (ffi));
		ext.getBrands();
		ext.getSegments();
		Test.stopTest();
	}
}