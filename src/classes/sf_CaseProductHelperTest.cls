/*

Test class for CaseProductHelper.cls

@author 	Chris Southworth
@date 		05/09/2014

*/

@isTest
private class sf_CaseProductHelperTest {
	
	public static testmethod void preventModifyAndDeleteCaseProductTest(){
		Profile agentProfile = [SELECT Id, Name FROM Profile WHERE Name = 'EU1 User'];
		User agentUser = new User(alias = 'agent', email='testAgent@test.com',
						emailencodingkey='UTF-8', firstname='Test', lastname='User', languagelocalekey='en_US',
						localesidkey='en_US', profileid = agentProfile.id,
						timezonesidkey='America/Los_Angeles', username='guest@testpkg.com');
		insert agentUser;
		
		System.runAs(agentUser){
			Test.StartTest();
				Case c = new Case ();
				c.Country__c = 'TestCountry';
				insert c;
				        
				Global_Product__c gp = new Global_Product__c();
				insert gp;
        		
				Local_Product__c lp = new Local_Product__c();
				lp.Name = 'Test';
				lp.Country__c = 'Test';
				lp.Translated_Path__c = 'Test';
				lp.Global_Product__c = gp.Id;
				insert lp;
				
				Case_Product__c cp = new Case_Product__c();
				cp.Case__c = c.Id;
				cp.Local_Product__c = lp.Id;
				cp.Status__c = 'Received';
				insert cp;
				
				//Test to verify failed update
				Boolean failedUpdate = false;
				try{
					cp.Status__c = 'Test';
					update cp;
				} catch(Exception e){
					failedUpdate = true;	
					System.assert(e.getMessage().contains('Product'));
				}
				System.assert(failedUpdate);
				
				//test to verify failed delete
				Boolean failedDelete = false;
				try{
					delete cp;
				} catch(Exception e){
					failedDelete = true;
					System.assert(e.getMessage().contains('Product'));
				}
				System.assert(failedDelete);	
			
			Test.StopTest();
		}
	}
	
	public static testmethod void preventDeleteSubmittedCaseProducts(){
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
    			delete cp;
    		} catch(Exception e){
    			errorFound = true;
    			System.assertEquals(true, e.getMessage().contains(Label.CaseProduct_PreventDeleteForCCCAEorPQC), 'Unexpected error message upon delete.');
    		}
    		System.assertEquals(true, errorFound, 'Error on delete was expected, but not found.');
    	
    	Test.stopTest();
	}
	
}