/**
* @author: salesforce.com
* @date: 02/10/2015
*
* @description: test class for sf_CSATSurveyExt
* Updated to include coverage for WR212 work
* 
*/

@isTest
private class sf_CSATSurveyExtTest {
	/*Rewriting as part of WR212*/
    /*
	@isTest static void testNewSurvey() {
		//create a contact 
    	Contact c = new Contact ();
    	c.LastName = 'test';
        c.Email = 'test@qeqwetestc.com';
    	insert c;

		Case ca = new Case ();
    	ca.Status = 'New';
    	ca.ContactId = c.Id;
    	insert ca;

    	ca.Status = 'Closed';
    	update ca;

    	CSAT_Survey__c csat = [SELECT Id, Survey_Id__c FROM CSAT_Survey__c WHERE Case__c = :ca.Id LIMIT 1];

    	PageReference p = Page.sf_CSATSurvey;
    	p.getParameters().put ('surveyid', csat.Survey_Id__c);

    	Test.setCurrentPage(p);

    	Test.startTest();

    	sf_CSATSurveyExt ext = new sf_CSATSurveyExt (new sf_ContactUsTemplateController ());
    	ext.getBrandYouCanTrustOptions();
    	ext.getRadioButtonOptions();
    	ext.getRadioButtonTenOptions();
    	ext.getBrandYouWillBuyOptions();
    	ext.saveSurvey();

    	Test.stopTest();

    	System.assert(ext.showThankYou);
    	System.assertEquals(false, ext.hasErrors);

	}*/

    @testSetup
    static void setupData(){
    	Contact c = new Contact ();
    	c.LastName = 'test';
        c.Email = 'test@qeqwetestc.com';
    	insert c;

		Case ca = new Case ();
    	ca.Status = 'New';
    	ca.ContactId = c.Id;
    	insert ca;
        
		EmailMessage lastResponseEm = new EmailMessage();
        lastResponseEm.ParentId = ca.Id;
        lastResponseEm.Subject = 'Agent last response';
        lastResponseEm.TextBody = 'Last response content goes here';
        lastResponseEm.Status = '3';
        lastResponseEm.Incoming = False;
        insert lastResponseEm;

    	ca.Status = 'Closed';
    	update ca;

        Contact_Us_Language__c langConfig = new Contact_Us_Language__c();
        langConfig.Country__c = 'United States of America';
        langConfig.Language__c = 'English-US';
        langConfig.Brand_Please_Select__c = 'Please select';
        langConfig.Helpful_Yes__c = 'Yes';
        langConfig.Helpful_No__c = 'No';
        insert langConfig;
    }
    @isTest
    static void noCSATTest(){
        
		PageReference p = Page.sf_CSATSurvey;
        
        Test.setCurrentPage(p);
        
		test.startTest();
            sf_CSATSurveyExt ext = new sf_CSATSurveyExt (new sf_ContactUsTemplateController ());
			List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());

        	system.assertEquals(1, msgs.size());
        	msgs.clear();
        
        	p.getParameters().put ('surveyid', 'stuff here');
            try{
                ext = new sf_CSATSurveyExt (new sf_ContactUsTemplateController ());
            }
            catch(exception e){
                msgs = new List<ApexPages.Message>(ApexPages.getMessages());
            }
        	system.assertEquals(1, msgs.size());        
    	Test.stopTest();
        
    }
    @isTest
    static void noEmailFoundTest(){
        Case ca = [SELECT Id FROM Case LIMIT 1];
        CSAT_Survey__c csat = [SELECT Id, Survey_Id__c FROM CSAT_Survey__c WHERE Case__c = :ca.Id LIMIT 1];
		EmailMessage deleteMe = [SELECT Id FROM EmailMessage WHERE ParentID = :ca.Id];
        delete deleteMe; //So no email message is found
        
		PageReference p = Page.sf_CSATSurvey;
    	p.getParameters().put ('surveyid', csat.Survey_Id__c);
        
        Test.setCurrentPage(p);
        
        test.startTest();
        	sf_CSATSurveyExt ext = new sf_CSATSurveyExt (new sf_ContactUsTemplateController ());
        	ext.replyReceived = 'No';
        	system.assertEquals('Sorry something went wrong, no message was found', ext.lastResponse);
        test.stopTest();
        
    }
    
	@isTest
    static void sf_CSATSurveyExtTest(){
        Case ca = [SELECT Id FROM Case LIMIT 1];
        CSAT_Survey__c csat = [SELECT Id, Survey_Id__c FROM CSAT_Survey__c WHERE Case__c = :ca.Id LIMIT 1];
        
		PageReference p = Page.sf_CSATSurvey;
    	p.getParameters().put ('surveyid', csat.Survey_Id__c);
        
        Test.setCurrentPage(p);
        
        test.startTest();
            sf_CSATSurveyExt ext = new sf_CSATSurveyExt (new sf_ContactUsTemplateController ());
        	String testString = ext.taskDescription;
            ext.getBrandYouCanTrustOptions();
            ext.getRadioButtonOptions();
            ext.getRadioButtonTenOptions();
            ext.getBrandYouWillBuyOptions();
        	
            ext.saveSurvey();
    	Test.stopTest();

    	System.assert(ext.showThankYou);
    	System.assertEquals(false, ext.hasErrors);
    }
    
    @isTest
    static void CSATResponseTest(){
		Case ca = [SELECT Id FROM Case LIMIT 1];
        CSAT_Survey__c csat = [SELECT Id, Survey_Id__c FROM CSAT_Survey__c WHERE Case__c = :ca.Id LIMIT 1];
		Contact_Us_Language__c langConfig = [SELECT Country__c, Language__c, Brand_Please_Select__c, Helpful_Yes__c, Helpful_No__c FROM Contact_Us_Language__c LIMIT 1];
        
    	PageReference p = Page.sf_CSATSurvey;
    	p.getParameters().put ('surveyid', csat.Survey_Id__c);
        p.getParameters().put ('country', langConfig.Country__c);
        p.getParameters().put ('language', langConfig.Language__c);

		Test.setCurrentPage(p);
        
        test.startTest();
        	sf_CSATSurveyExt ext = new sf_CSATSurveyExt (new sf_ContactUsTemplateController ());
        
			Integer taskCount = [SELECT Count() FROM Task WHERE WhatId = :ca.Id];
        	List <SelectOption> replyOption = ext.ReplyOptions;
        
        	ext.replyReceived = 'No';
        	String lastResponse = ext.lastResponse;
        	ext.needMoreHelp = 'No';
        	ext.taskDescription = 'Consumer response here. Please contact me on...';
        	ext.saveTask();

        	//Confirm Case has been reopened and flagged as Did not receive response
        	ca = [SELECT Id, Status, CX_Did_not_receive_response__c FROM Case WHERE Id = :ca.Id];
        	system.assertEquals(True, ca.CX_Did_not_receive_response__c);
        	system.assertEquals('Reopened by Consumer', ca.Status);
        
        	//Confirm that recontact task has been created:
			Integer postTaskCount = [SELECT Count() FROM Task WHERE WhatId = :ca.Id];
        	system.assertEquals(taskCount+1, postTaskCount);
        
        	//Confirm that CSAT record has been deleted
        	List<CSAT_Survey__c> csatList = new List<CSAT_Survey__c>([SELECT Id FROM CSAT_Survey__c WHERE Case__c = :ca.Id]);
        	system.assertEquals(0, csatList.size());
        test.stopTest();
    }
}