/*
* @author: Oleg Rikkers
* @date: 07/01/2014

* @description: 
* Test class
*/

@isTest
private class sf_OverrideMSTViewExtTest {
    
    @isTest static void testNoSurvey() {
    	Metadata_Survey_Trigger__c mst = new Metadata_Survey_Trigger__c ();
        sf_OverrideMSTViewExt ext = new sf_OverrideMSTViewExt (new ApexPages.StandardController (mst));
      
    }
    
    @isTest static void testWithSurvey() {
        

        Global_Product__c p = new Global_Product__c ();
        p.Path__c = 'Testing/test';
        insert p;

        Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
        gcc.Level_1__c = 'Testing';
        gcc.Level_2__c = 'Comments';
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
        mst.Brand__c = 'test';
        mst.Segment__c = 'test';
        mst.Comment_Code_L1__c = 'test';
        mst.Comment_Code_L2__c = 'test';
        mst.Comment_Code_L3__c = 'test';
        mst.Contact_Method__c = 'test';
        mst.Direction__c = 'test';
        mst.Survey_Fieldset__c = 'test';
        mst.Survey_Object__c = 'Survey__c';
        mst.Trigger_Type__c = 'Path';
        mst.Product_Path__c = 'Testing';
        mst.Comment_Code_Path__c = 'Testing';

        insert mst;

        Metadata_Survey_Trigger__c mst1 = new Metadata_Survey_Trigger__c ();
        mst1.Active__c = true;
        mst1.Expiration_Date__c = System.today() + 10;
       
        mst1.Country__c = 'United States of America';
        mst1.Language__c = 'English-US';
        mst1.Brand__c = 'test';
        mst1.Segment__c = 'test';
        mst1.Comment_Code_L1__c = 'test';
        mst1.Comment_Code_L2__c = 'test';
        mst1.Comment_Code_L3__c = 'test';
        mst1.Contact_Method__c = 'test';
        mst1.Direction__c = 'test';
        mst1.Survey_Fieldset__c = 'test';
        mst1.Survey_Object__c = 'Survey__c';
        mst1.Trigger_Type__c = 'Level';
        mst1.Product_Path__c = 'Testing';
        mst1.Comment_Code_Path__c = 'Testing';

        insert mst1;

        Test.startTest();

        Test.setCurrentPage(Page.sf_CaseSurveyProbingQuestions);
        ApexPages.currentPage().getParameters().put ('id', mst.Id);
        sf_OverrideMSTViewExt ext = new sf_OverrideMSTViewExt (new ApexPages.StandardController (mst));
        ext.getSelectedCountries();
        ext.getSelectedBrands();
        ext.getSelectedDirections();
        ext.getSelectedL1();
        ext.getSelectedL2();
        ext.getSelectedL3();
        ext.getSelectedContactMethods();
        ext.getSelectedSegments();
        ext.getSelectedLanguages();
        ext.getProducts();
        ext.getComments();
        
       

        ApexPages.currentPage().getParameters().put ('id', mst1.Id);
        sf_OverrideMSTViewExt ext1 = new sf_OverrideMSTViewExt (new ApexPages.StandardController (mst1));
        ext1.getSelectedCountries();
        ext1.getSelectedBrands();
        ext1.getSelectedDirections();
        ext1.getSelectedL1();
        ext1.getSelectedL2();
        ext1.getSelectedL3();
        ext1.getSelectedContactMethods();
        ext1.getSelectedSegments();
        ext1.getSelectedLanguages();
        ext1.getProducts();
        ext1.getComments();



        Test.stopTest();
        
        
    }
}