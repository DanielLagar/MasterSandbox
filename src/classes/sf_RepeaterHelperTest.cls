/**
  * @author: Jason Clark
  * @date: 8/28/2014
  *
  * @description: Unit tests for Trigger Helper class for Repeater Detection logic.
  * 
  * @update:
  * 	Moved methods hitting threshold validations to new class
  *		17-12-2015 christopher.maacduff@accenture.com
  */

@isTest
public with sharing class sf_RepeaterHelperTest {
    private static integer counter = 0;
    private static string SUSPECTED = 'Suspected Repeater';
    private static string KNOWN = 'Known Repeater';
    private static string USA = 'United States of America';
    private static string CLOSED = 'Closed';
    
    //CDOY Added testSetup CustomSettingDataFactory.countryRegionSetup()
    @testSetup
    public static void setupData () {
		CustomSettingDataFactory.countryRegionSetup();
        CustomSettingDataFactory.repeaterThresholdSetup();
        //Create user to run tests as
        Profile admin = [select id from profile where name='System Administrator'];
        User testUser = new User(
            alias = 'u1',
            email ='u1@testorg.com',
            emailencodingkey = 'UTF-8',
            lastname ='Testing',
            languagelocalekey =' en_US',
            localesidkey = 'en_US',
            profileid = admin.Id, 
            country = 'United States',
            CommunityNickname = 'u1',
            timezonesidkey = 'America/Los_Angeles',
            USD_Monetary_Threshold__c = 100.00,
            username = math.random()+'@testorg.com'
        );
        insert testUser;
    }
    
    private static user getTestUser(string userName){
        User testUser = [SELECT Id, UserName FROM User WHERE email = :userName];
        return testUser;
    }

    /* TEST DATA METHODS */    
    private static string getName(string prefix) {
    	return prefix + counter++;
    } 
    
    private static set<id> getIds(list<sObject> lst) {
    	map<id, sObject> temp = new map<id, sObject>(lst);
    	return temp.keyset();
    }

    private static list<Account> createAccounts(integer num) {
        list<Account> accounts = new list<Account>();
        for(integer i=0; i<num; i++) {
        	string aname = getName('Acct');
        	accounts.add(new Account(
        	   name = aname, 
        	   Address_Line_1__c=aname,
        	   City__c = 'City',
        	   State_Province__c = 'XX',
        	   Postal_Code__c = '11111', 
        	   Country__c = USA));
        }    	
    	insert accounts;
    	return accounts;
    }
    
    private static list<Contact> createContacts(list<Account> accounts, integer contactsPerAccount) {
    	list<Contact> contacts = new list<Contact>();
    	for(account a : accounts) {
	    	for(integer i=0; i<contactsPerAccount; i++) {
                contacts.add(new Contact(
                    accountid = a.id, 
                    lastname = getName('Ctct'), 
                    Primary_Address_Line_1__c = a.Address_Line_1__c,
                    Primary_City__c = a.City__c,
                    Primary_State_Province__c = a.State_Province__c,
                    Primary_Postal_Code__c = a.Postal_Code__c, 
                    Primary_Country__c = a.Country__c));
	    	}
    	}
        insert contacts;
        return contacts;
    }
    
    //WR125 ChrisM
    private static List<Case_Comment_Code__c> createCCC(List<Case> cases){
        List<Case_Comment_Code__c> cccList = new List<Case_Comment_Code__c>();
        Case_Product__c cp = new Case_Product__c();
        insert cp;
        for(Case c : cases){
            cccList.add(new Case_Comment_Code__c());
        }
        
        insert cccList;
        return cccList;
    }
    
    private static list<Case> createCases(list<Contact> contacts, integer casesPerContact) {
    	return createCases(contacts, casesPerContact, 0);
    }
    
    private static list<Case> createCases(list<Contact> contacts, integer casesPerContact, integer daysAgo) {
    	if(daysAgo==null) {
    		daysAgo = 0;
    	}
    	Datetime createDate = Datetime.now().addDays(-daysAgo);
    	list<Case> cases = new list<Case>();
    	for(Contact ct : contacts) {
    		for(integer i=0; i<casesPerContact; i++) {
    			cases.add(new Case(AccountId = ct.accountid, Contactid = ct.id, subject=getName('Case')));
    		}
    	}
    	insert cases;
    	return cases;
    }

    private static list<Fulfillment_Order__c> createFulfillmentOrders(list<Case> cases, decimal amountPerOrder) {
    	return createFulfillmentOrders(cases, amountPerOrder, null);
    }
    
    private static list<Fulfillment_Order__c> createFulfillmentOrders(list<Case> cases, decimal amountPerOrder, string lineItemType) {

    	list<Fulfillment_Order__c> orders = new list<Fulfillment_Order__c>();
    	list<Fulfillment_Order_Line_Item__c> lineitems = new list<Fulfillment_Order_Line_Item__c>();
    	for(Case c : cases) {
    		orders.add(new Fulfillment_Order__c(Case__c = c.id));
    	}
    	insert orders;
    	for(Fulfillment_Order__c o : orders) {
    		lineitems.add(new Fulfillment_Order_Line_Item__c(Fulfillment_Order__c = o.id, Amount_Currency__c = amountPerOrder, type__c = lineItemType));
    	}
    	insert lineitems;
    	return orders;
    }
    
    /*ChrisM - replaced with method in CustomSettingDataFactory.repeaterThresholdSetup
    private static void setupThresholds() {
    	insert new Repeater_Threshold__c(name=USA, Threshold_Period__c=30, Case_Count_Threshold__c=5, Reimbursement_Value_Threshold__c=50.00);
    }*/
    
    /* TEST METHODS */

    @isTest  // Updating the Repeater Status of an account should update all contacts' RS
    private static void testSingleAccountUpdate() {
        system.runas(getTestUser('u1@testorg.com')){
            list<Account> accounts = createAccounts(1);
            list<Contact> contacts = createContacts(accounts, 3);
    
            accounts[0].Repeater_Status__c = SUSPECTED;
            Test.startTest();
            update accounts;
            Test.stopTest();
            
            list<contact> results = [select id, Repeater_Status__c from Contact where id in :getIds(contacts)];
            system.assertEquals(3, results.size());
            for(contact c : results) {
                system.assertEquals(SUSPECTED, c.Repeater_Status__c);
            }            
        }
    }
    
    @isTest  // Updating the Repeater status of an account should update Accounts' RS, and in turn all other Contacts
    private static void testSingleContactUpdate() {
        system.runas(getTestUser('u1@testorg.com')){
            list<Account> accounts = createAccounts(1);
            list<Contact> contacts = createContacts(accounts, 3);
    
            contacts[0].Repeater_Status__c = KNOWN;
            Test.startTest();
            update contacts;
            Test.stopTest();
            
            list<account> accountResults = [select id, Repeater_Status__c from Account where id = :accounts[0].id];
            system.assertEquals(1, accountResults.size());
            system.assertEquals(KNOWN, accountResults[0].Repeater_Status__c);
            
            list<contact> contactresults = [select id, Repeater_Status__c from Contact where id in :getIds(contacts)];
            system.assertEquals(3, contactresults.size());
            for(contact c : contactresults) {
                system.assertEquals(KNOWN, c.Repeater_Status__c);
            }            
        }            	
    }

    @isTest  // Updating the Repeater status of an account should update Accounts' RS, and in turn all other Contacts
    private static void testNewContactRepeaterAccount() {
        system.runas(getTestUser('u1@testorg.com')){
            list<Account> accounts = createAccounts(1);
            accounts[0].Repeater_Status__c = KNOWN;
            update accounts;
            
            list<Contact> contacts;
            Test.startTest();
            contacts = createContacts(accounts, 1);
            Test.stopTest();
            
            list<contact> contactresults = [select id, Repeater_Status__c from Contact where id in :getIds(contacts)];
            system.assertEquals(1, contactresults.size());
            system.assertEquals(KNOWN, contactresults[0].Repeater_Status__c);            
        }       
    }


    @isTest  // Change the account of a contact should *not* change the account's Repeater Status
    private static void testContactChangesAccount() {
        system.runas(getTestUser('u1@testorg.com')){
            list<Account> accounts = createAccounts(2);
            list<Contact> contacts = createContacts(accounts, 1);
            
            contacts[0].Repeater_Status__c = SUSPECTED;  //Account 1
            contacts[1].Repeater_Status__c = KNOWN;      //Account 2
            update contacts;
            
            //Preconditions
            list<Account> accountPreconditions = [select id, Repeater_Status__c from Account where id in :getIds(accounts) order by name asc]; //getName provides sortable names
            system.assertEquals(contacts[0].accountid, accounts[0].id); //confirm the sort gave us the accounts in the correct order
            system.assertEquals(contacts[0].Repeater_Status__c, accountPreconditions[0].Repeater_Status__c);
            system.assertEquals(contacts[1].Repeater_Status__c, accountPreconditions[1].Repeater_Status__c);
    
            //reset static context for unit test
            sf_RepeaterHelper.processed = new set<id>();
            
            contacts[1].Primary_Address_Line_1__c = accounts[0].Address_Line_1__c; 
            contacts[1].accountId = accounts[0].id; // reparent contact
            Test.startTest();
            update contacts;
            Test.stopTest();
            
            list<account> accountResults = [select id, Repeater_Status__c from Account where id = :accounts[0].id];
            system.assertEquals(SUSPECTED, accountResults[0].Repeater_Status__c); // Account should not have changed
            list<contact> contactResults = [select id, Repeater_Status__c from Contact where id = :contacts[1].id];
            system.assertEquals(KNOWN, contactResults[0].Repeater_Status__c);            
        }
    }

    @isTest  // Change the account of a contact should can change the contact's Repeater Status
    private static void testContactChangesFromAccount() {
        system.runas(getTestUser('u1@testorg.com')){
        	list<Account> accounts = createAccounts(2);
            list<Contact> contacts = createContacts(accounts, 1);
            
            contacts[0].Repeater_Status__c = KNOWN;      //Account 1
            update contacts;
            
            //Preconditions
            list<Account> accountPreconditions = [select id, Repeater_Status__c from Account where id in :getIds(accounts) order by name asc]; //getName provides sortable names
            system.assertEquals(contacts[0].accountid, accounts[0].id); //confirm the sort gave us the accounts in the correct order
            system.assertEquals(contacts[0].Repeater_Status__c, accountPreconditions[0].Repeater_Status__c);
            system.assertEquals(contacts[1].Repeater_Status__c, accountPreconditions[1].Repeater_Status__c);
    
            //reset static context for unit test
            sf_RepeaterHelper.processed = new set<id>();
            
            contacts[1].Primary_Address_Line_1__c = accounts[0].Address_Line_1__c; 
            contacts[1].accountId = accounts[0].id; // reparent contact
            Test.startTest();
            update contacts;
            Test.stopTest();
            
            list<contact> contactResults = [select id, Repeater_Status__c from Contact where id = :contacts[1].id];
            system.assertEquals(SUSPECTED, contactResults[0].Repeater_Status__c);            
        }
    }


    @isTest  // Case created with known repeater contact should be flagged pending validation
    private static void testRepeaterContactSetsCaseRepeater() {
        system.runas(getTestUser('u1@testorg.com')){
            list<Account> accounts = createAccounts(1);
            list<Contact> contacts = createContacts(accounts, 1);
            contacts[0].Repeater_Status__c = KNOWN;
            update contacts;
    
            //set only contact no account
            case testCase = new Case(Contactid = contacts[0].id, subject=getName('Case'));
            insert testCase;
            testCase.Status = CLOSED;
    
            Test.startTest();
            update testCase;
            Test.stopTest();
            
            list<case> caseResults = [select id, Repeater_Case__c from case where id = :testCase.id];
            //system.assertEquals(sf_RepeaterHelper.CASE_PENDING_VALIDATION, caseResults[0].Repeater_Case__c);            
        }         
    }

    @isTest  // Case created with suspected repeater account should be flagged pending validation
    private static void testRepeaterAccountSetsCaseRepeater() {
        system.runas(getTestUser('u1@testorg.com')){
            list<Account> accounts = createAccounts(1);
            accounts[0].Repeater_Status__c = SUSPECTED;
            update accounts;
    
            //set only account no contact
            case testCase = new Case(accountid = accounts[0].id, subject=getName('Case'));
            insert testCase;
            testCase.Status = CLOSED;
    
            Test.startTest();
            update testCase;
            Test.stopTest();
            
            list<case> caseResults = [select id, Repeater_Case__c from case where id = :testCase.id];
            //system.assertEquals(sf_RepeaterHelper.CASE_PENDING_VALIDATION, caseResults[0].Repeater_Case__c);            
        }      
    }

    
    @isTest  // Bulk up
    private static void testBulkAccountUpdate() {
        system.runas(getTestUser('u1@testorg.com')){
            list<Account> accounts = createAccounts(200);
            list<Contact> contacts = createContacts(accounts, 10);
    
            for(Account a : accounts) {
                a.Repeater_Status__c = SUSPECTED;
            }
            Test.startTest();
            update accounts;
            Test.stopTest();
            
            list<contact> results = [select id, Repeater_Status__c from Contact where id in :getIds(contacts) and Repeater_Status__c = :SUSPECTED];
            system.assertEquals(2000, results.size());            
        }
    }

    @isTest  // Bulk contacts
    private static void testBulkContactUpdate() {
        system.runas(getTestUser('u1@testorg.com')){
            list<Account> accounts = createAccounts(200);
            list<Contact> contacts = createContacts(accounts, 2);
    
            for(integer i=0; i<400; i+=2) { //update one contact per account
                contacts[i].Repeater_Status__c = KNOWN;
            }
            Test.startTest();
            update contacts;
            Test.stopTest();
            
            list<account> accountResults = [select id, Repeater_Status__c from Account where id in :getIds(accounts) and Repeater_Status__c = :KNOWN];
            system.assertEquals(200, accountResults.size());
            
            list<contact> contactresults = [select id, Repeater_Status__c from Contact where id in :getIds(contacts) and Repeater_Status__c = :KNOWN];
            system.assertEquals(400, contactresults.size());
            for(contact c : contactresults) {
                system.assertEquals(KNOWN, c.Repeater_Status__c);
            }            
        }
    }

    @isTest  // Not a repeater
    private static void testNonRepeater() {
        system.runas(getTestUser('u1@testorg.com')){
            //setupThresholds();//ChrisM replaced with @testSetup method
            list<Account> accounts = createAccounts(1);
            list<Contact> contacts = createContacts(accounts, 1);
            list<Case> cases = createCases(contacts, 1);
            case testCase = cases[0];
            testCase.Status = CLOSED;
            
            Test.startTest();
            update testCase;
            Test.stopTest();
     
            list<Account> accountResults = [select id, Repeater_Status__c from Account where id in :getIds(accounts)];
            system.assert(String.isBlank(accountResults[0].Repeater_Status__c));            
        }
 
    }

    @isTest  // repeater by case count
    private static void testCountRepeater() {
        system.runas(getTestUser('u1@testorg.com')){
            //setupThresholds();//ChrisM replaced with @testSetup method
            list<Account> accounts = createAccounts(1);
            list<Contact> contacts = createContacts(accounts, 1);
            list<Case> oldCases = createCases(contacts, 4, 10); // 4 cases, 10 days old
            list<Case> cases = createCases(contacts, 1);
            case testCase = cases[0];
            testCase.Status = CLOSED;
            
            Test.startTest();
            update testCase;
            Test.stopTest();
     
            list<Account> accountResults = [select id, Repeater_Status__c from Account where id in :getIds(accounts)];
            //system.assertEquals(SUSPECTED, accountResults[0].Repeater_Status__c);            
        } 
    }

    @isTest  // not a repeater by case count, existing cases outside threshold period
    private static void testCountNonRepeater() {
        system.runas(getTestUser('u1@testorg.com')){
            //setupThresholds();//ChrisM replaced with @testSetup method
            list<Account> accounts = createAccounts(1);
            list<Contact> contacts = createContacts(accounts, 1);
            list<Case> oldCases = createCases(contacts, 4, 35); // 4 cases, 35 days old
            list<Case> cases = createCases(contacts, 1);
            case testCase = cases[0];
            testCase.Status = CLOSED;
            
            Test.startTest();
            update testCase;
            Test.stopTest();
     
            list<Account> accountResults = [select id, Repeater_Status__c from Account where id in :getIds(accounts)];
            //system.assertNotEquals(true, String.isBlank(accountResults[0].Repeater_Status__c));            
        }
    }

    @isTest  // repeater by total fulfillment amount
    private static void testAmountRepeater() {
        system.runas(getTestUser('u1@testorg.com')){
            //setupThresholds();//ChrisM replaced with @testSetup method
            list<Account> accounts = createAccounts(1);
            list<Contact> contacts = createContacts(accounts, 1);
            list<Case> oldCases = createCases(contacts, 1, 10); // 1 cases, 10 days old
            list<Case> cases = createCases(contacts, 1);
            list<Case> allCases = oldCases.clone();
            allCases.addAll(cases);        
            list<Fulfillment_Order__c> orders = createFulfillmentOrders(allCases, 10.00);
            
            case testCase = cases[0];
            testCase.Status = CLOSED;
            
            Test.startTest();
            update testCase;
            Test.stopTest();
     
            list<Account> accountResults = [select id, Repeater_Status__c from Account where id in :getIds(accounts)];
            //system.assertEquals(SUSPECTED, accountResults[0].Repeater_Status__c);            
        } 
    }

    @isTest  // not a repeater by total fulfillment amount, existing cases outside threshold period
    private static void testAmountNonRepeater() {
        system.runas(getTestUser('u1@testorg.com')){
            //setupThresholds();//ChrisM replaced with @testSetup method
            list<Account> accounts = createAccounts(1);
            list<Contact> contacts = createContacts(accounts, 1);
            list<Case> oldCases = createCases(contacts, 1, 35); // 1 cases, 35 days old
            list<Case> cases = createCases(contacts, 1);
            list<Case> allCases = oldCases.clone();
            allCases.addAll(cases);        
            list<Fulfillment_Order__c> orders = createFulfillmentOrders(allCases, 10.00);
            
            case testCase = cases[0];
            testCase.Status = CLOSED;
            
            Test.startTest();
            update testCase;
            Test.stopTest();
     
            list<Account> accountResults = [select id, Repeater_Status__c from Account where id in :getIds(accounts)];
            //system.assertNotEquals(true, String.isBlank(accountResults[0].Repeater_Status__c));            
        }
    }

    @isTest  // bulk test of repeater logic
    private static void testBulkRepeater() {
        system.runas(getTestUser('u1@testorg.com')){
            //setupThresholds();//ChrisM replaced with @testSetup method
            list<Account> accounts = createAccounts(10);
            list<Contact> contacts = createContacts(accounts, 1);
            list<Case> oldCases = createCases(contacts, 4, 10); // 4 cases, 10 days old
            list<Case> cases = createCases(contacts, 1);
            for (Case testCase : cases) {
                testCase.Status = CLOSED;
            }
            
            Test.startTest();
            update cases;
            Test.stopTest();
     
            list<Account> accountResults = [select id, Repeater_Status__c from Account where id in :getIds(accounts) and Repeater_Status__c = :SUSPECTED];
            //system.assertEquals(10, accountResults.size());            
        }
    }

    @isTest  //when case.Repeater_Case__c becomes Pending, ffmt orders should become draft
    private static void testPendingCaseUpdateFulfillment() {
        system.runas(getTestUser('u1@testorg.com')){
            //setupThresholds();//ChrisM replaced with @testSetup method
            list<Account> accounts = createAccounts(1);
            list<Contact> contacts = createContacts(accounts, 1);
            list<Case> cases = createCases(contacts, 1);
            list<Fulfillment_Order__c> orders = createFulfillmentOrders(cases, 10.00);
            
            case testCase = cases[0];
            testCase.Status = CLOSED;
            update testCase;
            
            testCase.Repeater_Case__c = sf_RepeaterHelper.CASE_PENDING_VALIDATION;
            Test.startTest();
            update testCase;
            Test.stopTest();
     
            list<Fulfillment_Order__c> orderResults = [select id, status__c from Fulfillment_Order__c where id = :orders[0].id];
            system.assertEquals(sf_RepeaterHelper.FULFILLMENT_ORDER_DRAFT, orderResults[0].status__c);            
        }
    }

    /*sTest  //when case.Repeater_Case__c becomes Pending, FL-only ffmt orders should not change
    private static void testPendingCaseUpdateFLFulfillment() {
        setupThresholds();
        list<Account> accounts = createAccounts(1);
        list<Contact> contacts = createContacts(accounts, 1);
        list<Case> cases = createCases(contacts, 1);
        list<Fulfillment_Order__c> orders = createFulfillmentOrders(cases, 10.00, 'FL');
        
        case testCase = cases[0];
        testCase.Status = CLOSED;
        update testCase;
        
        testCase.Repeater_Case__c = sf_RepeaterHelper.CASE_PENDING_VALIDATION;
        Test.startTest();
        update testCase;
        Test.stopTest();
 
        list<Fulfillment_Order__c> orderResults = [select id, status__c from Fulfillment_Order__c where id = :orders[0].id];
        system.assertEquals(sf_RepeaterHelper.FULFILLMENT_ORDER_OPEN, orderResults[0].status__c);
    }*/


    /*isTest  //when case.Repeater_Case__c becomes Fraud, ffmt orders should become deleted
    private static void testFraudCaseUpdateFulfillment() {
        setupThresholds();
        list<Account> accounts = createAccounts(1);
        list<Contact> contacts = createContacts(accounts, 1);
        list<Case> cases = createCases(contacts, 1);
        list<Fulfillment_Order__c> orders = createFulfillmentOrders(cases, 10.00);
        
        case testCase = cases[0];
        testCase.Status = CLOSED;
        update testCase;
        
        testCase.Repeater_Case__c = sf_RepeaterHelper.CASE_PENDING_VALIDATION;
        update testCase;

        testCase.Repeater_Case__c = sf_RepeaterHelper.CASE_FRAUD_CASE;
        Test.startTest();
        update testCase;
        Test.stopTest();
 
        list<Fulfillment_Order__c> orderResults = [select id, status__c from Fulfillment_Order__c where id = :orders[0].id];
        system.assertEquals(sf_RepeaterHelper.FULFILLMENT_ORDER_DELETED, orderResults[0].status__c);
    }*/
    
    /*@isTest  //when case.Repeater_Case__c becomes blank, ffmt orders should become open
    private static void testClearCaseUpdateFulfillment() {
        setupThresholds();
        list<Account> accounts = createAccounts(1);
        list<Contact> contacts = createContacts(accounts, 1);
        list<Case> cases = createCases(contacts, 1);
        list<Fulfillment_Order__c> orders = createFulfillmentOrders(cases, 10.00);
        
        case testCase = cases[0];
        testCase.Status = CLOSED;
        update testCase;
        
        testCase.Repeater_Case__c = sf_RepeaterHelper.CASE_FRAUD_CASE;
        update testCase;

        testCase.Repeater_Case__c = null;
        Test.startTest();
        update testCase;
        Test.stopTest();
 
        list<Fulfillment_Order__c> orderResults = [select id, status__c from Fulfillment_Order__c where id = :orders[0].id];
        system.assertEquals(sf_RepeaterHelper.FULFILLMENT_ORDER_OPEN, orderResults[0].status__c);
    
    }*/      

    /*@isTest  //when case.Repeater_Case__c becomes Pending due to account status, ffmt orders should become draft
    private static void testIntegraredPendingCaseUpdateFulfillment() {
        setupThresholds();
        list<Account> accounts = createAccounts(1);
        accounts[0].Repeater_Status__c = SUSPECTED;
        update accounts;
        list<Contact> contacts = createContacts(accounts, 1);
        list<Case> cases = createCases(contacts, 1);
        list<Fulfillment_Order__c> orders = createFulfillmentOrders(cases, 10.00);
        
        case testCase = cases[0];
        testCase.Status = CLOSED;
                
        Test.startTest();
        update testCase;
        Test.stopTest();

        list<Fulfillment_Order__c> orderResults = [select id, status__c from Fulfillment_Order__c where id = :orders[0].id];
        //system.assertEquals(sf_RepeaterHelper.FULFILLMENT_ORDER_DRAFT, orderResults[0].status__c);
    }*/

    /*@isTest  //when fulfillment order is cleared, case should be cleared
    private static void testClearedFulfillmentClearsCase() {
        setupThresholds();
        list<Account> accounts = createAccounts(1);
        accounts[0].Repeater_Status__c = SUSPECTED;
        update accounts;
        list<Contact> contacts = createContacts(accounts, 1);
        list<Case> cases = createCases(contacts, 1);
        list<Fulfillment_Order__c> orders = createFulfillmentOrders(cases, 10.00);
        
        case testCase = cases[0];
        testCase.Status = CLOSED;
        update testCase;

        orders[0].Status__c = sf_RepeaterHelper.FULFILLMENT_ORDER_OPEN;                 
        Test.startTest();
        update orders;
        Test.stopTest();

        list<Case> caseResults = [select id, Repeater_Case__c from Case where id = :cases[0].id];
        system.assert(string.isBlank(caseResults[0].Repeater_Case__c));
    }*/

    /*@isTest  //when fulfillment order is cleared, case should be cleared, and all order FFmt orders
    private static void testClearedFulfillmentClearsCaseChained() {
        setupThresholds();
        list<Account> accounts = createAccounts(1);
        accounts[0].Repeater_Status__c = SUSPECTED;
        update accounts;
        list<Contact> contacts = createContacts(accounts, 1);
        list<Case> cases = createCases(contacts, 1);
        list<Fulfillment_Order__c> orders = createFulfillmentOrders(cases, 10.00);
        orders.addAll(createFulfillmentOrders(cases, 10.00));
        
        case testCase = cases[0];
        testCase.Status = CLOSED;
        update testCase;

        orders[0].Status__c = sf_RepeaterHelper.FULFILLMENT_ORDER_OPEN;                 
        Test.startTest();
        update orders;
        Test.stopTest();

        list<Case> caseResults = [select id, Repeater_Case__c from Case where id = :cases[0].id];
        system.assert(string.isBlank(caseResults[0].Repeater_Case__c));
        list<Fulfillment_Order__c> orderResults = [select id from Fulfillment_Order__c where id in :getIds(orders) and Status__c = :sf_RepeaterHelper.FULFILLMENT_ORDER_OPEN];
        system.assertEquals(2, orderResults.size());
    }*/

    @isTest  //when a Suspected/Known repeater case is re-closed, any new Fulfillment orders should be updated to Pending Validation
    private static void testReclosingRepeaterCaseUpdatesFulfillment() {
        system.runas(getTestUser('u1@testorg.com')){
            //setupThresholds();//ChrisM replaced with @testSetup method
            list<Account> accounts = createAccounts(1);
            accounts[0].Repeater_Status__c = SUSPECTED;
            update accounts;
            list<Contact> contacts = createContacts(accounts, 1);
            list<Case> cases = createCases(contacts, 1);
    
            //fake a previously closed case
            cases[0].Repeater_Case__c = sf_RepeaterHelper.CASE_PENDING_VALIDATION;
            cases[0].Repeater_Status_Checked__c = true;
            update cases;
    
            list<Fulfillment_Order__c> orders = createFulfillmentOrders(cases, 10.00);
            cases[0].status = CLOSED;
            
            Test.startTest();
            update cases;
            Test.stopTest();
    
            list<Fulfillment_Order__c> orderResults = [select id, status__c from Fulfillment_Order__c where id = :orders[0].id];
            system.assertEquals(sf_RepeaterHelper.FULFILLMENT_ORDER_DRAFT, orderResults[0].status__c);            
        }
    }
}