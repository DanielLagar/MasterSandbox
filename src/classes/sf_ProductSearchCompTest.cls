/*

Test class for sf_ProductSearchConsoleComponentCtrl

@author 	Oleg Rikkers
@date 		05/09/2014


*/


@isTest

public with sharing class   sf_ProductSearchCompTest {

    public static testMethod void testAddProductComment () {

    	Case c = new Case ();
    	c.Country__c = 'China';
    	insert c;

        Global_Product__c gp = new Global_Product__c();
        //gp.Name = 'test product';
        insert gp;

    	List <Local_Product__c> lpl = new List <Local_Product__c> ();

    	for (Integer i=0; i<200; i++) {
    		Local_Product__c lp = new Local_Product__c ();
	    	lp.Name = 'tester' + i;
	    	lp.Country__c = 'China';
	    	lp.Translated_Path__c = 'tester path ' + i;
            lp.Global_Product__c = gp.Id;

	    	lpl.add(lp);
    	}

    	insert lpl;



    	Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
    	insert gcc;

    	Local_Comment_Code__c cc = new Local_Comment_Code__c ();
    	//cc.Name = 'test';
    	cc.Global_Comment_Code__c = gcc.Id;

    	insert cc;

    	System.assertEquals(200, [SELECT Id FROM Local_Product__c].size(), 'Product was not created.');

    	ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ProductSearchConsoleComponentCtrl ctrl = new sf_ProductSearchConsoleComponentCtrl (sc);

    	Test.startTest();
    	
    	List <sObject> lpList = sf_ProductSearchConsoleComponentCtrl.doSoslSearch('test', 'China');
    	List <sObject> ccList = sf_ProductSearchConsoleComponentCtrl.doCaseCommentSoslSearch('test', 'China', null);

    	//System.assertEquals(1, lpList.size(), 'Search did not return expected results');
    	sf_ProductSearchConsoleComponentCtrl.addProduct([SELECT Id FROM Local_Product__c LIMIT 1].Id, c.Id);

    	System.assertEquals(1, [SELECT Id FROM Case_Product__c].size(), 'Product was not added.');

    	ctrl.refreshCaseProducts();
    	ctrl.localProductId = [SELECT Id FROM Case_Product__c LIMIT 1].Id;
    	
    	sf_ProductSearchConsoleComponentCtrl.addCaseCommentCode(c.Id, cc.Id, ctrl.localProductId);
    	
    	System.assertEquals(1, [SELECT Id FROM Case_Comment_Code__c].size(), 'Case Comment was not added.');
    	
    	ctrl.refreshCaseProducts();
    	ctrl.commentCodeId = [SELECT Id FROM Case_Comment_Code__c LIMIT 1].Id;
    	
    	ctrl.removeCommentCode();
    	System.assertEquals(0, [SELECT Id FROM Case_Comment_Code__c].size(), 'Case Comment was not removed.');

    	
    	ctrl.removeCaseProduct();

    	Test.stopTest();
    }


    public static testMethod void testExceptions () {

    	Case c = new Case ();
    	c.Country__c = 'China';
    	insert c;

    

    	ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ProductSearchConsoleComponentCtrl ctrl = new sf_ProductSearchConsoleComponentCtrl (sc);

    	Test.startTest();
    	
    	

    	ctrl.removeCommentCode();
    	ctrl.removeCaseProduct();
    
    	ctrl.localProductId = 'sdas';
    	ctrl.commentCodeId = 'sdasd';
    	
    	ctrl.removeCommentCode();
    	ctrl.removeCaseProduct();


    	Test.stopTest();
    }
}