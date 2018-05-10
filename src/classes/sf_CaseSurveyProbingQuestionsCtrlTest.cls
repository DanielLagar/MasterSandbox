/*
* @author: Oleg Rikkers
* @date: 06/02/2014

* @description: 
* Test class
*/

@isTest
private class sf_CaseSurveyProbingQuestionsCtrlTest {
    
    @isTest static void testNoSurvey() {
        Case c = new Case ();
        sf_CaseSurveyProbingQuestionsCtrl ctrl = new sf_CaseSurveyProbingQuestionsCtrl (new ApexPages.StandardController(c));
        ctrl.saveQuestions();
    }
    
    @isTest static void testWithSurvey() {
        Case c = new Case ();
        c.Country__c = 'United States of America';
        c.Language__c = 'English-US';
        c.Status = 'Closed';
        insert c;

        Global_Product__c p = new Global_Product__c ();
        
        insert p;

        Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
        insert gcc;

        Local_Product__c  lp = new Local_Product__c ();
        lp.Global_Product__c = p.Id;
        insert lp;

        Local_Comment_Code__c lcc = new Local_Comment_Code__c ();
        lcc.Global_Comment_Code__c = gcc.Id; 
        insert lcc;

        Metadata_Survey_Trigger__c mst = new Metadata_Survey_Trigger__c ();
        mst.Active__c = true;
        mst.Expiration_Date__c = System.today() + 10;
       
        mst.Country__c = 'United States of America';
        mst.Language__c = 'English-US';
        mst.Survey_Fieldset__c = 'test';
        mst.Survey_Object__c = 'Survey__c';
        insert mst;

        Case_Product__c cp = new Case_Product__c ();
        cp.Case__c = c.Id;
        cp.Local_Product__c = lp.Id;
        insert cp;

        Case_Comment_Code__c ccc = new Case_Comment_Code__c ();
        ccc.Case__c = c.Id;
        ccc.Case_Product__c = cp.Id;
        ccc.Local_Comment_Code__c = lcc.Id;
        insert ccc;


        Survey__c s = new Survey__c ();
        s.Metadata_Survey_Trigger__c = mst.Id;
        s.Case_Comment_Code__c = ccc.Id;
        s.Case_Product__c = cp.Id;
        s.Case__c = c.Id;
        insert s;

        Test.startTest();

        Test.setCurrentPage(Page.sf_CaseSurveyProbingQuestions);
        ApexPages.currentPage().getParameters().put ('id', c.Id);
        sf_CaseSurveyProbingQuestionsCtrl ctrl = new sf_CaseSurveyProbingQuestionsCtrl (new ApexPages.StandardController(c));
        ctrl.saveQuestions();
        Test.stopTest();
        
        
    }
}