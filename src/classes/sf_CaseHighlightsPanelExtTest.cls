/**
* @author: Oleg Rikkers
* @date: 07/10/2014
*
* @description: 
* Test class
*/


@isTest
private class sf_CaseHighlightsPanelExtTest {
	@isTest static void testWithoutCase () {
		Case c = new Case ();
		sf_CaseHighlightsPanelExt ext = new sf_CaseHighlightsPanelExt (new ApexPages.StandardController (c));
	}

	@isTest static void testWithCase () {

		Case c = new Case ();
        c.Country__c = 'United States of America';
        c.Language__c = 'English-US';
        c.Status = 'Closed';
        c.Received_Date__c = System.now();
        insert c;

        Global_Product__c p = new Global_Product__c ();
        p.Path__c = 'test/test';
        insert p;
                
        Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
        insert gcc;

        Local_Product__c lp = new Local_Product__c ();
        lp.Global_Product__c = p.Id;
        lp.Name = 'Test1';
        insert lp;
        
        Local_Product__c lp2 = new Local_Product__c ();
        lp2.Global_Product__c = p.Id;
        lp2.Name = 'Test2';
        insert lp2;
        
        Local_Product__c lp3 = new Local_Product__c ();
        lp3.Global_Product__c = p.Id;
        lp3.Name = 'Test3';
        insert lp3;

        Local_Comment_Code__c lcc = new Local_Comment_Code__c ();
        lcc.Global_Comment_Code__c = gcc.Id; 
        lcc.Level_3__c = 'TestLevel3-1';
        insert lcc;
        
        Local_Comment_Code__c lcc2 = new Local_Comment_Code__c ();
        lcc2.Global_Comment_Code__c = gcc.Id; 
        lcc2.Level_3__c = 'TestLevel3-2';
        insert lcc2;
        
        Local_Comment_Code__c lcc3 = new Local_Comment_Code__c ();
        lcc3.Global_Comment_Code__c = gcc.Id; 
        lcc3.Level_3__c = 'TestLevel3-3';
        insert lcc3;
        
		List<Case_Product__c> cpList = new List<Case_Product__c>();
        for (Integer i=0; i<3; i++) {
        	Case_Product__c cp = new Case_Product__c ();
        	cp.Case__c = c.Id;
        	cp.Local_Product__c = lp.Id;
        	cpList.add(cp);
        }
        Case_Product__c cp2 = new Case_Product__c();
        cp2.Case__c = c.Id;
        cp2.Local_Product__c = lp2.Id;
        cpList.add(cp2);
        
        Case_Product__c cp3 = new Case_Product__c();
        cp3.Case__c = c.Id;
        cp3.Local_Product__c = lp3.Id;
        cpList.add(cp3);
        
        insert cpList;

		List<Case_Comment_Code__c> cccList = new List<Case_Comment_Code__c>();
        for (Integer i=0; i<3; i++) {
        	Case_Comment_Code__c ccc = new Case_Comment_Code__c ();
	        ccc.Case__c = c.Id;
	        ccc.Case_Product__c = [SELECT Id FROM Case_Product__c LIMIT 1].Id;
	        ccc.Local_Comment_Code__c = lcc.Id;
	        cccList.add(ccc);
        }
        
    	Case_Comment_Code__c ccc2 = new Case_Comment_Code__c ();
        ccc2.Case__c = c.Id;
        ccc2.Case_Product__c = [SELECT Id FROM Case_Product__c LIMIT 1].Id;
        ccc2.Local_Comment_Code__c = lcc2.Id;
        cccList.add(ccc2);
        
    	Case_Comment_Code__c ccc3 = new Case_Comment_Code__c ();
        ccc3.Case__c = c.Id;
        ccc3.Case_Product__c = [SELECT Id FROM Case_Product__c LIMIT 1].Id;
        ccc3.Local_Comment_Code__c = lcc3.Id;
        cccList.add(ccc3);
        
        insert cccList;

        Test.startTest();

        sf_CaseHighlightsPanelExt ext = new sf_CaseHighlightsPanelExt (new ApexPages.StandardController (c));
        ext.getBrands();
        ext.getComments();
        //ext.getProducts();

        Test.stopTest();

	}
}