/*
* @author: Oleg Rikkers
* @date: 06/02/2014

* @description: test class

*/

@isTest
private class sf_CaseCommentCodeTriggerHelperTest {
	
	@isTest static void testDeleteCommentCodeWithSAS() {
		sf_TestDataUtility.setupProducts(1);
		sf_TestDataUtility.setupComments(1);
		Case c = sf_TestDataUtility.createCase();
 
		Case_Product__c cp = new Case_Product__c ();
        cp.Case__c = c.Id;
        cp.Local_Product__c = [SELECT Id FROM Local_Product__c LIMIT 1].Id;
        insert cp;

        Case_Comment_Code__c ccc = new Case_Comment_Code__c ();
        ccc.Case__c = c.Id;
        ccc.Case_Product__c = cp.Id;
        ccc.Local_Comment_Code__c = [SELECT Id FROM Local_Comment_Code__c LIMIT 1].Id;
        insert ccc;

        Safety_Assessment_Survey__c sas = new Safety_Assessment_Survey__c ();
        sas.Case__c = c.Id;

        insert sas;

        Survey_Comment_Product__c scp = new Survey_Comment_Product__c ();
        scp.Safety_Assessment_Survey__c = sas.Id;
        scp.Case_Product__c = cp.Id;

        insert scp;


        Test.startTest();
        try {
        	delete ccc;
        } catch (Exception e) {
        	System.assert(e.getMessage().contains(Label.CommentCodeCannotBeDeleted));
        }

        Test.stopTest();

	}
	

	@isTest static void testDeleteCommentCodeWithoutSAS() {
		sf_TestDataUtility.setupProducts(1);
		sf_TestDataUtility.setupComments(1);
		Case c = sf_TestDataUtility.createCase();

		Case_Product__c cp = new Case_Product__c ();
        cp.Case__c = c.Id;
        cp.Local_Product__c = [SELECT Id FROM Local_Product__c LIMIT 1].Id;
        insert cp;

        Case_Comment_Code__c ccc = new Case_Comment_Code__c ();
        ccc.Case__c = c.Id;
        ccc.Case_Product__c = cp.Id;
        ccc.Local_Comment_Code__c = [SELECT Id FROM Local_Comment_Code__c LIMIT 1].Id;
        insert ccc;


        Test.startTest();
        delete ccc;
        Test.stopTest();  
	}
	
	@isTest static void testDeleteCommentCodeWithFulfillmentOrder() {
		sf_TestDataUtility.setupProducts(1);
		sf_TestDataUtility.setupComments(1);
		Case c = sf_TestDataUtility.createCase();
 
		Case_Product__c cp = new Case_Product__c ();
        cp.Case__c = c.Id;
        cp.Local_Product__c = [SELECT Id FROM Local_Product__c LIMIT 1].Id;
        insert cp;

        Case_Comment_Code__c ccc = new Case_Comment_Code__c ();
        ccc.Case__c = c.Id;
        ccc.Case_Product__c = cp.Id;
        ccc.Local_Comment_Code__c = [SELECT Id FROM Local_Comment_Code__c LIMIT 1].Id;
        insert ccc;

		Fulfillment_Order__c ffo = new Fulfillment_Order__c();
		ffo.Case__c = c.Id;
		ffo.Case_Comment_Code__c = ccc.Id;
		insert ffo;

        Test.startTest();
        
        try {
        	delete ccc;
        } catch (Exception e) {
        	System.assert(e.getMessage().contains(Label.CommentCodeCannotBeDeletedFulfillmentOrders));
        }

        Test.stopTest();
	}
	
	public static testmethod void preventDeleteSubmittedCaseComments(){
		Case c = new Case ();
    	c.Country__c = 'China';
    	c.Language__c = 'Chinese';
    	c.CCM_Initial_Pull__c = System.now();
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
    	gcc.Level_1__c = 'Adverse Event';
    	insert gcc;

    	Local_Comment_Code__c cc = new Local_Comment_Code__c ();
    	cc.Level_1__c = 'TestLevel1';
    	cc.Level_2__c = 'TestLevel2';
    	cc.Level_3__c = 'Test Classify';
    	cc.Global_Comment_Code__c = gcc.Id;
    	cc.Translated_Language__c = 'Chinese';
    	cc.Inactive__c = false;
    	insert cc;
    	
    	Case_Comment_Code__c ccc = new Case_Comment_Code__c();
    	ccc.Case__c = c.Id;
    	ccc.Local_Comment_Code__c = cc.Id;
    	ccc.Case_Product__c = cp.Id;
    	insert ccc;
    	
    	Test.startTest();
    	
    		Boolean errorFound = false;
    		try{
    			delete ccc;
    		} catch(Exception e){
    			errorFound = true;
    			System.assertEquals(true, e.getMessage().contains(Label.CaseCommentCode_PreventDeleteForAEorPQC), 'Unexpected error message upon delete.');
    		}
    		System.assertEquals(true, errorFound, 'Error on delete was expected, but not found.');
    	
    	Test.stopTest();
	}
	
}