/*
* @author: Oleg Rikkers
* @date: 07/01/2014

* @description: 
* Test class
*/

@isTest
private class sf_OverrideMSTNewEditExtTest {
    
    @isTest static void testNoSurvey() {
    	Metadata_Survey_Trigger__c mst = new Metadata_Survey_Trigger__c ();
        sf_OverrideMSTNewEditExt ext = new sf_OverrideMSTNewEditExt (new ApexPages.StandardController (mst));
        
        List<SelectOption> objOptions = ext.objectsOptionsList;
        List<SelectOption> countryOption = ext.countryOptionsList;
        List<SelectOption> langOptions = ext.languageOptionsList;
        List<SelectOption> caseDirectionOptions = ext.caseDirectionOptionsList;
        List<SelectOption> contactMethodOptions = ext.contactMethodOptionsList;
        List<SelectOption> fieldOptionsList = ext.fieldSetOptionsList;
        List<String> fieldSetStringList = ext.getSelectedFieldSets();
        ext.setSelectedFieldSets(fieldSetStringList);
        ext.populateL2Options();
		ext.populateL3Options();
        
      	ext.save();
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
        lp.Translated_Path__c = 'Test/Test';
        lp.Country__c = 'United States of America';
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
        mst.Trigger_Type__c = 'Level';
        mst.Product_Path__c = 'Testing';
        mst.Comment_Code_Path__c = 'Testing';

        insert mst;

        Test.startTest();
        sf_OverrideMSTNewEditExt ext = new sf_OverrideMSTNewEditExt (new ApexPages.StandardController (mst));

        Test.setCurrentPage(Page.sf_CaseSurveyProbingQuestions);
        ApexPages.currentPage().getParameters().put ('id', mst.Id);
        
        List <String> l = new List <String> {'test'};

        List<SelectOption> l1Options = ext.l1OptionsList;
        
        ext.setselectedBrands(l);
        ext.selectedBrands = null;
        ext.getSelectedBrands();

        ext.setselectedSegments(l);
        ext.selectedSegments = null;
        ext.getselectedSegments();

        ext.setSelectedLanguages(l);
        ext.selectedLanguages = null;
        ext.getselectedLanguages();

        ext.setSelectedCountries(l);
        ext.selectedCountries = null;
        ext.getSelectedCountries();

        ext.setSelectedDirections(l);
        ext.selectedDirections = null;
        ext.getSelectedDirections();

        ext.setSelectedContactMethods(l);
        ext.selectedContactMethods = null;
        ext.getSelectedContactMethods();

        ext.setselectedL1(l);
        List<SelectOption> l2Options = ext.l2OptionsList;
        ext.selectedL1 = null;
        ext.getSelectedL1();

        ext.setselectedL2(l);
        List<SelectOption> l3Options = ext.l3OptionsList;
        ext.selectedL2 = null;
        ext.getSelectedL2();

        ext.setselectedL3(l);
        ext.selectedL3 = null;
        ext.getSelectedL3();

        ext.setSelectedDirections(l);
        ext.selectedDirections = null;
        ext.getSelectedDirections();
        
        ext.populateFieldSetOptions();
        ext.populateBrandSegment ();
        ext.save();

        Test.stopTest();

    }
}