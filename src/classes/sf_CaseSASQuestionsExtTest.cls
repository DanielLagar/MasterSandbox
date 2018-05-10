/*

Test class 

@author 	Oleg Rikkers
@date 		07/30/2014

*/

@isTest

private class sf_CaseSASQuestionsExtTest {
	public static testmethod void testController (){
		
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
				
				Metadata_Survey_Trigger__c mst = new Metadata_Survey_Trigger__c ();
				mst.Survey_Fieldset__c = 'test';

				insert mst;

				Safety_Assessment_Survey__c sas = new Safety_Assessment_Survey__c ();
				sas.Metadata_Survey_Trigger__c = mst.Id;
				sas.Case__c = c.Id;
				insert sas;

				Survey_Comment_Product__c scp = new Survey_Comment_Product__c ();
				scp.Case_Product__c = cp.Id;
				scp.Safety_Assessment_Survey__c = sas.Id;
				insert scp;

				sf_CaseSASQuestionsExt ext = new sf_CaseSASQuestionsExt (new ApexPages.StandardController (c));
				ext.mstId = mst.Id;
				ext.sasId = sas.Id;

				ext.addSymptom();
				ext.removeSymptom();

				ext.getSurveyProducts();
				ext.getFieldSetMap();
				ext.createNewSas();
				ext.saveAllSas();
				ext.cloneSAS();
				
			
			Test.StopTest();
		}
	}
}