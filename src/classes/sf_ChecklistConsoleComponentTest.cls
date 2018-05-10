/**
*
* Test class for sf_ProductSearchConsoleComponentCtrl
*
* @author     Chris Southworth
* @date       05/23/2014
*
*/

@isTest
public with sharing class sf_ChecklistConsoleComponentTest {
    
    @testSetup static void setupData(){
        
		user runningUser = [SELECT Id FROM User WHERE Id = :userinfo.getUserId()];
        system.runAs(runningUser){
            EmailTemplate et = new EmailTemplate(
                    body = 'email template body',
                    htmlValue = '<p>Some html content here</p>',
                    isActive = True,
                    Subject = 'Test email template subject',
                    DeveloperName = 'testEmailTemplate',
                    FolderId = userinfo.getOrganizationId(),
                    TemplateType = 'Custom',//HTML needs a letterhead
                    name = 'testEmailTemplate'
            );
            insert et;
        }

        List<Country_Status__c> countrySettings = new List<Country_Status__c>();
        
		Country_Status__c bothRequired = new Country_Status__c(
            Name = 'United States of America',
            Uses_States__c = True,
            Uses_Postal_Codes__c = True
        );
        countrySettings.add(bothRequired);
        
		Country_Status__c postCodeRequired = new Country_Status__c(
			Name = 'Canada',
            Uses_States__c = False,
            Uses_Postal_Codes__c = True
        );
        countrySettings.add(postCodeRequired);
        
		Country_Status__c stateRequired = new Country_Status__c(
			Name = 'Scotland',
            Uses_States__c = True,
            Uses_Postal_Codes__c = False
        );
        countrySettings.add(stateRequired);
        
		Country_Status__c neitherRequired = new Country_Status__c(
			Name = 'Venezuela',
            Uses_States__c = False,
            Uses_Postal_Codes__c = False
        );
        countrySettings.add(neitherRequired);
        insert countrySettings;
    }
    
    public static testMethod void physicalReturnOnly(){
		Case c = new Case();
        c.Not_Handled_Reason__c = 'test';
        insert c;

        Global_Product__c gp = new Global_Product__c();
        //gp.Name = 'test product';
        insert gp;

        Local_Product__c lp = new Local_Product__c();
        lp.Name = 'Test Product';
        lp.Country__c = 'United States of America';
        lp.Translated_Path__c = 'Test Path';
        lp.Global_Product__c = gp.Id;
        insert lp;

        Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
        gcc.Level_1__c = 'Adverse Event';
        insert gcc;

        Local_Comment_Code__c lcc = new Local_Comment_Code__c ();
        //lcc.Name = 'Test Local Comment Code';
        lcc.Global_Comment_Code__c = gcc.Id;
        insert lcc;

        Case_Product__c cp = new Case_Product__c();
        cp.Local_Product__c = lp.Id;
        cp.Case__c = c.Id;
        cp.Product_available_for_return__c = 'Yes - Product is Available';//CR16
        cp.ACR_Info__c = 'test';//CR16
        cp.ACR_Return_Type__c = 'Physical'; //DPR = Physical
        insert cp;

        Case_Comment_Code__c ccc = new Case_Comment_Code__c();
        ccc.Local_Comment_Code__c = lcc.Id;
        ccc.Case__c = c.Id;
        ccc.Case_Product__c = cp.Id;
        insert ccc;

        Contact con = new Contact();
        con.Primary_Address_Line_1__c = 'Mandatory Contact Test Address';
        con.Primary_City__c = 'Test City';
        con.Primary_State_Province__c = 'Test State';
        con.Primary_Postal_Code__c = '12345';
        con.Primary_Country__c = 'Test Country';
        con.LastName = 'TestLastName';
        insert con;

        ApexPages.StandardController sc = new ApexPages.StandardController (c);
        sf_CheckListConsoleComponentCtrl ctrl = new sf_CheckListConsoleComponentCtrl (sc);

        Test.startTest();
        	//CR16
        	system.assertEquals(true, ctrl.returnRequired);
        	system.assertEquals(System.label.AgentChecklist_physical, ctrl.agentMessage);
        Test.stopTest();
    }

    public static testMethod void testMandatoryContactAndAddress() {
        Case c = new Case();
        c.Not_Handled_Reason__c = 'test';
        insert c;

        Global_Product__c gp = new Global_Product__c();
        //gp.Name = 'test product';
        insert gp;

        Local_Product__c lp = new Local_Product__c();
        lp.Name = 'Test Product';
        lp.Country__c = 'United States of America';
        lp.Translated_Path__c = 'Test Path';
        lp.Global_Product__c = gp.Id;
        insert lp;

        Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
        gcc.Level_1__c = 'Adverse Event';
        insert gcc;

        Local_Comment_Code__c lcc = new Local_Comment_Code__c ();
        //lcc.Name = 'Test Local Comment Code';
        lcc.Global_Comment_Code__c = gcc.Id;
        insert lcc;

        Case_Product__c cp = new Case_Product__c();
        cp.Local_Product__c = lp.Id;
        cp.Case__c = c.Id;
        cp.Product_available_for_return__c = 'Yes - Product is Available';//CR16
        cp.ACR_Info__c = 'test';//CR16
        cp.ACR_Return_Type__c = 'Digital'; //DPR = Digital+Physical
        insert cp;

        Case_Comment_Code__c ccc = new Case_Comment_Code__c();
        ccc.Local_Comment_Code__c = lcc.Id;
        ccc.Case__c = c.Id;
        ccc.Case_Product__c = cp.Id;
        insert ccc;

        Contact con = new Contact();
        con.Primary_Address_Line_1__c = 'Mandatory Contact Test Address';
        con.Primary_City__c = 'Test City';
        con.Primary_State_Province__c = 'Test State';
        con.Primary_Postal_Code__c = '12345';
        con.Primary_Country__c = 'Test Country';
        con.LastName = 'TestLastName';
        insert con;

        ApexPages.StandardController sc = new ApexPages.StandardController (c);
        sf_CheckListConsoleComponentCtrl ctrl = new sf_CheckListConsoleComponentCtrl (sc);

        Test.startTest();
			
        	//CR16
        	system.assertEquals(true, ctrl.returnRequired);
        	system.assertEquals(System.label.AgentChecklist_dpr, ctrl.agentMessage);
        
            //verify default values for new case
            System.assertEquals(null, ctrl.caseRecord.ContactId, 'Contact should be null');
            System.assertEquals(false, ctrl.caseClosed, 'Case should be open');
            System.assertEquals(false, ctrl.linkedContact, 'LinkedContact should be false');
            System.assertEquals(false, ctrl.populatedAddress, 'populatedAddress should be false');
            System.assertEquals(false, ctrl.caseRecord.Consumer_declined_to_share_Contact_Info__c, 'Contact override flag should be false');
            System.assertEquals(false, ctrl.closeCaseButtonEnabled, 'Close Button should be disabled');

            //verify variable values for a case with a linked contact with a populated address
            ctrl.caseRecord.contactId = con.Id;
            ctrl.caseRecord.contact = con;
            ctrl.checkCaseStatus();
                System.assertEquals(false, ctrl.caseClosed, 'Case should be open');
            ctrl.checkLinkedContact();
                System.assertEquals(true, ctrl.linkedContact, 'LinkedContact should be true');
                System.assertEquals(false, ctrl.caseRecord.Consumer_declined_to_share_Contact_Info__c, 'Contact Override should be false');
            ctrl.checkAddress();
                System.assertEquals(true, ctrl.populatedAddress, 'populatedAddress should be true');
                System.assertEquals(false, ctrl.caseRecord.Consumer_declined_to_share_Address__c, 'Address Override should be false');
            ctrl.checkCloseButtonStatus();
                System.assertEquals(false, ctrl.closeCaseButtonEnabled, 'Close Button should be disabled');
                
            //verify variable values for a case with a linked contact with an overrided address
            ctrl.caseRecord.contactId = con.Id;
            ctrl.caseRecord.contact = con;
            con.Primary_Address_Line_1__c = null;
        	con.Primary_City__c = null;
        	con.Primary_State_Province__c = null;
        	con.Primary_Postal_Code__c = null;
        	con.Primary_Country__c = null;
            update con;
            ctrl.caseRecord.Consumer_declined_to_share_Address__c = true;
            ctrl.checkLinkedContact();
                System.assertEquals(true, ctrl.linkedContact, 'LinkedContact should be true');
                System.assertEquals(false, ctrl.caseRecord.Consumer_declined_to_share_Contact_Info__c, 'Contact Override should be false');
            ctrl.checkAddress();
                System.assertEquals(true, ctrl.populatedAddress, 'populatedAddress should be true');
                System.assertEquals(true, ctrl.caseRecord.Consumer_declined_to_share_Address__c, 'Address Override should be false');
            ctrl.checkCloseButtonStatus();
                System.assertEquals(false, ctrl.closeCaseButtonEnabled, 'Close Button should be disabled');

            //verify variable values for a case with no linked contact and no override
            ctrl.caseRecord.contactId = null;
            ctrl.caseRecord.contact = null;
            ctrl.caseRecord.Consumer_declined_to_share_Contact_Info__c = false;
            ctrl.caseRecord.Consumer_declined_to_share_Address__c = false;
            ctrl.contactOverrideChanged();
                System.assertEquals(false, ctrl.linkedContact, 'LinkedContact should be false');
            ctrl.addressOverrideChanged();
                System.assertEquals(false, ctrl.populatedAddress, 'populatedAddress should be false');
            ctrl.checkCloseButtonStatus();
                System.assertEquals(false, ctrl.closeCaseButtonEnabled, 'Close Button should be enabled');

            //verify variable values for a case with no linked contact and override = true
            ctrl.caseRecord.Consumer_declined_to_share_Contact_Info__c = true;
            ctrl.caseRecord.Consumer_declined_to_share_Address__c = true;
            ctrl.contactOverrideChanged();
                System.assertEquals(true, ctrl.linkedContact, 'LinkedContact should be true');
            ctrl.addressOverrideChanged();
                System.assertEquals(true, ctrl.populatedAddress, 'populatedAddress should be true');
            ctrl.checkCaseStatus();
                System.assertEquals(false, ctrl.caseClosed, 'Case should be open');
            ctrl.checkLinkedContact();
                System.assertEquals(true, ctrl.linkedContact, 'LinkedContact should be true');
                System.assertEquals(true, ctrl.caseRecord.Consumer_declined_to_share_Contact_Info__c, 'Contact Override should be true');
            ctrl.checkAddress();
                System.assertEquals(true, ctrl.populatedAddress, 'populatedAddress should be true');
                System.assertEquals(true, ctrl.caseRecord.Consumer_declined_to_share_Address__c, 'Address Override should be true');
            ctrl.checkCloseButtonStatus();
                System.assertEquals(false, ctrl.closeCaseButtonEnabled, 'Close Button should be disabled');

            //verify variable state upon closed case
            ctrl.closeCase();
                System.assertNotEquals('Closed', ctrl.caseRecord.Status, 'CaseRecord.Status should not be Closed');
            ctrl.checkCloseButtonStatus();
                System.assertEquals(false, ctrl.closeCaseButtonEnabled, 'Close button should be disabled');
            ctrl.checkCaseStatus();
                System.assertNotEquals(true, ctrl.caseClosed, 'CaseClosed should not be true');
        Test.stopTest();

    }
    
    public static testMethod void testSurveyChecklistItem() {
        Case c = new Case ();
        c.Country__c = 'United States of America';
        c.Language__c = 'English-US';
        c.Status = 'Open';
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
        cp.Production_Code__c = '123123';
        cp.Product_available_for_return__c = 'yes';
		/*cp.Product_available_for_return__c = 'Yes - Product is Available';//CR16
        cp.ACR_Info__c = 'test';//CR16
        cp.ACR_Return_Type__c = 'Digital'; //cheetz*/
        
        insert cp;

        Case_Comment_Code__c ccc = new Case_Comment_Code__c ();
        ccc.Case__c = c.Id;
        ccc.Case_Product__c = cp.Id;
        ccc.Local_Comment_Code__c = lcc.Id;
        insert ccc;

        Safety_Assessment_Survey__c s = new Safety_Assessment_Survey__c ();
        s.Metadata_Survey_Trigger__c = mst.Id;
        //s.Case_Comment_Code__c = ccc.Id;
        //s.Case_Product__c = cp.Id;
        s.Case__c = c.Id;
        //s.Has_Data__c = true;
        insert s;
        
        Test.startTest();
        
            ApexPages.StandardController sc = new ApexPages.StandardController (c);
            sf_CheckListConsoleComponentCtrl ctrl = new sf_CheckListConsoleComponentCtrl (sc);
        
			//CR16
        	/*system.assertEquals(true, ctrl.returnRequired);
        	system.assertEquals(System.label.AgentChecklist_physical, ctrl.agentMessage);*/
            
            System.assertEquals(false, ctrl.caseClosed, 'Case should be open');
            
            //test for uncompleted survey
            ctrl.sasSurveyCount = 3;
            ctrl.sasCompletedSurveyCount = 1;
            ctrl.checkSurveyProgress();
            ctrl.checkCloseButtonStatus();
            System.assertEquals(false, ctrl.sasSurveysComplete, 'Surveys should not be completed');
            System.assertEquals(false, ctrl.closeCaseButtonEnabled, 'Close Button should be disabled');
            
            //test for completed survey
            ctrl.sasSurveyCount = 3;
            ctrl.sasCompletedSurveyCount = 3;
            ctrl.checkSurveyProgress();
            ctrl.checkCloseButtonStatus();
            System.assertEquals(true, ctrl.sasSurveysComplete, 'Survey should be complete');
            System.assertEquals(true, ctrl.closeCaseButtonEnabled, 'Close Button should be enabled');
        
        Test.stopTest();
        
    }
    //WR120 coverage start
    public static testMethod void testPostCodeOnly(){
		Case c = new Case();
        insert c;
        
		Contact con = new Contact();
        con.Primary_Address_Line_1__c = 'PostCode Only required';
        con.Primary_City__c = 'Test City';
        con.Primary_Postal_Code__c = '12345';
        con.Primary_Country__c = 'Canada';
        con.LastName = 'TestLastName';
        insert con;
        
		ApexPages.StandardController sc = new ApexPages.StandardController (c);
        sf_CheckListConsoleComponentCtrl ctrl = new sf_CheckListConsoleComponentCtrl (sc);
        
        test.startTest();
			ctrl.caseRecord.contactId = con.Id;
            ctrl.caseRecord.contact = con;
        	ctrl.checkAddress();
        	system.assertEquals(true, ctrl.populatedAddress);
        test.stopTest();
    }
    
    public static testMethod void testStateOnly(){
		Case c = new Case();
        insert c;
        
		Contact con = new Contact();
        con.Primary_Address_Line_1__c = 'State Only required';
        con.Primary_City__c = 'Test City';
        con.Primary_State_Province__c = 'Test State';
        con.Primary_Country__c = 'Scotland';
        con.LastName = 'TestLastName';
        insert con;
        
		ApexPages.StandardController sc = new ApexPages.StandardController (c);
        sf_CheckListConsoleComponentCtrl ctrl = new sf_CheckListConsoleComponentCtrl (sc);
        
        test.startTest();
			ctrl.caseRecord.contactId = con.Id;
            ctrl.caseRecord.contact = con;
        	ctrl.checkAddress();
        	system.assertEquals(true, ctrl.populatedAddress);
        test.stopTest();
    }    

    public static testMethod void testStatePostNoRequired(){
		Case c = new Case();
        insert c;
        
		Contact con = new Contact();
        con.Primary_Address_Line_1__c = 'State Only required';
        con.Primary_City__c = 'Test City';
        con.Primary_Country__c = 'Venezuela';
        con.LastName = 'TestLastName';
        insert con;
        
		ApexPages.StandardController sc = new ApexPages.StandardController (c);
        sf_CheckListConsoleComponentCtrl ctrl = new sf_CheckListConsoleComponentCtrl (sc);
        
        test.startTest();
			ctrl.caseRecord.contactId = con.Id;
            ctrl.caseRecord.contact = con;
        	ctrl.checkAddress();
        	system.assertEquals(true, ctrl.populatedAddress);
        test.stopTest();
    }
    
    public static testMethod void testMiscCoverage(){
		Case c = new Case();
        insert c;
        
		Contact con = new Contact();
        con.Primary_Address_Line_1__c = 'State Only required';
        con.Primary_City__c = 'Test City';
        con.Primary_State_Province__c = 'Test State';
        con.Primary_Postal_Code__c = '12345';
        con.Primary_Country__c = 'United States of America';
        con.LastName = 'TestLastName';
        insert con;
        
		ApexPages.StandardController sc = new ApexPages.StandardController (c);
        sf_CheckListConsoleComponentCtrl ctrl = new sf_CheckListConsoleComponentCtrl (sc);
        
        test.startTest();
			ctrl.caseRecord.contactId = con.Id;
            ctrl.caseRecord.contact = con;
        	ctrl.closeCaseButtonEnabled = True;
        
        	ctrl.closeCase();
        	c = [SELECT Id, Sent_to_CCM__c FROM Case WHERE Id = :c.Id];
        	system.assertEquals(True, c.Sent_to_CCM__c);
        	ctrl.openCase();
        	c = [SELECT Id, Status FROM Case WHERE Id = :c.Id];
			system.assertEquals('Reopened by User', c.Status);
        	boolean caseStatusBoo = sf_CheckListConsoleComponentCtrl.verifyCaseStatus(c.Id);
        	system.assertEquals(false, caseStatusBoo);

        test.stopTest();
    }
    //WR120 coverage finish
}