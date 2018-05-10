/**

Test class for sf_CaseHelper.cls

@author     Chris Southworth
@date       06/05/2014

*/
@isTest
private class sf_CaseHelperTest {
    /*Pre WR120
    public static testmethod void preventCloseForMissingContactAndAddressTest() {
        Case c = new Case();
        c.Status = 'Open';
        insert c;

        Global_Product__c gp = new Global_Product__c();
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
        insert cp;

        Case_Comment_Code__c ccc = new Case_Comment_Code__c();
        //ccc.Number_of_Adverse_Event__c = 1;
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

        Test.startTest();
            c = [SELECT Id, Number_of_Adverse_Event__c FROM Case WHERE Id =:c.Id];
            System.assertEquals(1, c.Number_of_Adverse_Event__c, 'Should be 1 Adverse Event');

            //Error on missing contact
            Boolean noContactError = false;
            try{
                c.Status = 'Closed';
                update c;
            } catch(Exception e){
                noContactError = true;
                System.assert(e.getMessage().contains(Label.Case_Checklist_Error_Missing_Contact));
            }
            System.assertEquals(true, noContactError, 'Should throw error for missing contact');

            //Error for no Contact, with Contact override = true, but missing Address
            Boolean noContactFlagSetNoAddress = false;
            try{
                c.Consumer_declined_to_share_Contact_Info__c = true;
                c.Status = 'Closed';
                update c;
            } catch(Exception e){
                noContactFlagSetNoAddress = true;
                System.assert(e.getMessage().contains(Label.Case_Checklist_Error_Missing_Address));
            }
            System.assertEquals(true, noContactFlagSetNoAddress, 'Should throw error for missing Address, with contact flag set');

//validation rule prevents contact with partial address
            //No error for valid Contact with Address
            Boolean invalidAddress = false;
            con.Primary_City__c = null;
            update con;
            try{
                c.ContactId = con.Id;
                c.Consumer_declined_to_share_Contact_Info__c = false;
                c.Consumer_declined_to_share_Address__c = false;
                c.Status = 'Closed';
                update c;
            } catch(Exception e){
                invalidAddress = true;
                System.assert(e.getMessage().contains(Label.Case_Checklist_Error_Missing_Address));
            }
            System.assertEquals(true, invalidAddress, 'Should throw error for missing Address, with contact flag set');
            //No error for valid Contact with Address
            Boolean validContact = true;
            con.Primary_City__c = 'test';
            update con;
            try{
                c.ContactId = con.Id;
                c.Status = 'Closed';
                update c;
            } catch(Exception e){
                validContact = false;
            }
            System.assertEquals(true, validContact, 'Should not throw error for valid contact and address');

            //No error thrown for Contact and Address Overrides set, but no contact
            Boolean validBothFlags = true;
            try{
                c.Consumer_declined_to_share_Contact_Info__c = true;
                c.Consumer_declined_to_share_Address__c = true;
                c.Status = 'Closed';
                update c;
            } catch(Exception e){
                validBothFlags = false;
            }
            System.assertEquals(true, validBothFlags, 'Should not show error for both override flags being set');


        Test.stopTest();
    }*/
 
    private static void setupCountryRegionSMO() {
        list<Country_Region_SMO__c> regions = new list<Country_Region_SMO__c> {
            new Country_Region_SMO__c(name='Canada', Region__c='NA', SMO__c='NA'),
            new Country_Region_SMO__c(name='BRAZIL', Region__c='LA', SMO__c='LA')
        };
        insert regions;
    }
 
    @isTest  //region should be set on insert
    public static void testRegionSMOCaseInsert() {
        setupCountryRegionSMO();
        list<Case> cases = new list<Case>{
            new Case(Country__c='Canada'),
            new Case(Country__c='Brazil')
        };
        test.startTest();
        insert cases;
        test.stopTest();
        
        list<Case> caseResults = [select id, Country__c, Region__c, SMO__c from Case order by Country__c];
        system.assertEquals(2, caseResults.size());
        system.assertEquals('Brazil', caseResults[0].Country__c);
        system.assertEquals('LA', caseResults[0].Region__c);
        system.assertEquals('LA', caseResults[0].SMO__c);
        system.assertEquals('Canada', caseResults[1].Country__c);
        system.assertEquals('NA', caseResults[1].Region__c);
        system.assertEquals('NA', caseResults[1].SMO__c);
        
    } 
    
    @isTest  //region should be changed on update
    public static void testRegionSMOCaseUpdate() {
        setupCountryRegionSMO();
        Case c =  new Case(Country__c='Canada');
        insert c;
        c.Country__c = 'Brazil';
        test.startTest();
        update c;
        test.stopTest();
        
        list<Case> caseResults = [select id, Country__c, Region__c, SMO__c from Case];
        system.assertEquals(1, caseResults.size());
        system.assertEquals('Brazil', caseResults[0].Country__c);
        system.assertEquals('LA', caseResults[0].Region__c);
        system.assertEquals('LA', caseResults[0].SMO__c);
    }   

    @isTest  //region should be null on update with bad country
    public static void testRegionSMOCaseUpdateBadCountry() {
        setupCountryRegionSMO();
        Case c =  new Case(Country__c='Canada');
        insert c;
        c.Country__c = 'USA';
        test.startTest();
        update c;
        test.stopTest();
        
        list<Case> caseResults = [select id, Country__c, Region__c, SMO__c from Case];
        system.assertEquals(1, caseResults.size());
        system.assertEquals('USA', caseResults[0].Country__c);
        system.assertEquals(null, caseResults[0].Region__c);
        system.assertEquals(null, caseResults[0].SMO__c);
    }

    @isTest //
    public static void testTransferActivityTaskUserToUser() {
        sf_TestDataUtility tdu = new sf_TestDataUtility();
        User olduser = sf_TestDataUtility.createUser('System Administrator', 'alpha');
        User newuser = sf_TestDataUtility.createUser('System Administrator', 'omega');

        olduser.location__c = 'US';
        newuser.location__c = 'CA';

        insert oldUser;
        insert newUser;

        Case c = new Case();
        c.ownerid = oldUser.id;
        insert c;
        c.ownerid = newuser.id;

        test.startTest();
        update c;
        test.stopTest();

        List<Task> taskResults = [SELECT id, subject, status, New_Owner__c, New_Owner_Location__c, New_Owner_Id__c, Old_Owner__c, Old_Owner_Location__c, Old_Owner_Id__c FROM Task WHERE Recordtype.name = 'Transfer Activity'];
        
        system.debug('@@@taskResults: ' + taskResults);
        system.debug('@@@taskResults[0]: ' + taskResults[0]);
        
        system.assertEquals(1, taskResults.size());
        system.assertEquals('CA', taskResults[0].New_Owner_Location__c);
        system.assertEquals('US', taskResults[0].Old_Owner_Location__c);

    }


    @isTest
    public static void testCaseUpdatesSAS(){
        Case testcase = new Case();
        insert testcase;

        Safety_Assessment_Survey__c testsas = new Safety_Assessment_Survey__c();
        testsas.Case__c = testcase.Id;
        insert testsas;

        testCase.Medical_QR_Status__c = 'Unwilling to Complete';

        test.startTest();
        update testcase;
        test.stopTest();

        List<Safety_Assessment_Survey__c> sasResults = [SELECT id, Medical_QR_Status__c FROM Safety_Assessment_Survey__c];

        system.assertEquals(1, sasResults.size());
        system.assertEquals('Unwilling to Complete', sasResults[0].Medical_QR_Status__c);
    }
    
}