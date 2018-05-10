/*
  * @author: Chris MacDuff
  * @date: 14-12-2015
  *
  * @description: Rewriting some sf_RepeaterHelperTest methods
  * to handle currency threshold validation rules and to
  * use @testSetup
  */

@isTest
public with sharing class sf_RepeaterHelperTest_Part2 {
    
    private static string SUSPECTED = 'Suspected Repeater';
    private static string USA = 'United States of America';
    private static string CLOSED = 'Closed';

    @testSetup static void setupData(){

        /*User to create data as - use this as threshold validations are
          dependent on user data and could cause deployment failures
        */
        Profile p = [SELECT Id FROM Profile WHERE Name='Global Administrator'];
        User agentTestUser = new User(
            Lastname = 'agentTestUser',
            Alias = 'atu',
            Email = 'agentTestUser@pgTEST.com',
            Username = 'agentTestUser@pgTEST.com',
            CommunityNickname = 'atu',
            ProfileId=p.Id,
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='ISO-8859-1',
            LanguageLocaleKey='en_US',
            USD_Monetary_Threshold__c = 50,
            GBP_Monetary_Threshold__c = 50,
            EUR_Monetary_Threshold__c = 50,
            IsActive = True
        );
        Insert agentTestUser;

        CustomSettingDataFactory.countryRegionSetup();
        
        Repeater_Threshold__c testRepeaterThresholds = new Repeater_Threshold__c(
            name=USA,
            Threshold_Period__c=30,
            Case_Count_Threshold__c=5,
            Reimbursement_Value_Threshold__c=50.00
        );
        Insert testRepeaterThresholds;
        
        /*Test record data to insert and use to test*/
        List<Account> acccountsToInsert = new List<Account>();
        List<Contact> contactsToInsert = new List<Contact>();
        List<Case> casesToInsert = new List<Case>();
        List<Fulfillment_Order__c> fosToInsert = new list<Fulfillment_Order__c>();
        List<Fulfillment_Order_Line_Item__c> folisToInsert = new List<Fulfillment_Order_Line_Item__c>();
        
        system.runAs(agentTestUser){
            Account testAcc1 = new Account(
                name = 'testAcc1', 
                Address_Line_1__c='testAcc1',
                City__c = 'City',
                State_Province__c = 'XX',
                Postal_Code__c = '11111', 
                Country__c = USA
            );
            acccountsToInsert.add(testAcc1);
            
            insert acccountsToInsert;
            
            Contact testCon1 = new Contact(
                accountid = testAcc1.Id,
                lastname = 'testCon1', 
                Primary_Address_Line_1__c = testAcc1.Address_Line_1__c,
                Primary_City__c = testAcc1.City__c,
                Primary_State_Province__c = testAcc1.State_Province__c,
                Primary_Postal_Code__c = testAcc1.Postal_Code__c, 
                Primary_Country__c = testAcc1.Country__c
            );
            contactsToInsert.add(testCon1);
            
            insert contactsToInsert;
            
            Case testCase1 = new Case(
                accountId = testAcc1.Id,
                contactId = testCon1.Id,
                subject = 'test case 1'
            );
            casesToInsert.add(testCase1);
            
            insert casesToInsert;        
            
            Fulfillment_Order__c fo1 = new Fulfillment_Order__c(
                Case__c = testCase1.Id,
                Status__c = 'Open'
            );
            fosToInsert.add(fo1);
            
            insert fosToInsert;
            
            system.assertEquals(1, [SELECT Count() FROM Fulfillment_Order__c]);
            
            Fulfillment_Order_Line_Item__c foli1 = new Fulfillment_Order_Line_Item__c(
                Fulfillment_Order__c = fo1.Id,
                Amount_Currency__c = 10,
                type__c = ''
            );
            folisToInsert.add(foli1);
            
            insert folisToInsert;               
        }
    }

    @isTest
    static void testIntegraredPendingCaseUpdateFulfillment(){
        user atu = [SELECT Id FROM User WHERE Username='agentTestUser@pgTEST.com'];
        Case testCase = [SELECT Id, ContactId, AccountId FROM Case LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Id = :testCase.AccountId];
        
        system.runAs(atu){
            testAccount.Repeater_Status__c = SUSPECTED;
            update testAccount;
            
            testCase.Status = CLOSED;
            
            test.startTest();
                update testCase;
            test.stopTest();
            
            Fulfillment_Order__c testFO = [SELECT Id, Status__c, Case__c FROM Fulfillment_Order__c WHERE Case__c = :testCase.Id];
            system.assertEquals('Deleted', testFO.status__c); //Not sure if this is the correct/expected behaviour...
        }        
    }
    
    @isTest
    static void testPendingCaseUpdateFLFulfillment(){
        user atu = [SELECT Id FROM User WHERE Username='agentTestUser@pgTEST.com'];        
        Case testCase = [SELECT Id, ContactId, AccountId FROM Case LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Id = :testCase.AccountId];
        Fulfillment_Order_Line_Item__c testFOLI = [SELECT Id, Type__c FROM Fulfillment_Order_Line_Item__c LIMIT 1];
        testFOLI.Type__c = 'FL';
 
        system.runAs(atu){
            update testFOLI;

            testCase.Status = CLOSED;
            update testCase;
            
            testCase.Repeater_Case__c = sf_RepeaterHelper.CASE_PENDING_VALIDATION;
            Test.startTest();
            update testCase;
            Test.stopTest();
        }
        Fulfillment_Order__c testFO = [SELECT Id, Status__c, Case__c FROM Fulfillment_Order__c WHERE Case__c = :testCase.Id];
        system.assertEquals(sf_RepeaterHelper.FULFILLMENT_ORDER_OPEN, testFO.status__c);
    }

    @isTest
    static void testClearCaseUpdateFulfillment(){
        user atu = [SELECT Id FROM User WHERE Username='agentTestUser@pgTEST.com'];        
        Case testCase = [SELECT Id, ContactId, AccountId FROM Case LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Id = :testCase.AccountId];
        
        system.runAs(atu){
            testCase.Status = CLOSED;
            update testCase;
        
            testCase.Repeater_Case__c = sf_RepeaterHelper.CASE_FRAUD_CASE;
            update testCase;

            testCase.Repeater_Case__c = null;
            Test.startTest();
            update testCase;
            Test.stopTest();
 
            list<Fulfillment_Order__c> orderResults = [SELECT id, status__c FROM Fulfillment_Order__c WHERE Case__c = :testCase.Id];
            system.assertEquals(sf_RepeaterHelper.FULFILLMENT_ORDER_OPEN, orderResults[0].status__c);
                
        }
    }
    
    @isTest
    static void testClearedFulfillmentClearsCase(){
        user atu = [SELECT Id FROM User WHERE Username='agentTestUser@pgTEST.com'];        
        Case testCase = [SELECT Id, ContactId, AccountId FROM Case LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Id = :testCase.AccountId];
        Fulfillment_Order__c testFO = [SELECT Id FROM Fulfillment_Order__c WHERE Case__c = :testCase.Id];

        system.runAs(atu){
            testAccount.Repeater_Status__c = SUSPECTED;
            update testAccount;
            
            testCase.Status = CLOSED;
            update testCase;
            
            testFO.Status__c = sf_RepeaterHelper.FULFILLMENT_ORDER_OPEN;                 
            Test.startTest();
            update testFO;
            Test.stopTest();
            
            list<Case> caseResults = [SELECT id, Repeater_Case__c FROM Case WHERE id = :testCase.Id];
            system.assert(string.isBlank(caseResults[0].Repeater_Case__c));
        }       
    }
    
    /* We don't run this test as the atu user as a typical agent loses
     * access when Case is closed
    */
    @isTest
    static void testFraudCaseUpdateFulfillment(){
        user atu = [SELECT Id FROM User WHERE Username='agentTestUser@pgTEST.com'];        
        Case testCase = [SELECT Id, ContactId, AccountId FROM Case LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Id = :testCase.AccountId];
        //Fulfillment_Order__c testFO = [SELECT Id FROM Fulfillment_Order__c WHERE Case__c = :testCase.Id];
        system.runAs(atu){
            Test.startTest();
                testCase.Status = CLOSED;
                update testCase;
                    
                testCase.Repeater_Case__c = sf_RepeaterHelper.CASE_PENDING_VALIDATION; //Should set to draft
                update testCase;
                list<Fulfillment_Order__c> orderResults = [SELECT id, status__c FROM Fulfillment_Order__c WHERE Case__c = :testCase.Id];
                system.assertEquals(sf_RepeaterHelper.FULFILLMENT_ORDER_DRAFT, orderResults[0].status__c);
                
                testCase.Repeater_Case__c = sf_RepeaterHelper.CASE_FRAUD_CASE; //Should set to deleted
                update testCase;
            
            Test.stopTest();
         
            //list<Fulfillment_Order__c> orderResults = [SELECT id, status__c FROM Fulfillment_Order__c WHERE Case__c = :testCase.Id];
            orderResults = [SELECT id, status__c FROM Fulfillment_Order__c WHERE Case__c = :testCase.Id];
            system.assertEquals(sf_RepeaterHelper.FULFILLMENT_ORDER_DELETED, orderResults[0].status__c);                
        }
    }
    
    @isTest
    static void testClearedFulfillmentClearsCaseChained(){
        user atu = [SELECT Id FROM User WHERE Username='agentTestUser@pgTEST.com'];        
        Case testCase = [SELECT Id, ContactId, AccountId FROM Case LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Id = :testCase.AccountId];
        Fulfillment_Order__c testFO = [SELECT Id FROM Fulfillment_Order__c WHERE Case__c = :testCase.Id];

        system.runAs(atu){
            testAccount.Repeater_Status__c = SUSPECTED;
            update testAccount;
            
            testCase.Status = CLOSED;
            update testCase;
    
            testFO.Status__c = sf_RepeaterHelper.FULFILLMENT_ORDER_OPEN;                 
            Test.startTest();
            update testFO;
            Test.stopTest();
    
            list<Case> caseResults = [SELECT id, Repeater_Case__c FROM Case WHERE id = :testCase.id];
            system.assert(string.isBlank(caseResults[0].Repeater_Case__c));
        }
    }

}